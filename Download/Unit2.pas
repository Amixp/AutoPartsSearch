unit Unit2;

interface

uses
  Forms, SysUtils, Classes, IdFtp, IdComponent;

type
  WorkThread = class(TThread)
  private
    ftpHost, ftpDir, ftpFile, ftpLocalPath, ftpUser, ftpPasswd: String;
    aFtp: TIdFTP;
    destructor Destroy;
  protected
    constructor Create(CreateSuspended: boolean);
    procedure Execute; override;
    procedure FTPWork(Sender: TObject; AWorkMode: TWorkMode;
       AWorkCount: Int64);
    procedure FTPWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
  end;

implementation

uses  Unit1;

{ WorkThread }
procedure WorkThread.FTPWork(Sender: TObject; AWorkMode: TWorkMode;
   AWorkCount: Int64);
begin
  Form1.ProgressBar1.Position := AWorkCount;
end;

procedure WorkThread.FTPWorkBegin(Sender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  Form1.ProgressBar1.Max := aFtp.Size(ftpFile);
end;

constructor WorkThread.Create;
begin
  ftpHost := 'ftp.servage.net';
  ftpDir := '/';
  ftpFile := ExtractFileName(Application.ExeName)+'_';
  ftpUser := 'avtoefi';
  ftpPasswd := 'RuR7nSTh7IZo';
  ftpLocalPath :=  Application.exename;
  aFtp := TIdFTP.Create(nil);
  aFtp.OnWork := FTPWork;
  aFtp.OnWorkBegin := FTPWorkBegin;
  inherited Create(CreateSuspended);
end;

destructor WorkThread.Destroy;
begin
  aFtp.Free;
  inherited Destroy;
end;

procedure WorkThread.Execute;
begin
  { Place thread code here }
  if aftp=nil then Exit;

  aFtp.Connect;
  aFtp.ChangeDir(ftpDir);
  aFtp.Get(ftpFile, ftpLocalPath);
  aFtp.Disconnect;
end;

end.
