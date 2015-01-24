object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 158
  ClientWidth = 628
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
  object Label1: TLabel
    Left = 35
    Top = 19
    Width = 23
    Height = 13
    Caption = 'URL:'
  end
  object Label2: TLabel
    Left = 5
    Top = 48
    Width = 53
    Height = 13
    Caption = 'Target file:'
  end
  object BtnDownload: TButton
    Left = 344
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Download'
    TabOrder = 0
    OnClick = BtnDownloadClick
  end
  object BtnStop: TButton
    Left = 446
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = BtnStopClick
  end
  object Edit1: TEdit
    Left = 64
    Top = 16
    Width = 377
    Height = 21
    TabOrder = 2
    Text = 'http://download.downloadmaster.ru/dm/dmaster.exe'
  end
  object ProgressBar1: TProgressBar
    Left = 64
    Top = 80
    Width = 377
    Height = 17
    TabOrder = 3
  end
  object EdFilename: TEdit
    Left = 64
    Top = 45
    Width = 377
    Height = 21
    TabOrder = 4
    Text = 'dmaster.exe'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 139
    Width = 628
    Height = 19
    Panels = <>
    ExplicitLeft = 240
    ExplicitTop = 88
    ExplicitWidth = 0
  end
  object Button1: TButton
    Left = 8
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Delete file'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 89
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Download2'
    TabOrder = 7
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 170
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Upload'
    TabOrder = 8
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 251
    Top = 108
    Width = 75
    Height = 25
    Caption = 'Upload2'
    TabOrder = 9
    OnClick = Button4Click
  end
end
