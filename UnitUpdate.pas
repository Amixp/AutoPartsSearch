unit UnitUpdate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wininet, IdHTTP, IdFtp, IdComponent, Math,
  StdCtrls, ComCtrls;

type
  tidWorkType = (stFTP, stHTTP);

  tWorkThread = class(TThread)
  private
    fHost, fDir, fURL, fURLini, fFile, fFileini, fLocalPath, fUser,
      fPasswd: String;
    fFileSize: integer;
    aFtp: TIdFTP;
    aIdHTTP: TIdHTTP;
    fidWorkType: tidWorkType;
    fsizes: string;
    destructor Destroy;
    function GetUrlSize(const URL: string): integer;
  protected
    procedure Execute; override;
    procedure idWork(Sender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure idWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
  public
    constructor Create(idWorkType: tidWorkType; CreateSuspended: boolean);
      reintroduce;
  end;

  TUpdateApp = class
  private
    fURL: string;
    fFileName: string;
    fFileSize: integer;
    fUrlList: TStrings;
    fEnabled: boolean;
    function GetURL: String;
    procedure SetURL(const Value: String);
    function GetEnabled: boolean;
    function GetFileName: String;
    procedure SetFileName(const Value: String);
    procedure SetEnabled(const Value: boolean);
    constructor Create;
    destructor Destroy; override;
  published
    function CheckUpdate: boolean;
    procedure UpdateApp;
    function DownloadUrl: string;
    function UploadFile: boolean;
    property URL: String read GetURL write SetURL;
    property FileName: String read GetFileName write SetFileName;
    property Enabled: boolean read GetEnabled write SetEnabled;

  end;

implementation

{ WorkThread }

uses settings, MainUnit;

function tWorkThread.GetUrlSize(const URL: string): integer;
// результат в байтах

var
  IdHTTP: TIdHTTP;
begin
  Result := -1; // Ставим первоначальное значение -1, потом поймёте зачем
  IdHTTP := TIdHTTP.Create(nil);
  try
    aIdHTTP.Head(URL);
    // Мы получаем только заголовок нашего файла, где хранится размер файла, код запроса и т.п.
    if aIdHTTP.ResponseCode = 200 then
      // Если файл существует, то... (200 это успешный код: HTTP OK)
      Result := aIdHTTP.Response.ContentLength;
    // В результат пихаем наш размер файла в байтах.
  except
    IdHTTP.Free;
  end;

end;

procedure tWorkThread.idWork(Sender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  FormSettings.ProgressBar1.Position := AWorkCount;
  FormSettings.LbSize.Caption := floattostr(RoundTo(AWorkCount / (1024 * 1024),
    -2)) + ' MB.';
end;

procedure tWorkThread.idWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin

  FormSettings.ProgressBar1.Max := fFileSize;

end;

constructor tWorkThread.Create(idWorkType: tidWorkType;
  CreateSuspended: boolean);
begin
  fHost := 'http://avtoefi.ru/'; // 'ftp.servage.net';
  fDir := '/';
  fFile := ExtractFileName(Application.ExeName);
  fURL := fHost + fFile;
  fURLini := fHost + 'version.ini';
  fUser := 'avtoefi';
  fPasswd := 'RuR7nSTh7IZo';
  fLocalPath := Application.ExeName + '_';
  fFileini := ExtractFilePath(Application.ExeName) + 'version.ini';
  fidWorkType := idWorkType;
  case fidWorkType of
    stFTP:
      begin
        aFtp := TIdFTP.Create(nil);
        aFtp.OnWork := idWork;
        aFtp.OnWorkBegin := idWorkBegin;
      end;
    stHTTP:
      begin
        aIdHTTP := TIdHTTP.Create(nil);
        aIdHTTP.OnWork := idWork;
        aIdHTTP.OnWorkBegin := idWorkBegin;
      end;
  end;

  inherited Create(CreateSuspended);
end;

destructor tWorkThread.Destroy;
begin
  case fidWorkType of
    stFTP:
      aFtp.Free;

    stHTTP:
      aIdHTTP.Free;
  end;
  inherited Destroy;
end;

procedure tWorkThread.Execute;
const
  BufferSize = 1024;
var
  stream: TMemoryStream;
  FName: String;

begin
  stream := TMemoryStream.Create;

  { Place thread code here }
  if (aFtp = nil) and (aIdHTTP = nil) then
    Exit;
  case fidWorkType of
    stFTP:
      begin
        try
          aFtp.Connect;
          aFtp.ChangeDir(fDir);
          fFileSize := aFtp.Size(fFile);
          aFtp.Get(fFile, fLocalPath);
          aFtp.Disconnect;
        except
          // this will always be 404 for this domain (test from outside the IDE)
        end;
      end;
    stHTTP:
      begin
        // URL := 'http://liga-updates.ua.tc/GDI+.zip';

        try
          // check ini version
          FormMain.Log('Check ini from server...', 1);
          try
            aIdHTTP.Head(fURLini);
          except
            on E: Exception do
              Exit;
          end;
          // Мы получаем только заголовок нашего файла, где хранится размер файла, код запроса и т.п.
          if aIdHTTP.ResponseCode = 200 then
          begin
            FormMain.Log('Check ini from server OK! Download ini...', 1);
            aIdHTTP.Get(fURLini, stream); // Начинаем скачивание
            stream.SaveToFile(fFileini); // Сохраняем

            // ---------
            // aIdHTTP.URL.Host := fHost;
            // aIdHTTP.URL.Path:=fURL;
            // aIdHTTP.MultiThreaded := True;
            FormMain.Log('Check app from server ...', 1);
            try
              aIdHTTP.Head(fURL);
            except
              on E: Exception do
                Exit;
            end;
            // Мы получаем только заголовок нашего файла, где хранится размер файла, код запроса и т.п.
            if aIdHTTP.ResponseCode = 200
            then { TODO : Добавить чтение версии с ini и проверка с реальным }
            begin
              FormMain.Log('Check app from server OK! Download app...', 1);
              // Если файл существует, то... (200 это успешный код: HTTP OK)
              fFileSize := aIdHTTP.Response.ContentLength;
              // В результат пихаем наш размер файла в байтах.
              fsizes := floattostr(RoundTo(fFileSize / (1024 * 1024), -2));
              // Переводим в МБ
              FormMain.Log('Check app size... ' + inttostr(fFileSize), 1);
              try
                aIdHTTP.Get(fURL, stream); // Начинаем скачивание
              except
                on E: Exception do
                  Exit;
              end;
              stream.SaveToFile(fLocalPath); // Сохраняем
              FormSettings.UpdateStart := False;
              // замена старого файла программы на новый - скачанный, старый бэкап удалить
              if FileExists(Application.ExeName + '_') then
              begin
                if FileExists(Application.ExeName + '$bak') then
                  DeleteFile(Application.ExeName + '$bak');
                RenameFile(Application.ExeName, Application.ExeName + '$bak');
                RenameFile(Application.ExeName + '_', Application.ExeName);
                FormMain.Log('Update app from server OK!', 1);
              end;
            end;
          end;
        except
          // FreeAndNil(aIdHTTP); //Завершаем HTTP
          FreeAndNil(stream); // Завершаем Stream
        end

      end;
  end;
end;

{
  //Обновление программы
  idftp1.Get('/Update/'+UN,ND+NND+UN);
  Memo1.Lines.LoadFromFile(ND+NND+UN);
  UVersion:=copy(Memo1.Lines[0],pos(':',Memo1.Lines[0])+1,length(Memo1.Lines[0]));
  if not (UVersion=Ver) then begin
  Timer1.Interval := 14400000;
  UFName:=copy(Memo1.Lines[1],pos(':',Memo1.Lines[1])+1,length(Memo1.Lines[1]));
  DeleteFile(ND+NND+'\'+UFName+'.exe');
  showmessage(ND+NND+'\'+UFName+'.exe');
  idftp1.Get('/Update/'+UFName+'.exe', ND+NND+'\'+UFName+'.exe');
  WinExec(Pchar(ND+NND+'\'+UFName+'.exe'), SW_SHOWNORMAL);
  idFTP1.Disconnect;
  Close;
  end;
}
function TUpdateApp.CheckUpdate: boolean;
begin

end;

constructor TUpdateApp.Create;
begin
  inherited Create;

end;

destructor TUpdateApp.Destroy;
begin
  inherited Destroy;
  // procedure Free;
end;

function TUpdateApp.DownloadUrl: string;
var
  Buffer: TFileStream;
  HttpClient: TIdHTTP;
begin
  Buffer := TFileStream.Create(fFileName, fmCreate or fmShareDenyWrite);
  try
    HttpClient := TIdHTTP.Create(nil);
    try
      HttpClient.Get(fURL, Buffer); // wait until it is done
    finally
      HttpClient.Free;
    end;
  finally
    Buffer.Free;
  end;
end;

function TUpdateApp.GetEnabled: boolean;
begin
  Result := fEnabled;
end;

function TUpdateApp.GetFileName: String;
begin
  Result := fFileName;
end;

function TUpdateApp.GetURL: String;
begin
  Result := fURL;
end;

procedure TUpdateApp.SetEnabled(const Value: boolean);
begin
  fEnabled := Value;
end;

procedure TUpdateApp.SetFileName(const Value: String);
begin
  fFileName := Value;
end;

procedure TUpdateApp.SetURL(const Value: String);
begin
  fURL := Value;
end;

procedure TUpdateApp.UpdateApp;
begin

end;

function TUpdateApp.UploadFile: boolean;
begin

end;

{

  type
  TNoPresizeFileStream = class(TFileStream)
  procedure
  procedure SetSize(const NewSize: Int64); override;
  end;

  procedure TNoPresizeFileStream.SetSize(const NewSize: Int64);
  begin
  end;

  .
  type
  TSomeClass = class(TSomething)
  ...
  TotalBytes: In64;
  LastWorkCount: Int64;
  LastTicks: LongWord;
  procedure Download;
  procedure HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
  procedure HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  procedure HttpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  ...
  end;

  procedure TSomeClass.Download;
  var
  Buffer: TNoPresizeFileStream;
  HttpClient: TIdHttp;
  begin
  Buffer := TNoPresizeFileStream.Create('somefile.exe', fmCreate or fmShareDenyWrite);
  try
  HttpClient := TIdHttp.Create(nil);
  try
  HttpClient.OnWorkBegin := HttpWorkBegin;
  HttpClient.OnWork := HttpWork;
  HttpClient.OnWorkEnd := HttpWorkEnd;

  HttpClient.Get('http://somewhere.com/somefile.exe', Buffer); // wait until it is done
  finally
  HttpClient.Free;
  end;
  finally
  Buffer.Free;
  end;
  end;

  procedure TSomeClass.HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
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

  procedure TSomeClass.HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  var
  PercentDone: Integer;
  ElapsedMS: LongWord;
  BytesTransferred: Int64;
  BytesPerSec: Int64;
  begin
  if AWorkMode <> wmRead then Exit;

  ElapsedMS := GetTickDiff(LastTicks, Ticks);
  if ElapsedMS = 0 then ElapsedMS := 1; // avoid EDivByZero error

  if TotalBytes > 0 then
  PercentDone := (Double(AWorkCount) / TotalBytes) * 100.0;
  else
  PercentDone := 0.0;

  BytesTransferred := AWorkCount - LastWorkCount;

  // using just BytesTransferred and ElapsedMS, you can calculate
  // all kinds of speed stats - b/kb/mb/gm per sec/min/hr/day ...
  BytesPerSec := (Double(BytesTransferred) * 1000) / ElapsedMS;

  // update the status UI as needed...

  LastWorkCount := AWorkCount;
  LastTicks := Ticks;
  end;

  procedure TSomeClass.HttpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  begin
  if AWorkMode <> wmRead then Exit;

  // finalize the status UI as needed...
  end;
}

end.
