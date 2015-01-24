unit UnitURLs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DBCtrls, ExtCtrls, StdCtrls, MainUnit, Vcl.Tabs;

type
  TFormURLs = class(TForm)
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    BtnAddURL: TButton;
    BtnAddURL2: TButton;
    BtnAddURL3: TButton;
    TabSet1: TTabSet;
    DBMemo1: TDBMemo;
    procedure BtnAddURLClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure BtnAddURL2Click(Sender: TObject);
    procedure TabSet1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    function BeautyStr(s: string; iLength: Integer): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormURLs: TFormURLs;

implementation

uses UnitDB, UnitWEB, UnitVars, UnitWEB2;

{$R *.dfm}

procedure TFormURLs.BtnAddURLClick(Sender: TObject);
var
  i: Integer;
begin
  Sets.LsURLs.Clear;
  FormWEB := TFormWEB.Create(self);
  FormWEB.WebBrowser1.Navigate(Sets.SiteURL);
  FormWEB.ShowModal;
  { if Form6.LsURLs.Count>0 then
    begin

    end; }
  FormWEB.free;
  if Sets.LsURLs.Count > 0 then
  // перенос список ссылок из формы браузера в базу
  begin
    for i := 0 to Sets.LsURLs.Count - 1 do
    begin
      if not DM.AddURL(Sets.LsURLs.Strings[i]) then
        FormMain.Log('Ошибка добавления адреса: ' + Sets.LsURLs.Strings[i], 3);
    end;
    DM.QURLs.Requery();
  end;
end;

procedure TFormURLs.BtnAddURL2Click(Sender: TObject);
var
  i: Integer;
begin
  Sets.LsURLs.Clear;
  FormWEB2 := TFormWEB2.Create(self);
  FormWEB2.WebBrowserLogin;
  FormWEB2.ShowModal;
  FormWEB2.free;
  if Sets.LsURLs.Count > 0 then
  // перенос список ссылок из формы браузера в базу
  begin
    i := 0;
    while (i < Sets.LsURLs.Count) do
    begin
      if Sets.LsURLs.Strings[i + 1] <> '' then
        if not DM.Add2URL(Sets.LsURLs.Strings[i], Sets.LsURLs.Strings[i + 1])
        then
          FormMain.Log('Ошибка добавления параметров: ' + Sets.LsURLs.Strings[i]
            + Sets.LsURLs.Strings[i + 1], 3);
      i := i + 2;
    end;
    DM.QURLs2.Requery();
  end;
end;

procedure TFormURLs.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
  s: string;
begin
  Grid := TDBGrid(Sender);
  if (Column.FieldName = DBMemo1.Field.FieldName) then
  begin
    with DBGrid1.Canvas do
    begin
      Brush.Color := clWhite;
      FillRect(Rect);
      s := VarToStrDef(Column.Field.Value, '');
      s := BeautyStr(s, Rect.Right - Rect.Left);
      TextOut(Rect.Left + 2, Rect.Top + 2, s);
    end;
  end;
end;

// Обрезание строки по длине
function TFormURLs.BeautyStr(s: string; iLength: Integer): string;
var
  bm: TBitmap;
  sResult: string;
  iStrLen: Integer;
  bAdd: Boolean;
begin
  Result := s;
  if Trim(s) = '' then
    exit;

  bAdd := false;
  sResult := Trim(s);
  bm := TBitmap.Create;
  bm.Width := 100;
  bm.Height := 100;
  iStrLen := bm.Canvas.TextWidth(sResult);
  while iStrLen > iLength do
  begin
    if Length(sResult) < 4 then
      break;

    Delete(sResult, Length(sResult) - 2, 3);
    bAdd := true;
    iStrLen := bm.Canvas.TextWidth(sResult);
  end;

  if (iStrLen <= iLength) and bAdd then
    sResult := sResult + '...';

  bm.free;
  Result := sResult;
end;

// Обрезание имени файла по длине
function CutFoldersFromFileName(s: string; iLength: Integer): string;
var
  bm: TBitmap;
  sResult: string;
  iStrLen: Integer;

  // Поменять порядок символов в строке
  function ChangeLettersOrder(s: string): string;
  var
    sResult: string;
    i: Integer;
  begin
    sResult := '';
    if Trim(s) <> '' then
      for i := Length(s) downto 1 do
        sResult := sResult + s[i];
    Result := sResult;
  end;

// Количество вхождений символа в строку
  function SymbolEntersCount(ch: char; s: string;
    bCaseInsensitive: Boolean): Integer;
  var
    i, iResult: Integer;
    cSymbol: char;

    function LoCase(ch: char): char;
    begin
      if (ch in ['A' .. 'Z', 'А' .. 'Я']) then
        Result := chr(ord(ch) + 32)
      else
        Result := ch;
    end;

  begin
    iResult := 0;
    if bCaseInsensitive then
      ch := LoCase(ch);
    if s <> '' then
      for i := 1 to Length(s) do
      begin
        cSymbol := s[i];
        if bCaseInsensitive then
          cSymbol := LoCase(cSymbol);
        if cSymbol = ch then
          inc(iResult);
      end;
    Result := iResult;
  end;

// Удалить имя последнего каталога из полного имени файла
  function DeleteLastFolderFromFileName(sFileName: string): string;
  var
    sResult, sFName: string;
  begin
    sResult := sFileName;
    if Pos('\...\', sResult) <> 0 then
      Delete(sResult, Pos('\...\', sResult), 4);
    if SymbolEntersCount('\', sResult, false) < 2 then
    begin
      Result := sFileName;
      exit;
    end;
    sResult := ChangeLettersOrder(sResult);
    sFName := ChangeLettersOrder(Copy(sResult, 1, Pos('\', sResult) - 1));
    // Взяли имя файла
    Delete(sResult, 1, Pos('\', sResult)); // Удалили имя файла
    Delete(sResult, 1, Pos('\', sResult));
    // Удалили имя каталог перед именем файла
    sResult := ChangeLettersOrder(sResult) + '\...\' + sFName;
    Result := sResult;
  end;

begin
  Result := s;
  if (Trim(s) = '') or (SymbolEntersCount('\', s, false) < 2) then
    exit;

  sResult := s;
  bm := TBitmap.Create;
  bm.Width := 100;
  bm.Height := 100;
  iStrLen := bm.Canvas.TextWidth(sResult);
  while iStrLen > iLength do
  begin
    sResult := DeleteLastFolderFromFileName(sResult);
    iStrLen := bm.Canvas.TextWidth(sResult);
    if SymbolEntersCount('\', sResult, false) < 3 then
      break;
  end;
  bm.free;
  Result := sResult;
end;

procedure TFormURLs.DBGrid1TitleClick(Column: TColumn);
begin
  Column.Width := 100; // (
  // Column.Collection.Items[0].DisplayName;
  { TODO : вычислить ширину текста для ширины колонки }
end;

procedure TFormURLs.TabSet1Change(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  case NewTab of
    0:
      begin
        DBGrid1.DataSource := DM.DSURL;
        DBNavigator1.DataSource := DM.DSURL;
        DBMemo1.DataField := '';
        DBMemo1.DataSource := DM.DSURL;
        DBMemo1.DataField := 'url';
      end;
    1:
      begin
        DBGrid1.DataSource := DM.DSQURLs2;
        DBNavigator1.DataSource := DM.DSQURLs2;
        DBMemo1.DataField := '';
        DBMemo1.DataSource := DM.DSQURLs2;
        DBMemo1.DataField := 'set2';
      end;
    2:
      begin
        DBGrid1.DataSource := DM.DSQItems2;
        DBNavigator1.DataSource := DM.DSQItems2;
        DBMemo1.DataField := '';
        DBMemo1.DataSource := DM.DSQItems2;
        DBMemo1.DataField := 'part2';
      end;
  end;
  DBGrid1.Columns.RebuildColumns;

end;

end.
