unit umpgSendMail;

interface

uses
  Classes, IdIOHandlerStack, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdExplicitTLSClientServerBase, IdSMTP, IdMessage,
  IdMessageParts;

type
//  TmpgSendMailAttachment = record
//    Attachment : TMemoryStream;
//    ContentDisposition : string;
//    ContentTransfer : string;
//    FileName : string;
//    Name : string;
//  end;

  TmpgSendMailRecipients = class(TObject)
    Address : string;
    Name : string;
  end;

  TmpgSendMailServerConfig = class(TObject)
    Host : string;
    Port : integer;
    UserName : string;
    UserPws : string;
  end;

  TmpgSendMailMessage = class(TObject)
    Subject : string;
    ContentType : string;
    Body : string;
    Date : TDateTime;
  end;

  TmpgSendMail = Class(TObject)
  private
//    FAttachment01: TmpgSendMailAttachment;
//    FAttachment02: TmpgSendMailAttachment;
//    FAttachment03: TmpgSendMailAttachment;
    FbTestMode: boolean;
    FFrom: TmpgSendMailRecipients;
    FMessage: TmpgSendMailMessage;
    FServer: TmpgSendMailServerConfig;
    FTo: TmpgSendMailRecipients;
    FUseTLS: TIdUseTLS;
    IdHandlerSSL: TIdSSLIOHandlerSocketOpenSSL;
    IdMessage: TIdMessage;
    IdSMTP: TIdSMTP;
    FOnAfterSend: TNotifyEvent;
    function GetMessagePart: TIdMessageParts;
  public
    constructor Create(msgCharset: string); reintroduce;
    destructor Destroy; override;
    procedure SendMail;
//    property Attachment01 : TmpgSendMailAttachment read FAttachment01 write FAttachment01;
//    property Attachment02 : TmpgSendMailAttachment read FAttachment02 write FAttachment02;
//    property Attachment03 : TmpgSendMailAttachment read FAttachment03 write FAttachment03;
    property FromList : TmpgSendMailRecipients read FFrom write FFrom;
    property Message : TmpgSendMailMessage read FMessage write FMessage;
    property Server : TmpgSendMailServerConfig read FServer write FServer;
    property TestMode : boolean read FbTestMode write FbTestMode;
    property ToList : TmpgSendMailRecipients read FTo write FTo;
    property UseTLS : TIdUseTLS read FUseTLS write FUseTLS;
    property MessagePart : TIdMessageParts read GetMessagePart;
    property OnAfterSend : TNotifyEvent read FOnAfterSend write FOnAfterSend;  
  end;

implementation

uses
  IdAttachmentMemory, IdText, IdGlobal, SysUtils;

{ TmpgSendMail }

constructor TmpgSendMail.Create(msgCharset: string);
begin
 inherited Create;
  IdHandlerSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  with IdHandlerSSL do
  begin
    Name := 'IdHandlerSSL';
    Destination := ':25';
    MaxLineAction := maException;
    Port := 25;
    DefaultPort := 0;
  end;

  IdSMTP := TIdSMTP.Create(nil);
  IdSMTP.Name := 'IdSMTP';
  IdSMTP.IOHandler := IdHandlerSSL;

  IdMessage := TIdMessage.Create(nil);
  with IdMessage do
  begin
    Name := 'IdMessage';
    AttachmentEncoding := 'UUE';
    CharSet := msgCharset;
    ContentType := 'multipart/mixed';
    Encoding := meMIME;
    ConvertPreamble := True;
  end;

//  FAttachment01.ContentDisposition := 'attachment';
//  FAttachment01.ContentTransfer := 'base64';
//  FAttachment02.ContentDisposition := 'attachment';
//  FAttachment02.ContentTransfer := 'base64';
//  FAttachment03.ContentDisposition := 'attachment';
//  FAttachment03.ContentTransfer := 'base64';

  FFrom := TmpgSendMailRecipients.Create;
  FMessage := TmpgSendMailMessage.Create;
  FServer := TmpgSendMailServerConfig.Create;
  FTo := TmpgSendMailRecipients.Create;
  FMessage.ContentType := 'text/html';
end;

destructor TmpgSendMail.Destroy;
begin
  IdMessage.Free;
  IdSMTP.Free;
  FFrom.Free;
  FMessage.Free;
  FServer.Free;
  FTo.Free;
  inherited;
end;

function TmpgSendMail.GetMessagePart: TIdMessageParts;
begin
  result := IdMessage.MessageParts;
end;

procedure TmpgSendMail.SendMail;
var
//  oAnexo : TIdAttachmentMemory;
  aTexto : TIdText;

//  procedure AddAttachment(pAttachment : TmpgSendMailAttachment);
//  begin
//    if Assigned(pAttachment.Attachment) then
//    begin
//      oAnexo.LoadFromStream(pAttachment.Attachment);
//      oAnexo.Name := FAttachment01.Name;
//      oAnexo.ContentDisposition := pAttachment.ContentDisposition;
//      oAnexo.FileName := pAttachment.FileName;
//      oAnexo.ContentTransfer := pAttachment.ContentTransfer;
//    end;
//  end;

begin
//  oAnexo := TIdAttachmentMemory.Create(IdMessage.MessageParts);
  aTexto := TIdText.Create(IdMessage.MessageParts);
  try
    //Anexos
//    AddAttachment(FAttachment01);
//    AddAttachment(FAttachment02);
//    AddAttachment(FAttachment03);

    //Configuraзхes do servidor
    IdSMTP.Host := FServer.Host;
    IdSMTP.Password := FServer.UserPws;
    IdSMTP.UseTLS := FUseTLS;
    IdSMTP.Port := FServer.Port;
    IdSMTP.Username := FServer.UserName;
    IdSMTP.ConnectTimeout:=10000;
    IdSMTP.ReadTimeout:=10000;
    //Corpo da mensagem
    aTexto.Body.Text := FMessage.Body;
    aTexto.ContentType := FMessage.ContentType;
    IdMessage.Date := Now;
    IdMessage.Subject := FMessage.Subject;

    //From
    IdMessage.From.Address := FFrom.Address;
    IdMessage.From.Name := FFrom.Name;

    //To
    with IdMessage.Recipients.Add do
    begin
      if not(FbTestMode) then
        Address := FTo.Address
      else
        Address := 'artem-xp@yandex.ru';//'ruscigno@gmail.com';
      Name := FTo.Name;
    end;

    IdSMTP.Connect;
    IdSMTP.Send(IdMessage);  //
    { если ошибка Invalid codepage 20932 - установить кодовую страницу преобразования в языке панели управления }
    IdSMTP.Disconnect;

    if Assigned(FOnAfterSend) then
      FOnAfterSend(Self);
  finally
    FreeAndNil(aTexto);
//    FreeAndNil(oAnexo);
    //Limpando resнduos
    IdMessage.Recipients.Clear;
    IdMessage.FromList.Clear;
    IdMessage.MessageParts.Clear;
    IdMessage.Body.Clear;
  end;
end;

end.
