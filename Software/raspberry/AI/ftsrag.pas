unit ftsrag;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, sqlite3conn, sqldb;

type
  TFTSHit = record
    Path: string;
    Title: string;
    Score: Double;
    Content: string;
  end;
  TFTSHitArray = array of TFTSHit;

  TFTSSyncStats = record
    Added: Integer;
    Updated: Integer;
    Removed: Integer;
    Unchanged: Integer;
  end;

function SyncFTSIndex(const ARoot, ADatabase: string): TFTSSyncStats;
function SearchFTS(const ADatabase, AQuery: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000): TFTSHitArray;
function FTSContext(const ADatabase, AQuery: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000): string;
function SyncStatsJSON(const S: TFTSSyncStats): string;

implementation

type
  TDocInfo = class
  public
    Path: string;
    Title: string;
    Content: string;
    Size: Int64;
    MTime: Int64;
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

procedure ScanDocs(const Dir: string; Docs: TList);
var
  SR: TSearchRec;
  Path, Ext: string;
  S: TStringList;
  D: TDocInfo;
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
          ScanDocs(Path, Docs);
        Continue;
      end;

      Ext := LowerCase(ExtractFileExt(Path));
      if (Ext <> '.md') and (Ext <> '.txt') then Continue;

      S := TStringList.Create;
      try
        try
          S.LoadFromFile(Path);
          D := TDocInfo.Create;
          D.Path := ExpandFileName(Path);
          D.Content := S.Text;
          D.Title := ExtractTitle(Path, D.Content);
          D.Size := SR.Size;
          D.MTime := SR.Time;
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

procedure OpenDB(const FileName: string; out C: TSQLite3Connection;
  out T: TSQLTransaction);
begin
  ForceDirectories(ExtractFileDir(FileName));
  C := TSQLite3Connection.Create(nil);
  T := TSQLTransaction.Create(nil);
  C.Transaction := T;
  C.DatabaseName := FileName;
  C.Open;
  T.StartTransaction;

  C.ExecuteDirect(
    'CREATE TABLE IF NOT EXISTS documents (' +
    'path TEXT PRIMARY KEY,' +
    'title TEXT NOT NULL,' +
    'content TEXT NOT NULL,' +
    'size INTEGER NOT NULL,' +
    'mtime INTEGER NOT NULL' +
    ')'
  );

  C.ExecuteDirect(
    'CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts USING fts5(' +
    'path UNINDEXED, title, content, tokenize="unicode61")'
  );
  T.Commit;
  T.StartTransaction;
end;

function FindExisting(C: TSQLite3Connection; T: TSQLTransaction;
  const Path: string; out Size, MTime: Int64): Boolean;
var
  Q: TSQLQuery;
begin
  Result := False;
  Size := 0;
  MTime := 0;
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := C;
    Q.Transaction := T;
    Q.SQL.Text := 'SELECT size, mtime FROM documents WHERE path = :path';
    Q.Params.ParamByName('path').AsString := Path;
    Q.Open;
    if not Q.EOF then
    begin
      Size := Q.Fields[0].AsLargeInt;
      MTime := Q.Fields[1].AsLargeInt;
      Result := True;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure UpsertDoc(C: TSQLite3Connection; T: TSQLTransaction; D: TDocInfo);
var
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := C;
    Q.Transaction := T;

    Q.SQL.Text := 'DELETE FROM documents_fts WHERE path = :path';
    Q.Params.ParamByName('path').AsString := D.Path;
    Q.ExecSQL;

    Q.SQL.Text :=
      'INSERT OR REPLACE INTO documents(path,title,content,size,mtime) ' +
      'VALUES(:path,:title,:content,:size,:mtime)';
    Q.Params.ParamByName('path').AsString := D.Path;
    Q.Params.ParamByName('title').AsString := D.Title;
    Q.Params.ParamByName('content').AsString := D.Content;
    Q.Params.ParamByName('size').AsLargeInt := D.Size;
    Q.Params.ParamByName('mtime').AsLargeInt := D.MTime;
    Q.ExecSQL;

    Q.SQL.Text :=
      'INSERT INTO documents_fts(path,title,content) VALUES(:path,:title,:content)';
    Q.Params.ParamByName('path').AsString := D.Path;
    Q.Params.ParamByName('title').AsString := D.Title;
    Q.Params.ParamByName('content').AsString := D.Content;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function SyncFTSIndex(const ARoot, ADatabase: string): TFTSSyncStats;
var
  C: TSQLite3Connection;
  T: TSQLTransaction;
  Docs: TList;
  Seen: TStringList;
  Q: TSQLQuery;
  I: Integer;
  D: TDocInfo;
  OldSize, OldMTime: Int64;
  Path: string;
begin
  FillChar(Result, SizeOf(Result), 0);
  Docs := TList.Create;
  Seen := TStringList.Create;
  Seen.Sorted := True;
  Seen.Duplicates := dupIgnore;
  C := nil;
  T := nil;
  try
    if DirectoryExists(ARoot) then
      ScanDocs(ARoot, Docs);
    OpenDB(ADatabase, C, T);

    for I := 0 to Docs.Count - 1 do
    begin
      D := TDocInfo(Docs[I]);
      Seen.Add(D.Path);
      if not FindExisting(C, T, D.Path, OldSize, OldMTime) then
      begin
        UpsertDoc(C, T, D);
        Inc(Result.Added);
      end
      else if (OldSize <> D.Size) or (OldMTime <> D.MTime) then
      begin
        UpsertDoc(C, T, D);
        Inc(Result.Updated);
      end
      else
        Inc(Result.Unchanged);
    end;

    Q := TSQLQuery.Create(nil);
    try
      Q.DataBase := C;
      Q.Transaction := T;
      Q.SQL.Text := 'SELECT path FROM documents';
      Q.Open;
      while not Q.EOF do
      begin
        Path := Q.Fields[0].AsString;
        if Seen.IndexOf(Path) < 0 then
        begin
          C.ExecuteDirect('DELETE FROM documents_fts WHERE path=' +
            QuotedStr(Path));
          C.ExecuteDirect('DELETE FROM documents WHERE path=' +
            QuotedStr(Path));
          Inc(Result.Removed);
        end;
        Q.Next;
      end;
      Q.Close;
    finally
      Q.Free;
    end;

    T.Commit;
  finally
    if Assigned(C) then C.Close;
    T.Free;
    C.Free;
    Seen.Free;
    for I := 0 to Docs.Count - 1 do TObject(Docs[I]).Free;
    Docs.Free;
  end;
end;

function FTSQuery(const S: string): string;
var
  N: string;
  P: TStringList;
  I: Integer;
  T: string;
begin
  N := LowerCase(S);
  for I := 1 to Length(N) do
    if not (N[I] in ['a'..'z','0'..'9','_','-']) then N[I] := ' ';

  Result := '';
  P := TStringList.Create;
  try
    P.Delimiter := ' ';
    P.StrictDelimiter := True;
    P.DelimitedText := N;
    for I := 0 to P.Count - 1 do
    begin
      T := Trim(P[I]);
      if Length(T) < 3 then Continue;
      if Result <> '' then Result := Result + ' OR ';
      Result := Result + '"' + StringReplace(T, '"', '""', [rfReplaceAll]) + '"';
    end;
  finally
    P.Free;
  end;
end;

function SearchFTS(const ADatabase, AQuery: string;
  AMaxFiles, AMaxChars: Integer): TFTSHitArray;
var
  C: TSQLite3Connection;
  T: TSQLTransaction;
  Q: TSQLQuery;
  QueryText: string;
  UsedChars: Integer;
begin
  SetLength(Result, 0);
  if not FileExists(ADatabase) then Exit;
  QueryText := FTSQuery(AQuery);
  if QueryText = '' then Exit;

  C := nil; T := nil;
  try
    OpenDB(ADatabase, C, T);
    Q := TSQLQuery.Create(nil);
    try
      Q.DataBase := C;
      Q.Transaction := T;
      Q.SQL.Text :=
        'SELECT path,title,content,bm25(documents_fts,0.0,5.0,1.0) AS rank ' +
        'FROM documents_fts WHERE documents_fts MATCH :q ORDER BY rank LIMIT :lim';
      Q.Params.ParamByName('q').AsString := QueryText;
      Q.Params.ParamByName('lim').AsInteger := AMaxFiles;
      Q.Open;

      UsedChars := 0;
      while (not Q.EOF) and (UsedChars < AMaxChars) do
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)].Path := Q.FieldByName('path').AsString;
        Result[High(Result)].Title := Q.FieldByName('title').AsString;
        Result[High(Result)].Score := -Q.FieldByName('rank').AsFloat;
        Result[High(Result)].Content := Q.FieldByName('content').AsString;

        if Length(Result[High(Result)].Content) > AMaxChars - UsedChars then
          SetLength(Result[High(Result)].Content, AMaxChars - UsedChars);
        Inc(UsedChars, Length(Result[High(Result)].Content));
        Q.Next;
      end;
      Q.Close;
    finally
      Q.Free;
    end;
    T.Commit;
  finally
    if Assigned(C) then C.Close;
    T.Free;
    C.Free;
  end;
end;

function FTSContext(const ADatabase, AQuery: string;
  AMaxFiles, AMaxChars: Integer): string;
var
  Hits: TFTSHitArray;
  I: Integer;
  O: TJSONObject;
begin
  Result := '';
  Hits := SearchFTS(ADatabase, AQuery, AMaxFiles, AMaxChars);
  for I := 0 to High(Hits) do
  begin
    if Result <> '' then Result := Result + LineEnding + LineEnding;
    O := TJSONObject.Create;
    try
      O.Add('path', Hits[I].Path);
      O.Add('title', Hits[I].Title);
      O.Add('fts_score', Hits[I].Score);
      Result := Result + '=== DOCUMENT ===' + LineEnding +
        'METADATA: ' + O.AsJSON + LineEnding + Hits[I].Content;
    finally
      O.Free;
    end;
  end;
end;

function SyncStatsJSON(const S: TFTSSyncStats): string;
var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  try
    O.Add('added', S.Added);
    O.Add('updated', S.Updated);
    O.Add('removed', S.Removed);
    O.Add('unchanged', S.Unchanged);
    Result := O.AsJSON;
  finally
    O.Free;
  end;
end;

end.
