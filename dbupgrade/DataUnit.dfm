object DataModule1: TDataModule1
  OldCreateOrder = False
  Height = 266
  Width = 610
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 44
    Top = 112
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=P:\Do' +
      'cuments\RAD Studio\Projects\SearchAutoCat\Database.mdb;Mode=Shar' +
      'e Deny None;Persist Security Info=False;Jet OLEDB:System databas' +
      'e="";Jet OLEDB:Registry Path="";Jet OLEDB:Database Password="";J' +
      'et OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet OLE' +
      'DB:Global Partial Bulk Ops=2;Jet OLEDB:Global Bulk Transactions=' +
      '1;Jet OLEDB:New Database Password="";Jet OLEDB:Create System Dat' +
      'abase=False;Jet OLEDB:Encrypt Database=False;Jet OLEDB:Don'#39't Cop' +
      'y Locale on Compact=False;Jet OLEDB:Compact Without Replica Repa' +
      'ir=False;Jet OLEDB:SFP=False;'
    LoginPrompt = False
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 44
    Top = 4
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 40
    Top = 60
  end
  object DSItems: TDataSource
    DataSet = QItems
    Left = 96
    Top = 112
  end
  object QItems: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from items')
    Left = 96
    Top = 60
    object QItemsid: TAutoIncField
      FieldName = 'id'
      ReadOnly = True
    end
    object QItemsфото: TWideStringField
      FieldName = #1092#1086#1090#1086
      Size = 50
    end
    object QItemsфирма: TWideStringField
      FieldName = #1092#1080#1088#1084#1072
      Size = 50
    end
    object QItemsназвание: TWideStringField
      FieldName = #1085#1072#1079#1074#1072#1085#1080#1077
      Size = 50
    end
    object QItemsкузовдвиг: TWideStringField
      FieldName = #1082#1091#1079#1086#1074#1076#1074#1080#1075
      Size = 50
    end
    object QItemsN: TWideStringField
      FieldName = 'N'
      Size = 50
    end
    object QItemsField5: TWideStringField
      FieldName = 'Field5'
      Size = 50
    end
    object QItemsцена: TWideStringField
      FieldName = #1094#1077#1085#1072
      Size = 50
    end
    object QItemsпродавец: TWideStringField
      FieldName = #1087#1088#1086#1076#1072#1074#1077#1094
      Size = 50
    end
    object QItemsдата: TDateTimeField
      FieldName = #1076#1072#1090#1072
    end
  end
  object DSURL: TDataSource
    DataSet = QURLs
    Left = 148
    Top = 112
  end
  object QURLs: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from urls')
    Left = 148
    Top = 60
    object QURLsid: TAutoIncField
      FieldName = 'id'
      ReadOnly = True
    end
    object QURLsurl: TWideMemoField
      FieldName = 'url'
      BlobType = ftWideMemo
    end
  end
  object DSQItems2: TDataSource
    DataSet = QItems2
    Left = 216
    Top = 112
  end
  object QItems2: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from items2')
    Left = 216
    Top = 60
    object QItems2id: TAutoIncField
      FieldName = 'id'
      ReadOnly = True
    end
    object QItems2part1: TWideMemoField
      FieldName = 'part1'
      BlobType = ftWideMemo
    end
    object QItems2part2: TWideMemoField
      FieldName = 'part2'
      BlobType = ftWideMemo
    end
    object QItems2partnumber: TWideStringField
      FieldName = 'partnumber'
      Size = 50
    end
  end
  object DSQURLs2: TDataSource
    DataSet = QURLs2
    Left = 276
    Top = 112
  end
  object QURLs2: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from urls2')
    Left = 276
    Top = 60
    object QURLs2id: TAutoIncField
      FieldName = 'id'
      ReadOnly = True
    end
    object QURLs2set1: TWideMemoField
      FieldName = 'set1'
      BlobType = ftWideMemo
    end
    object QURLs2set2: TWideMemoField
      FieldName = 'set2'
      BlobType = ftWideMemo
    end
  end
end
