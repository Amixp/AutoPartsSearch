unit MainUnit;

interface

{ http://www.bl-recycle.jp/psnet/sbe/AUP0000.HTML

  ЦУБАСА РОМИНА
  8083700
  ps81365i
  jm751h00
  ----------------------------------------
  ЦУБАСА ИМПЕКС
  8297400
  ps84124q
  ab340u79
  ----------------------------------------
}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, ExtCtrls, IdUserPassProvider, IdSASLPlain,
  IdSASL, IdSASLUserPass, IdSASLLogin, IdMessage, IdCoder,
  IdCoderQuotedPrintable, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdSMTP, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdBaseComponent, IdIntercept, IdLogBase, IdLogDebug, JvFormPlacement,
  JvComponentBase, JvAppStorage, JvAppXMLStorage, Menus, JvMenus, JvTrayIcon,
  JvDebugHandler, JvVersionControlActions, ImgList, JvImageList, UnitVars,
  JvLogFile, ComCtrls, XPMan, JvDesktopAlert, JvBaseDlg, JvExStdCtrls, JvButton,
  JvCtrls, JvExButtons, JvBitBtn, Vcl.Buttons, JvExControls, JvSpeedButton,
  IdLogFile, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, IdAntiFreezeBase, Vcl.IdAntiFreeze, System.Actions,
  JclFileUtils, JclStrings, JclSysUtils,
  // cromis units
  Cromis.SimpleLog, Cromis.Exceptions, JvAppInst, JvFormMagnet;

type
  TFormMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ActionList1: TActionList;
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Button4: TButton;
    JvAppXMLFileStorage1: TJvAppXMLFileStorage;
    JvFormStorage1: TJvFormStorage;
    IdLogDebug1: TIdLogDebug;
    IdHTTP1: TIdHTTP;
    IdConnectionIntercept1: TIdConnectionIntercept;
    IdEncoderQuotedPrintable1: TIdEncoderQuotedPrintable;
    IdMessage1: TIdMessage;
    JvDebugHandler1: TJvDebugHandler;
    JvTrayIcon1: TJvTrayIcon;
    JvIconPopupMenu1: TJvPopupMenu;
    N1: TMenuItem;
    Databse1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Action0: TAction;
    N4: TMenuItem;
    JvImageList1: TJvImageList;
    JvLogFile1: TJvLogFile;
    MainTimer: TTimer;
    XPManifest1: TXPManifest;
    StatusBar1: TStatusBar;
    JvDesktopAlert1: TJvDesktopAlert;
    JvDesktopAlertStack1: TJvDesktopAlertStack;
    JvSpeedButton1: TJvSpeedButton;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    AcJapanCar: TAction;
    AcPCNET: TAction;
    AcModule3: TAction;
    IdLogFile1: TIdLogFile;
    IdAntiFreeze1: TIdAntiFreeze;
    BtnShowDB: TButton;
    Action5: TAction;
    JvFormMagnet1: TJvFormMagnet;
    JvAppInstances1: TJvAppInstances;
    AutoStartTimer: TTimer;
    procedure Action4Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Action0Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Log(Msg: string; LevelLog: integer = 0);
    procedure MainTimerTimer(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure JvTrayIcon1DblClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure JvSpeedButton1Click(Sender: TObject);
    procedure AcJapanCarExecute(Sender: TObject);
    procedure AcPCNETExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Action5Execute(Sender: TObject);
    procedure AutoStartTimerTimer(Sender: TObject);

  private
    procedure AppHide(Sender: TObject);
    procedure AppShow(Sender: TObject);
    procedure SendEmail(const Recipients, Subject, Body: string);
    { Private declarations }
  public
    fSearch: boolean;
    function SendMail(aHost: String): boolean; OverLoad;
    procedure SendMail(idMsg: TIdMessage); OverLoad;
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  Sets: TSets;
  pr: TProgressBar;

implementation

uses
  settings, SearchUnit, DBs, UnitURLs, UnitDB;

{$R *.dfm}

procedure TFormMain.AcJapanCarExecute(Sender: TObject);
begin
  //
end;

procedure TFormMain.AcPCNETExecute(Sender: TObject);
begin
  //
end;

procedure TFormMain.Action0Execute(Sender: TObject);
begin
  if JvTrayIcon1.ApplicationVisible then
  begin
    // Action0.Caption := 'Показать';
    JvTrayIcon1.HideApplication;
  end
  else
  begin
    // Action0.Caption := 'Спрятать';
    JvTrayIcon1.ShowApplication;
    AppShow(Sender);
  end;

end;

{ TODO : проверить кол-во отправляемых и надпись - отправлено позиций! }
{ TODO : добавить отключение всплывающих сообщений }
{ TODO 5 : не работает японский каталог!!! }
{ TODO 1 : Добавить обновление программы через ссылку Dropbox }
procedure TFormMain.Action1Execute(Sender: TObject);
begin
  if not fSearch then // Start search
  begin
    Action1.Caption := 'Остановить';
    { TODO : Зависает на долгой процедуре парсера. Не выходит до завершения парсера. }
    FormSearch := TFormSearch.Create(self);
    if not FormSettings.ChAutoHide.Checked then
      FormSearch.Show;
  end
  else // stop search
  begin
    Action1.Enabled := false;
    FormSearch.st.FlgCancel := true;
    while FormSearch.st.fSearchDo do { TODO : проблема выхода за стек вызовов }
    begin
      Application.ProcessMessages;
    end;
    Action1.Caption := 'Начать';
    FormSearch.free;
    Action1.Enabled := true;
  end;
  fSearch := not fSearch;
end;

procedure TFormMain.Action2Execute(Sender: TObject);
begin
  FormURLs := TFormURLs.Create(self);
  FormURLs.ShowModal;
  FormURLs.free;
end;

procedure TFormMain.Action3Execute(Sender: TObject);
begin
  // FormSettings := TFormSettings.Create(self);
  // Log('test',2);
  FormSettings.ShowModal;
  // FormSettings.free;
end;

procedure TFormMain.Action4Execute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormMain.Action5Execute(Sender: TObject);
begin
  FormDB := TFormDB.Create(self);
  FormDB.ShowModal;
  FormDB.free;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  JvLogFile1.SaveToFile(JvLogFile1.FileName);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  // ProgressBarStyle: integer;
  p1, p2, p3: TStatusPanel;
  ps: TStatusPanels;

begin
  SimpleLog.RegisterLog(sLogNameDebug, ExtractFilePath(Application.ExeName) +
    sLogNameDebug + '.txt');
  SimpleLog.RegisterLog(sLogNameStack, ExtractFilePath(Application.ExeName) +
    sLogNameStack + '.txt');
  ExceptionHandler.UnhandledExceptionsOnly := true;
  ExceptionHandler.SimpleLogID := 'StackLog';
  SimpleLog.LockType := ltNone;

  JvLogFile1.Active := false;
  JvLogFile1.FileName := ExtractFilePath(Application.ExeName) + 'event.log';
  JvLogFile1.Active := true;
  if FileExists(JvLogFile1.FileName) then
    JvLogFile1.LoadFromFile(JvLogFile1.FileName);
  JvLogFile1.AutoSave := false;

  fSearch := false;
  Sets := TSets.Create;
  ps := TStatusPanels.Create(StatusBar1);
  p1 := ps.Add; // панель с прогресс баром
  p1.Text := 'Ждём.';
  p2 := ps.Add; // панель статус работы поиска:...
  p2.Text := '0';
  p2.Width := 40;
  p3 := ps.Add;
  p3.Text := '...'; // панель статус работы
  // p3.Style := psOwnerDraw;
  pr := TProgressBar.Create(self);
  pr.Visible := false;
  // pr.Parent := StatusBar1;
  // remove progress bar border
  { ProgressBarStyle := GetWindowLong(pr.Handle,
    GWL_EXSTYLE);
    ProgressBarStyle := ProgressBarStyle
    - WS_EX_STATICEDGE;
    SetWindowLong(pr.Handle,
    GWL_EXSTYLE,
    ProgressBarStyle);
    pr.Top := pr.Top + 3; }

  StatusBar1.Panels.AddItem(p1, 0);
  StatusBar1.Panels.AddItem(p2, 1);
  StatusBar1.Panels.AddItem(p3, 2);
  Application.OnMinimize := AppHide;
  Application.OnRestore := AppShow;

  if VersionResourceAvailable(Application.ExeName) then
    with TJclFileVersionInfo.Create(Application.ExeName) do
      try
        self.Caption := self.Caption + ' ' + BinFileVersion;
        { TODO : Добавить запись версии в version.ini }
        {
          for I := 0 to LanguageCount - 1 do
          begin
          LanguageIndex := I;
          Memo1.Lines.Add(Format('[%s] %s', [LanguageIds[I], LanguageNames[I]]));
          Memo1.Lines.Add(StringOfChar('-', 80));
          Memo1.Lines.AddStrings(Items);
          Memo1.Lines.Add(BinFileVersion);
          Memo1.Lines.Add(OSIdentToString(FileOS));
          Memo1.Lines.Add(OSFileTypeToString(FileType, FileSubType));
          Memo1.Lines.Add('');
          end;
          Memo1.Lines.Add('Translations:');
          for I := 0 to TranslationCount - 1 do
          Memo1.Lines.Add(VersionLanguageId(Translations[I]));
          Memo1.Lines.Add(BooleanToStr(TranslationMatchesLanguages)); }
      finally
        free;
      end;

  Log('Start program.'+self.Caption );
end;

procedure TFormMain.JvSpeedButton1Click(Sender: TObject);
begin
  //
  JvLogFile1.ShowLog('Log');
end;

procedure TFormMain.JvTrayIcon1DblClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  Action0Execute(Sender);
end;

procedure TFormMain.AppHide(Sender: TObject);
begin
  Action0.Caption := 'Показать';
end;

procedure TFormMain.AppShow(Sender: TObject);
begin
  Action0.Caption := 'Спрятать';
end;

procedure TFormMain.AutoStartTimerTimer(Sender: TObject);
begin
AutoStartTimer.Enabled:=false;
Action1Execute(self);  // старт поиска при запуске программы
end;

procedure TFormMain.Log(Msg: string; LevelLog: integer = 0);
var
  JvDesktopAlert2: TJvDesktopAlert;
begin
  { SimpleLog.LogEvent('DebugLog','This is warning', ltWarning);
    SimpleLog.LogEvent('DebugLog','This is error', ltError);
    SimpleLog.LogEvent('DebugLog','This is info', ltInfo);
    SimpleLog.LogEvent('DebugLog','This is hint', ltHint);
  }
  try
    JvDesktopAlert2 := TJvDesktopAlert.Create(Application);
    JvDesktopAlert2.AutoFree := true;
    with JvDesktopAlert2 do
    begin
      Location.Width := 400;
      // TJvFormDesktopAlert(Form).lblHeader.WordWrap := True;
      // StyleOptions.DisplayDuration := mPopupDelay;
      Font.Color := clRed;
    end;
    case LevelLog of
      0:
        SimpleLog.LogEvent(sLogNameDebug, Msg, ltHint);

      1:
        begin
          JvDesktopAlert2.HeaderText := 'Сообщение!';
          JvDesktopAlert2.MessageText := Msg;
          JvDesktopAlert2.Execute;
          SimpleLog.LogEvent(sLogNameDebug, Msg, ltInfo);
        end;
      2:
        begin
          JvDesktopAlert2.HeaderText := 'Внимание!';
          JvDesktopAlert2.MessageText := Msg;
          JvDesktopAlert2.Execute;
          SimpleLog.LogEvent(sLogNameDebug, Msg, ltWarning);
        end;
      3 .. 99:
        begin
          JvDesktopAlert2.HeaderText := 'Ошибка!';
          JvDesktopAlert2.MessageText := Msg;
          JvDesktopAlert2.Execute;
          SimpleLog.LogEvent(sLogNameDebug, Msg, ltError);
        end;
    end;
    /// ////////// JvLogFile1.Add(JvDesktopAlert2.HeaderText, Msg);
    { TODO : Иногда срабатывает блокировка файла }
  Except
    // JvDesktopAlert2.free;
    on E: Exception do
      SimpleLog.LogEvent(sLogNameDebug, 'Handled exception: ' +
        E.Message, ltError);
  end; { First chance exception at $7C812AFB. Exception class EOSError with message
    'System Error.  Code: 1158.
    Текущий процесс использовал все системные разрешения по управлению объектами диспетчера окон'. }
  { Process AutoWebSearch.exe (1608) }
end;

procedure TFormMain.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  { if Panel.Index = 2 then
    begin
    pr.BoundsRect := Rect;
    pr.PaintTo(StatusBar.Canvas.Handle, Rect.Left, Rect.Top);
    end; }
  { with ProgressBar1 do begin
    Top := Rect.Top;
    Left := Rect.Left;
    Width := Rect.Right - Rect.Left - 15;
    Height := Rect.Bottom - Rect.Top;
    end; }
end;

procedure TFormMain.MainTimerTimer(Sender: TObject);
  procedure SetText(SB: TStatusBar; I: integer; const Text: String);
  var
    l: tlabel;
  begin
    l := tlabel.Create(self);
    l.AutoSize := true;
    l.Font.Assign(SB.Font);
    l.Caption := Text + '  ';
    SB.Panels[I].Width := l.Width;
    SB.Panels[I].Text := l.Caption;
    l.free;
  end;

begin
  if fSearch and FormSearch.st.fSearchDo then
  begin
    JvTrayIcon1.IconIndex := 26;
  end
  else
    JvTrayIcon1.IconIndex := 6;
  if fSearch then
  begin
    if FormSearch.st.fSearchDo then
      SetText(StatusBar1, 0, 'Поиск... ')
    else
    begin
    //  Timer1.Enabled := false;
 // Timer1.Interval := FormSettings.AutoTime;
      SetText(StatusBar1, 0, 'Ожидание: ' +
        IntToStr(trunc(FormSearch.st.iTime / 1000)) + 'сек.');
      if FormSettings.chkUpdateApp.Checked then
        FormSettings.btUpdateClick(self);
    end;
    SetText(StatusBar1, 1, 'URLs:' + IntToStr(FormSearch.st.DoneURLs));
    SetText(StatusBar1, 2, FormSearch.st.Status);
    { pr.Max:=FormSearch.ST.ProgressMax;
      pr.Position:=FormSearch.ST.Progress;
      pr.Repaint; }
    StatusBar1.Refresh;
  end;
end;

function TFormMain.SendMail(aHost: String): boolean;
begin
  Result := false;
  { with FormMain.IdSMTP1 do
    begin
    Caption := 'Trying to sendmail via: ' + aHost;
    FormMain.Log('Trying to sendmail via: ' + aHost);
    Host := aHost;
    AuthType := satSASL;
    // FormMain.IdUserPassProvider1.Username := FormSettings.EdMailLogin.Text;
    //FormMain.IdUserPassProvider1.Password := FormSettings.EdMailPass.Text;
    try
    // IdEncoderQuotedPrintable1.Encode(IdMessage1.);
    FormMain.Log('Attempting connect');
    Connect;
    FormMain.Log('Successful connect ... sending message');
    Send(FormMain.IdMessage1);
    FormMain.Log('Attempting disconnect');
    Disconnect;
    FormMain.Log('Successful disconnect');
    Result := true;
    except
    on E: Exception do
    begin
    if connected then
    try
    Disconnect;
    except
    end;
    FormMain.Log('Error sending message: ' + E.Message, 3);
    Result := false;
    // ShowMessage(E.Message);
    end;
    end;
    end;
    Caption := ''; }
end;

procedure TFormMain.SendMail(idMsg: TIdMessage);
{ DONE : Sendmail работает. осталось добавить отправку по таймеру и переделать тестовую отправку }
begin
  FormMain.Log('Attempting to send mail');
  if SendMail(FormSettings.EdSMTPHost.Text) then
  begin
    FormMain.Log
      ('Mail successfully sent and available for pickup by recipient !');
    Exit;
  end;
  // if we are here then something went wrong .. ie there were no available servers to accept our mail!
  FormMain.Log
    ('Could not send mail to remote server - please try again later.', 2);
end;

procedure TFormMain.SendEmail(const Recipients: string; const Subject: string;
  const Body: string);
var
  SMTP: TIdSMTP;
  Email: TIdMessage;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Log: TIdLogFile;
begin
  Log := TIdLogFile.Create(nil);
  Log.FileName := 'debug.txt';
  SMTP.Intercept := Log;
  SMTP := TIdSMTP.Create(nil);
  Email := TIdMessage.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  SSLHandler.Intercept := Log;
  Log.Active := true;
  try
    // SSLHandler.MaxLineAction := maException;
    SSLHandler.SSLOptions.Method := sslvTLSv1;
    SSLHandler.SSLOptions.Mode := sslmUnassigned;
    SSLHandler.SSLOptions.VerifyMode := [];
    SSLHandler.SSLOptions.VerifyDepth := 0;

    SMTP.IOHandler := SSLHandler;
    // SMTP.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8;
    SMTP.Host := 'smtp.yandex.ru';
    SMTP.Port := 465; // or 587;
    SMTP.Username := 'email@gmail.com';
    SMTP.Password := 'password';
    SMTP.UseTLS := utUseExplicitTLS;

    Email.CharSet := 'UTF-8';
    Email.ContentTransferEncoding := 'base64';
    // Email.OnInitializeISO := frmMain.OnInitISO;
    Email.From.Address := 'email@gmail.com';
    Email.Recipients.EmailAddresses := Recipients;
    Email.Subject := UTF8Encode(Subject);
    Email.Body.Text := UTF8Encode(Body);

    SMTP.Connect;
    SMTP.Send(Email);
    SMTP.Disconnect;
  finally
    SMTP.free;
    Email.free;
    SSLHandler.free;
    Log.free;
  end;
end;

end.
