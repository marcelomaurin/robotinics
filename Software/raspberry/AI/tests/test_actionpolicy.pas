program test_actionpolicy;

{$mode objfpc}{$H+}

uses
  SysUtils, actionpolicy;

procedure AssertTrue(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create('ASSERT FAILED: ' + AMessage);
end;

var
  D: TActionDecision;
  Catalog: string;
begin
  D := EvaluateAction('gateway.command', 'ULTRA1');
  AssertTrue(D.Allowed, 'diagnostic allowed');
  AssertTrue(not D.RequiresConfirmation, 'diagnostic no confirmation');
  AssertTrue(D.Risk = arDiagnostic, 'diagnostic risk');

  D := EvaluateAction('gateway.command', 'FRENTE');
  AssertTrue(D.Allowed, 'movement catalogued');
  AssertTrue(D.RequiresConfirmation, 'movement confirmation');
  AssertTrue(D.Risk = arPhysicalHigh, 'movement high risk');

  D := EvaluateAction('gateway.command', 'PARA');
  AssertTrue(D.Allowed, 'stop allowed');
  AssertTrue(not D.RequiresConfirmation, 'stop no confirmation');

  D := EvaluateAction('gateway.command', 'COMANDO_INVENTADO');
  AssertTrue(not D.Allowed, 'unknown command denied');
  AssertTrue(D.Risk = arForbidden, 'unknown command forbidden');

  Catalog := ToolCatalogJSON;
  AssertTrue(Pos('gateway.read', Catalog) > 0, 'read tool catalogued');
  AssertTrue(Pos('gateway.command', Catalog) > 0, 'command tool catalogued');

  Writeln('Action policy tests: OK');
end.
