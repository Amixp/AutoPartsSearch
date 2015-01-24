unit DBs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, ExtCtrls, DBCtrls, Vcl.Tabs, Vcl.StdCtrls;

type
  TFormDB = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    TabSet1: TTabSet;
    DBMemo1: TDBMemo;
    ComboBox1: TComboBox;
    Panel2: TPanel;
    edSearch: TEdit;
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure TabSet1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure ComboBox1Change(Sender: TObject);
    procedure edSearchEnter(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
  private
    procedure SetTableFilter(parms: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDB: TFormDB;

implementation

uses UnitDB;

{$R *.dfm}

procedure TFormDB.ComboBox1Change(Sender: TObject);
begin
  { TODO : добавить ниницитализацию при первом открытии формы }
  DBMemo1.DataField := '';
  // DBMemo1.DataSource  := DM.DSQURLs2;
  try
    DBMemo1.DataField := ComboBox1.Text;
  finally

  end;

end;

procedure TFormDB.DBGrid1TitleClick(Column: TColumn);
begin
  Column.Width := 100; // (
  // Column.Collection.Items[0].DisplayName;
  { TODO : вычислить ширину текста для ширины колонки }
end;

procedure TFormDB.edSearchChange(Sender: TObject);
begin
  SetTableFilter(edSearch.Text);
end;

procedure TFormDB.edSearchEnter(Sender: TObject);
begin
  if edSearch.Text = 'строка поиска' then
    edSearch.Text := '';

end;

procedure TFormDB.SetTableFilter(parms: string);
begin
  with DBGrid1.DataSource.DataSet do
  begin
    Filtered := False;
    if edSearch.Text <> '' then
    begin
      Filter := 'Field5 LIKE  ' + QuotedStr(parms + '%') + ' OR ' + 'N LIKE ' +
        QuotedStr(parms + '%');
      Filtered := True;
    end;
  end;

end;

procedure TFormDB.TabSet1Change(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  case NewTab of
    0:
      begin
        DBGrid1.DataSource := DM.DSItems;
        DBNavigator1.DataSource := DM.DSItems;
        ComboBox1.Items.Text := DM.DSItems.DataSet.FieldList.Text;
        DBMemo1.DataField := '';
        DBMemo1.DataSource := DM.DSItems;
      end;
    1:
      begin
        DBGrid1.DataSource := DM.DSQItems2;
        DBNavigator1.DataSource := DM.DSQItems2;
        ComboBox1.Items.Text := DM.DSQItems2.DataSet.FieldList.Text;
        DBMemo1.DataField := '';
        DBMemo1.DataSource := DM.DSQItems2;
      end;
    2:
      begin
        DBGrid1.DataSource := DM.DSQItems2;
        DBNavigator1.DataSource := DM.DSQItems2;
        ComboBox1.Items.Text := DM.DSQItems2.DataSet.FieldList.Text;
        DBMemo1.DataField := '';
        DBMemo1.DataSource := DM.DSQItems2;
      end;
  end;
  DBGrid1.Columns.RebuildColumns;
end;

end.
