program test_rag;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, doclookup;

procedure AssertTrue(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create('ASSERT FAILED: ' + AMessage);
end;

procedure WriteFile(const APath, AText: string);
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Text := AText;
    S.SaveToFile(APath);
  finally
    S.Free;
  end;
end;

var
  Dir: string;
  Hits: TDocHitArray;
  Context: string;
begin
  Dir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
         'robotinics-rag-test-' + IntToStr(GetProcessID);
  ForceDirectories(Dir);

  WriteFile(IncludeTrailingPathDelimiter(Dir) + 'motores.md',
    '# Controle de Motores' + LineEnding +
    'FRENTE RE PARA GESQ GDIR controle dos motores e safety.');
  WriteFile(IncludeTrailingPathDelimiter(Dir) + 'camera.md',
    '# Visao' + LineEnding +
    'camera tracking imagem calibracao pan tilt.');

  Hits := SearchDocumentation(Dir, 'motores frente safety', 5, 10000);
  AssertTrue(Length(Hits) > 0, 'hits returned');
  AssertTrue(Pos('motores.md', LowerCase(Hits[0].Path)) > 0, 'motor doc ranked first');
  AssertTrue(Hits[0].Score > 0, 'positive score');
  AssertTrue(Hits[0].Title <> '', 'title metadata');

  Context := LookupDocumentation(Dir, 'motores frente safety', 5, 10000);
  AssertTrue(Pos('METADATA:', Context) > 0, 'metadata emitted');
  AssertTrue(Pos('"score"', Context) > 0, 'score metadata emitted');

  Writeln('RAG tests: OK');
end.
