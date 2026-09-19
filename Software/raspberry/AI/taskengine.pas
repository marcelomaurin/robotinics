unit taskengine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser;

type
  TRobotTask = class
  private
    FID: string;
    FQuestion: string;
    FStatus: string;
    FSteps: TStringList;
    FSubTasks: TStringList;
    FEvidence: TStringList;
    FAudit: TStringList;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
    FResultText: string;
    FCancelled: Boolean;
    FCancelReason: string;
    function FindSubTaskIndex(const AID: string): Integer;
    function SubTaskStatus(const AID: string): string;
    function DependenciesResolved(const AID: string): Boolean;
    procedure Touch;
    procedure UpdateSubTask(const AID, AStatus, ADetail: string;
      AIncrementAttempt: Boolean);
  public
    constructor Create(const AQuestion: string);
    destructor Destroy; override;

    { Compatibilidade com Task Engine 1.x }
    procedure AddStep(const AName, AStatus, ADetail: string);
    procedure SetStatus(const AStatus: string);

    { Task Engine 2.0 }
    function AddSubTask(const AName, AKind, ADependsOn: string): string;
    procedure StartSubTask(const AID, ADetail: string);
    procedure CompleteSubTask(const AID, ADetail: string);
    procedure FailSubTask(const AID, ADetail: string);
    procedure CancelSubTask(const AID, AReason: string);
    procedure AddEvidence(const ASource, AKind, ADetail: string);
    procedure SetResult(const AResult: string);
    procedure Cancel(const AReason: string);
    procedure Audit(const AEvent, ADetail: string);

    function AsJSON: string;
    function Save(const AStatePath: string): string;

    property ID: string read FID;
    property Status: string read FStatus;
    property Cancelled: Boolean read FCancelled;
  end;

implementation

function ISODateTime(const AValue: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', AValue);
end;

function NewID: string;
begin
  Result := FormatDateTime('yyyymmddhhnnsszzz', Now) + '-' +
            IntToHex(Random($FFFFFF), 6);
end;

function NewSubTaskID: string;
begin
  Result := 'st-' + NewID;
end;

constructor TRobotTask.Create(const AQuestion: string);
begin
  inherited Create;
  Randomize;
  FID := NewID;
  FQuestion := AQuestion;
  FStatus := 'RUNNING';
  FCreatedAt := Now;
  FUpdatedAt := FCreatedAt;
  FResultText := '';
  FCancelled := False;
  FCancelReason := '';

  FSteps := TStringList.Create;
  FSubTasks := TStringList.Create;
  FEvidence := TStringList.Create;
  FAudit := TStringList.Create;

  Audit('task_created', 'Tarefa criada.');
end;

destructor TRobotTask.Destroy;
begin
  FAudit.Free;
  FEvidence.Free;
  FSubTasks.Free;
  FSteps.Free;
  inherited Destroy;
end;

procedure TRobotTask.Touch;
begin
  FUpdatedAt := Now;
end;

procedure TRobotTask.Audit(const AEvent, ADetail: string);
var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  try
    O.Add('timestamp', ISODateTime(Now));
    O.Add('event', AEvent);
    O.Add('detail', ADetail);
    FAudit.Add(O.AsJSON);
    Touch;
  finally
    O.Free;
  end;
end;

procedure TRobotTask.AddStep(const AName, AStatus, ADetail: string);
var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  try
    O.Add('name', AName);
    O.Add('status', AStatus);
    O.Add('detail', ADetail);
    O.Add('timestamp', ISODateTime(Now));
    FSteps.Add(O.AsJSON);
  finally
    O.Free;
  end;
  Audit('step', AName + ':' + AStatus);
end;

procedure TRobotTask.SetStatus(const AStatus: string);
begin
  FStatus := AStatus;
  Audit('status', AStatus);
end;

function TRobotTask.AddSubTask(const AName, AKind, ADependsOn: string): string;
var
  O: TJSONObject;
begin
  Result := NewSubTaskID;
  O := TJSONObject.Create;
  try
    O.Add('id', Result);
    O.Add('name', AName);
    O.Add('kind', AKind);
    O.Add('depends_on', ADependsOn);
    O.Add('status', 'PENDING');
    O.Add('attempts', 0);
    O.Add('detail', '');
    O.Add('created_at', ISODateTime(Now));
    O.Add('started_at', '');
    O.Add('finished_at', '');
    FSubTasks.Add(O.AsJSON);
  finally
    O.Free;
  end;
  Audit('subtask_created', Result + ':' + AName);
end;

function TRobotTask.FindSubTaskIndex(const AID: string): Integer;
var
  I: Integer;
  D: TJSONData;
  O: TJSONObject;
begin
  Result := -1;
  for I := 0 to FSubTasks.Count - 1 do
  begin
    D := GetJSON(FSubTasks[I]);
    try
      if D.JSONType <> jtObject then
        Continue;
      O := TJSONObject(D);
      if O.Get('id', '') = AID then
        Exit(I);
    finally
      D.Free;
    end;
  end;
end;

function TRobotTask.SubTaskStatus(const AID: string): string;
var
  I: Integer;
  D: TJSONData;
  O: TJSONObject;
begin
  Result := '';
  I := FindSubTaskIndex(AID);
  if I < 0 then Exit;

  D := GetJSON(FSubTasks[I]);
  try
    if D.JSONType = jtObject then
    begin
      O := TJSONObject(D);
      Result := O.Get('status', '');
    end;
  finally
    D.Free;
  end;
end;

function TRobotTask.DependenciesResolved(const AID: string): Boolean;
var
  I, P: Integer;
  D: TJSONData;
  O: TJSONObject;
  Deps, DepID, Status: string;
begin
  Result := False;
  I := FindSubTaskIndex(AID);
  if I < 0 then Exit;

  D := GetJSON(FSubTasks[I]);
  try
    if D.JSONType <> jtObject then Exit;
    O := TJSONObject(D);
    Deps := Trim(O.Get('depends_on', ''));
  finally
    D.Free;
  end;

  if Deps = '' then Exit(True);

  repeat
    P := Pos(',', Deps);
    if P > 0 then
    begin
      DepID := Trim(Copy(Deps, 1, P - 1));
      Delete(Deps, 1, P);
    end
    else
    begin
      DepID := Trim(Deps);
      Deps := '';
    end;

    if DepID <> '' then
    begin
      Status := SubTaskStatus(DepID);
      if (Status = '') or (Status = 'PENDING') or (Status = 'RUNNING') then
        Exit(False);
    end;
  until Deps = '';

  Result := True;
end;

procedure TRobotTask.UpdateSubTask(const AID, AStatus, ADetail: string;
  AIncrementAttempt: Boolean);
var
  I, Attempts: Integer;
  D: TJSONData;
  O: TJSONObject;
begin
  I := FindSubTaskIndex(AID);
  if I < 0 then
    raise Exception.Create('Subtarefa nao encontrada: ' + AID);

  D := GetJSON(FSubTasks[I]);
  try
    O := TJSONObject(D);
    Attempts := O.Get('attempts', 0);
    if AIncrementAttempt then
      Inc(Attempts);

    O.Strings['status'] := AStatus;
    O.Integers['attempts'] := Attempts;
    O.Strings['detail'] := ADetail;

    if (AStatus = 'RUNNING') and (O.Get('started_at', '') = '') then
      O.Strings['started_at'] := ISODateTime(Now);

    if (AStatus = 'DONE') or (AStatus = 'ERROR') or (AStatus = 'CANCELLED') then
      O.Strings['finished_at'] := ISODateTime(Now);

    FSubTasks[I] := O.AsJSON;
  finally
    D.Free;
  end;

  Audit('subtask_' + LowerCase(AStatus), AID + ':' + ADetail);
end;

procedure TRobotTask.StartSubTask(const AID, ADetail: string);
begin
  if not DependenciesResolved(AID) then
    raise Exception.Create('Dependencias ainda nao concluidas para subtarefa: ' + AID);
  UpdateSubTask(AID, 'RUNNING', ADetail, True);
end;

procedure TRobotTask.CompleteSubTask(const AID, ADetail: string);
begin
  UpdateSubTask(AID, 'DONE', ADetail, False);
end;

procedure TRobotTask.FailSubTask(const AID, ADetail: string);
begin
  UpdateSubTask(AID, 'ERROR', ADetail, False);
end;

procedure TRobotTask.CancelSubTask(const AID, AReason: string);
begin
  UpdateSubTask(AID, 'CANCELLED', AReason, False);
end;

procedure TRobotTask.AddEvidence(const ASource, AKind, ADetail: string);
var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  try
    O.Add('timestamp', ISODateTime(Now));
    O.Add('source', ASource);
    O.Add('kind', AKind);
    O.Add('detail', ADetail);
    FEvidence.Add(O.AsJSON);
  finally
    O.Free;
  end;
  Audit('evidence', ASource + ':' + AKind);
end;

procedure TRobotTask.SetResult(const AResult: string);
begin
  FResultText := AResult;
  Audit('result', 'Resultado final registrado.');
end;

procedure TRobotTask.Cancel(const AReason: string);
var
  I: Integer;
  D: TJSONData;
  O: TJSONObject;
begin
  if FCancelled then Exit;

  FCancelled := True;
  FCancelReason := AReason;
  FStatus := 'CANCELLED';

  for I := 0 to FSubTasks.Count - 1 do
  begin
    D := GetJSON(FSubTasks[I]);
    try
      if D.JSONType <> jtObject then Continue;
      O := TJSONObject(D);
      if (O.Get('status', '') = 'PENDING') or
         (O.Get('status', '') = 'RUNNING') then
      begin
        O.Strings['status'] := 'CANCELLED';
        O.Strings['detail'] := AReason;
        O.Strings['finished_at'] := ISODateTime(Now);
        FSubTasks[I] := O.AsJSON;
      end;
    finally
      D.Free;
    end;
  end;

  Audit('task_cancelled', AReason);
end;

function TRobotTask.AsJSON: string;

  procedure AddJSONList(AObject: TJSONObject; const AName: string;
    AList: TStringList);
  var
    A: TJSONArray;
    I: Integer;
  begin
    A := TJSONArray.Create;
    for I := 0 to AList.Count - 1 do
      A.Add(GetJSON(AList[I]));
    AObject.Add(AName, A);
  end;

var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  try
    O.Add('schema_version', 2);
    O.Add('id', FID);
    O.Add('question', FQuestion);
    O.Add('status', FStatus);
    O.Add('cancelled', FCancelled);
    O.Add('cancel_reason', FCancelReason);
    O.Add('result', FResultText);
    O.Add('created_at', ISODateTime(FCreatedAt));
    O.Add('updated_at', ISODateTime(FUpdatedAt));

    AddJSONList(O, 'steps', FSteps);
    AddJSONList(O, 'subtasks', FSubTasks);
    AddJSONList(O, 'evidence', FEvidence);
    AddJSONList(O, 'audit', FAudit);

    Result := O.FormatJSON;
  finally
    O.Free;
  end;
end;

function TRobotTask.Save(const AStatePath: string): string;
var
  Dir, Tmp: string;
  S: TStringList;
begin
  Dir := IncludeTrailingPathDelimiter(AStatePath) + 'tasks';
  ForceDirectories(Dir);
  Result := IncludeTrailingPathDelimiter(Dir) + FID + '.json';
  Tmp := Result + '.tmp';

  S := TStringList.Create;
  try
    S.Text := AsJSON;
    S.SaveToFile(Tmp);
    if FileExists(Result) then
      DeleteFile(Result);
    if not RenameFile(Tmp, Result) then
      raise Exception.Create('Falha ao persistir tarefa: ' + Result);
  finally
    S.Free;
  end;
end;

end.
