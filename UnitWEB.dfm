object FormWEB: TFormWEB
  Left = 0
  Top = 0
  Caption = #1055#1077#1088#1077#1093#1074#1072#1090' '#1089#1089#1099#1083#1086#1082' '#1085#1072' '#1079#1072#1087#1095#1072#1089#1090#1080
  ClientHeight = 394
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  WindowState = wsMaximized
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 29
    Width = 649
    Height = 259
    Align = alClient
    TabOrder = 0
    OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
    ExplicitTop = 27
    ControlData = {
      4C00000013430000C51A00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object PnURL: TPanel
    Left = 0
    Top = 288
    Width = 649
    Height = 106
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      649
      106)
    object Label1: TLabel
      Left = 4
      Top = 12
      Width = 71
      Height = 13
      Caption = #1058#1077#1082#1091#1097#1080#1081' URL:'
    end
    object EdPostURL: TEdit
      Left = 81
      Top = 8
      Width = 480
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object BtAddPostURL: TButton
      Left = 567
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = BtAddPostURLClick
    end
    object LsURLs: TListBox
      Left = 4
      Top = 35
      Width = 557
      Height = 66
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 2
      OnClick = LsURLsClick
    end
    object BtEditURL: TButton
      Left = 567
      Top = 35
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      Enabled = False
      TabOrder = 3
      OnClick = BtEditURLClick
    end
    object BtDelURL: TButton
      Left = 567
      Top = 66
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Enabled = False
      TabOrder = 4
      OnClick = BtDelURLClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 649
    Height = 29
    Align = alTop
    TabOrder = 2
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 620
      Height = 26
      Align = alClient
      Caption = 
        #1042#1074#1077#1076#1080#1090#1077' '#1074#1089#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1080#1089#1082#1072' '#1080' '#1074#1099#1087#1086#1083#1085#1080#1090#1077' '#1079#1072#1087#1088#1086#1089'. '#1055#1088#1086#1075#1088#1072#1084#1084#1072' '#1087#1077#1088#1077#1093 +
        #1074#1072#1090#1080#1090' '#1079#1072#1087#1088#1086#1089' '#1080' '#1076#1086#1073#1072#1074#1080#1090' '#1077#1075#1086' '#1074' '#1090#1077#1082#1091#1097#1080#1081' URL. '#1055#1086#1089#1083#1077' '#1084#1086#1078#1085#1086' '#1085#1072#1078#1072#1090#1100' '#1082#1085#1086 +
        #1087#1082#1091', '#1095#1090#1086#1073' '#1076#1086#1073#1072#1074#1080#1090#1100' '#1077#1075#1086' '#1074' '#1089#1087#1080#1089#1086#1082' URLs.'
      WordWrap = True
    end
  end
end
