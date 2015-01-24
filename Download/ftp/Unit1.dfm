object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 294
  ClientWidth = 562
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
    Left = 216
    Top = 127
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 216
    Top = 146
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 216
    Top = 177
    Width = 37
    Height = 16
    AutoSize = False
    Caption = 'Label3'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 207
    Top = 16
    Width = 185
    Height = 105
    Caption = 'GroupBox1'
    TabOrder = 0
  end
  object GroupBox3: TGroupBox
    Left = 16
    Top = 16
    Width = 185
    Height = 105
    Caption = 'GroupBox3'
    TabOrder = 1
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 127
    Width = 185
    Height = 105
    Caption = 'GroupBox2'
    TabOrder = 2
  end
  object Button1: TButton
    Left = 8
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Upload'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 173
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Pause'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 254
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Unpause'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 344
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Terminate'
    TabOrder = 6
    OnClick = Button4Click
  end
  object ProgressBar1: TProgressBar
    Left = 216
    Top = 223
    Width = 281
    Height = 17
    TabOrder = 7
  end
  object Button5: TButton
    Left = 89
    Top = 261
    Width = 75
    Height = 25
    Caption = 'Download'
    TabOrder = 8
    OnClick = Button5Click
  end
end
