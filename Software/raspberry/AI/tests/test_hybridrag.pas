program test_hybridrag;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, hybridrag;

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
  Dir, IndexFile, Context: string;
  Hits: THybridHitArray;
  Count: Integer;
begin
  Dir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
         'robotinics-hybridrag-test-' + IntToStr(GetProcessID);
  ForceDirectories(Dir);

  WriteText(IncludeTrailingPathDelimiter(Dir) + 'motores.md',
    '# Motores' + LineEnding +
    'FRENTE RE PARA safety motor controle movimento.');
  WriteText(IncludeTrailingPathDelimiter(Dir) + 'camera.md',
    '# Camera' + LineEnding +
    'visao tracking imagem camera pan tilt.');

  IndexFile := IncludeTrailingPathDelimiter(Dir) + 'index/index.json';
  Count := BuildHybridIndex(Dir, IndexFile, '', '', '');
  AssertTrue(Count = 2, 'two docs indexed');
  AssertTrue(FileExists(IndexFile), 'index persisted');

  Hits := SearchHybridIndex(IndexFile, 'frente motor safety', '', '', '', 5, 10000, 0.65);
  AssertTrue(Length(Hits) > 0, 'hybrid search returns hit');
  AssertTrue(Pos('motores.md', LowerCase(Hits[0].Path)) > 0, 'motor doc first');
  AssertTrue(Hits[0].SemanticScore = 0, 'semantic fallback zero without embeddings');
  AssertTrue(Hits[0].FinalScore > 0, 'final score positive');

  Context := HybridContext(IndexFile, 'frente motor safety', '', '', '', 5, 10000, 0.65);
  AssertTrue(Pos('lexical_score', Context) > 0, 'hybrid metadata');
  AssertTrue(Pos('semantic_score', Context) > 0, 'semantic metadata');

  Writeln('Hybrid RAG tests: OK');
end.
