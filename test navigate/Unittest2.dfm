object Form2: TForm2
  Left = 457
  Top = 360
  Caption = 'Form2'
  ClientHeight = 451
  ClientWidth = 703
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  Visible = True
  DesignSize = (
    703
    451)
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 24
    Top = 8
    Width = 671
    Height = 21
    TabOrder = 0
    Text = 
      'http://parts.japancar.ru/?code=parts&mode=old&cl=search_partsold' +
      'ng&cl_partCode=3cvFLjAwNg_1316&cl_marka=TOYOTA'
  end
  object Button1: TButton
    Left = 447
    Top = 35
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = Button1Click
  end
  object PageControl1: TPageControl
    AlignWithMargins = True
    Left = 24
    Top = 91
    Width = 658
    Height = 344
    ActivePage = TabSheet3
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object WebBrowser1: TWebBrowser
        Left = 0
        Top = 0
        Width = 650
        Height = 316
        Align = alClient
        TabOrder = 0
        OnProgressChange = WebBrowser1ProgressChange
        ExplicitWidth = 477
        ExplicitHeight = 207
        ControlData = {
          4C0000002E430000A92000000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object StringGrid1: TStringGrid
        Left = 0
        Top = 0
        Width = 650
        Height = 316
        Align = alClient
        FixedCols = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'TabSheet3'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 650
        Height = 316
        Align = alClient
        BorderStyle = bsNone
        Lines.Strings = (
          'Memo1')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object DBGrid1: TDBGrid
        Left = 0
        Top = 0
        Width = 650
        Height = 316
        Align = alClient
        DataSource = DataModule2.DataSource1
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 37
    Width = 401
    Height = 17
    TabOrder = 3
  end
  object Button2: TButton
    Left = 24
    Top = 60
    Width = 75
    Height = 25
    Caption = 'parse'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 105
    Top = 60
    Width = 75
    Height = 25
    Caption = #1043#1072#1079#1087#1088#1086#1084
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 186
    Top = 60
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 267
    Top = 60
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 7
    OnClick = Button5Click
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 528
    Top = 40
  end
  object JvHTMLParser1: TJvHTMLParser
    Left = 576
    Top = 40
  end
  object JvLocalFileUrlGrabber1: TJvLocalFileUrlGrabber
    FileName = 'output.txt'
    Agent = 'JEDI-VCL'
    Left = 608
    Top = 40
  end
end
