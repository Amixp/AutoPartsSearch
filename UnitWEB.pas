unit UnitWEB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ExtCtrls, StrUtils, MainUnit;

type
  TFormWEB = class(TForm)
    WebBrowser1: TWebBrowser;
    PnURL: TPanel;
    Label1: TLabel;
    EdPostURL: TEdit;
    BtAddPostURL: TButton;
    Panel1: TPanel;
    Label2: TLabel;
    LsURLs: TListBox;
    BtEditURL: TButton;
    BtDelURL: TButton;

    procedure FormCreate(Sender: TObject);
    procedure BtAddPostURLClick(Sender: TObject);
    procedure BtEditURLClick(Sender: TObject);
    procedure BtDelURLClick(Sender: TObject);
    procedure LsURLsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
  private
    procedure BlinkEdit;
    { Private declarations }
  public
    { Public declarations }
    PostURL: string;
    // LsURLs: TStringList;
  end;

var
  FormWEB: TFormWEB;

implementation

uses getstrparam;

{$R *.dfm}

procedure TFormWEB.BtAddPostURLClick(Sender: TObject);
begin
  if PostURL <> '' then
    if LsURLs.items.IndexOf(PostURL) = -1 then
      LsURLs.items.Add(PostURL);
end;

procedure TFormWEB.BtDelURLClick(Sender: TObject);
begin
  LsURLs.items.Delete(LsURLs.ItemIndex);
  LsURLsClick(Sender);
end;

procedure TFormWEB.BtEditURLClick(Sender: TObject);
begin
  EdPostURL.Text := LsURLs.items.Strings[LsURLs.ItemIndex];
  LsURLs.items.Delete(LsURLs.ItemIndex);
  LsURLsClick(Sender);
end;

procedure TFormWEB.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

begin
  if LsURLs.items.Count > 0 then
    Sets.LsURLs.Text := LsURLs.items.Text;

  CanClose := true;
end;

procedure TFormWEB.FormCreate(Sender: TObject);
begin
  PostURL := '';
end;

procedure TFormWEB.LsURLsClick(Sender: TObject);
begin
  { DONE : Добавить реакцию кнопок на выбор списка ссылок }
  BtDelURL.enabled := (LsURLs.Count > 0) and (LsURLs.ItemIndex > -1);
  BtEditURL.enabled := (LsURLs.Count > 0) and (LsURLs.ItemIndex > -1);
end;

procedure TFormWEB.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  i: integer;
  StrArr: TArrayOfString;
begin
  // FormTest.log('BeforeNavigate. "'+url+'"'+EOL+'Post:"'+VarToStr(PostData)+'"');
  StrArr := fcToParts(URL, ['/', '&']);
  for i := 0 to Length(StrArr) - 1 do
  begin
    // memo2.Lines.Add('#'+inttostr(i)+':'+StrArr[i]);
    if AnsiContainsText(StrArr[i], 'code=parts') then
    begin
      // FormTest.log('POST URL:' + URL);
      PostURL := URL;
      if PostURL <> EdPostURL.Text then
        BlinkEdit;

      EdPostURL.Text := PostURL;
    end;
  end;

end;

procedure TFormWEB.BlinkEdit;
var
  c: integer;
begin
  c := EdPostURL.Color;
  EdPostURL.Color := clRed;
  Application.ProcessMessages;
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;
  EdPostURL.Color := clRed;
  Application.ProcessMessages;

  Sleep(500);
  EdPostURL.Color := clRed;
  Application.ProcessMessages;
  EdPostURL.Color := clBlue;
  Application.ProcessMessages;
  EdPostURL.Color := clNavy;
  Application.ProcessMessages;
  EdPostURL.Color := clOlive;
  Application.ProcessMessages;
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;

  Sleep(500);
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;
  EdPostURL.Color := clGreen;
  Application.ProcessMessages;
  EdPostURL.Color := clRed;
  Application.ProcessMessages;

  EdPostURL.Color := c;
  Application.ProcessMessages;
end;

end.
