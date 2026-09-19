program test_ftsrag;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, ftsrag;

procedure AssertTrue(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create('ASSERT FAILED: ' + AMessage);
end;

procedure WriteText(const APath, AText: string);
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
  Dir, DB, MotorFile, CamFile, Context: string;
  S1, S2, S3, S4: TFTSSyncStats;
  Hits: TFTSHitArray;
begin
  Dir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
         'robotinics-fts-test-' + IntToStr(GetProcessID);
  ForceDirectories(Dir);
  DB := IncludeTrailingPathDelimiter(Dir) + 'index/robotinics.sqlite';
  MotorFile := IncludeTrailingPathDelimiter(Dir) + 'motores.md';
  CamFile := IncludeTrailingPathDelimiter(Dir) + 'camera.md';

  WriteText(MotorFile,
    '# Motores' + LineEnding +
    'FRENTE RE PARA safety controle dos motores.');
  WriteText(CamFile,
    '# Camera' + LineEnding +
    'camera visao tracking imagem pan tilt.');

  S1 := SyncFTSIndex(Dir, DB);
  AssertTrue(S1.Added = 2, 'initial add');
  AssertTrue(S1.Updated = 0, 'initial no update');

  S2 := SyncFTSIndex(Dir, DB);
  AssertTrue(S2.Unchanged = 2, 'second sync unchanged');
  AssertTrue((S2.Added = 0) and (S2.Updated = 0), 'no needless reindex');

  Hits := SearchFTS(DB, 'frente motor safety', 5, 10000);
  AssertTrue(Length(Hits) > 0, 'search hit');
  AssertTrue(Pos('motores.md', LowerCase(Hits[0].Path)) > 0, 'motor document ranked');

  WriteText(MotorFile,
    '# Motores' + LineEnding +
    'FRENTE RE PARA safety controle dos motores emergencia watchdog adicional.');
  S3 := SyncFTSIndex(Dir, DB);
  AssertTrue(S3.Updated = 1, 'changed document updated');
  AssertTrue(S3.Unchanged = 1, 'unchanged document preserved');

  DeleteFile(CamFile);
  S4 := SyncFTSIndex(Dir, DB);
  AssertTrue(S4.Removed = 1, 'removed document deleted from index');

  Hits := SearchFTS(DB, 'camera tracking', 5, 10000);
  AssertTrue(Length(Hits) = 0, 'removed document not searchable');

  Context := FTSContext(DB, 'watchdog motores', 5, 10000);
  AssertTrue(Pos('fts_score', Context) > 0, 'fts score metadata');
  AssertTrue(Pos('motores.md', LowerCase(Context)) > 0, 'context contains hit');

  Writeln('FTS RAG tests: OK');
end.
