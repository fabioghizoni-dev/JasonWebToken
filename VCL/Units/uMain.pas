unit uMain;

interface

uses
  Horse, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, ShellAPI, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
    pnlMain: TPanel;
    btnInit: TButton;
    pnlPort: TPanel;
    lblPort: TLabel;
    pnlEdts: TPanel;
    edtServer: TEdit;
    edtEndPoint: TEdit;
    lblEndPoint: TLabel;
    edtUserID: TEdit;
    lblUserID: TLabel;
    procedure btnInitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnInitClick(Sender: TObject);
var
  Paramns:
  String;
begin

  Paramns := edtServer.Text + ' ' + edtEndPoint.Text + ' ' + edtUserID.Text;

  try

    ShellExecute(0, 'Open', 'C:\Users\User\Documents\Embarcadero\Studio\Projects\JasonWebToken\Console\Exe\Win32Debug\jwtConsole.exe',
    PChar(Paramns), nil, SW_SHOWNORMAL);

  except

    on E: Exception do
      ShowMessage(E.ClassName + ': ' + E.Message);

  end;

end;

end.
