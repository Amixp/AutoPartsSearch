object FormWEB2: TFormWEB2
  Left = 0
  Top = 0
  Caption = 'FormWEB2'
  ClientHeight = 514
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 29
    Width = 728
    Height = 379
    Align = alClient
    TabOrder = 0
    OnDownloadBegin = WebBrowser1DownloadBegin
    OnDownloadComplete = WebBrowser1DownloadComplete
    OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
    ExplicitWidth = 649
    ExplicitHeight = 259
    ControlData = {
      4C0000003E4B00002C2700000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object PnURL: TPanel
    Left = 0
    Top = 408
    Width = 728
    Height = 106
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      728
      106)
    object BtDelURL: TButton
      Left = 646
      Top = 35
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Enabled = False
      TabOrder = 0
      OnClick = BtDelURLClick
    end
    object ListView1: TListView
      Left = 4
      Top = 6
      Width = 636
      Height = 91
      Anchors = [akLeft, akTop, akRight]
      Columns = <
        item
        end
        item
        end
        item
        end>
      PopupMenu = PopupMenu1
      TabOrder = 1
      ViewStyle = vsReport
    end
    object Button1: TButton
      Left = 646
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1050
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 646
      Top = 66
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 728
    Height = 29
    Align = alTop
    TabOrder = 2
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 696
      Height = 26
      Align = alClient
      Caption = 
        #1042#1074#1077#1076#1080#1090#1077' '#1074#1089#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1080#1089#1082#1072' '#1080' '#1074#1099#1087#1086#1083#1085#1080#1090#1077' '#1079#1072#1087#1088#1086#1089'. '#1055#1088#1086#1075#1088#1072#1084#1084#1072' '#1087#1077#1088#1077#1093 +
        #1074#1072#1090#1080#1090' '#1079#1072#1087#1088#1086#1089' '#1080' '#1076#1086#1073#1072#1074#1080#1090' '#1077#1075#1086' '#1074' '#1090#1077#1082#1091#1097#1080#1081' URL. '#1055#1086#1089#1083#1077' '#1084#1086#1078#1085#1086' '#1085#1072#1078#1072#1090#1100' '#1082#1085#1086 +
        #1087#1082#1091', '#1095#1090#1086#1073' '#1076#1086#1073#1072#1074#1080#1090#1100' '#1077#1075#1086' '#1074' '#1089#1087#1080#1089#1086#1082' URLs.'
      WordWrap = True
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 232
    Top = 252
    object Insert1: TMenuItem
      Caption = 'Insert'
    end
    object Edit5: TMenuItem
      Caption = 'Edit'
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
  end
end
