object DataModule2: TDataModule2
  OldCreateOrder = False
  Height = 150
  Width = 215
  object JvMemoryData: TJvMemoryData
    FieldDefs = <>
    ApplyMode = amAppend
    Left = 40
    Top = 72
  end
  object JvDataSource: TJvDataSource
    DataSet = JvMemoryData
    Left = 40
    Top = 20
  end
  object DataSource1: TDataSource
    DataSet = JvCsvDataSet1
    Left = 140
    Top = 84
  end
  object JvCsvDataSet1: TJvCsvDataSet
    FileName = 'table.csv'
    AutoBackupCount = 0
    Left = 140
    Top = 28
  end
end
