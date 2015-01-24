unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wininet,   IdHttp, idftp, IdComponent,  idglobal,System.Math, IdFTPCommon,


  ComCtrls, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit; //<-строка для УРЛа
    Label1: TLabel;
    BtnDownload: TButton;
    BtnStop: TButton; //<-кнопка Stop
    ProgressBar1: TProgressBar;
    EdFilename: TEdit;
    Label2: TLabel;
    StatusBar1: TStatusBar;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton; //<-декорация
    procedure BtnDownloadClick(Sender: TObject); //<-|процедура начала скачки
    procedure BtnStopClick(Sender: TObject); //<-|принудительный обрыв
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    procedure HttpWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure HttpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    { Private declarations }
  public
    { Public declarations }
  end;

var
    TotalBytes: Int64;
    LastWorkCount: Int64;
    LastTicks: LongWord;
  Form1: TForm1;
  stop: boolean; //<-|вспомогательная переменная отв. за
  //  |остановку скачки
implementation
{$R *.DFM}

uses Unit2;

 { lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  lpdwReserved: pointer): BOOL; stdcall;
    external 'wininet.dll' name 'HttpQueryInfoW'; }



procedure TForm1.BtnDownloadClick(Sender: TObject);

function SizeQuery(hRequest: pointer; out Size : cardinal): boolean;
var
  RSize,rv : cardinal;
  p : pointer;
begin
  RSize  := 4;
  result := HttpQueryInfoW(hRequest,
    HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER,
    @Size, RSize, rv);
  if NOT result then Size := 0;
end;
var
  hInet, //<-переменная сод. указатель на сессию
  hURL: HINTERNET; //<-указатель на URL
  fSize, //<-размер файла
  ReadLen, //<-количество реально прочитанных байт
  RestartPos: DWORD; //<-|позиция с которой начинается
  //  |докачка
  fBuf: array[1..1024] of byte; //<-буфер куда качаем
  f: file; //<-файл куда качаем
  Header: string; //<-|дополнительная переменная в HTTP
  //  |заголовок

begin
ReadLen:=1;
  RestartPos := 0; //<- |инициализация
  fSize := 0; //<- |переменных
  BtnDownload.Enabled := false;
  BtnStop.Enabled := true;
    StatusBar1.Panels.Items[0].Text:='Start download...';
  //Если на винте есть файл то считаем, что нужно докачивать
  if FileExists(EdFilename.Text) then
  begin
    AssignFile(f, EdFilename.Text);
    Reset(f, 1);
    RestartPos := FileSize(F);
    Seek(F, FileSize(F));
      StatusBar1.Panels.Items[0].Text:='FileExists! Restart download...';
  end
  else
  begin
    //иначе с начала
    AssignFile(f, EdFilename.Text);
    ReWrite(f, 1);
//     StatusBar1.Panels.Items[0].Text:='download...';
  end;
  //открываем сессию
  hInet := InternetOpen('Mozilla',
    PRE_CONFIG_INTERNET_ACCESS,
    nil,
    nil,
    0);
  //Пишем дополнительную строку для заголовка
  Header := 'Accept: */*';
  //открываем URL
  hURL := InternetOpenURL(hInet,
    PChar(Edit1.Text),
    pchar(Header),
    StrLen(pchar(Header)),
    0,
    0);
  //устанавливаем позицию в файле для докачки
  if RestartPos > 0 then
    InternetSetFilePointer(hURL,
      RestartPos,
      nil,
      0,
      0);
  //смотрим ск-ко надо скачать
 SizeQuery(hURL,fSize);
//  InternetQueryDataAvailable(hURL, fSize, 0, 0);
  if RestartPos > 0 then
  begin
    ProgressBar1.Min := 0;
    ProgressBar1.Max := fSize + RestartPos;
    ProgressBar1.Position := RestartPos;
  end
  else
  begin
    ProgressBar1.Min := 0;
    ProgressBar1.Max := fSize + RestartPos;
  end;
  //качаем до тех пор пока реально прочитаное число байт не
  //будет равно нулю или не стор
  while (ReadLen <> 0) and (stop = false) do
  begin
    //читаем в буфер
    InternetReadFile(hURL, @fBuf, SizeOf(fBuf), ReadLen);
    //смотрим ск-ко осталось докачать
    InternetQueryDataAvailable(hURL, fSize, 0, 0);
    ProgressBar1.Position := ProgressBar1.Max - fSize;
    BlockWrite(f, fBuf, ReadLen); //<-пишем в файл
    Application.ProcessMessages;
  end;
  stop := false;
  BtnDownload.Enabled := true;
  BtnStop.Enabled := false;
  InternetCloseHandle(hURL); //<-|закрываем
  InternetCloseHandle(hInet); //<-|сесcии
  CloseFile(f); //<-|и файл
   StatusBar1.Panels.Items[0].Text:='Download complete.';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  stop := false; //<-прервать скачку
  BtnStop.Enabled := false; //<-кнопка останова скачки
with  StatusBar1.Panels.Add do
begin
  Text:='Start application complete.';
end;
end;

procedure TForm1.BtnStopClick(Sender: TObject);
begin
  stop := true; //<-сообщаем о необходимости прерывания скачки
  StatusBar1.Panels.Items[0].Text:='Stop download!';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    if FileExists(EdFilename.Text) then
  DeleteFile(EdFilename.Text);

end;

procedure TForm1.Button2Click(Sender: TObject);
const
  IFRAME_SRC = '<iframe src="';
var
  HttpCli: TIdHttp;
  S, URL, FileName: string;
  I: Integer;
  FS: TFileStream;
begin
 { URL := 'http://liga-updates.ua.tc/GDI+.zip';

  HttpCli := TIdHttp.Create(nil);
  try
    HttpCli.URL := URL;
    HttpCli.MultiThreaded := True;
    try
      HttpCli.Get;
    except
      // this will always be 404 for this domain (test from outside the IDE)
    end;
    S := HttpCli.LastResponse; // THttpCli returns valid response when status 404
    // extract IFRAME src
    I := Pos(IFRAME_SRC, S);
    if I <> 0 then
    begin
      Delete(S, 1, I + Length(IFRAME_SRC) - 1);
      URL := Copy(S, 1, Pos('"', S) - 1);
      HttpCli.URL := URL;
      FileName := ExtractFileName(StringReplace(URL, '/', '\', [rfReplaceAll]));
      FS := TFileStream.Create(FileName, fmCreate);
      try
        HttpCli.RcvdStream := FS;
        try
          HttpCli.Get;
          ShowMessage('Downaloded OK');
        except
          ShowMessage('Unable to download file.');
        end;
      finally
        FS.Free;
      end;
    end
    else
      ShowMessage('Unable to extract download information.');
  finally
    HttpCli.Free;
  end;
         }
end;


procedure TForm1.HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  if AWorkMode <> wmRead then Exit;

  // initialize the status UI as needed...
  //
  // If TIdHTTP is running in the main thread, update your UI
  // components directly as needed and then call the Form's
  // Update() method to perform a repaint, or Application.ProcessMessages()
  // to process other UI operations, like button presses (for
  // cancelling the download, for instance).
  //
  // If TIdHTTP is running in a worker thread, use the TIdNotify
  // or TIdSync class to update the UI components as needed, and
  // let the OS dispatch repaints and other messages normally...

  TotalBytes := AWorkCountMax;
  LastWorkCount := 0;
  LastTicks := Ticks;
end;

procedure TForm1.HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  PercentDone: Integer;
  ElapsedMS: int16;
  BytesTransferred: Int64;
  BytesPerSec: Int64;
begin
  if AWorkMode <> wmRead then Exit;

  ElapsedMS := GetTickDiff(LastTicks, Ticks);
  if ElapsedMS = 0 then ElapsedMS := 1; // avoid EDivByZero error

  if TotalBytes > 0 then
    PercentDone := Floor(((AWorkCount) / TotalBytes) * 100)
  else
    PercentDone := 0;

  BytesTransferred := AWorkCount - LastWorkCount;

  // using just BytesTransferred and ElapsedMS, you can calculate
  // all kinds of speed stats - b/kb/mb/gm per sec/min/hr/day ...
  BytesPerSec := floor(((BytesTransferred) * 1000) / ElapsedMS);

  // update the status UI as needed...

  LastWorkCount := AWorkCount;
  LastTicks := Ticks;
end;

procedure TForm1.HttpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  if AWorkMode <> wmRead then Exit;

  // finalize the status UI as needed...
end;

procedure TForm1.Button3Click(Sender: TObject);
var
_idftp: tidftp;
begin
_idftp:=tidftp.Create(nil);
 with _IdFTP do
 begin
  try
//  CurrentTransferMode.:=
OnWorkBegin := HttpWorkBegin;
      OnWork := HttpWork;
      OnWorkEnd := HttpWorkEnd;
   Username:='avtoefi';
   Password:='RuR7nSTh7IZo';
   Host:='ftp.servage.net';
   Passive:=True;
   Connect;
   TransferType:=ftBinary;
   except
     ShowMessage('net');
  end;
  if Connected then
  begin
      try
      Put(Application.ExeName,ExtractFileName(Application.ExeName), False);
   ShowMessage('Загружен');
    except
     on e:Exception do ShowMessage('Не загружен : '+ e.Classname + ' ' + e.Message);
    end;
end;
free;
 end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
fWorkThread: WorkThread;
begin
fWorkThread := WorkThread.create(false);
//fWorkThread.FreeOnTerminate := False;
//fWorkThread.Start;
while fWorkThread <>nil do
   Application.ProcessMessages;
//fWorkThread.Start;
end;

end.
