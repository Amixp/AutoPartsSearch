unit dbUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormMain = class(TForm)
    btnOpenDB: TButton;
    sEditDBfile: TEdit;
    lbl1: TLabel;
    lstLog: TListBox;
    procedure btnOpenDBClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure log(MSG: string;loglevel:integer=1);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses DataUnit;

procedure TFormMain.btnOpenDBClick(Sender: TObject);
begin
DataModule1.OpenTbls2(ExtractFilePath(Application.ExeName)+ sEditDBfile.Text);
end;

procedure TFormMain.log(MSG: string; loglevel:integer);
begin
//
lstLog.Items.Append(MSG);
lstLog.Update;
Application.ProcessMessages;
end;

end.
