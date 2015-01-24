object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 571
  ClientWidth = 594
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  DesignSize = (
    594
    571)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 89
    Top = 12
    Width = 276
    Height = 21
    TabOrder = 1
    Text = 'http://www.bl-recycle.jp/psnet/com/AUP1000.HTML'
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 39
    Width = 578
    Height = 338
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      object WebBrowser1: TWebBrowser
        Left = 0
        Top = 0
        Width = 570
        Height = 310
        Align = alClient
        TabOrder = 0
        OnStatusTextChange = WebBrowser1StatusTextChange
        OnDownloadBegin = WebBrowser1DownloadBegin
        OnDownloadComplete = WebBrowser1DownloadComplete
        OnTitleChange = WebBrowser1TitleChange
        OnPropertyChange = WebBrowser1PropertyChange
        OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
        ExplicitTop = 4
        ExplicitHeight = 240
        ControlData = {
          4C000000E93A00000A2000000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object Memo2: TMemo
        Left = 12
        Top = 16
        Width = 361
        Height = 213
        Lines.Strings = (
          'Memo2')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object Edit2: TEdit
    Left = 371
    Top = 12
    Width = 61
    Height = 21
    TabOrder = 3
    Text = '8297400'
  end
  object Edit3: TEdit
    Left = 438
    Top = 12
    Width = 57
    Height = 21
    TabOrder = 4
    Text = 'ps84124q'
  end
  object Edit4: TEdit
    Left = 501
    Top = 12
    Width = 57
    Height = 21
    TabOrder = 5
    Text = 'ab340u79'
  end
  object PageControl2: TPageControl
    Left = 8
    Top = 383
    Width = 582
    Height = 180
    ActivePage = TabSheet4
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 6
    object TabSheet3: TTabSheet
      Caption = 'Log'
      object sLogs: TMemo
        Left = 0
        Top = 0
        Width = 574
        Height = 152
        Align = alClient
        Lines.Strings = (
          'Memo1')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'POST DATA'
      ImageIndex = 1
      OnContextPopup = TabSheet4ContextPopup
      DesignSize = (
        574
        152)
      object Label1: TLabel
        Left = 11
        Top = 12
        Width = 19
        Height = 13
        Caption = 'URL'
      end
      object Label2: TLabel
        Left = 3
        Top = 33
        Width = 32
        Height = 13
        Caption = 'POST1'
      end
      object Label3: TLabel
        Left = 3
        Top = 100
        Width = 32
        Height = 13
        Caption = 'Cookie'
      end
      object Label4: TLabel
        Left = 3
        Top = 52
        Width = 32
        Height = 13
        Caption = 'POST2'
      end
      object edURLpost: TEdit
        Left = 36
        Top = 8
        Width = 535
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object Button2: TButton
        Left = 32
        Top = 123
        Width = 81
        Height = 25
        Caption = 'Resend post1'
        TabOrder = 1
        OnClick = Button2Click
      end
      object EdCookie: TMemo
        Left = 35
        Top = 96
        Width = 536
        Height = 21
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 2
      end
      object Button3: TButton
        Left = 220
        Top = 123
        Width = 75
        Height = 25
        Caption = 'Button3'
        TabOrder = 3
        OnClick = Button3Click
      end
      object edPost2: TEdit
        Left = 36
        Top = 52
        Width = 535
        Height = 21
        TabOrder = 4
        Text = 'edPost2'
      end
      object edPost1: TEdit
        Left = 36
        Top = 31
        Width = 535
        Height = 21
        TabOrder = 5
        Text = 'edPost1'
      end
      object Button4: TButton
        Left = 119
        Top = 123
        Width = 78
        Height = 25
        Caption = 'Resend post2'
        TabOrder = 6
        OnClick = Button4Click
      end
    end
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
    CookieManager = IdCookieManager1
    Left = 16
    Top = 232
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    UseAppManager = True
    Left = 88
    Top = 237
  end
  object IdCookieManager1: TIdCookieManager
    Left = 28
    Top = 284
  end
end
