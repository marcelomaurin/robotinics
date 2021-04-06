unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, lNetComponents, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, lNet;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    edIP: TEdit;
    edPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbversao: TLabel;
    LTCPComponent1: TLTCPComponent;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LTCPComponent1Connect(aSocket: TLSocket);
    procedure LTCPComponent1Disconnect(aSocket: TLSocket);
    procedure Enviar(Info: string);
  private
    { private declarations }
  public
    { public declarations }
    Const Versao = '1.0';
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.LTCPComponent1Connect(aSocket: TLSocket);
begin
  ShowMessage('Conectou!');
end;

procedure TfrmMain.LTCPComponent1Disconnect(aSocket: TLSocket);
begin
  ShowMessage('Desconectou!');
end;

procedure TfrmMain.Enviar(Info: string);
begin
    LTCPComponent1.SendMessage(Info,nil);

end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
     Enviar('FRENTE'+#10);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
    Enviar('GESQ'+#10);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
    Enviar('PARAR'+#10);
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
    Enviar('RE'+#10);
end;

procedure TfrmMain.Button5Click(Sender: TObject);
begin
    Enviar('GDIR'+#10);
end;

procedure TfrmMain.Button6Click(Sender: TObject);
begin
  LTCPComponent1.Connect(edIP.text,strtoint(edPort.text));
end;

procedure TfrmMain.Button7Click(Sender: TObject);
begin
  LTCPComponent1.Disconnect(false);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
     lbversao.Caption:= Versao;
end;

end.

