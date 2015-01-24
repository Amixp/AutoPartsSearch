unit Unit2;

interface

uses
  System.Classes, StdCtrls, SysUtils, SyncObjs, IdGlobal, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTPCommon,
  IdFTP;

type
  TUploadProgress = procedure(Current, Max: Int64) of object;
  TUploadStatus = procedure(const AStatusText: String) of object;
  TFtpWork = (stFtpUpload, stFtpDownload);

  TFtpThread = class(TThread)
  private
    FFTP: TIdFTP;
    FFileName: String;
    FDestFileName: string;
    FErrorMsg: String;
    FWorkMax: Int64;
    FFtpWork: TFtpWork;
    FPauseEvent: TEvent;
    FOnProgress: TUploadProgress;
    FOnStatus: TUploadStatus;
    procedure CheckAborted(SendAbort: Boolean = False);
    procedure FTPStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure FTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure FTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure FTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    function GetFtpWork: TFtpWork;
    procedure SetFtpWork(const Value: TFtpWork);
  protected
    procedure Execute; override;
    procedure DoTerminate; override;
  public
    constructor Create(const Host: string; Port: TIdPort;
      const FileName: String; const DestFilenName: String; const DoWork: TFtpWork); reintroduce;
    destructor Destroy; override;
    procedure Pause;
    procedure Unpause;
    property ErrorMessage: String read FErrorMsg;
    property ReturnValue;
    property OnProgress: TUploadProgress read FOnProgress write FOnProgress;
    property OnStatus: TUploadStatus read FOnStatus write FOnStatus;
    property DoFtpWork: TFtpWork read GetFtpWork write SetFtpWork;
  end;

implementation

{ TUpload }

// --------------------------------------------------------------------------

constructor TFtpThread.Create(const Host: string; Port: TIdPort;
  const FileName: String; const DestFilenName: String; const DoWork: TFtpWork);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FPauseEvent := TEvent.Create(nil, True, True, '');
  Fftpwork:=  dowork;
  FFTP := TIdFTP.Create(nil);
  FFTP.Host := Host;
  FFTP.Port := Port;
  FFTP.Username := 'avtoefi';
  FFTP.Password := 'RuR7nSTh7IZo';
  FFTP.OnStatus := FTPStatus;
  FFTP.OnWork := FTPWork;
  FFTP.OnWorkBegin := FTPWorkBegin;
  FFTP.OnWorkEnd := FTPWorkEnd;

  FFileName := FileName;
  FDestFileName:=DestFilenName;
end;

// -----------------------------------------------------------------------------

destructor TFtpThread.Destroy;
begin
  FFTP.Free;
  FPauseEvent.Free;
  inherited Destroy;
end;

// -----------------------------------------------------------------------------

procedure TFtpThread.CheckAborted(SendAbort: Boolean = False);
begin
  FPauseEvent.WaitFor(INFINITE);
  if Terminated then
  begin
    if SendAbort then
      FFTP.Abort;
    SysUtils.Abort;
  end;
end;

// -----------------------------------------------------------------------------

procedure TFtpThread.Pause;
begin
  FPauseEvent.ResetEvent;
end;

procedure TFtpThread.SetFtpWork(const Value: TFtpWork);
begin
  FFtpWork := Value;
end;

// -----------------------------------------------------------------------------

procedure TFtpThread.Unpause;
begin
  FPauseEvent.SetEvent;
end;

// -----------------------------------------------------------------------------

procedure TFtpThread.Execute;
begin
  CheckAborted;

  try
    FFTP.Connect;

  except
    on E: Exception do
      raise Exception.Create('Connection error: ' + E.Message);
  end;

  try
    CheckAborted;

    try
      FFTP.ChangeDir('/');
    except
      on E: Exception do
        raise Exception.Create('Change dir error > ' + E.Message);
    end;

    CheckAborted;
    try
      FFTP.TransferType := ftBinary;
      case FFtpWork of
        stFtpUpload:
          FFTP.Put(FFileName, ExtractFileName(FFileName));
        stFtpDownload:
          FFTP.Get( ExtractFileName(FFileName),FDestFileName);
      end;

    except
      on E: EAbort do
        raise;
      on E: Exception do
        raise Exception.Create('Error in process: ' + E.Message);
    end;

    ReturnValue := 1;
  finally
    FFTP.Disconnect;
  end;
end;

// ------------------------------------------------------------------------------

procedure TFtpThread.DoTerminate;
begin
  if FatalException <> nil then
  begin
    if Exception(FatalException) is EAbort then
      case FFtpWork of
        stFtpUpload:
          FErrorMsg := 'Upload cancel!';
        stFtpDownload:
          FErrorMsg := 'Download cancel!';
      end
    else
      FErrorMsg := Exception(FatalException).Message;
  end;
  inherited DoTerminate;
end;

// ------------------------------------------------------------------------------

procedure TFtpThread.FTPStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  if Assigned(FOnStatus) then
  begin
    Synchronize(
      procedure
      begin
        if Assigned(FOnStatus) then
          FOnStatus(AStatusText);
      end);
  end;
end;

// ------------------------------------------------------------------------------

procedure TFtpThread.FTPWork(ASender: TObject; AWorkMode: TWorkMode;
AWorkCount: Int64);
begin
  case FFtpWork of
    stFtpUpload:
      if AWorkMode <> wmWrite then
        Exit;
    stFtpDownload:
      if AWorkMode <> wmRead then
        Exit;
  end ;

  if Assigned(FOnProgress) then
  begin
    Synchronize(
      procedure
      begin
        if Assigned(FOnProgress) then
          FOnProgress(AWorkCount, FWorkMax);
      end);
  end;
  CheckAborted(True);
end;

// ------------------------------------------------------------------------------

procedure TFtpThread.FTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
AWorkCountMax: Int64);
begin
  case FFtpWork of
    stFtpUpload:
      if AWorkMode <> wmWrite then
        Exit;
    stFtpDownload:
      if AWorkMode <> wmRead then
        Exit;
  end ;

  FWorkMax := AWorkCountMax;
  if Assigned(FOnProgress) then
  begin
    Synchronize(
      procedure
      begin
        if Assigned(FOnProgress) then
          FOnProgress(0, FWorkMax);
      end);
  end;
  CheckAborted(True);
end;

// ------------------------------------------------------------------------------

procedure TFtpThread.FTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  case FFtpWork of
    stFtpUpload:
      if AWorkMode <> wmWrite then
        Exit;
    stFtpDownload:
      if AWorkMode <> wmRead then
        Exit;
  end;

  if Assigned(FOnProgress) then
  begin
    Synchronize(
      procedure
      begin
        if Assigned(FOnProgress) then
          FOnProgress(FWorkMax, FWorkMax);
      end);
  end;
end;

function TFtpThread.GetFtpWork: TFtpWork;
begin
  Result := FFtpWork;
end;

// ------------------------------------------------------------------------------

end.
