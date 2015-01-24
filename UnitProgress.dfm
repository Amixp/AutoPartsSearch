object FormProgress: TFormProgress
  Left = 0
  Top = 0
  Caption = #1055#1086#1080#1089#1082'...'
  ClientHeight = 95
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 337
    Height = 24
    Align = alTop
    Alignment = taCenter
    Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1076#1072#1085#1085#1099#1093' '#1089' '#1080#1085#1090#1077#1088#1085#1077#1090#1072'...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 304
  end
  object LbCount: TLabel
    Left = 320
    Top = 71
    Width = 9
    Height = 19
    BiDiMode = bdRightToLeft
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
  end
  object BtCancel: TButton
    Left = 128
    Top = 65
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 30
    Width = 321
    Height = 29
    TabOrder = 1
  end
end
