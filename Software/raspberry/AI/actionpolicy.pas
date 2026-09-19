unit actionpolicy;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TActionRisk = (arReadOnly, arDiagnostic, arPhysicalLow, arPhysicalHigh, arForbidden);

  TActionDecision = record
    ToolName: string;
    Command: string;
    Risk: TActionRisk;
    Allowed: Boolean;
    RequiresConfirmation: Boolean;
    Reason: string;
  end;

function RiskToString(ARisk: TActionRisk): string;
function EvaluateAction(const AToolName, ACommand: string): TActionDecision;
function ToolCatalogJSON: string;

implementation

uses
  fpjson;

function RiskToString(ARisk: TActionRisk): string;
begin
  case ARisk of
    arReadOnly: Result := 'READ_ONLY';
    arDiagnostic: Result := 'DIAGNOSTIC';
    arPhysicalLow: Result := 'PHYSICAL_LOW';
    arPhysicalHigh: Result := 'PHYSICAL_HIGH';
    arForbidden: Result := 'FORBIDDEN';
  end;
end;

function StartsWithAny(const S: string; const Prefixes: array of string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(Prefixes) to High(Prefixes) do
    if Pos(Prefixes[I], S) = 1 then
      Exit(True);
end;

function EvaluateAction(const AToolName, ACommand: string): TActionDecision;
var
  Tool, Cmd: string;
begin
  Tool := LowerCase(Trim(AToolName));
  Cmd := UpperCase(Trim(ACommand));

  Result.ToolName := Tool;
  Result.Command := Cmd;
  Result.Risk := arForbidden;
  Result.Allowed := False;
  Result.RequiresConfirmation := False;
  Result.Reason := 'Ferramenta ou comando nao catalogado.';

  if Tool = 'gateway.read' then
  begin
    Result.Risk := arReadOnly;
    Result.Allowed := True;
    Result.Reason := 'Consulta de estado sem atuacao fisica.';
    Exit;
  end;

  if Tool = 'gateway.diagnostic' then
  begin
    Result.Risk := arDiagnostic;
    Result.Allowed := True;
    Result.Reason := 'Diagnostico sem comando de movimento.';
    Exit;
  end;

  if Tool <> 'gateway.command' then Exit;

  if (Cmd = 'PING') or (Cmd = 'SAFETY') or (Cmd = 'IDENTIFY') or
     (Cmd = 'CAPABILITIES') or (Cmd = 'HEALTH') or
     (Cmd = 'ULTRA') or (Cmd = 'ULTRA1') or (Cmd = 'ULTRA2') or
     (Cmd = 'GAS') or (Cmd = 'CORR') or (Cmd = 'GPS') or
     (Cmd = 'ACEL') or StartsWithAny(Cmd, ['MCAB:DIST', 'MCAB:GETPOS', 'MCAB:HEALTH']) then
  begin
    Result.Risk := arDiagnostic;
    Result.Allowed := True;
    Result.Reason := 'Comando somente de leitura/diagnostico.';
    Exit;
  end;

  if (Cmd = 'PARA') then
  begin
    Result.Risk := arPhysicalLow;
    Result.Allowed := True;
    Result.RequiresConfirmation := False;
    Result.Reason := 'Parada segura permitida sem confirmacao.';
    Exit;
  end;

  if (Cmd = 'FRENTE') or (Cmd = 'RE') or (Cmd = 'GESQ') or (Cmd = 'GDIR') then
  begin
    Result.Risk := arPhysicalHigh;
    Result.Allowed := True;
    Result.RequiresConfirmation := True;
    Result.Reason := 'Movimento fisico exige confirmacao humana.';
    Exit;
  end;

  if StartsWithAny(Cmd, [
      'GCABECAESQ=', 'GCABECADIR=', 'GBDIR=', 'GBESQ=',
      'GPGARRADIR=', 'GPGARRAESQ=', 'GPPUNHOESQ=', 'GPPUNHODIR=',
      'MCAB:POINT:', 'MCAB:CENTER', 'MCAB:LASERON', 'MCAB:LASEROFF',
      'MCAB:LEDAZUL=', 'MCAB:LEDVERDE=', 'MCAB:LEDVERMELHO=',
      'MCAB:OLHOS=', 'MCAB:LIGHTAUTO='
    ]) then
  begin
    Result.Risk := arPhysicalHigh;
    Result.Allowed := True;
    Result.RequiresConfirmation := True;
    Result.Reason := 'Atuador fisico exige confirmacao humana.';
    Exit;
  end;
end;

function ToolCatalogJSON: string;
var
  Root: TJSONObject;
  Tools: TJSONArray;
  O: TJSONObject;
begin
  Root := TJSONObject.Create;
  Tools := TJSONArray.Create;
  try
    O := TJSONObject.Create;
    O.Add('name', 'gateway.read');
    O.Add('description', 'Le estado, historico e catalogo do Gateway.');
    O.Add('physical_effect', False);
    Tools.Add(O);

    O := TJSONObject.Create;
    O.Add('name', 'gateway.diagnostic');
    O.Add('description', 'Executa consultas de diagnostico sem movimento.');
    O.Add('physical_effect', False);
    Tools.Add(O);

    O := TJSONObject.Create;
    O.Add('name', 'gateway.command');
    O.Add('description', 'Solicita comando catalogado ao Gateway.');
    O.Add('physical_effect', True);
    O.Add('policy', 'physical actions require confirmation except PARA');
    Tools.Add(O);

    Root.Add('schema_version', 1);
    Root.Add('tools', Tools);
    Result := Root.AsJSON;
  finally
    Root.Free;
  end;
end;

end.
