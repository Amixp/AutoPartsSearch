object FormSettings: TFormSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 368
  ClientWidth = 520
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
  object LbSize: TLabel
    Left = 391
    Top = 338
    Width = 30
    Height = 13
    Caption = 'LbSize'
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 0
    Width = 266
    Height = 140
    Caption = #1055#1086#1080#1089#1082
    TabOrder = 0
    object Label6: TLabel
      Left = 16
      Top = 45
      Width = 34
      Height = 13
      Caption = 'Period:'
    end
    object CmTime: TComboBox
      Left = 103
      Top = 42
      Width = 54
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Text = #1089#1077#1082'.'
      OnChange = CmTimeChange
      Items.Strings = (
        #1089#1077#1082'.'
        #1084#1080#1085'.'
        #1095#1072#1089#1099)
    end
    object EdTime: TEdit
      Left = 56
      Top = 42
      Width = 41
      Height = 21
      TabOrder = 1
      Text = '20'
    end
    object ChAutoUpdate: TCheckBox
      Left = 16
      Top = 22
      Width = 137
      Height = 17
      Caption = #1055#1086#1089#1090#1086#1103#1085#1085#1099#1081' '#1087#1086#1080#1089#1082
      TabOrder = 2
    end
    object ChAutoStartSearch: TCheckBox
      Left = 20
      Top = 69
      Width = 165
      Height = 20
      Caption = #1057#1090#1072#1088#1090' '#1087#1086#1080#1089#1082#1072' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077
      TabOrder = 3
    end
    object ChAutoStartApp: TCheckBox
      Left = 20
      Top = 95
      Width = 243
      Height = 17
      Caption = #1057#1090#1072#1088#1090' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1087#1088#1080' '#1079#1072#1075#1088#1091#1079#1082#1077' Windows'
      Enabled = False
      TabOrder = 4
      OnClick = ChAutoStartAppClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 272
    Top = 0
    Width = 246
    Height = 268
    Caption = 'Alarms'
    TabOrder = 1
    object Label1: TLabel
      Left = 39
      Top = 71
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = #1054#1090' '#1082#1086#1075#1086':'
    end
    object Label2: TLabel
      Left = 15
      Top = 98
      Width = 68
      Height = 13
      Alignment = taRightJustify
      Caption = 'SMTP '#1089#1077#1088#1074#1077#1088':'
    end
    object Label3: TLabel
      Left = 7
      Top = 123
      Width = 76
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
    end
    object Label4: TLabel
      Left = 42
      Top = 152
      Width = 41
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1072#1088#1086#1083#1100':'
    end
    object Label5: TLabel
      Left = 10
      Top = 179
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1086#1088#1090' '#1089#1077#1088#1074#1077#1088#1072':'
    end
    object Label8: TLabel
      Left = 54
      Top = 44
      Width = 29
      Height = 13
      Alignment = taRightJustify
      Caption = #1050#1086#1084#1091':'
    end
    object EdSender: TEdit
      Left = 89
      Top = 68
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object EdSMTPHost: TEdit
      Left = 89
      Top = 95
      Width = 121
      Height = 21
      TabOrder = 1
    end
    object EdMailPass: TEdit
      Left = 89
      Top = 149
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
    end
    object ChSendMail: TCheckBox
      Left = 12
      Top = 18
      Width = 177
      Height = 17
      Caption = #1055#1086#1089#1099#1083#1072#1090#1100' '#1086#1090#1095#1077#1090#1099' '#1085#1072' e-mail'
      TabOrder = 3
    end
    object EdMailLogin: TEdit
      Left = 89
      Top = 122
      Width = 121
      Height = 21
      TabOrder = 4
    end
    object BtTestMail: TButton
      Left = 69
      Top = 208
      Width = 116
      Height = 25
      Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '#1087#1086#1095#1090#1091
      TabOrder = 5
      OnClick = BtTestMailClick
    end
    object edSMTPport: TEdit
      Left = 89
      Top = 176
      Width = 32
      Height = 21
      TabOrder = 6
      Text = '25'
    end
    object ChSSL: TCheckBox
      Left = 127
      Top = 176
      Width = 110
      Height = 17
      Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' SSL'
      TabOrder = 7
    end
    object StaticText1: TStaticText
      Left = 11
      Top = 239
      Width = 222
      Height = 17
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = '...'
      TabOrder = 8
    end
    object EdRecipients: TEdit
      Left = 89
      Top = 41
      Width = 121
      Height = 21
      TabOrder = 9
    end
  end
  object Button1: TButton
    Left = 438
    Top = 335
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 11
    TabOrder = 2
    OnClick = Button1Click
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 146
    Width = 266
    Height = 87
    Caption = #1042#1080#1076
    TabOrder = 3
    object ChAutoHide: TCheckBox
      Left = 16
      Top = 16
      Width = 177
      Height = 17
      Caption = #1057#1082#1088#1099#1090#1100' '#1086#1082#1085#1086' '#1087#1086#1080#1089#1082#1072
      TabOrder = 0
    end
    object ChDebuglog: TCheckBox
      Left = 16
      Top = 39
      Width = 97
      Height = 17
      Caption = 'Debug log'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object ChEventslog: TCheckBox
      Left = 16
      Top = 62
      Width = 97
      Height = 17
      Caption = 'Events log'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object GroupBox4: TGroupBox
    Left = 0
    Top = 239
    Width = 266
    Height = 92
    Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
    TabOrder = 4
    object BtDBcreate: TButton
      Left = 16
      Top = 52
      Width = 105
      Height = 25
      Caption = #1085#1086#1074#1072#1103' '#1041#1044
      TabOrder = 0
      OnClick = BtDBcreateClick
    end
    object BtnShowDB: TButton
      Left = 16
      Top = 21
      Width = 105
      Height = 25
      Caption = #1057#1087#1080#1089#1086#1082' '#1079#1072#1087#1095#1072#1089#1090#1077#1081
      TabOrder = 1
      OnClick = BtnShowDBClick
    end
  end
  object chkUpdateApp: TCheckBox
    Left = 12
    Top = 337
    Width = 145
    Height = 17
    Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
    TabOrder = 5
  end
  object btUpdate: TButton
    Left = 157
    Top = 335
    Width = 75
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 6
    OnClick = btUpdateClick
  end
  object ProgressBar1: TProgressBar
    Left = 238
    Top = 339
    Width = 147
    Height = 17
    TabOrder = 7
  end
  object JvFormStorage1: TJvFormStorage
    AppStorage = FormMain.JvAppXMLFileStorage1
    AppStoragePath = '%FORM_NAME%\'
    Options = [fpState, fpLocation]
    StoredProps.Strings = (
      'ChSendMail.Checked'
      'ChAutoHide.Checked'
      'ChAutoUpdate.Checked'
      'ChSSL.Checked'
      'CmTime.Text'
      'EdMailLogin.Text'
      'EdMailPass.Text'
      'EdRecipients.Text'
      'EdSender.Text'
      'EdSMTPHost.Text'
      'edSMTPport.Text'
      'EdTime.Text'
      'ChEventslog.Checked'
      'ChDebuglog.Checked'
      'chkUpdateApp.Checked'
      'ChAutoStartApp.Checked'
      'ChAutoStartSearch.Checked')
    StoredValues = <>
    Left = 209
    Top = 251
  end
end
