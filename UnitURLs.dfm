object FormURLs: TFormURLs
  Left = 0
  Top = 0
  Caption = #1057#1087#1080#1089#1086#1082' '#1089#1089#1099#1083#1086#1082' '#1085#1072' '#1079#1072#1087#1095#1072#1089#1090#1080
  ClientHeight = 266
  ClientWidth = 645
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 645
    Height = 53
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object DBNavigator1: TDBNavigator
      Left = 12
      Top = 14
      Width = 240
      Height = 25
      DataSource = DM.DSURL
      Flat = True
      TabOrder = 0
    end
    object BtnAddURL: TButton
      Left = 282
      Top = 15
      Width = 113
      Height = 25
      Caption = '+ '#1089#1089#1099#1083#1082#1080' JapanCar'
      TabOrder = 1
      OnClick = BtnAddURLClick
    end
    object BtnAddURL2: TButton
      Left = 401
      Top = 15
      Width = 97
      Height = 25
      Caption = '+ '#1089#1089#1099#1083#1082#1080' PS-NET'
      TabOrder = 2
      OnClick = BtnAddURL2Click
    end
    object BtnAddURL3: TButton
      Left = 504
      Top = 15
      Width = 97
      Height = 25
      Caption = '+ '#1089#1089#1099#1083#1082#1080
      TabOrder = 3
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 73
    Width = 645
    Height = 172
    Align = alClient
    DataSource = DM.DSURL
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDrawColumnCell = DBGrid1DrawColumnCell
    OnTitleClick = DBGrid1TitleClick
    Columns = <
      item
        Expanded = False
        FieldName = 'id'
        Width = 29
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'url'
        Width = 120
        Visible = True
      end>
  end
  object TabSet1: TTabSet
    Left = 0
    Top = 245
    Width = 645
    Height = 21
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Style = tsModernTabs
    Tabs.Strings = (
      'JapanCar'
      'PS-NET'
      'catalog')
    TabIndex = 0
    OnChange = TabSet1Change
    ExplicitTop = 244
  end
  object DBMemo1: TDBMemo
    Left = 0
    Top = 53
    Width = 645
    Height = 20
    Align = alTop
    DataField = 'url'
    DataSource = DM.DSURL
    TabOrder = 3
  end
end
