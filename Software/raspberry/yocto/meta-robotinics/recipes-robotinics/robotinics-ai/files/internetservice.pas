unit internetservice;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets;

type
  TInternetService = class
  private
    FSearchURL: string;
  public
    constructor Create(const ASearchURL: string);
    function Enabled: Boolean;
    function Search(const AQuery: string): string;
    function Fetch(const AURL: string): string;
  end;

implementation

function URLEncodeSimple(const S: string): string;
const
  Hex: array[0..15] of Char = '0123456789ABCDEF';
var
  I: Integer;
  C: Byte;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := Ord(S[I]);
    if (C in [Ord('a')..Ord('z'), Ord('A')..Ord('Z'), Ord('0')..Ord('9'),
              Ord('-'), Ord('_'), Ord('.'), Ord('~')]) then
      Result := Result + Chr(C)
    else if C = Ord(' ') then
      Result := Result + '+'
    else
      Result := Result + '%' + Hex[C shr 4] + Hex[C and $0F];
  end;
end;

constructor TInternetService.Create(const ASearchURL: string);
begin
  inherited Create;
  FSearchURL := Trim(ASearchURL);
end;

function TInternetService.Enabled: Boolean;
begin
  Result := FSearchURL <> '';
end;

function TInternetService.Fetch(const AURL: string): string;
var
  H: TFPHttpClient;
begin
  H := TFPHttpClient.Create(nil);
  try
    H.AllowRedirect := True;
    H.IOTimeout := 15000;
    H.ConnectTimeout := 7000;
    H.AddHeader('User-Agent', 'Robotinics/1.0');
    Result := H.Get(AURL);
    if Length(Result) > 65536 then
      SetLength(Result, 65536);
  finally
    H.Free;
  end;
end;

function TInternetService.Search(const AQuery: string): string;
var
  URL: string;
begin
  if not Enabled then
    Exit('');

  URL := StringReplace(FSearchURL, '{query}', URLEncodeSimple(AQuery),
                       [rfReplaceAll]);
  if URL = FSearchURL then
  begin
    if Pos('?', URL) > 0 then
      URL := URL + '&q=' + URLEncodeSimple(AQuery)
    else
      URL := URL + '?q=' + URLEncodeSimple(AQuery);
  end;
  Result := Fetch(URL);
end;

end.
