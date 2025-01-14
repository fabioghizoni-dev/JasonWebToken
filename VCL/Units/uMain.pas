unit uMain;

interface

uses
  Horse,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  JOSE.Core.JWT,
  JOSE.Core.JWA,
  JOSE.Core.JWK,
  JOSE.Core.Builder,
  JOSE.Core.Parts,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
    pnlMain: TPanel;
    pnlLeft: TPanel;
    pnlEndPoint: TPanel;
    pnlEdtPort: TPanel;
    pnlLblPort: TPanel;
    lblPort: TLabel;
    lblEndPoint: TLabel;
    pnlEdtEndPoint: TPanel;
    pnlCheckBox: TPanel;
    pnlLblStandard: TPanel;
    lblStandard: TLabel;
    check: TCheckBox;
    pnlQuite: TPanel;
    pnlLblUser: TPanel;
    lblUser: TLabel;
    pnlEdtUser: TPanel;
    edtUser: TEdit;
    pnlLblPassWord: TPanel;
    pnlEdtPassWord: TPanel;
    lblPassWord: TLabel;
    edtPassWord: TEdit;
    pnlBtnConfirm: TPanel;
    btnConfirm: TButton;
    lblPortStandard: TLabel;
    lblEnPointStandard: TLabel;
    mmoJSON: TMemo;
    pnlMMO: TPanel;
    procedure checkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
  private
    function MakeJWT(User, PassWord, Issuer, Subject: string): string;
    function ValidJWT(JWT: TJWT; Token, Key: String): Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses System.JSON;

{$R *.dfm}



{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  ID: Integer;
  LBody: TJSONObject;
  LToken,
  Server_User,
  Server_Pass: String;
begin
  try

    THorse.Use(Jhonson);
    lblPortStandard.Caption := '8080';
    lblEnPointStandard.Caption := '/Private';

    mmoJSON.Clear;
    checkClick(Sender);
    Server_User := 'Fabio Ghizoni';
    Server_Pass := '12345678';
    ID := 40028922;

    THorse.Use(HorseBasicAuthentication(function(const AUsername, APassword: String): Boolean
    begin
      Result := AUsername.Equals(Server_User) and APassword.Equals(Server_Pass);
    end));

    THorse.Get('/Private/FirstAuth', procedure(Req: THorseRequest; Res: THorseResponse)
    begin

      try

        LBody := TJSONObject.Create;
        LBody.AddPair('User', Server_User);
        LBody.AddPair('ID', TJSONNumber.Create(ID));

        Res.ContentType('application/json');
        Res.AddHeader('Hello', 'World');
        Res.Send(LBody.ToJSON);

        THorse.Get('/Private/AuthToken', procedure(Req: THorseRequest; Res: THorseResponse)
        begin
          Res.Send(MakeJWT(Server_User, Server_Pass, 'SOS Soluções', 'Fabio Ghizoni'));
        end);

      except
        on E: Exception do
          ShowMessage(E.Message);

      end;
    end);

    THorse.Listen(8080);

  finally
    FreeAndNil(LBody);
  end;
end;

procedure TfrmMain.btnConfirmClick(Sender: TObject);
var
  User,
  PassWord:
  String;

begin

  if not (Trim(edtUser.Text) = EmptyStr) then
  begin
    User := edtUser.Text;
  end
  else
    Exit;

  if not (Trim(edtPassWord.Text) = EmptyStr) then
  begin
    PassWord := edtPassWord.Text;
  end
  else
    Exit;

  //MakeJWT(User, PassWord);

end;

function TfrmMain.ValidJWT(JWT: TJWT; Token, Key: String): Boolean;
begin

  Result := False;

end;

function TfrmMain.MakeJWT(User, PassWord, Issuer, Subject: string): string;
var
  LToken: TJWT;
  LCompactToken: String;
begin

  if (User = 'Fabio Ghizoni') and (PassWord = '40028922') then
  begin
    try

      if mmoJSON.Lines.Count > 0 then
        mmoJSON.Clear;

      if (Trim(Issuer) = EmptyStr) and (Trim(Subject) = EmptyStr) then
      begin
        LToken := TJWT.Create;
        LToken.Claims.Issuer := Issuer;
        LToken.Claims.Subject := Subject;
        LToken.Claims.Expiration := Now + 1;

        LCompactToken := TJOSE.SHA256CompactToken('my_key', LToken);
        mmoJSON.Lines.Add(LCompactToken);
      end;

      Result := LCompactToken;

    finally

      FreeAndNil(LToken);

    end;
  end;

end;

procedure TfrmMain.checkClick(Sender: TObject);
begin

  if check.Checked = True then
  begin
    edtUser.Text := 'Fabio Ghizoni';
    edtPassWord.Text := '40028922';
  end
  else
  begin
    edtUser.Text := EmptyStr;
    edtPassWord.Text := EmptyStr;
  end;

end;

end.
