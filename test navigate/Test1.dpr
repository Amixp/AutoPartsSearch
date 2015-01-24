program Test1;

uses
  Forms,
  Unittest1 in 'Unittest1.pas' {Form1} ,
  Unittest2 in 'Unittest2.pas' {Form2} ,
  Unittest4 in 'Unittest4.pas' {Form4} ,
  UnitData in 'UnitData.pas' {DataModule2: TDataModule} ,
  getstrparam in 'getstrparam.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TDataModule2, DataModule2);
  Application.Run;

end.
