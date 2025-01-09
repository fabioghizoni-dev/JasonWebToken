program JWTproj;

uses
  Horse,
  System.SysUtils,
  System.Hash,
  JOSE.Core.JWT,
  JOSE.Core.Builder;

var
  Port,
  UserID,
  UserParam:
  Integer;
  Hash:
  THashSHA2;
  HashResult,
  EndPoint,
  PassWord:
  string;

begin
  try
    // Verifica se o Parâmetro da Porta foi Passado
    if ParamCount > 0 then
    begin
      Port := StrToInt(ParamStr(1));
    end
    else
    begin
      Port := 9000;
    end;

    // Verifica se o Parâmetro do ENDPOINT foi Passado
    if ParamCount > 1 then
    begin
      EndPoint := ParamStr(2);
    end
    else
    begin
      EndPoint := '/login';
    end;

    // Verifica se o Parâmetro da SENHA do User foi Passado
    if ParamCount > 2 then
    begin

      UserID := 1234;
      UserParam := StrToInt(ParamStr(3));

      if not UserID = UserParam then
        Exit;

    end;

    // Inicialize o Hash
    Hash := THashSHA2.Create(SHA256);
    try

      HashResult := Hash.HashAsString; // Obtém o hash como string

      // Configuração do servidor Horse
      THorse.Get(EndPoint,
      procedure(Req: THorseRequest; Res: THorseResponse)
      var
        LToken: TJWT;
        LCompactToken: string;
      begin
        LToken := TJWT.Create;
        try
          // Adiciona claims no JWT
          LToken.Claims.Issuer := 'SOS Soluções';
          LToken.Claims.Subject := 'Fabio Ghizoni';
          LToken.Claims.Expiration := Now + 1; // Expiração em 1 dia

          // Outros claims se necessário
          LToken.Claims.SetClaimOfType<String>('NOME', 'Marcos');
          LToken.Claims.SetClaimOfType<Integer>('ID', UserID);

          // Assinatura e criação do token compactado
          LCompactToken := TJOSE.SHA256CompactToken('KEY', LToken);

          // Envia o token como resposta
          Res.Send(LCompactToken);

          // Inicia o servidor na porta configurada
          try
            Writeln('  Iniciando Servidor na Porta ', Port);
            Writeln('  Iniciando Servidor no EndPoint ', EndPoint);
            THorse.Listen(Port);
          except
            on E: Exception do
            begin
              Writeln('  Erro: ' + E.ClassName + E.Message);
              THorse.StopListen;
            end;
          end;

        finally
          LToken.Free;
        end;
      end);

    finally
    //
    end;
  except
    on E: Exception do
      Writeln('  Erro: ' + E.ClassName + E.Message);
  end;
end.

