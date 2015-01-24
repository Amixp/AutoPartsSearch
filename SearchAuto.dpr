program SearchAuto;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {FormMain},
  settings in 'settings.pas' {FormSettings},
  SearchUnit in 'SearchUnit.pas' {FormSearch},
  HTMLUnit in 'HTMLUnit.pas' {Form7},
  UnitDB in 'UnitDB.pas' {DM: TDataModule},
  UnitVars in 'UnitVars.pas',
  DBs in 'DBs.pas' {FormDB},
  UnitWEB in 'UnitWEB.pas' {FormWEB},
  getstrparam in 'getstrparam.pas',
  UnitURLs in 'UnitURLs.pas' {FormURLs};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormSettings, FormSettings);
  dm.OpenTbls;
  Application.Run;

end.
