{

  THTMLObject or THTMLParser

  An easy HTML parser, aim to make HTML processing in Delphi/Pascal
  like in Javascript with DOM object.

  Author: William.Yang
  Website: http://www.tiaon.com

}

{$INCLUDE DFS.inc}
unit HTMLParser;

interface

uses Classes, SysUtils, Graphics, HTMLObjs;

const
  E_SYMBOL_INGORED = 1;

type
  DWord = Cardinal;

  TElementType = (etNormalText, etTag, etComment, etStyleSheet, etScript);

  TParseElementCompleteEvent = procedure(Sender: TObject;
    ElementType: TElementType; Element: THTMLElement; var Continue: Boolean);

  // TParseTagCompleteEvent = procedure (Tag: TTagObject; var Continue: Boolean);
  // TParseTagBeginEvent = procedure (Tag: TTagObject; var Continue: Boolean);

  TParseErrorEvent = procedure(Sender: TObject; AErrorCode: Integer;
    AErrorMsg: String; var Continue: Boolean);

  THTMLObject = class(TObject)
  private
    fTags: TObjectsList;
    fFirstLevelTags: THTMLElements;
    fErrors: TStrings;
    fCurrent: Integer;
    fTagName: String;
    fScript: String;
    fPosition: DWord;
    FOnElementComplete: TParseElementCompleteEvent;
    FOnError: TParseErrorEvent;
    procedure SetText(Val: String);
    function GetText: String;
    function GetTagByname(AName: String): TTagObject;
    procedure SetCurrent(const Value: Integer);
    procedure SetOnElementComplete(const Value: TParseElementCompleteEvent);
    procedure SetOnError(const Value: TParseErrorEvent);
    procedure DoError(ErrCode: Integer; ErrMsg: String; var Continue: Boolean);
    procedure DoComplete(ElementType: TElementType; Element: THTMLElement;
      var Continue: Boolean);
  protected
    procedure AddHTML(const Source: String; var LastState: LongInt);
    procedure Changed; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SortTags;
    procedure LoadFromFile(Filename: String);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(Filename: String);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStrings(Strings: TStrings);
    procedure SaveToStrings(Strings: TStrings);
    function Next: TTagObject;
    function Prev: TTagObject;
    function First: TTagObject;
    function Last: TTagObject;
    property Text: String read GetText write SetText;
    property Current: Integer read fCurrent write SetCurrent;
    property TagName: String read fTagName write fTagName;
    property Position: DWord read fPosition;
    property TagByName[AName: String]: TTagObject read GetTagByname;
    property Tags: TObjectsList read fTags;
    property FirstLevelTags: THTMLElements read fFirstLevelTags;
    property OnElementComplete: TParseElementCompleteEvent
      read FOnElementComplete write SetOnElementComplete;
    property OnError: TParseErrorEvent read FOnError write SetOnError;

    // property OnTagBegin: TParseElementCompleteEvent;
    // property OnTagComplete: TParseElementCompleteEvent;

  end;

  THTMLParser = THTMLObject;

implementation

uses StrMan;

// ---------------------------------------------------------------------- \\
// ---------------------------------------------------------------------- \\

const
  Breaks = [#0 .. ' ', #$3A .. #$40, '-', '~', '{', '"', '''', '\', '}', '<',
    '>', '='];
  DefaultParents = 'HTML,P,A,FORM,FRAME,NOFRAME,TITLE,HEAD,STYLE,' +
    'TABLE,TR,UL,OL,OPTION,MENU,' + 'DIV,SPAN,LAYER,OBJECT,APPLET,PRE';

var
  ParentTags: TStrings;

function IsParentTag(ATagname: String): Boolean;
begin
  Result := ParentTags.IndexOf(Uppercase(ATagname)) >= 0;
end;

{ THTMLObject }
constructor THTMLObject.Create;
begin
  inherited Create;
  fTags := TObjectsList.Create;
  fErrors := TStringList.Create;
  fFirstLevelTags := THTMLElements.Create;
end;

destructor THTMLObject.Destroy;
begin
  fTags.Free;
  fErrors.Free;
  fFirstLevelTags.Free;
  inherited Destroy;
end;

procedure THTMLObject.LoadFromStrings(Strings: TStrings);
var
  Val: LongInt;
begin
  fTags.Clear;
  fErrors.Clear;
  Val := 0;
  AddHTML(Strings.Text, Val);
  Changed;
end;

procedure THTMLObject.SaveToStrings(Strings: TStrings);
begin
  Strings.Text := Text;
end;

procedure THTMLObject.LoadFromFile(Filename: String);
var
  Strings: TStringList;
begin
  Strings := TStringList.Create;
  Strings.LoadFromFile(Filename);
  try
    LoadFromStrings(Strings);
  finally
    Strings.Free;
  end;
end;

procedure THTMLObject.LoadFromStream(Stream: TStream);
var
  Buffer: array [1 .. 4096] of Char;
  s: String;
  Size: Integer;
  State: LongInt;
begin
  fTags.Clear;
  fErrors.Clear;
  fScript := '';
  State := 0;
  while Stream.Position < Stream.Size do
  begin
    if (Stream.Size - Stream.Position) > 4096 then
      Size := 4096
    else
      Size := Stream.Size - Stream.Position;
    Stream.Read(Buffer, Size);
    SetString(s, PChar(@Buffer[1]), Size);
    AddHTML(s, State);
  end;
  Changed;
end;

procedure THTMLObject.SaveToFile(Filename: String);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(Filename, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure THTMLObject.SaveToStream(Stream: TStream);
var
  Obj: THTMLElement;
  i, j: Integer;
  s: String;
  C: Char;
begin
  for i := 0 to fTags.Count - 1 do
  begin
    Obj := THTMLElement(fTags[i]);
    s := Obj.Text;
    for j := 1 to Length(s) do
    begin
      C := s[j];
      Stream.Write(C, 1);
    end;
  end;
end;

function THTMLObject.Next: TTagObject;
var
  i: Integer;
begin
  Result := nil;
  for i := fCurrent + 1 to fTags.Count - 1 do
  begin
    Inc(fPosition, Length(THTMLElement(fTags[i]).Text));
    if TObject(fTags[i]) is TTagObject then
      if (CompareText(TTagObject(fTags[i]).TagName, fTagName) = 0) or
        (fTagName = '') then
      begin
        Result := TTagObject(fTags[i]);
        fCurrent := i;
        Break;
      end;
  end;
end;

function THTMLObject.Prev: TTagObject;
var
  i: Integer;
begin
  Result := nil;
  for i := fCurrent - 1 downto 0 do
  begin
    if TObject(fTags[i]) is TTagObject then
      if (CompareText(TTagObject(fTags[i]).TagName, fTagName) = 0) or
        (fTagName = '') then
      begin
        Result := TTagObject(fTags[i]);
        fCurrent := i;
        Break;
      end;
    Dec(fPosition, Length(THTMLElement(fTags[i]).Orignal));
  end;
end;

procedure THTMLObject.AddHTML(const Source: String; var LastState: LongInt);

label TerminateParse, ParseEnd;

const
  bitTag = $1;
  bitScript = $2;
  bitComment = $4;
  bitCF = $8;
  bitString = $10;
  bitStyle = $20;
  bitJsBlockComment = $40;
  bitState = $FF000000;
  bitStringChar = $00FF0000;
var
  i, Size: Integer;
  Buffer, Scripts, s, t: String;
  ScrObj, Tag: THTMLElement;
  AChar, StringChar: Char;
  IsScript, IsString, ISJSBlockComment, IsComment, IsStyle, IsCF,
    IsTag: Boolean;
  IgnoreChar: Boolean;
  TagState: TTagState;
  fContinue: Boolean;
begin
  fContinue := True;
  IsTag := (LastState and bitTag) = bitTag;
  IsScript := (LastState and bitScript) = bitScript;
  IsComment := (LastState and bitComment) = bitComment;
  IsCF := (LastState and bitCF) = bitCF;
  IsString := (LastState and bitString) = bitString;
  IsStyle := (LastState and bitStyle) = bitStyle;
  ISJSBlockComment := ((LastState and bitJsBlockComment) = bitJsBlockComment);
  IgnoreChar := False;
  StringChar := Char(Byte((LastState and bitStringChar) shr 16));
  Scripts := fScript;
  Buffer := Source;
  Tag := nil;
  TagState := TTagState((LastState and bitState) shr 24);

  t := '';
  s := '';

  Size := Length(Buffer);
  for i := 1 to Size do
  begin
    if not fContinue then
      Break;
    AChar := Buffer[i];
    case AChar of
      '<':
        begin
          s := '';
          if not(IsScript or IsString) then
          begin
            if not IsTag then
            begin
              IsTag := True;
              IgnoreChar := True;
              TagState := tsBegin;
              if t <> '' then
              begin

                fTags.Add(TNormalText.CreateFromtext(nil, t));
                DoComplete(etNormalText, fTags[fTags.Count - 1], fContinue);
                if not fContinue then
                  Break;

                t := '';
              end;
            end
            else
              DoError(E_SYMBOL_INGORED, IntToStr(i) + ': "<" Symbol is ignored',
                fContinue);
          end
          else if IsScript and (not(IsString)) then
          begin
            TagState := tsBegin;
            t := '';
            IsTag := True;
          end;
          ISJSBlockComment := False;
          IsComment := False;
          IsString := False;
          IsStyle := False;
        end;
      '>':
        if not(IsScript or IsString or IsCF) then
        begin
          if IsTag then
          begin
            if t <> '' then
            begin
              if IsComment then
              begin
                // tag := TNormalText.CreateFromText(nil, '<'+t+'>');
                Tag := TTagObject.CreateFromtext(nil, '<' + t + '>');
                DoComplete(etTag, Tag, fContinue);
                if not fContinue then
                  Break;
              end
              else
              begin
                Tag := TTagObject.CreateFromtext(nil, t);
                DoComplete(etTag, Tag, fContinue);
                if not fContinue then
                  Break;
              end;
              Tag.Document := Self;
              fTags.Add(Tag);
              t := '';
            end;
            if Tag is TTagObject then
              if TTagObject(Tag).NameIS('SCRIPT') then
                IsScript := True;
            TagState := tsEnd;
            IsTag := False;
            IsComment := False;
            IsString := False;
            ISJSBlockComment := False;
            IgnoreChar := True;
          end
          else
            DoError(E_SYMBOL_INGORED, IntToStr(i) + ': ">" Symbol is ignored',
              fContinue);
        end
        else if (not IsString or IsCF) and IsScript and IsTag then
        begin
          if (Pos('/SCRIPT', Uppercase(Trim(t))) >= 1) and IsTag then
          begin
            Tag := TTagObject.CreateFromtext(nil, t);
            Tag.Document := Self;
            Delete(Scripts, Length(Scripts) - Length(t) + 1, Length(t));
            ScrObj := TScriptObject.CreateFromtext(nil, Scripts);
            ScrObj.Document := Self;
            DoComplete(etScript, ScrObj, fContinue);
            if not fContinue then
              Break;
            fTags.Add(ScrObj);

            DoComplete(etTag, Tag, fContinue);
            if not fContinue then
              Break;

            fTags.Add(Tag);
            Scripts := '';
            IsScript := False;
            IgnoreChar := True;
            t := '';
            IsTag := False;
          end;
          s := '';
        end;
      ' ', #13, #10, #8, #9:
        begin
          // When in Script requires more tight Syntax, any space will cause a invalid tag
          if IsScript and IsTag then
            IsTag := False;
          // If IsTag then check if is Begining a PropertyName or PropertyValue
          if (not IsString) and (IsTag) then
          begin
            if TagState = tsBegin then
              TagState := tsPropertyName;
            if TagState = tsPropertyValue then
              TagState := tsPropertyName;
          end;
          if ((Trim(s) = '<!--') or (Trim(s) = '<!---')) and IsScript then
            IsCF := True;
          if ((AChar = #13) or (AChar = #10)) and IsCF then
          begin
            Scripts := '';
            IsString := False;
            IsComment := False;
            ISJSBlockComment := False;
            IsCF := False;
            Tag := TNormalText.CreateFromtext(nil, t + #13);

            DoComplete(etNormalText, Tag, fContinue);
            if not fContinue then
              Break;

            fTags.Add(Tag);
            t := '';
          end
          else if (AChar = #13) then
            if IsScript then
              if IsComment and (not ISJSBlockComment) then
                IsComment := False;
          s := '';
        end;
      '/':
        if IsScript then
        begin
          if Buffer[i - 1] = '/' then
          begin
            if not(IsComment or IsString or ISJSBlockComment) then
              IsComment := True;
          end
          else
          begin
            if ISJSBlockComment then
              if Buffer[i - 1] = '*' then
              begin
                ISJSBlockComment := False;
                IsComment := False;
              end;
          end;
        end;
      '*':
        if IsScript and (not IsString) then
          if not ISJSBlockComment then
          begin
            if Buffer[i - 1] = '/' then
            begin
              ISJSBlockComment := True;
              IsComment := True;
            end;
          end;
      '"', '''':
        if IsString and (not IsComment) and (not ISJSBlockComment) then
        begin
          if Buffer[i - 1] <> '\' then
            if StringChar = AChar then
              IsString := False;
        end
        else
        begin
          if IsScript and (not IsComment) and (not ISJSBlockComment) then
          begin
            IsString := True;
            StringChar := AChar;
          end
          else if IsTag then
          begin
            if TagState = tsPropertyValue then
            begin
              IsString := True;
              StringChar := AChar;
            end;
          end;
        end;
      '=':
        if IsTag and (not IsString) then
        begin
          if (not(IsScript and IsCF)) and (TagState = tsPropertyName) then
            TagState := tsPropertyValue;
        end;
      '!':
        if IsTag and (not(IsString or IsComment)) then
        begin
          IsComment := True;
        end;
    end;
    if not IgnoreChar then
    begin
      t := t + AChar;
      s := s + AChar;
      if IsScript then
        Scripts := Scripts + AChar;
    end;
    IgnoreChar := False;
  end;

  if fContinue then
    goto ParseEnd;

TerminateParse:

  LastState := 0;
  fScript := '';
  fTags.Clear;

  Exit;

ParseEnd:

  for i := 0 to fTags.Count - 1 do
  begin
    THTMLElement(fTags[i]).Document := Self;
  end;

  if IsTag then
    LastState := LastState or bitTag;
  if IsScript then
    LastState := LastState or bitScript;
  if IsCF then
    LastState := LastState or bitCF;
  if IsComment then
    LastState := LastState or bitComment;
  if IsString then
    LastState := LastState or bitString;
  LastState := LastState or (Byte(StringChar) shl 16);
  LastState := LastState or (Byte(TagState) shl 24);
  fScript := Scripts;
end;

function THTMLObject.GetText: String;
var
  Obj: THTMLElement;
  i: Integer;
  s: String;
begin
  Result := '';
  for i := 0 to fTags.Count - 1 do
  begin
    Obj := THTMLElement(fTags[i]);
    s := Obj.Text;
    Result := Result + s;
  end;
end;

procedure THTMLObject.SetText(Val: String);
var
  State: LongInt;
begin
  fTags.Clear;
  fErrors.Clear;
  State := 0;
  AddHTML(Val, State);
  Changed;
end;

function THTMLObject.GetTagByname(AName: String): TTagObject;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to fTags.Count - 1 do
  begin
    if TObject(fTags[i]) is TTagObject then
      if CompareText(TTagObject(fTags[i]).TagName, AName) = 0 then
      begin
        Result := TTagObject(fTags[i]);
        fCurrent := i;
        Break;
      end;
  end;
end;

procedure THTMLObject.SortTags;
var
  Element: THTMLElement;
  Parent, Curr: TTagObject;
  i: Integer;
begin
  fFirstLevelTags.Clear;
  Parent := nil;
  for i := 0 to fTags.Count - 1 do
  begin
    Element := THTMLElement(fTags[i]);
    if Element is TTagObject then
    begin
      Curr := TTagObject(Element);
      if IsParentTag(Curr.TagName) then
      begin
        if Parent <> nil then
        begin
          // Automatic break up, if same parent tag occurs
          if CompareText(Parent.TagName, Curr.TagName) = 0 then
            Parent := Parent.Owner
          else
          begin
            Parent.Subitems.Add(Curr);
            Curr.Owner := Parent;
            Parent := Curr;
            Parent.Subitems.Clear;
          end;
        end
        else // if parent is nil and curr is a parent it self
        begin
          fFirstLevelTags.Add(Curr);
          Parent := Curr;
          Curr.Owner := Parent;
          Parent.Subitems.Clear;
        end;
      end
      else // is not parent
      begin
        if Parent <> nil then
        begin
          // but could be slashed.
          if CompareText('/' + Parent.TagName, Curr.TagName) = 0 then
            Parent := Parent.Owner
          else
            Parent.Subitems.Add(Curr);
        end
        else
          fFirstLevelTags.Add(Curr);
      end;
    end
    else // is not Tag
    begin
      if Parent <> nil then
      begin
        Parent.Subitems.Add(Element);
      end
      else
        fFirstLevelTags.Add(Element);
    end;
  end;
end;

procedure THTMLObject.SetCurrent(const Value: Integer);
var
  i: Integer;
begin
  fCurrent := Value;
  fPosition := 0;
  if fTags.Count = 0 then
    Exit;
  for i := 0 to Value do
  begin
    Inc(fPosition, Length(THTMLElement(fTags[i]).Orignal));
  end;
end;

procedure THTMLObject.Changed;
begin

end;

function THTMLObject.First: TTagObject;
begin
  Result := fTags[0];
  Current := 0;
end;

function THTMLObject.Last: TTagObject;
begin
  Result := fTags[fTags.Count - 1];
  Current := fTags.Count - 1;
end;

procedure THTMLObject.SetOnElementComplete(const Value
  : TParseElementCompleteEvent);
begin
  FOnElementComplete := Value;
end;

procedure THTMLObject.SetOnError(const Value: TParseErrorEvent);
begin
  FOnError := Value;
end;

procedure THTMLObject.DoComplete(ElementType: TElementType;
  Element: THTMLElement; var Continue: Boolean);
begin
  if Assigned(FOnElementComplete) then
    FOnElementComplete(Self, ElementType, Element, Continue);
end;

procedure THTMLObject.DoError(ErrCode: Integer; ErrMsg: String;
  var Continue: Boolean);
begin
  if Assigned(FOnError) then
    FOnError(Self, ErrCode, ErrMsg, Continue);
end;

initialization

ParentTags := TStringList.Create;
if FileExists('ptags.txt') then
  ParentTags.LoadFromFile('ptags.txt')
else
  ParentTags.CommaText := DefaultParents;

finalization

ParentTags.Free;

end.
