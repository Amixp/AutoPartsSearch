unit HTMLUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, StdCtrls, IdTCPServer, Grids, DBGrids, JvDBGrid, DB, JvCsvData,
  StrUtils,
  DBClient, JvExDBGrids, JvExGrids, JvStringGrid;

type
  TForm7 = class(TForm)
    StrGrd: TStringGrid;
    ListBox1: TListBox;
  private
    { Private declarations }
  public
    { Public declarations }
    // Procedure EdNumKeyPress(Sender: TObject; Var Key: Char);
    // procedure LoadPages;
    // procedure BtnLoadHtmlClick(Sender: TObject);
    function ParseHTML(HTMLs: String): String;
    // function GetLastNum: String;
    // function ParseNum(HTMLs: String): String;
    Procedure Log(Str: String);

    Function GetHTML(Number, Page: integer): String;
    procedure StartLoad;
    constructor Create;
    { Public declarations }

  end;

type
  _Tag = record
    name, text: string;
    params: TStrings;
  end;

type
  _ClmnTbl = record
    Name, text, URL, FotoUrl, ClassName: string;
  end;

type
  _TblParts = record
    Index: integer;
    URL, URLFoto, Firm, Name, Body, Cost, Saler, Date, num, CostType: string;
  end;

type
  TParseHTML = class
  private
    function GetTag(buf, tagIn, tagOut: string; var pos: integer;
      var Tag: _Tag): boolean;
    function FirstDelimiter(const Delimiters, S: string;
      StartPos: integer): integer;
    function GetTagName(buf: string; var pos, n1, n2, l2, len: integer): string;
    function FindTag(html: string; var Tag: _Tag; var pos: integer): boolean;
    function GetTable(html: string; var pos: integer;
      StrGrd: TStringGrid): boolean;
    { Private declarations }
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

  published
    procedure Parse(FileName: string);
    function ParseTable(html: string; StrGrd: TStringGrid): integer;
  end;

var
  Form7: TForm7;
  NewID: integer;
  NamePaper: string;
  flgStop: boolean;
  ApplicationPath, DocumentsPath: String;
  nThread: Cardinal;

implementation

{$R *.dfm}

Function TForm7.ParseHTML(HTMLs: String): String;
Var
  Count, Ps0, Ps1, Ps2, Ps4, Count0, n: integer;
  Buff, snum, Str, Tag0, Tag1, Tag2, Tag4, Tag5, Tag6, Txt: String;
  I: integer;
Begin
  Result := '';
  Ps1 := 0;
  Tag0 := UpperCase('найдено');
  Tag1 := UpperCase('СТРАНИЦЫ');
  Tag2 := UpperCase('<table');
  Tag4 := UpperCase('</tr>');
  Tag5 := UpperCase('</head>');
  Tag6 := UpperCase('</STYLE>');
  Try
    Count := Length(HTMLs);
    Buff := UpperCase(HTMLs);
    Ps0 := 1;
    while Ps0 > 0 do
    begin
      Ps0 := PosEx(Tag6, Buff, Ps0 + 1);
      if Ps0 > 0 then
        Ps1 := Ps0;
    end;
    // Ps1:=PosEx('>',Buff,Ps1+1);
    while Str = '' do
    begin
      Ps1 := PosEx('>', Buff, Ps1 + 1);
      if Buff[Ps1 + 1] <> '<' then
      begin
        Ps2 := PosEx('<', Buff, Ps1 + 1);
        Str := MidStr(Buff, Ps1 + 1, Ps2 - Ps1);
        for I := 1 to Length(Str) do
        begin
          if IsCharAlphaNumeric(Str[I]) then
            Txt := Txt + Str[I];
        end;
        Str := Trim(Txt);
        Str := StringReplace(Str, ' ', '', [rfReplaceAll, rfIgnoreCase]);
        Str := StringReplace(Str, '/', '\', [rfReplaceAll, rfIgnoreCase]);
        Str := StringReplace(Str, 'nbsp', '\', [rfReplaceAll, rfIgnoreCase]);
        NamePaper := StringReplace(Str, '\\', '\',
          [rfReplaceAll, rfIgnoreCase]);
      end;
    end;
    Ps0 := PosEx(Tag0, Buff, 1);
    Txt := '';
    Str := '';
    If Ps0 > 0 Then
    Begin
      Ps0 := Ps0 + Length(Tag0);
      snum := '';
      // ---- поиск кол-ва
      While (Ps0 < Count) And (Buff[Ps0] <> '<') Do
      Begin
        If (Buff[Ps0] >= '0') And (Buff[Ps0] <= '9') Then
          snum := snum + Buff[Ps0]
        Else If snum <> '' Then
          break;
        Inc(Ps0);
      End;
      // -----------------------------
      If snum = '' Then
        snum := '0'; // Найдено: + snum
      If snum = '0' Then
        Exit;
      Ps2 := PosEx(Tag2, Buff, Ps0); // Start text *****************
      If Ps2 > 0 Then
      Begin
        Ps1 := PosEx(Tag1, Buff, Ps2);
        If Ps1 > 0 Then
        Begin
          Count0 := Length(Tag4);
          n := 0;
          For Ps4 := Ps1 Downto 0 Do
          Begin
            Str := MidStr(Buff, Ps4, Count0);
            n := CompareStr(Str, Tag4);
            If n = 0 Then
              break;
          End;
          If n = 0 Then
          Begin
            Ps4 := Ps4 + Count0; // End text *****************
            Txt := Txt + MidStr(HTMLs, Ps2, Ps4 - Ps2);
          End;
        End;
      End;
    End;
  Finally
    Result := Txt;
  End;
End;

Function TForm7.GetHTML(Number, Page: integer): String;
Var
  s_url, buf: String;
  IdHTTP1: TIdHTTP;
Begin
  Result := '';
  s_url := 'http://www.dalpress.ru/gazeta/list/?' +
    Format('s=35&t=%%&h=&n=%d2006&o=1&p=1&r=0&pg=%d', [Number, Page]);
  If (Number + Page) = 0 Then
    s_url := 'http://www.dalpress.ru/gazeta/';
  IdHTTP1 := TIdHTTP.Create(nil);
  With IdHTTP1 Do
  Begin
    Request.Referer := 'http://www.dalpress.ru/';
    Request.Host := 'http://www.dalpress.ru/';
    ReadTimeout := 15000;
    Try
      buf := Get(s_url);
    Except
      On e: Exception Do
        Log('IdHTTP: ' + e.Message);
    End;
  End; // with
  IdHTTP1.free;
  Result := buf;
End;

Procedure TForm7.Log(Str: String);
Begin
  ListBox1.Items.Insert(0, Str);
End;

{ function TForm7.ParseNum(HTMLs: String): String;
  Var
  Ps0, Ps1, Ps2: integer;
  Buff, Tag0: String;
  Begin
  Result := '';
  Ps1 := 0;
  Tag0 := UpperCase('Тираж');
  Try
  // Count := Length(HTMLs);
  Buff := UpperCase(HTMLs);
  Ps0 := 1;
  while Ps0 > 0 do
  begin
  Ps0 := PosEx(Tag0, Buff, Ps0 + 1);
  if Ps0 > 0 then
  Ps1 := Ps0;
  end;
  Ps1 := PosEx('№', Buff, Ps1 + 1);
  if Ps1 = 0 then
  Abort;
  Ps2 := PosEx('<', Buff, Ps1 + 1);
  if Ps2 = 0 then
  Abort;
  Result := MidStr(Buff, Ps1 + 1, Ps2 - Ps1 - 1);
  finally

  end;
  End; }

{ Procedure TForm7.LoadPages;
  Const
  HeaderTxt: String =
  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' +
  '<HTML><HEAD>' +
  '<META http-equiv=Content-Type content="text/html; charset=windows-1251">' +
  '<META content="MSHTML 6.00.3790.0" name=GENERATOR></HEAD>' + '<BODY>';
  EndTxt: String = '</TABLE></BODY></HTML>';
  Var
  BufHTML: String;
  Page: integer;
  StrTxt: TStrings;
  sFileName: String;
  StrGrd: TStringGrid;
  pHTML: TParseHTML;
  I, n: integer;
  Begin
  For Page := 1 To 1000 Do
  Begin
  BufHTML := GetHTML(000, Page);
  If (BufHTML = '') and (Page = 1) Then
  Exit;
  StrTxt := TStringList.Create;
  sFileName := DocumentsPath + '1' + '-' + Format('%d', [Page]) + '.htm';
  StrTxt.text := BufHTML;
  StrTxt.SaveToFile(sFileName);
  StrTxt.free;
  // ========================
  StrGrd := TStringGrid.Create(nil);
  pHTML := TParseHTML.Create;
  n := pHTML.ParseTable(BufHTML, StrGrd);
  if n = 0 then
  Exit;
  for I := 0 to n do
  begin
  if Trim(StrGrd.Cells[1, I]) <> '' then
  begin
  ClientDataSet1.Append;
  ClientDataSet1.FieldByName('ID').AsInteger := NewID;
  ClientDataSet1.FieldByName('ID0').AsString := StrGrd.Cells[0, I];
  ClientDataSet1.FieldByName('Num').AsInteger := 000;
  ClientDataSet1.FieldByName('TEXT').AsString := StrGrd.Cells[1, I];
  ClientDataSet1.Post;
  Inc(NewID);
  end;
  end;
  StrGrd.free;
  // ========================
  /// /////////////////    BufHTML := (ParseHTML(BufHTML));
  /// ///////    If BufHTML = '' Then break;
  // LbPage.Caption:=Format('%d',[Page]);
  // LbPage.Refresh;
  // Dalpress := Dalpress + BufHTML;
  Application.ProcessMessages;
  if flgStop then
  Exit;
  End;
  { Dalpress := Dalpress + EndTxt;
  StrTxt := TStringList.Create;
  Try
  // sFileName := DocumentsPath + 'Выпуск номер №' + MainForm.EdNum.Text + '.htm';
  StrTxt.Text := Dalpress;
  // StrTxt.SaveToFile(sFileName);
  Finally
  StrTxt.Free;
  End; }{
  End;
}

{ function TForm7.GetLastNum(): string;
  Var
  num, BufHTML: String;
  Page: integer;
  begin
  // --------------
  BufHTML := GetHTML(0, 0);
  If (BufHTML = '') and (Page = 1) Then
  Exit;
  num := (ParseNum(BufHTML));
  Result := num;
  end; }

{ Procedure TForm7.EdNumKeyPress(Sender: TObject; Var Key: Char);
  Var
  Txt: String;
  Begin
  Try
  // if MainForm.EdNum.Text='' then MainForm.EdNum.Text:='1';
  Txt := '0';

  If Key <> #8 Then
  Txt := Txt + Key;
  If Not(Key In ['0' .. '9', #8]) Or (StrToInt(Txt) < 1) Or
  (StrToInt(Txt) > 990000) Then
  Begin
  Key := #0;
  MessageBeep(MB_OK);
  End;
  except
  End;
  End; }

procedure TForm7.StartLoad;
begin
  if flgStop then
  begin
    // MainForm.EdNum.Enabled := false;
    // MainForm.BtnLoad.Caption := 'Прервать';
    flgStop := false;
    /// ///  LoadPages;
    // MainForm.EdNum.Enabled := true;
    // MainForm.BtnLoad.Caption := 'Загрузка';
  end;
  flgStop := true;
end;

{ procedure TForm7.BtnLoadHtmlClick(Sender: TObject);
  var
  Clmn: _ClmnTbl;
  Tbl: _TblParts;
  IdHTTP1: TIdHTTP;
  BufHTML: String;
  Page: integer;
  StrTxt: TStrings;
  sFileName: String;
  StrGrd: TStringGrid;
  pHTML: TParseHTML;
  I, n: integer;
  begin
  ApplicationPath := ExtractFilePath(Application.ExeName);
  DocumentsPath := ApplicationPath + 'Объявления\';
  { If Not DirectoryExists(ApplicationPath + 'Logs') Then
  CreateDir(ApplicationPath + 'Logs'); }
{
  If Not DirectoryExists(DocumentsPath) Then
  ForceDirectories(DocumentsPath);

  Page := 1;
  if CheckBox1.Checked then
  begin
  IdHTTP1 := TIdHTTP.Create(nil);
  With IdHTTP1 Do
  Begin
  Request.Referer := Edit1.text; // 'http://www.dalpress.ru/';
  Request.Host := Edit1.text; // 'http://www.dalpress.ru/';
  ReadTimeout := 15000;
  Try
  BufHTML := Get(Edit1.text);
  Except
  On e: Exception Do
  Log('IdHTTP: ' + e.Message);
  End;
  End; // with
  IdHTTP1.free;

  // BufHTML := GetHTML(000, Page);
  If (BufHTML = '') and (Page = 1) Then
  Exit;
  StrTxt := TStringList.Create;
  sFileName := DocumentsPath + '1' + '-' + Format('%d', [Page]) + '.htm';
  StrTxt.text := BufHTML;
  StrTxt.SaveToFile(sFileName);
  StrTxt.free;
  // ========================
  end
  else
  begin
  StrTxt := TStringList.Create;
  sFileName := DocumentsPath + '1' + '-' + Format('%d', [Page]) + '.htm';
  StrTxt.LoadFromFile(sFileName);
  BufHTML := StrTxt.text;
  StrTxt.free;
  end;
  StrGrd := TStringGrid.Create(nil);
  pHTML := TParseHTML.Create;
  n := pHTML.ParseTable(BufHTML, StrGrd);
  if n = 0 then
  Exit;
  for I := 0 to n do
  begin
  if Trim(StrGrd.Cells[1, I]) <> '' then
  begin
  ClientDataSet1.Append;
  ClientDataSet1.FieldByName('ID').AsInteger := NewID;
  ClientDataSet1.FieldByName('ID0').AsString := StrGrd.Cells[0, I];
  ClientDataSet1.FieldByName('Num').AsInteger := 000;
  ClientDataSet1.FieldByName('TEXT').AsString := StrGrd.Cells[1, I];
  ClientDataSet1.Post;
  Inc(NewID);
  end;
  end;
  StrGrd.free;

  end; }

constructor TForm7.Create;
begin
  // inherited Create;
  { flgStop := true; // флаг статуса процедуры
    ApplicationPath := ExtractFilePath(Application.ExeName);
    DocumentsPath := ApplicationPath + 'Объявления\';
    { If Not DirectoryExists(ApplicationPath + 'Logs') Then
    CreateDir(ApplicationPath + 'Logs'); }
  { If Not DirectoryExists(DocumentsPath) Then
    ForceDirectories(DocumentsPath); }
end;


// ==========================================

procedure TParseHTML.Parse(FileName: string);
var
  buf: String;
  Str: TStrings;
  StrGrd: TStringGrid;
begin
  { if Button1.Tag=1 then
    begin
    Button1.Caption:='Parse';
    Button1.Tag:=0; //stop
    Exit;
    end;
    Button1.Tag:=1; //start
    Button1.Caption:='Stop';
  }
  Str := TStringList.Create;
  Str.LoadFromFile(FileName);
  buf := Str.text;
  Str.free;
  StrGrd := TStringGrid.Create(nil);
  // StrGrd.Assign(ParseTable(Buf));
  ParseTable(buf, StrGrd);
  {
    Button1.Caption:='Parse';
    Button1.Tag:=0; //stop
  }
  StrGrd.free;
end;

function TParseHTML.GetTagName(buf: string;
  var pos, n1, n2, l2, len: integer): string;
// var
// n1,n2,len,l2: integer;
begin
  n1 := PosEx('<', buf, pos);
  if n1 = 0 then
    Abort;
  Inc(n1);
  n2 := PosEx('>', buf, n1);
  l2 := n2;
  len := n2 - n1;
  n2 := FirstDelimiter(' >', buf, n1); // first word after <
  Result := MidStr(buf, n1, n2 - n1);
end;

function TParseHTML.FirstDelimiter(const Delimiters, S: string;
  StartPos: integer): integer;
var
  P: PChar;
begin
  Result := StartPos; // Length(S);
  P := PChar(Delimiters);
  while Result < Length(S) do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then
        Inc(Result)
      else
        Exit;
    Inc(Result);
  end;
end;

function TParseHTML.GetTag(buf, tagIn, tagOut: string; var pos: integer;
  var Tag: _Tag): boolean;
var
  S, sk: string;
  n1, n2, len, l2: integer;
begin // <<<----------
  try
    Result := false;
    S := '';
    sk := '';
    Tag.name := '';

    Tag.text := '';
    Tag.params.Clear;
    // s:=buf[pos];  //test
    Tag.name := GetTagName(buf, pos, n1, n2, l2, len); // имя тега
    pos := n2;
    // --
    if buf[pos] <> '>' then
      while pos < l2 do
      begin
        n1 := pos + 1;
        pos := FirstDelimiter(' >"', buf, n1);
        if buf[pos] = '"' then
        begin
          pos := FirstDelimiter('>"', buf, pos + 1);
          if buf[pos] = '"' then
            Inc(pos);
        end;
        if n2 = 0 then
          pos := len + 1;
        S := MidStr(buf, n1, pos - n1);
        Tag.params.Append(S);
      end;
    // pos:=n2;
    // --
    sk := '';
    S := '';
    while (S = '') or (S = 'a') or (S = '/a') or (S = 'b') or (S = 'ul') or
      (S = '/ul') or (S = 'div') or (S = '/div') or (S = '/b') or (S = '/td') or
      (S = '/tr') or (S = 'font') or (S = '/font') do
    // span /span , i /i , br /br
    begin
      n1 := PosEx(tagOut, buf, pos);
      if n1 = 0 then
        Abort;
      Inc(n1);
      n2 := PosEx(tagIn, buf, n1);
      sk := sk + MidStr(buf, n1, n2 - n1); // строка между > <
      pos := n2;
      S := GetTagName(buf, pos, n1, n2, l2, len);
    end;
    Tag.text := sk;
    Result := true;
  except
  end;

end;

function TParseHTML.ParseTable(html: string; StrGrd: TStringGrid): integer;
var
  Tag: _Tag;
  td, tr, table: string;
  pos: integer;
begin // <<<<<<<<<<<<<<<<<<<<<<<<<<<<

  td := 'td'; // ячйека
  tr := 'tr'; // строка
  table := 'table';
  Tag.params := TStringList.Create;
  pos := 1;
  // index := 0;
  StrGrd.FixedRows := 0;
  StrGrd.Cols[0].Clear;
  StrGrd.Rows[0].Clear;
  StrGrd.ColCount := 4;
  StrGrd.RowCount := 0;
  try
    Tag.name := 'table';
    Tag.params.Add('class="main-list"'); // таблица
    if FindTag(html, Tag, pos) then
      Tag.name := 'tr';
    Tag.params.Values['class'] := '"  "';
    if FindTag(html, Tag, pos) then // строка начала
      GetTable(html, pos, StrGrd);
  finally
    Result := pos; { TODO : проверить, зачем здесь результат функции? }
  end;
end;

function TParseHTML.GetTable(html: string; var pos: integer;
  StrGrd: TStringGrid): boolean;
var { TODO : Проверить выход функции }
  row, clm: integer;
  Tag: _Tag;
  // TagName, TagClass: string;
  // NewLine: boolean;
begin
  Tag.params := TStringList.Create;
  Result := false;
  row := 0;
  clm := 0;
  while GetTag(html, '<', '>', pos, Tag) do
  begin
    if Tag.name = 'tr' then
      if Tag.params.Values['class'] = '  ' then
      begin
        Inc(row);
        clm := 0;
        { TODO : ошибка перехода на новую строку в гриде , возможно некоректно определ. конец тек. строки в html таблице }
      end;
    if Tag.name = 'td' then
    begin
      StrGrd.Cells[clm, row] := Trim(Tag.text);
      Inc(clm);
    end;
  end;
end;

function TParseHTML.FindTag(html: string; var Tag: _Tag;
  var pos: integer): boolean;
var
  // Tag: _Tag;
  TagName, TagClass: string;
begin
  TagName := Tag.name;
  TagClass := Tag.params.Values['class'];
  Result := false;
  while GetTag(html, '<', '>', pos, Tag) do
  begin
    if Tag.name = TagName then
      if Tag.params.Values['class'] = TagClass then
      begin
        Result := true;
        Exit;
      end;
  end;
end;

function ParseTable1(html: string; StrGrd: TStringGrid): integer;
var
  Tag: _Tag;
  td, tr, table: string;
  index { , pos } : integer;
begin // <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  td := 'td'; // ячйека
  tr := 'tr'; // строка
  table := 'table';
  Tag.params := TStringList.Create;
  // pos := 1;
  index := 0;
  StrGrd.FixedRows := 0;
  StrGrd.Cols[0].Clear;
  StrGrd.Rows[0].Clear;
  StrGrd.ColCount := 4;
  StrGrd.RowCount := 0;
  // ProgressBar1.Max:=Length(html);
  // ProgressBar1.Position:=0;
  try
    // GetTag(html, '<', '>', pos, Tag);
    while Tag.name <> '' do
    begin
      // GetTag(html, '<', '>', pos, Tag);
      // label1.Caption:=IntToStr(i);
      // Label1.Refresh;
      // ProgressBar1.Position:=i;
      // ProgressBar1.Refresh;

      // Application.ProcessMessages;
      // if Button1.Tag=0 then Abort; // stop

      { if tag.name=tr then
        inc(index); }
      if Tag.name = td then
        if Tag.params.Values['class'] = 'N' then
          StrGrd.Cells[0, index] := Tag.text;
      if Tag.params.Values['class'] = 'N3' then
      begin
        StrGrd.Cells[1, index] := Tag.text;
        Inc(index);
      end;
    end;
    Result := index; // кол-во строк !!!
  except
  end;

end;

constructor TParseHTML.Create;
begin
  inherited Create;
end;

destructor TParseHTML.Destroy;
begin
  inherited Destroy;
end;

end.
