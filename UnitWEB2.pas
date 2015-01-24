unit UnitWEB2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.OleCtrls, SHDocVw,
  mshtml, idglobal,
  StrUtils, Vcl.Menus, Vcl.ComCtrls {, IdCookieManager, IdBaseComponent,
    Winapi.ActiveX, IniFiles,
    IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.StdCtrls, Vcl.OleCtrls,
    idAntiFreeze,
    SHDocVw,Vcl.Grids, Vcl.ExtCtrls, Vcl.Menus, JvAppStorage,
    JvAppIniStorage, JvComponentBase, JvFormPlacement, JvDebugHandler, IdUserPassProvider, IdExplicitTLSClientServerBase,
    IdMessageClient, IdSMTPBase, IdSMTP, IdSASLPlain, IdSASL, IdSASLUserPass, IdSASLLogin, IdMessage, IdLogBase,
    IdLogDebug, IdCoder, IdCoderQuotedPrintable, IdIntercept};

function FindListViewItem(lv: TListView; const S: string; column: Integer)
  : TListItem;
procedure PostWithWebBrowser(sPost: string; URL, Headers: OleVariant;
  WebBrwser: TWebBrowser);

type
  TFormWEB2 = class(TForm)
    WebBrowser1: TWebBrowser;
    PnURL: TPanel;
    BtDelURL: TButton;
    Panel1: TPanel;
    Label2: TLabel;
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    Insert1: TMenuItem;
    Edit5: TMenuItem;
    Delete1: TMenuItem;
    Button1: TButton;
    Button2: TButton;
    procedure WebBrowser1DownloadBegin(Sender: TObject);
    procedure WebBrowser1DownloadComplete(Sender: TObject);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure Delete1Click(Sender: TObject);
    procedure BtDelURLClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddPost(sPost: string);
    procedure WebBrowserLogin;
    { Public declarations }
  end;

var
  FormWEB2: TFormWEB2;
  fDownload: Boolean;

implementation

{$R *.dfm}

uses MainUnit;

procedure PostWithWebBrowser(sPost: string; URL, Headers: OleVariant;
  WebBrwser: TWebBrowser);
var
  // Data: Pointer;
  i: Integer;
  Post: OleVariant;
  // Flags, TargetFrame: OleVariant;
begin
  Post := VarArrayCreate([0, length(sPost) - 1], varByte);
  // Put Post in array
  for i := 1 to length(sPost) do
    Post[i - 1] := Ord(sPost[i]);
  WebBrwser.Navigate(URL, EmptyParam, EmptyParam, Post, Headers);
end;

function FindListViewItem(lv: TListView; const S: string; column: Integer)
  : TListItem;
var
  i: Integer;
  found: Boolean;
begin
  Assert(Assigned(lv));
  Assert((lv.viewstyle = vsReport) or (column = 0));
  Assert(S <> '');
  for i := 0 to lv.Items.Count - 1 do
  begin
    Result := lv.Items[i];
    if column = 0 then
      found := AnsiCompareText(Result.Caption, S) = 0
    else if column > 0 then
      found := AnsiCompareText(Result.SubItems[column - 1], S) = 0
    else
      found := false;
    if found then
      exit;
  end;
  // No hit if we get here
  Result := nil;
end;

procedure TFormWEB2.BtDelURLClick(Sender: TObject);
begin
  ListView1.Items.Delete(ListView1.ItemIndex);

end;

procedure TFormWEB2.Button1Click(Sender: TObject);
begin
  Close; { TODO 1: Добавить флаг закрытия формы с сохранением запросов }
end;

procedure TFormWEB2.Button2Click(Sender: TObject);
begin
  Close;
  { TODO 1 : Добавить флаг закрытия формы без сохранениея запросов }
end;

procedure TFormWEB2.Delete1Click(Sender: TObject);
begin
  ListView1.ItemFocused.Delete;
end;

procedure TFormWEB2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  l, i: Integer;
  part1, part2: string;
begin
  if ListView1.Items.Count > 0 then
  begin
    for l := 0 to ListView1.Items.Count - 1 do // цикл запросов по машинам
    begin
      part1 := ListView1.Items.Item[l].SubItems.Strings[0];
      part2 := ListView1.Items.Item[l].SubItems.Strings[1];
      if part2 <> '' then
      begin
        Sets.LsURLs.Add(part1);
        Sets.LsURLs.Add(part2);
      end;
    end;
  end;
  CanClose := true;
end;

procedure TFormWEB2.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
  function VariantArrayToStream(varArray: OleVariant): TStream;
  var
    pLocked: Pointer;
  begin
    Result := TMemoryStream.Create;
    if VarIsEmpty(varArray) or VarIsNull(varArray) then
      exit;
    Result.Size := VarArrayHighBound(varArray, 1) -
      VarArrayLowBound(varArray, 1) + 1;
    pLocked := VarArrayLock(varArray);
    try
      Result.Write(pLocked^, Result.Size);
    finally
      VarArrayUnlock(varArray);
      Result.Position := 0;
    end;
  end;

var
  // i: Integer;
  stream1, stream2: TStream;
  // StrArr: TArrayOfString;
  // S: string;
  str1: tstrings;
  Document: IHtmlDocument2;
  // HtmlDocument: IHtmlDocument2;
  // HtmlCollection: IHtmlElementCollection;
  // HtmlElement: IHtmlElement;
  sPostData, sHeaders: string;
  // document: IHTMLDocument2;
  cookies: String;
begin
  Document := WebBrowser1.Document as IHtmlDocument2;
  if Assigned(Document) then
    cookies := trim(Document.cookie);

  str1 := TStringList.Create;
  stream1 := VariantArrayToStream(PostData);
  if not VarIsStr(Headers) then
    stream2 := VariantArrayToStream(Headers)
  else
    sHeaders := Headers;
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
  /// Log('BeforeNavigate. "' + URL + '"' + EOL + 'Post:"' +
  // VarToStr(PostData) + '"');
  // JvFormStorage1.SaveFormPlacement;
end;

procedure TFormWEB2.AddPost(sPost: string);
var
  sl: tstrings;
  sPost1, sPost2: string;
  ls: TListItem;
  i: Integer;
begin
  if sPost = '' then
    exit;

  sl := TStringList.Create;
  try
    FormMain.Log('Прилетел запрос: ' + sPost);
    sl.Text := ReplaceText(sPost, '&', EOL);
    if sl.IndexOfName('E_WORKID') > -1 then
    begin
      if (sl.Values['E_WORKID'] = 'ID1410') then
        sPost2 := sPost; // запрос запчасти
      if (sl.Values['E_WORKID'] = 'ID1210') then
        sPost1 := sPost; // запрос машины
    end;
    if (sPost2 + sPost1) <> '' then
    begin
      // поиск последней записи      { TODO : неправильно вставляется второй запрос }
      if (sPost1 <> '') then
      begin // если найден первый запрос модели - добавить новую запись
        { DONE : добавить проверку на дубликаты sPots1 }
        ls := FindListViewItem(ListView1, sPost1, 1);
        // s:='';
        FormMain.Log('Первый запрос...');
        { i := 0;
          for i := 0 to ListView1.Items.Count - 1 do
          begin
          if ListView1.Items.Item[i].SubItems.Count > 0 then
          if ListView1.Items.Item[i].SubItems.Strings[0] = sPost1 then
          begin
          Break;
          end;
          end; }
        if ls = nil then
        // if i = ListView1.Items.Count then
        // ls:=ListView1.Items.Item[i]
        // else
        begin
          ls := ListView1.Items.Add; // +1
          ls.Caption := inttostr(ListView1.Items.Count);
          ls.SubItems.Add(sPost);
        end;
      end;
      if (sPost2 <> '') then
      begin
        FormMain.Log('Второй запрос...');
        { TODO : добавить проверку на дубликаты sPost2 }
        // если найден второй запрос машины - добавить в сушествуюшую запись параметров
        if ListView1.Items.Count > 0 then
        begin
          ls := ListView1.Items.Item[ListView1.Items.Count - 1];
          if (ls <> nil) then
          begin
            if ls.SubItems.Count > 1 then
            begin
              // если модель та же - но изменилась машина, то добавить новую запись копированием параметра модели
              ls := ListView1.Items.Add;
              ls.Caption := inttostr(ListView1.Items.Count);
              ls.SubItems.Add(ListView1.Items.Item[ListView1.Items.Count - 2]
                .SubItems.Strings[0]);
            end;
            ls.SubItems.Add(sPost);
          end;
        end;
      end;
    end;
  finally
    sl.Free;
  end;
end;

procedure TFormWEB2.WebBrowser1DownloadBegin(Sender: TObject);
begin
  fDownload := true;
end;

procedure TFormWEB2.WebBrowser1DownloadComplete(Sender: TObject);
begin
  fDownload := false;
end;

procedure TFormWEB2.WebBrowserLogin;
var
  sUrl, sPost, SHeader: string;
  // i: Integer;
  // EncodedStr: string;
  // Header: OleVariant;
  // Post: OleVariant;
begin
  FormMain.Log('Логинимся на сайт...');
  sUrl := Sets.Opt2.SiteLoginURL;
  sPost := 'AD1210=' + Sets.Opt2.Login1 + '&AD1510=' + Sets.Opt2.Login2 +
    '&AD1520=' + Sets.Opt2.Login3 +
    '&E_SID=PARTS_SB&E_WORKID=ID0110&AD9820=101010';
  SHeader := 'Referer: ' + Sets.Opt2.SiteURL + EOL +
    'Content-Type: application/x-www-form-urlencoded' + EOL +
    'Cookie: E_SID=PARTS_SB; AGREE01=1; SESSIONID=' +
    '20120303010416402_default#128906' + EOL;

  PostWithWebBrowser(sPost, Sets.Opt2.SiteLoginURL, SHeader, WebBrowser1);
  // Login
  while fDownload do
    Application.ProcessMessages;
  sleep(2000);
  SHeader := 'Referer: ' + Sets.Opt2.SiteURL + EOL +
    'Content-Type: application/x-www-form-urlencoded' + EOL +
    'Cookie: E_SID=PARTS_SB; AGREE01=1; SESSIONID=' +
    '20120303010416402_default#128906' + EOL;
  sPost := 'E_WORKID=ID1100';
  // PostWithWebBrowser(sPost,edit1.Text,sHeader);  // Select group
  sPost := 'AD3000M=-1&AD3000=1000&AD3500M=-1&AD3010M=0&AD3010=1010&AD3530M=-1&AD1030I=2'
    + '&AD5400M=-1&AD4020M=0&AD4100M=0&E_WORKID=ID1410&ORDER01=AD4610B&ORDER01D=1&'
    + 'ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020B&ORDER03D=1&CHARGE=0';
  while fDownload do
    Application.ProcessMessages;
  sleep(1000);
  // PostWithWebBrowser(sPost,edit1.Text,sHeader);  // Select category

end;

end.
