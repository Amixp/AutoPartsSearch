program AutoWebSearch;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {FormMain},
  settings in 'settings.pas' {FormSettings},
  SearchUnit in 'SearchUnit.pas' {FormSearch},
  UnitDB in 'UnitDB.pas' {DM: TDataModule},
  UnitVars in 'UnitVars.pas',
  DBs in 'DBs.pas' {FormDB},
  UnitWEB in 'UnitWEB.pas' {FormWEB},
  getstrparam in 'getstrparam.pas',
  UnitURLs in 'UnitURLs.pas' {FormURLs},
  UnitProgress in 'UnitProgress.pas' {FormProgress},
  Vcl.Themes,
  Vcl.Styles,
  UnitWEB2 in 'UnitWEB2.pas' {FormWEB2},
  HTMLObjs in 'HtmlParser\HTMLObjs.pas',
  HTMLParser in 'HtmlParser\HTMLParser.pas',
  StrMan in 'HtmlParser\StrMan.pas',
  SearchUnit2 in 'SearchUnit2.pas',
  UnitUpdate in 'UnitUpdate.pas',
  parse in 'test navigate\parse.pas',
  UnitSend in 'test navigate\UnitSend.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormSettings, FormSettings);
  Application.CreateForm(TFormWEB2, FormWEB2);
  // Application.CreateForm(TFormProgress, FormProgress);
  FormSettings.JvFormStorage1.RestoreFormPlacement;
  FormMain.JvDebugHandler1.ExceptionLogging := FormSettings.ChDebuglog.Checked;
  FormMain.JvDebugHandler1.StackTrackingEnable :=
    FormSettings.ChDebuglog.Checked;
  FormMain.JvDebugHandler1.LogToFile := FormSettings.ChDebuglog.Checked;
  FormMain.JvLogFile1.Active := FormSettings.ChEventslog.Checked;
  FormMain.JvLogFile1.AutoSave := FormSettings.ChEventslog.Checked;
  FormMain.AutoStartTimer.Enabled:=FormSettings.ChAutoStartSearch.Checked;
  FormSettings.CmTimeChange(nil);
  DM.OpenTbls;
  Application.Run;

end.
