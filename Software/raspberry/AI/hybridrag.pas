unit hybridrag;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpjson, jsonparser, fphttpclient, opensslsockets;

type
  TDoubleArray = array of Double;

  THybridHit = record
    Path: string;
    Title: string;
    LexicalScore: Double;
    SemanticScore: Double;
    FinalScore: Double;
    Content: string;
  end;
  THybridHitArray = array of THybridHit;

function BuildHybridIndex(const ARoot, AIndexFile, AEmbeddingURL,
  AEmbeddingToken, AEmbeddingModel: string): Integer;

function SearchHybridIndex(const AIndexFile, AQuery, AEmbeddingURL,
  AEmbeddingToken, AEmbeddingModel: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000;
  ALexicalWeight: Double = 0.65): THybridHitArray;

function HybridContext(const AIndexFile, AQuery, AEmbeddingURL,
  AEmbeddingToken, AEmbeddingModel: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000;
  ALexicalWeight: Double = 0.65): string;

implementation

function JsonEscape(const S: string): string;
begin
  Result := StringReplace(S, '', '\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '"', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '
', [rfReplaceAll]);
end;

function ExtractTitle(const Path, Text: string): string;
var
  L: TStringList;
  I: Integer;
  S: string;
begin
  Result := ChangeFileExt(ExtractFileName(Path), '');
  L := TStringList.Create;
  try
    L.Text := Text;
    for I := 0 to L.Count - 1 do
    begin
      S := Trim(L[I]);
      if S = '' then Continue;
      while (Length(S) > 0) and (S[1] = '#') do Delete(S, 1, 1);
      S := Trim(S);
      if S <> '' then Exit(S);
    end;
  finally
    L.Free;
  end;
end;

function Normalize(const S: string): string;
var
  I: Integer;
begin
  Result := LowerCase(S);
  for I := 1 to Length(Result) do
    if not (Result[I] in ['a'..'z','0'..'9','_','-','/','.']) then
      Result[I] := ' ';
end;

function Tokens(const S: string): TStringList;
var
  P: TStringList;
  I: Integer;
  T: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
  P := TStringList.Create;
  try
    P.Delimiter := ' ';
    P.StrictDelimiter := True;
    P.DelimitedText := Normalize(S);
    for I := 0 to P.Count - 1 do
    begin
      T := Trim(P[I]);
      if Length(T) >= 3 then Result.Add(T);
    end;
  finally
    P.Free;
  end;
end;

function CountToken(const Text, Token: string): Integer;
var
  L, N: string;
  P, Offset: Integer;
begin
  Result := 0;
  L := ' ' + Normalize(Text) + ' ';
  N := ' ' + LowerCase(Token) + ' ';
  Offset := 1;
  repeat
    P := Pos(N, Copy(L, Offset, MaxInt));
    if P <= 0 then Break;
    Inc(Result);
    Inc(Offset, P + Length(N) - 1);
  until False;
end;

function LexicalScore(const Title, Path, Text, Query: string): Double;
var
  Q: TStringList;
  I, TF: Integer;
  Tok: string;
begin
  Result := 0;
  Q := Tokens(Query);
  try
    for I := 0 to Q.Count - 1 do
    begin
      Tok := Q[I];
      TF := CountToken(Text, Tok);
      if TF > 0 then
        Result := Result + (1.0 + Ln(1 + TF));
      if Pos(Tok, LowerCase(Title)) > 0 then Result := Result + 1.5;
      if Pos(Tok, LowerCase(Path)) > 0 then Result := Result + 0.5;
    end;
  finally
    Q.Free;
  end;
end;

function GetEmbedding(const URL, Token, ModelName, Text: string): TDoubleArray;
var
  H: TFPHttpClient;
  Body: TStringStream;
  Payload, Raw: string;
  Root, DataItem: TJSONData;
  Arr: TJSONArray;
  I: Integer;
begin
  SetLength(Result, 0);
  if Trim(URL) = '' then Exit;

  Payload := '{"model":"' + JsonEscape(ModelName) + '","input":"' +
             JsonEscape(Text) + '"}';

  H := TFPHttpClient.Create(nil);
  Body := TStringStream.Create(Payload);
  try
    H.AddHeader('Content-Type', 'application/json');
    if Trim(Token) <> '' then H.AddHeader('Authorization', 'Bearer ' + Token);
    H.RequestBody := Body;
    H.IOTimeout := 30000;
    H.ConnectTimeout := 7000;
    Raw := H.Post(URL);
  finally
    Body.Free;
    H.Free;
  end;

  Root := GetJSON(Raw);
  try
    if Root.JSONType <> jtObject then Exit;
    DataItem := TJSONObject(Root).FindPath('data[0].embedding');
    if (DataItem = nil) or (DataItem.JSONType <> jtArray) then Exit;
    Arr := TJSONArray(DataItem);
    SetLength(Result, Arr.Count);
    for I := 0 to Arr.Count - 1 do
      Result[I] := Arr.Floats[I];
  finally
    Root.Free;
  end;
end;

function VectorToJSON(const V: TDoubleArray): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to High(V) do Result.Add(V[I]);
end;

function JSONArrayToVector(A: TJSONArray): TDoubleArray;
var
  I: Integer;
begin
  SetLength(Result, A.Count);
  for I := 0 to A.Count - 1 do Result[I] := A.Floats[I];
end;

function Cosine(const A, B: TDoubleArray): Double;
var
  I, N: Integer;
  Dot, NA, NB: Double;
begin
  Result := 0;
  N := Min(Length(A), Length(B));
  if N = 0 then Exit;
  Dot := 0; NA := 0; NB := 0;
  for I := 0 to N - 1 do
  begin
    Dot := Dot + A[I] * B[I];
    NA := NA + A[I] * A[I];
    NB := NB + B[I] * B[I];
  end;
  if (NA <= 0) or (NB <= 0) then Exit;
  Result := Dot / (Sqrt(NA) * Sqrt(NB));
end;

procedure ScanAndAppend(const Dir, EmbedURL, EmbedToken, EmbedModel: string;
  Docs: TJSONArray; var Count: Integer);
var
  SR: TSearchRec;
  Path, Ext, Text: string;
  S: TStringList;
  O: TJSONObject;
  V: TDoubleArray;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR) <> 0 then Exit;
  try
    repeat
      if (SR.Name='.') or (SR.Name='..') then Continue;
      Path := IncludeTrailingPathDelimiter(Dir) + SR.Name;
      if (SR.Attr and faDirectory) <> 0 then
      begin
        if (SR.Name<>'.git') and (SR.Name<>'build') and (SR.Name<>'tmp') and
           (SR.Name<>'node_modules') then
          ScanAndAppend(Path, EmbedURL, EmbedToken, EmbedModel, Docs, Count);
        Continue;
      end;
      Ext := LowerCase(ExtractFileExt(Path));
      if (Ext<>'.md') and (Ext<>'.txt') then Continue;

      S := TStringList.Create;
      try
        S.LoadFromFile(Path);
        Text := S.Text;
      finally
        S.Free;
      end;

      O := TJSONObject.Create;
      O.Add('path', Path);
      O.Add('title', ExtractTitle(Path, Text));
      O.Add('content', Text);
      O.Add('size', Length(Text));
      O.Add('mtime', SR.Time);

      if Trim(EmbedURL) <> '' then
      begin
        try
          V := GetEmbedding(EmbedURL, EmbedToken, EmbedModel, Text);
          O.Add('embedding', VectorToJSON(V));
        except
          O.Add('embedding', TJSONArray.Create);
        end;
      end
      else
        O.Add('embedding', TJSONArray.Create);

      Docs.Add(O);
      Inc(Count);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function BuildHybridIndex(const ARoot, AIndexFile, AEmbeddingURL,
  AEmbeddingToken, AEmbeddingModel: string): Integer;
var
  Root: TJSONObject;
  Docs: TJSONArray;
  S: TStringList;
  Tmp: string;
begin
  Result := 0;
  Root := TJSONObject.Create;
  Docs := TJSONArray.Create;
  try
    Root.Add('schema_version', 1);
    Root.Add('root', ARoot);
    Root.Add('embedding_model', AEmbeddingModel);
    Root.Add('embedding_enabled', Trim(AEmbeddingURL) <> '');
    Root.Add('documents', Docs);

    if DirectoryExists(ARoot) then
      ScanAndAppend(ARoot, AEmbeddingURL, AEmbeddingToken, AEmbeddingModel, Docs, Result);

    ForceDirectories(ExtractFileDir(AIndexFile));
    Tmp := AIndexFile + '.tmp';
    S := TStringList.Create;
    try
      S.Text := Root.FormatJSON;
      S.SaveToFile(Tmp);
    finally
      S.Free;
    end;
    if FileExists(AIndexFile) then DeleteFile(AIndexFile);
    if not RenameFile(Tmp, AIndexFile) then
      raise Exception.Create('Falha ao gravar indice RAG: ' + AIndexFile);
  finally
    Root.Free;
  end;
end;

procedure SortHits(var Hits: THybridHitArray);
var
  I, J: Integer;
  T: THybridHit;
begin
  for I := 0 to High(Hits)-1 do
    for J := I+1 to High(Hits) do
      if Hits[J].FinalScore > Hits[I].FinalScore then
      begin
        T := Hits[I]; Hits[I] := Hits[J]; Hits[J] := T;
      end;
end;

function SearchHybridIndex(const AIndexFile, AQuery, AEmbeddingURL,
  AEmbeddingToken, AEmbeddingModel: string; AMaxFiles, AMaxChars: Integer;
  ALexicalWeight: Double): THybridHitArray;
var
  S: TStringList;
  Root, D: TJSONData;
  Docs, Emb: TJSONArray;
  O: TJSONObject;
  I, UsedChars: Integer;
  QV, DV: TDoubleArray;
  LScore, SScore, MaxLex: Double;
  All: THybridHitArray;
begin
  SetLength(Result, 0);
  if not FileExists(AIndexFile) then Exit;

  S := TStringList.Create;
  try
    S.LoadFromFile(AIndexFile);
    Root := GetJSON(S.Text);
  finally
    S.Free;
  end;

  try
    Docs := TJSONObject(Root).Arrays['documents'];
    SetLength(All, Docs.Count);
    MaxLex := 0;
    for I := 0 to Docs.Count-1 do
    begin
      O := Docs.Objects[I];
      LScore := LexicalScore(O.Get('title',''), O.Get('path',''),
        O.Get('content',''), AQuery);
      All[I].Path := O.Get('path','');
      All[I].Title := O.Get('title','');
      All[I].Content := O.Get('content','');
      All[I].LexicalScore := LScore;
      if LScore > MaxLex then MaxLex := LScore;
    end;

    SetLength(QV, 0);
    if Trim(AEmbeddingURL) <> '' then
      try QV := GetEmbedding(AEmbeddingURL, AEmbeddingToken, AEmbeddingModel, AQuery);
      except SetLength(QV, 0); end;

    for I := 0 to High(All) do
    begin
      O := Docs.Objects[I];
      SScore := 0;
      D := O.Find('embedding');
      if (D<>nil) and (D.JSONType=jtArray) and (Length(QV)>0) then
      begin
        Emb := TJSONArray(D);
        DV := JSONArrayToVector(Emb);
        SScore := Cosine(QV, DV);
      end;
      All[I].SemanticScore := SScore;
      if MaxLex > 0 then LScore := All[I].LexicalScore / MaxLex else LScore := 0;
      All[I].FinalScore := ALexicalWeight * LScore +
        (1.0 - ALexicalWeight) * Max(0.0, SScore);
    end;

    SortHits(All);
    UsedChars := 0;
    for I := 0 to High(All) do
    begin
      if Length(Result) >= AMaxFiles then Break;
      if UsedChars >= AMaxChars then Break;
      if All[I].FinalScore <= 0 then Continue;
      SetLength(Result, Length(Result)+1);
      Result[High(Result)] := All[I];
      if Length(Result[High(Result)].Content) > AMaxChars-UsedChars then
        SetLength(Result[High(Result)].Content, AMaxChars-UsedChars);
      Inc(UsedChars, Length(Result[High(Result)].Content));
    end;
  finally
    Root.Free;
  end;
end;

function HybridContext(const AIndexFile, AQuery, AEmbeddingURL,
  AEmbeddingToken, AEmbeddingModel: string; AMaxFiles, AMaxChars: Integer;
  ALexicalWeight: Double): string;
var
  Hits: THybridHitArray;
  I: Integer;
  Meta: TJSONObject;
begin
  Result := '';
  Hits := SearchHybridIndex(AIndexFile, AQuery, AEmbeddingURL, AEmbeddingToken,
    AEmbeddingModel, AMaxFiles, AMaxChars, ALexicalWeight);
  for I := 0 to High(Hits) do
  begin
    if Result<>'' then Result := Result + LineEnding + LineEnding;
    Meta := TJSONObject.Create;
    try
      Meta.Add('path', Hits[I].Path);
      Meta.Add('title', Hits[I].Title);
      Meta.Add('lexical_score', Hits[I].LexicalScore);
      Meta.Add('semantic_score', Hits[I].SemanticScore);
      Meta.Add('final_score', Hits[I].FinalScore);
      Result := Result + '=== DOCUMENT ===' + LineEnding +
        'METADATA: ' + Meta.AsJSON + LineEnding + Hits[I].Content;
    finally
      Meta.Free;
    end;
  end;
end;

end.
