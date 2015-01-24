unit UnitProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TFormProgress = class(TForm)
    Label1: TLabel;
    BtCancel: TButton;
    ProgressBar1: TProgressBar;
    LbCount: TLabel;
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    // FlgCancel: boolean;
  end;

var
  FormProgress: TFormProgress;

implementation

uses SearchUnit;

{$R *.dfm}

procedure TFormProgress.BtCancelClick(Sender: TObject);
begin
  formsearch.st.FlgCancel := true;
  (Sender as TButton).Enabled := false;
end;

procedure TFormProgress.FormCreate(Sender: TObject);
begin
  formsearch.st.FlgCancel := false;
end;

end.
