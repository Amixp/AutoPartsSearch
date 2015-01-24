program FtpThread;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form3},
  Unit2 in 'Unit2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
