unit UnitData;

interface

uses
  SysUtils, Classes, DB, JvDataSource, JvMemoryDataset, DBClient, JvCsvData;

type
  TDataModule2 = class(TDataModule)
    JvMemoryData: TJvMemoryData;
    JvDataSource: TJvDataSource;
    DataSource1: TDataSource;
    JvCsvDataSet1: TJvCsvDataSet;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule2: TDataModule2;

implementation

{$R *.dfm}

end.
