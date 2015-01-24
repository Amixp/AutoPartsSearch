unit UnitVars;

interface

uses
  Windows, Messages, SysUtils, Variants,
  Classes, Graphics, Controls, Forms;
// Dialogs;

// procedure InitVars();
type
  SearchT = record
    Name: string; // Ќазвание сайта/зона поиска
    fSearchDo: boolean; // process download and parse urls
    iTime, // врем€ до старта поиска
    Progress, ProgressMax, // прогресс поиска
    DoneURLs: integer; // кол-во загруженных ссылок
    FlgCancel: boolean; // флаг прерывани€ поиска
    Status: string; // сообщени€ статуса в StatusBar
    NewItems: integer; // кол-во новых запчастей
  end;

type
  TOpt2 = record // настройки сайта .NET
    SiteLoginURL, SiteURL, Login1, Login2, Login3: string;
  end;

type
  TSets = class(TObject)
  public
    DatabaseFileName, SiteURL: string;
    LsURLs: TStrings;
    Opt2: TOpt2;
    Constructor Create;
    Destructor Destroy; override;
  end;

type
  TsItem = class(TObject)
  public
    Foto, Firm, Name, Body, N1, N2, Price, Saler: string;
    Date: TDate;
    Constructor Create;
    Destructor Destroy; override;
  end;

type
  TsItem2 = class(TObject)
  public
    part1, part2, partnumber: string;
    Constructor Create;
    Destructor Destroy; override;
  end;

implementation

{
  procedure Log(Msg: string);
  begin

  end;

  procedure InitVars();
  begin

  end; }
{ TSets }

constructor TSets.Create;
begin
  DatabaseFileName := 'Database.mdb';
  DatabaseFileName := extractfilepath(Application.ExeName) + DatabaseFileName;
  SiteURL :=
    'http://parts.japancar.ru/?code=parts&mode=old&cl=search_partsoldng';
  LsURLs := TStringList.Create;
  with Opt2 do
  begin
    SiteLoginURL := 'http://www.bl-recycle.jp/servlet/EW3SAS_WEB_PS';
    SiteURL := 'http://www.bl-recycle.jp/psnet/com/AUP1100.HTML';
    Login1 := '8297400';
    Login2 := 'ps84124q';
    Login3 := 'ab340u79';
  end;
end;

destructor TSets.Destroy;
begin

  inherited;
end;

{ TsItem }

constructor TsItem.Create;
begin

end;

destructor TsItem.Destroy;
begin

  inherited;
end;

{ TsItem2 }

constructor TsItem2.Create;
begin

end;

destructor TsItem2.Destroy;
begin

  inherited;
end;

end.
