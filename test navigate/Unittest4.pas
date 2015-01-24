unit Unittest4;

interface

uses

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  mshtml, IdGlobal, strutils,
  Dialogs, StdCtrls, ActiveX, OleCtrls, SHDocVw, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, ComCtrls, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, Data.Bind.Components, IdCookieManager;

type

  TForm4 = class(TForm)
    Button1: TButton;
    IdHTTP1: TIdHTTP;
    Edit1: TEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo2: TMemo;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    BindingsList1: TBindingsList;
    WebBrowser1: TWebBrowser;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    sLogs: TMemo;
    edURLpost: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button2: TButton;
    EdCookie: TMemo;
    Label3: TLabel;
    Button3: TButton;
    IdCookieManager1: TIdCookieManager;
    edPost1: TEdit;
    Label4: TLabel;
    edPost2: TEdit;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure WebBrowser1NavigateComplete2(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);

    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure WebBrowser1DownloadBegin(Sender: TObject);
    procedure WebBrowser1DownloadComplete(Sender: TObject);
    procedure WebBrowser1PropertyChange(ASender: TObject;
      const szProperty: WideString);
    procedure WebBrowser1StatusTextChange(ASender: TObject;
      const Text: WideString);
    procedure WebBrowser1TitleChange(ASender: TObject; const Text: WideString);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TabSheet4ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button4Click(Sender: TObject);

  private
    procedure WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);
    procedure Log(Txt: string);
    procedure Navigate(stURL, stPostData: String;
       wbWebBrowser: TWebBrowser);
    procedure AddPost(sPost: string);
    procedure PostWithWebBrowser(PostString: string; URL: OleVariant);

    { Private declarations }

  public

    { Public declarations }

  end;

var
  oLog: string;
  Form4: TForm4;

implementation

uses getstrparam;

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);

{ var
  i, j: integer;
  ovTable: OleVariant;
  SLBody: TStringList;
  s: string; }
var
  i: Integer;
  EncodedStr: string;
  Header: OleVariant;
  Post: OleVariant;
begin
  // Make the post string URL encoded
  EncodedStr :=
    'AD1210=8297400&AD1510=ps84124q&AD1520=ab340u79&E_SID=PARTS_SB&E_WORKID=ID0110&AD9820=101010';
  // The post must be an array. But without null terminator (-1)
  Post := VarArrayCreate([0, Length(EncodedStr) - 1], varByte);
  // Put Post in array
  for i := 1 to Length(EncodedStr) do
    Post[i - 1] := Ord(EncodedStr[i]);
  Header := 'Content-Type: application/x-www-form-urlencoded' + #10#13;
  WebBrowser1.Navigate('http://www.bl-recycle.jp/servlet/EW3SAS_WEB_PS',
    EmptyParam, EmptyParam, Post, Header);
end;

procedure TForm4.WB_LoadHTML(WebBrowser: TWebBrowser; HTMLCode: string);
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
  while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;

  if Assigned(WebBrowser.Document) then
  begin
    sl := TStringList.Create;
    try
      ms := TMemoryStream.Create;
      try
        sl.Text := HTMLCode;
        sl.SaveToStream(ms);
        ms.Seek(0, 0);
        (WebBrowser.Document as IPersistStreamInit)
          .Load(TStreamAdapter.Create(ms));
      finally
        ms.Free;
      end;
    finally
      sl.Free;
    end;
  end;
end;

procedure TForm4.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
  function VariantArrayToStream(VarArray: OleVariant): TStream;
  var
    pLocked: Pointer;
  begin
    Result := TMemoryStream.Create;
    if VarIsEmpty(VarArray) or VarIsNull(VarArray) then
      Exit;
    Result.Size := VarArrayHighBound(VarArray, 1) -
      VarArrayLowBound(VarArray, 1) + 1;
    pLocked := VarArrayLock(VarArray);
    try
      Result.Write(pLocked^, Result.Size);
    finally
      VarArrayUnlock(VarArray);
      Result.Position := 0;
    end;
  end;

var
  f, i: Integer;
  stream1, stream2: TStream;
  StrArr: TArrayOfString;
  s: string;
  str1: tstrings;
  Document: IHtmlDocument2;
  HtmlDocument: IHtmlDocument2;
  HtmlCollection: IHtmlElementCollection;
  HtmlElement: IHtmlElement;
  sPostData, sHeaders: string;

  //document: IHTMLDocument2;
  cookies: String;
begin
  document := WebBrowser1.Document as IHTMLDocument2;
  if Assigned(document) then
    cookies := trim(document.cookie);

  str1:=TStringList.Create;
  stream1 := VariantArrayToStream(PostData);
   if not VarIsStr(Headers) then
  stream2 := VariantArrayToStream(Headers)
  else
   sHeaders:=Headers;
  try
    str1.LoadFromStream(stream1);
    sPostData:= Trim(str1.Text);  // POST DATA strings
   if (sHeaders='') and (stream2<>nil) then
   begin
    str1.LoadFromStream(stream2);
    sHeaders:= Trim(str1.Text);  // POST header strings
    end;
    Log('POST Headers:'+sHeaders);
    Log('POST cookies:'+cookies);
    Log('POST Stream:'+sPostData);
   finally
    stream1.Free;
    stream2.Free;
  end;
  str1.Free;
   edURLpost.Text:=URL;
   AddPost(sPostData);
   if cookies<>'' then
   EdCookie.Lines.Text:=cookies;
//======================================
  HtmlDocument := WebBrowser1.Document as IHtmlDocument2;
  if HtmlDocument <> nil then
  begin
    HtmlCollection := HtmlDocument.All;
    for i := 0 to HtmlCollection.Length - 1 do
    begin
      HtmlElement := HtmlCollection.Item(i, 0) as IHtmlElement;
      Memo2.Lines.Add(HtmlElement.TagName + ' ' + HtmlElement.InnerText);
    end;
  end;
  if Length(PostData) > 0 then
  begin
    i := VarArrayDimCount(PostData);
    s := VarArrayGet(PostData, i);
    s := VarToStr(PostData);
  end;

  Log('BeforeNavigate. "' + URL + '"' + EOL + 'Post:"' +
    VarToStr(PostData) + '"');

  // if AnsiContainsText(StrArr[i],'code=parts') then
  Log('POST URL:' + URL);

end;

procedure tform4.AddPost(sPost: string);
var
sL: TStrings;
begin
sL:=TStringList.Create;
try
  sL.Text:= ReplaceText(sPost, '&', EOL);
  if sL.IndexOfName('E_WORKID')>-1 then
    if (sL.Values['E_WORKID']='ID1410') then
       edPost2.Text:=sPost;
    if (sL.Values['E_WORKID']='ID1210') then
       edPost1.Text:=sPost;
finally
  sL.Free;
end;

end;

procedure TForm4.Navigate(stURL, stPostData: String;  wbWebBrowser: TWebBrowser);
var
  vWebAddr, vPostData, vFlags, vFrame, vHeaders: OleVariant;
  iLoop: Integer;
begin
{Are we posting data to this Url?}
if Length(stPostData)> 0 then
begin
{Require this header information if there is stPostData.}
vHeaders:= 'Content-Type: application/x-www-form-urlencoded'+ #10#13#0;
{Set the variant type for the vPostData.}
vPostData:= VarArrayCreate([0, Length(stPostData)], varByte);
for iLoop := 0 to Length(stPostData)- 1 do // Iterate
begin
  vPostData[iLoop]:= Ord(stPostData[iLoop+ 1]);
end; // for
{Final terminating Character.}
vPostData[Length(stPostData)]:= 0;
{Set the type of Variant, cast}
TVarData(vPostData).vType:= varArray;
end;
{And the other stuff.}
vWebAddr:= stURL;
{Make the call Rex.}
   vFlags:= EmptyParam;
   vFrame:= EmptyParam;
wbWebBrowser.Navigate2(vWebAddr, vFlags, vFrame, vPostData, vHeaders);

end;

procedure TForm4.PostWithWebBrowser(PostString: string; URL: OleVariant);
var
  Data: Pointer;
  PostData: OleVariant;
  Flags, TargetFrame, Headers: OleVariant;
begin
  PostData := VarArrayCreate([0, Length(PostString) - 1], varByte);
  Data := VarArrayLock(PostData);
  try
    Move(PostString[1], Data^, Length(PostString));
  finally
    VarArrayUnlock(PostData);
  end;
  Flags := EmptyParam;
  TargetFrame := '';
  Headers := 'Content-Type: application/x-www-form-urlencoded' + #10#13
  +'Cookie:'+EdCookie.Lines.Text + #10#13;
  WebBrowser1.Navigate2(URL, Flags, TargetFrame, PostData, Headers);
end;

 procedure TForm4.TabSheet4ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

{End of Navigate procedure.}

procedure TForm4.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  Log('DocumentComplete.');
end;

procedure TForm4.WebBrowser1DownloadBegin(Sender: TObject);
begin
  Log('DownloadBegin.');
end;

procedure TForm4.WebBrowser1DownloadComplete(Sender: TObject);
begin
  Log('DownloadComplete.');
end;

procedure TForm4.WebBrowser1NavigateComplete2(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  i, j: Integer;
  ovTable: OleVariant;
begin
  Log('NavigateComplete. "' + URL + '"');

  ovTable := WebBrowser1.OleObject.Document.All.tags('TABLE').Item(2);
  if ovTable = 0 then
    Exit;

  for i := 0 to (ovTable.Rows.Length - 1) do
  begin
    for j := 0 to (ovTable.Rows.Item(i).Cells.Length - 1) do
    begin
      sLogs.Lines.Add(ovTable.Rows.Item(i).Cells.Item(j).InnerText);
    end;
  end;

end;

procedure TForm4.WebBrowser1PropertyChange(ASender: TObject;
  const szProperty: WideString);
begin
  Log('PropertyChange. "' + szProperty + '"');
end;

procedure TForm4.WebBrowser1StatusTextChange(ASender: TObject;
  const Text: WideString);
begin
  Log('StatusTextChange. "' + Text + '"');
end;

procedure TForm4.WebBrowser1TitleChange(ASender: TObject;
  const Text: WideString);
begin
  Log('TitleChange. "' + Text + '"');
end;

procedure TForm4.Button2Click(Sender: TObject);
begin                            //      +EOL+EdCookie.Lines.Text
PostWithWebBrowser(edPost1.text+EOL+EdCookie.Lines.Text,edURLpost.Text );

//Navigate('/servlet/EW3SAS_WEB_PS?E_WORKID=ID1510&AD9500=45545479&AD3000=2000',EdCookie.Lines.Text ,WebBrowser1);

end;

procedure TForm4.Button3Click(Sender: TObject);
begin
with IdHTTP1 do
begin
 AllowCookies:=true;

 Request.Referer:='http://www.bl-recycle.jp/servlet/EW3SAS_WEB_PS';//http://www.bl-recycle.jp/psnet/sbe/AUP0000.HTML
 Request.URL:='/servlet/EW3SAS_WEB_PS';
 Request.Method:='POST';
 Request.Host:='http://www.bl-recycle.jp';
 Request.UserAgent:='Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)';
// Post('/servlet/EW3SAS_WEB_PS',)
end;

end;

procedure TForm4.Button4Click(Sender: TObject);
begin
 PostWithWebBrowser(edPost2.text+eol+EdCookie.Text,edURLpost.Text);

end;

procedure TForm4.Log(Txt: string);
begin

if (oLog=Txt) or (Txt='')  then exit;
  oLog:=txt;
  sLogs.Lines.Add(TimeToStr(now) + ': ' + Txt);
end;

end.
