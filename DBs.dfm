object FormDB: TFormDB
  Left = 0
  Top = 0
  Caption = #1057#1087#1080#1089#1086#1082' '#1080#1079#1074#1077#1089#1090#1085#1099#1093' '#1079#1072#1087#1095#1072#1089#1090#1077#1081
  ClientHeight = 264
  ClientWidth = 718
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
    Width = 718
    Height = 53
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object DBNavigator1: TDBNavigator
      Left = 12
      Top = 14
      Width = 240
      Height = 25
      DataSource = DM.DSItems
      Flat = True
      TabOrder = 0
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 94
    Width = 718
    Height = 149
    Align = alClient
    DataSource = DM.DSItems
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnTitleClick = DBGrid1TitleClick
    Columns = <
      item
        Expanded = False
        FieldName = 'id'
        Width = 26
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1092#1086#1090#1086
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1092#1080#1088#1084#1072
        Width = 81
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1085#1072#1079#1074#1072#1085#1080#1077
        Width = 96
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1082#1091#1079#1086#1074#1076#1074#1080#1075
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'N'
        Width = 32
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Field5'
        Width = 37
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1094#1077#1085#1072
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1087#1088#1086#1076#1072#1074#1077#1094
        Width = 76
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1076#1072#1090#1072
        Width = 76
        Visible = True
      end
      item
        Expanded = False
        FieldName = #1086#1090#1087#1088#1072#1074#1083#1077#1085#1086
        Visible = True
      end>
  end
  object TabSet1: TTabSet
    Left = 0
    Top = 243
    Width = 718
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
  end
  object Panel2: TPanel
    Left = 0
    Top = 74
    Width = 718
    Height = 20
    Align = alTop
    Caption = 'Panel2'
    TabOrder = 3
    object ComboBox1: TComboBox
      Left = 572
      Top = 1
      Width = 145
      Height = 21
      Align = alRight
      TabOrder = 0
      Text = 'ComboBox1'
      OnChange = ComboBox1Change
    end
    object DBMemo1: TDBMemo
      Left = 1
      Top = 1
      Width = 571
      Height = 18
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 1
      WantReturns = False
    end
  end
  object edSearch: TEdit
    Left = 0
    Top = 53
    Width = 718
    Height = 21
    Align = alTop
    TabOrder = 4
    Text = #1089#1090#1088#1086#1082#1072' '#1087#1086#1080#1089#1082#1072
    OnChange = edSearchChange
    OnEnter = edSearchEnter
    ExplicitLeft = -8
    ExplicitTop = 66
  end
end
