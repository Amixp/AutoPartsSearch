unit UnitSend;

interface

uses SysUtils, System.IOUtils,
  IdUserPassProvider, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP, IdSASLPlain, IdSASL, IdSASLUserPass,
  IdSASLLogin, IdMessage, IdLogBase, IdAntiFreeze, IdAttachment,
  IdAttachmentFile, IdText, IdLogDebug, IdCoder, IdCoderQuotedPrintable,
  IdIntercept, IdHTTP,
  Classes;

type
  dt = string; // пустое определение для обьчвления функций ниже!
  // странное решение, но работает! :)

function PostHTTP(idHTTPvar: TIdHTTP; sURL: string; PostData: tstrings): string;
function GetHTTP(idHTTPvar: TIdHTTP; sURL: string): string;
procedure SendMail(idMsg: TIdMessage);
procedure SendMail1(idMsg: TIdMessage);
function SendMail2(sFrom, sTo, sHost, sPort, sSubject, sLogin, sPass, sBody: string; slAttachments: tstrings): boolean;
// function sSendMail(aHost: String): Boolean;
procedure TestMail;
// procedure TestMail2;
procedure SendAtach;
procedure SendHTMLMail;
procedure AttacheFiles(var mIdMessage: TIdMessage; BodyHTML: string; sAttacheFilesPath: tstrings);

implementation

uses MainUnit, SearchUnit;


end.
