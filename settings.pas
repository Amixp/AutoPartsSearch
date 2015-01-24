unit settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IdMessageParts, IdExplicitTLSClientServerBase,
  Dialogs, StdCtrls, JvComponentBase, JvFormPlacement, IdAttachmentFile, IdText,
  Vcl.ComCtrls;

type
  TFormSettings = class(TForm)
    GroupBox2: TGroupBox;
    Label6: TLabel;
    CmTime: TComboBox;
    EdTime: TEdit;
    ChAutoUpdate: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label8: TLabel;
    EdSender: TEdit;
    EdSMTPHost: TEdit;
    EdMailPass: TEdit;
    ChSendMail: TCheckBox;
    EdMailLogin: TEdit;
    BtTestMail: TButton;
    edSMTPport: TEdit;
    ChSSL: TCheckBox;
    StaticText1: TStaticText;
    EdRecipients: TEdit;
    Button1: TButton;
    GroupBox3: TGroupBox;
    ChAutoHide: TCheckBox;
    JvFormStorage1: TJvFormStorage;
    GroupBox4: TGroupBox;
    BtDBcreate: TButton;
    BtnShowDB: TButton;
    ChDebuglog: TCheckBox;
    ChEventslog: TCheckBox;
    chkUpdateApp: TCheckBox;
    btUpdate: TButton;
    ProgressBar1: TProgressBar;
    LbSize: TLabel;
    ChAutoStartSearch: TCheckBox;
    ChAutoStartApp: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure BtDBcreateClick(Sender: TObject);
    procedure BtnShowDBClick(Sender: TObject);
    procedure CmTimeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtTestMailClick(Sender: TObject);
    procedure btUpdateClick(Sender: TObject);
    procedure ChAutoStartAppClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AutoTime: integer;
    UpdateStart: Boolean;
  end;

var
  FormSettings: TFormSettings;

const
  sLogNameDebug: string = 'DebugLog';
  sLogNameStack: string = 'StackLog';

implementation

uses MainUnit, UnitDB, UnitVars, DBs, getstrparam, umpgSendMail, UnitUpdate;

{$R *.dfm}

procedure TFormSettings.BtDBcreateClick(Sender: TObject);
var
  err: string;
begin
  err := 'База данных не создана!';
  if DM.CreateDB then
  begin
    // if DM.CreateTables then
    // begin
    err := 'База данных успешно создана!';
    { end
      else
      err := 'Ошибка создания таблиц в базе данных!'; }
  end;
  FormMain.Log(err, 2);
  ShowMessage(err); { TODO : поменять на MessageDlg }
end;

procedure TFormSettings.BtnShowDBClick(Sender: TObject);
begin
  FormDB := TFormDB.Create(self);
  FormDB.ShowModal;
  FormDB.Free;
end;

procedure TFormSettings.BtTestMailClick(Sender: TObject);
var
  msgMail: TmpgSendMail;
  msgPart: TIdMessagePart;
begin
  with FormMain.IdMessage1 do
  begin
    FormMain.Log('Assigning mail test message properties');
    From.Text := 'Delphi Indy Client <' + FormSettings.EdSender.Text + '>';
    Sender.Text := FormSettings.EdSender.Text;
    Recipients.EMailAddresses := FormSettings.EdRecipients.Text;
    Subject := 'Japancar.ru - Поиск автозапчастей по параметрам (TEST MESSAGE)';
    ContentType := 'text/plain';
    CharSet := 'Windows-1251';
    ContentTransferEncoding := '8bit';
    IsEncoded := true;
    Body.Text := 'Japancar.ru - Поиск автозапчастей по параметрам ' + #$D + #$A
      + 'TEST MESSAGE!'
  end;
  msgMail := TmpgSendMail.Create('Windows-1251');

  FormMain.Log('SendMail test.');
  { TODO : исправить кодировку! }
  // msgMail.MessagePart.AttachmentEncoding:=
  msgMail.Message.Body := '';
  msgMail.Message.ContentType := 'text/plain';
  TIdText.Create(msgMail.MessagePart, FormMain.IdMessage1.Body);
  msgMail.MessagePart.Items[0].ContentTransfer :=
    FormMain.IdMessage1.ContentTransferEncoding;
  msgMail.MessagePart.Items[0].CharSet := FormMain.IdMessage1.CharSet;
  msgMail.MessagePart.Items[0].ContentType := FormMain.IdMessage1.ContentType;
  msgMail.Message.Subject := FormMain.IdMessage1.Subject;
  msgMail.MessagePart.CountParts;
  // ShowMessage(IntToStr(msgMail.MessagePart.Count));

  msgMail.Server.UserName := FormSettings.EdMailLogin.Text;
  msgMail.Server.UserPws := FormSettings.EdMailPass.Text;
  msgMail.Server.Port := StrToInt(FormSettings.edSMTPport.Text);
  msgMail.Server.Host := FormSettings.EdSMTPHost.Text;
  msgMail.FromList.Address := FormSettings.EdSender.Text;
  msgMail.FromList.Name := FormSettings.EdSender.Text;
  msgMail.ToList.Address := FormSettings.EdRecipients.Text;
  msgMail.UseTLS := utUseImplicitTLS; // (ExplicitTLSVals);
  { IdMessage.Body.AddStrings(mMessage.Lines);

    for i := 0 to lbAttachments.Items.Count - 1 do
    begin
    if (FileExists(lbAttachments.Items[i])) then
    begin
    TIdAttachmentFile.Create(IdMessage.MessageParts, lbAttachments.Items[i]);
    end;
    end;
  }
  // msgPart:=msgMail.MessagePart.Add ;
  TIdAttachmentFile.Create(msgMail.MessagePart,
    ExtractFilePath(Application.ExeName) + '\autocar.jpeg');
  // msgPart.FileName:=ExtractFilePath(Application.ExeName)+'\autocar.jpeg';
  msgMail.SendMail;
  // FormMain.SendMail(FormMain.IdMessage1);
  FormMain.Log('Тестовое письмо отправлено.');
  msgMail.Free;
end;

procedure TFormSettings.btUpdateClick(Sender: TObject);
var
  fWorkThread: tWorkThread;
begin
  if not(UpdateStart) then
  begin
    UpdateStart := true;
    fWorkThread := tWorkThread.Create(stHTTP, false);
    // fWorkThread.Start;
    // btUpdate.Enabled:=False;
    btUpdate.Caption := 'Остановить';
    while (fWorkThread <> nil) and (UpdateStart) do
      Application.ProcessMessages;
    UpdateStart := false;
    btUpdate.Caption := 'Обновить';;
  end
  else
  begin
    if fWorkThread <> nil then
    begin
      // fWorkThread.Terminate;
      // btUpdate.Caption:='Обновить';;
      UpdateStart := false;
    end;
  end;
end;

{ var
  upd: TUpdateApp;
  begin

  upd:=tupdateapp.create;
  upd.Enabled:=ChAutoUpdate.Checked;
  upd.URL:='http://avtoefi.ru/'+ExtractFileName(Application.ExeName);
  upd.
  end; }

procedure TFormSettings.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormSettings.ChAutoStartAppClick(Sender: TObject);
begin
case ChAutoStartApp.Checked  of
           { TODO : Добавить программу в автозагрузку Windows }
 true:
  begin
    exit;
  end;
  false:
  begin
Exit;
  end;
end;

end;

procedure TFormSettings.CmTimeChange(Sender: TObject);
begin
  try
    case CmTime.ItemIndex of
      0:
        AutoTime := 1000 * StrToInt(EdTime.Text);
      1:
        AutoTime := 60000 * StrToInt(EdTime.Text);
      2:
        AutoTime := 60000 * 60 * StrToInt(EdTime.Text);
    end;
  finally

  end;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
  AutoTime := 1000 * 60 * 20;
  UpdateStart := false;
end;

end.
