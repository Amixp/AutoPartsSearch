{

  Author: William.Yang
  Website: http://www.tiaon.com

}

unit HTMLObjs;

interface

uses Windows, Classes, SysUtils, Graphics;

type
  TObjectsList = class(TList)
  private
    function GetObjs(Index: Integer): TObject;
    procedure SetObjs(Index: Integer; Val: TObject);
  public
    procedure Clear;
    destructor Destroy; override;
    property Objects[Index: Integer]: TObject read GetObjs write SetObjs;
    procedure FreeItem(Index: Integer);
    procedure RemoveItem(Item: Pointer);
  end;

  THTMLElements = class;
  // THTMLStyleSheet = class;
  TTagObject = class;

  TTagState = (tsNone, tsBegin, tsEnd, tsPropertyName, tsSpace, tsEqual,
    tsPropertyValue);

  THTMLValueType = (utValue, utPercentage);

  THTMLValue = record
    UnitType: THTMLValueType;
    Value: Real;
  end;

  THTMLEvent = string;

  THTMLAlign = (haLeft, haRight, haTop, haTextTop, haMiddle, haAbsMiddle,
    haBaseline, haBottom, haAbsBottom);

  THTML4Tags = (hA, // Anchor
    hABBR, // Abbreviation
    hACRONYM, // Acronym
    hADDRESS, // Address
    hAPPLET, // Java applet
    hAREA, // Image map region
    hB, // Bold text
    hBASE, // Document base URI
    hBASEFONT, // Base font change
    hBDO, // BiDi override
    hBIG, // Large text
    hBLOCKQUOTE, // Block quotation
    hBODY, // Document body
    hBR, // Line break
    hBUTTON, // Button
    hCAPTION, // Table caption
    hCENTER, // Centered block
    hCITE, // Citation
    hCODE, // Computer code
    hCOL, // Table column
    hCOLGROUP, // Table column group
    hDD, // Definition description
    hDEL, // Deleted text
    hDFN, // Defined term
    hDIR, // Directory list
    hDIV, // Generic block, //level container
    hDL, // Definition list
    hDT, // Definition term
    hEM, // Emphasis
    hFIELDSET, // Form control group
    hFONT, // Font change
    hFORM, // Interactive form
    hFRAME, // Frame
    hFRAMESET, // Frameset
    hH1, // Level, //one heading
    hH2, // Level, //two heading
    hH3, // Level, //three heading
    hH4, // Level, //four heading
    hH5, // Level, //five heading
    hH6, // Level, //six heading
    hHEAD, // Document head
    hHR, // Horizontal rule
    hHTML, // HTML document
    hI, // Italic text
    hIFRAME, // Inline frame
    hIMG, // Inline image
    hINPUT, // Form input
    hINS, // Inserted text
    hISINDEX, // Input prompt
    hKBD, // Text to be input
    hLABEL, // Form field label
    hLEGEND, // Fieldset caption
    hLI, // List item
    hLINK, // Document relationship
    hMAP, // Image map
    hMENU, // Menu list
    hMETA, // Metadata
    hNOFRAMES, // Frames alternate content
    hNOSCRIPT, // Alternate script content
    hOBJECT, // Object
    hOL, // Ordered list
    hOPTGROUP, // Option group
    hOPTION, // Menu option
    hP, // Paragraph
    hPARAM, // Object parameter
    hPRE, // Preformatted text
    hQ, // Short quotation
    hS, // Strike, //through text
    hSAMP, // Sample output
    hSCRIPT, // Client, //side script
    hSELECT, // Option selector
    hSMALL, // Small text
    hSPAN, // Generic inline container
    hSTRIKE, // Strike, //through text
    hSTRONG, // Strong emphasis
    hSTYLE, // Embedded style sheet
    hSUB, // Subscript
    hSUP, // Superscript
    hTABLE, // Table
    hTBODY, // Table body
    hTD, // Table data cell
    hTEXTAREA, // Multi, //line text input
    hTFOOT, // Table foot
    hTH, // Table header cell
    hTHEAD, // Table head
    hTITLE, // Document title
    hTR, // Table row
    hTT, // Teletype text
    hU, // Underlined text
    hUL, // Unordered list
    hVAR, // Variable
    hNoIndex, //
    hComment, // Comment text
    hUnknown);

  THTMLElement = class(TObject)
  private
    fOwner: TTagObject;
    fOnChanged: TNotifyEvent;
    fOrignal: String;
    fPosition: Integer;
    FDocument: TObject;
    procedure SetPosition(const Value: Integer);
    procedure SetDocument(const Value: TObject);
  protected
    function GetAsText: String; virtual;
    procedure SetAsText(Val: String); virtual;
    procedure DoChanged;
  public
    constructor Create(AOwner: TTagObject); virtual;
    constructor CreateFromText(AOwner: TTagObject; ASource: String); virtual;

    function First: THTMLElement;
    function Last: THTMLElement;
    function Next: THTMLElement;
    function Prev: THTMLElement;

    property Document: TObject read FDocument write SetDocument;
    property Position: Integer read fPosition write SetPosition;
    property Text: String read GetAsText write SetAsText;
    property AsText: String read GetAsText write SetAsText;
    property Orignal: String read fOrignal;
    property Owner: TTagObject read fOwner write fOwner;
    property OnChanged: TNotifyEvent read fOnChanged write fOnChanged;
  end;

  TTagObject = class(THTMLElement)
  private
    fSubitems: THTMLElements;
    function getID: String;
    procedure SetDHTMLClass(const Value: String);
    procedure setID(const Value: String);
    procedure SetSTYLE(const Value: String);
    function getDHTMLClass: String;
    function getSTYLE: String;
    function getInnerHTML: String;
    function getInnerText: String;

  protected
    function GetAsText: String; override;
    procedure SetAsText(Val: String); override;

  public
    TagName: String;
    Properties: TStrings;
    TagType: THTML4Tags;

    function ReadBoolean(AName: String; ADefault: Boolean): Boolean;
    procedure WriteBoolean(AName: String; AValue: Boolean);
    function ReadColor(AName: String; ADefault: TColor): TColor;
    function ReadInteger(AName: String; ADefault: Integer): Integer;
    function ReadBool(AName: String): Boolean;
    function ReadString(AName: String; ADefault: String): String;
    procedure WriteColor(AName: String; AValue: TColor);
    procedure WriteInteger(AName: String; AValue: Integer);
    procedure WriteBool(AName: String; AValue: Boolean);
    procedure WriteString(AName: String; AValue: String);
    function ReadHTMLValue(AName: String): THTMLValue;
    procedure WriteHTMLValue(AName: String; AHTMLValue: THTMLValue);
    function CompareValue(AName, AValue: String): Boolean;

    // short hand procedures
    function _RS(AName: String; ADefault: String): String;
    function _RB(AName: String): Boolean;
    function _RI(AName: String; ADefault: Integer): Integer;
    function _RC(AName: String; ADefault: TColor): TColor;

    procedure _WS(AName: String; AValue: String);
    procedure _WB(AName: String; AValue: Boolean);
    procedure _WI(AName: String; AValue: Integer);
    procedure _WC(AName: String; AValue: TColor);

    procedure RemoveProperty(AName: String);
    function PropertyExists(AName: String): Boolean;
    function NameIs(ATestName: String): Boolean;

    constructor Create(AOwner: TTagObject); override;
    constructor CreateFromText(AOwner: TTagObject; ASource: String); override;
    destructor Destroy; override;

    function IsEmpty: Boolean;
    function IsEqualTo(ATag: TTagObject): Boolean;

    property Subitems: THTMLElements read fSubitems;
    property ID: String read getID write setID;
    property DHTMLClass: String read getDHTMLClass write SetDHTMLClass;
    property STYLE: String read getSTYLE write SetSTYLE;

    property innerText: String read getInnerText;
    property innerHTML: String read getInnerHTML;

  end;

  PTagObject = ^TTagObject;

  {
    THTMLBody = class(TTagObject)
    private
    function Get_aLink: TColor;
    function Get_background: String;
    function Get_bgColor: TColor;
    function Get_bgProperties: String;
    function Get_bottomMargin: THTMLValue;
    function Get_leftMargin: THTMLValue;
    function Get_link: TColor;
    function Get_noWrap: boolean;
    function Get_onbeforeunload: THTMLEvent;
    function Get_onload: THTMLEvent;
    function Get_onselect: THTMLEvent;
    function Get_onunload: THTMLEvent;
    function Get_rightMargin: THTMLValue;
    function Get_scroll: String;
    function Get_text: TColor;
    function Get_topMargin: THTMLValue;
    function Get_vLink: TColor;
    procedure Set_aLink(const Value: TColor);
    procedure Set_background(const Value: String);
    procedure Set_bgColor(const Value: TColor);
    procedure Set_bgProperties(const Value: String);
    procedure Set_bottomMargin(const Value: THTMLValue);
    procedure Set_leftMargin(const Value: THTMLValue);
    procedure Set_link(const Value: TColor);
    procedure Set_noWrap(const Value: boolean);
    procedure Set_onbeforeunload(const Value: THTMLEvent);
    procedure Set_onload(const Value: THTMLEvent);
    procedure Set_onselect(const Value: THTMLEvent);
    procedure Set_onunload(const Value: THTMLEvent);
    procedure Set_rightMargin(const Value: THTMLValue);
    procedure Set_scroll(const Value: String);
    procedure Set_text(const Value: TColor);
    procedure Set_topMargin(const Value: THTMLValue);
    procedure Set_vLink(const Value: TColor);
    public
    property background: String read Get_background write Set_background;
    property bgProperties: String read Get_bgProperties write Set_bgProperties;
    property leftMargin: THTMLValue read Get_leftMargin write Set_leftMargin;
    property topMargin: THTMLValue read Get_topMargin write Set_topMargin;
    property rightMargin: THTMLValue read Get_rightMargin write Set_rightMargin;
    property bottomMargin: THTMLValue read Get_bottomMargin write Set_bottomMargin;
    property noWrap: boolean read Get_noWrap write Set_noWrap;
    property bgColor: TColor read Get_bgColor write Set_bgColor;
    property text: TColor read Get_text write Set_text;
    property link: TColor read Get_link write Set_link;
    property vLink: TColor read Get_vLink write Set_vLink;
    property aLink: TColor read Get_aLink write Set_aLink;
    property onload: THTMLEvent read Get_onload write Set_onload;
    property onunload: THTMLEvent read Get_onunload write Set_onunload;
    property scroll: String read Get_scroll write Set_scroll;
    property onselect: THTMLEvent read Get_onselect write Set_onselect;
    property onbeforeunload: THTMLEvent read Get_onbeforeunload write Set_onbeforeunload;
    end;

    THTMLLink = class(TTagObject)
    private
    function Get_disabled: Boolean;
    function Get_href: String;
    function Get_media: String;
    function Get_onerror: THTMLEvent;
    function Get_onload: THTMLEvent;
    function Get_onreadystatechange: THTMLEvent;
    function Get_readyState: String;
    function Get_rel: String;
    function Get_rev: String;
    function Get_styleSheet: THTMLStyleSheet;
    function Get_type_: String;
    procedure Set_disabled(const Value: Boolean);
    procedure Set_href(const Value: String);
    procedure Set_media(const Value: String);
    procedure Set_onerror(const Value: THTMLEvent);
    procedure Set_onload(const Value: THTMLEvent);
    procedure Set_onreadystatechange(const Value: THTMLEvent);
    procedure Set_rel(const Value: String);
    procedure Set_rev(const Value: String);
    procedure Set_type_(const Value: String);
    public
    property href: String read Get_href write Set_href;
    property rel: String read Get_rel write Set_rel;
    property rev: String read Get_rev write Set_rev;
    property type_: String read Get_type_ write Set_type_;
    property readyState: String read Get_readyState;
    property onreadystatechange: THTMLEvent read Get_onreadystatechange write Set_onreadystatechange;
    property onload: THTMLEvent read Get_onload write Set_onload;
    property onerror: THTMLEvent read Get_onerror write Set_onerror;
    property styleSheet: THTMLStyleSheet read Get_styleSheet;
    property disabled: Boolean read Get_disabled write Set_disabled;
    property media: String read Get_media write Set_media;
    end;

    THTMLScript = class(TTagObject)
    private
    function Get_defer: Boolean;
    function Get_event: String;
    function Get_htmlFor: String;
    function Get_onerror: THTMLEvent;
    function Get_src: String;
    function Get_type_: String;
    procedure Set_defer(const Value: Boolean);
    procedure Set_event(const Value: String);
    procedure Set_htmlFor(const Value: String);
    procedure Set_onerror(const Value: THTMLEvent);
    procedure Set_src(const Value: String);
    procedure Set_type_(const Value: String);
    public
    property src: String read Get_src write Set_src;
    property htmlFor: String read Get_htmlFor write Set_htmlFor;
    property event: String read Get_event write Set_event;
    property defer: Boolean read Get_defer write Set_defer;
    property onerror: THTMLEvent read Get_onerror write Set_onerror;
    property type_: String read Get_type_ write Set_type_;
    end;

    THTMLSpan = class(TTagObject)
    private
    function getonAbort: THTMLEvent;
    function getonBlur: THTMLEvent;
    function getonClick: THTMLEvent;
    function getonDblClick: THTMLEvent;
    function getonDragStart: THTMLEvent;
    function getonFilterChange: THTMLEvent;
    function getonHelp: THTMLEvent;
    function getonKeyDown: THTMLEvent;
    function getonMouseDown: THTMLEvent;
    function getonMouseEnter: THTMLEvent;
    function getonMouseMove: THTMLEvent;
    function getonMouseOut: THTMLEvent;
    function getonMouseUp: THTMLEvent;
    function getonSelectStart: THTMLEvent;
    procedure SetonAbort(const Value: THTMLEvent);
    procedure SetonBlur(const Value: THTMLEvent);
    procedure SetonClick(const Value: THTMLEvent);
    procedure SetonDblClick(const Value: THTMLEvent);
    procedure SetonDragStart(const Value: THTMLEvent);
    procedure SetonFilterChange(const Value: THTMLEvent);
    procedure SetonHelp(const Value: THTMLEvent);
    procedure SetonKeyDown(const Value: THTMLEvent);
    procedure SetonMouseDown(const Value: THTMLEvent);
    procedure SetonMouseEnter(const Value: THTMLEvent);
    procedure SetonMouseMove(const Value: THTMLEvent);
    procedure SetonMouseOut(const Value: THTMLEvent);
    procedure SetonMouseUp(const Value: THTMLEvent);
    procedure SetonSelectStart(const Value: THTMLEvent);
    function getLanguage: String;
    procedure SetLanguage(const Value: String);
    procedure setDataSrc(const Value: String);
    function getDataFld: String;
    function getDataSrc: String;
    function getLang: String;
    procedure SetDataFld(const Value: String);
    procedure SetLang(const Value: String);
    public

    function ReadHTMLAlign(AName: String; ADefault: THTMLAlign): THTMLAlign;
    procedure WriteHTMLAlign(AName: String; AHTMLAlign: THTMLAlign);

    property Language: String read getLanguage write SetLanguage;
    property Lang: String read getLang write SetLang;
    property DataFld: String read getDataFld write SetDataFld;
    property DataSrc: String read getDataSrc write setDataSrc;
    property onAbort: THTMLEvent read getonAbort write SetonAbort;
    property onBlur: THTMLEvent read getonBlur write SetonBlur;

    property onClick: THTMLEvent read getonClick write SetonClick;
    property onDblClick: THTMLEvent read getonDblClick write SetonDblClick;
    property onDragStart: THTMLEvent read getonDragStart write SetonDragStart;
    property onFilterChange: THTMLEvent read getonFilterChange write SetonFilterChange;
    property onHelp: THTMLEvent read getonHelp write SetonHelp;
    property onKeyDown: THTMLEvent read getonKeyDown write SetonKeyDown;

    property onMouseDown: THTMLEvent read getonMouseDown write SetonMouseDown;
    property onMouseMove: THTMLEvent read getonMouseMove write SetonMouseMove;
    property onMouseOut: THTMLEvent read getonMouseOut write SetonMouseOut;
    property onMouseUp: THTMLEvent read getonMouseUp write SetonMouseUp;
    property onSelectStart: THTMLEvent read getonSelectStart write SetonSelectStart;
    property onMouseEnter: THTMLEvent read getonMouseEnter write SetonMouseEnter;
    end;

    THTMLDiv=THTMLSpan;

    THTMLFont = class(TTagObject)
    private
    procedure SetColor(const Value: TColor);
    procedure SetFace(const Value: String);
    procedure SetSize(const Value: Integer);
    function getFont: TFont;
    procedure setFont(const Value: TFont);
    function getColor: TColor;
    function getFace: String;
    function getSize: Integer;
    public
    constructor Create(AOwner: TTagObject); override;
    constructor CreateFromText(AOwner: TTagObject; ASource: String); override;

    property Face: String read getFace write SetFace;
    property Size: Integer read getSize write SetSize;
    property Color: TColor read getColor write SetColor;

    property Font: TFont read getFont write setFont;
    end;



    THTMLImage = class(THTMLSpan)
    private
    procedure SetAlign(const Value: THTMLAlign);
    procedure SetAlt(const Value: String);
    procedure SetDataFld(const Value: String);
    procedure SetHSpace(const Value: THTMLValue);
    procedure SetISMAP(const Value: Boolean);
    procedure SetLang(const Value: String);
    procedure SetLanguage(const Value: String);
    procedure SetLowSrc(const Value: String);
    procedure SetName(const Value: String);
    procedure SetSrc(const Value: String);
    procedure SetTitle(const Value: String);
    procedure SetVSpace(const Value: THTMLValue);
    function getAlign: THTMLAlign;
    function getAlt: String;
    function getDataFld: String;
    function getHSpace: THTMLValue;
    function getISMAP: Boolean;
    function getLang: String;
    function getLanguage: String;
    function getLowSrc: String;
    function getName: String;
    function getSrc: String;
    function getTitle: String;
    function getVSpace: THTMLValue;

    public
    property Align: THTMLAlign read getAlign write SetAlign;
    property Alt: String read getAlt write SetAlt;
    property ISMAP: Boolean read getISMAP write SetISMAP;
    property Src: String read getSrc write SetSrc;
    property VSpace: THTMLValue read getVSpace write SetVSpace;
    property HSpace: THTMLValue read getHSpace write SetHSpace;
    property LowSrc: String read getLowSrc write SetLowSrc;
    property Name: String read getName write SetName;
    property Title: String read getTitle write SetTitle;
    property Lang: String read getLang write SetLang;

    end;

    THTMLAnchor = class(THTMLSpan)
    private
    function getHREF: String;
    function getMethods: String;
    function getName: String;
    function getRel: String;
    function getRev: String;
    function getTarget: String;
    function getTitle: String;
    procedure setHREF(const Value: String);
    procedure setMethods(const Value: String);
    procedure setName(const Value: String);
    procedure setRel(const Value: String);
    procedure setRev(const Value: String);
    procedure setTarget(const Value: String);
    procedure setTitle(const Value: String);
    function getHash: String;
    function getHost: String;
    function getHostname: String;
    function getMimeType: String;
    function getNameProp: String;
    function getPathname: String;
    function getPort: String;
    function getProtocol: String;
    function getProtocolLong: String;
    function getSearch: String;
    function getTabIndex: Smallint;
    procedure setAccesskey(const Value: String);
    procedure setHash(const Value: String);
    procedure setHost(const Value: String);
    procedure setHostname(const Value: String);
    procedure setPathname(const Value: String);
    procedure setPort(const Value: String);
    procedure setProtocol(const Value: String);
    procedure setSearch(const Value: String);
    procedure setTabIndex(const Value: Smallint);
    function getAccessKey: String;
    public
    property HREF: String read getHREF write setHREF;
    property Name: String read getName write setName;
    property Target: String read getTarget write setTarget;
    property Rel: String read getRel write setRel;
    property Rev: String read getRev write setRev;
    property Title: String read getTitle write setTitle;
    property Methods: String read getMethods write setMethods;

    property host: String read getHost write setHost;
    property hostname: String read getHostname write setHostname;
    property pathname: String read getPathname write setPathname;
    property port: String read getPort write setPort;
    property protocol: String read getProtocol write setProtocol;
    property search: String read getSearch write setSearch;
    property hash: String read getHash write setHash;
    property accessKey: String read getAccessKey write setAccesskey;
    property protocolLong: String read getProtocolLong;
    property mimeType: String read getMimeType;
    property nameProp: String read getNameProp;
    property tabIndex: Smallint read getTabIndex write setTabIndex;
    procedure focus; virtual; abstract;
    procedure blur;  virtual; abstract;
    end;

    TTagParagraph = class(TTagObject)
    private
    fFont: THTMLFont;
    public

    end; }

  TNormalText = class(THTMLElement)
  private
    fContent: String;
  protected
    function GetAsText: String; override;
    procedure SetAsText(Val: String); override;
  public
    constructor CreateFromText(AOwner: TTagObject; ASource: String); override;
  end;

  TScriptObject = class(TNormalText)
  public

  end;

  TStyleSheetElement = (seFontFamily, seFontStyle, seFontVariant, seFontWeight,
    seFontSize,
    // Color and background
    seColor, seBackgroundColor, seBackgroundImage, seBackgroundRepeat,
    seBackgroundAttachment,
    // Text Properties
    seLetterSpacing, seWordSpacing, seTextDecoration, seVerticalAlign,
    seTextTransform, seTextAlign, seTextIndent, seLineHeight,
    // Border
    seMarginTop, seMarginRight, seMarginBottom, seMarginLeft, sePaddingTop,
    sePaddingRight, sePaddingBottom, sePaddingLeft,

    seWidth, seHeight, seClear, seFloat, seBorder, seBorderStyle, seBorderColor,
    seBorderWidth, seBorderTop, seBorderTopWidth, seBorderTopStyle,
    seBorderTopColor, seBorderRight, seBorderRightWidth, seBorderRightStyle,
    seBorderRightColor, seBorderBottom, seBorderBottomWidth,
    seBorderBottomStyle, seBorderBottomColor, seBorderLeft, seBorderLeftWidth,
    seBorderLeftStyle, seBorderLeftColor,

    seDisplay, seListStyle, seListImage, seListPos, seWhiteSpace, seFilter);


  // body {font: xxxx; }

  TStyleClass = class(THTMLElement)
  protected
    function GetAsText: String; override;
    procedure SetAsText(Val: String); override;
  public
    Name: String;
    Elements: array [TStyleSheetElement] of String;

  end;

  THTMLStyleSheet = class(TTagObject)
  end;

  // the one look like in C++ /* .... */
  TStyleComment = class(TNormalText);

  TStyleObject = class(TNormalText)
  private
  protected
    function GetAsText: String; override;
    procedure SetAsText(Val: String); override;

  public
    Classes: TObjectsList;
  end;

  THTMLElements = class(TList)
  private
    function GetElements(i: Integer): THTMLElement;
    procedure SetElements(i: Integer; Val: THTMLElement);
  public
    property Elements[i: Integer]: THTMLElement read GetElements
      write SetElements; default;
    destructor Destroy; override;
  end;

  THTMLTable = class(TTagObject)
  private
    function GetCells(ACol, ARow: Integer): THTMLElement;
    function GetRows(ARow: Integer): THTMLElement;
    procedure SetCells(ACol, ARow: Integer; const Value: THTMLElement);
    procedure SetRows(ARow: Integer; const Value: THTMLElement);

  public
    constructor Create(AOwner: TTagObject); override;
    property Cells[ACol, ARow: Integer]: THTMLElement read GetCells
      write SetCells;
    property Rows[ARow: Integer]: THTMLElement read GetRows write SetRows;
  end;

function TagToTagObject(ATag: String): TTagObject;
function TagObjToTag(TagObj: TTagObject): String;
function ColorToHTML(C: TColor): String;
function htmlToColor(S: String): TColor;

implementation

uses Strman, HTMLParser;

const
  HTMLAlignData: array [THTMLAlign] of string = ('Left', 'Right', 'Top',
    'TextTop', 'Middle', 'AbsMiddle', 'Baseline', 'Bottom', 'AbsBottom');

  // BreakChars = [WideChar(#$0009), WideChar(#$0008), WideChar(#$0020), WideChar(#$000A), WideChar(#$000D)];
  BreakChars = [#9, #8, #32, #13, #10];

var
  fTmpFont: TFont;

function ColorToHTML(C: TColor): String;
var
  r, g, b: Byte;
begin
  r := C shr 16;
  g := C shr 8;
  b := C;
  Result := '#' + IntToHex(r, 2) + IntToHex(g, 2) + IntToHex(b, 2);
end;

function htmlToColor(S: String): TColor;
const
  Digits: String = '0123456789ABCDEF';
  Order: array [1 .. 6] of Integer = (5, 6, 3, 4, 1, 2);
var
  i: Integer;
begin
  Result := 0;
  S := UpperCase(S);
  if S[1] = '#' then
  begin
    Delete(S, 1, 1);
    for i := 1 to Length(S) do
      Result := Result shl 4 + Pos(S[Order[i]], Digits) - 1;
  end
  else
  begin
    if S = 'BLACK' then
      Result := clBlack
    else if S = 'WHITE' then
      Result := clWhite
    else if S = 'GREEN' then
      Result := clGreen
    else if S = 'BLUE' then
      Result := clBlue
    else if S = 'GRAY' then
      Result := clGray
    else if S = 'RED' then
      Result := clRed
    else if S = 'YELLOW' then
      Result := clYellow
    else if S = 'OLIVE' then
      Result := clOlive
    else if S = 'TEAL' then
      Result := clTeal
    else if S = 'AQUA' then
      Result := clAqua
    else if S = 'FUCHSIA' then
      Result := clFuchsia
    else if S = 'PURPLE' then
      Result := clPurple
    else if S = 'SILVER' then
      Result := clSilver
    else if S = 'MAROON' then
      Result := clMaroon
    else if S = 'NAVY' then
      Result := clNavy
    else if S = 'LIME' then
      Result := clLime;
  end;
end;

procedure RemoveQuote(var S: String);
begin
  if Length(S) <= 2 then
    Exit;
  if S[1] = '"' then
    Delete(S, 1, 1);
  if S[Length(S)] = '"' then
    Delete(S, Length(S), 1);
end;

function HTMLAlignToString(AHTMLAlign: THTMLAlign): String;
begin
  Result := HTMLAlignData[AHTMLAlign];
end;

function StringToHTMLAlign(aStr: String): THTMLAlign;
var
  i: THTMLAlign;
begin
  Result := haLeft;
  for i := Low(THTMLAlign) to High(THTMLAlign) do
  begin
    if CompareText(HTMLAlignData[i], aStr) = 0 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TagToTagObject(ATag: String): TTagObject;
var
  i: Integer;
  S, t: String;
  Stage: Integer;
  Breaket: Boolean;
begin
  Result := TTagObject.Create(nil);
  if ATag = '' then
    Exit;
  S := ATag;
  if S[1] = '<' then
    Delete(S, 1, 1);
  if S = '' then
    Exit;
  if S[Length(S)] = '>' then
    Delete(S, Length(S), 1);
  if S = '' then
    Exit;
  Stage := 1;
  Breaket := False;
  for i := 1 to Length(S) do
  begin
    t := t + WideCharToString(@S[i]);
    if S[i] = '"' then
      Breaket := not Breaket;
    if ((S[i] in BreakChars) or (i = Length(S))) and (t <> '') and (not Breaket)
    then
    begin
      case Stage of
        1:
          begin
            Result.TagName := Trim(t);
            Stage := 2;
          end;
        2:
          if not Breaket then
            Result.Properties.Add(Trim(t));
      end;
      t := '';
    end;
  end;
end;

function TagObjToTag(TagObj: TTagObject): String;
var
  i: Integer;
begin
  Result := '<' + TagObj.TagName;
  for i := 0 to TagObj.Properties.Count - 1 do
  begin
    Result := Result + ' ' + TagObj.Properties[i];
  end;
  Result := Result + '>';
end;

function TestTagType(AName: String): THTML4Tags;
const
  HTMLTags: array [0 .. 92] of String = ('A', 'ABBR', 'ACRONYM', 'ADDRESS',
    'APPLET', 'AREA', 'B', 'BASE', 'BASEFONT', 'BDO', 'BIG', 'BLOCKQUOTE',
    'BODY', 'BR', 'BUTTON', 'CAPTION', 'CENTER', 'CITE', 'CODE', 'COL',
    'COLGROUP', 'DD', 'DEL', 'DFN', 'DIR', 'DIV', 'DL', 'DT', 'EM', 'FIELDSET',
    'FONT', 'FORM', 'FRAME', 'FRAMESET', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6',
    'HEAD', 'HR', 'HTML', 'I', 'IFRAME', 'IMG', 'INPUT', 'INS', 'ISINDEX',
    'KBD', 'LABEL', 'LEGEND', 'LI', 'LINK', 'MAP', 'MENU', 'META', 'NOFRAMES',
    'NOSCRIPT', 'OBJECT', 'OL', 'OPTGROUP', 'OPTION', 'P', 'PARAM', 'PRE', 'Q',
    'S', 'SAMP', 'SCRIPT', 'SELECT', 'SMALL', 'SPAN', 'STRIKE', 'STRONG',
    'STYLE', 'SUB', 'SUP', 'TABLE', 'TBODY', 'TD', 'TEXTAREA', 'TFOOT', 'TH',
    'THEAD', 'TITLE', 'TR', 'TT', 'U', 'UL', 'VAR', 'noindex', '!--');
var
  i: Integer;
  S: String;
begin
  Result := hUnknown;
  if AName = '' then
    Exit;
  if AName[1] = '/' then
    S := Copy(AName, 2, Length(AName))
  else
    S := AName;
  for i := 0 to 92 do
  begin
    if CompareText(leftstr(S, Length(HTMLTags[i])), HTMLTags[i]) = 0 then
    begin
      Result := THTML4Tags(i);
      Exit;
    end;
  end;
  Result := hUnknown;
end;

{ TObjectsList }
destructor TObjectsList.Destroy;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    FreeItem(0);
  inherited Destroy;
end;

function TObjectsList.GetObjs(Index: Integer): TObject;
begin
  Result := TObject(Items[Index]);
end;

procedure TObjectsList.SetObjs(Index: Integer; Val: TObject);
begin
  Items[Index] := @Val;
end;

procedure TObjectsList.FreeItem(Index: Integer);
begin
  if Index < 0 then
    Exit;
  Objects[Index].Free;
  inherited Delete(Index);
end;

procedure TObjectsList.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    FreeItem(0);
end;

procedure TObjectsList.RemoveItem(Item: Pointer);
var
  i: Integer;
begin
  i := IndexOf(Item);
  if i < 0 then
    Exit;
  FreeItem(i);
end;

{ THTMLElement }
constructor THTMLElement.Create(AOwner: TTagObject);
begin
  inherited Create;
  fOwner := AOwner;
end;

constructor THTMLElement.CreateFromText(AOwner: TTagObject; ASource: String);
begin
  Self.Create(AOwner);
  fOrignal := ASource;
end;

procedure THTMLElement.DoChanged;
begin
  if Assigned(fOnChanged) then
    fOnChanged(Self);
end;

function THTMLElement.First: THTMLElement;
begin
  if fOwner <> nil then
  begin
    if fOwner.Subitems.Count > 0 then
      Result := fOwner.Subitems[0]
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function THTMLElement.GetAsText: String;
begin
  // nothing to do yet.
end;

function THTMLElement.Last: THTMLElement;
begin
  if fOwner <> nil then
  begin
    if fOwner.Subitems.Count > 0 then
      Result := fOwner.Subitems[fOwner.Subitems.Count - 1]
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function THTMLElement.Next: THTMLElement;
var
  Index: Integer;
begin
  if fOwner <> nil then
  begin
    index := fOwner.Subitems.IndexOf(Self);
    if Index + 1 <= fOwner.Subitems.Count - 1 then
      Result := fOwner.Subitems[Index + 1]
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function THTMLElement.Prev: THTMLElement;
var
  Index: Integer;
begin
  if fOwner <> nil then
  begin
    index := fOwner.Subitems.IndexOf(Self);
    if Index - 1 >= 0 then
      Result := fOwner.Subitems[Index - 1]
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure THTMLElement.SetAsText(Val: String);
begin
  // changed
  DoChanged;
end;

procedure THTMLElement.SetDocument(const Value: TObject);
begin
  FDocument := Value;
end;

procedure THTMLElement.SetPosition(const Value: Integer);
begin
  fPosition := Value;
end;

{ THTMLElements }
function THTMLElements.GetElements(i: Integer): THTMLElement;
begin
  Result := THTMLElement(Items[i]);
end;

procedure THTMLElements.SetElements(i: Integer; Val: THTMLElement);
begin
  Items[i] := Val;
end;

destructor THTMLElements.Destroy;
begin
  inherited Destroy;
end;

{ TTagObject }
constructor TTagObject.Create(AOwner: TTagObject);
begin
  inherited Create(AOwner);
  Properties := TStringList.Create;
  fSubitems := THTMLElements.Create;
end;

destructor TTagObject.Destroy;
begin
  fSubitems.Free;
  Properties.Free;
  inherited Destroy;
end;

constructor TTagObject.CreateFromText(AOwner: TTagObject; ASource: String);
begin
  inherited CreateFromText(AOwner, ASource);
  Properties := TStringList.Create;
  fSubitems := THTMLElements.Create;
  Text := ASource;
end;

function TTagObject.GetAsText: String;
begin
  Result := TagObjToTag(Self);
end;

procedure TTagObject.SetAsText(Val: String);
var
  i: Integer;
  S, t: String;
  Stage: Integer;
  Breaket: Boolean;
begin
  if Val = '' then
    Exit;
  S := Val;
  if S[1] = '<' then
    Delete(S, 1, 1);
  if S = '' then
    Exit;
  if S[Length(S)] = '>' then
    Delete(S, Length(S), 1);
  if S = '' then
    Exit;
  Stage := 1;
  Breaket := False;
  for i := 1 to Length(S) do
  begin
    t := t + S[i];
    if S[i] = '"' then
      Breaket := not Breaket;
    if ((S[i] in BreakChars) or (i = Length(S))) and (t <> '') and (not Breaket)
    then
    begin
      case Stage of
        1:
          begin
            TagName := Trim(t);
            Stage := 2;
          end;
        2:
          if not Breaket then
            Properties.Add(Trim(t));
      end;
      t := '';
    end;
  end;
  TagType := TestTagType(TagName);
end;

function TTagObject.ReadColor(AName: String; ADefault: TColor): TColor;
var
  S: String;
begin
  S := ReadString(AName, '');
  if (S <> '') then
  begin
    Result := htmlToColor(S);;
  end
  else
  begin
    Result := ADefault;
  end;
end;

function TTagObject.ReadInteger(AName: String; ADefault: Integer): Integer;
var
  S: String;
begin
  S := ReadString(AName, '');
  if (S <> '') then
  begin
    Result := StrToIntDef(S, ADefault);
  end
  else
  begin
    Result := ADefault;
  end;
end;

function TTagObject.ReadString(AName: String; ADefault: String): String;
var
  i: Integer;
begin
  Result := ADefault;
  for i := 0 to Properties.Count - 1 do
    if CompareText(Properties.Names[i], AName) = 0 then
    begin
      Result := Properties.ValueFromIndex[i];
      RemoveQuote(Result);
      Break
    end;
end;

function TTagObject.ReadBool(AName: String): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Properties.Count - 1 do
    if CompareText(Trim(Properties[i]), AName) = 0 then
    begin
      Result := True;
      Break
    end;
end;

function TTagObject.ReadBoolean(AName: String; ADefault: Boolean): Boolean;
const
  BoolToStr: array [Boolean] of String = ('FALSE', 'TRUE');
begin
  if UpperCase(ReadString(AName, BoolToStr[ADefault])) = 'TRUE' then
    Result := True
  else
    Result := False;
end;

procedure TTagObject.WriteBoolean(AName: String; AValue: Boolean);
const
  BoolToStr: array [Boolean] of String = ('FALSE', 'TRUE');
begin
  WriteString(AName, BoolToStr[AValue]);
end;

procedure TTagObject.WriteColor(AName: String; AValue: TColor);
begin
  if AValue = clNone then
    RemoveProperty(AName)
  else
    WriteString(AName, ColorToHTML(AValue));
end;

procedure TTagObject.WriteInteger(AName: String; AValue: Integer);
begin
  WriteString(AName, IntToStr(AValue));
end;

procedure TTagObject.WriteString(AName: String; AValue: String);
begin
  if AValue = '' then
    RemoveProperty(AName)
  else
  begin
    if Properties.IndexOfName(AName) >= 0 then
    begin
      Properties.Values[AName] := Format('"%s"', [Trim(AValue)]);
    end
    else
      Properties.Add(Format('%s="%s"', [Trim(AName), Trim(AValue)]));
  end;
end;

procedure TTagObject.WriteBool(AName: String; AValue: Boolean);
var
  i, j: Integer;
begin
  j := -1;
  for i := 0 to Properties.Count - 1 do
    if CompareText(Trim(Properties[i]), AName) = 0 then
    begin
      j := i;
      Break
    end;
  if AValue then
  begin
    if j >= 0 then
      Properties[j] := AName
    else
      Properties.Add(AName);
  end
  else
  begin
    if j >= 0 then
      Properties.Delete(j);
  end;
end;

function TTagObject.IsEmpty: Boolean;
begin
  Result := Properties.Count = 0;
end;

procedure TTagObject.RemoveProperty(AName: String);
var
  i: Integer;
begin
  i := Properties.IndexOfName(AName);
  if i >= 0 then
    Properties.Delete(i);
end;

function TTagObject.NameIs(ATestName: String): Boolean;
begin
  Result := CompareText(TagName, ATestName) = 0;
end;

function TTagObject.PropertyExists(AName: String): Boolean;
begin
  Result := Properties.IndexOfName(AName) >= 0;
end;

function TTagObject.IsEqualTo(ATag: TTagObject): Boolean;
var
  i: Integer;
  S: String;
begin
  Result := False;
  for i := 0 to Properties.Count - 1 do
  begin
    S := Properties[i];
    if CompareText(ReadString(S, ''), ATag.ReadString(S, '')) <> 0 then
      Exit;
  end;
  Result := True;
end;

function TTagObject.getID: String;
begin

end;

procedure TTagObject.SetDHTMLClass(const Value: String);
begin
  _WS('class', Value);
end;

procedure TTagObject.setID(const Value: String);
begin
  _WS('id', Value);
end;

procedure TTagObject.SetSTYLE(const Value: String);
begin
  _WS('style', Value);
end;

function TTagObject.ReadHTMLValue(AName: String): THTMLValue;
var
  S: String;
begin
  S := ReadString(AName, '');
  if S <> '' then
  begin
    // if the last char is "%"
    if Pos('%', S) = Length(S) then
    begin
      Result.UnitType := utPercentage;
      Delete(S, Length(S), 1);
    end
    else
      Result.UnitType := utValue;
    Result.Value := StrToFloat(S);
  end;
end;

procedure TTagObject.WriteHTMLValue(AName: String; AHTMLValue: THTMLValue);
var
  S: String;
begin
  with AHTMLValue do
  begin
    S := FloatToStr(Value);
    if UnitType = utPercentage then
      S := S + '%';
  end;
  WriteString(AName, S);
end;

function TTagObject._RB(AName: String): Boolean;
begin
  Result := ReadBool(AName);
end;

function TTagObject._RC(AName: String; ADefault: TColor): TColor;
begin
  Result := ReadColor(AName, ADefault);
end;

function TTagObject._RI(AName: String; ADefault: Integer): Integer;
begin
  Result := ReadInteger(AName, ADefault);
end;

function TTagObject._RS(AName, ADefault: String): String;
begin
  Result := ReadString(AName, ADefault);
end;

procedure TTagObject._WB(AName: String; AValue: Boolean);
begin
  WriteBool(AName, AValue);
end;

procedure TTagObject._WC(AName: String; AValue: TColor);
begin
  WriteColor(AName, AValue);
end;

procedure TTagObject._WI(AName: String; AValue: Integer);
begin
  WriteInteger(AName, AValue);
end;

procedure TTagObject._WS(AName, AValue: String);
begin
  WriteString(AName, AValue);
end;

function TTagObject.getDHTMLClass: String;
begin

end;

function TTagObject.getSTYLE: String;
begin

end;

function TTagObject.getInnerHTML: String;
var
  i: Integer;
  ele: THTMLElement;
  HTMLObject: THTMLObject;
  fNoClosingTag: Boolean;
begin
  Result := '';
  fNoClosingTag := True;
  if (Self.Document = nil) then
  begin
    Exit;
  end;
  HTMLObject := THTMLObject(Self.Document); // !! добавил
  for i := fPosition + 1 to HTMLObject.Tags.Count - 1 do
  begin
    ele := HTMLObject.Tags[i];
    if (ele is TNormalText) then
    begin
      Result := Result + TNormalText(ele).Text;
    end
    else if (ele is TTagObject) then
    begin
      if (TTagObject(ele).NameIs('/' + Self.TagName)) then
      begin
        fNoClosingTag := False;
        Break;
      end
      else
      begin
        Result := Result + TTagObject(ele).Text;
      end;
    end;
  end;
  if (fNoClosingTag) then
  begin
    Result := '';
  end;
end;

function TTagObject.getInnerText: String;
var
  i: Integer;
  ele: THTMLElement;
  HTMLObject: THTMLObject;
  fNoClosingTag: Boolean;
begin
  Result := '';
  { DONE : Ќайти и убрать комментарий(<!-- коментарий -->) из текста }
  fNoClosingTag := True; { DONE : »зменить: теги в тексте на пробелы }
  if (Self.Document = nil) then
  begin
    Exit;
  end;
  HTMLObject := THTMLObject(Self.Document);
  for i := fPosition + 1 to HTMLObject.Tags.Count - 1 do
  begin
    ele := HTMLObject.Tags[i];
    if (ele is TNormalText) then
    begin
      Result := Result + TNormalText(ele).Text;
    end
    else if (ele is TTagObject) then
    begin
      if (TTagObject(ele).NameIs('/' + Self.TagName)) then
      begin
        fNoClosingTag := False;
        Break;
      end
      else
        Result := Result + ' '; // мен€ем теги на пробелы в тексте
    end;
  end;
  if (fNoClosingTag) then
  begin
    Result := '';
  end;
end;

function TTagObject.CompareValue(AName, AValue: String): Boolean;
begin
  Result := (CompareText(ReadString(AName, ''), AValue) = 0);
end;

{ TNormalText }
function TNormalText.GetAsText: String;
begin
  Result := fContent;
end;

procedure TNormalText.SetAsText(Val: String);
begin
  fContent := Val;
  inherited SetAsText(Val);
end;

constructor TNormalText.CreateFromText(AOwner: TTagObject; ASource: String);
begin
  inherited CreateFromText(AOwner, ASource);
  fContent := ASource;
end;

(*
  { TTagFont }

  constructor THTMLFont.Create(AOwner: TTagObject);
  begin
  inherited Create(AOwner);

  end;

  constructor THTMLFont.CreateFromText(AOwner: TTagObject; ASource: String);
  begin
  inherited CreateFromText(AOwner, ASource);

  end;

  function THTMLFont.getColor: TColor;
  begin
  Result := ReadColor('color', clNone);
  end;

  function THTMLFont.getFace: String;
  begin
  Result := ReadString('face', '');
  end;

  function THTMLFont.getFont: TFont;
  begin
  if fTmpFont=nil then
  fTmpFont := TFont.Create;
  with fTmpFont do
  begin
  Name := getFace;
  Size := getSize;
  Color := getColor;
  end;
  Result := fTMpFont;
  end;

  function THTMLFont.getSize: Integer;
  begin
  Result := ReadInteger('size', 0);
  end;

  procedure THTMLFont.SetColor(const Value: TColor);
  begin
  WriteColor('color', Value);
  end;

  procedure THTMLFont.SetFace(const Value: String);
  begin
  WriteString('face', Value);
  end;

  procedure THTMLFont.setFont(const Value: TFont);
  begin
  with Value do
  begin
  setFace(Name);
  case Abs(Size) of
  0..8: setSize(1);
  9..11: setSize(2);
  12..14: setSize(3);
  15..19: setSize(4);
  20..25:  setSize(5);
  else setSize(6);
  end;
  setColor(Color);
  end;
  end;

  procedure THTMLFont.SetSize(const Value: Integer);
  begin
  WriteInteger('size', Value);
  end;

*)

{ TStyleClass }

function TStyleClass.GetAsText: String;
begin

end;

procedure TStyleClass.SetAsText(Val: String);
const
  fElementsName: array [TStyleSheetElement] of String = ('font-family',
    'font-style', 'font-variant', 'font-weight', 'fontsize',
    // Color and background
    'color', 'background-color', 'background-image', 'background-repeat',
    'background-attachment',

    // Text Properties
    'letter-spacing', 'word-spacing', 'text-decoration', 'vertical-align',
    'text-transform', 'text-align', 'text-indent', 'line-height',
    // Box
    'margin-top', 'margin-right', 'margin-bottom', 'margin-left', 'padding-Top',
    'padding-right', 'padding-bottom', 'padding-left',
    // Border
    'width', 'height', 'clear', 'float', 'border', 'border-style',
    'border-color', 'border-width', 'border-top', 'border-top-width',
    'border-top-style', 'border-top-color', 'border-right',
    'border-right-width', 'border-right-style', 'border-right-color',
    'border-bottom', 'border-bottom-width', 'border-bottom-style',
    'border-bottom-color', 'border-left', 'border-left-width',
    'border-left-style', 'border-left-color',

    // Classification Properties
    'display', 'list-style-type', 'list-style-image', 'list-style-position',
    'white-space', 'filter');
var
  S, t, CSS: String;
  i, j: Integer;
  Back, State: Integer;
  PropertyName, Value: String;

  procedure SetValue;
  var
    p: String;
    i: TStyleSheetElement;
  begin
    p := LowerCase(PropertyName);
    for i := Low(TStyleSheetElement) to High(TStyleSheetElement) do
    begin
      if p = fElementsName[i] then
        Elements[i] := Value;
    end;
  end;

begin
  CSS := Val;
  i := 1;
  while i < Length(CSS) do
  begin
    case CSS[i] of
      // skip these chars.
      #0, ' ', #13, #10, #9:
        ; // do noting
      // check for the comment, and skip them
      '/':
        if i <> Length(CSS) then
          if CSS[i + 1] = '*' then
            i := Instr(i, CSS, '*/');

      '{':
        begin
          Name := S;
          S := '';
        end;

      // : indicates the start of the value, and end of the property name
      ':':
        begin
          PropertyName := S;
          S := '';
        end;
      // a complete set is finished so add it
      ';', '}':
        begin
          if PropertyName <> '' then
          begin
            Value := S;
            SetValue;
            PropertyName := '';
            S := '';
          end;
        end;
      // add everything else
    else
      S := S + WideCharToString(@CSS[i]);
    end;
    Inc(i);
  end;
  if PropertyName <> '' then
  begin
    Value := S;
    SetValue;
  end;
end;

{ TStyleObject }

function TStyleObject.GetAsText: String;
begin

end;

procedure TStyleObject.SetAsText(Val: String);
const
  sComment = 4;
  sNone = 0;
  sInProc = 2;
var
  S, t, CSS: String;
  i, j: Integer;
  StartPos, ClassLen: Integer;
  Quate: Boolean;
  PropertyName, Value: String;
begin
  CSS := Val;
  Quate := False;
  i := 1;
  while i < Length(CSS) do
  begin
    case CSS[i] of
      // skip these chars.
      #0, #9:
        ; // do noting
      // check for the comment, and skip them
      '/':
        if i <> Length(CSS) then
        begin
          if CSS[i + 1] = '*' then
          begin
            j := Instr(i, CSS, '*/');
            Classes.Add(TStyleComment.CreateFromText(Owner, Copy(CSS, i, j)));
            i := j;
          end;
        end;
      // a new class starts
      '"', '''':
        Quate := not Quate;
      #13, #10, ' ':
        begin
          if StartPos = -1 then
          begin
            StartPos := i;
            S := '';
          end;
        end;
      // a complete set is finished so add it
      '}':
        if not Quate then
        begin
          if StartPos <> -1 then
          begin
            ClassLen := i - StartPos;
            Classes.Add(TStyleClass.CreateFromText(Owner, Copy(CSS, StartPos,
              ClassLen)));
            StartPos := -1;
          end;
        end;
    end;
    Inc(i);
  end;
end;

(*

  { THTMLImage }

  function THTMLImage.getAlign: THTMLAlign;
  begin
  Result := ReadHTMLAlign('align', haleft);
  end;

  function THTMLImage.getAlt: String;
  begin
  Result := ReadString('alt', '');
  end;

  function THTMLImage.getDataFld: String;
  begin
  Result := ReadString('DataFld', '');
  end;

  function THTMLImage.getHSpace: THTMLValue;
  begin
  Result := ReadHTMLValue('hspace');
  end;

  function THTMLImage.getISMAP: Boolean;
  begin
  Result := ReadBool('ISMAP');
  end;

  function THTMLImage.getLang: String;
  begin
  Result := ReadString('lang', '');
  end;

  function THTMLImage.getLanguage: String;
  begin

  end;

  function THTMLImage.getLowSrc: String;
  begin
  Result := ReadString('lowsrc', '');
  end;

  function THTMLImage.getName: String;
  begin
  Result := ReadString('name', '');
  end;


  function THTMLImage.getSrc: String;
  begin
  Result := ReadString('name', '');
  end;

  function THTMLImage.getTitle: String;
  begin
  Result := ReadString('title', '');
  end;

  function THTMLImage.getVSpace: THTMLValue;
  begin
  Result := ReadHTMLValue('vspace');
  end;

  procedure THTMLImage.SetAlign(const Value: THTMLAlign);
  begin
  WriteHTMLAlign('Algin', Value);
  end;

  procedure THTMLImage.SetAlt(const Value: String);
  begin
  WriteString('Alt', Value);
  end;

  procedure THTMLImage.SetDataFld(const Value: String);
  begin
  WriteString('Datafld', Value);
  end;

  procedure THTMLImage.SetHSpace(const Value: THTMLValue);
  begin
  WriteHTMLValue('HSpace', Value);
  end;

  procedure THTMLImage.SetISMAP(const Value: Boolean);
  begin
  WriteBool('ISMAP', Value);
  end;

  procedure THTMLImage.SetLang(const Value: String);
  begin
  WriteString('Lang', Value);
  end;

  procedure THTMLImage.SetLanguage(const Value: String);
  begin
  WriteString('Language', Value);
  end;

  procedure THTMLImage.SetLowSrc(const Value: String);
  begin
  WriteString('LowSrc', Value);
  end;

  procedure THTMLImage.SetName(const Value: String);
  begin
  WriteString('Name', Value);
  end;

  procedure THTMLImage.SetSrc(const Value: String);
  begin
  WriteString('Src', Value);
  end;

  procedure THTMLImage.SetTitle(const Value: String);
  begin
  WriteString('Title', Value);
  end;

  procedure THTMLImage.SetVSpace(const Value: THTMLValue);
  begin
  WriteHTMLValue('VSpace', Value);
  end;

  { THTMLSpan }

  procedure THTMLSpan.setDataSrc(const Value: String);
  begin
  WriteString('DataSrc', Value);
  end;

  function THTMLSpan.getDataFld: String;
  begin
  Result := ReadString('DataFld', '');
  end;

  function THTMLSpan.getDataSrc: String;
  begin

  end;

  function THTMLSpan.getLang: String;
  begin

  end;

  function THTMLSpan.getLanguage: String;
  begin
  Result := ReadString('language', '');
  end;

  function THTMLSpan.getonAbort: THTMLEvent;
  begin
  Result := ReadString('onabort', '');
  end;

  function THTMLSpan.getonBlur: THTMLEvent;
  begin
  Result := ReadString('onblur', '');
  end;

  function THTMLSpan.getonClick: THTMLEvent;
  begin
  Result := ReadString('onclick', '');
  end;

  function THTMLSpan.getonDblClick: THTMLEvent;
  begin
  Result := ReadString('ondblclick', '');
  end;

  function THTMLSpan.getonDragStart: THTMLEvent;
  begin
  Result := ReadString('ondragstart', '');
  end;

  function THTMLSpan.getonFilterChange: THTMLEvent;
  begin
  Result := ReadString('onfilterchange', '');
  end;

  function THTMLSpan.getonHelp: THTMLEvent;
  begin
  Result := ReadString('onhelp', '');
  end;

  function THTMLSpan.getonKeyDown: THTMLEvent;
  begin
  Result := ReadString('onkeydown', '');
  end;

  function THTMLSpan.getonMouseDown: THTMLEvent;
  begin
  Result := ReadString('onmousedown', '');
  end;

  function THTMLSpan.getonMouseEnter: THTMLEvent;
  begin
  Result := ReadString('onmouseenter', '');
  end;

  function THTMLSpan.getonMouseMove: THTMLEvent;
  begin
  Result := ReadString('onmousemove', '');
  end;

  function THTMLSpan.getonMouseOut: THTMLEvent;
  begin
  Result := ReadString('onmouseout', '');
  end;

  function THTMLSpan.getonMouseUp: THTMLEvent;
  begin
  Result := ReadString('onmouseup', '');
  end;

  function THTMLSpan.getonSelectStart: THTMLEvent;
  begin
  Result := ReadString('onselectstart', '');
  end;

  function THTMLSpan.ReadHTMLAlign(AName: String;
  ADefault: THTMLAlign): THTMLAlign;
  var
  s: String;
  begin
  s := ReadString('align', '');
  if s='' then
  Result := ADefault
  else
  Result := StringToHTMLAlign(s);
  end;

  procedure THTMLSpan.SetDataFld(const Value: String);
  begin

  end;

  procedure THTMLSpan.SetLang(const Value: String);
  begin

  end;

  procedure THTMLSpan.SetLanguage(const Value: String);
  begin
  WriteString('language', Value);
  end;

  procedure THTMLSpan.SetonAbort(const Value: THTMLEvent);
  begin
  WriteString('onabort', Value);
  end;

  procedure THTMLSpan.SetonBlur(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonClick(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonDblClick(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonDragStart(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonFilterChange(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonHelp(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonKeyDown(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonMouseDown(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonMouseEnter(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonMouseMove(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonMouseOut(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonMouseUp(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.SetonSelectStart(const Value: THTMLEvent);
  begin

  end;

  procedure THTMLSpan.WriteHTMLAlign(AName: String; AHTMLAlign: THTMLAlign);
  begin
  WriteString('align', HTMLAlignToString(AHtmlAlign));
  end;

  { THTMLAnchor }

  function THTMLAnchor.getAccessKey: String;
  begin

  end;

  function THTMLAnchor.getHash: String;
  begin

  end;

  function THTMLAnchor.getHost: String;
  begin

  end;

  function THTMLAnchor.getHostname: String;
  begin

  end;

  function THTMLAnchor.getHREF: String;
  begin
  Result := _RS('HREF', '');
  end;

  function THTMLAnchor.getMethods: String;
  begin
  Result := _RS('Methods', '');
  end;

  function THTMLAnchor.getMimeType: String;
  begin

  end;

  function THTMLAnchor.getName: String;
  begin
  Result := _RS('Name', '');
  end;

  function THTMLAnchor.getNameProp: String;
  begin

  end;

  function THTMLAnchor.getPathname: String;
  begin

  end;

  function THTMLAnchor.getPort: String;
  begin

  end;

  function THTMLAnchor.getProtocol: String;
  begin

  end;

  function THTMLAnchor.getProtocolLong: String;
  begin

  end;

  function THTMLAnchor.getRel: String;
  begin
  Result := _RS('REL', '');
  end;

  function THTMLAnchor.getRev: String;
  begin
  Result := _RS('REV', '');
  end;

  function THTMLAnchor.getSearch: String;
  begin

  end;

  function THTMLAnchor.getTabIndex: Smallint;
  begin

  end;

  function THTMLAnchor.getTarget: String;
  begin
  Result := _RS('Target', '');
  end;

  function THTMLAnchor.getTitle: String;
  begin
  Result := _RS('Title', '');
  end;

  procedure THTMLAnchor.setAccesskey(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setHash(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setHost(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setHostname(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setHREF(const Value: String);
  begin
  _WS('HREF', Value);
  end;

  procedure THTMLAnchor.setMethods(const Value: String);
  begin
  _WS('Methods', Value);
  end;

  procedure THTMLAnchor.setName(const Value: String);
  begin
  _WS('Name', Value);
  end;

  procedure THTMLAnchor.setPathname(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setPort(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setProtocol(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setRel(const Value: String);
  begin
  _WS('REL', Value);
  end;

  procedure THTMLAnchor.setRev(const Value: String);
  begin
  _WS('REV', Value);
  end;

  procedure THTMLAnchor.setSearch(const Value: String);
  begin

  end;

  procedure THTMLAnchor.setTabIndex(const Value: Smallint);
  begin

  end;

  procedure THTMLAnchor.setTarget(const Value: String);
  begin
  _WS('Target', Value);
  end;

  procedure THTMLAnchor.setTitle(const Value: String);
  begin
  _WS('Title', Value);
  end;

  { THTMLBody }

  function THTMLBody.Get_aLink: TColor;
  begin
  result := _RC('alink', clRed);
  end;

  function THTMLBody.Get_background: String;
  begin
  result := _RS('background', '');
  end;

  function THTMLBody.Get_bgColor: TColor;
  begin
  result := _RC('bgcolor', clWhite);
  end;

  function THTMLBody.Get_bgProperties: String;
  begin
  result := _RS('bgProperties', '');
  end;

  function THTMLBody.Get_bottomMargin: THTMLValue;
  begin
  result := ReadHTMLValue('bottommargin');
  end;

  function THTMLBody.Get_leftMargin: THTMLValue;
  begin
  result := ReadHTMLValue('leftmargin');
  end;

  function THTMLBody.Get_link: TColor;
  begin
  result := _RC('link', clBlue);
  end;

  function THTMLBody.Get_noWrap: boolean;
  begin
  result := _RB('nowrap');
  end;

  function THTMLBody.Get_onbeforeunload: THTMLEvent;
  begin
  result := _RS('onbeforeunload', '');
  end;

  function THTMLBody.Get_onload: THTMLEvent;
  begin
  result := _RS('onload', '');
  end;

  function THTMLBody.Get_onselect: THTMLEvent;
  begin
  result := _RS('onselect', '');
  end;

  function THTMLBody.Get_onunload: THTMLEvent;
  begin
  result := _RS('onunload', '');
  end;

  function THTMLBody.Get_rightMargin: THTMLValue;
  begin
  result := ReadHTMLValue('rightmargin');
  end;

  function THTMLBody.Get_scroll: String;
  begin
  result := _RS('scroll', '');
  end;

  function THTMLBody.Get_text: TColor;
  begin
  result := _RC('text', clBlack);
  end;

  function THTMLBody.Get_topMargin: THTMLValue;
  begin
  result := ReadHTMLValue('topMargin');
  end;

  function THTMLBody.Get_vLink: TColor;
  begin
  result := _RC('vlink', clPurple);
  end;

  procedure THTMLBody.Set_aLink(const Value: TColor);
  begin
  _WC('alink', value);
  end;

  procedure THTMLBody.Set_background(const Value: String);
  begin
  _WS('background', value);
  end;

  procedure THTMLBody.Set_bgColor(const Value: TColor);
  begin
  _WC('bgColor', value);
  end;

  procedure THTMLBody.Set_bgProperties(const Value: String);
  begin
  _WS('bgProperties', value);
  end;

  procedure THTMLBody.Set_bottomMargin(const Value: THTMLValue);
  begin
  WriteHTMLValue('bottomMargin', Value);
  end;

  procedure THTMLBody.Set_leftMargin(const Value: THTMLValue);
  begin
  WriteHTMLValue('leftMargin', Value);
  end;

  procedure THTMLBody.Set_link(const Value: TColor);
  begin
  _WC('link', Value);
  end;

  procedure THTMLBody.Set_noWrap(const Value: boolean);
  begin
  _WB('noWarp', Value);
  end;

  procedure THTMLBody.Set_onbeforeunload(const Value: THTMLEvent);
  begin
  _WS('onbeforeunload', value);
  end;

  procedure THTMLBody.Set_onload(const Value: THTMLEvent);
  begin
  _WS('onload', value);
  end;

  procedure THTMLBody.Set_onselect(const Value: THTMLEvent);
  begin
  _WS('onselect', value);
  end;

  procedure THTMLBody.Set_onunload(const Value: THTMLEvent);
  begin
  _WS('onunload', value);
  end;

  procedure THTMLBody.Set_rightMargin(const Value: THTMLValue);
  begin
  WriteHTMLValue('rightMargin', Value);
  end;

  procedure THTMLBody.Set_scroll(const Value: String);
  begin
  _WS('scroll', Value);
  end;

  procedure THTMLBody.Set_text(const Value: TColor);
  begin
  _WC('text', Value);
  end;

  procedure THTMLBody.Set_topMargin(const Value: THTMLValue);
  begin
  WriteHTMLValue('topMargin', Value);
  end;

  procedure THTMLBody.Set_vLink(const Value: TColor);
  begin
  _WC('vLink', Value);
  end;

  { THTMLLink }

  function THTMLLink.Get_disabled: Boolean;
  begin
  result := _RB('disabled');
  end;

  function THTMLLink.Get_href: String;
  begin
  result := _RS('href', '');
  end;

  function THTMLLink.Get_media: String;
  begin
  result := _RS('media', '');
  end;

  function THTMLLink.Get_onerror: THTMLEvent;
  begin
  result := _RS('onerror', '');
  end;

  function THTMLLink.Get_onload: THTMLEvent;
  begin
  result := _RS('onload', '');
  end;

  function THTMLLink.Get_onreadystatechange: THTMLEvent;
  begin
  result := _RS('onreadystatechange', '');
  end;

  function THTMLLink.Get_readyState: String;
  begin
  Result := _RS('readystate', '');
  end;

  function THTMLLink.Get_rel: String;
  begin
  Result := _RS('rel', '');
  end;

  function THTMLLink.Get_rev: String;
  begin
  Result := _RS('rel', '');
  end;

  function THTMLLink.Get_styleSheet: THTMLStyleSheet;
  begin
  // not implemented
  end;

  function THTMLLink.Get_type_: String;
  begin
  Result := _RS('type', '');
  end;

  procedure THTMLLink.Set_disabled(const Value: Boolean);
  begin
  _Wb('disabled', value);
  end;

  procedure THTMLLink.Set_href(const Value: String);
  begin
  _WS('href', value);
  end;

  procedure THTMLLink.Set_media(const Value: String);
  begin
  _WS('media', value);
  end;

  procedure THTMLLink.Set_onerror(const Value: THTMLEvent);
  begin
  _WS('onerror', value);
  end;

  procedure THTMLLink.Set_onload(const Value: THTMLEvent);
  begin
  _WS('onload', value);
  end;

  procedure THTMLLink.Set_onreadystatechange(const Value: THTMLEvent);
  begin
  _WS('onreadystatechange', value);
  end;

  procedure THTMLLink.Set_rel(const Value: String);
  begin
  _WS('rel', value);
  end;

  procedure THTMLLink.Set_rev(const Value: String);
  begin
  _WS('rev', value);
  end;

  procedure THTMLLink.Set_type_(const Value: String);
  begin
  _WS('type', value);
  end;

  { THTMLScript }

  function THTMLScript.Get_defer: Boolean;
  begin
  Result := _RB('defer');
  end;

  function THTMLScript.Get_event: String;
  begin
  Result := _RS('event', '');
  end;

  function THTMLScript.Get_htmlFor: String;
  begin
  Result := _RS('htmlfor', '');
  end;

  function THTMLScript.Get_onerror: THTMLEvent;
  begin
  Result := _RS('onerror', '');
  end;

  function THTMLScript.Get_src: String;
  begin
  Result := _RS('src', '');
  end;

  function THTMLScript.Get_type_: String;
  begin
  Result := _RS('type', '');
  end;

  procedure THTMLScript.Set_defer(const Value: Boolean);
  begin
  _WB('defer', Value);
  end;

  procedure THTMLScript.Set_event(const Value: String);
  begin
  _WS('event', Value);
  end;

  procedure THTMLScript.Set_htmlFor(const Value: String);
  begin
  _WS('htmlfor', Value);
  end;

  procedure THTMLScript.Set_onerror(const Value: THTMLEvent);
  begin
  _WS('onerror', Value);
  end;

  procedure THTMLScript.Set_src(const Value: String);
  begin
  _WS('src', Value);
  end;

  procedure THTMLScript.Set_type_(const Value: String);
  begin
  _WS('type', Value);
  end;

*)

{ THTMLTable }

constructor THTMLTable.Create(AOwner: TTagObject);
begin
  inherited Create(AOwner);

end;

function THTMLTable.GetCells(ACol, ARow: Integer): THTMLElement;
begin { TODO : “ут должна быть обработка таблицы! }

end;

function THTMLTable.GetRows(ARow: Integer): THTMLElement;
begin

end;

procedure THTMLTable.SetCells(ACol, ARow: Integer; const Value: THTMLElement);
begin

end;

procedure THTMLTable.SetRows(ARow: Integer; const Value: THTMLElement);
begin

end;

end.
