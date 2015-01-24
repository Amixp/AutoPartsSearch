object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 465
  ClientWidth = 644
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 340
    Width = 644
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    ExplicitTop = 0
    ExplicitWidth = 343
  end
  object Button1: TButton
    Left = 0
    Top = 440
    Width = 644
    Height = 25
    Align = alBottom
    Caption = 'START'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 644
    Height = 340
    ActivePage = TabSheet4
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 636
        Height = 312
        Align = alClient
        Lines.Strings = (
          'Memo1')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object StringGrid1: TStringGrid
        Left = 0
        Top = 0
        Width = 636
        Height = 312
        Align = alClient
        FixedCols = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
        TabOrder = 0
        ColWidths = (
          108
          101
          107
          83
          64)
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'TabSheet3'
      ImageIndex = 2
      object ListBox1: TListBox
        Left = 0
        Top = 0
        Width = 636
        Height = 165
        Align = alTop
        ItemHeight = 13
        Items.Strings = (
          
            'AD3000M=-1&AD3000=2000&AD3500M=-1&AD3010M=0&AD3010=2017&AD3530M=' +
            '-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD5510M=0&E_WORKID=ID1410&ORDE' +
            'R01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020' +
            'B&ORDER03D=1&CHARGE=0'
          
            'AD3000M=-1&AD3000=1000&AD3500M=-1&AD3010M=0&AD3010=1010&AD3530M=' +
            '-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD4100M=0&E_WORKID=ID1410&ORDE' +
            'R01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020' +
            'B&ORDER03D=1&CHARGE=0'
          
            'AD3000M=-1&AD3000=2000&AD3500M=-1&AD3010M=0&AD3010=2040&AD3530M=' +
            '-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD5510M=0&E_WORKID=ID1410&ORDE' +
            'R01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020' +
            'B&ORDER03D=1&CHARGE=0'
          
            'AD3000M=-1&AD3000=2000&AD3500M=-1&AD3010M=0&AD3010=2013&AD3530M=' +
            '-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD5510M=0&E_WORKID=ID1410&ORDE' +
            'R01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020' +
            'B&ORDER03D=1&CHARGE=0')
        TabOrder = 0
      end
      object ListPArts: TListBox
        Left = 0
        Top = 168
        Width = 317
        Height = 141
        ItemHeight = 13
        Items.Strings = (
          
            '<html> <head> <meta http-equiv="Content-Type" content="text/html' +
            '; charset=EUC-JP"> <link rel="stylesheet" href="/psnet/com/tsuba' +
            'sa-adc.css"> <script type="text/javascript"> <!-- if(window.top.' +
            'name==""){   myDate = new Date()   nowH = myDate.getHours()   no' +
            'wM = myDate.getMinutes()   nowS = myDate.getMilliseconds()   win' +
            'name = nowH+":"+nowM+":"+nowS   window.top.name=winname } //--> ' +
            '</script>  </head> <body bgcolor="#FFFFFF" text="#000000" margin' +
            'width="0" marginheight="0" leftmargin="0" topmargin="0" onLoad="' +
            'setEnabled()"> <table width="100%" border="0" cellpadding="4" ce' +
            'llspacing="0" height="100%">   <tr align="left" valign="top">   ' +
            '  <td>       <table width="100%" border="0" cellpadding="4" cell' +
            'spacing="0">         <tr>           <td>             <font class' +
            '="texts">               <img src="/psnet/images/l_head.gif">    ' +
            '           <span class="textn"><b>???????? 2???a???????</b></spa' +
            'n><br>               <font color="#AAAAAA">p?????</font>        ' +
            '       <font color="#AAAAAA">???????</font>               ??1???' +
            '?????               1               ??????              2       ' +
            '        ?????????????????????             </font>           </td' +
            '>         </tr>         <tr>           <td>             <table w' +
            'idth="100%" border="0" cellspacing="0" cellpadding="4" class="te' +
            'xts">               <tr valign="middle" bgcolor="#99FFCC" nowrap' +
            '>                 <th height="25" width="9%"  align="center">PS?' +
            '?????td>                 <th height="25" width="14%" align="left' +
            '"  >?????/td>                 <th height="25" width="11%" align=' +
            '"left"  >?????/td>                 <th height="25" width="8%"  a' +
            'lign="left"  >??????/td>                 <th height="25" width="' +
            '12%" align="left"  >????</td>                 <th height="25" wi' +
            'dth="9%"  align="left"  >????????????</td>                 <th h' +
            'eight="25" width="6%"  align="left"  >???</td>                 <' +
            'th height="25" width="6%"  align="center">??Otd>                ' +
            ' <th height="25" width="6%"  align="center">??|/td>             ' +
            '    <th height="25" width="6%"  align="right" >????</td>        ' +
            '         <th height="25" width="7%"  align="right" >?s?/td>     ' +
            '            <th height="25" width="7%"  align="left"  >??I</td> ' +
            '              </tr>   <tr valign="middle" bgcolor="" nowrap> <td' +
            ' height="25" align="center"><font color="#000000">45545479</font' +
            '></td> <td height="25" align="left"  ><font color="#000000"><a h' +
            'ref="JavaScript:selectParts('#39'45545479'#39')">???????????????/a></fon' +
            't></td> <td height="25" align="left"  ><font color="#000000">???' +
            '????????-??/font></td> <td height="25" align="left"  ><font colo' +
            'r="#000000">WB300</font></td> <td height="25" align="left"  ><fo' +
            'nt color="#6600FF">KK-LK252AB-M2E</font></td> <td height="25" al' +
            'ign="left"  ><font color="#000000">FE6F</font></td> <td height="' +
            '25" align="left"  ><font color="#000000"></font></td> <td height' +
            '="25" align="center"><font color="#000000">??'#1084'/font></td> <td he' +
            'ight="25" align="center"><font color="#000000">???</font></td> <' +
            'td height="25" align="right" ><font color="#000000">1?l/font></t' +
            'd> <td height="25" align="right" ><font color="#FF3300">&yen24,0' +
            '00</font></td> <td height="25" align="left"  ><font color="#0000' +
            '00">'#167'??</font></td> </tr> <tr valign="middle" bgcolor="#FFFFCC" ' +
            'nowrap> <td height="25" align="center"><font color="#000000">455' +
            '46155</font></td> <td height="25" align="left"  ><font color="#0' +
            '00000"><a href="JavaScript:selectParts('#39'45546155'#39')">????????????' +
            '???/a></font></td> <td height="25" align="left"  ><font color="#' +
            '000000">???????????-??/font></td> <td height="25" align="left"  ' +
            '><font color="#000000">WB300</font></td> <td height="25" align="' +
            'left"  ><font color="#6600FF">KK-LK252AB-M2E</font></td> <td hei' +
            'ght="25" align="left"  ><font color="#000000">FE6F</font></td> <' +
            'td height="25" align="left"  ><font color="#000000"></font></td>' +
            ' <td height="25" align="center"><font color="#000000">??'#1084'/font><' +
            '/td> <td height="25" align="center"><font color="#000000">???</f' +
            'ont></td> <td height="25" align="right" ><font color="#000000">1' +
            '?l/font></td> <td height="25" align="right" ><font color="#FF330' +
            '0">&yen25,800</font></td> <td height="25" align="left"  ><font c')
        TabOrder = 1
        OnClick = ListPArtsClick
      end
      object ListView2: TListView
        Left = 323
        Top = 168
        Width = 310
        Height = 141
        Columns = <
          item
          end
          item
          end
          item
          end>
        TabOrder = 2
        ViewStyle = vsReport
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      ImageIndex = 3
      object WebBrowser1: TWebBrowser
        Left = 0
        Top = 0
        Width = 636
        Height = 144
        Align = alClient
        TabOrder = 0
        OnDownloadBegin = WebBrowser1DownloadBegin
        OnDownloadComplete = WebBrowser1DownloadComplete
        OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
        ExplicitHeight = 141
        ControlData = {
          4C000000BC410000E20E00000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
      object Panel1: TPanel
        Left = 0
        Top = 144
        Width = 636
        Height = 168
        Align = alBottom
        Color = clCream
        ParentBackground = False
        TabOrder = 1
        object Edit1: TEdit
          Left = 89
          Top = 12
          Width = 276
          Height = 21
          TabOrder = 0
          Text = 'http://www.bl-recycle.jp/servlet/EW3SAS_WEB_PS'
        end
        object Edit2: TEdit
          Left = 371
          Top = 12
          Width = 61
          Height = 21
          TabOrder = 1
          Text = '8297400'
        end
        object Edit3: TEdit
          Left = 438
          Top = 12
          Width = 57
          Height = 21
          TabOrder = 2
          Text = 'ps84124q'
        end
        object Edit4: TEdit
          Left = 501
          Top = 12
          Width = 57
          Height = 21
          TabOrder = 3
          Text = 'ab340u79'
        end
        object Button2: TButton
          Left = 8
          Top = 8
          Width = 75
          Height = 25
          Caption = 'login'
          TabOrder = 4
          OnClick = Button2Click
        end
        object ListView1: TListView
          Left = 1
          Top = 39
          Width = 634
          Height = 128
          Align = alBottom
          Checkboxes = True
          Columns = <
            item
              Caption = '111'
            end
            item
              Caption = '22'
              Width = 255
            end
            item
              Caption = '33'
            end>
          Groups = <
            item
              GroupID = 0
              State = [lgsNormal]
              HeaderAlign = taLeftJustify
              FooterAlign = taLeftJustify
              TitleImage = -1
            end
            item
              GroupID = 1
              State = [lgsNormal]
              HeaderAlign = taLeftJustify
              FooterAlign = taLeftJustify
              TitleImage = -1
            end>
          ParentColor = True
          PopupMenu = PopupMenu1
          TabOrder = 5
          ViewStyle = vsReport
        end
        object Button3: TButton
          Left = 564
          Top = 8
          Width = 59
          Height = 25
          Caption = 'Test Mail'
          TabOrder = 6
        end
      end
    end
  end
  object LogList: TListBox
    Left = 0
    Top = 343
    Width = 644
    Height = 97
    Align = alBottom
    ItemHeight = 13
    TabOrder = 2
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
    Left = 184
    Top = 348
  end
  object IdCookieManager1: TIdCookieManager
    Left = 248
    Top = 348
  end
  object JvFormStorage1: TJvFormStorage
    AppStorage = JvAppIniFileStorage1
    AppStoragePath = '%FORM_NAME%\'
    StoredProps.Strings = (
      'ListView1.Items')
    StoredValues = <>
    Left = 392
    Top = 276
  end
  object JvAppIniFileStorage1: TJvAppIniFileStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    FileName = 'settings.ini'
    DefaultSection = 'main'
    SubStorages = <>
    Left = 388
    Top = 340
  end
  object PopupMenu1: TPopupMenu
    Left = 232
    Top = 252
    object Insert1: TMenuItem
      Caption = 'Insert'
    end
    object Edit5: TMenuItem
      Caption = 'Edit'
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
  end
  object IdConnectionIntercept1: TIdConnectionIntercept
    Intercept = IdLogDebug1
    Left = 208
    Top = 192
  end
  object IdEncoderQuotedPrintable1: TIdEncoderQuotedPrintable
    Left = 198
    Top = 104
  end
  object IdLogDebug1: TIdLogDebug
    Active = True
    Left = 342
    Top = 156
  end
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CCList = <>
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 325
    Top = 208
  end
  object IdSASLLogin1: TIdSASLLogin
    UserPassProvider = IdUserPassProvider1
    Left = 113
    Top = 80
  end
  object IdSASLPlain1: TIdSASLPlain
    UserPassProvider = IdUserPassProvider1
    Left = 95
    Top = 180
  end
  object IdSMTP1: TIdSMTP
    Intercept = IdConnectionIntercept1
    SASLMechanisms = <
      item
        SASL = IdSASLPlain1
      end
      item
        SASL = IdSASLLogin1
      end>
    Left = 301
    Top = 108
  end
  object IdUserPassProvider1: TIdUserPassProvider
    Left = 49
    Top = 116
  end
  object JvDebugHandler1: TJvDebugHandler
    LogFileName = 'debug.log'
    Left = 285
    Top = 52
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 592
    Top = 16
  end
end
