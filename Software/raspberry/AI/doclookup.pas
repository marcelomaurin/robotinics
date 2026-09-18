unit doclookup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function LookupDocumentation(const ARoot, AQuery: string;
  AMaxFiles: Integer = 8; AMaxChars: Integer = 24000): string;

implementation

function ScoreText(const Text, Query: string): Integer;
var
  Parts: TStringList;
  I: Integer;
  Token, LText: string;
begin
  Result := 0;
  LText := LowerCase(Text);
  Parts := TStringList.Create;
  try
    Parts.Delimiter := ' ';
    Parts.StrictDelimiter := False;
    Parts.DelimitedText := StringReplace(LowerCase(Query), #9, ' ', [rfReplaceAll]);
    for I := 0 to Parts.Count - 1 do
    begin
      Token := Trim(Parts[I]);
      if Length(Token) < 3 then Continue;
      if Pos(Token, LText) > 0 then
        Inc(Result);
    end;
  finally
    Parts.Free;
  end;
end;

procedure ScanDir(const Dir, Query: string; Results: TStringList);
var
  SR: TSearchRec;
  Path, Ext, Text: string;
  S: TStringList;
  Score: Integer;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR) <> 0 then
    Exit;
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then Continue;
      Path := IncludeTrailingPathDelimiter(Dir) + SR.Name;
      if (SR.Attr and faDirectory) <> 0 then
      begin
        if (SR.Name <> '.git') and (SR.Name <> 'build') and
           (SR.Name <> 'tmp') then
          ScanDir(Path, Query, Results);
      end
      else
      begin
        Ext := LowerCase(ExtractFileExt(Path));
        if not (Ext in ['.md', '.txt']) then Continue;
        S := TStringList.Create;
        try
          try
            S.LoadFromFile(Path);
            Text := S.Text;
            Score := ScoreText(Text, Query);
            if Score > 0 then
              Results.AddObject(Format('%.6d|%s', [999999 - Score, Path]),
                                TObject(S));
            S := nil;
          except
          end;
        finally
          S.Free;
        end;
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function LookupDocumentation(const ARoot, AQuery: string;
  AMaxFiles: Integer; AMaxChars: Integer): string;
var
  R: TStringList;
  I, Count: Integer;
  S: TStringList;
  Key, Path: string;
begin
  Result := '';
  if not DirectoryExists(ARoot) then Exit;

  R := TStringList.Create;
  try
    R.Sorted := True;
    ScanDir(ARoot, AQuery, R);
    Count := 0;
    for I := 0 to R.Count - 1 do
    begin
      if Count >= AMaxFiles then Break;
      S := TStringList(R.Objects[I]);
      Key := R[I];
      Path := Copy(Key, Pos('|', Key) + 1, MaxInt);
      if Result <> '' then
        Result := Result + LineEnding + LineEnding;
      Result := Result + '=== ' + Path + ' ===' + LineEnding + S.Text;
      Inc(Count);
      if Length(Result) >= AMaxChars then
      begin
        SetLength(Result, AMaxChars);
        Break;
      end;
    end;
  finally
    for I := 0 to R.Count - 1 do
      R.Objects[I].Free;
    R.Free;
  end;
end;

end.
