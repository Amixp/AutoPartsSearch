unit UnitSend;

interface

uses SysUtils, System.IOUtils, IdUserPassProvider,
  IdExplicitTLSClientServerBase, httpsend,
  IdMessageClient, IdSMTPBase, IdSMTP, IdSASLPlain, IdSASL, IdSASLUserPass,
  IdSASLLogin, IdMessage, IdLogBase, IdAntiFreeze, IdAttachment,
  IdAttachmentFile, IdText, IdLogDebug, IdCoder, IdCoderQuotedPrintable,
  IdIntercept, IdHTTP, StrUtils, Mshtml, SHDocVw, System.Variants,
  IdMessageParts,
  ActiveX, Windows, Winapi.Messages, Vcl.Forms, IdCharsets, umpgSendMail,
  Classes;

type
  dt = string; // пустое определение для обьявления функций ниже!
  // странное решение, но работает! :)

procedure Log(Txt: string; debuglevel: Integer = 0; ToConsole: boolean = true);
procedure SendMail(idMsg: TIdMessage);
procedure SendMail1(idMsg: TIdMessage);
function SendMail2(sFrom, sTo, sHost, sPort, sSubject, sLogin, sPass,
  sBody: string; slAttachments: tstrings): boolean;
function SendMail3(idMsg: TIdMessage; slAttachments: tstrings): boolean;
// function sSendMail(aHost: String): Boolean;
// procedure TestMail;
procedure mIdMessageInitializeISO(var VHeaderEncoding: Char;
  var VCharSet: string);

// procedure SendAtach;
// procedure SendHTMLMail;
procedure AttacheFiles(var mIdMessage: TIdMessage; BodyHTML: string;
  sAttacheFilesPath: tstrings; sCharset: string);
function GetImg(const sURL: string; var StreamFile: TMemoryStream)
  : boolean; overload;
function GetImg(sURL, FileNameToSave: string): boolean; overload;
function GetHTTP(idHTTPvar: TIdHTTP; sURL: string): string; overload;
procedure GetHTTP(idHTTPvar: TIdHTTP; sURL: string;
  AResponseContent: TStream); overload;
function PostHTTP(sMethod: string; idHTTPvar: TIdHTTP; sURL: string;
  PostData: tstrings): string;

// procedure SendData(sListData: tstrings);
function ValidData: boolean;
procedure TextToWebBrowser(Text: string; var WB: tWebBrowser);

var
  Cookies: string;

implementation

uses MainUnit, settings;

function ProxyHttpPostURL(const URL, URLData: string;
  const Data: TStream): boolean;
var
  sgHTTP: THTTPSend;
begin
  sgHTTP := THTTPSend.Create;
  try
    sgHTTP.Document.Write(Pointer(URLData)^, Length(URLData));
    sgHTTP.MimeType := 'application/x-www-form-urlencoded';
    Result := sgHTTP.HTTPMethod('POST', URL);
    Data.CopyFrom(sgHTTP.Document, 0);
  finally
    sgHTTP.Free;
  end;
end;

procedure Log(Txt: string; debuglevel: Integer = 0; ToConsole: boolean = true);
begin
  // MainTest.Log(Txt, debuglevel, ToConsole);
  FormMain.Log(Txt, debuglevel);
end;

procedure SendMail(idMsg: TIdMessage);
{ DONE : Sendmail работает. осталось добавить отправку по таймеру и переделать тестовую отправку }
const
  EdMailLogin: string = 'artem-xp@yandex.ru';
  EdMailPass: string = 'prepare5swine';
var
  IdSMTP: TIdSMTP;
  IdMessage: TIdMessage;
  IdUserPassProvider: TIdUserPassProvider;
  IdSASL: TIdSASLLogin;
  IdAntiFreeze: TidAntiFreeze;
begin
  IdSMTP := TIdSMTP.Create(nil);
  // IdMessage := TIdMessage.Create(nil);
  IdUserPassProvider := TIdUserPassProvider.Create(nil);
  IdSASL := TIdSASLLogin.Create(nil);
  IdAntiFreeze := TidAntiFreeze.Create(nil);
  Log('Attempting to send mail');

  with IdSMTP do
  begin
    // Caption := 'Trying to sendmail via: ' + aHost;
    Host := 'smtp.yandex.ru';
    Log('Trying to sendmail via: ' + Host);
    AuthType := satDefault;
    Port := 25;
    Username := EdMailLogin;
    Password := EdMailPass;

    IdUserPassProvider.Username := EdMailLogin;
    IdUserPassProvider.Password := EdMailPass;
    IdSASL.UserPassProvider := IdUserPassProvider;

    try
      // IdEncoderQuotedPrintable1.Encode(IdMessage1.);
      Log('Attempting connect');
      Connect;
      Log('Successful connect ... sending message');
      Send(idMsg);
      Log('Attempting disconnect');
      Disconnect;
      Log('Successful disconnect');

      Log('Messege successfule send!');
    except
      on E: Exception do
      begin
        if connected then
          try
            Disconnect;
          except
          end;
        Log('Error sending message!' + E.Message);

      end;
    end;
  end;
  IdAntiFreeze.Free;
  IdUserPassProvider.Free;
  IdSMTP.Free;
  IdSASL.Free;
  // IdMessage.free;
end;

{
  procedure TestMail;
  var
  IdMessage: TIdMessage;
  EdSender, EdRecipients: string;
  begin
  IdMessage := TIdMessage.Create(nil);
  with IdMessage do
  begin
  Log('Assigning mail test message properties');
  From.Text := 'Delphi Indy Client <' + 'artemxp@yandex.ru' + '>';
  Sender.Text := 'artemxp@yandex.ru';
  Recipients.EMailAddresses := 'artemxp@gmail.com';
  Subject := 'Поиск автозапчастей по параметрам (TEST MESSAGE)';
  ContentType := 'text/plain';
  CharSet := 'Windows-1251';
  ContentTransferEncoding := '8bit';
  IsEncoded := true;
  Body.Text := 'Поиск автозапчастей по параметрам ' + #$D + #$A +
  'TEST MESSAGE!'
  end;
  Log('SendMail test.');
  SendMail(IdMessage);
  // ShowMessage('Тестовое письмо отправлено.');
  IdMessage.Free;
  end;
}
procedure AttacheFiles(var mIdMessage: TIdMessage; BodyHTML: string;
  sAttacheFilesPath: tstrings; sCharset: string);
var
  i: Integer;
begin
  with TIdText.Create(mIdMessage.MessageParts, nil) do
  begin // вставка HTML текста, перед аттачами
    ContentType := 'text/html;';
    CharSet := sCharset; // !!!!!!!!!!!!!
    // ContentTransferEncoding := '8bit';
    Body.Text := BodyHTML; // AnsiToUtf8(
  end;

  i := 0;
  if sAttacheFilesPath <> nil then
  begin
    while i < sAttacheFilesPath.Count do
    begin
      if FileExists(sAttacheFilesPath.Strings[i]) then
      begin
        // замена всех путей в тексте на cid:filename
        BodyHTML := StringReplace(BodyHTML, sAttacheFilesPath.Strings[i],
          'cid:' + TPath.GetFileNameWithoutExtension
          (sAttacheFilesPath.Strings[i]), []);
        inc(i);
      end
      else
        sAttacheFilesPath.Delete(i);
      // удалить несуществующий путь к файлу картинки
    end;

    for i := 0 to sAttacheFilesPath.Count - 1 do
      with TIdAttachmentFile.Create(mIdMessage.MessageParts,
        sAttacheFilesPath.Strings[i]) do
      begin // присоединение файлов в аттачи
        ContentDisposition := 'inline';
        ContentID := TPath.GetFileNameWithoutExtension
          (sAttacheFilesPath.Strings[i]);
        ContentType := 'image/' + StringReplace
          (ExtractFileExt(sAttacheFilesPath.Strings[i]), '.', '', []);
        FileName := ExtractFileName(sAttacheFilesPath.Strings[i]);
        { DONE : Работает!! ))) }
      end;
  end;
  mIdMessage.ContentType := 'multipart/related; type="text/html"';
  mIdMessage.CharSet := sCharset;
  mIdMessage.ContentTransferEncoding := 'base64';
  mIdMessage.Encoding := meMIME;
  mIdMessage.GenerateHeader;
  // =====
end;

procedure SendMail1(idMsg: TIdMessage);
{ DONE : Sendmail работает. осталось добавить отправку по таймеру и переделать тестовую отправку }
const
  EdMailLogin: string = 'artem-xp@yandex.ru';
  EdMailPass: string = 'prepare5swine';
var
  IdSMTP: TIdSMTP;
  IdMessage: TIdMessage;
  IdUserPassProvider: TIdUserPassProvider;
  IdSASL: TIdSASLLogin;
  IdAntiFreeze1: TidAntiFreeze;
begin
  IdSMTP := TIdSMTP.Create(nil);
  // IdMessage := TIdMessage.Create(nil);
  IdUserPassProvider := TIdUserPassProvider.Create(nil);
  IdSASL := TIdSASLLogin.Create(nil);
  IdAntiFreeze1 := TidAntiFreeze.Create(nil);
  Log('Attempting to send mail');
  try
    with IdSMTP do
    begin
      // Caption := 'Trying to sendmail via: ' + aHost;
      Host := 'smtp.yandex.ru';
      Log('Trying to sendmail via: ' + Host);
      AuthType := satDefault;
      Port := 25;
      Username := EdMailLogin;
      Password := EdMailPass;

      IdUserPassProvider.Username := EdMailLogin;
      IdUserPassProvider.Password := EdMailPass;
      IdSASL.UserPassProvider := IdUserPassProvider;

      try
        // IdEncoderQuotedPrintable1.Encode(IdMessage1.);
        Log('Attempting connect');
        Connect;
        Log('Successful connect ... sending message');
        Send(idMsg);
        Log('Attempting disconnect');
        Disconnect;
        Log('Successful disconnect');

        Log('Messege successfule send!');
      except
        on E: Exception do
        begin
          if connected then
            try
              Disconnect;
            except
            end;
          Log('Error sending message!' + E.Message);

        end;
      end;
    end;
  finally
    IdAntiFreeze1.Free;
    IdUserPassProvider.Free;
    IdSMTP.Free;
    IdSASL.Free;
  end;
  // IdMessage.free;
end;

procedure mIdMessageInitializeISO(var VHeaderEncoding: Char;
  var VCharSet: string);
begin
  VCharSet := IdCharsetNames[idcs_EUC_JP];
  VHeaderEncoding := 'B';
end;

function SendMail3(idMsg: TIdMessage; slAttachments: tstrings): boolean;
var
  msgMail: TmpgSendMail;
  msgPart: TIdMessagePart;
  i: Integer;
begin
  Result := False;

  { with IdMsg do
    begin
    FormMain.Log('Assigning mail test message properties');
    From.Text := 'Delphi Indy Client <' + FormSettings.EdSender.Text + '>';
    Sender.Text := FormSettings.EdSender.Text;
    Recipients.EMailAddresses := FormSettings.EdRecipients.Text;
    Subject := 'Japancar.ru - Поиск автозапчастей по параметрам (TEST MESSAGE)';
    ContentType := 'text/plain';
    CharSet := 'Windows-1251';
    ContentTransferEncoding := '8bit';
    IsEncoded := true;
    Body.Text := 'Japancar.ru - Поиск автозапчастей по параметрам ' + #$D + #$A + 'TEST MESSAGE!'
    end; }
  msgMail := TmpgSendMail.Create('Windows-1251');

  try
    FormMain.Log('SendMail ready...');
    { TODO : исправить кодировку! }
    // msgMail.MessagePart.AttachmentEncoding:=
    msgMail.Message.Body := '';
    msgMail.Message.ContentType := idMsg.ContentType;
    TIdText.Create(msgMail.MessagePart, idMsg.Body);
    msgMail.MessagePart.Items[0].ContentTransfer :=
      idMsg.ContentTransferEncoding;
    msgMail.MessagePart.Items[0].CharSet := idMsg.CharSet;
    msgMail.MessagePart.Items[0].ContentType := idMsg.ContentType;
    msgMail.Message.Subject := idMsg.Subject;
    msgMail.MessagePart.CountParts;
    // ShowMessage(IntToStr(msgMail.MessagePart.Count));

    msgMail.Server.Username := FormSettings.EdMailLogin.Text;
    msgMail.Server.UserPws := FormSettings.EdMailPass.Text;
    msgMail.Server.Port := StrToInt(FormSettings.edSMTPport.Text);
    msgMail.Server.Host := FormSettings.EdSMTPHost.Text;
    msgMail.FromList.Address := FormSettings.EdSender.Text;
    msgMail.FromList.Name := FormSettings.EdSender.Text;
    msgMail.ToList.Address := FormSettings.EdRecipients.Text;
    msgMail.UseTLS := utUseImplicitTLS; // (ExplicitTLSVals);
    { IdMessage.Body.AddStrings(mMessage.Lines);
    }
    if slAttachments <> nil then

      for i := 0 to slAttachments.Count - 1 do
      begin
        if (FileExists(slAttachments.Strings[i])) then
        begin
          TIdAttachmentFile.Create(msgMail.MessagePart,
            slAttachments.Strings[i]);
        end;
      end;

    // msgPart:=msgMail.MessagePart.Add ;
    /// /  TIdAttachmentFile.Create(msgMail.MessagePart,  ExtractFilePath(Application.ExeName)+'\autocar.jpeg');
    // msgPart.FileName:=ExtractFilePath(Application.ExeName)+'\autocar.jpeg';
    msgMail.SendMail;
    // FormMain.SendMail(FormMain.IdMessage1);
    FormMain.Log('письмо отправлено.');
    Result := true;
  finally
    msgMail.Free;
  end;
end;

function SendMail2(sFrom, sTo, sHost, sPort, sSubject, sLogin, sPass,
  sBody: string; slAttachments: tstrings): boolean;
var
  msg: TIdMessage;
  IdSMTP1: TIdSMTP;
  att: TIdAttachmentFile;
  i: Integer;
  sl: tstrings;
  s, b: string;
  str: tstrings;
  Metod: Tmethod;

  msgMail: TmpgSendMail;
  msgPart: TIdMessagePart;

begin
  Result := False;
  str := TStringList.Create;

  msgMail := TmpgSendMail.Create('EUC-JP');
  try
    FormMain.Log('SendMail ready...');
    { TODO : исправить кодировку письма! }
    // msgMail.MessagePart.AttachmentEncoding:=

    msgMail.Message.Body := sBody;
    str.Add(sBody);
    msgMail.Message.ContentType := 'text/html'; // charset=EUC-JP';
    // msgMail.Message.
    msgMail.MessagePart.Items[0].ContentTransfer := '8bit';
    msgMail.MessagePart.Items[0].CharSet := 'EUC-JP';
    msgMail.MessagePart.Items[0].ContentType := 'text/html'; // ; charset=EUC-JP
    // msgMail.MessagePart.Items[0].PartType(mptText);
    TIdText.Create(msgMail.MessagePart, str);
    s := msgMail.Message.Body;
    msgMail.Message.Subject := sSubject;
    msgMail.MessagePart.CountParts;
    // ShowMessage(IntToStr(msgMail.MessagePart.Count));

    msgMail.Server.Username := FormSettings.EdMailLogin.Text;
    msgMail.Server.UserPws := FormSettings.EdMailPass.Text;
    msgMail.Server.Port := StrToInt(FormSettings.edSMTPport.Text);
    msgMail.Server.Host := FormSettings.EdSMTPHost.Text;
    msgMail.FromList.Address := FormSettings.EdSender.Text;
    msgMail.FromList.Name := FormSettings.EdSender.Text;
    msgMail.ToList.Address := FormSettings.EdRecipients.Text;
    msgMail.UseTLS := utUseImplicitTLS; // (ExplicitTLSVals);
    { IdMessage.Body.AddStrings(mMessage.Lines);
    }
    if slAttachments <> nil then

      for i := 0 to slAttachments.Count - 1 do
      begin
        if (FileExists(slAttachments.Strings[i])) then
        begin
          TIdAttachmentFile.Create(msgMail.MessagePart,
            slAttachments.Strings[i]);
        end;
      end;
    msgMail.SendMail;
    FormMain.Log('письмо отправлено.');
    Result := true;
  finally
    msgMail.Free;
    str.Free;
  end;

  {
    // version 2
    try
    with FormMain.IdMessage1 do
    begin
    FormMain.Log('Assigning mail message properties');
    From.Text := sFrom;
    From.Address :=sFrom;
    Sender.Text := sTo;
    Recipients.EMailAddresses := sTo;
    Subject := sSubject;
    ContentType := 'text/html; charset=EUC-JP';
    CharSet := 'EUC-JP';
    ContentTransferEncoding := '8bit';
    IsEncoded := true;
    Body.Text := sBody;
    end;
    FormMain.Log('SendMail.');
    FormMain.Log('Attempting to send mail');
    if SendMail3(FormMain.IdMessage1,slAttachments) then
    begin
    Log('Send mail OK');
    result:=true;
    end;

    except
    on E: Exception do
    begin

    Log('Error send mail:' + E.Message);
    result:=false;
    end;
    end; }

  { // version 1
    result:=false;
    Log('Start SMTP...');
    IdSMTP1 := TIdSMTP.Create(nil);
    try
    IdSMTP1.AuthType := satDefault;
    IdSMTP1.Host := sHost; // 'smtp.yandex.ru';
    IdSMTP1.Port := StrToInt(sPort); // 25;
    IdSMTP1.Username := sLogin; // 'a.cia';
    IdSMTP1.Password := sPass; // 'Ferdy4to)';
    IdSMTP1.ConnectTimeout:= 55000;
    IdSMTP1.ReadTimeout:=30000;

    Log('SMTP connect...');
    IdSMTP1.Connect;
    except
    on E: Exception do
    Log('Error init smtp:' + E.Message);
    end;
    Log('SMTP connected.');
    try
    Log('Init mail body...');
    msg := TIdMessage.Create(nil);
    // msg.Body.Add(sBody);
    Metod.Data := msg;
    Metod.Code := @mIdMessageInitializeISO;
    // msg.OnInitializeISO := TIdInitializeISOEvent(Metod);
    msg.Subject := AnsiToUtf8(sSubject); // 'header email';
    msg.From.Address := AnsiToUtf8(sFrom); // 'a.cia@yandex.ru';
    msg.From.Name := AnsiToUtf8(sFrom); // 'Artem';
    msg.Recipients.EMailAddresses := AnsiToUtf8(sTo); // 'artemxp@gmail.com';
    //  msg.Encoding:=meMIME;

    // msg.ContentType:= 'text/html; charset=EUC-JP';
    //  msg.ContentTransferEncoding:= 'base64';
    // msg.CharSet := 'EUC-JP';        //   'EUC-JP';
    // msg.ContentTransferEncoding := '8bit';
    msg.IsEncoded := true;

    AttacheFiles(msg, sBody, slAttachments, 'Windows-1251');
    if IdSMTP1.connected = true then
    begin
    IdSMTP1.Send(msg);
    Log('Send mail OK');
    result:=true;
    end;
    msg.Free;
    except
    on E: Exception do
    begin
    msg.Free;
    IdSMTP1.Disconnect;
    Log('Error send mail:' + E.Message);
    result:=false;
    end;
    end;
    IdSMTP1.Free;
  }
end;

function GetImg(const sURL: string; var StreamFile: TMemoryStream): boolean;
// var
// lHTTP: THTTPSend;
begin

  // lHTTP := THTTPSend.Create;
  try
    HttpGetBinary(sURL, StreamFile);
    // if result then
    // lHTTP.Document.SaveToFile(FileNameToSave);
  finally
    // lHTTP.Free;
  end;
end;

function GetImg(sURL, FileNameToSave: string): boolean; overload;
var
  lHTTP: THTTPSend;
begin

  lHTTP := THTTPSend.Create;

  try
    Result := lHTTP.HTTPMethod('GET', sURL);
    if Result then
      lHTTP.Document.SaveToFile(FileNameToSave);
  finally
    lHTTP.Free;
  end;
end;

function GetHTTP(idHTTPvar: TIdHTTP; sURL: string): string;
var
  iNumTimeout: Integer; // кол-во повторов
  iRT: Integer;
  str: tstrings;
const
  iRetry = 3; // кол-во попыток чтения
begin
  str := TStringList.Create;
  Result := PostHTTP('GET', idHTTPvar, sURL, str);
  str.Free;

  { iNumTimeout := iRetry;
    Result := '';
    iRT := idHTTPvar.ReadTimeout;
    while (iNumTimeout > 0) and (Result = '') do
    begin
    try
    Log('Загрузка#' + inttostr(iRetry - iNumTimeout) + ' URL:' + sURL, 1);
    // Application.ProcessMessages;
    Result := idHTTPvar.get(sURL);
    except
    on E: Exception do
    begin
    Log('Ошибка: ' + E.Message + ' URL:' + sURL, 3);
    Result := '';
    idHTTPvar.ReadTimeout := idHTTPvar.ReadTimeout + 10000;
    end;
    end;
    dec(iNumTimeout);
    end;
    idHTTPvar.ReadTimeout := iRT;
    if Result = '' then
    Log('Ошибка: пустой ответ сервера!');
  }
end;

procedure GetHTTP(idHTTPvar: TIdHTTP; sURL: string;
  AResponseContent: TStream); overload;
var
  iNumTimeout: Integer; // кол-во повторов
  iRT: Integer;
  str: tstrings;
const
  iRetry = 3; // кол-во попыток чтения
begin
  { str := TStringList.Create;
    Str.Text := PostHTTP('GET',idHTTPvar, sURL, Str);
    Str.SaveToStream(AResponseContent); }

  iNumTimeout := iRetry;
  iRT := idHTTPvar.ReadTimeout;
  while (iNumTimeout > 0) and (AResponseContent.Size = 0) do
  begin
    try
      Log('Загрузка#' + inttostr(iRetry - iNumTimeout) + ' URL:' + sURL, 1);
      // Application.ProcessMessages;
      idHTTPvar.get(sURL, AResponseContent);
    except
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message + ' URL:' + sURL, 3);
        idHTTPvar.ReadTimeout := idHTTPvar.ReadTimeout + 10000;
      end;
    end;
    dec(iNumTimeout);
  end;
  idHTTPvar.ReadTimeout := iRT;
  if AResponseContent.Size = 0 then
    Log('Ошибка: пустой ответ сервера!');

end;

{ **** UBPFD *********** by delphibase.endimus.com ****
  >> Вставка текста (программно сгенерированной HTML-страницы) в TWebBrowser
  (не из файла, а из текстовой переменной)

  Функция позволяет отображать любой текст в TWebBrowser или TWebBrowser_V1.
  С ее помощью можно обойтись без html-файлов и отображать html-странички,
  генерируя их программно. Обрабатывая клики в таких страничках можно быстро
  и просто создавать интерфейс приложения в формате HTML.
  Для работы функции обязателен установленный в системе Internet Explorer.
  Здесь я использую веббраузер старой версии - TWebBrowser_V1, при необходимости
  можно заменить его на TWebBrowser (просто переписать тип входной переменной WB),
  Но при этом программа с этой функцией будет работать только на системах
  с IE версии 5.0 и выше, в то время как TWebBrowser_V1 обеспечивает работу
  начиная с версии 4.0.

  Зависимости: ActiveX, SHDocVw, MSHTML, Forms, установленный Internet Explorer
  Автор:       lipskiy, lipskiy@mail.ru, ICQ:51219290, Санкт-Петербург
  Copyright:   Взято из FAQ и оптимизировано lipskiy и Donal_Graeme
  Дата:        14 августа 2002 г.
  ***************************************************** }

procedure TextToWebBrowser(Text: string; var WB: tWebBrowser);
var
  Document: IHTMLDocument2;
  V: OleVariant;
begin
  // Документ необходимо создать только один раз за текущую сессию работы
  if WB.Document = nil then
    WB.Navigate('about:blank', EmptyParam, EmptyParam, EmptyParam, EmptyParam);
  // Ожидаем создания документа и позволяем обрабатывать все сообщения
  while WB.Document = nil do
    Application.ProcessMessages;
  Document := WB.Document as IHTMLDocument2;
  // Вставляем текст (до 2Гб)
  { следующие строчки внесены недавно - старый вариант функции не работал под XP }
  V := VarArrayCreate([0, 0], varVariant);
  V[0] := Text;
  Document.Write(PSafeArray(TVarData(V).VArray));
  Document.Close;
end;

function PostHTTP(sMethod: string; idHTTPvar: TIdHTTP; sURL: string;
  PostData: tstrings): string;
var
  iNumTimeout: Integer; // кол-во повторов
  iRT: Integer;
  sgHTTP: THTTPSend;
  Data: TStream;
  st: TMemoryStream;
  str: tstrings;
  URLData: String;
begin
  iNumTimeout := 3;
  Result := '';
  iRT := idHTTPvar.ReadTimeout;
  while (iNumTimeout > 0) and (Result = '') do
  begin
    try
      st := TMemoryStream.Create;
      str := TStringList.Create;
      sgHTTP := THTTPSend.Create;
      PostData.Delimiter := '&';
      URLData := PostData.DelimitedText;
      try
        sgHTTP.Document.Write(Pointer(URLData)^, Length(URLData));
        sgHTTP.TargetHost := idHTTPvar.Request.Host;
        sgHTTP.UserAgent := idHTTPvar.Request.UserAgent;
        sgHTTP.MimeType := 'application/x-www-form-urlencoded';
        // sgHTTP.MimeType :=idHTTPvar.Request.Accept;// 'application/x-www-form-urlencoded';
        sgHTTP.Headers.Add('Referer: ' + idHTTPvar.Request.Referer);
        sgHTTP.Cookies.Text := Cookies;
        sgHTTP.HTTPMethod(sMethod, sURL); // 'POST'
        Cookies := sgHTTP.Cookies.Text;
        // idHTTPvar.CookieManager.CookieCollection.Cookies[0].CookieText;
        // if idHTTPvar.CookieManager.CookieCollection.Count>1 then
        // sgHTTP.Cookies.Text:=sgHTTP.Cookies.Text+','+idHTTPvar.CookieManager.CookieCollection.Cookies[1].CookieText;
        st.CopyFrom(sgHTTP.Document, 0);
        st.Seek(0, soFromBeginning);
        str.LoadFromStream(st);
        Result := str.Text;
      finally
        sgHTTP.Free;
        str.Free;
        st.Free;
      end;
      // Result := idHTTPvar.Post(sURL, PostData);   { TODO : Invalid code page }
    except
      // on E: EIDHttpProtocolException do
      // FormMain.Log('Ошибка: ' + E.Message, 3);
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message + ' URL:' + sURL + ' Post:' +
          PostData.Text, 3);
        Result := '';
        idHTTPvar.ReadTimeout := idHTTPvar.ReadTimeout + 10000;
      end;
    end;
    dec(iNumTimeout);
  end;
  idHTTPvar.ReadTimeout := iRT;
  if Result = '' then
    Log('Ошибка: пустой ответ сервера!');
end;

function ValidData: boolean;
var
  ErrString: string;
begin
  Result := true;
  { ErrString := '';
    if StringGrid1.RowCount<1 then
    ErrString := 'Новых данных нет. Нечего отсылать.';
    if Length(trim(StringGrid1.Rows[0].Text)) < 10 then
    ErrString := 'Новых данных нет. Нечего отсылать.';
    if trim(FormSettings.EdSMTPHost.Text)
    = '' then { TODO : переделать передачу параметров не из формы! }
  { ErrString := ErrString + #13 + #187 + 'DNS server not filled in';
    if trim(FormSettings.EdRecipients.Text) = '' then
    ErrString := ErrString + #13 + #187 + 'Recipients email not filled in';
    if trim(FormSettings.EdSender.Text) = '' then
    ErrString := ErrString + #13 + #187 + 'Sender email not filled in';
    if trim(FormSettings.edSMTPport.Text) = '' then
    ErrString := ErrString + #13 + #187 + 'SMTPport not filled in';
    if ErrString <> '' then
    begin
    FormMain.Log('Cannot proceed due to the following errors:' + EOL +
    ErrString);
    Result := false;
    end; }
end;
{
  procedure SendData(sListData: tstrings);
  function GetStrGrd(): UnicodeString;
  var
  r, c: Integer;
  s: string;

  begin
  { Result := '<html><head>'
  +'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />'
  +'<title>Japancar.ru - Поиск автозапчастей по параметрам</title></head>'
  +'<body><table width="100%" border="1"><tr>'
  +'<th scope="col">№</th>'
  +'<th scope="col">Адрес обьявления</th>'
  +'<th scope="col">Марка</th>'
  +'<th scope="col">ДВС</th>'
  +'<th scope="col">Номер кузова, двигателя</th>'
  +'<th scope="col">N</th>'
  +'<th scope="col">&nbsp;</th>'
  +'<th scope="col">Цена</th>'
  +'<th scope="col">Адрес продавца</th>'
  +'<th scope="col">Дата</th>'
  +'</tr>'; }
{ for r := 0 to -1 do
  begin
  s := sListData.Strings[c];
  Result := Result + s;
  for c := 2 to sListData.Count - 1 do
  begin

  if s = '' then
  s := '<br>';
  if c = 1 then
  s := '<a href="' + s + '">' + s + '</a>';
  Result := Result + '<td>' + s + '</td>';
  end;
  // result := result + '</tr>';
  end;
  { Result := '> ';
  for r := 0 to StringGrid1.RowCount - 1 do
  begin
  Result := Result+' ' + StringGrid1.Rows[r].DelimitedText;
  if r < (StringGrid1.RowCount - 1) then
  Result := Result + EOL + '> ';
  end; }
// result := result + '</table></body></html>';
{ end;

  var
  IdMessage: TIdMessage;
  EdSender, EdRecipients: string;
  begin
  Log('SendMail.Check...');

  IdMessage := TIdMessage.Create();
  EdSender := 'artemxp@gmail.com';
  EdRecipients := 'artemxp@gmail.com';
  with IdMessage do
  begin
  Log('Assigning mail message properties');
  From.Text := 'Delphi Indy Client <' + EdSender + '>';
  Sender.Text := EdSender;
  Recipients.EMailAddresses := EdRecipients;
  Subject := 'Japancar.ru - Поиск автозапчастей по параметрам';
  ContentType := 'text/html';
  CharSet := 'Windows-1251';
  ContentTransferEncoding := '8bit';
  IsEncoded := true;
  Body.Text := GetStrGrd();
  end;
  Log('SendMail.');
  SendMail(IdMessage);

  // end;
  end; }

end.
