unit umpgSelectableStringList;

interface

uses
  Classes;

type
  TmpgSelectableStringList = class(TObject)
  private
    FItems : TStrings;
    FMultiSelect: Boolean;
    FnItemIndex: integer;
    FOnChange: TNotifyEvent;
    FSelected : TStrings;
    function GetSelCount: Integer;
    function GetSelected(Index: Integer): Boolean;
    function GetText: string;
    procedure SetItemIndex(const Value: integer);
    procedure SetItems(const Value: TStrings);
    procedure SetSelected(Index: Integer; const Value: Boolean);
    procedure SetText(const Value: string);
    procedure SetMultiSelect(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SelectAll;
    procedure UnSelectAll;
    property ItemIndex : integer read FnItemIndex write SetItemIndex;
    property Items: TStrings read FItems write SetItems;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
    property SelCount: Integer read GetSelCount;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
    property Text : string read GetText write SetText;
  end;

implementation

{ TmpgSelectableStringList }

procedure TmpgSelectableStringList.Clear;
begin
  FnItemIndex := -1;
  FItems.Clear;
  FSelected.Clear;
end;

constructor TmpgSelectableStringList.Create;
begin
  inherited;
  FItems := TStringList.Create;
  FSelected := TStringList.Create;
end;

destructor TmpgSelectableStringList.Destroy;
begin
  FItems.Free;
  FSelected.Free;
  inherited;
end;

function TmpgSelectableStringList.GetSelCount: Integer;
begin
  result := FSelected.Count;
end;

function TmpgSelectableStringList.GetSelected(Index: Integer): Boolean;
begin
  result := (FSelected.IndexOf(FItems[Index]) > -1);
end;

function TmpgSelectableStringList.GetText: string;
begin
  if (FnItemIndex < 0) then
    result := ''
  else
    result := FItems[FnItemIndex];
end;

procedure TmpgSelectableStringList.SetText(const Value: string);
begin
  ItemIndex := FItems.IndexOf(Value);
  if (ItemIndex = -1) then
    FnItemIndex := FItems.Add(Value);
end;

procedure TmpgSelectableStringList.SelectAll;
begin
  FSelected.Clear;
  FSelected.Assign(FItems);
end;

procedure TmpgSelectableStringList.SetItemIndex(const Value: integer);
begin
  if (FnItemIndex <> Value) then
  begin
    FnItemIndex := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TmpgSelectableStringList.SetItems(const Value: TStrings);
begin
  FItems := Value;
end;

procedure TmpgSelectableStringList.SetSelected(Index: Integer;
  const Value: Boolean);
var
  iIndex : integer;
begin
  if FMultiSelect then
  begin
    iIndex := FSelected.IndexOf(FItems[Index]);
    if Value then
      if (iIndex = -1) then
        FSelected.Add(FItems[Index])
      else if (iIndex >= 0) then
        FSelected.Delete(FSelected.IndexOf(FItems[Index]));
  end
  else
  begin
    FSelected.Clear;
    if (Value) then
      FSelected.Add(FItems[Index]);
  end;
  if not (Value) or (FSelected.Count = 0) then
    FnItemIndex := -1
  else if (Value) and (FSelected.Count >= 0) then
    FnItemIndex := Index;
end;

procedure TmpgSelectableStringList.SetMultiSelect(const Value: Boolean);
begin
  if (FMultiSelect <> Value) then
    FMultiSelect := Value;
end;

procedure TmpgSelectableStringList.UnSelectAll;
begin
  FSelected.Clear;
end;

end.
