object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 40
    Top = 24
    Width = 96
    Height = 13
    Caption = 'Database file name:'
  end
  object btnOpenDB: TButton
    Left = 40
    Top = 72
    Width = 75
    Height = 25
    Caption = 'btnOpenDB'
    TabOrder = 0
    OnClick = btnOpenDBClick
  end
  object sEditDBfile: TEdit
    Left = 40
    Top = 45
    Width = 113
    Height = 21
    TabOrder = 1
    Text = 'DB1.mdb'
    TextHint = 'dataase file name (*.mdb)'
  end
  object lstLog: TListBox
    Left = 0
    Top = 120
    Width = 554
    Height = 170
    Align = alBottom
    ItemHeight = 13
    TabOrder = 2
  end
end
