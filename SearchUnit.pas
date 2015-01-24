unit SearchUnit;

interface

uses
  Windows, MSHTML, activex, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Vcl.ComCtrls, Data.Win.ADODB,
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
  UnitVars, UnitProgress, IdAntiFreezeBase;

type
  TFormSearch = class(TForm)
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    Timer2: TTimer;
    DBGrid1: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private

    procedure Load(sURL: string);
    procedure SearchURLs;
    procedure SendData;
    function ValidData: boolean;

    function DeleteLineBreaks(const S: string): string;
    function isUnique(sField, sItem: string): boolean;
    function AddRecord(sFields: array of string): boolean;
    procedure GetHtmlTbl0(StrGrd0: TStringGrid);
    { Private declarations }
  public
    { Public declarations }
    ST: SearchT;
  end;

var
  FormSearch: TFormSearch;
  iRow: integer;

implementation

uses UnitDB, parse, UnitSend, UnitURLs, SearchUnit2, Cromis.SimpleLog;

{$R *.dfm}

procedure TFormSearch.FormCreate(Sender: TObject);
begin
  ST.iTime := 0;
  Timer2.Interval := 1;
  Timer2.Enabled := true;

  //
  Timer1.Enabled := true;
  Timer1.Interval := 3000;
end;

procedure TFormSearch.SearchURLs;
var
  i: integer;
  LsURLs: tstrings;
begin
  ST.FlgCancel := false;
  ST.Name := 'Поиск по JapanCar';
  ST.iTime := 0;
  iRow := 0;
  LsURLs := TStringList.Create;
  LsURLs.Text := DM.GetURLs();
  if not FormSettings.ChAutoHide.Checked then
  begin
    FormProgress := TFormProgress.Create(self);
    FormProgress.Show;
  end;
  StringGrid1.RowCount := 0; // delete all records
  // StringGrid1.RowCount := 1;
  StringGrid1.ColCount := 0;
  StringGrid1.FixedRows := 0;
  StringGrid1.FixedCols := 0;
  StringGrid1.ColCount := 9; // ColCount+ StrGrd.ColCount;
  try
    for i := 0 to LsURLs.Count - 1 do
    begin
      Load(LsURLs.Strings[i]);
      ST.DoneURLs := i + 1;
      ST.Status := 'Новых ссылок: ' + inttostr(ST.NewItems);
      if not FormSettings.ChAutoHide.Checked then
        FormProgress.LbCount.Caption := 'Новых ссылок: ' +
          inttostr(ST.NewItems);
      if ST.FlgCancel then
        exit;
    end;
    DM.QItems.Requery(); // перезагрузка таблицы
    if ValidData then
      SendData;
  finally
    if not FormSettings.ChAutoHide.Checked then
      FormProgress.Free;
  end;
end;

{ TODO : добавить загрузку формы с полями поиска
  и парсинг ее отправки для захвата POST запроса }
// procedure SafeArray(var Doc: IHTMLDocument2; h: string);
// var
// v: OleVariant;
// begin
// // - чего-то
// v := VarArrayCreate([0, 0], VarVariant);
// v[0] := h;
// Doc.write(PSafeArray(TVarData(v).VArray));
// // конец чего-то
// end;

procedure TFormSearch.Load(sURL: string);
var
  S, html, StrURL: string;
  // SLBody: TStringList;
  RowCnt, i, RC, p, n, iRetries: integer;
  // Doc: IHTMLDocument2;
  // DocAll: IHTMLElementCollection;
  // DocTag: IHtmlElement;
  StrTxt: tstrings;
  sFileName: String;
  StrGrd: TStringGrid;
  pHTML: TParseHTML;
  // t, r0, i, r, c, m, n: Integer;
begin
  { DONE -oАртем -cпарсер : добавить загрузку остальных страниц }
  FormMain.Log('Start load...');
  if not FormSettings.ChAutoHide.Checked then
  begin
    FormProgress.ProgressBar1.Max := 0;
    FormProgress.ProgressBar1.Position := 0;
    FormProgress.ProgressBar1.Step := 1;
  end;
  StrURL := sURL;
  ST.Progress := 0;
  repeat
    ST.Status := 'Загрузка URLs...';
    html := GetHTTP(FormMain.IdHTTP1, StrURL); // GetURL(StrURL);
    // http://parts.japancar.ru/?code=parts&amp;mode=old&amp;cl=search_partsoldng&amp;cl_partCode=3cvFLjAwNg_289&amp;cl_marka=MITSUBISHI&amp;cl_model=DELICA&amp;cl_kuzovN=PF8W&page=2
    // http://parts.japancar.ru/?code=parts&mode=old&cl=search_partsoldng&cl_partCode=3cvFLjAwNg_289&cl_marka=HONDA&page=2
    // загрузка страницы по адресу StrURL в html
    if html = '' then
      Break;
    StrTxt := TStringList.Create();
    StrGrd := TStringGrid.Create(nil);
    StrGrd.RowCount := 0;
    pHTML := TParseHTML.Create;
    StrTxt.Text := html;
    FormMain.Log('Do GetHtmlTable...');
    FormMain.Log('URL:' + StrURL);
    n := pHTML.ParseTable3(StrTxt, StrGrd);
    if n < 2 then
      Break;
    StrTxt.Free;
    Application.ProcessMessages;
    if ST.ProgressMax < 1 then
    begin
      n := 0;
      try
        S := StrGrd.Cells[0, 0];
        if S = '' then
          S := '0';

        n := StrToInt(S); { TODO : Добавить проверку на корректность }
        ST.ProgressMax := n;
        if not FormSettings.ChAutoHide.Checked then
          FormProgress.ProgressBar1.Max := n + 1;
      finally
        FormMain.Log('Найдено позиций: ' + inttostr(n));
        ST.Status := 'Найдено позиций: ' + inttostr(n);
      end;
      { DONE : Проблема!!! в поиск попадают все похожие запчасти! }
    end;
    // FormMain.Log('Do GetHtmlTable...');
    // ST.Status:='Найдено: 0';
    GetHtmlTbl0(StrGrd); // вставка таблицы в базу данных
    ///
    FormMain.Log('Do GetURL Page...');
    StrURL := (StrGrd.Cells[1, 0]);
    // StrURL := GetURLpage(DocAll);
    { -----------------------
      if StrURL <> '' then
      begin
      p := pos('?', sURL);
      StrURL := midstr(sURL, 0, p - 1) + StrURL;
      end; ---------------------- }
    RC := StringGrid1.RowCount - 1;
    RowCnt := RC - 1;

    for i := RC + 2 to (RC + StrGrd.RowCount - 1) do
    begin
      p := i - RC;
      if Trim(StrGrd.Cells[1, p]) <> '' then
      begin
        inc(RowCnt);
        with StringGrid1 do
        begin
          RowCount := RowCount + 1; // StrGrd.RowCount;
          // form1.StrGrd0.Cells[0, I]:=inttostr(NewID);
          Cells[0, RowCnt] := StrGrd.Cells[0, p]; // foto
          Cells[1, RowCnt] := StrGrd.Cells[1, p];
          Cells[2, RowCnt] := StrGrd.Cells[2, p];
          Cells[3, RowCnt] := StrGrd.Cells[3, p];
          Cells[4, RowCnt] := StrGrd.Cells[4, p];
          Cells[5, RowCnt] := StrGrd.Cells[5, p];
          Cells[6, RowCnt] := StrGrd.Cells[6, p];
          Cells[7, RowCnt] := StrGrd.Cells[7, p];
          Cells[8, RowCnt] := StrGrd.Cells[8, p];
        end;
        // Inc(NewID);
      end;
    end;
    Application.ProcessMessages;
    // if not FormSettings.ChAutoHide.Checked then
    if ST.FlgCancel then
      Break;
  until StrURL = '';
  // if not FormSettings.ChAutoHide.Checked then
  StrGrd.Free;
  ST.Progress := 0;
  FormMain.Log('End load.');
end;

function TFormSearch.ValidData: boolean;
var
  ErrString: string;
begin
  Result := true;
  ErrString := '';
  if { (StringGrid1.RowCount < 1) or }
    (DM.GetDoSendItems('items').RecordCount = 0) { or
    (Length(Trim(StringGrid1.Rows[0].Text)) < 10) } then
    ErrString := 'Новых данных нет. Нечего отсылать.';
  if Trim(FormSettings.EdSMTPHost.Text) = ''
  then { TODO : переделать передачу параметров не из формы! }
    ErrString := ErrString + #13 + #187 + 'DNS server not filled in';
  if Trim(FormSettings.EdRecipients.Text) = '' then
    ErrString := ErrString + #13 + #187 + 'Recipients email not filled in';
  if Trim(FormSettings.EdSender.Text) = '' then
    ErrString := ErrString + #13 + #187 + 'Sender email not filled in';
  if Trim(FormSettings.edSMTPport.Text) = '' then
    ErrString := ErrString + #13 + #187 + 'SMTPport not filled in';
  if ErrString <> '' then
  begin
    FormMain.Log('Cannot proceed due to the following errors:' + EOL +
      ErrString);
    Result := false;
  end;
end;

procedure TFormSearch.SendData;

  function GetStrGrd2(): UnicodeString;
  var
    r, c, items: integer;
    S: string;
    RC: _recordset;
  begin
    // StringGrid1.Rows[0].Text:=DM.GetDoSendItems('items');
    RC := DM.GetDoSendItems('items');
    items := 1;
    Result := '<html><head>' +
      '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />'
      + '<title>Japancar.ru - Поиск автозапчастей по параметрам</title></head>'
      + '<body><table width="100%" border="1"><tr>' + '<th scope="col">№</th>' +
      '<th scope="col">Адрес обьявления</th>' + '<th scope="col">Марка</th>' +
      '<th scope="col">ДВС</th>' +
      '<th scope="col">Номер кузова, двигателя</th>' + '<th scope="col">N</th>'
      + '<th scope="col">&nbsp;</th>' + '<th scope="col">Цена</th>' +
      '<th scope="col">Адрес продавца</th>' + '<th scope="col">Дата</th>'
      + '</tr>';
    RC.MoveFirst;
    for r := 0 to RC.RecordCount - 1 do
    begin
      Result := Result + '<tr>';

      // if StringGrid1.Cells[1, r] <> '' then
      // begin
      // Result := Result + '<td>' + inttostr(items) + '</td>';
      inc(items);
      for c := 0 to RC.Fields.Count - 2 do
      begin
        // if not VarIsNull(rc.Fields.Item[c].Value) then
        S := VarToStrDef(RC.Fields.Item[c].Value, 'null');
        // else
        // S:='null';
        StringGrid1.Cells[c, r] := S;

        if S = '' then
          S := '<br>';

        if RC.Fields.Item[c].Name = 'фото' then
          S := '<a href="' + S + '">' + S + '</a>';
        Result := Result + '<td>' + S + '</td>';
      end;
      // end;
      Result := Result + '</tr>';
      RC.MoveNext;
    end;
    Result := Result + '</table></body></html>';
  end;

  function GetStrGrd(): UnicodeString;
  var
    r, c, items: integer;
    S: string;
    // rc: _recordset;
  begin
    // StringGrid1.Rows[0].Text:=DM.GetDoSendItems('items');
    // /rc:=  DM.GetDoSendItems('items');
    items := 1;
    Result := '<html><head>' +
      '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />'
      + '<title>Japancar.ru - Поиск автозапчастей по параметрам</title></head>'
      + '<body><table width="100%" border="1"><tr>' + '<th scope="col">№</th>' +
      '<th scope="col">Адрес обьявления</th>' + '<th scope="col">Марка</th>' +
      '<th scope="col">ДВС</th>' +
      '<th scope="col">Номер кузова, двигателя</th>' + '<th scope="col">N</th>'
      + '<th scope="col">&nbsp;</th>' + '<th scope="col">Цена</th>' +
      '<th scope="col">Адрес продавца</th>' + '<th scope="col">Дата</th>'
      + '</tr>';
    for r := 0 to StringGrid1.RowCount - 1 do
    begin
      Result := Result + '<tr>';
      if StringGrid1.Cells[1, r] <> '' then
      begin
        Result := Result + '<td>' + inttostr(items) + '</td>';
        inc(items);
        for c := 0 to StringGrid1.ColCount - 1 do
        begin
          S := StringGrid1.Cells[c, r];
          if S = '' then
            S := '<br>';

          if c = 0 then
            S := '<a href="' + S + '">' + S + '</a>';
          Result := Result + '<td>' + S + '</td>';
        end;
      end;
      Result := Result + '</tr>';

    end;
    Result := Result + '</table></body></html>';
  end;

begin
  FormMain.Log('SendMail.Check...');
  // if ChSendMail.Checked then
  // begibegin

  with FormMain.IdMessage1 do
  begin
    FormMain.Log('Assigning mail message properties');
    From.Text := 'Delphi Indy Client <' + FormSettings.EdSender.Text + '>';
    From.Text := FormSettings.EdSender.Text;
    Sender.Text := FormSettings.EdSender.Text;
    Recipients.EMailAddresses := FormSettings.EdRecipients.Text;
    Subject := 'Japancar.ru - Поиск автозапчастей по параметрам';
    ContentType := 'text/html';
    CharSet := 'Windows-1251';
    ContentTransferEncoding := '8bit';
    IsEncoded := true;
    Body.Text := GetStrGrd2();
    { TODO 5: Изменить! ОТправить записи с без флага отправлено в базе }
  end;
  FormMain.Log('SendMail.');
  // FormMain.SendMail(FormMain.IdMessage1);
  FormMain.Log('Attempting to send mail');
  if SendMail3(FormMain.IdMessage1, nil) then
  {
    if SendMail2(FormMain.IdMessage1.From.Text,FormMain.IdMessage1.Sender.Text,
    FormSettings.EdSMTPHost.Text,FormSettings.edSMTPport.Text,FormMain.IdMessage1.Subject,
    FormSettings.EdMailLogin.Text,FormSettings.EdMailPass.Text,FormMain.IdMessage1.Body.Text,nil) then }
  begin
    { if SendMail(FormMain.IdMessage1) then
      begin
    } FormMain.Log
      ('Mail successfully sent and available for pickup by recipient !');
    ST.Status := 'Отправлено позиций: ' + inttostr(StringGrid1.RowCount-1);
    FormMain.JvTrayIcon1.BalloonHint('Почта', ST.Status);
    DM.SetSendItems('items');
  end;
  { TODO : Установить флаг Отправлено в базе для новых записей }
  // end;
  { TODO 4 : Привести отправку писем в одну функцию }
end;

procedure TFormSearch.Timer1Timer(Sender: TObject);

var
  Sr2: TSearch2;
begin
  (Sender as TTimer).Enabled := false;
  ST.FlgCancel := false;
  Timer1.Enabled := false;
  Timer1.Interval := FormSettings.AutoTime;
  { TODO 4 : Отключено на время тестирования }
  if FormMain.AcJapanCar.Checked then
    SearchURLs; // поиск запчастей на JapanCar
  try
    Sr2 := TSearch2.Create;
    ST.fSearchDo := true;
    StringGrid1.Cols[0].Clear;
    StringGrid1.Rows[0].Clear;
    StringGrid1.ColCount := 0;
    StringGrid1.RowCount := 1;
    if FormMain.AcPCNET.Checked then
      Sr2.Search2; // поиск запчастей на .NET
  finally
    Sr2.Free;
  end;
  Timer1.Enabled := FormSettings.ChAutoUpdate.Checked; { TODO : ??? }
  Timer1.Enabled := true;
  ST.fSearchDo := false;
  // (Sender as TTimer).enabled := FormSettings.ChAutoUpdate.Checked;
end;

procedure TFormSearch.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := false;
  if Timer1.Enabled then
  begin
    if ST.iTime <= 0 then
    begin
      ST.iTime := Timer1.Interval;
    end;
    if ST.iTime > 0 then
      (self as TForm).Caption := 'Timer: ' +
        inttostr(trunc(ST.iTime / 1000)) + 'sec';
    ST.iTime := ST.iTime - 1000;
  end;
  Timer2.Interval := 1000;
  Timer2.Enabled := true;
end;

procedure TFormSearch.GetHtmlTbl0(StrGrd0: TStringGrid);
var
  S: string;
  // Doc: IHTMLDocument2;
  DocTable, DocA: IHTMLElementCollection;
  row: ihtmltablerow;
  table: ihtmltable;
  // cell: ihtmltablecell;
  Elem, sURL: OleVariant;
  sFields: array of string;
  el, TRElement: IHtmlElement;
  t, n, p, r, c, m: integer;
  FlgFieldsName, FlgFieldAds: boolean;
  sHTTP: string;
begin
  sHTTP := 'http://parts.japancar.ru';
  { TODO : Заменить декларирование на анализ }
  sURL := sHTTP + StrGrd0.Cells[1, 0];
  StrGrd0.Cells[1, 0] := AnsiReplaceText(sURL, '&amp;', '&');
  iRow := StrGrd0.RowCount; { TODO : ??? }
  p := 0; // кл-во новый эелементов
  for r := 2 to iRow do
  begin
    // S := DeleteLineBreaks(StrGrd0.Cells[0, 0]);
    Application.ProcessMessages;
    if ST.FlgCancel then
      exit;
    ST.Progress := ST.Progress + 1;
    if ST.FlgCancel then
      exit;
    if not FormSettings.ChAutoHide.Checked then
    begin
      FormProgress.ProgressBar1.Position := ST.Progress;
      // FormProgress.ProgressBar1.StepIt;
      FormProgress.ProgressBar1.Repaint;
      FormProgress.LbCount.Caption := inttostr(p);
    end;
    // =================================
    // URL строки
    if StrGrd0.Cells[0, r] = '' then
      Break;
    sURL := sHTTP + StrGrd0.Cells[0, r];
    StrGrd0.Cells[0, r] := sURL;
    { DONE : добавить к URL домен }
    if isUnique('фото', sURL) then
    // проверка в базе даных на существующую запись
    begin
      inc(p);
      Setlength(sFields, StrGrd0.ColCount);
      for c := 0 to StrGrd0.ColCount - 1 do
      begin
        sFields[c] := DeleteLineBreaks(StrGrd0.Cells[c, r]);
      end;
      // -------------------------------------
      AddRecord(sFields);
      Application.ProcessMessages;
      // if not FormSettings.ChAutoHide.Checked then
      if ST.FlgCancel then
        exit;
    end
    else
    begin
      StrGrd0.Cells[1, r] := '';
      FormMain.Log('Skip append: duplicate record.');
    end;
  end;
  ST.NewItems := p;
  ST.Status := 'Найдено новых: ' + inttostr(ST.NewItems);
  { TODO : Проверить на дубливрование статуса с функцией Log }
  FormMain.JvTrayIcon1.BalloonHint(ST.Name, ST.Status);
  iRow := iRow + r;
end;

function TFormSearch.AddRecord(sFields: array of string): boolean;
var
  i: integer;
  S: string;
  sItem: TsItem;
begin
  // ------====* добавление записи в базу данных *======------
  try
    FormMain.Log('Append new record.');
    // if not DM.JvCsvDataSet1.Active then
    // DataModule2.JvCsvDataSet1.open;
    sItem := TsItem.Create;
    sItem.Foto := sFields[0];
    { TODO : некорректная передача элементов! }
    sItem.Firm := sFields[1];
    sItem.Name := sFields[2];
    sItem.Body := sFields[3];
    sItem.N1 := sFields[4];
    sItem.N2 := sFields[5];
    sItem.Price := sFields[6];
    sItem.Saler := sFields[7];
    if AnsiContainsStr(sFields[8], 'вчера') or AnsiContainsStr(sFields[8],
      'сегодня') then
    begin
      i := pos(' ', sFields[8]);
      if i > 0 then
      begin
        S := RightStr(sFields[8], Length(sFields[8]) - i);
        if AnsiContainsStr(sFields[8], 'сегодня') then
          sFields[8] := DateToStr(NOW) + ' ' + S + ':00';
        if AnsiContainsStr(sFields[8], 'вчера') then
          sFields[8] := DateToStr(NOW - StrToTime('23:59')) + ' ' + S + ':00';
      end;
      // s:=DateTimeToStr(now);
    end;
    sItem.Date := StrToDateTime(sFields[8]);

    DM.AddItem(sItem);
    sItem.Destroy;
    {
      with DataModule2.JvCsvDataSet1 do
      begin
      Log('Append new record.');
      Append;
      for m := 0 to FieldCount - 1 do
      begin
      if m < Length(sFields) then
      // проверка на выход из диапазона доступных полей в базе
      Fields.Fields[m].AsString := sFields[m];
      end;
      // Setlength(sFields, 0); // освобождение памяти
      // Fields.GetFieldNames(sFields);
      Post;
      // sFields.Destroy;

      end; }
    Result := true;
  except
    on E: Exception do
    begin
      SimpleLog.LogEvent(sLogNameDebug, 'Handled exception: ' +
        E.Message, ltError);
      Result := false;
      FormMain.Log('Error add record:' + sFields[0]);
    end;
  end;

end;

function TFormSearch.isUnique(sField, sItem: string): boolean;
begin
  with DM.QItems do
  begin
    DisableControls;
    Result := DM.GetItemID(sField, sItem) <= 0;
    // Result := not(Locate(sField, VarArrayOf([sItem]), [loCaseInsensitive]));
    if not Result then
      FormMain.Log('NOT Unique string: ' + sItem);
    EnableControls;
  end;
end;

function TFormSearch.DeleteLineBreaks(const S: string): string;
  function TrimStr(const S, Quot: string): string;
  { обрезание с краев строки заданного символа }
  var
    i, l: integer;
  begin
    l := Length(S);
    i := 1;
    if (l > 0) and (S[i] > Quot) and (S[l] > Quot) then
      exit(S);
    while (i <= l) and (S[i] = Quot) do
      inc(i);
    if i > l then
      exit('');
    while S[l] = Quot do
      dec(l);
    Result := Copy(S, i, l - i + 1);
  end;

var
  str: string;
begin
  str := StringReplace(S, #10, ' ', [rfReplaceAll]);
  str := TrimStr(StringReplace(str, #13, ' ', [rfReplaceAll]), ',');
  Result := Trim(StringReplace(str, '  ', ' ', [rfReplaceAll]));
end;

end.
