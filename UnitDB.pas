unit UnitDB;

interface

uses
  SysUtils, comobj, ADODB, DB, controls, UnitVars, variants, Dialogs,
  Classes;

type
  trec = record
    name: string;
    len: integer;
  end;

type
  TDM = class(TDataModule)
    DataSource1: TDataSource;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    DSItems: TDataSource;
    QItems: TADOQuery;
    DSURL: TDataSource;
    QURLs: TADOQuery;
    DSQItems2: TDataSource;
    QItems2: TADOQuery;
    DSQURLs2: TDataSource;
    QURLs2: TADOQuery;
    QItemsid: TAutoIncField;
    QItemsфото: TWideStringField;
    QItemsфирма: TWideStringField;
    QItemsназвание: TWideStringField;
    QItemsкузовдвиг: TWideStringField;
    QItemsN: TWideStringField;
    QItemsField5: TWideStringField;
    QItemsцена: TWideStringField;
    QItemsпродавец: TWideStringField;
    QItemsдата: TDateTimeField;
    QURLsid: TAutoIncField;
    QURLsurl: TWideMemoField;
    QItems2id: TAutoIncField;
    QItems2part1: TWideMemoField;
    QItems2part2: TWideMemoField;
    QItems2partnumber: TWideStringField;
    QURLs2id: TAutoIncField;
    QURLs2set1: TWideMemoField;
    QURLs2set2: TWideMemoField;
    QItemsотправлено: TBooleanField;
    QItems2отправлено: TBooleanField;
    ds1: TDataSource;
    qry1: TADOQuery;
    procedure ADOConnection1BeforeConnect(Sender: TObject);
  private

    { Private declarations }
  public
    procedure SetSendItems(sTable: string);
    function GetDoSendItems(sTable: string): _Recordset;
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
    { Public declarations }
  end;

var
  DM: TDM;
  sF: array [0 .. 8] of trec = (
    (
      name: 'KeySearch'; len: 50), (name: 'фото'; len: 255), (name: 'фирма';
    len: 255), (name: 'название'; len: 255), (name: 'кузов_ двиг.'; len: 255),
    (name: 'N'; len: 255), (name: 'Р. $ € цена'; len: 255), (name: 'продавец';
    len: 255), (name: 'дата'; len: 40));

  // TODO Замена поля Field5 на KeySearch
implementation

uses settings, MainUnit;

{$R *.dfm}

function TDM.CloseTbls(): boolean;
begin
  FormMain.Log('Закрываем таблицы...');
  QItems.Close;
  QURLs.Close;
  QURLs2.Close;
  QItems2.Close;
  ADOConnection1.Close;
end;

function TDM.OpenTbls(): boolean;
var
  cnstr: string;
begin
  ADOConnection1.Close;
  cnstr := 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=' +
    Sets.DatabaseFileName +
  { OLE DB Services = -2; Для закрытия соединения с базой после Close }
    ';Mode=Share Deny None;Persist Security Info=False;Jet ' +
    'OLEDB:System database="";Jet OLEDB:Registry Path="";Jet OLEDB:Database ' +
    'Password="";Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet '
    + 'OLEDB:Global Partial Bulk Ops=2;OLE DB Services = -2;Jet OLEDB:Global Bulk Transactions=1;Jet '
    + 'OLEDB:New Database Password="";Jet OLEDB:Create System Database=False;Jet '
    + 'OLEDB:Encrypt Database=False;Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:SFP=False';
  ADOConnection1.ConnectionString := cnstr;
  if not FileExists(Sets.DatabaseFileName) then
  begin
    FormMain.Log('База не найдена: ' + Sets.DatabaseFileName, 2);
    CreateDB;
  end;
  FormMain.Log('Открываем базу...');
  ADOConnection1.open;
  if ADOConnection1.Connected then
    if CreateTables then
    begin
      FormMain.Log('Открываем таблицы...');
      QItems.open; { DONE : Добавить проверку на существование таблиц }
      QURLs.open;
      QURLs2.open;
      QItems2.open;

    end;
end;

function TDM.CreateAccessDatabase(FileName: string): string;
var
  cat: OLEVariant;
begin
  result := '';
  try
    cat := CreateOleObject('ADOX.Catalog');
    cat.create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' +
      FileName + ';');
    cat := Null;
  except
    on e: Exception do
      result := e.message;
  end;
end;

function TDM.CreateDB: boolean;
var
  s: string;
begin
  result := false;
  CloseTbls;
  try
    if FileExists(Sets.DatabaseFileName) then
      if MessageDlg('База данных существует! Удалить ее и создать новую?',
        mtConfirmation, mbYesNo, 0) <> mrYes then
        exit
      else if not DeleteFile(Sets.DatabaseFileName)
      then { DONE 2 : Не удаляет файл! Не закрытая база...?! }
      begin
        FormMain.Log('Ошибка удаления файла базы!' + #10 + #13 +
          'Невозможно создать базу данных!', 3);
        // , ошибка = '+IntToStr(GetLastError)
        exit;
      end;
    FormMain.Log('Создаем базу: ' + Sets.DatabaseFileName);
    s := CreateAccessDatabase(Sets.DatabaseFileName);
  finally
  end;

  try
    if s = '' then
    begin
      FormMain.Log('Создали базу!', 2);
      if CreateTables then
      begin
        OpenTbls;
        result := true;
      end
      else
        FormMain.Log('Ошибка создания таблиц в базе!', 3)
    end
    else
      FormMain.Log('Ошибка создания базы! ' + s, 3);
  finally
  end;
end;

function TDM.CreateTables: boolean;
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
      FormMain.Log('Создаем таблицу: items');
      s := 'CREATE TABLE items (' + 'id AUTOINCREMENT PRIMARY KEY,' +
        'фото VARCHAR(255),' + 'фирма VARCHAR(50),' + 'название VARCHAR(50),' +
        'кузовдвиг VARCHAR(50),' + 'N VARCHAR(50),' + 'Field5 VARCHAR(50),' +
        'цена VARCHAR(50),' + 'продавец VARCHAR(255),' + 'дата DATE,' +
        'отправлено BIT)';
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
      FormMain.Log('Создаем таблицу: items2');
      s := 'CREATE TABLE items2 (id AUTOINCREMENT PRIMARY KEY,' +
        'part1 TEXT, part2 TEXT, partnumber VARCHAR(50),' + 'отправлено BIT)';
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
      FormMain.Log('Создаем таблицу: urls');
      s := 'CREATE TABLE urls (id AUTOINCREMENT PRIMARY KEY,' +
        'url TEXT NOT NULL UNIQUE)';
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
      FormMain.Log('Создаем таблицу: urls2');
      s := 'CREATE TABLE urls2 (id AUTOINCREMENT PRIMARY KEY, ' +
        'set1 TEXT NOT NULL, set2 TEXT NOT NULL)';
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

function TDM.AddURL(sURL: string): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text := 'INSERT INTO urls (url) VALUES (' +
      QuotedStr(sURL) + ')';
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

procedure TDM.ADOConnection1BeforeConnect(Sender: TObject);
begin
  //
end;

function TDM.Add2Item(sItem: tsItem2): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text :=
      'INSERT INTO items2 (part1, part2, partnumber,отправлено)' +
      ' VALUES (:P1,:P2,:PN,:Sended)';
    ADOQuery1.Parameters.ParseSQL(ADOQuery1.SQL.Text, true);
    ADOQuery1.Parameters.ParamByName('P1').Value :=
      ansiQuotedStr(sItem.part1, '"');
    ADOQuery1.Parameters.ParamByName('P2').Value :=
      ansiQuotedStr(sItem.part2, '"');
    ADOQuery1.Parameters.ParamByName('PN').Value := sItem.partnumber;
    ADOQuery1.Parameters.ParamByName('Sended').Value := false;
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDM.Add2URL(set1, set2: string): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text := 'INSERT INTO urls2 (set1, set2)' +
      ' VALUES (:P1,:P2)';
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

function TDM.AddItem(sItem: TsItem): boolean;
begin
  result := false;
  try
    ADOQuery1.SQL.Text :=
      'INSERT INTO items (фото, фирма, название, кузовдвиг, N, Field5, цена, продавец, дата,отправлено)'
      + ' VALUES (:Foto,:Firm,:Name,:Body,:N1,:N2,:Price,:Saler,:sDate,:Sended)';
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
    ADOQuery1.Parameters.ParamByName('Sended').Value := false;
    ADOQuery1.ExecSQL;
    result := true;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDM.GetCountURLs(): integer;
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

function TDM.GetCount2URLs(): integer;
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

function TDM.GetItemID(sFName, sURL: string): integer;
begin
  try
    ADOQuery1.SQL.Text := 'SELECT id FROM items WHERE ' + sFName + '=' +
      QuotedStr(sURL);
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

function TDM.GetItem2ID(sItem: tsItem2): integer;
begin
  try
    { ADOQuery1.SQL.Text := 'SELECT id FROM items2 WHERE part1=' + ansiQuotedStr(sItem.part1, '"') + ' AND part2=' +
      ansiQuotedStr(sItem.part2, '"') + ' AND partnumber=' + QuotedStr(sItem.partnumber); }
    ADOQuery1.SQL.Text := 'SELECT id FROM items2 WHERE partnumber=' +
      QuotedStr(sItem.partnumber);
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

function TDM.GetURLs(): String;
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

function TDM.GetDoSendItems(sTable: string): _Recordset;
var
  c, i: integer; // результат функции: по две строки на запись в базе !!
begin
  try
    qry1.SQL.Text := 'SELECT * from ' + sTable + ' where отправлено=False';
    qry1.open;
    c := qry1.RecordCount;
    // if c > 0 then
    result := qry1.Recordset; // .GetString(2, c, ' ', #$D#$A, 'null')
    /// /else
    /// result := '';
    qry1.Close;
  except
    on e: Exception do
      FormMain.Log('Error get not sended items: ' + e.message, 3);
  end;
end;

procedure TDM.SetSendItems(sTable: string);
begin
  try
    qry1.SQL.Text := 'UPDATE ' + sTable +
      ' SET отправлено=true where отправлено=False';
    qry1.ExecSQL;
    // c := qry1.RecordCount;
    // if c > 0 then
    // result := qry1.Recordset;//.GetString(2, c, ' ', #$D#$A, 'null')
    /// /else
    /// result := '';
    qry1.Close;
  except
    on e: Exception do
      FormMain.Log('Error set not sended items: ' + e.message, 3);
  end;
end;

function TDM.Get2URLs(sUrls: TStrings): integer;
var
  c, i: integer; // результат функции: по две строки на запись в базе !!
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
        sUrls.Add(VarToStrDef(ADOQuery1.Recordset.Fields.Item[0].Value,
          'null'));
        { DONE 5 : Проверить!!! }
        sUrls.Add(VarToStrDef(ADOQuery1.Recordset.Fields.Item[1].Value,
          'null'));
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

function TDM.GetURL(idURL: integer): string;
begin

  try
    ADOQuery1.SQL.Text := 'SELECT фото FROM urls WHERE id=' + IntToStr(idURL);
    ADOQuery1.open;
    if ADOQuery1.RecordCount > 0 then
      result := ADOQuery1.Fields[0].AsString
    else
      result := '';
    ADOQuery1.Close;
  except
    on e: Exception do
      FormMain.Log('Error sending message: ' + e.message, 3);
  end;
end;

function TDM.GetURLID(sURL: string): integer;
begin

  try
    ADOQuery1.SQL.Text := 'SELECT id FROM urls WHERE фото=' + QuotedStr(sURL);
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

end.
