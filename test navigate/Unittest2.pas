unit Unittest2;

interface

uses
  MSHTML, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, UrlMon, activex, db,
  strutils,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, Grids, ComCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, JvUrlListGrabber,
  JvUrlGrabbers, JvComponentBase, JvHtmlParser, DBGrids;

type
  TForm2 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    WebBrowser1: TWebBrowser;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    StringGrid1: TStringGrid;
    ProgressBar1: TProgressBar;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    IdHTTP1: TIdHTTP;
    JvHTMLParser1: TJvHTMLParser;
    JvLocalFileUrlGrabber1: TJvLocalFileUrlGrabber;
    Button5: TButton;
    TabSheet3: TTabSheet;
    Memo1: TMemo;
    TabSheet4: TTabSheet;
    DBGrid1: TDBGrid;
    procedure Button1Click(Sender: TObject);
    procedure WebBrowser1ProgressChange(ASender: TObject;
      Progress, ProgressMax: Integer);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    function GetElementById(const Doc: IDispatch; const Id: string): IDispatch;
    procedure GetHtmlTbl(html: string);
    function GetURLpage(html: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  iRow: Integer;

implementation

uses UnitData;

{$R *.dfm}

procedure TForm2.Button2Click(Sender: TObject);
var
  URL: OleVariant;
begin
  URL := '';
  WebBrowser1DocumentComplete(Sender, WebBrowser1.Application, URL);
end;

function DownloadFile(SourceFile, DestFile: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(SourceFile), PChar(DestFile),
      0, nil) = 0;
  except
    Result := False;
  end;
end;

procedure TForm2.Button3Click(Sender: TObject);
var
  StrURL, sFileName: string;
  SLBody: TStringList;
  Doc: IHTMLDocument2;
  v: OleVariant;
  DocAll, DocTR, DocTD: IHTMLElementCollection;
  TRElement, TDElement: IHtmlElement;
  i: Integer;
begin
  // ������� ��������� ��������. ��� ����� ������� ������� ���������
  // � ������� �������� �������� � ����, ��� ��� � ��� ����� ����
  // ������ ������ ����������� Indy, ��� ����� �������������
  StrURL := 'http://stock.rbc.ru/demo/micex.0/intraday/eod.rus.shtml';
  SLBody := TStringList.Create;
  sFileName := ExtractFilePath(Application.ExeName) + 'cache.txt';
  if DownloadFile(StrURL, sFileName) then
    SLBody.LoadFromFile(sFileName);
  DeleteFile(sFileName);
  // ��������� ��� � "WebBrowser". ������, ������� ������ IHTMLDocument2
  // �������, �����. ���� � ���, ��� ��������� ����������
  // ��������-�������� ���������� �������. ������� ��������� XMLDocument
  // ��� �� ������� ����� �� ������ �������. ��� ���������� ����� �
  // ���������� ��������� (���� ��������� ����� ����� �������� �� ������
  // � ���������, �, ��������, �������� �� ���� �������)
  Doc := coHTMLDocument.Create as IHTMLDocument2;
  if Doc = nil then
  begin
    ShowMessage('������ �������� IHTMLDocument2');
    exit;
  end;
  v := VarArrayCreate([0, 0], VarVariant);
  v[0] := SLBody.Text;
  Doc.write(PSafeArray(TVarData(v).VArray));
  // ���� � DOM-��������� �������, �������� �������� ��� �����.
  // ��� ����� ������� ����������� ��������, ����� ���������� ��������,
  // ������� ��� ������� ��� �������. ��� ����� ����:
  // <TR>
  // <TD><A TARGET="_top" HREF="../daily/GAZP.rus.shtml?show=all" class="n"><img src="http://pics.rbc.ru/img/up_grf.gif" width="19" height="15" border="0">  %u0413%u0430%u0437%u043F%u0440%u043E%u043C</A></TD>
  // <TD class=G>158.2</TD>
  // �� ���� ���� ����� ������� TR, � ������ TD �������� �������� "�������",
  // � ����� �������� �� �������  TD
  DocAll := Doc.all;
  DocTR := DocAll.Tags('TR') as IHTMLElementCollection;
  for i := 0 to DocTR.length - 1 do
  begin
    TRElement := DocTR.Item(i, 0) as IHtmlElement;
    // ������� ��� �������� �������� (TD-��������)
    DocTD := TRElement.children as IHTMLElementCollection;
    // ������ ��� ���������� � ������� � ������� TD-�������� � ���������,
    // ������� ���� �� ���������, ���� �� ��� ������������� 2 �������� (��� ������)
    if (DocTD.length > 1) then
    begin
      TDElement := DocTD.Item(0, 0) as IHtmlElement;
      // ���� � ������ �������� �������� �������, �� ��� ��, ��� �� ����
      if (AnsiCompareStr(trim(TDElement.innerText), '�������') = 0) then
      begin
        ShowMessage((DocTD.Item(1, 0) as IHtmlElement).innerText);
        exit;
      end;
    end;
  end;
  SLBody.Free;
end;

procedure TForm2.Button4Click(Sender: TObject);
var
  StrURL, sFileName: string;
  SLBody: TStringList;
  Doc: IHTMLDocument2;
  v, Elem: OleVariant;
  DocAll, DocTR, DocTD: IHTMLElementCollection;
  TRElement, TDElement: IHtmlElement;
  i, m, n: Integer;
begin
  StrURL := Edit1.Text;
  // 'http://stock.rbc.ru/demo/micex.0/intraday/eod.rus.shtml';
  SLBody := TStringList.Create;
  // sFileName := ExtractFilePath(Application.ExeName) + 'cache.txt';
  // if DownloadFile(StrURL, sFileName) then
  // SLBody.LoadFromFile(sFileName);
  // DeleteFile(sFileName);
  // -----
  With IdHTTP1 Do
  Begin
    ReadTimeout := 15000;
    Try
      SLBody.Add(Get(StrURL));
    Except
    End;
  End;
  // -----
  Doc := coHTMLDocument.Create as IHTMLDocument2;
  if Doc = nil then
  begin
    ShowMessage('������ �������� IHTMLDocument2');
    exit;
  end;
  v := VarArrayCreate([0, 0], VarVariant);
  v[0] := SLBody.Text;
  Doc.write(PSafeArray(TVarData(v).VArray));
  // ���� � DOM-��������� �������, �������� �������� ��� �����.
  // ��� ����� ������� ����������� ��������, ����� ���������� ��������,
  // ������� ��� ������� ��� �������. ��� ����� ����:
  // <TR>
  // <TD><A TARGET="_top" HREF="../daily/GAZP.rus.shtml?show=all" class="n"><img src="http://pics.rbc.ru/img/up_grf.gif" width="19" height="15" border="0">  %u0413%u0430%u0437%u043F%u0440%u043E%u043C</A></TD>
  // <TD class=G>158.2</TD>
  // �� ���� ���� ����� ������� TR, � ������ TD �������� �������� "�������",
  // � ����� �������� �� �������  TD
  DocAll := Doc.all;
  DocTR := DocAll.Tags('table') as IHTMLElementCollection;
  for i := 0 to DocTR.length - 1 do
  begin
    TRElement := DocTR.Item(i, 0) as IHtmlElement;
    Elem := TRElement.getAttribute('className', 0);
    if not VarIsNull(Elem) then
      if (UpperCase(Elem) = UpperCase('main-list')) then
      begin
        Memo1.Lines.Clear;
        DocAll := TRElement.all as IHTMLElementCollection;
        DocTR := DocAll.Tags('TR') as IHTMLElementCollection;
        for n := 0 to DocTR.length - 1 do
        begin
          TRElement := DocTR.Item(n, 0) as IHtmlElement;
          // ������� ��� �������� �������� (TD-��������)
          DocTD := TRElement.children as IHTMLElementCollection;

          // ������ ��� ���������� � ������� � ������� TD-�������� � ���������,
          // ������� ���� �� ���������, ���� �� ��� ������������� 2 �������� (��� ������)

          if (DocTD.length > 1) then
            for m := 0 to DocTD.length - 1 do
            begin
              /// /// TDElement := DocTD.Item(m, 0) as IHtmlElement;
              // ���� � ������ �������� �������� �������, �� ��� ��, ��� �� ����
              // if (AnsiCompareStr(trim(TDElement.innerText), '�������') <> 0) then
              // begin
              Memo1.Lines.Add((DocTD.Item(m, 0) as IHtmlElement).innerText);
              // exit;
              // end;
            end;
        end;

      end;
  end;

  exit;
  for i := 0 to DocTR.length - 1 do
  begin
    TRElement := DocTR.Item(i, 0) as IHtmlElement;
    if not VarIsNull(TDElement.getAttribute('class', 0)) then
      if (AnsiCompareStr(trim(TDElement.getAttribute('class', 0)),
        'main_list') = 0) then
      begin
        ShowMessage((DocTD.Item(1, 0) as IHtmlElement).innerText);
        exit;
      end;
    // ������� ��� �������� �������� (TD-��������)
    DocTD := TRElement.children as IHTMLElementCollection;
    // ������ ��� ���������� � ������� � ������� TD-�������� � ���������,
    // ������� ���� �� ���������, ���� �� ��� ������������� 2 �������� (��� ������)
    if (DocTD.length > 1) then
    begin
      TDElement := DocTD.Item(0, 0) as IHtmlElement;
      if not VarIsNull(TDElement.getAttribute('class', 0)) then
        //
        if (AnsiCompareStr(trim(TDElement.getAttribute('class', 0)),
          'main_list') = 0) then
        begin
          ShowMessage((DocTD.Item(1, 0) as IHtmlElement).innerText);
          exit;
        end;
    end;
  end;
  SLBody.Free;
end;

procedure TForm2.Button5Click(Sender: TObject);
var
  StrURL, sFileName: string;
  SLBody: TStringList;
  Doc: IHTMLDocument2;
  row: ihtmltablerow;
  table: ihtmltable;
  cell: ihtmltablecell;
  v, Elem: OleVariant;
  tables, DocAll, DocTR, DocTD: IHTMLElementCollection;
  el, TRElement, TDElement: IHtmlElement;
  t, r0, i, r, c, m, n: Integer;
begin
  { DONE -o����� -c������ : �������� �������� ��������� ������� }
  StrURL := Edit1.Text;
  SLBody := TStringList.Create;
  DataModule2.JvCsvDataSet1.Active := False;
  DataModule2.JvCsvDataSet1.FieldList.Clear;
  DataModule2.JvCsvDataSet1.CsvFieldDef := '';
  DataModule2.JvCsvDataSet1.Filename := ExtractFilePath(Application.ExeName) +
    'TestData.csv';
  // DataModule2.JvCsvDataSet1.Active:=true;
  // DataModule2.JvCsvDataSet1.EmptyTable;
  // sFileName := ExtractFilePath(Application.ExeName) + 'cache.txt';
  // if DownloadFile(StrURL, sFileName) then
  // SLBody.LoadFromFile(sFileName);
  // DeleteFile(sFileName);
  // -----
  repeat
    With IdHTTP1 Do
    Begin
      ReadTimeout := 15000;
      Try
        SLBody.Add(Get(StrURL));
        if SLBody.Text = '' then
        begin
          ShowMessage('������ �������� HTML');
          exit;
        end;
      Except
        on E: Exception do
        begin
          ShowMessage(E.Message);
          exit;
        end;
      End;
    End;

    GetHtmlTbl(SLBody.Text);
    StrURL := GetURLpage(SLBody.Text);
  until StrURL <> '';
end;

function TForm2.GetURLpage(html: string): string;
var
  StrURL, sFileName: string;
  Doc: IHTMLDocument2;
  row: ihtmltablerow;
  table: ihtmltable;
  cell: ihtmltablecell;
  v, Elem: OleVariant;
  tables, DocAll, DocTR, DocA, DocDIV, DocTD: IHTMLElementCollection;
  el, TRElement, TDElement: IHtmlElement;
  t, r0, i, r, c, m, n: Integer;
begin
  // -----
  Doc := coHTMLDocument.Create as IHTMLDocument2;
  if Doc = nil then
  begin
    ShowMessage('������ �������� IHTMLDocument2');
    exit;
  end;
  // - ����-��
  v := VarArrayCreate([0, 0], VarVariant);
  v[0] := html;
  Doc.write(PSafeArray(TVarData(v).VArray));
  // ����� ����-��
  DocAll := Doc.all;
  DocTR := DocAll.Tags('div') as IHTMLElementCollection;
  for t := 0 to DocTR.length - 1 do
  begin
    TRElement := DocTR.Item(t, 0) as IHtmlElement;
    Elem := TRElement.getAttribute('className', 0);
    if not VarIsNull(Elem) then
      if (UpperCase(Elem) = UpperCase('pagination')) then
      begin // ������ ��� � ������ �������
        DocDIV := DocAll.Tags('DIV') as IHTMLElementCollection;
        for i := 0 to DocDIV.length - 1 do
        begin
          TRElement := DocDIV.Item(i, 0) as IHtmlElement;
          // ������� ��� �������� �������� (a-��������)
          DocAll := TRElement.children as IHTMLElementCollection;
          DocA := DocAll.Tags('a') as IHTMLElementCollection;
          for n := 0 to DocA.length - 1 do
          begin
            TRElement := DocA.Item(n, 0) as IHtmlElement;
            Elem := TRElement.getAttribute('href', 0);
            if not VarIsNull(Elem) then
              if (AnsiContainsText(TDElement.innerText, '���������')) then
              begin
                // if not VarIsNull(Elem) then
                // begin // ������ ��� � ������ �������
                Result := Elem;
                exit;
                // end;
              end;
          end;
        end;
      end;
  end;
end;


// procedure TForm1.Button3Click(Sender: TObject);
// var
// Document: IHTMLDocument2;
// Collection: IHTMLElementCollection;
// Element: IHTMLElement;
// I: Integer;
// begin
// // ���� ����� ������������ ����� ��������� ��� ������ DHTML
// Document := WebBrowser1.Document as IHtmlDocument2;
// Collection := Document.all;
// Collection := Collection.Tags('BODY') as IHTMLElementCollection;
// Element := Collection.Item(NULL, 0) as IHTMLElement;
// Element.InnerText := 'Modifyed by DHTML';
// end;

procedure TForm2.GetHtmlTbl(html: string);
var
  s, StrURL, sFileName: string;
  Doc: IHTMLDocument2;
  row: ihtmltablerow;
  table: ihtmltable;
  cell: ihtmltablecell;
  v, Elem: OleVariant;
  sFields: TStrings;
  tables, DocAll, DocTR, DocTD: IHTMLElementCollection;
  el, TRElement, TDElement: IHtmlElement;
  t, r0, i, r, c, m, n: Integer;
  FlgFieldsName: Boolean;
begin
  // -----
  Doc := coHTMLDocument.Create as IHTMLDocument2;
  if Doc = nil then
  begin
    ShowMessage('������ �������� IHTMLDocument2');
    exit;
  end;
  // - ����-��
  r0 := iRow;
  v := VarArrayCreate([0, 0], VarVariant);
  v[0] := html;
  Doc.write(PSafeArray(TVarData(v).VArray));
  // ����� ����-��
  DocAll := Doc.all;
  DocTR := DocAll.Tags('table') as IHTMLElementCollection;
  for t := 0 to DocTR.length - 1 do
  begin
    TRElement := DocTR.Item(t, 0) as IHtmlElement;
    Elem := TRElement.getAttribute('className', 0);
    if not VarIsNull(Elem) then
      if (UpperCase(Elem) = UpperCase('main-list')) then
      begin // ������ ��� � ������ �������
        table := DocTR.Item(t, 0) as ihtmltable;
        for r := 0 to table.rows.length - 1 do
        begin
          // if FlgFieldsName then  DataModule2.JvMemoryData1.

          FlgFieldsName := False;
          row := table.rows.Item(r, 0) as ihtmltablerow;
          sFields := TStringList.Create;
          for c := 0 to row.cells.length - 1 do
          begin
            el := row.cells.Item(c, 0) as IHtmlElement;
            Elem := el.getAttribute('className', 0);
            cell := el as ihtmltablecell;
            if not VarIsNull(Elem) then
            begin
              if (UpperCase(Elem) = UpperCase('photo')) then
                FlgFieldsName := true;
              // ������ ��� ������ ������� - ��������� �������
            end;
            if FlgFieldsName then
            begin
              with DataModule2.JvCsvDataSet1 do
              begin
                with FieldDefs do
                begin
                  with AddFieldDef do
                  begin
                    s := trim(el.innerText);
                    if s = '' then
                      s := 'Field' + IntToStr(c);
                    Name := s;
                    DataType := ftString;
                    Required := False;
                    Size := 55;
                  end;
                end;
                if CsvFieldDef <> '' then
                  CsvFieldDef := CsvFieldDef + ',';
                CsvFieldDef := CsvFieldDef + '"' + s + '":$255';
              end;
            end
            else
              sFields.Add(trim(el.innerText));

            if StringGrid1.colcount < c then
              StringGrid1.colcount := c;
            if StringGrid1.rowcount < r then
              StringGrid1.rowcount := r;
            StringGrid1.cells[c, r + r0] := el.innerText;
          end;
          if FlgFieldsName then
            // DataModule2.JvCsvDataSet1.CsvFieldDef
            /// /        DataModule2.JvCsvDataSet1.Active:=true
          else
            with DataModule2.JvCsvDataSet1 do
            begin
              // Append;
              for m := 0 to FieldCount - 1 do
              begin
                // if m<sFields.Count then
                // Fields.Fields[m].AsString := sFields.Strings[m];
              end;
              // sFields.Clear;
              // Fields.GetFieldNames(sFields);
              // Post;
              sFields.Destroy;
            end;
        end;
      end;
    r0 := r0 + r;
    iRow := r0;
  end;
end;

function TForm2.GetElementById(const Doc: IDispatch; const Id: string)
  : IDispatch;
var
  Document: IHTMLDocument2; // IHTMLDocument2 interface of Doc
  Body: IHTMLElement2; // document body element
  Tags: IHTMLElementCollection; // all tags in document body
  Tag: IHtmlElement; // a tag in document body
  i: Integer; // loops thru tags in document body
begin
  Result := nil;
  // Check for valid document: require IHTMLDocument2 interface to it
  if not Supports(Doc, IHTMLDocument2, Document) then
    raise Exception.Create('Invalid HTML document');
  // Check for valid body element: require IHTMLElement2 interface to it
  if not Supports(Document.Body, IHTMLElement2, Body) then
    raise Exception.Create('Can''t find <body> element');
  // Get all tags in body element ('*' => any tag name)
  Tags := Body.getElementsByTagName('*');
  // Scan through all tags in body
  for i := 0 to Pred(Tags.length) do
  begin
    // Get reference to a tag
    Tag := Tags.Item(i, EmptyParam) as IHtmlElement;
    // Check tag's id and return it if id matches
    if AnsiSameText(Tag.Id, Id) then
    begin
      Result := Tag;
      Break;
    end;
  end;
end;

procedure TForm2.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  Doc: IHTMLDocument2;
  tables: IHTMLElementCollection;
  table: ihtmltable;
  row: ihtmltablerow;
  cell: ihtmltablecell;
  el: IHtmlElement;
  r, c, i, r0: Integer;
begin
  Doc := WebBrowser1.Document as IHTMLDocument2;
  tables := Doc.all.Tags('table') as IHTMLElementCollection;
  for i := 0 to tables.length - 1 do
  begin
    table := tables.Item(i, 0) as ihtmltable;
    for r := 0 to table.rows.length - 1 do
    begin
      row := table.rows.Item(r, 0) as ihtmltablerow;
      for c := 0 to row.cells.length - 1 do
      begin
        el := row.cells.Item(c, 0) as IHtmlElement;
        cell := el as ihtmltablecell;
        if StringGrid1.colcount < c then
          StringGrid1.colcount := c;
        if StringGrid1.rowcount < r then
          StringGrid1.rowcount := r;
        StringGrid1.cells[c, r + r0] := el.innerHTML;
      end;

    end;
    r0 := r0 + r;
  end;
end;

procedure TForm2.WebBrowser1ProgressChange(ASender: TObject;
  Progress, ProgressMax: Integer);
begin
  ProgressBar1.Position := Progress;
  ProgressBar1.Max := ProgressMax;
end;

procedure TForm2.Button1Click(Sender: TObject);

begin

  WebBrowser1.Navigate(Edit1.Text);

end;

end.
