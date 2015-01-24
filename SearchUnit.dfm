object FormSearch: TFormSearch
  Left = 0
  Top = 0
  Caption = #1055#1086#1080#1089#1082
  ClientHeight = 296
  ClientWidth = 644
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 0
    Top = 120
    Width = 644
    Height = 176
    Align = alClient
    TabOrder = 0
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 644
    Height = 120
    Align = alTop
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 48
    Top = 164
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 48
    Top = 212
  end
end
