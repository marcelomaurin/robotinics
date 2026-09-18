unit gatewayclient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets;

type
  TGatewayClient = class
  private
    FBaseURL: string;
    function HTTPGet(const APath: string): string;
  public
    constructor Create(const ABaseURL: string);
    function State: string;
    function Catalog: string;
    function History(ALimit: Integer = 20): string;
    function Command(const ACommand: string; ATimeout: Double = 5.0): string;
  end;

implementation

constructor TGatewayClient.Create(const ABaseURL: string);
begin
  inherited Create;
  FBaseURL := ExcludeTrailingPathDelimiter(ABaseURL);
end;

function TGatewayClient.HTTPGet(const APath: string): string;
var
  H: TFPHttpClient;
begin
  H := TFPHttpClient.Create(nil);
  try
    H.IOTimeout := 10000;
    H.ConnectTimeout := 5000;
    Result := H.Get(FBaseURL + APath);
  finally
    H.Free;
  end;
end;

function TGatewayClient.State: string;
begin
  Result := HTTPGet('/v1/state');
end;

function TGatewayClient.Catalog: string;
begin
  Result := HTTPGet('/v1/catalog');
end;

function TGatewayClient.History(ALimit: Integer): string;
begin
  Result := HTTPGet('/v1/history?limit=' + IntToStr(ALimit));
end;

function JsonEscape(const S: string): string;
begin
  Result := StringReplace(S, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;

function TGatewayClient.Command(const ACommand: string; ATimeout: Double): string;
var
  H: TFPHttpClient;
  Body: TStringStream;
  Payload, Speed: string;
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  Speed := FloatToStr(ATimeout, FS);
  Payload := '{"command":"' + JsonEscape(ACommand) + '","timeout":' + Speed + '}';

  H := TFPHttpClient.Create(nil);
  Body := TStringStream.Create(Payload);
  try
    H.AddHeader('Content-Type', 'application/json');
    H.RequestBody := Body;
    H.IOTimeout := Round((ATimeout + 2) * 1000);
    H.ConnectTimeout := 5000;
    Result := H.Post(FBaseURL + '/v1/command');
  finally
    Body.Free;
    H.Free;
  end;
end;

end.
