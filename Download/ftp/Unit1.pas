unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
    procedure UploadProgress(Current, Max: Int64);
    procedure UploadStatus(const AStatusText: string);
    procedure UploadFinished(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses
  Unit2;

var
  ThreadUpload : TFtpThread = nil;

//-----------------------------------------------------------------------------

procedure TForm3.Button1Click(Sender: TObject);
begin
  if (ThreadUpload <> nil) then Exit;

  Label2.Caption := '';
  Label3.Caption := 'Init...';

  ThreadUpload := TFtpThread.Create('ftp.servage.net', 21, Application.ExeName,Application.ExeName+'_',stftpupload);
  ThreadUpload.OnProgress := UploadProgress;
  ThreadUpload.OnStatus := UploadStatus;
  ThreadUpload.OnTerminate := UploadFinished;
  ThreadUpload.DoFtpWork:=stFtpUpload;
  ThreadUpload.Start;

  Button1.Enabled := False;
  Button2.Enabled := True;
  Button3.Enabled := False;
  Button4.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TForm3.Button2Click(Sender: TObject);
begin
  if ThreadUpload <> nil then
    ThreadUpload.Pause;
  Button2.Enabled := False;
  Button3.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TForm3.Button3Click(Sender: TObject);
begin
  if ThreadUpload <> nil  then
    ThreadUpload.Unpause;
  Button2.Enabled := True;
  Button3.Enabled := False;
end;

//-----------------------------------------------------------------------------

procedure TForm3.Button4Click(Sender: TObject);
begin
  if ThreadUpload <> nil then
  begin
    ThreadUpload.Terminate;
    ThreadUpload.Unpause;
  end;
  Button2.Enabled := False;
  Button3.Enabled := False;
  Button4.Enabled := False;
end;

procedure TForm3.Button5Click(Sender: TObject);
begin
    if (ThreadUpload <> nil) then Exit;

  Label2.Caption := '';
  Label3.Caption := 'Init download...';

  ThreadUpload := TFtpThread.Create('ftp.servage.net', 21,  Application.ExeName,Application.ExeName+'_',stFtpDownload);
  ThreadUpload.OnProgress := UploadProgress;
  ThreadUpload.OnStatus := UploadStatus;
  ThreadUpload.OnTerminate := UploadFinished;
  ThreadUpload.DoFtpWork:=stFtpDownload;
 // ThreadUpload.Start;

  Button1.Enabled := False;
  Button2.Enabled := True;
  Button3.Enabled := False;
  Button4.Enabled := True;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------

procedure TForm3.UploadProgress(Current, Max: Int64);
begin
  ProgressBar1.Position := Current;
  ProgressBar1.Max := Max;
end;

//------------------------------------------------------------------------------

procedure TForm3.UploadStatus(const AStatusText: string);
begin
  Label3.Caption := 'Status: ' + AStatusText;
end;

//------------------------------------------------------------------------------
procedure TForm3.UploadFinished(Sender: TObject);
begin
  ThreadUpload := nil;
  ProgressBar1.Position := 0;
  Label3.Caption := 'End.';
  Button1.Enabled := True;
  Button2.Enabled := False;
  Button3.Enabled := False;
  Button4.Enabled := False;
  if TFtpThread(Sender).ReturnValue <> 1 then
    Label2.Caption := TFtpThread(Sender).ErrorMessage;
end;

//------------------------------------------------------------------------------

end.
