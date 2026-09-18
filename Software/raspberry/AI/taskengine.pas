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
    FCreatedAt: TDateTime;
  public
    constructor Create(const AQuestion: string);
    destructor Destroy; override;
    procedure AddStep(const AName, AStatus, ADetail: string);
    procedure SetStatus(const AStatus: string);
    function AsJSON: string;
    function Save(const AStatePath: string): string;
    property ID: string read FID;
  end;

implementation

function NewID: string;
begin
  Randomize;
  Result := FormatDateTime('yyyymmddhhnnsszzz', Now) + '-' +
            IntToHex(Random($FFFFFF), 6);
end;

constructor TRobotTask.Create(const AQuestion: string);
begin
  inherited Create;
  FID := NewID;
  FQuestion := AQuestion;
  FStatus := 'RUNNING';
  FCreatedAt := Now;
  FSteps := TStringList.Create;
end;

destructor TRobotTask.Destroy;
begin
  FSteps.Free;
  inherited Destroy;
end;

procedure TRobotTask.AddStep(const AName, AStatus, ADetail: string);
var
  O: TJSONObject;
begin
  O := TJSONObject.Create;
  O.Add('name', AName);
  O.Add('status', AStatus);
  O.Add('detail', ADetail);
  FSteps.Add(O.AsJSON);
  O.Free;
end;

procedure TRobotTask.SetStatus(const AStatus: string);
begin
  FStatus := AStatus;
end;

function TRobotTask.AsJSON: string;
var
  O: TJSONObject;
  A: TJSONArray;
  I: Integer;
begin
  O := TJSONObject.Create;
  A := TJSONArray.Create;
  try
    O.Add('id', FID);
    O.Add('question', FQuestion);
    O.Add('status', FStatus);
    O.Add('created_at', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', FCreatedAt));
    for I := 0 to FSteps.Count - 1 do
      A.Add(GetJSON(FSteps[I]));
    O.Add('steps_json', A);
    Result := O.FormatJSON;
  finally
    O.Free;
  end;
end;

function TRobotTask.Save(const AStatePath: string): string;
var
  Dir: string;
  S: TStringList;
begin
  Dir := IncludeTrailingPathDelimiter(AStatePath) + 'tasks';
  ForceDirectories(Dir);
  Result := IncludeTrailingPathDelimiter(Dir) + FID + '.json';
  S := TStringList.Create;
  try
    S.Text := AsJSON;
    S.SaveToFile(Result);
  finally
    S.Free;
  end;
end;

end.
