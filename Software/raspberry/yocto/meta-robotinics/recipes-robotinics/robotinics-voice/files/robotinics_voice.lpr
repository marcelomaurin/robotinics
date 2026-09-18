program robotinics_voice;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Process,
  aivoicesynthesizer;

const
  EXIT_OK = 0;
  EXIT_USAGE = 2;
  EXIT_CONFIG = 3;
  EXIT_TTS = 4;
  EXIT_PLAYBACK = 5;

function Env(const AName, ADefault: string): string;
begin
  Result := GetEnvironmentVariable(AName);
  if Result = '' then
    Result := ADefault;
end;

function LoadTextFile(const AFileName: string): string;
var
  S: TStringList;
begin
  if not FileExists(AFileName) then
    raise Exception.Create('Arquivo não encontrado: ' + AFileName);

  S := TStringList.Create;
  try
    S.LoadFromFile(AFileName);
    Result := Trim(S.Text);
  finally
    S.Free;
  end;
end;

function CollectTextFromArgs(AStart: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := AStart to ParamCount do
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + ParamStr(I);
  end;
end;

procedure Usage;
begin
  Writeln('Robotinics Voice - TCHATGPT / TAIVoiceSynthesizer');
  Writeln;
  Writeln('Uso interno:');
  Writeln('  robotinics-voice --text "texto"');
  Writeln('  robotinics-voice --file arquivo.txt');
  Writeln;
  Writeln('Entradas públicas compatíveis:');
  Writeln('  robotinics-speak "texto"');
  Writeln('  robotinics-read-file arquivo.txt');
end;

function PlayWavSync(const AFileName: string): Boolean;
var
  P: TProcess;
begin
  Result := False;

  if not FileExists(AFileName) then
    Exit;

  P := TProcess.Create(nil);
  try
    P.Executable := Env('ROBOTINICS_AUDIO_PLAYER', '/usr/bin/aplay');
    P.Parameters.Add(AFileName);
    P.Options := [poWaitOnExit, poUsePipes];

    try
      P.Execute;
      Result := P.ExitStatus = 0;
      if not Result then
        Writeln(StdErr, 'Falha ao reproduzir áudio. ExitStatus=', P.ExitStatus);
    except
      on E: Exception do
      begin
        Writeln(StdErr, 'Falha ao iniciar player: ', E.Message);
        Result := False;
      end;
    end;
  finally
    P.Free;
  end;
end;

function ParseSpeed(const S: string): Double;
var
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  if not TryStrToFloat(S, Result, FS) then
    Result := 1.0;
end;

var
  Synth: TAIVoiceSynthesizer;
  TextToSpeak: string;
  OutputFile: string;
  Token: string;
  Mode: string;
  InputValue: string;
  ExitCodeValue: Integer;
begin
  ExitCodeValue := EXIT_OK;

  try
    if ParamCount < 2 then
    begin
      Usage;
      Halt(EXIT_USAGE);
    end;

    Mode := ParamStr(1);

    if Mode = '--text' then
      TextToSpeak := Trim(CollectTextFromArgs(2))
    else if Mode = '--file' then
    begin
      InputValue := ParamStr(2);
      TextToSpeak := LoadTextFile(InputValue);
    end
    else
    begin
      Usage;
      Halt(EXIT_USAGE);
    end;

    if TextToSpeak = '' then
    begin
      Writeln(StdErr, 'Texto vazio.');
      Halt(EXIT_USAGE);
    end;

    Token := Env('ROBOTINICS_TTS_TOKEN', Env('ROBOTINICS_LLM_TOKEN', ''));
    if Token = '' then
    begin
      Writeln(StdErr, 'ROBOTINICS_TTS_TOKEN ou ROBOTINICS_LLM_TOKEN não configurado.');
      Halt(EXIT_CONFIG);
    end;

    OutputFile := Env('ROBOTINICS_TTS_OUTPUT', '/tmp/robotinics-voice.wav');

    Synth := TAIVoiceSynthesizer.Create(nil);
    try
      Synth.Engine := seOpenAI;
      Synth.Asynchronous := False;
      Synth.OpenAIToken := Token;
      Synth.OpenAIEndpoint := Env('ROBOTINICS_TTS_ENDPOINT',
        'https://api.openai.com/v1/audio/speech');
      Synth.OpenAIModel := Env('ROBOTINICS_TTS_MODEL', 'gpt-4o-mini-tts');
      Synth.OpenAIVoice := Env('ROBOTINICS_TTS_VOICE', 'alloy');
      Synth.OpenAIOutputFormat := 'wav';
      Synth.OpenAIOutputFile := OutputFile;
      Synth.Language := Env('ROBOTINICS_TTS_LANGUAGE', 'pt-BR');
      Synth.OpenAIInstructions := Env('ROBOTINICS_TTS_INSTRUCTIONS',
        'Fale de forma clara, natural e objetiva.');
      Synth.Speed := ParseSpeed(Env('ROBOTINICS_TTS_SPEED', '1.0'));

      Synth.Say(TextToSpeak);

      if not Synth.LastSuccess then
      begin
        Writeln(StdErr, 'Erro TTS: ', Synth.LastError);
        Halt(EXIT_TTS);
      end;
    finally
      Synth.Free;
    end;

    if not PlayWavSync(OutputFile) then
      ExitCodeValue := EXIT_PLAYBACK;

  except
    on E: Exception do
    begin
      Writeln(StdErr, 'Erro: ', E.Message);
      ExitCodeValue := EXIT_TTS;
    end;
  end;

  Halt(ExitCodeValue);
end.
