object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 285
  ClientWidth = 262
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    AlignWithMargins = True
    Left = 88
    Top = 44
    Width = 75
    Height = 25
    Action = Action1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 88
    Top = 88
    Width = 75
    Height = 25
    Action = Action2
    TabOrder = 1
  end
  object Button3: TButton
    Left = 88
    Top = 136
    Width = 75
    Height = 25
    Action = Action3
    TabOrder = 2
  end
  object Button4: TButton
    Left = 88
    Top = 184
    Width = 75
    Height = 25
    Action = Action4
    TabOrder = 3
  end
  object ActionList1: TActionList
    Left = 108
    Top = 224
    object Action1: TAction
      Caption = 'Action1'
    end
    object Action2: TAction
      Caption = 'Action2'
    end
    object Action3: TAction
      Caption = #1085#1072#1089#1090#1088#1086#1081#1082#1080
      OnExecute = Action3Execute
    end
    object Action4: TAction
      Caption = #1074#1099#1093#1086#1076
      OnExecute = Action4Execute
    end
  end
end
