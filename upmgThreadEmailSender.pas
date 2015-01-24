unit upmgThreadEmailSender;

interface

uses
  Classes, Windows, umailSendMail;

type
  TpmgThreadEmailSender = class(TThread)
  private
    FMailSender : TmailSendEmail;
    FsMailAviso : string;
    FnIntervalo : integer;
    FnIntervaloContador : integer;
    FsListaEmails : TStringList;
    function ServicoAtivo : boolean;
    procedure CalcHoraNovaExecucao;
  protected
    procedure Execute; override;
    procedure OnBeforeSend(Sender: TObject);
    procedure OnAfterSend(Sender: TObject);
  public
    constructor Create(CreateSuspended: Boolean); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  upmgDMemailSender, upmgEmailSenderConfig, umpgConstantes, SysUtils,
  upmgConstantes, umailEmails, DateUtils, umpgSendMail, umailContas, DB,
  IdExplicitTLSClientServerBase;

{ TpmgThreadEmailSender }

procedure TpmgThreadEmailSender.CalcHoraNovaExecucao;
begin
  if (FnIntervalo > 0) then
    FnIntervaloContador := FnIntervalo * 60 {segundos} * 60 {minutos}
  else
    Terminate;
end;

constructor TpmgThreadEmailSender.Create(CreateSuspended: Boolean);
begin
  inherited;
  FMailSender := TmailSendEmail.Create(fpmgDMemailSender.ZConnection);
  FMailSender.OnBeforeSend := OnBeforeSend;
  FMailSender.OnAfterSend := OnAfterSend;
  FreeOnTerminate := True;
  FsMailAviso := STRING_INDEFINIDO;
  FnIntervalo := NUMERO_INDEFINIDO;
  FnIntervaloContador := NUMERO_INDEFINIDO;
  FsListaEmails := TStringList.Create;
end;

destructor TpmgThreadEmailSender.Destroy;
begin
  FMailSender.Free;
  FsListaEmails.Free;
  inherited;
end;

procedure TpmgThreadEmailSender.Execute;
var
  emailEmails : TemailEmails;

  function VerificaData : boolean;
  begin
    if (emailEmails.FieldByName('NUDIASPERIODICIDADE').AsInteger > 0) then
      result := (DaySpan(
        emailEmails.FieldByName('DTULTENVIO').AsDateTime, Now) >
        emailEmails.FieldByName('NUDIASPERIODICIDADE').AsInteger)
    else
      result := false;
  end;

  procedure SendMailAviso;
  var
    oSend : TmpgSendMail;
    oContas : TemailContas;
  begin
    oContas := TemailContas.Create(nil);
    oSend := TmpgSendMail.Create;
    try
      oContas.Connection := fpmgDMemailSender.ZConnection;
      oContas.Select := 'SelectConsulta';
      oContas.ParamByName('USUARIO').AsString := FsMailAviso;
      oContas.Open;
      if not(oContas.IsEmpty) then
      begin
        oSend.FromList.Address := oContas.FieldByName('USUARIO').AsString;
        oSend.FromList.Name := 'Personal Manager';
        oSend.Message.Subject := 'EmailSender';
        oSend.Message.ContentType := 'text/plain';
        oSend.Message.Body := FsListaEmails.Text;
        oSend.Message.Date := Now;
        oSend.Server.Host := oContas.FieldByName('SERVIDOR').AsString;
        oSend.Server.Port := oContas.FieldByName('NUPORTA').AsInteger;
        oSend.Server.UserName := oContas.FieldByName('USUARIO').AsString;
        oSend.Server.UserPws := oContas.FieldByName('SENHA').AsString;
        oSend.UseTLS := TIdUseTLS(oContas.FieldByName('NUTSL').AsInteger);
        oSend.ToList.Address := FsMailAviso;
        oSend.SendMail;
      end;
    finally
      oSend.Free;
      oContas.Free;
    end;
  end;
  
begin
  inherited;
  if (ServicoAtivo) then
    while not Terminated do
    begin
      if (FnIntervaloContador = 0) or (FnIntervaloContador = NUMERO_INDEFINIDO) then
      begin
        emailEmails := TemailEmails.Create(nil);
        try
          emailEmails.Select := 'SelectEnvioAtivos';
          emailEmails.Connection := fpmgDMemailSender.ZConnection;
          emailEmails.Open;
          while not emailEmails.Eof do
          begin
            if (VerificaData) then
              try
                FMailSender.CreateMsg(True, emailEmails.FieldByName('CDEMAIL').AsInteger);
              except
                On E: Exception do
                  FsListaEmails.Add(emailEmails.FieldByName('EMAIL').AsString + ' - Erro: ' + E.Message);
              end;
            emailEmails.Next;
          end;
          if (FsListaEmails.Count > 0) then
          begin
            SendMailAviso;
            FsListaEmails.Clear;
          end;
        finally
          emailEmails.Free;
        end;
        CalcHoraNovaExecucao;
      end;
      Sleep(1000);
      Dec(FnIntervaloContador);
    end;
end;

procedure TpmgThreadEmailSender.OnAfterSend(Sender: TObject);
begin
  with TmailSendEmail(Sender) do
    FsListaEmails.Add(ToNome + ' <' + ToEmail + '> - ' + ToCargo + ': ' +
      ToEmpresa + ' [' + Assunto + ']');
end;

procedure TpmgThreadEmailSender.OnBeforeSend(Sender: TObject);
begin

end;

function TpmgThreadEmailSender.ServicoAtivo: boolean;
var
  epmgConfig : TepmgEmailSenderConfig;
begin
  epmgConfig := TepmgEmailSenderConfig.Create(nil);
  try
    FnIntervalo := NUMERO_INDEFINIDO;
    FsMailAviso := STRING_INDEFINIDO;
    epmgConfig.Select := 'SelectPadrao';
    epmgConfig.Open;
    while not epmgConfig.Eof do
    begin
      if (UpperCase(epmgConfig.FieldByName('CDCONFIG').AsString) = smailCONFIG_EMAIL_AVISO) then
        FsMailAviso := epmgConfig.FieldByName('VLCONFIG1').AsString
      else if (UpperCase(epmgConfig.FieldByName('CDCONFIG').AsString) = smailCONFIG_INTERVALO) then
        FnIntervalo := epmgConfig.FieldByName('VLCONFIG1').AsInteger;
      epmgConfig.Next;
    end;
    result := (FnIntervalo > 0);
  finally
    epmgConfig.Free;
  end;
end;

end.
