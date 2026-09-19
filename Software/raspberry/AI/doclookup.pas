unit doclookup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpjson;

type
  TDocHit = record
    Path: string;
    Title: string;
    Score: Double;
    TokenCount: Integer;
    Content: string;
  end;

  TDocHitArray = array of TDocHit;

function SearchDocumentation(const ARoot, AQuery: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000): TDocHitArray;

function LookupDocumentation(const ARoot, AQuery: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000): string;

implementation

type
  TDocRecord = class
  public
    Path: string;
    Title: string;
    Text: string;
    Tokens: TStringList;
    TokenCount: Integer;
    destructor Destroy; override;
  end;

destructor TDocRecord.Destroy;
begin
  Tokens.Free;
  inherited Destroy;
end;

function NormalizeText(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := LowerCase(S);
  for I := 1 to Length(Result) do
  begin
    C := Result[I];
    if not (C in ['a'..'z', '0'..'9', '_', '-', '/', '.']) then
      Result[I] := ' ';
  end;
end;

function Tokenize(const S: string): TStringList;
var
  N: string;
  P: TStringList;
  I: Integer;
  T: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
  N := NormalizeText(S);
  P := TStringList.Create;
  try
    P.Delimiter := ' ';
    P.StrictDelimiter := True;
    P.DelimitedText := N;
    for I := 0 to P.Count - 1 do
    begin
      T := Trim(P[I]);
      if Length(T) < 3 then Continue;
      Result.Add(T);
    end;
  finally
    P.Free;
  end;
end;

function CountToken(const Text, Token: string): Integer;
var
  LText, Needle: string;
  P, StartAt: Integer;
begin
  Result := 0;
  LText := NormalizeText(Text);
  Needle := ' ' + LowerCase(Token) + ' ';
  LText := ' ' + LText + ' ';
  StartAt := 1;
  repeat
    P := Pos(Needle, Copy(LText, StartAt, MaxInt));
    if P <= 0 then Break;
    Inc(Result);
    Inc(StartAt, P + Length(Needle) - 1);
  until False;
end;

function CountWordsSimple(const S: string): Integer;
var
  I: Integer;
  InWord: Boolean;
begin
  Result := 0;
  InWord := False;
  for I := 1 to Length(S) do
  begin
    if S[I] in [' ', #9, #10, #13] then
      InWord := False
    else if not InWord then
    begin
      InWord := True;
      Inc(Result);
    end;
  end;
end;

function ExtractTitle(const Path, Text: string): string;
var
  Lines: TStringList;
  I: Integer;
  S: string;
begin
  Result := ChangeFileExt(ExtractFileName(Path), '');
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for I := 0 to Lines.Count - 1 do
    begin
      S := Trim(Lines[I]);
      if S = '' then Continue;
      if Copy(S, 1, 1) = '#' then
      begin
        while (Length(S) > 0) and (S[1] = '#') do
          Delete(S, 1, 1);
        S := Trim(S);
      end;
      if S <> '' then
      begin
        Result := S;
        Exit;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure ScanDir(const Dir: string; Docs: TList);
var
  SR: TSearchRec;
  Path, Ext: string;
  S: TStringList;
  D: TDocRecord;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR) <> 0 then Exit;
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then Continue;
      Path := IncludeTrailingPathDelimiter(Dir) + SR.Name;

      if (SR.Attr and faDirectory) <> 0 then
      begin
        if (SR.Name <> '.git') and (SR.Name <> 'build') and
           (SR.Name <> 'tmp') and (SR.Name <> 'node_modules') then
          ScanDir(Path, Docs);
        Continue;
      end;

      Ext := LowerCase(ExtractFileExt(Path));
      if (Ext <> '.md') and (Ext <> '.txt') then Continue;

      S := TStringList.Create;
      try
        try
          S.LoadFromFile(Path);
          D := TDocRecord.Create;
          D.Path := Path;
          D.Text := S.Text;
          D.Title := ExtractTitle(Path, D.Text);
          D.Tokens := Tokenize(D.Text);
          D.TokenCount := Max(1, CountWordsSimple(D.Text));
          Docs.Add(D);
        except
        end;
      finally
        S.Free;
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function DocumentFrequency(Docs: TList; const Token: string): Integer;
var
  I: Integer;
  D: TDocRecord;
begin
  Result := 0;
  for I := 0 to Docs.Count - 1 do
  begin
    D := TDocRecord(Docs[I]);
    if D.Tokens.IndexOf(Token) >= 0 then
      Inc(Result);
  end;
end;

function BM25Score(D: TDocRecord; Docs: TList; QueryTokens: TStringList;
  AvgLen: Double): Double;
const
  K1 = 1.5;
  B = 0.75;
var
  I, TF, DF, N: Integer;
  Token: string;
  IDF, Den, TitleBoost, PathBoost: Double;
  LTitle, LPath: string;
begin
  Result := 0.0;
  N := Max(1, Docs.Count);
  LTitle := LowerCase(D.Title);
  LPath := LowerCase(D.Path);

  for I := 0 to QueryTokens.Count - 1 do
  begin
    Token := QueryTokens[I];
    TF := CountToken(D.Text, Token);
    if TF = 0 then Continue;

    DF := DocumentFrequency(Docs, Token);
    IDF := Ln(1.0 + (N - DF + 0.5) / (DF + 0.5));
    Den := TF + K1 * (1.0 - B + B * D.TokenCount / Max(1.0, AvgLen));
    Result := Result + IDF * ((TF * (K1 + 1.0)) / Den);

    TitleBoost := 0.0;
    PathBoost := 0.0;
    if Pos(Token, LTitle) > 0 then TitleBoost := 1.5 * IDF;
    if Pos(Token, LPath) > 0 then PathBoost := 0.5 * IDF;
    Result := Result + TitleBoost + PathBoost;
  end;
end;

procedure SortHits(var Hits: TDocHitArray);
var
  I, J: Integer;
  T: TDocHit;
begin
  for I := 0 to High(Hits) - 1 do
    for J := I + 1 to High(Hits) do
      if Hits[J].Score > Hits[I].Score then
      begin
        T := Hits[I];
        Hits[I] := Hits[J];
        Hits[J] := T;
      end;
end;

function SearchDocumentation(const ARoot, AQuery: string;
  AMaxFiles: Integer; AMaxChars: Integer): TDocHitArray;
var
  Docs: TList;
  QueryTokens: TStringList;
  I, Count, UsedChars, TotalLen: Integer;
  D: TDocRecord;
  AvgLen, Score: Double;
  AllHits: TDocHitArray;
begin
  SetLength(Result, 0);
  if not DirectoryExists(ARoot) then Exit;

  Docs := TList.Create;
  QueryTokens := Tokenize(AQuery);
  try
    ScanDir(ARoot, Docs);
    if (Docs.Count = 0) or (QueryTokens.Count = 0) then Exit;

    TotalLen := 0;
    for I := 0 to Docs.Count - 1 do
      Inc(TotalLen, TDocRecord(Docs[I]).TokenCount);
    AvgLen := TotalLen / Max(1, Docs.Count);

    SetLength(AllHits, 0);
    for I := 0 to Docs.Count - 1 do
    begin
      D := TDocRecord(Docs[I]);
      Score := BM25Score(D, Docs, QueryTokens, AvgLen);
      if Score <= 0 then Continue;

      SetLength(AllHits, Length(AllHits) + 1);
      AllHits[High(AllHits)].Path := D.Path;
      AllHits[High(AllHits)].Title := D.Title;
      AllHits[High(AllHits)].Score := Score;
      AllHits[High(AllHits)].TokenCount := D.TokenCount;
      AllHits[High(AllHits)].Content := D.Text;
    end;

    SortHits(AllHits);

    Count := 0;
    UsedChars := 0;
    for I := 0 to High(AllHits) do
    begin
      if Count >= AMaxFiles then Break;
      if UsedChars >= AMaxChars then Break;

      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := AllHits[I];

      if Length(Result[High(Result)].Content) > (AMaxChars - UsedChars) then
        SetLength(Result[High(Result)].Content, AMaxChars - UsedChars);

      Inc(UsedChars, Length(Result[High(Result)].Content));
      Inc(Count);
    end;
  finally
    for I := 0 to Docs.Count - 1 do
      TObject(Docs[I]).Free;
    Docs.Free;
    QueryTokens.Free;
  end;
end;

function LookupDocumentation(const ARoot, AQuery: string;
  AMaxFiles: Integer; AMaxChars: Integer): string;
var
  Hits: TDocHitArray;
  I: Integer;
  Meta: TJSONObject;
begin
  Result := '';
  Hits := SearchDocumentation(ARoot, AQuery, AMaxFiles, AMaxChars);

  for I := 0 to High(Hits) do
  begin
    if Result <> '' then
      Result := Result + LineEnding + LineEnding;

    Meta := TJSONObject.Create;
    try
      Meta.Add('path', Hits[I].Path);
      Meta.Add('title', Hits[I].Title);
      Meta.Add('score', Hits[I].Score);
      Meta.Add('tokens', Hits[I].TokenCount);

      Result := Result +
        '=== DOCUMENT ===' + LineEnding +
        'METADATA: ' + Meta.AsJSON + LineEnding +
        Hits[I].Content;
    finally
      Meta.Free;
    end;
  end;
end;

end.
