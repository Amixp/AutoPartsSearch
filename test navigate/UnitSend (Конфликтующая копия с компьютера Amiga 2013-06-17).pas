unit UnitSend;

interface

uses SysUtils, System.IOUtils,
  IdUserPassProvider, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP, IdSASLPlain, IdSASL, IdSASLUserPass,
  IdSASLLogin, IdMessage, IdLogBase, IdAntiFreeze, IdAttachment,
  IdAttachmentFile, IdText, IdLogDebug, IdCoder, IdCoderQuotedPrintable,
  IdIntercept, IdHTTP, StrUtils,
  Classes;

type
  dt = string; // пустое определение для обьчвления функций ниже!
  // странное решение, но работает! :)

procedure Log(Txt: string; debuglevel: Integer = 0; ToConsole: boolean = true);
procedure SendMail(idMsg: TIdMessage);
procedure SendMail1(idMsg: TIdMessage);
function SendMail2(sFrom, sTo, sHost, sPort, sSubject, sLogin, sPass, sBody: string; slAttachments: tstrings): boolean;
// function sSendMail(aHost: String): Boolean;
procedure TestMail;

// procedure SendAtach;
// procedure SendHTMLMail;
procedure AttacheFiles(var mIdMessage: TIdMessage; BodyHTML: string; sAttacheFilesPath: tstrings);
function GetHTTP(idHTTPvar: TIdHTTP; sURL: string): string; overload;
procedure GetHTTP(idHTTPvar: TIdHTTP; sURL: string; AResponseContent: TStream); overload;
function PostHTTP(idHTTPvar: TIdHTTP; sURL: string; PostData: tstrings): string;

procedure SendData(sListData: tstrings);
function ValidData: boolean;

implementation

uses MainUnit;

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
          try Disconnect;
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
    Body.Text := 'Поиск автозапчастей по параметрам ' + #$D + #$A + 'TEST MESSAGE!'
  end;
  Log('SendMail test.');
  SendMail(IdMessage);
  // ShowMessage('Тестовое письмо отправлено.');
  IdMessage.Free;
end;

procedure AttacheFiles(var mIdMessage: TIdMessage; BodyHTML: string; sAttacheFilesPath: tstrings);
var
  i: Integer;
begin
  i := 0;
  while i < sAttacheFilesPath.Count do
  begin
    if FileExists(sAttacheFilesPath.Strings[i]) then
    begin
      // замена всех путей в тексте на cid:filename
      BodyHTML := StringReplace(BodyHTML, sAttacheFilesPath.Strings[i],
        'cid:' + TPath.GetFileNameWithoutExtension(sAttacheFilesPath.Strings[i]), []);
      inc(i);
    end
    else sAttacheFilesPath.Delete(i);
    // удалить несуществующий путь к файлу картинки
  end;

  with TIdText.Create(mIdMessage.MessageParts, nil) do
  begin // вставка HTML текста, перед аттачами
    Body.Text := BodyHTML;
    ContentType := 'text/html';
  end;

  for i := 0 to sAttacheFilesPath.Count - 1 do
    with TIdAttachmentFile.Create(mIdMessage.MessageParts, sAttacheFilesPath.Strings[i]) do
    begin // присоединение файлов в аттачи
      ContentDisposition := 'inline';
      ContentID := TPath.GetFileNameWithoutExtension(sAttacheFilesPath.Strings[i]);
      ContentType := 'image/' + StringReplace(ExtractFileExt(sAttacheFilesPath.Strings[i]), '.', '', []);
      FileName := ExtractFileName(sAttacheFilesPath.Strings[i]);
      { DONE : Работает!! ))) }
    end;

  mIdMessage.ContentType := 'multipart/related; type="text/html"';
  mIdMessage.IsEncoded := true;
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
            try Disconnect;
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

function SendMail2(sFrom, sTo, sHost, sPort, sSubject, sLogin, sPass, sBody: string; slAttachments: tstrings): boolean;
var
  msg: TIdMessage;
  IdSMTP1: TIdSMTP;
  att: TIdAttachmentFile;
  i: Integer;
  sl: tstrings;

  s, b: string;
  str: tstrings;
begin
  Log('Start SMTP...');
  IdSMTP1 := TIdSMTP.Create(nil);
  try
    IdSMTP1.AuthType := satDefault;
    IdSMTP1.Host := sHost; // 'smtp.yandex.ru';
    IdSMTP1.Port := strtoint(sPort); // 25;
    IdSMTP1.Username := sLogin; // 'a.cia';
    IdSMTP1.Password := sPass; // 'Ferdy4to)';
    Log('SMTP connect...');
    IdSMTP1.Connect;
  except
    on E: Exception do Log('Error init smtp:' + E.Message);
  end;
  Log('SMTP connected.');
  try
    Log('Init mail body...');
    msg := TIdMessage.Create(nil);
    // msg.Body.Add(sBody);
    msg.Subject := sSubject; // 'header email';
    msg.From.Address := sFrom; // 'a.cia@yandex.ru';
    msg.From.Name := sFrom; // 'Artem';
    msg.Recipients.EMailAddresses := sTo; // 'artemxp@gmail.com';

    msg.CharSet := 'EUC-JP';
    // msg.ContentTransferEncoding := '8bit';
    // msg.IsEncoded := true;

    AttacheFiles(msg, sBody, slAttachments);
    // ================
    {
      for i := 0 to slAttachments.Count - 1 do
      begin // замена всех путей в тексте на cid:filename
      sBody := StringReplace(sBody, slAttachments.Strings[i],
      'cid:' + TPath.GetFileNameWithoutExtension(slAttachments.Strings[i]), []);
      // s:=s+  sAttacheFilesPath.Strings[i]+   'cid:' + TPath.GetFileNameWithoutExtension(sAttacheFilesPath.Strings[i]);
      end;


      with TIdText.Create(msg.MessageParts, nil) do
      begin // вставка HTML текста, перед аттачами
      Body.Text := sBody;
      // body.SaveToFile('d:\temp_'+RightStr((TimeToStr(now)),2)+'.html');
      ContentType := 'text/html';
      b := Body.Text;
      //  ParentPart := 0;
      end;

      {  with TIdText.Create(msg.MessageParts, nil) do
      begin // вставка HTML текста, перед аттачами
      Body.Text := b;
      // body.SaveToFile('d:\temp_'+RightStr((TimeToStr(now)),2)+'.html');
      ContentType := 'text/html';
      b := Body.Text;
      //       ParentPart := 0;
      end;

      for i := 0 to slAttachments.Count - 1 do
      with TIdAttachmentFile.Create(msg.MessageParts, slAttachments.Strings[i]) do
      begin // присоединение файлов в аттачи
      ContentDisposition := 'inline';
      ContentID := TPath.GetFileNameWithoutExtension(slAttachments.Strings[i]);
      ContentType := 'image/' + StringReplace(ExtractFileExt(slAttachments.Strings[i]), '.', '', []);
      FileName := ExtractFileName(slAttachments.Strings[i]);
      { DONE : Работает!! )))
      end;

      msg.ContentType := 'multipart/related; type="text/html"';
      msg.IsEncoded := true; }
    // ==================

    // msg.SaveToFile('d:\temp_'+RightStr((TimeToStr(now)),2)+'.html');
    // sl:=tstringlist.create;
    // sl.Text:= sBody;
    // .. sl.SaveToFile('d:\temp2_'+RightStr((TimeToStr(now)),2)+'.html');
    // sl.Free;
    {
      if slAttachments.Count > 0 then
      for i := 0 to slAttachments.Count - 1 do
      begin
      Log('Load attachment..' + inttostr(i + 1));
      if i = 0 then
      att := TIdAttachmentFile.Create(msg.MessageParts,
      slAttachments.Strings[i])
      else
      att.LoadFromFile(slAttachments.Strings[i]);
      end;
      msg.IsEncoded := true; }
    if IdSMTP1.connected = true then
    begin
      IdSMTP1.Send(msg);
      Log('Send mail OK');
    end;
    msg.Free;
  except
    on E: Exception do
    begin
      msg.Free;
      IdSMTP1.Disconnect;
      Log('Error send mail:' + E.Message);
    end;
  end;
  IdSMTP1.Free;
end;

{ procedure Button1Click(Sender: TObject);
  var
  http : TIdHttp;
  url : string;
  code : integer;
  begin
  url := 'http://www.WEBSITE.com';
  http := TIdHTTP.Create(nil);
  try
  try
  http.Head(url);
  code := http.ResponseCode;
  except
  on E: EIdHTTPProtocolException do
  code := http.ResponseCode; // or: code := E.ErrorCode;
  end;
  ShowMessage(IntToStr(code));
  finally
  http.Free();
  end;
  end;

  procedure Button2Click(Sender: TObject);
  var
  http : TIdHttp;
  url : string;
  code : integer;
  begin
  url := 'http://www.WEBSITE.com';
  http := TIdHTTP.Create(nil);
  try
  try
  http.Get(url, nil);
  code := http.ResponseCode;
  except
  on E: EIdHTTPProtocolException do
  code := http.ResponseCode; // or: code := E.ErrorCode;
  end;
  ShowMessage(IntToStr(code));
  finally
  http.Free();
  end;
  end; }

//
// procedure SendHTMLMail;
// var
// msg: TIdMessage;
// att: TIdAttachmentFile;
// F: TextFile;
// IdSMTP1: TIdSMTP;
// IdUserPassProvider1: TIdUserPassProvider;
// IdSASL1: TIdSASLLogin;
// IdAntiFreeze1: TidAntiFreeze;
// IdSASLPlain1: TIdSASLPlain;
//
// begin
// IdSMTP1 := TIdSMTP.Create(nil);
// try
// Log('Init SMTP');
// IdUserPassProvider1 := TIdUserPassProvider.Create(nil);
// IdSASL1 := TIdSASLLogin.Create(nil);
// IdAntiFreeze1 := TidAntiFreeze.Create(nil);
// IdSASLPlain1 := TIdSASLPlain.Create(nil);
// IdSASL1.UserPassProvider := IdUserPassProvider1;
// IdSASLPlain1.UserPassProvider := IdUserPassProvider1;
// IdSMTP1.SASLMechanisms.Add.SASL := IdSASLPlain1;
//
// IdSMTP1.AuthType := satSASL;
// IdSMTP1.Host := 'smtp.yandex.ru';
// IdSMTP1.Port := 25;
// IdSMTP1.Username := 'a.cia';
// IdSMTP1.Password := 'Ferdy4to)';
// Log('Connect to ' + IdSMTP1.Host);
// IdUserPassProvider1.Username := IdSMTP1.Username;
// IdUserPassProvider1.Password := IdSMTP1.Password;
//
// IdSMTP1.Connect;
// except
// on E: Exception do
// begin
// Log('Error connection!' + #10#13 + E.Message);
// Exit;
// end;
// end;
//
// try
// Log('Init Message');
// msg := TIdMessage.Create(nil);
// msg.Body.Add('email text');
// msg.Subject := 'header email';
// msg.From.Address := 'a.cia@yandex.ru'; // от кого отправляем
// msg.From.Name := 'Artem';
// msg.Recipients.EMailAddresses := 'artemxp@yandex.ru;artemxp@gmail.com';
// // кому отправляем
// Log('Load atachment...');
// att := TIdAttachmentFile.Create(msg.MessageParts, 'd:\testhtml.htm');
// msg.IsEncoded := true;
// if IdSMTP1.connected = true then
// begin
// Log('Send message...');
// IdSMTP1.Send(msg);
// Log('Send OK.');
// end;
// att.Free;
// msg.Free;
//
// except
// on E: Exception do
// begin
// Log('Error connection!' + #10#13 + E.Message);
// msg.Free;
// att.Free;
// IdSMTP1.Disconnect;
// end;
// end;
// IdSMTP1.Free;
// IdAntiFreeze1.Free;
// IdUserPassProvider1.Free;
// IdSASL1.Free;
// IdSASLPlain1.Free;
// Log('Send done.');
// end;

function GetHTTP(idHTTPvar: TIdHTTP; sURL: string): string;
var
  iNumTimeout: Integer; // кол-во повторов
  iRT: Integer;
const
  iRetry = 3; // кол-во попыток чтения
begin
  iNumTimeout := iRetry;
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
  if Result = '' then Log('Ошибка: пустой ответ сервера!');

end;

procedure GetHTTP(idHTTPvar: TIdHTTP; sURL: string; AResponseContent: TStream); overload;
var
  iNumTimeout: Integer; // кол-во повторов
  iRT: Integer;
const
  iRetry = 3; // кол-во попыток чтения
begin
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
  if AResponseContent.Size = 0 then Log('Ошибка: пустой ответ сервера!');

end;

function PostHTTP(idHTTPvar: TIdHTTP; sURL: string; PostData: tstrings): string;
var
  iNumTimeout: Integer; // кол-во повторов
  iRT: Integer;
begin
  iNumTimeout := 3;
  Result := '';
  iRT := idHTTPvar.ReadTimeout;
  while (iNumTimeout > 0) and (Result = '') do
  begin
    try Result := idHTTPvar.Post(sURL, PostData);
    except
      // on E: EIDHttpProtocolException do
      // FormMain.Log('Ошибка: ' + E.Message, 3);
      on E: Exception do
      begin
        Log('Ошибка: ' + E.Message + ' URL:' + sURL + ' Post:' + PostData.Text, 3);
        Result := '';
        idHTTPvar.ReadTimeout := idHTTPvar.ReadTimeout + 10000;
      end;
    end;
    dec(iNumTimeout);
  end;
  idHTTPvar.ReadTimeout := iRT;
  if Result = '' then Log('Ошибка: пустой ответ сервера!');
end;


function ValidData: boolean;
var
  ErrString: string;
begin
  result := true;
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

procedure SendData(sListData: tstrings);
  function GetStrGrd(): UnicodeString;
  var
    r, c: integer;
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
    for r := 0 to -1 do
    begin
      s := sListData.Strings[c];
      result := result + s;
      for c := 2 to sListData.Count - 1 do
      begin

        if s = '' then s := '<br>';
        if c = 1 then s := '<a href="' + s + '">' + s + '</a>';
        result := result + '<td>' + s + '</td>';
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
  end;

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
end;
end.
