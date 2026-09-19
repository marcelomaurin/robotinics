unit toolrunner;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, actionpolicy, gatewayclient, taskengine;

type
  TToolExecution = record
    OK: Boolean;
    NeedsConfirmation: Boolean;
    Risk: string;
    ToolName: string;
    Command: string;
    Response: string;
    Error: string;
  end;

function ExecuteTool(AGateway: TGatewayClient; ATask: TRobotTask;
  const AToolName, ACommand: string; AConfirmed: Boolean): TToolExecution;
function ToolExecutionJSON(const R: TToolExecution): string;

implementation

function ExecuteTool(AGateway: TGatewayClient; ATask: TRobotTask;
  const AToolName, ACommand: string; AConfirmed: Boolean): TToolExecution;
var
  D: TActionDecision;
begin
  Result.OK := False;
  Result.NeedsConfirmation := False;
  Result.Risk := '';
  Result.ToolName := AToolName;
  Result.Command := ACommand;
  Result.Response := '';
  Result.Error := '';

  D := EvaluateAction(AToolName, ACommand);
  Result.Risk := RiskToString(D.Risk);

  if not D.Allowed then
  begin
    Result.Error := D.Reason;
    if Assigned(ATask) then
      ATask.AddEvidence('toolrunner', 'denied', AToolName + ':' + ACommand + ':' + D.Reason);
    Exit;
  end;

  if D.RequiresConfirmation and not AConfirmed then
  begin
    Result.NeedsConfirmation := True;
    Result.Error := 'CONFIRMATION_REQUIRED';
    if Assigned(ATask) then
      ATask.AddEvidence('toolrunner', 'confirmation_required',
        AToolName + ':' + ACommand);
    Exit;
  end;

  try
    if SameText(AToolName, 'gateway.read') then
    begin
      if SameText(ACommand, 'state') then Result.Response := AGateway.State
      else if SameText(ACommand, 'catalog') then Result.Response := AGateway.Catalog
      else if SameText(ACommand, 'history') then Result.Response := AGateway.History(20)
      else raise Exception.Create('Leitura nao catalogada.');
    end
    else if SameText(AToolName, 'gateway.diagnostic') then
      Result.Response := AGateway.Diagnostics
    else if SameText(AToolName, 'gateway.command') then
      Result.Response := AGateway.Command(ACommand, 5.0)
    else
      raise Exception.Create('Ferramenta nao suportada.');

    Result.OK := True;
    if Assigned(ATask) then
      ATask.AddEvidence('toolrunner', 'result', AToolName + ':' + ACommand + ':' + Result.Response);
  except
    on E: Exception do
    begin
      Result.Error := E.Message;
      if Assigned(ATask) then
        ATask.AddEvidence('toolrunner', 'error', AToolName + ':' + ACommand + ':' + E.Message);
    end;
  end;
end;

function ToolExecutionJSON(const R: TToolExecution): string;
var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  try
    O.Add('ok', R.OK);
    O.Add('needs_confirmation', R.NeedsConfirmation);
    O.Add('risk', R.Risk);
    O.Add('tool', R.ToolName);
    O.Add('command', R.Command);
    O.Add('response', R.Response);
    O.Add('error', R.Error);
    Result := O.AsJSON;
  finally
    O.Free;
  end;
end;

end.
