program DBUpg;

uses
  Vcl.Forms,
  dbUnit in 'dbUnit.pas' {FormMain},
  DataUnit in 'DataUnit.pas' {DataModule1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
