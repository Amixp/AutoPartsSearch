unit DataUnit;

interface

uses
  Data.DB, Data.Win.ADODB , SysUtils, comobj,  controls, variants, Dialogs,
  Classes;


 //-------------
  const
  iDBver: Integer = 4;  //������ ��������� ���� ������
 ///////////
  type
  TOpt2 = record // ��������� ����� .NET
    SiteLoginURL, SiteURL, Login1, Login2, Login3: string;
  end;

  type
  TSets = class(TObject)
  public
    DatabaseFileName, SiteURL: string;
    LsURLs: TStrings;
    Opt2: TOpt2;
    Constructor Create;
    Destructor Destroy; override;
  end;

type
  trec = record
    name: string;
    len: integer;
  end;

  type
  TsItem = class(TObject)
  public
    Foto, Firm, Name, Body, N1, N2, Price, Saler: string;
    Date: TDate;
    Constructor Create;
    Destructor Destroy; override;
  end;

type
  TsItem2 = class(TObject)
  public
    part1, part2, partnumber: string;
    Constructor Create;
    Destructor Destroy; override;
  end;

type
  TDataModule1 = class(TDataModule)
    DataSource1: TDataSource;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    DSItems: TDataSource;
    QItems: TADOQuery;
    QItemsid: TAutoIncField;
    QItems����: TWideStringField;
    QItems�����: TWideStringField;
    QItems��������: TWideStringField;
    QItems���������: TWideStringField;
    QItemsN: TWideStringField;
    QItemsField5: TWideStringField;
    QItems����: TWideStringField;
    QItems��������: TWideStringField;
    QItems����: TDateTimeField;
    DSURL: TDataSource;
    QURLs: TADOQuery;
    QURLsid: TAutoIncField;
    QURLsurl: TWideMemoField;
    DSQItems2: TDataSource;
    QItems2: TADOQuery;
    QItems2id: TAutoIncField;
    QItems2part1: TWideMemoField;
    QItems2part2: TWideMemoField;
    QItems2partnumber: TWideStringField;
    DSQURLs2: TDataSource;
    QURLs2: TADOQuery;
    QURLs2id: TAutoIncField;
    QURLs2set1: TWideMemoField;
    QURLs2set2: TWideMemoField;
  private
    function SetVersionDB(iVer: integer): boolean;
    { Private declarations }
  public
    { Public declarations }
    function ModifyColumn(sTableName, newColumn, TypeCol: string): string;
    function CopyAccessDatabase(FileName: string): string;
    function CreateDB2(sDatabaseFileName: string): boolean;
    function OpenTbls2(sDatabaseFileName: string): boolean;
    function ExecSQL(sSQL: string): string;
    function CreateTables2: boolean;
    function GetVersionDB: integer;
    function CheckTableExist(sTableName: string): boolean;
    procedure CreateTblItems;
    procedure CreateTblItems2;
    procedure CreateTblUrls;
    procedure CreateTblUrls2;
        function GetCount2URLs: integer;
    function Get2URLs(sUrls: TStrings): integer;
    function GetURL(idURL: integer): string;
    function GetURLID(sURL: string): integer;
    function GetItemID(sFName, sURL: string): integer;
    function GetItem2ID(sItem: tsItem2): integer;
    function GetCountURLs: integer;
    function GetURLs: String;
    function AddItem(sItem: TsItem): boolean;
   function Add2Item(sItem: tsItem2): boolean;
    function AddURL(sURL: string): boolean;
    function Add2URL(set1, set2: string): boolean;
    function CloseTbls: boolean;
    function OpenTbls: boolean;
    function CreateAccessDatabase(FileName: string): string;
    function CreateDB: boolean;
    function CreateTables: boolean;
  end;

var

 Sets: TSets;
  DataModule1: TDataModule1;
    sF: array [0 .. 8] of trec = (
    (
      name: '����'; len: 255), (name: '�����'; len: 255), (name: '��������'; len: 255), (name: '�����_ ����.'; len: 255), (name: 'N'; len: 255),
    (name: 'Field5'; len: 255), (name: '�. $ � ����'; len: 255), (name: '��������'; len: 255), (name: '����'; len: 40));

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses dbUnit;

{$R *.dfm}



function TDataModule1.CloseTbls(): boolean;
begin
if not ADOConnection1.Connected then Exit;

 FormMain.Log('��������� �������...');
  QItems.Close;
  QURLs.Close;
  QURLs2.Close;
  QItems2.Close;
  ADOConnection1.Close;
end;

function TDataModule1.OpenTbls(): boolean;
var
  cnstr: string;
begin
  ADOConnection1.Close;
  cnstr := 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=' + Sets.DatabaseFileName +
  { OLE DB Services = -2; ��� �������� ���������� � ����� ����� Close }
    ';Mode=Share Deny None;Persist Security Info=False;Jet ' + 'OLEDB:System database="";Jet OLEDB:Registry Path="";Jet OLEDB:Database ' +
    'Password="";Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet ' +
    'OLEDB:Global Partial Bulk Ops=2;OLE DB Services = -2;Jet OLEDB:Global Bulk Transactions=1;Jet ' +
    'OLEDB:New Database Password="";Jet OLEDB:Create System Database=False;Jet ' +
    'OLEDB:Encrypt Database=False;Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:SFP=False';
  ADOConnection1.ConnectionString := cnstr;
  if not FileExists(Sets.DatabaseFileName) then
  begin
    FormMain.Log('���� �� �������: ' + Sets.DatabaseFileName, 2);
    CreateDB;
  end;
  FormMain.Log('��������� ����...');
  ADOConnection1.open;
  if ADOConnection1.Connected then
    if CreateTables then
    begin
      FormMain.Log('��������� �������...');
      QItems.open; { DONE : �������� �������� �� ������������� ������ }
      QURLs.open;
      QURLs2.open;
      QItems2.open;

    end;
end;

function TDataModule1.CreateAccessDatabase(FileName: string): string;
var
  cat: OLEVariant;
begin
  result := '';
  try
    cat := CreateOleObject('ADOX.Catalog');
    cat.create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + FileName + ';');
    cat := Null;
  except
    on e: Exception do
      result := e.message;
  end;
end;

function TDataModule1.CreateDB: boolean;
var
  s: string;
begin
  result := false;
  CloseTbls;
  try
    if FileExists(Sets.DatabaseFileName) then
      if MessageDlg('���� ������ ����������! ������� �� � ������� �����?', mtConfirmation, mbYesNo, 0) <> mrYes then
        exit
      else if not DeleteFile(Sets.DatabaseFileName) then { DONE 2 : �� ������� ����! �� �������� ����...?! }
      begin
        FormMain.Log('������ �������� ����� ����!' + #10 + #13 + '���������� ������� ���� ������!', 3);
        // , ������ = '+IntToStr(GetLastError)
        exit;
      end;
    FormMain.Log('������� ����: ' + Sets.DatabaseFileName);
    s := CreateAccessDatabase(Sets.DatabaseFileName);
  finally
  end;

  try
    if s = '' then
    begin
      FormMain.Log('������� ����!', 2);
      if CreateTables then
      begin
        OpenTbls;
        result := true;
      end
      else
        FormMain.Log('������ �������� ������ � ����!', 3)
    end
    else
      FormMain.Log('������ �������� ����! ' + s, 3);
  finally
  end;
end;

function TDataModule1.CreateTables: boolean;
var
  s: string;
  sTables: TStrings;
begin
  result := false;
  try
    sTables := TStringList.create;
    ADOConnection1.GetTableNames(sTables);
    // http://www.ageent.ru/sql-increment.html
    // http://www.pssuk.com/Articles/AccessDDL.htm
    // http://social.msdn.microsoft.com/Forums/en-SG/csharplanguage/thread/f004ed4a-ce78-43fb-b4f2-011a82395c57
    if sTables.IndexOf('items') < 0 then
    begin
      FormMain.Log('������� �������: items');
      s := 'CREATE TABLE items (' + 'id AUTOINCREMENT PRIMARY KEY,' + '���� VARCHAR(255),' + '����� VARCHAR(50),' + '�������� VARCHAR(50),' +
        '��������� VARCHAR(50),' + 'N VARCHAR(50),' + 'Field5 VARCHAR(50),' + '���� VARCHAR(50),' + '�������� VARCHAR(255),' + '���� DATE)';
      ADOQuery1.SQL.Text := s;
      try
        ADOQuery1.ExecSQL;
        result := true;
      finally
      end;
    end;
    // -------------------------------------
    if sTables.IndexOf('items2') < 0 then
    begin
      FormMain.Log('������� �������: items2');
      s := 'CREATE TABLE items2 (id AUTOINCREMENT PRIMARY KEY,' + 'part1 TEXT, part2 TEXT, partnumber VARCHAR(50))';
      ADOQuery1.SQL.Text := s;
      try
        ADOQuery1.ExecSQL;
        result := true;
      finally
      end;
    end;
    // -------------------------------------
    if sTables.IndexOf('urls') < 0 then
    begin
      FormMain.Log('������� �������: urls');
      s := 'CREATE TABLE urls (id AUTOINCREMENT PRIMARY KEY,' + 'url TEXT NOT NULL UNIQUE)';
      ADOQuery1.SQL.Text := s;
      try
        ADOQuery1.ExecSQL;
        result := true;
      finally
      end;
    end;
    // -------------------------------------
    if sTables.IndexOf('urls2') < 0 then
    begin
      FormMain.Log('������� �������: urls2');
      s := 'CREATE TABLE urls2 (id AUTOINCREMENT PRIMARY KEY, ' + 'set1 TEXT NOT NULL, set2 TEXT NOT NULL)';
      ADOQuery1.SQL.Text := s;
      try
        ADOQuery1.ExecSQL;
        result := true;
      finally
      end;
    end;
    result := true;
    // ========================================
  finally
    sTables.Free;
  end;
end;

function TDataModule1.AddURL(sURL: string): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text := 'INSERT INTO urls (url) VALUES (' + QuotedStr(sURL) + ')';
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;


function TDataModule1.Add2Item(sItem: tsItem2): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text := 'INSERT INTO items2 (part1, part2, partnumber)' + ' VALUES (:P1,:P2,:PN)';
    ADOQuery1.Parameters.ParseSQL(ADOQuery1.SQL.Text, true);
    ADOQuery1.Parameters.ParamByName('P1').Value := ansiQuotedStr(sItem.part1, '"');
    ADOQuery1.Parameters.ParamByName('P2').Value := ansiQuotedStr(sItem.part2, '"');
    ADOQuery1.Parameters.ParamByName('PN').Value := sItem.partnumber;
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.Add2URL(set1, set2: string): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text := 'INSERT INTO urls2 (set1, set2)' + ' VALUES (:P1,:P2)';
    // QuotedStr(set1) + QuotedStr(set2) + ')';
    ADOQuery1.Parameters.ParseSQL(ADOQuery1.SQL.Text, true);
    ADOQuery1.Parameters.ParamByName('P1').Value := ansiQuotedStr(set1, '"');
    ADOQuery1.Parameters.ParamByName('P2').Value := ansiQuotedStr(set2, '"');
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.AddItem(sItem: TsItem): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text := 'INSERT INTO items (����, �����, ��������, ���������, N, Field5, ����, ��������, ����)' +
      ' VALUES (:Foto,:Firm,:Name,:Body,:N1,:N2,:Price,:Saler,:sDate)';
    ADOQuery1.Parameters.ParseSQL(ADOQuery1.SQL.Text, true);
    ADOQuery1.Parameters.ParamByName('Foto').Value := sItem.Foto;
    ADOQuery1.Parameters.ParamByName('Firm').Value := sItem.Firm;
    ADOQuery1.Parameters.ParamByName('Name').Value := sItem.name;
    ADOQuery1.Parameters.ParamByName('Body').Value := sItem.Body;
    ADOQuery1.Parameters.ParamByName('N1').Value := sItem.N1;
    ADOQuery1.Parameters.ParamByName('N2').Value := sItem.N2;
    ADOQuery1.Parameters.ParamByName('Price').Value := sItem.Price;
    ADOQuery1.Parameters.ParamByName('Saler').Value := sItem.Saler;
    ADOQuery1.Parameters.ParamByName('sDate').Value := sItem.Date;
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.GetCountURLs(): integer;
begin
  result := -1;
  try
    ADOQuery1.SQL.Text := 'SELECT * FROM urls';
    ADOQuery1.open;
    result := ADOQuery1.RecordCount;
    ADOQuery1.Close;
    // ADOQuery1.;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.GetCount2URLs(): integer;
begin
  result := -1;
  try
    ADOQuery1.SQL.Text := 'SELECT * FROM urls2';
    ADOQuery1.open;
    result := ADOQuery1.RecordCount;
    ADOQuery1.Close;
    // ADOQuery1.;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.GetItemID(sFName, sURL: string): integer;
begin
  try
    ADOQuery1.SQL.Text := 'SELECT id FROM items WHERE '+sFName+'=' + QuotedStr(sURL);
    ADOQuery1.open;
    if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsInteger
    else
      result := -1;
    ADOQuery1.Close;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;

end;

function TDataModule1.GetItem2ID(sItem: tsItem2): integer;
begin
  try
    { ADOQuery1.SQL.Text := 'SELECT id FROM items2 WHERE part1=' + ansiQuotedStr(sItem.part1, '"') + ' AND part2=' +
      ansiQuotedStr(sItem.part2, '"') + ' AND partnumber=' + QuotedStr(sItem.partnumber); }
    ADOQuery1.SQL.Text := 'SELECT id FROM items2 WHERE partnumber=' + QuotedStr(sItem.partnumber);
    ADOQuery1.open;
    if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsInteger
    else
      result := -1;
    ADOQuery1.Close;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;

end;

function TDataModule1.GetURLs(): String;
var
  c: integer;
begin
  try
    ADOQuery1.SQL.Text := 'SELECT url FROM urls';
    ADOQuery1.open;
    c := ADOQuery1.RecordCount;
    if c > 0 then
      result := ADOQuery1.Recordset.GetString(2, c, ' ', #$D#$A, 'null')
    else
      result := '';
    ADOQuery1.Close;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.ModifyColumn(sTableName, newColumn,
  TypeCol: string): string;
begin

end;

function TDataModule1.Get2URLs(sUrls: TStrings): integer;
var
  c, i: integer; // ��������� �������: �� ��� ������ �� ������ � ���� !!
begin
  try
    // sUrls.Clear;
    ADOQuery1.SQL.Text := 'SELECT set1,set2 FROM urls2';
    ADOQuery1.open;
    c := ADOQuery1.RecordCount;
    if c > 0 then
    begin
    ADOQuery1.Recordset.MoveFirst;
      i := 0;
      while (i <= c) and (not ADOQuery1.Recordset.EOF) do
      begin
        sUrls.Add(ADOQuery1.Recordset.Fields.Item[0].Value);
        { DONE 5 : ���������!!! }
        sUrls.Add(ADOQuery1.Recordset.Fields.Item[1].Value);
        i := i + 1;
        ADOQuery1.Recordset.MoveNext;
      end;
    end; // result := ADOQuery1.Recordset.GetString(2, c, '=', #$D#$A, 'null')
    // else
    result := c;
    ADOQuery1.Close;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.GetURL(idURL: integer): string;
begin

  try
    ADOQuery1.SQL.Text := 'SELECT ���� FROM urls WHERE id=' + IntToStr(idURL);
    ADOQuery1.open;
    if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsString
    else
      result := '';
    ADOQuery1.Close;
  except
    on e: Exception do
      formmain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.GetURLID(sURL: string): integer;
begin

  try
    ADOQuery1.SQL.Text := 'SELECT id FROM urls WHERE ����=' + QuotedStr(sURL);
    ADOQuery1.open;
    if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsInteger
    else
      result := -1;
    ADOQuery1.Close;
  except
    on e: Exception do
     formmain.Log('Error sending message: ' + e.message, 3);
  end;
end;

{ TSets }

constructor TSets.Create;
begin

end;

destructor TSets.Destroy;
begin

  inherited;
end;

{ TsItem }

constructor TsItem.Create;
begin

end;

destructor TsItem.Destroy;
begin

  inherited;
end;

{ TsItem2 }

constructor TsItem2.Create;
begin

end;

destructor TsItem2.Destroy;
begin

  inherited;
end;

 //////================================================*****************
//-===================== new procedures ==============

function TDataModule1.ExecSQL(sSQL: string): string;
begin
 try
    ADOQuery1.SQL.Text := sSQL;
    ADOQuery1.ExecSQL;
   { if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsInteger
    else
      result := -1;
    ADOQuery1.Close;}
  except
    on e: Exception do
     formmain.Log('Error sending message: ' + e.message, 3);
  end;
end;



function TDataModule1.OpenTbls2(sDatabaseFileName: string): boolean;
var
  cnstr: string;
begin
result:=False;
  ADOConnection1.Close;
  cnstr := 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=' + sDatabaseFileName +
  { OLE DB Services = -2; ��� �������� ���������� � ����� ����� Close }
    ';Mode=Share Deny None;Persist Security Info=False;Jet ' + 'OLEDB:System database="";Jet OLEDB:Registry Path="";Jet OLEDB:Database ' +
    'Password="";Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet ' +
    'OLEDB:Global Partial Bulk Ops=2;OLE DB Services = -2;Jet OLEDB:Global Bulk Transactions=1;Jet ' +
    'OLEDB:New Database Password="";Jet OLEDB:Create System Database=False;Jet ' +
    'OLEDB:Encrypt Database=False;Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:SFP=False';
  ADOConnection1.ConnectionString := cnstr;
  if not FileExists(sDatabaseFileName) then
  begin
    FormMain.Log('���� �� �������: ' + sDatabaseFileName, 2);
    CreateDB2(sDatabaseFileName);
  end;
  FormMain.Log('��������� ����...');
  ADOConnection1.open;
  if ADOConnection1.Connected then
     if CreateTables2 then
      begin
      FormMain.Log('��������� �������...');
      QItems.open; { DONE : �������� �������� �� ������������� ������ }
      QURLs.open;
      QURLs2.open;
      QItems2.open;
        result := true;
      end
      else
        FormMain.Log('������ �������� ������ � ����!', 3);

end;

function TDataModule1.CopyAccessDatabase(FileName: string): string;
var
  cat: OLEVariant;
begin
  result := '';
  try
    {cat := CreateOleObject('ADOX.Catalog');
    cat.create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + FileName + ';');
    cat := Null; }
  except
    on e: Exception do
      result := e.message;
  end;
end;

function TDataModule1.CreateDB2(sDatabaseFileName: string): boolean;
var
  s: string;
begin
  result := false;
  CloseTbls;
  try         // sDatabaseFileName=Sets.sDatabaseFileName
    if FileExists(sDatabaseFileName) then
      if MessageDlg('���� ������ ����������! ������� �� � ������� �����?', mtConfirmation, mbYesNo, 0) <> mrYes then
        exit
      else if not DeleteFile(sDatabaseFileName) then { DONE 2 : �� ������� ����! �� �������� ����...?! }
      begin
        FormMain.Log('������ �������� ����� ����!' + #10 + #13 + '���������� ������� ���� ������!', 3);
        // , ������ = '+IntToStr(GetLastError)
        exit;
      end;
    FormMain.Log('������� ����: ' + sDatabaseFileName);
    s := CreateAccessDatabase(sDatabaseFileName);
  finally
  end;

  try
    if s = '' then
    begin
      FormMain.Log('������� ����!', 2);
    end
    else
      FormMain.Log('������ �������� ����! ' + s, 3);
  finally
  end;
end;

procedure TDataModule1.CreateTblItems;
begin
   if not CheckTableExist('items') then
    begin
      FormMain.Log('������� �������: items');
      ADOQuery1.SQL.Text  := 'CREATE TABLE items (' + 'id AUTOINCREMENT PRIMARY KEY,' + '���� VARCHAR(255),' + '����� VARCHAR(50),' + '�������� VARCHAR(50),' +
        '��������� VARCHAR(50),' + 'N VARCHAR(50),' + 'Field5 VARCHAR(50),' + '���� VARCHAR(50),' + '�������� VARCHAR(255),' + '���� DATE)';
      try
        ADOQuery1.ExecSQL;
       // result := true;
      finally
      end;
    end;
end;

procedure TDataModule1.CreateTblItems2;
begin
   if not CheckTableExist('items2') then
    begin
      FormMain.Log('������� �������: items2');
      ADOQuery1.SQL.Text := 'CREATE TABLE items2 (id AUTOINCREMENT PRIMARY KEY, part1 TEXT, part2 TEXT, partnumber VARCHAR(50))';
      try
        ADOQuery1.ExecSQL;
       // result := true;
      finally
      end;
    end;
end;

procedure TDataModule1.CreateTblUrls;
begin
   if not CheckTableExist('urls') then
    begin
      FormMain.Log('������� �������: urls');
      ADOQuery1.SQL.Text  := 'CREATE TABLE urls (id AUTOINCREMENT PRIMARY KEY,' + 'url TEXT NOT NULL UNIQUE)';

      try
        ADOQuery1.ExecSQL;
       // result := true;
      finally
      end;
    end;
end;


procedure TDataModule1.CreateTblUrls2;
begin
   if not CheckTableExist('urls2') then
    begin
      FormMain.Log('������� �������: urls2');
      ADOQuery1.SQL.Text := 'CREATE TABLE urls2 (id AUTOINCREMENT PRIMARY KEY, ' + 'set1 TEXT NOT NULL, set2 TEXT NOT NULL)';

      try
        ADOQuery1.ExecSQL;
       // result := true;
      finally
      end;
    end;
end;


function TDataModule1.CheckTableExist(sTableName: string): boolean;
var
  s: string;
  sTables: TStrings;
begin
  result := false;
  try
    sTables := TStringList.create;
    ADOConnection1.GetTableNames(sTables);
    result := sTables.IndexOf(sTableName) >= 0 ;
  finally
    sTables.Free;
  end;
end;

function TDataModule1.CreateTables2: boolean;
var
  s: string;
  v: integer;
begin
  result := false;
  try

    //version table
      FormMain.Log('��������� ������� ������ ��������� ��...');
    if not CheckTableExist('version')  then
    begin
      FormMain.Log('������� �������: version');
      try
       s := 'CREATE TABLE version ( iVer  INTEGER )';
      ADOQuery1.SQL.Text := s;
      ADOQuery1.ExecSQL;
      s := 'INSERT INTO  version VALUES (0)'; //������ ��������� ��������� � �������� ������� ����������
      ADOQuery1.SQL.Text := s;
        ADOQuery1.ExecSQL;
        result := true;
      finally
      end;
    end;

    v:=GetVersionDB;
    FormMain.Log('������ �������� ��:'+inttostr(v));
    if v< iDBver then
   begin
    while  v < iDBver  do
    begin
       case v of
           0: CreateTblItems;
           1: CreateTblItems2;
           2: CreateTblUrls;
           3: CreateTblUrls2;
       end;
     Inc(v);
     SetVersionDB(v);
    end;
     FormMain.Log('�������� �������� �� ���������. ������:'+inttostr(v));
   end;
    // http://www.ageent.ru/sql-increment.html
    // http://www.pssuk.com/Articles/AccessDDL.htm
    // http://social.msdn.microsoft.com/Forums/en-SG/csharplanguage/thread/f004ed4a-ce78-43fb-b4f2-011a82395c57
    result := true;
    // ========================================
  finally
  end;
end;


function TDataModule1.GetVersionDB: integer;
begin

  try
    ADOQuery1.SQL.Text := 'SELECT iVer FROM version';
    ADOQuery1.open;
    if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsInteger
    else
      result := -1;
    ADOQuery1.Close;
  except
    on e: Exception do
     formmain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDataModule1.SetVersionDB(iVer: integer): boolean;
begin
   result :=  False;
  try
    ADOQuery1.SQL.Text := 'UPDATE version  SET iVer='+IntToStr(iVer);
   result :=  ADOQuery1.ExecSQL>0;
  except
    on e: Exception do
     formmain.Log('Error sending message: ' + e.message, 3);
  end;
end;

//=======*********************************************************************
end.

