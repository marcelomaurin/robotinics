unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SdpoSerial, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btConectar: TButton;
    btDesconectar: TButton;
    btUltra0: TButton;
    btUltra1: TButton;
    Button1: TButton;
    btCorrente: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    btGAS: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ckSetmonitor: TCheckBox;
    edCMD: TEdit;
    edLCD1: TEdit;
    edLCD2: TEdit;
    edPorta: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lbVersao: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    SdpoSerial1: TSdpoSerial;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TBbDir: TTrackBar;
    TBbEsq: TTrackBar;
    tbGarraESQ: TTrackBar;
    tbGCABECA: TTrackBar;
    tbGPunhoDir: TTrackBar;
    tbGPunhoEsq: TTrackBar;
    tbGarra: TTrackBar;
    procedure btConectarClick(Sender: TObject);
    procedure btDesconectarClick(Sender: TObject);
    procedure btGASClick(Sender: TObject);
    procedure btUltra0Click(Sender: TObject);
    procedure btUltra1Click(Sender: TObject);
    procedure btCorrenteClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure ckSetmonitorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SdpoSerial1RxData(Sender: TObject);
    procedure TBbDirChange(Sender: TObject);
    procedure TBbEsqChange(Sender: TObject);
    procedure tbGarraESQChange(Sender: TObject);
    procedure tbGarraChange(Sender: TObject);
    procedure tbGCABECAChange(Sender: TObject);
    procedure tbGPunhoDirChange(Sender: TObject);
    procedure tbGPunhoEsqChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Const Versao = '1.0';
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  SdpoSerial1.WriteData('FRENTE'+#10);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    SdpoSerial1.WriteData('GESQ'+#10);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    SdpoSerial1.WriteData('GDIR'+#10);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
    SdpoSerial1.WriteData('RE'+#10);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  SdpoSerial1.WriteData(edCMD.text+#10);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
   SdpoSerial1.WriteData('PARA'+#10);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
   SdpoSerial1.WriteData('MSG1:'+edLCD1.Text+#10);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
     SdpoSerial1.WriteData('MSG2:'+edLCD2.text+#10);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
   SdpoSerial1.WriteData('LCDCLEAR'+#10);
end;

procedure TForm1.ckSetmonitorChange(Sender: TObject);
var
  Info: String;
begin
 if ckSetmonitor.Checked then
   Info := 'ON'
 else
   Info := 'OFF';
 SdpoSerial1.WriteData('SETMONITOR='+info+#10);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  lbVersao.Caption:= Versao;
end;

procedure TForm1.SdpoSerial1RxData(Sender: TObject);
begin
  Memo1.Lines.Append(SdpoSerial1.ReadData);
end;

procedure TForm1.TBbDirChange(Sender: TObject);
begin
  SdpoSerial1.WriteData('GBDIR='+inttostr(TBbDir.Position)+#10);
end;

procedure TForm1.TBbEsqChange(Sender: TObject);
begin
  SdpoSerial1.WriteData('GBESQ='+inttostr(TBbEsq.Position)+#10);
end;

procedure TForm1.tbGarraESQChange(Sender: TObject);
begin
  SdpoSerial1.WriteData('GPGARRAESQ='+inttostr(tbGarraESQ.Position)+#10);
end;

procedure TForm1.tbGarraChange(Sender: TObject);
begin
  SdpoSerial1.WriteData('GPGARRADIR='+inttostr(tbGarra.Position)+#10);
end;

procedure TForm1.tbGCABECAChange(Sender: TObject);
begin
  if (tbGCABECA.Position<90) THEN
  begin
    SdpoSerial1.WriteData('GCABECADIR='+inttostr(90-tbGCABECA.Position)+#10);
  end
   else
   begin
    SdpoSerial1.WriteData('GCABECAESQ='+inttostr(tbGCABECA.Position-90)+#10);
   end;
end;

procedure TForm1.tbGPunhoDirChange(Sender: TObject);
begin
    SdpoSerial1.WriteData('GPPUNHODIR='+inttostr(tbGPunhoDir.Position)+#10);
end;

procedure TForm1.tbGPunhoEsqChange(Sender: TObject);
begin
      SdpoSerial1.WriteData('GPPUNHOESQ='+inttostr(tbGPunhoEsq.Position)+#10);
end;

procedure TForm1.btConectarClick(Sender: TObject);
begin
 try
  SdpoSerial1.Device:= edPorta.text;
  SdpoSerial1.Open;;
  Memo1.Lines.Clear;

 finally
   Memo1.Lines.Append('Conectado!');
 end;
end;

procedure TForm1.btDesconectarClick(Sender: TObject);
begin
  SdpoSerial1.close;
  Memo1.Lines.Append('Desconectado');
end;

procedure TForm1.btGASClick(Sender: TObject);
begin
     SdpoSerial1.WriteData('GAS'+#10);
end;

procedure TForm1.btUltra0Click(Sender: TObject);
begin
       SdpoSerial1.WriteData('ULTRA0'+#10);
end;

procedure TForm1.btUltra1Click(Sender: TObject);
begin
       SdpoSerial1.WriteData('ULTRA1'+#10);
end;

procedure TForm1.btCorrenteClick(Sender: TObject);
begin
  //CORR
  SdpoSerial1.WriteData('CORR'+#10);
end;

end.

