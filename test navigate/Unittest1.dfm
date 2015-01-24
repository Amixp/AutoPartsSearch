object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 493
  ClientWidth = 875
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 32
    Top = 16
    Width = 678
    Height = 21
    TabOrder = 0
    Text = 
      'http://parts.japancar.ru/?code=parts&mode=old&cl=search_partsold' +
      'ng&cl_partCode=3cvFLjAwNg_1316&cl_marka=TOYOTA'
  end
  object BtnLoadHtml: TButton
    Left = 716
    Top = 14
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = BtnLoadHtmlClick
  end
  object JvDBGrid1: TJvDBGrid
    Left = 32
    Top = 52
    Width = 813
    Height = 214
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    SelectColumnsDialogStrings.Caption = 'Select columns'
    SelectColumnsDialogStrings.OK = '&OK'
    SelectColumnsDialogStrings.NoSelectionWarning = 'At least one column must be visible!'
    EditControls = <>
    RowsHeight = 17
    TitleRowHeight = 17
  end
  object StrGrd: TJvStringGrid
    Left = 32
    Top = 272
    Width = 813
    Height = 205
    ColCount = 11
    DefaultColWidth = 120
    FixedCols = 0
    RowCount = 11
    Options = [goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
    TabOrder = 3
    Alignment = taLeftJustify
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'Tahoma'
    FixedFont.Style = []
  end
  object CheckBox1: TCheckBox
    Left = 797
    Top = 18
    Width = 97
    Height = 17
    Caption = 'skip load'
    TabOrder = 4
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    FileName = 'H:\Documents\RAD Studio\Projects\SearchAutoCat\test1\db.xml'
    Params = <>
    Left = 12
    Top = 356
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 12
    Top = 420
  end
end
