unit UnitParseTable;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Mask, JvExMask, JvToolEdit, StrUtils, ComCtrls,
  JvgStringGrid, JvFormPlacement, JvComponentBase, JvAppStorage,
  JvAppIniStorage;

type
  _Tag = record
    name, text: string;
    params: TStrings;
  end;

type
  TForm3 = class(TForm)
    JvFilenameEdit1: TJvFilenameEdit;
    Button1: TButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    StringGrid1: TStringGrid;
    JvAppIniFileStorage1: TJvAppIniFileStorage;
    JvFormStorage1: TJvFormStorage;
    procedure Button1Click(Sender: TObject);
  private
    function GetTag(buf, tagIn, tagOut: string; var pos: integer;
      var Tag: _Tag): boolean;
    function FirstDelimiter(const Delimiters, S: string;
      StartPos: integer): integer;
    function GetTagName(buf: string; var pos, n1, n2, l2, len: integer): string;
    procedure ParseTable(html: string; StrGrd: TStringGrid);
    { Private declarations }
  public
    { Public declarations }

  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
var
  buf: String;
  Str: TStrings;
begin
  if Button1.Tag = 1 then
  begin
    Button1.Caption := 'Parse';
    Button1.Tag := 0; // stop
    Exit;
  end;
  Button1.Tag := 1; // start
  Button1.Caption := 'Stop';
  Str := TStringList.Create;
  Str.LoadFromFile(JvFilenameEdit1.FileName);
  buf := Str.text;
  Str.Free;
  // StrGrd:=TStringGrid.Create(nil);
  // StrGrd.Assign(ParseTable(Buf));
  ParseTable(buf, StringGrid1);
  Button1.Caption := 'Parse';
  Button1.Tag := 0; // stop
end;

function TForm3.GetTagName(buf: string;
  var pos, n1, n2, l2, len: integer): string;
// var
// n1,n2,len,l2: integer;
begin
  n1 := PosEx('<', buf, pos);
  if n1 = 0 then
    Abort;
  inc(n1);
  n2 := PosEx('>', buf, n1);
  l2 := n2;
  len := n2 - n1;
  n2 := FirstDelimiter(' >', buf, n1); // first word after <
  Result := MidStr(buf, n1, n2 - n1);
end;

function TForm3.FirstDelimiter(const Delimiters, S: string;
  StartPos: integer): integer;
var
  P: PChar;
begin
  Result := StartPos; // Length(S);
  P := PChar(Delimiters);
  while Result < Length(S) do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      if (ByteType(S, Result) = mbTrailByte) then
        inc(Result)
      else
        Exit;
    inc(Result);
  end;
end;

function TForm3.GetTag(buf, tagIn, tagOut: string; var pos: integer;
  var Tag: _Tag): boolean;
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
    Tag.name := GetTagName(buf, pos, n1, n2, l2, len); // имя тега
    pos := n2;
    // --
    if buf[pos] <> '>' then
      while pos < l2 do
      begin
        n1 := pos + 1;
        pos := FirstDelimiter(' >"', buf, n1);
        if buf[pos] = '"' then
        begin
          pos := FirstDelimiter('>"', buf, pos + 1);
          if buf[pos] = '"' then
            inc(pos);
        end;
        if n2 = 0 then
          pos := len + 1;
        S := MidStr(buf, n1, pos - n1);
        Tag.params.Append(S);
      end;
    // pos:=n2;
    // --
    sk := '';
    S := '';
    while (S = '') or (S = 'b') or (S = '/b') or (S = '/td') or (S = '/tr') or
      (S = 'font') or (S = '/font') do
    begin
      n1 := PosEx(tagOut, buf, pos);
      if n1 = 0 then
        Abort;
      inc(n1);
      n2 := PosEx(tagIn, buf, n1);
      sk := sk + MidStr(buf, n1, n2 - n1); // строка между > <
      pos := n2;
      S := GetTagName(buf, pos, n1, n2, l2, len);
    end;
    Tag.text := sk;
    Result := true;
  except
  end;
end;

procedure TForm3.ParseTable(html: string; StrGrd: TStringGrid);

var
  Tag: _Tag;
  td, tr, th, table: string;
  iLine, iBlock, iPos, iColumn: integer;
  fParse, fTable: boolean;
begin // <<<<<<<<<<<<<<<<<<<<<<<<<<<<
  fParse := false; // начало парсинга таблицы с записями
  fTable := false; // ----v
  iBlock := 0; // начало парсинга строк с записами
  iColumn := 0; // текущая колонка таблице
  td := 'td'; // ячйека
  tr := 'tr'; // строка
  th := 'th';
  table := 'table';
  Tag.params := TStringList.Create;
  iPos := 1;
  iLine := 0;
  StrGrd.Cols[0].Clear;
  StrGrd.Rows[0].Clear;
  StrGrd.ColCount := 2;
  StrGrd.RowCount := 0;
  ProgressBar1.Max := Length(html);
  ProgressBar1.Position := 0;
  try
    GetTag(html, '<', '>', iPos, Tag);
    Label1.Caption := IntToStr(iPos);
    Label1.Refresh;
    while Tag.name <> '' do
    begin
      GetTag(html, '<', '>', iPos, Tag);
      Label1.Caption := IntToStr(iPos);
      Label1.Refresh;
      ProgressBar1.Position := iPos;
      ProgressBar1.Refresh;
      Application.ProcessMessages;
      if Button1.Tag = 0 then
        Abort; // stop
      // if tag.name='div' then
      // if Pos('header_str',tag.params.Text)>0 then
          if Tag.name='table' then
         begin
         //GetTag(html,'<','>',i,Tag);
         if Pos('class="texts"',tag.params.Text)>0 then
//         StrGrd.Cells[1,iLine]:=Tag.text;
     fParse := true;
          end;
          if Tag.name='/table' then
         begin
       fParse := false;
         end;
     if fParse then
      begin
        if Tag.name = tr then
        begin
          inc(iLine);
          iColumn:=0;
        end;
        if (Tag.name = td) or (Tag.name = th) then
        begin
          // if Pos('по запросу:',tag.text)>0 then
          // begin
          // StrGrd.Cells[0,iLine]:=Trim(RightStr(Tag.text,Length(Tag.text)-Pos(':',Tag.text)));
          // StrGrd.Cells[1,iLine]:=MidStr(Tag.text,1,Pos(':',Tag.text));
          // end;
          { if Pos('СТРАНИЦЫ',tag.text)>0 then
            begin
            Inc(iBlock);
            if iBlock=2 then tag.name:=''; //Exit;
            //   if fTable then tag.name:=''; //Exit;
            //   fTable:=not fTable;
            //   dec(iLine);
            end; }
          if Tag.name <> '' then
//            if iBlock = 1 then
            begin
//              if not fTable then
//                fTable := true
//              else
//              begin
                StrGrd.Cells[iColumn, iLine] := Trim(Tag.text);
                inc(iColumn);
                if iColumn >= StrGrd.ColCount then
                  StrGrd.ColCount := iColumn;
//              end;
              // if tag.params.Values['class']='N' then
              // StrGrd.Cells[0,index]:=Tag.text;
              // if tag.params.Values['class']='N3' then
              // StrGrd.Cells[1,index]:=Tag.text;
//            end;
        end;

        end;
      end;
    end;

    StrGrd.RowCount := iLine + 2;
    StrGrd.FixedRows := 1;
  except
  end;

end;

end.
