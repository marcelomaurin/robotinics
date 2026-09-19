program test_toolrunner;

{$mode objfpc}{$H+}

uses
  SysUtils, toolrunner;

procedure AssertTrue(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create('ASSERT FAILED: ' + AMessage);
end;

var
  R: TToolExecution;
  J: string;
begin
  R := ExecuteTool(nil, nil, 'gateway.command', 'COMANDO_INVENTADO', False);
  AssertTrue(not R.OK, 'unknown command denied');
  AssertTrue(not R.NeedsConfirmation, 'unknown is denied, not confirmable');
  AssertTrue(R.Risk = 'FORBIDDEN', 'unknown risk');

  R := ExecuteTool(nil, nil, 'gateway.command', 'FRENTE', False);
  AssertTrue(not R.OK, 'movement not executed without confirmation');
  AssertTrue(R.NeedsConfirmation, 'movement requires confirmation');
  AssertTrue(R.Risk = 'PHYSICAL_HIGH', 'movement risk');

  J := ToolExecutionJSON(R);
  AssertTrue(Pos('needs_confirmation', J) > 0, 'json serialization');

  Writeln('Tool runner tests: OK');
end.
