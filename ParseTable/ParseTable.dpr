program ParseTable;

uses
  Forms,
  UnitParseTable in 'UnitParseTable.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;

end.
