{ **** UBPFD *********** by kladovka.net.ru ****
  >> ��������� ��������� �� ������ �� ��� �������, � ����� ��������� ������ ����� ���������� � ������

  � ����� ������������ ��� �������, ���� �� �������, GetParamFromString, ��������� �������� �������� �� ������, �� ������� ����� ��������� (���������� ���������� � 1). ���������� � ������, � ������� ����� �����, ���������� �����-������ ���������� ������������, �������� �������� ";".
  � ������ ������ "fex;9x-1;code" ����� ��� ���������:
  fex
  9x-1
  code.

  �������� ���������� ������� GetParamFromString:
  SourceStr - ������, ���������� � ���� ���������;
  Delimiter - ����������� ���������� � ������;
  Ind - ������ �������������� ���������.

  ������� GetParamsCount ������ ���������� ���������� ���������� � ������.
  �������� ���������� ������� GetParamsCount:
  SourceStr - ������, ���������� � ���� ���������;
  Delimiter - ����������� ���������� � ������;

  �����������: Windows
  �����:       VID, ICQ:132234868, ���������
  Copyright:   (c) �� ��
  ����:        26 ������ 2004 �.
  ********************************************** }

unit getstrparam;

interface

uses Windows;

type
  TDelim = set of Char;
  TArrayOfString = Array of String;

function GetParamsCount(const SourceStr, Delimiter: String): integer;
function GetParamFromString(const SourceStr, Delimiter: String;
  Ind: integer): string;
function fcToParts(sString: String; tdDelim: TDelim): TArrayOfString;

implementation

function GetDTextItem(DText, delimeter: pchar; var idx: integer): pchar;
var
  nextpos: pchar;
  i, len, p: integer;
begin
  result := DText;
  len := length(delimeter);
  if (len = 0) or (DText = '') then
    exit;
  i := 1;
  while TRUE do
  begin
    p := pos(delimeter, result);
    if (p <> 0) then
      nextpos := pointer(integer(result) + p - 1)
    else
      nextpos := pointer(integer(result) + length(result));
    if (i = idx) or (p = 0) then
      break;
    result := pointer(integer(nextpos) + len);
    inc(i);
  end;
  if i = idx then
    // byte(nextpos^) := 0     { TODO : ���������. ����� �� ���������� }
  else
    // byte(result^) := 0;
end;

function GetDTextCount(DText, delimeter: pchar): integer;
var
  subpos: pchar;
  i, len: integer;
begin
  result := 0;
  len := length(delimeter);
  if (len = 0) or (DText = '') then
    exit;
  subpos := DText;
  i := pos(delimeter, subpos);
  while i <> 0 do
  begin
    inc(result);
    subpos := pointer(integer(subpos) + i + len - 1);
    i := pos(delimeter, subpos);
  end;
  if (byte(subpos^)) <> 0 then
    inc(result);
end;

function GetParamsCount(const SourceStr, Delimiter: String): integer;
begin
  result := GetDTextCount(pchar(SourceStr), pchar(Delimiter));
end;

function GetParamFromString(const SourceStr, Delimiter: String;
  Ind: integer): string;
var
  TmpS, TmpRes: pchar;
  LRes: integer;
begin
  GetMem(TmpS, length(SourceStr) + 1);
  try
    CopyMemory(TmpS, pchar(SourceStr), length(SourceStr));
    byte(pointer(integer(TmpS) + length(SourceStr))^) := 0;
    TmpRes := GetDTextItem(TmpS, pchar(Delimiter), Ind);
    LRes := length(TmpRes);
    SetLength(result, LRes);
    CopyMemory(@result[1], TmpRes, LRes);
  finally
    FreeMem(TmpS);
  end;
end;

// *******************
//
// ��������� ������ � ������������� �� �����
// � ���������� ������ ������
//
// fcToParts
//

function fcToParts(sString: String; tdDelim: TDelim): TArrayOfString;
var
  iCounter, iBegin: integer;
begin // fc
  if length(sString) > 0 then
  begin
    include(tdDelim, #0);
    iBegin := 1;
    SetLength(result, 0);
    For iCounter := 1 to length(sString) do
    begin // for

      if (sString[iCounter] in tdDelim) or (iCounter = length(sString)) then
      begin
        SetLength(result, length(result) + 1);
        // if (iCounter - iBegin)>1 then
        result[length(result) - 1] := Copy(sString, iBegin, iCounter - iBegin);
        iBegin := iCounter + 1;
      end;
    end; // for
  end; // if
end; // fc

{

  #0:http:
  #1:
  #2:parts.japancar.ru
  #3:?code=parts
  #4:mode=old
  #5:cl=search_partsoldng
  #6:cl_partCode=3cvFLjAwNg_1316
  #7:cl_marka=TOYOTA
  #8:cl_model=4RUNNER
  #9:cl_kuzovN=kuzov
  #10:cl_engineN=dvigatel
  #11:cl_modelN=optika
  #12:cl_note=primechanie
}
end.
