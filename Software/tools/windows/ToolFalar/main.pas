unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, lNetComponents, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, lNet;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btFalar: TButton;
    btConect: TButton;
    btDisconect: TButton;
    btPropaganda: TButton;
    edIP: TEdit;
    edFalar: TEdit;
    edPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LTCPComponent1: TLTCPComponent;
    Shape1: TShape;
    procedure btConectClick(Sender: TObject);
    procedure btDisconectClick(Sender: TObject);
    procedure btFalarClick(Sender: TObject);
    procedure btPropagandaClick(Sender: TObject);
    procedure edFalarKeyPress(Sender: TObject; var Key: char);
    procedure edPortChange(Sender: TObject);
    procedure LTCPComponent1Connect(aSocket: TLSocket);
    procedure LTCPComponent1Disconnect(aSocket: TLSocket);
    procedure LTCPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btConectClick(Sender: TObject);
begin
  LTCPComponent1.Connect(edIP.text,strtoint(edPort.text));
end;

procedure TfrmMain.btDisconectClick(Sender: TObject);
begin
  LTCPComponent1.Disconnect(true);
end;

procedure TfrmMain.btFalarClick(Sender: TObject);
begin
  LTCPComponent1.SendMessage(edFalar.text+#10,nil);

end;

procedure TfrmMain.btPropagandaClick(Sender: TObject);
begin

end;

procedure TfrmMain.edFalarKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) then
  begin
     btFalarClick(self);
  end;

end;

procedure TfrmMain.edPortChange(Sender: TObject);
begin

end;

procedure TfrmMain.LTCPComponent1Connect(aSocket: TLSocket);
begin
  ShowMessage('Conectou!');
end;

procedure TfrmMain.LTCPComponent1Disconnect(aSocket: TLSocket);
begin
  ShowMessage('Disconectou');
end;

procedure TfrmMain.LTCPComponent1Error(const msg: string; aSocket: TLSocket);
begin
  ShowMessage('Erro ao conectar!');
end;

procedure TfrmMain.LTCPComponent1Receive(aSocket: TLSocket);
var
   info : String;
begin
  //ShowMessage('Recebeu a mensagem:');

  aSocket.GetMessage(info);
  ShowMessage(info);
end;

end.

