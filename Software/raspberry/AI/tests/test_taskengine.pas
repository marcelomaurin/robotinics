program test_taskengine;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, fpjson, jsonparser, taskengine;

procedure AssertTrue(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create('ASSERT FAILED: ' + AMessage);
end;

function ParseObject(const S: string): TJSONObject;
var
  D: TJSONData;
begin
  D := GetJSON(S);
  if D.JSONType <> jtObject then
  begin
    D.Free;
    raise Exception.Create('JSON root is not object');
  end;
  Result := TJSONObject(D);
end;

var
  T: TRobotTask;
  Root: TJSONObject;
  Subs, Evidence, Audit: TJSONArray;
  ST1, ST2, FileName, TempDir: string;
begin
  TempDir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
             'robotinics-taskengine-test-' + IntToStr(GetProcessID);
  ForceDirectories(TempDir);

  T := TRobotTask.Create('diagnosticar robotinics');
  try
    ST1 := T.AddSubTask('coletar estado', 'telemetry', '');
    ST2 := T.AddSubTask('analisar estado', 'reasoning', ST1);

    try
      T.StartSubTask(ST2, 'nao deveria iniciar');
      raise Exception.Create('dependency guard did not block');
    except
      on E: Exception do
        AssertTrue(Pos('Dependencias', E.Message) > 0, 'dependency guard');
    end;

    T.StartSubTask(ST1, 'coletando');
    T.AddEvidence('gateway', 'state', '{"connected":true}');
    T.CompleteSubTask(ST1, 'coleta concluida');

    T.StartSubTask(ST2, 'analisando');
    T.CompleteSubTask(ST2, 'analise concluida');

    T.AddStep('compat', 'DONE', 'API 1.x preservada');
    T.SetResult('sistema operacional');
    T.SetStatus('DONE');

    Root := ParseObject(T.AsJSON);
    try
      AssertTrue(Root.Get('schema_version', 0) = 2, 'schema version');
      AssertTrue(Root.Get('status', '') = 'DONE', 'task status');
      AssertTrue(Root.Get('result', '') = 'sistema operacional', 'result');

      Subs := Root.Arrays['subtasks'];
      Evidence := Root.Arrays['evidence'];
      Audit := Root.Arrays['audit'];

      AssertTrue(Subs.Count = 2, 'subtask count');
      AssertTrue(Evidence.Count = 1, 'evidence count');
      AssertTrue(Audit.Count >= 6, 'audit events');

      AssertTrue(
        TJSONObject(Subs.Objects[0]).Get('attempts', 0) = 1,
        'attempt counter'
      );
      AssertTrue(
        TJSONObject(Subs.Objects[1]).Get('depends_on', '') = ST1,
        'dependency persisted'
      );
    finally
      Root.Free;
    end;

    FileName := T.Save(TempDir);
    AssertTrue(FileExists(FileName), 'task persistence');
  finally
    T.Free;
  end;

  T := TRobotTask.Create('cancelamento');
  try
    ST1 := T.AddSubTask('acao pendente', 'action', '');
    T.Cancel('operador cancelou');
    Root := ParseObject(T.AsJSON);
    try
      AssertTrue(Root.Get('cancelled', False), 'task cancelled');
      AssertTrue(Root.Get('status', '') = 'CANCELLED', 'cancelled status');
      Subs := Root.Arrays['subtasks'];
      AssertTrue(
        TJSONObject(Subs.Objects[0]).Get('status', '') = 'CANCELLED',
        'pending subtask cancelled'
      );
    finally
      Root.Free;
    end;
  finally
    T.Free;
  end;

  Writeln('Task Engine 2.0 tests: OK');
end.
