unit SearchUnit2;

interface

uses Windows, MSHTML, activex, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Vcl.ComCtrls,
  Dialogs, strutils, DBGrids, DB, MainUnit, idglobal, IdMessage, IdSMTP, Grids,
  settings, ExtCtrls, IdCookieManager, IdBaseComponent, IniFiles,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.StdCtrls, Vcl.OleCtrls,
  idAntiFreeze, IdHeaderList,
  SHDocVw, Vcl.Menus, JvAppStorage,
  JvAppIniStorage, JvComponentBase, JvFormPlacement, JvDebugHandler,
  IdUserPassProvider, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSASLPlain, IdSASL, IdSASLUserPass,
  IdSASLLogin, IdLogBase,
  IdLogDebug, IdCoder, IdCoderQuotedPrintable, IdIntercept,
  UnitVars, UnitProgress, IdAntiFreezeBase, UnitSend;

type
  TSearch2 = class(TOBJECT)
    procedure Search2;
  private
    procedure DeleteImgs(listFiles: Tstrings);
  public
    { Public declarations }
    ST: SearchT;
    StringGrd: TStringGrid;
    Constructor Create;
    Destructor Destroy; override;
  end;

var
  // FormSearch: TFormSearch;
  iRow: integer;

implementation

uses parse, DBs, UnitDB;

constructor TSearch2.Create;
begin
  StringGrd := TStringGrid.Create(nil);

end;

destructor TSearch2.Destroy;
begin
  StringGrd.Free;
  inherited;
end;

procedure TSearch2.Search2;
var
  http: TIdHTTP;
  CM: TIdCookieManager;
  Data, Imgs, Parts: Tstrings;
  StrPage, sPost, JsScript, urlStr, sAD3000, sPart, sdt: String;
  r, n, p, l: integer;
  iRepeat, iNum, iPageNum, iPage: integer;
  sItem: TsItem2;
  // iURI: tidURI;
  pHTML: TParseHTML;
  Headers: TIdHeaderList;
  IdConnectionIntercept1: TIdConnectionIntercept;
begin
  // =========================

  iRepeat := 5; // ���-�� �������� �������� ����
  iNum := 0; // ���-�� ���������
  ST.Name := '����� �� PC-NET';
  FormMain.Log('�������� ����������');
  try
    // ----- Start init vars--------
    http := TIdHTTP.Create();
    http.Intercept := TIdConnectionIntercept.Create();
    http.ConnectTimeout := 30000;
    http.ReadTimeout := 60000;
    http.HTTPOptions := [hoKeepOrigProtocol, hoForceEncodeParams];
    http.AllowCookies := true; // ��������� ����
    http.HandleRedirects := false; // �������������
    Data := TStringList.Create;
    CM := TIdCookieManager.Create(http);
    http.AllowCookies := true;
    http.CookieManager := CM;
    http.HandleRedirects := true;
    http.Request.Host := 'www.bl-recycle.jp';
    { TODO : �������� ������ ����� �� url }
    http.Request.UserAgent :=
      'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.0.10) Gecko/2009042316 Firefox/3.0.10';
    http.Request.Accept :=
      'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
    http.Request.AcceptLanguage := 'ru,en-us;q=0.7,en;q=0.3';
    http.Request.AcceptCharSet := 'windows-1251,utf-8;q=0.7,*;q=0.7';
    http.Request.Referer := Sets.Opt2.SiteURL;
    http.CookieManager.CookieCollection.AddClientCookies('AGREE01=1');

    // http.CookieManager.GenerateClientCookies(Sets.Opt2.SiteLoginURL,false,Headers);
    // �������� ������ �����
    // ������-�� �� ��������???
    // ----- end init vars--------
    FormMain.Log('������ ������ ���������� ������� � ����� �� ����...');
    Sets.LsURLs.Clear;
    // ������ ������ ���������� �� ����
    if DM.Get2URLs(Sets.LsURLs) < 1 then
      exit; // ��� �������  - ������� �� finally
    FormMain.Log('�������: ' + inttostr(Sets.LsURLs.Count));
    // Data.Add('AD1210=8297400');
    Data.Add('AD1210=' + Sets.Opt2.Login1);
    Data.Add('AD1510=' + Sets.Opt2.Login2);
    Data.Add('AD1520=' + Sets.Opt2.Login3);
    Data.Add('E_SID=PARTS_SB');
    Data.Add('E_WORKID=ID0110');
    Data.Add('AD9820=101010');
    // AD1210=8297400&AD1510=ps84124q&AD1520=ab340u79&E_SID=PARTS_SB&E_WORKID=ID0110&AD9820=101010
    FormMain.Log('��������� �� ������'); { DONE 4 : �������� ������ �� ���� }
    { DONE : ������� ������� ��� ��������� ���������� }
    StrPage := PostHTTP('POST', http, Sets.Opt2.SiteLoginURL, Data);
    if (StrPage = '') or (AnsiPos('��̿Ū���顼', StrPage) > 0) then
      exit;

    // ��� ������ ���� �������� � ������� ������ � ����� ��������
    FormMain.Log('�������� �� ������...');
    Data.Clear;
    Data.Add('E_WORKID=ID0120');
    Data.Add('turl=sbe');
    FormMain.Log('������� ������ �����������.');
    sleep(2000);
    sItem := TsItem2.Create;
    FormMain.Log('�������� �������...');
    { DONE : ������� ������� ��� ��������� ���������� }
    StrPage := PostHTTP('POST', http, Sets.Opt2.SiteLoginURL, Data);
    if StrPage = '' then
      exit;
    l := 0;
    // http://www.bl-recycle.jp/servlet/EW3SAS_WEB_PS
    // AD3000M=-1&AD3000=1000&AD3500M=-1&AD3010M=0&AD3010=1010&AD3530M=-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD4100M=0&E_WORKID=ID1410&ORDER01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020B&ORDER03D=1&CHARGE=0
    while (l < Sets.LsURLs.Count) do // ���� �������� �� �������
    begin
      Data.Clear;
      sPost := AnsiDequotedStr(Sets.LsURLs.Strings[l], '"');
      if sPost = '' then
      begin
        FormMain.Log('������!!! ������ ������ - ������!', 3);
        Break;
      end;
      sItem.part1 := ReplaceText(sPost, '&', EOL);
      Data.Text := sItem.part1;
      sleep(2000);
      { DONE : ������� ������� ��� ��������� ���������� }
      FormMain.Log('���� �� ������ � ���������...');
      StrPage := PostHTTP('POST', http, Sets.Opt2.SiteLoginURL, Data);
      // StrPage := '';
      // ListPArts.Items.Clear;
      // for i := 0 to ListView1.Items.Count - 1 do
      // ���� ��������� � ������
      if StrPage <> '' then
      begin
        Data.Clear;
        // 'AD3000M=-1&AD3000=3000&AD3500M=-1&AD3010M=0&AD3010=3020&AD3530M=-1&AD1030I=2&AD5400M=-1&AD4020M=0&AD5510M=0&E_WORKID=ID1410&ORDER01=AD4610B&ORDER01D=1&ORDER02=AD4060B&ORDER02D=1&ORDER03=AD4020B&ORDER03D=1&CHARGE=0';
        //
        sPost := AnsiDequotedStr(Sets.LsURLs.Strings[l + 1], '"');
        if sPost = '' then
        begin
          FormMain.Log('������!!! ������ ������ - ������!', 3);
          Break;
        end;
        FormMain.Log('������ ������ ������: ' + inttostr(l));
        FormMain.Log(sPost);
        sItem.part2 := ReplaceText(sPost, '&', EOL);
        sleep(2000);
        iPage := 99999; // ������� ������� ������� � ������ ���������
        iPageNum := 1; // ����� ������� ��������
        FormMain.Log('������ ������ ��������� �� ����������...');
        { DONE : ������� ������� ��� ��������� ���������� }
        while (iPage > 0) and (StrPage <> '') do
        begin
          Data.Text := sItem.part2;
          sAD3000 := Data.Values['AD3000'];
          if iPageNum > 1 then
          begin // ������ ������ - ��������� ��� ����������� �������
            Data.Values['E_WORKID'] := 'ID1411';
            Data.Values['PAGENO'] := inttostr(iPageNum);
          end;
          StrPage := PostHTTP('POST', http, Sets.Opt2.SiteLoginURL, Data);
          { TODO 3 : �������� ������ ����������� �������� ����� ��������� > 20 }
          if StrPage <> '' then
          begin
            FormMain.Log('������ ������� ��� StringGrid');
            pHTML := TParseHTML.Create;
            iNum := pHTML.ParseTableSR2(StrPage, StringGrd);
            // iNum := ParseTable1(StrPage, StringGrd); { TODO : ���������!"""" }
            inc(iPageNum); // ����������� ����� ������� ��� ��� ��� ��� �������
            if iPage > iNum then
              iPage := iNum;
            // ���� ������ ������ ��� - �� ���������� ���-�� ��������� ��� �������� �������
            FormMain.Log('���-�� ���������: ' + inttostr(iNum) + ' ��������: ' +
              inttostr(iPageNum));
            if iNum = 0 then
              Break; // ������ ������� - ������ �������

            { DONE : ����� ��� ������� �������??? }
            FormMain.Log('������ ���� �������...');
            JsScript := GetScript(StrPage);
            FormMain.Log('����� ������ �� ���-������:' + JsScript);

            if pHTML.ParserScript(Data, JsScript, http) then
            begin
              FormMain.Log('��������� ��������� �� �������...');
              Parts := TStringList.Create;
              if GetPartsNum(StrPage, Parts) then
              // ����� ������ ��������� �� ��������
              begin
                FormMain.Log('������� ���������: ' + inttostr(Parts.Count));
                ST.Status := '������� ���������: ' + inttostr(Parts.Count);
                iPage := iPage - Parts.Count;
                for r := 0 to Parts.Count - 1 do
                begin
                  sItem.partnumber := Parts.Strings[r]; // �������� �������
                  FormMain.Log('��������� - ���� �� �������� � ����...' +
                    inttostr(r + 1));
                  if DM.GetItem2ID(sItem) < 0 then
                  // ��������� ���� �� ������ � ����, ����� ��������� �� � ����
                  begin
                    urlStr := 'http://' + http.Request.Host;
                    FormMain.Log('�������� URL ����� �������� �� ������...');
                    for n := 1 to Data.Count - 1 do
                    begin
                      sdt := AnsiDequotedStr(Data.Strings[n], '''');
                      if AnsiContainsStr(sdt, 'target') then
                        sdt := sItem.partnumber;
                      if AnsiContainsStr(sdt, 'document') then
                        sdt := sAD3000;
                      urlStr := urlStr + sdt;
                      // Data.Strings[Data.IndexOf('target')] := Parts.Strings[r];
                      // ��������� POST ������ �� ������ ����� ��������
                      { DONE 3 : �������� �� �������� �����! }
                    end;
                    try
                      FormMain.Log('������ ��������: ' + urlStr);
                      { DONE : ������� ������� ��� ��������� ���������� }
                      StrPage := getHTTP(http, urlStr);
                      { TODO : ����� �� c������ �������� �������� � ���� �� ������? }
                      http.Request.Referer := urlStr;
                      http.Request.Accept :=
                        'image/png, image/svg+xml, image/*;q=0.8, */*;q=0.5';
                      FormMain.Log('������ �������� ��� �' + sItem.partnumber);
                      Imgs := TStringList.Create;
                      GetImagesFromHTML(http, StrPage, Imgs,
                        'http://' + http.Request.Host, sItem.partnumber);
                      { ListPArts.Items.Add(StrPage);
                        ListPArts.Items.SaveToFile(ExtractFilePath(Application.ExeName)
                        + 'part' + Parts.Strings[r] + '.htm'); }
                      FormMain.Log('�������� ������.');
                      while not SendMail2(FormSettings.EdSender.Text,
                        FormSettings.EdRecipients.Text,
                        FormSettings.EdSMTPHost.Text,
                        FormSettings.edSMTPport.Text,
                        'PS-NET - ����� ������������� �� ����������. ID' +
                        sItem.partnumber, FormSettings.EdMailLogin.Text,
                        FormSettings.EdMailPass.Text,
                        // 'a.cia@yandex.ru', 'a.cia@yandex.ru',
                        // 'smtp.yandex.ru', '25', 'New parts.', 'a.cia', 'Ferdy4to)',
                        StrPage, Imgs) and (iRepeat > 0) do
                      begin
                        FormMain.Log
                          ('������ �������� ������! ���� � ���������...');
                        Application.ProcessMessages;
                        sleep(4000);
                        dec(iRepeat);
                      end;
                      FormMain.Log('������ ����������.');
                      DeleteImgs(Imgs);
                      FormMain.Log('��������� �������� �' + sItem.partnumber +
                        ' � ����.');
                      DM.Add2Item(sItem);
                      sleep(3000);
                      { DONE : ��������� ����� }
                      { TODO : �������� ������ � ����� ��������� ��� �������� ����� }
                    finally
                      { TODO :
                        ������������ ��������� ������.
                        �������� ������ � �������� �������� ��������� ���� ����. }
                      FormMain.Log('������ ���������: ' + inttostr(r + 1) +
                        ' �� ' + inttostr(Parts.Count));
                    end;
                  end;
                end;
                FormMain.Log('���������.');
              end;
              Parts.Free;
            end;
            pHTML.Free;
          end;
          if StrPage = '' then
            FormMain.Log('������: StrPage = ������ !', 2);
          if iPage < 1 then
            FormMain.Log('������: iPage < 1 !', 2);
        end;
      end
      else
        FormMain.Log('������ ����� �������!', 2);
      l := l + 2; //
    end;
    // WB_LoadHTML(WebBrowser1,StrPage);
  finally
    FormMain.Log('�����������...');
    sItem.Free;
    Data.Free;
    CM.Free;
    http.Free;
    ST.FlgCancel := true;

  end;
  FormMain.Log('������.');
  { if Pos('<input class="logoutlj_hidden" id="user" name="user" type="hidden" value="'+Edit1.Text,StrPage) <> 0 then
    FormMain.Log('����������� ������ �������',1)
    else
    FormMain.Log('����������� �����������',3); }

  // Memo1.Lines.Text := StrPage;
end;

procedure TSearch2.DeleteImgs(listFiles: Tstrings);
var
  i: integer;
begin
  i := 0;
  while i < listFiles.Count do
  begin
    try
      if FileExists(listFiles.Strings[i]) then
        DeleteFile(listFiles.Strings[i]); // �������  ���� ��������
    except
    end;
    inc(i);
  end;
end;

end.
