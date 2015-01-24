unit parse;

interface

uses
  Windows, System.Character, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,
  Dialogs, Grids, StdCtrls, Mask, JvExMask, JvToolEdit, StrUtils, ComCtrls,
  JvgStringGrid, JvFormPlacement, JvComponentBase, JvAppStorage,
  JvAppIniStorage;

type
  _Tag = record
    name, text: string;
    params: TStrings;
    HTML: string;
  end;

type
  _ClmnTbl = record
    name, text, URL, FotoUrl, ClassName: string;
  end;

type
  _TblParts = record
    Index: integer;
    URL, URLFoto, Firm, Name, Body, Cost, Saler, Date, num, CostType: string;
  end;

type
  _img = record
    name, URL: string;
    img: array of Byte;
  end;

type
  _Imgs = array of _img;

type
  _Part = record
    number: string;
    imgs: _Imgs;
    sHTML: string;
  end;

type
  TCharSet = set of Char;

type
  TParseHTML = class
  private
    function GetTag(buf, tagIn, tagOut: string; var iPos: integer; var Tag: _Tag): boolean;
    function FirstDelimiter(const Delimiters, S: string; StartPos: integer): integer;
    function GetTagName(buf: string; var pos, n1, n2, l2, len: integer): string;
    function FindTag(HTML: string; var Tag: _Tag; var iPos: integer): boolean;
    function GetTable(HTML: string; var iPos, iPosEnd: integer): boolean;
    function FindTagClose(HTML: string; var Tag: _Tag; var iPos: integer): integer;
    { Private declarations }
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

  published
    procedure parse(FileName: string);
    function ParseTable(HTML: string; StrGrd: TStringGrid): integer;
    function ParseTable0(HTML: string; StrGrd: TStringGrid): integer;
    function ParseTable2(HTML: string; StrGrd: TStringGrid): integer;
    function ParseTable3(Str: TStrings; StrGrd: TStringGrid): integer;
  end;

function ArrayToStr(dStr: array of Byte): string;
function GenName: string;
function GetTag(buf, tagIn, tagOut: string; var iPos: integer; var Tag: _Tag): boolean;
function FirstDelimiter(const Delimiters, S: string; StartPos: integer): integer;
function GetScript(sHTML: string): string;
// function GetImg(sHTML: string): _img;
// procedure GetImg(dImgs: _imgs);
function GetTagName(buf: string; var pos, n1, n2, l2, len: integer): string;
function ParseTable1(HTML: string; StrGrd: TStringGrid): integer;
// function ParseTable2(html: string; StrGrd: TStringGrid): integer;
function GetPartsNum(sHTML: string; var StrGrd: TStrings): boolean;

implementation

uses HTMLParser, HTMLObjs, StrMan;

function FirstDelimiter(const Delimiters, S: string; StartPos: integer): integer;
var
  P: PChar;
begin
  Result := StartPos; // Length(S);
  P := PChar(Delimiters);
  while Result < Length(S) do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then inc(Result)
      else Exit;
    inc(Result);
  end;
end;

function GetTagName(buf: string; var pos, n1, n2, l2, len: integer): string;
// var                    { TODO : проверить входящие параметры на полезность }
// n1,n2,len,l2: integer;
begin
  n1 := PosEx('<', buf, pos);
  if n1 = 0 then Exit;
  inc(n1);
  n2 := PosEx('>', buf, n1);
  l2 := n2;
  len := n2 - n1;
  n2 := FirstDelimiter(' >', buf, n1); // first word after <
  Result := MidStr(buf, n1, n2 - n1);
end;

function GetTag(buf, tagIn, tagOut: string; var iPos: integer; var Tag: _Tag): boolean;
var
  S, sk: string;
  n1, n2, len, l2: integer;
begin // <<<----------
  try
    Result := false;
    S := '';
    sk := '';
    Tag.name := '';
    Tag.text := '';
    Tag.params.Clear;
    // s:=buf[pos];  //test
    Tag.name := GetTagName(buf, iPos, n1, n2, l2, len); // имя тега
    if (n1 = 0) then Exit;

    iPos := n2;
    // --
    if buf[iPos] <> '>' then
      while iPos < l2 do
      begin
        n1 := iPos + 1;
        iPos := FirstDelimiter(' >"', buf, n1);
        // поиск первого разделитя параметров
        if buf[iPos] = '"' then
        begin
          iPos := FirstDelimiter('>"', buf, iPos + 1);
          // поиск следующего разделителя параметра
          if buf[iPos] = '"' then inc(iPos);
        end;
        if n2 = 0 then iPos := len + 1;
        S := MidStr(buf, n1, iPos - n1);
        Tag.params.Append(S); // доавить новый параметр тега
      end;
    // pos:=n2;
    // --
    sk := '';
    S := '';
    while (S = '') or (S = 'a') or (S = '/a') or (S = 'br') or (S = 'br /') or (S = 'b') or (S = 'ul') or (S = '/ul') or
      (S = 'div') or (S = '/div') or (S = '/b') or (S = '/td') or (S = '/tr') or (S = 'font') or (S = '/font') do
    // span /span , i /i , br /br
    begin
      n1 := PosEx(tagOut, buf, iPos);
      if n1 = 0 then break;
      inc(n1);
      n2 := PosEx(tagIn, buf, n1);
      sk := sk + MidStr(buf, n1, n2 - n1); // строка между > <
      iPos := n2;
      S := GetTagName(buf, iPos, n1, n2, l2, len);
      if pos('br', S) > 0 then // перевод строки на пробел
          sk := sk + ' ';
    end;
    Tag.text := sk;
    Result := true;
  except
  end;
end;

function GetScript(sHTML: string): string;
var // parse HTML and get url java-script
  Tag: _Tag;
  P: integer;
begin
  P := 1;
  Tag.params := TStringList.Create;
  while P > 0 do
  begin
    P := PosEx('<script', sHTML, P);
    GetTag(sHTML, '<', '>', P, Tag);
    if AnsiContainsStr(Tag.params.Values['LANGUAGE'], 'JavaScript') then
        Result := AnsiDequotedStr(Tag.params.Values['src'], '"');
  end;
  Tag.params.free;
end;

function GetPartsNum(sHTML: string; var StrGrd: TStrings): boolean;
var // parse HTML and get java-script params
  Tag: _Tag; // <a href="JavaScript:selectParts('45545479')"
  S: string;
  P, n1, n2: integer;
begin
  P := 1;
  if Assigned(StrGrd) then
  begin
    Tag.params := TStringList.Create;
    StrGrd.Clear;
    while P > 0 do
    begin
      P := PosEx('<a', sHTML, P);
      GetTag(sHTML, '<', '>', P, Tag);
      S := Tag.params.Values['href'];
      if AnsiContainsStr(S, 'selectParts') then
      begin
        // S:=FloatToStr(GetNumericValue(S, PosEx('(',S)));
        // n1:=PosEx('(',S);
        // n2:=PosEx(')',S,n1+1);
        // S := MidStr(S,n1+1,n2-n1-1);
        n1 := 1;
        while not(S[n1] in ['0' .. '9']) do inc(n1);
        n2 := n1;
        while S[n2] in ['0' .. '9'] do inc(n2);
        // n1:=PosEx('"',S);
        // n2:=PosEx('"',S,n1+1);
        S := MidStr(S, n1, n2 - n1);
        if S <> '' then StrGrd.Add(S);
      end;

    end;
    Tag.params.free;
    Result := (StrGrd.Count > 0);
  end;
end;

function GenName: string;
var
  G: TGUID;
begin
  G.D1 := DateTimeToTimeStamp(now).Date + DateTimeToTimeStamp(now).Time;
  G.D2 := random(65534);
  G.D3 := random(65534);
  Result := IntToHex(G.D1, 8) + IntToHex(G.D2, 4) + IntToHex(G.D3, 4);
end;

function StripNonConforming(const S: string; const ValidChars: TCharSet): string;
var
  DestI: integer;
  SourceI: integer;
begin
  SetLength(Result, Length(S));
  DestI := 0;
  for SourceI := 1 to Length(S) do
    if S[SourceI] in ValidChars then
    begin
      inc(DestI);
      Result[DestI] := S[SourceI]
    end;
  SetLength(Result, DestI)
end;

function StripNonNumeric(const S: string): string;
begin
  Result := StripNonConforming(S, ['0' .. '9'])
end;

function TParseHTML.ParseTable0(HTML: string; StrGrd: TStringGrid): integer;
var
  Tag: _Tag;
  td, tr, th, table, sNum: string;
  iLine, iBlock, iPos, iColumn, iNum: integer;
  fParse, fParseNum, fTable: boolean;
begin // <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  fParse := false; // начало парсинга таблицы с записями
  fTable := false; // ----v
  iNum := 0; // Кол-во запчастей
  fParseNum := false; // парсер кол-ва запчастей
  iBlock := 0; // начало парсинга строк с записами
  iColumn := 0; // текущая колонка таблице
  td := 'td'; // ячейка
  tr := 'tr'; // строка
  th := 'th';
  table := 'table';
  Tag.params := TStringList.Create;
  iPos := 1;
  iLine := 1; // StrGrd.RowCount;
  try
    GetTag(HTML, '<', '>', iPos, Tag);
    while Tag.name <> '' do
    begin
      GetTag(HTML, '<', '>', iPos, Tag);
      Application.ProcessMessages;
      if Tag.name = 'table' then
      begin
        if pos('class="texts"', Tag.params.text) > 0 then fParse := true; // ищем таблицу с классом texts
      end;
      if pos('class="textn"', Tag.params.text) > 0 then
      begin
        sNum := StripNonNumeric(Tag.text);
        iNum := strtoint(sNum);
        // iNum:=StrToInt(GetNumericValue(Tag.text));
      end;
      // fParseNum := true; // ищем таблицу с классом textn с кол-вом деталей
      if Tag.name = '/table' then
      begin
        fParse := false; // кончилась таблица - кончили парсить
        fParseNum := false;
      end;
      if fParseNum then
      begin
        if (Tag.name = td) or (Tag.name = th) then
        begin
          if Tag.name <> '' then
          begin

            StrGrd.Cells[iColumn, iLine] := Trim(Tag.text);
          end;
        end;
      end;
      if fParse then
      begin
        if Tag.name = tr then
        begin
          inc(iLine);
          iColumn := 0;
        end;
        if (Tag.name = td) or (Tag.name = th) then
        begin
          if Tag.name <> '' then
          begin

            StrGrd.Cells[iColumn, iLine] := Trim(Tag.text);
            inc(iColumn);
            if iColumn >= StrGrd.ColCount then StrGrd.ColCount := iColumn;
          end;
        end;
      end;
    end;

    StrGrd.RowCount := iLine + 1;
    StrGrd.FixedRows := 1;
  except
  end;
  Result := iNum;
end;

function TParseHTML.ParseTable2(HTML: string; StrGrd: TStringGrid): integer;
var
  Tag: _Tag;
  td, tr, th, table, sNum: string;
  iLine, iBlock, iPos, iColumn, iNum: integer;
  fParse, fParseNum, fTable: boolean;
  sHTTP: string;
begin
  sHTTP := 'http://parts.japancar.ru';
  fParse := false; // начало парсинга таблицы с записями
  fTable := false; // ----v
  iNum := 0; // Кол-во запчастей
  fParseNum := false; // парсер кол-ва запчастей
  iBlock := 0; // начало парсинга строк с записами
  iColumn := 0; // текущая колонка таблице
  td := 'td'; // ячейка
  tr := 'tr'; // строка
  th := 'th';
  table := 'table';
  Tag.params := TStringList.Create;
  iPos := 1;
  iLine := 1; // StrGrd.RowCount;
  try
    GetTag(HTML, '<', '>', iPos, Tag);
    while Tag.name <> '' do
    begin
      GetTag(HTML, '<', '>', iPos, Tag);
      Application.ProcessMessages;
      if Tag.name = 'table' then
      begin
        if pos('class="main-list"', Tag.params.text) > 0 then fParse := true; // ищем таблицу с классом texts
      end;
      if pos('class="comment"', Tag.params.text) > 0 then
      begin
        sNum := StripNonNumeric(Tag.text);
        iNum := strtoint(sNum);
        // iNum:=StrToInt(GetNumericValue(Tag.text));
      end;
      // fParseNum := true; // ищем таблицу с классом textn с кол-вом деталей
      if Tag.name = '/table' then
      begin
        fParse := false; // кончилась таблица - кончили парсить
        fParseNum := false;
      end;
      if fParseNum then
      begin
        if (Tag.name = td) or (Tag.name = th) then
        begin
          if Tag.name <> '' then
          begin
            StrGrd.Cells[iColumn, iLine] := Trim(Tag.text);
            if Tag.name = 'a' then
            begin
              StrGrd.Cells[iColumn, iLine] := sHTTP + StrGrd.Cells[iColumn, iLine]; { TODO 5 : !!! проверить!!! }
            end;
          end;
        end;
      end;
      if fParse then
      begin
        if (Tag.name = tr) or (Tag.name = 'banner') then
        begin
          inc(iLine);
          iColumn := 0;
        end;
        if (Tag.name = td) or (Tag.name = th) then
        begin
          if Tag.name <> '' then
          begin
            if Tag.name <> 'banner' then
            begin
              StrGrd.Cells[iColumn, iLine] := Trim(Tag.text);
              inc(iColumn);
              if iColumn >= StrGrd.ColCount then StrGrd.ColCount := iColumn;
            end;
          end;
        end;
      end;
    end;

    StrGrd.RowCount := iLine + 1;
    StrGrd.FixedRows := 1;
  except
  end;
  Result := iNum;
end;

function TParseHTML.ParseTable3(Str: TStrings; StrGrd: TStringGrid): integer;
var
  ht: THTMLParser;
  iDiv, iTable, iTD, iTH, iTR, iNum, n, j, I, P, grdCol, grdRow: integer;
  htag, htag2: TTagObject;
  sNum, sTagClass, sTag, sTagText, sCellText, sText, sUrl: string;
  {
    TagName = имя тега без кавычек
    Text  =  весь тэг с кавычками и параметрами
    !Если тэг самозакрывающися( />) то в параметрах появится строка /
    Position = ??позиция тэга в документе??
    Current  =  позиция символа текущего тэга в документе  (самозакрывающися тег за два тега)
  }
begin
  ht := THTMLParser.Create;
  ht.LoadFromStrings(Str);
  htag := ht.First;
  Result := 0;
  StrGrd.FixedRows := 0;
  StrGrd.Cols[0].Clear;
  StrGrd.Rows[0].Clear;
  StrGrd.ColCount := 1;
  StrGrd.RowCount := 1;
  grdRow := 1; // разместить в первой строке счетчик
  grdCol := 0;
  iDiv := 0;
  iTD := 0;
  iTR := 0;
  iTH := 0;
  iTable := 0;
  sCellText := '';
  repeat
    sTagClass := '';
    htag.Position := ht.Current; // для правильной работы innerText
    sTag := htag.TagName;
    sTagText := htag.text;
    sText := Trim(htag.innertext); { DONE 5 : Найти способ вытащить текст между тегами }
    if htag.Properties <> nil then
      // for P := 0 to htag.Properties.Count - 1 do
        sTagClass := AnsiDequotedStr(htag.Properties.Values['class'], '"');
    if sTag = '/div' then
      if iDiv > 0 then Dec(iDiv);
    if sTag = 'div' then inc(iDiv);
    if iDiv > 0 then
    begin
      if sTagClass = 'pagination' then // ищем ссылку на след сраницу
      begin
        { DONE : Парсер ссылок на страницу }
        while sTag <> '/div' do // парсим таблицу
        begin
          sTagText := htag.text;
          sText := Trim(htag.innertext); { DONE 5 : Найти способ вытащить текст между тегами }
          if (sTag = 'a') then
            if pos('Следующая', sText) > 0 then
              if htag.Properties <> nil then
              begin
                sUrl := AnsiDequotedStr(htag.Properties.Values['href'], ''''); // ссылка на запчасть
                sUrl := AnsiDequotedStr(sUrl, '"'); // ссылка на запчасть
                StrGrd.Cells[1, 0] := sUrl;
              end;
          htag := ht.Next;
          sTag := htag.TagName;
          htag.Position := ht.Current; // для правильной работы innerText
        end;
      end;
        if sTagClass = 'count' then
        begin
          sText := Trim(htag.innertext);
          if pos('Найдено', sText) > 0 then
          begin
            sNum := StripNonNumeric(sText);
            iNum := strtoint(sNum); // кол-во найденных позиций
            StrGrd.Cells[0, 0] := sNum;
          end;
        end;
    end;
    if sTag = '/table' then
      if iTable > 0 then Dec(iTable);
    if sTag = 'table' then
      if sTagClass = 'main-list' then inc(iTable);
    if iTable > 0 then
    begin
      if (sTag = 'a') then
        if (grdCol = 0) and (iTD > 0) then
          if htag.Properties <> nil then
          begin
            sUrl := AnsiDequotedStr(htag.Properties.Values['href'], ''''); // ссылка на запчасть
            sUrl := AnsiDequotedStr(sUrl, '"'); // ссылка на запчасть
          end;
      if (grdCol = 0) and (grdRow > 1) then sCellText := sUrl;
      if (sTag = '/th') or (sTag = '/td') then
      begin
        if sTag = '/th' then Dec(iTH);
        if sTag = '/td' then Dec(iTD);
        StrGrd.Cells[grdCol, grdRow] := Trim(sCellText + ' ' + sText);
        inc(grdCol); // колонка
        if StrGrd.ColCount < grdCol then StrGrd.ColCount := grdCol+1;
        sCellText := '';
      end;
      if (sTag = 'th') or (sTag = 'td') then // заголовок таблицы
      begin
        if sTag = 'th' then inc(iTH);
        if sTag = 'td' then inc(iTD);
        sCellText := sText;
      end;
      if sTag = '/tr' then
      begin
        Dec(iTR);
        inc(grdRow); // колонка
        if StrGrd.RowCount < grdRow then StrGrd.RowCount := grdRow+1;
        grdCol := 0;
        sUrl:='';
      end;
      if sTag = 'tr' then   inc(iTR); // новая строка таблицы
    end;
    htag := ht.Next;
    // sTag := htag.TagName;
    // htag.Position := ht.Current; // для правильной работы innerText
  until htag = nil;
  ht.free;
  Result := grdRow-2;
end;

function GetImgs(sHTML: string; var dImgs: _Imgs): integer;
var
  Tag: _Tag;
  P, I: integer;
  // gm: array of Byte;
begin
  P := 1;
  I := 0;
  Tag.params := TStringList.Create;
  while P > 0 do
  begin
    P := PosEx('<img', sHTML, P);
    if P > 0 then
    begin
      SetLength(dImgs, I + 1);
      GetTag(sHTML, '<', '>', P, Tag);
      dImgs[I].URL := AnsiDequotedStr(Tag.params.Values['src'], '"');
      dImgs[I].name := GenName;
      { TODO : добавить парсер расширения файла картинки }
      // GetImg(dImgs[i]);
      inc(I);
    end;
  end;
  Tag.params.free;
end;

function ArrayToStr(dStr: array of Byte): string;
var
  I: integer;
begin
  Result := '';
  // if dstr = nil then
  // Exit;
  for I := low(dStr) to high(dStr) do Result := Result + IntToHex(dStr[I], 2);
end;


// ==========================================

procedure TParseHTML.parse(FileName: string);
var
  buf: String;
  Str: TStrings;
  StringGrd: TStringGrid;

begin
  { if Button1.Tag=1 then
    begin
    Button1.Caption:='Parse';
    Button1.Tag:=0; //stop
    Exit;
    end;
    Button1.Tag:=1; //start
    Button1.Caption:='Stop';
  }
  Str := TStringList.Create;
  Str.LoadFromFile(FileName);
  buf := Str.text;
  Str.free;
  StringGrd := TStringGrid.Create(nil);

  // StrGrd.Assign(ParseTable(Buf));
  ParseTable2(buf, StringGrd);
  /// ...,...  form1.StrGrd0.Assign(StringGrd);
  // ParseTable(buf, StrGrd);
  {
    Button1.Caption:='Parse';
    Button1.Tag:=0; //stop
  }

  StringGrd.free;
end;

function TParseHTML.GetTagName(buf: string; var pos, n1, n2, l2, len: integer): string;
// var

// pos=текущаяя позиция в тексте
// n1 = начало содержимого(имени) тэга
// n2 = конец имени тэга
// l2 = конец содержимого тэга
// len = длина содержимого тэга

// n1,n2,len,l2: integer;
begin
  n1 := PosEx('<', buf, pos);
  if n1 = 0 then Abort;
  inc(n1);
  n2 := PosEx('>', buf, n1);
  // if buf[n2-1]='/' then
  l2 := n2;
  len := n2 - n1;
  n2 := FirstDelimiter(' >', buf, n1); // first word after <
  Result := MidStr(buf, n1, n2 - n1);
end;

function TParseHTML.FirstDelimiter(const Delimiters, S: string; StartPos: integer): integer;
var
  P: PChar;
begin
  Result := StartPos; // Length(S);
  P := PChar(Delimiters);
  while Result < Length(S) do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then inc(Result)
      else Exit;
    inc(Result);
  end;
end;

function TParseHTML.GetTag(buf, tagIn, tagOut: string; var iPos: integer; var Tag: _Tag): boolean;
{ Функция вычитает имя, параметры тега и его текст, игнорируя некоторые текстовые коды до самого конца тега.
  Так же читает весь тескт внутри тега и все параметры с тегом от начала и до конца .
}
var
  S, sk: string;
  iCountTag, iStartTag, n1, n2, len, l2: integer;
begin // <<<----------
  try
    Result := false;
    S := '';
    sk := '';
    iCountTag := 0; // кол-во вложенных таких же тегов
    iStartTag := iPos; // начало тега
    Tag.name := '';
    Tag.text := '';
    Tag.params.Clear;
    // s:=buf[pos];  //test
    Tag.name := GetTagName(buf, iPos, n1, n2, l2, len); // имя тега
    if (n1 = 0) then Exit;

    iPos := n2;
    // --
    if buf[iPos] <> '>' then
      while iPos < l2 do // читаем параметры до конца скобки тега
      begin
        n1 := iPos + 1;
        iPos := FirstDelimiter(' >"', buf, n1);
        // поиск первого разделителя параметров
        if buf[iPos] = '"' then
        begin
          iPos := FirstDelimiter('>"', buf, iPos + 1);
          // поиск следующего разделителя параметра
          if buf[iPos] = '"' then inc(iPos);
        end;
        if n2 = 0 then iPos := len + 1;
        S := MidStr(buf, n1, iPos - n1);
        Tag.params.Append(S); // добавить новый параметр тега
      end;
    // pos:=n2;
    // --
    sk := '';
    S := ''; // читаем текст внутри тега кроме вложенных тегов
    while (S = '') or (S = 'a') or (S = '/a') or (S = 'br') or (S = 'br /') or (S = 'b') or (S = 'ul') or (S = '/ul') or
      (S = 'div') or (S = '/div') or (S = '/b') or (S = '/td') or (S = '/tr') or (S = 'font') or (S = '/font') or
      (S = 'span') or (S = '/span') do
    // span /span , i /i , br /br
    begin
      n1 := PosEx('>', buf, iPos);
      /// ищем закрывающий знак
      if n1 = 0 then // ненайден > Выход
          break;
      inc(n1);
      n2 := PosEx('<', buf, iPos);
      sk := sk + MidStr(buf, n1, n2 - n1); // строка между > <
      iPos := n2;
      S := GetTagName(buf, iPos, n1, n2, l2, len);
      if buf[l2 - 1] = '/' then // тег заканчивается сразу без завершающего тега
          break; // !!! { TODO : перепроверить!!! учесть счетчик тегов }
      if S = Tag.name then
      begin
        inc(iCountTag); // встретили вложенный одноименный тег = учтем его
        S := '';
      end;
      if S = '/' + Tag.name then
      begin
        if iCountTag = 0 then break; // найден закрывающий тег = Выход
        Dec(iCountTag);
      end;
      if pos('br', S) > 0 then // перевод строки на пробел
          sk := sk + ' ';
      if pos('span', S) > 0 then // перевод строки на пробел
          sk := sk + ' ';
    end;
    Tag.text := sk;
    Tag.HTML := MidStr(buf, iStartTag, l2 - iStartTag + 1); // копируем все содержимое тега с его именем
    Result := true;
  except
  end;
end;

function TParseHTML.ParseTable(HTML: string; StrGrd: TStringGrid): integer;
var
  Tag: _Tag;

  td, tr, table: string;
  Index, iPos, posEnd: integer;
begin // <<<<<<<<<<<<<<<<<<<<<<<<<<<<

  td := 'td'; // ячейка
  tr := 'tr'; // строка
  table := 'table';
  Tag.params := TStringList.Create;
  iPos := 1;
  index := 0;
  StrGrd.FixedRows := 0;
  StrGrd.Cols[0].Clear;
  StrGrd.Rows[0].Clear;
  StrGrd.ColCount := 1;
  StrGrd.RowCount := 1;
  try
    Tag.name := 'table';
    Tag.params.Add('class="main-list"'); // таблица
    if FindTag(HTML, Tag, iPos) then
    begin
      posEnd := FindTagClose(HTML, Tag, iPos); // поиск закрывающего тега
      Tag.name := 'tr';
      Tag.params.Values['class'] := '"  "';
      if FindTag(HTML, Tag, iPos) then // строка начала
      begin
        GetTable(HTML, iPos, posEnd); // выбор табличных данных с начала и до конца позиций
      end;
    end;
  finally

  end;
end;

function TParseHTML.GetTable(HTML: string; var iPos, iPosEnd: integer): boolean;
var
  row, clm: integer;
  Tag: _Tag;
  TagName, TagClass: string;
  NewLine: boolean;
begin
  Tag.params := TStringList.Create;
  Result := false;
  row := 0;
  clm := 0;
  while (GetTag(HTML, '<', '>', iPos, Tag)) and (iPos < iPosEnd) do
  begin
    if Tag.name = 'tr' then
      if Tag.params.Values['class'] = '"  "' then
      begin
        inc(row);
        clm := 0;
        // Form1.StrGrd0.RowCount := row + 1;
        { DONE : ошибка перехода на новую строку в гриде , возможно некоректно определ. конец тек. строки в html таблице }
      end;
    if Tag.name = 'td' then
    begin
      // Form1.StrGrd0.Cells[clm, row] := Trim(Tag.text);
      inc(clm);
      // Form1.StrGrd0.ColCount := clm + 1;
    end;
  end;
end;

function TParseHTML.FindTag(HTML: string; var Tag: _Tag; var iPos: integer): boolean;
var
  // Tag: _Tag;
  TagName, TagClass: string;
begin
  TagName := Tag.name;
  TagClass := Tag.params.Values['class'];
  Result := false;
  while GetTag(HTML, '<', '>', iPos, Tag) do
  begin
    if Tag.name = TagName then
      if Tag.params.Values['class'] = TagClass then
      begin
        Result := true;
        Exit;
      end;
  end;
end;

function TParseHTML.FindTagClose(HTML: string; var Tag: _Tag; var iPos: integer): integer;
var
  // Tag: _Tag;
  TagName, TagClass: string;
begin
  TagName := Tag.name;
  TagClass := Tag.params.Values['class'];
  Result := -1;
  while GetTag(HTML, '<' + Tag.name, '/' + Tag.name + '>', iPos, Tag) do
  begin
    if Tag.name = TagName then { TODO : проверить! }
      if Tag.params.Values['class'] = TagClass then
      begin
        Result := iPos;
        Exit;
      end;
  end;
end;

function ParseTable1(HTML: string; StrGrd: TStringGrid): integer;
var
  Tag: _Tag;
  td, tr, table: string;
  Index, pos: integer;
begin // <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  td := 'td'; // ячйека
  tr := 'tr'; // строка
  table := 'table';
  Tag.params := TStringList.Create;
  pos := 1;
  index := 0;
  StrGrd.FixedRows := 0;
  StrGrd.Cols[0].Clear;
  StrGrd.Rows[0].Clear;
  StrGrd.ColCount := 4;
  StrGrd.RowCount := 0;
  try
    while Tag.name <> '' do
    begin
      if Tag.name = td then
        if Tag.params.Values['class'] = 'N' then StrGrd.Cells[0, index] := Tag.text;
      if Tag.params.Values['class'] = 'N3' then
      begin
        StrGrd.Cells[1, index] := Tag.text;
        inc(index);
      end;
    end;
    Result := index; // кол-во строк !!!
  except
  end;

end;

constructor TParseHTML.Create;
begin
  inherited Create;
end;

destructor TParseHTML.Destroy;
begin
  inherited Destroy;
end;

end.
