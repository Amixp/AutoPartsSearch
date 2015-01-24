object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 371
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    689
    371)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 355
    Width = 18
    Height = 13
    Caption = '000'
  end
  object ProgressBar1: TProgressBar
    Left = 60
    Top = 355
    Width = 609
    Height = 16
    TabOrder = 2
  end
  object JvFilenameEdit1: TJvFilenameEdit
    Left = 20
    Top = 8
    Width = 517
    Height = 21
    TabOrder = 0
    Text = 
      'm:\Documents\RAD Studio\Projects\SearchAutoCat\Project2\EW3SAS_W' +
      'EB_PS[3].html'
  end
  object Button1: TButton
    Left = 575
    Top = 6
    Width = 75
    Height = 25
    Caption = 'Parse'
    TabOrder = 1
    OnClick = Button1Click
  end
  object StringGrid1: TStringGrid
    Left = 20
    Top = 35
    Width = 649
    Height = 310
    Anchors = [akLeft, akTop, akRight, akBottom]
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 3
    ColWidths = (
      64
      92
      64
      64
      64)
  end
  object JvAppIniFileStorage1: TJvAppIniFileStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    FileName = 'parsetable.ini'
    DefaultSection = 'Settings'
    SubStorages = <>
    Left = 280
    Top = 208
  end
  object JvFormStorage1: TJvFormStorage
    AppStorage = JvAppIniFileStorage1
    AppStoragePath = '%FORM_NAME%\'
    StoredProps.Strings = (
      'JvFilenameEdit1.Text')
    StoredValues = <>
    Left = 256
    Top = 136
  end
end
