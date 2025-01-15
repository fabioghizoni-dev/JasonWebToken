unit uMain;

interface

uses
  Horse,
  Horse.JWT,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  JOSE.Core.JWT,
  JOSE.Core.JWK,
  JOSE.Consumer,
  JOSE.Core.Builder,
  JOSE.Hashing.HMAC,
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
    mmoJSON: TMemo;
    pnlMMO: TPanel;
    procedure checkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
  private
    function MakeJWT(User, PassWord, Issuer, Subject: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses System.JSON, System.DateUtils;

{$R *.dfm}



{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  ID: Integer;
  LToken,
  Server_User,
  Server_Pass: String;
begin
  try

    THorse.Use(Jhonson);

    mmoJSON.Clear;
    checkClick(Sender);
    Server_User := 'Fabio Ghizoni';
    Server_Pass := '12345678';
    ID := 40028922;

    THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals(Server_User) and APassword.Equals(Server_Pass);
    end));

    // Rota para autenticação básica '/private/FirstAuth'
    THorse.Post('private/FirstAuth',
      procedure(Req: THorseRequest; Res: THorseResponse)
      begin
        try
          Res.ContentType('application/json');
          LToken := MakeJWT(Server_User, Server_Pass, 'SOS Soluções', '40028922');
          Res.Send(LToken);
        except
          on E: Exception do
            ShowMessage('Classe: ' + E.ClassName + sLineBreak + 'Erro: ' + E.Message);
        end;
      end
    );

    // Após a autenticação básica, agora vamos usar JWT para todas as outras rotas
    THorse.Use(HorseJWT(LToken, THorseJWTConfig.New.SkipRoutes(['private/FirstAuth'])));

    // Rota '/private/TokenAuth' agora usa JWT para autenticação
    THorse.Post('private/TokenAuth',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Res.Send('Sucesso');
      end
    );

    THorse.Listen(8080,
    procedure
    begin
      if THorse.IsRunning = True then
        Caption := Format('Servidor rodando em %d', [THorse.Port]);
    end);

  finally

  end;
end;

function TfrmMain.MakeJWT(User, PassWord, Issuer, Subject: string): string;
var
  LTokenJWT: TJWT;
  LKeyJWK: TJWK;
  LCompactToken: String;
begin

  Result := EmptyStr;
  LKeyJWK := TJWK.Create('key');

  if (User = 'Fabio Ghizoni') and (PassWord = '12345678') then
  begin
    try

      if mmoJSON.Lines.Count > 0 then
        mmoJSON.Clear;

      if not (Trim(Issuer) = EmptyStr) and not (Trim(Subject) = EmptyStr) then
      begin

        LTokenJWT := TJWT.Create;

        LTokenJWT.Claims.Issuer := Issuer;
        LTokenJWT.Claims.Subject := Subject;
        LTokenJWT.Claims.Expiration := IncHour(Now + 1);

        LCompactToken := TJOSE.SHA512CompactToken('key', LTokenJWT);
        mmoJSON.Lines.Add(LCompactToken);

        LTokenJWT.Verified := False;
        TJOSE.Verify(LKeyJWK, LCompactToken, LTokenJWT.ClaimClass);

        if Assigned(LTokenJWT) then
        begin

          if LTokenJWT.Verified = True then
          begin
            Result := 'Token verificado com sucesso!';
          end
          else
          begin
            Result := 'Token errado, tente novamente ou mude o Token!';
          end;

        end;

      end;

    finally

      FreeAndNil(LTokenJWT);

    end;
  end;

end;

procedure TfrmMain.btnConfirmClick(Sender: TObject);
var
  User,
  PassWord:
  String;

begin

  User := 'Fabio Ghizoni';
  PassWord := '12345678';

  ShowMessage(MakeJWT(User, PassWord, 'SOS Soluções', '40028922'));

end;

procedure TfrmMain.checkClick(Sender: TObject);
begin

  if check.Checked = True then
  begin
    edtUser.Text := 'Fabio Ghizoni';
    edtPassWord.Text := '12345678';
  end
  else
  begin
    edtUser.Text := EmptyStr;
    edtPassWord.Text := EmptyStr;
  end;

end;

end.
