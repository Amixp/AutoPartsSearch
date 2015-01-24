unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, mshtml,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdCookieManager, IdBaseComponent,
  Winapi.ActiveX, IniFiles,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.StdCtrls, Vcl.OleCtrls,
  StrUtils, idglobal, idAntiFreeze,
  SHDocVw, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Menus, JvAppStorage,
  JvAppIniStorage, JvComponentBase, JvFormPlacement, JvDebugHandler, IdUserPassProvider, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP, IdSASLPlain, IdSASL, IdSASLUserPass, IdSASLLogin, IdMessage, IdLogBase,
  IdLogDebug, IdCoder, IdCoderQuotedPrintable, IdIntercept;

function FindListViewItem(lv: TListView; const S: string; column: Integer): TListItem;

type
  TMainTest = class(TForm)
    Button1: TButton;
    IdHTTP1: TIdHTTP;
    IdCookieManager1: TIdCookieManager;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    TabSheet3: TTabSheet;
    ListBox1: TListBox;
    StringGrid1: TStringGrid;
    LogList: TListBox;
    Splitter1: TSplitter;
    ListPArts: TListBox;
    TabSheet4: TTabSheet;
    WebBrowser1: TWebBrowser;
    Panel1: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Button2: TButton;
    JvFormStorage1: TJvFormStorage;
    JvAppIniFileStorage1: TJvAppIniFileStorage;
    PopupMenu1: TPopupMenu;
    Insert1: TMenuItem;
    Edit5: TMenuItem;
    Delete1: TMenuItem;
    ListView1: TListView;
    ListView2: TListView;
    IdConnectionIntercept1: TIdConnectionIntercept;
    IdEncoderQuotedPrintable1: TIdEncoderQuotedPrintable;
    IdLogDebug1: TIdLogDebug;
    IdMessage1: TIdMessage;
    IdSASLLogin1: TIdSASLLogin;
    IdSASLPlain1: TIdSASLPlain;
    IdSMTP1: TIdSMTP;
    IdUserPassProvider1: TIdUserPassProvider;
    JvDebugHandler1: TJvDebugHandler;
    Button3: TButton;
    IdTCPClient1: TIdTCPClient;
    procedure Button1Click(Sender: TObject);
    procedure ListPArtsClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
    procedure WebBrowser1DownloadBegin(Sender: TObject);
    procedure WebBrowser1DownloadComplete(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure DeleteImgs(listFiles: Tstrings);

    { Private declarations }
  public
    oLog: string;
    procedure WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);

    // procedure GetImagesFromHTML(http: TIdHTTP; var sHTML: string; var Imgs: tstrings; urlStr, PartNum: string);
    // function ParserScript(var sData: tstrings; sScript: string; http: TIdHTTP): boolean;
    procedure PostWithWebBrowser(sPost: string; URL, Headers: OleVariant);
    procedure AddPost(sPost: string);

    procedure Log(Txt: string; debuglevel: Integer = 0; ToConsole: boolean = true);
    { Public declarations }
  end;

var
  MainTest: TMainTest;
  fDownload: boolean;

implementation

{$R *.dfm}

uses parse, getstrparam, Unitmail;

procedure TMainTest.WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);
{ * Как загрузить строковые данные в WebBrowser не прибегая к открытию файла
  var
  v: Variant;
  HTMLDocument: IHTMLDocument2;
  begin
  HTMLDocument := WebBrowser1.Document as IHTMLDocument2;
  v := VarArrayCreate([0, 0], varVariant);
  v[0] := HTMLString; // Это Ваша HTML строка
  HTMLDocument.Write(PSafeArray(TVarData(v).VArray));
  HTMLDocument.Close; ...
}
var
  sl: TStringList;
  ms: TMemoryStream;
begin
  WebBrowser.Navigate('about:blank');
  while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do Application.ProcessMessages;

  if Assigned(WebBrowser.Document) then
  begin
    sl := TStringList.Create;
    try
      ms := TMemoryStream.Create;
      try
        sl.Text := HTMLCode;
        sl.SaveToStream(ms);
        ms.Seek(0, 0);
        (WebBrowser.Document as IPersistStreamInit).Load(TStreamAdapter.Create(ms));
      finally ms.Free;
      end;
    finally sl.Free;
    end;
  end;
end;

procedure TMainTest.WebBrowser1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
  function VariantArrayToStream(varArray: OleVariant): TStream;
  var
    pLocked: Pointer;
  begin
    Result := TMemoryStream.Create;
    if VarIsEmpty(varArray) or VarIsNull(varArray) then exit;
    Result.Size := VarArrayHighBound(varArray, 1) - VarArrayLowBound(varArray, 1) + 1;
    pLocked := VarArrayLock(varArray);
    try Result.Write(pLocked^, Result.Size);
    finally
      VarArrayUnlock(varArray);
      Result.Position := 0;
    end;
  end;

var
  i: Integer;
  stream1, stream2: TStream;
  // StrArr: TArrayOfString;
  S: string;
  str1: Tstrings;
  Document: IHtmlDocument2;
  HtmlDocument: IHtmlDocument2;
  HtmlCollection: IHtmlElementCollection;
  HtmlElement: IHtmlElement;
  sPostData, sHeaders: string;

  // document: IHTMLDocument2;
  cookies: String;
begin
  Document := WebBrowser1.Document as IHtmlDocument2;
  if Assigned(Document) then cookies := trim(Document.cookie);

  str1 := TStringList.Create;
  stream1 := VariantArrayToStream(PostData);
  if not VarIsStr(Headers) then stream2 := VariantArrayToStream(Headers)
  else sHeaders := Headers;
  try
    str1.LoadFromStream(stream1);
    sPostData := trim(str1.Text); // POST DATA strings
    if (sHeaders = '') and (stream2 <> nil) then
    begin
      str1.LoadFromStream(stream2);
      sHeaders := trim(str1.Text); // POST header strings
    end;
    AddPost(sPostData);
  finally
    stream1.Free;
    stream2.Free;
  end;
  str1.Free;
  Log('BeforeNavigate. "' + URL + '"' + EOL + 'Post:"' + VarToStr(PostData) + '"');
  JvFormStorage1.SaveFormPlacement;
end;

procedure TMainTest.WebBrowser1DownloadBegin(Sender: TObject);
begin
  fDownload := true;
end;

procedure TMainTest.WebBrowser1DownloadComplete(Sender: TObject);
begin
  fDownload := false;
end;

procedure TMainTest.AddPost(sPost: string);
var
  sl: Tstrings;
  S, sPost1, sPost2: string;
  ls: TListItem;
  i: Integer;
begin
  if sPost = '' then exit;

  sl := TStringList.Create;
  try
    sl.Text := ReplaceText(sPost, '&', EOL);
    if sl.IndexOfName('E_WORKID') > -1 then
      if (sl.Values['E_WORKID'] = 'ID1410') then sPost2 := sPost; // запрос запчасти
    if (sl.Values['E_WORKID'] = 'ID1210') then sPost1 := sPost; // запрос машины
    if (sPost2 + sPost1) <> '' then
    begin
      ls := FindListViewItem(ListView1, inttostr(ListView1.Items.Count), 0);
      // поиск последней записи      { TODO : неправильно вставляется второй запрос }
      if (sPost1 <> '') then
      begin // если найден первый запрос модели - добавить новую запись
        { DONE : добавить проверку на дубликаты sPots1 }
        // s:='';
        for i := 0 to ListView1.Items.Count - 1 do
        begin
          if ListView1.Items.Item[i].SubItems.Count > 0 then
            if ListView1.Items.Item[i].SubItems.Strings[0] = sPost1 then
            begin
              Break;
            end;
        end;
        if i = ListView1.Items.Count then
        // ls:=ListView1.Items.Item[i]
        // else
        begin
          ls := ListView1.Items.Add; // +1
          ls.Caption := inttostr(ListView1.Items.Count);
          ls.SubItems.Add(sPost);
        end;
      end;
      if (sPost2 <> '') and (ls <> nil) then
        { TODO : добавить проверку на дубликаты sPost2 }
        // если найден второй запрос машины - добавить в сушествуюшую запись параметров
        if ls.SubItems.Count < 2 then ls.SubItems.Add(sPost)
        else
        begin // если модель та же - но изменилась машина, то добавить новую запись копированием параметра модели
          ls := ListView1.Items.Add;
          ls.Caption := inttostr(ListView1.Items.Count);
          ls.SubItems.Add(ListView1.Items.Item[ListView1.Items.Count - 2].SubItems.Strings[0]);
          ls.SubItems.Add(sPost);
        end;
    end;
  finally sl.Free;
  end;
end;

function FindListViewItem(lv: TListView; const S: string; column: Integer): TListItem;
var
  i: Integer;
  found: boolean;
begin
  Assert(Assigned(lv));
  Assert((lv.viewstyle = vsReport) or (column = 0));
  Assert(S <> '');
  for i := 0 to lv.Items.Count - 1 do
  begin
    Result := lv.Items[i];
    if column = 0 then found := AnsiCompareText(Result.Caption, S) = 0
    else if column > 0 then found := AnsiCompareText(Result.SubItems[column - 1], S) = 0
    else found := false;
    if found then exit;
  end;
  // No hit if we get here
  Result := nil;
end;

procedure TMainTest.Button1Click(Sender: TObject);
var
  http: TIdHTTP;
  CM: TIdCookieManager;
  Data, Imgs, Parts: Tstrings;
  StrPage, sPost, JsScript, urlStr, sAD3000, sPart, sdt: String;
  i, r, n, p, l: Integer;
  IdAntiFreeze1: TidAntiFreeze;
  IdConnectionIntercept1: TIdConnectionIntercept;
  pHTML: TParseHTML;
begin

  StringGrid1.Cols[0].Clear;
  StringGrid1.Rows[0].Clear;
  StringGrid1.ColCount := 0;
  StringGrid1.RowCount := 1;
  Log('Загрузка параметров');
  try
    IdAntiFreeze1 := TidAntiFreeze.Create(self);
    http := TIdHTTP.Create(self);
    http.Intercept := TIdConnectionIntercept.Create(self);
    http.ConnectTimeout := 30000;
    http.ReadTimeout := 60000;
    http.HTTPOptions := [hoKeepOrigProtocol, hoForceEncodeParams];

    Data := TStringList.Create;
    CM := TIdCookieManager.Create(http);
    http.AllowCookies := true;
    http.CookieManager := CM;
    http.HandleRedirects := true;

    http.Request.Host := 'http://www.bl-recycle.jp';
    http.Request.UserAgent :=
      'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.10) Gecko/2009042316 Firefox/3.0.10';
    http.Request.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
    http.Request.AcceptLanguage := 'ru,en-us;q=0.7,en;q=0.3';
    http.Request.AcceptCharSet := 'windows-1251,utf-8;q=0.7,*;q=0.7';
    http.Request.Referer := 'http://www.bl-recycle.jp/psnet/sbe/AUP0000.HTML';

    http.CookieManager.CookieCollection.AddClientCookies('AGREE01=1');
    // принятие правил сайта
    // почему-то не работает???

    Data.Add('AD1210=8297400');
    Data.Add('AD1210=' + Edit2.Text);
    Data.Add('AD1510=' + Edit3.Text);
    Data.Add('AD1520=' + Edit4.Text);
    Data.Add('E_SID=PARTS_SB');
    Data.Add('E_WORKID=ID0110');
    Data.Add('AD9820=101010');
    // AD1210=8297400&AD1510=ps84124q&AD1520=ab340u79&E_SID=PARTS_SB&E_WORKID=ID0110&AD9820=101010
    Log('Логинимся на сервер');
    { DONE : Сделать обетрку для обработки исключений }
    StrPage := PostHTTP(http, Edit1.Text, Data);
    // тут должна быть страница с текстом правил и двумя кнопками
    Log('нажимаем на кнопку...');
    Data.Clear;
    Data.Add('E_WORKID=ID0120');
    Data.Add('turl=sbe');
    sleep(2000);
    Log('успешно прошли авторизацию.');
    Log('выбираем область...');
    { DONE : Сделать обетрку для обработки исключений }
    StrPage := PostHTTP(http, Edit1.Text, Data);
    // http://www.bl-recycle.jp/servlet/EW3SAS_WEB_PS
    // AD3000M=-1&AD3000=1000&AD3500M=-1&AD3010M=0&AD3010=1010&AD3530M=-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD4100M=0&E_WORKID=ID1410&ORDER01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020B&ORDER03D=1&CHARGE=0
    for l := 0 to ListView1.Items.Count - 1 do // цикл запросов по машинам
    begin
      Data.Clear;
      sPost := ListView1.Items.Item[l].SubItems.Strings[0];
      if sPost = '' then
      begin
        Log('Ошибка!!! Запрос машины - пустой!');
        Break;
      end;
      Data.Text := ReplaceText(sPost, '&', EOL);
      sleep(2000);
      { TODO : Сделать обетрку для обработки исключений }
      PostHTTP(http, Edit1.Text, Data);
      Log('идем по ссылке к запчастям...');
      StrPage := '';
      ListPArts.Items.Clear;
      for i := 0 to ListView1.Items.Count - 1 do // цикл запчастей в машине
      begin
        Data.Clear;
        // 'AD3000M=-1&AD3000=3000&AD3500M=-1&AD3010M=0&AD3010=3020&AD3530M=-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD5510M=0&E_WORKID=ID1410&ORDER01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020B&ORDER03D=1&CHARGE=0';
        //
        sPost := ListView1.Items.Item[i].SubItems.Strings[1];
        if sPost = '' then
        begin
          Log('Ошибка!!! Запрос детали - пустой!');
          Break;
        end;
        Log('читаем строку детали: ' + inttostr(i));
        Log(sPost);
        Data.Text := ReplaceText(sPost, '&', EOL);
        sAD3000 := Data.Values['AD3000'];
        sleep(2000);
        Log('Грузим список запчастей по параметрам...');
        { TODO : Сделать обетрку для обработки исключений }
        StrPage := PostHTTP(http, Edit1.Text, Data) + EOL + '============================' + EOL;
        Log('Парсим таблицу');
        pHTML := TParseHTML.Create;
        pHTML.ParseTableSR2(StrPage, StringGrid1);
        Log('Парсим блок скрипта');
        JsScript := GetScript(StrPage);
        Log('поиск ссылки на яву-скрипт:' + JsScript);
        if pHTML.ParserScript(Data, JsScript, http) then
        begin
          Log('заполняем параметры из скрипта');
          Parts := TStringList.Create;
          if GetPartsNum(StrPage, Parts) then // деталька найдена
          // берем номера запчастей из страницы
          begin
            Log('Найдено запчастей: ' + inttostr(Parts.Count));
            for r := 0 to Parts.Count - 1 do
            begin
              urlStr := 'http://www.bl-recycle.jp';
              Log('собираем URL запчасти по частям...');
              for n := 1 to Data.Count - 1 do
              begin
                sdt := AnsiDequotedStr(Data.Strings[n], '''');
                if AnsiContainsStr(sdt, 'target') then sdt := Parts.Strings[r];
                if AnsiContainsStr(sdt, 'document') then sdt := sAD3000;
                urlStr := urlStr + sdt;
                // Data.Strings[Data.IndexOf('target')] := Parts.Strings[r];
                // заполняем POST запрос на каждый номер запчасти
                { DONE 3 : Заменить на реальный номер! }
              end;
              try
                Log('Грузим: ' + urlStr);
                { TODO : Сделать обертку для обработки исключений }
                StrPage := GetHTTP(http, urlStr);
                http.Request.Referer := urlStr;
                http.Request.Accept := 'image/png, image/svg+xml, image/*;q=0.8, */*;q=0.5';
                Log('Грузим картинки для №' + Parts.Strings[r]);
                Imgs := TStringList.Create;
                GetImagesFromHTML(http, StrPage, Imgs, 'http://' + http.Request.Host, Parts.Strings[r]);
                // ListPArts.Items.Add(StrPage);
                // ListPArts.Items.SaveToFile(ExtractFilePath(Application.ExeName) + 'part' + Parts.Strings[r] + '.htm');
                Log('Отсылаем письмо.');
                SendMail2('a.cia@yandex.ru', 'a.cia@yandex.ru', 'smtp.yandex.ru', '25', 'New parts.', 'a.cia',
                  'Ferdy4to)', StrPage, Imgs);
                DeleteImgs(Imgs);
                { DONE : Проверить почту }
                { TODO : Добавить работу с базой запчастей для контроля новых }
              finally Log('готово: ' + inttostr(r + 1));
              end;
            end;
            Log('Закончили.');
          end;
          Parts.Free;
        end;
        pHTML.Free;
      end;
    end;
    // WB_LoadHTML(WebBrowser1,StrPage);
  finally

    Log('Прибираемся...');
    Data.Free;
    CM.Free;
    http.Free;
    IdAntiFreeze1.Free;
  end;
  Log('Готово.');
  { if Pos('<input class="logoutlj_hidden" id="user" name="user" type="hidden" value="'+Edit1.Text,StrPage) <> 0 then
    ShowMessage('Авторизация прошла успешно')
    else
    ShowMessage('Авторизация провалилась'); }

  Memo1.Lines.Text := StrPage;
end;

procedure TMainTest.DeleteImgs(listFiles: Tstrings);
var
  i: Integer;
begin
  i := 0;
  while i < listFiles.Count do
  begin
    if FileExists(listFiles.Strings[i]) then DeleteFile(listFiles.Strings[i]); // удалить  файл картинки
    inc(i);
  end;
end;

procedure TMainTest.Button2Click(Sender: TObject);
var
  sURL, sPost, SHeader: string;
  i: Integer;
  EncodedStr: string;
  Header: OleVariant;
  Post: OleVariant;
begin
  sURL := Edit1.Text;
  sPost := 'AD1210=' + Edit2.Text + '&AD1510=' + Edit3.Text + '&AD1520=' + Edit4.Text +
    '&E_SID=PARTS_SB&E_WORKID=ID0110&AD9820=101010';
  SHeader := 'Referer: http://www.bl-recycle.jp/psnet/com/AUP1100.HTML' + EOL +
    'Content-Type: application/x-www-form-urlencoded' + EOL + 'Cookie: E_SID=PARTS_SB; AGREE01=1; SESSIONID=' +
    '20120303010416402_default#128906' + EOL;
  PostWithWebBrowser(sPost, Edit1.Text, SHeader); // Login
  while fDownload do Application.ProcessMessages;
  sleep(2000);
  SHeader := 'Referer: http://www.bl-recycle.jp/psnet/com/AUP1100.HTML' + EOL +
    'Content-Type: application/x-www-form-urlencoded' + EOL + 'Cookie: E_SID=PARTS_SB; AGREE01=1; SESSIONID=' +
    '20120303010416402_default#128906' + EOL;
  sPost := 'E_WORKID=ID1100';
  // PostWithWebBrowser(sPost,edit1.Text,sHeader);  // Select group
  sPost := 'AD3000M=-1&AD3000=1000&AD3500M=-1&AD3010M=0&AD3010=1010&AD3530M=-1&AD1030I=2' +
    '&AD5400M=-1&AD4020M=0&AD4100M=0&E_WORKID=ID1410&ORDER01=AD4610B&ORDER01D=1&' +
    'ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020B&ORDER03D=1&CHARGE=0';
  while fDownload do Application.ProcessMessages;
  sleep(1000);
  // PostWithWebBrowser(sPost,edit1.Text,sHeader);  // Select category

end;

procedure TMainTest.Delete1Click(Sender: TObject);
begin
  ListView1.ItemFocused.Delete;
end;

procedure TMainTest.FormCreate(Sender: TObject);
var
  i, c: Integer;
  S: string;
  listitem: TListItem;
  ini: TIniFile;
begin
  ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  i := 0;
  while (true) do
  begin
    S := ini.ReadString('Section', 'Column' + inttostr(i), '');
    if S = '' then Break;
    listitem := ListView1.Items.Add;
    listitem.Caption := S;
    for c := 0 to ListView1.Columns.Count - 1 do
    begin
      listitem.SubItems.Add(ini.ReadString('Section', 'Column' + inttostr(i) + '.' + inttostr(c), ''));
      // listitem.SubItems.Add(Ini.ReadString('Section', 'Column'+IntToStr(i) + '.Login',''));
    end;
    i := i + 1;
  end;
  ini.Free;
end;

procedure TMainTest.FormDestroy(Sender: TObject);
var
  ini: TIniFile;
  listitem: TListItem;
  i, c: Integer;
  n: String;
begin
  ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  for i := 0 to ListView1.Items.Count - 1 do
  begin
    listitem := ListView1.Items[i];
    n := 'Column' + inttostr(i);
    ini.WriteString('Section', n, listitem.Caption);
    for c := 0 to listitem.SubItems.Count - 1 do
    begin
      n := 'Column' + inttostr(i) + '.' + inttostr(c);
      ini.WriteString('Section', n, listitem.SubItems.Strings[c]);
    end;
  end;
  ini.Free;

end;

procedure TMainTest.PostWithWebBrowser(sPost: string; URL, Headers: OleVariant);
var
  Data: Pointer;
  i: Integer;
  Post: OleVariant;
  Flags, TargetFrame: OleVariant;
begin
  Post := VarArrayCreate([0, length(sPost) - 1], varByte);
  // Put Post in array
  for i := 1 to length(sPost) do Post[i - 1] := Ord(sPost[i]);
  WebBrowser1.Navigate(URL, EmptyParam, EmptyParam, Post, Headers);
end;

procedure TMainTest.ListPArtsClick(Sender: TObject);
var
  F: TForm;
  WB: TWebBrowser;
  // L: TLabel;
begin
  F := TForm.Create(self);
  try
    WB := TWebBrowser.Create(F);
    TWinControl(WB).name := 'MyWebBrowser';
    TWinControl(WB).Parent := F;
    WB.Align := alClient;
    WB_LoadHTML(WB, ListPArts.Items.Strings[ListPArts.ItemIndex]);
    F.Showmodal;
    // showmessage('wait');
  finally F.Free;
  end;
end;

procedure TMainTest.Log(Txt: string; debuglevel: Integer = 0; ToConsole: boolean = true);
begin
  if (oLog = Txt) or (Txt = '') then exit;
  oLog := Txt;
  LogList.Items.Add(TimeToStr(now) + ': ' + Txt);
  LogList.ItemIndex := LogList.Count - 1;
  Application.ProcessMessages;
end;
{ DONE -cдобавить : Загрузка фотки запчасти }
{ DONE -cдобавить : парсер номеров деталей из таблицы }

end.
