unit multilog;

{ Copyright (C) 2006 Luiz Am�rico Pereira C�mara

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

{$mode objfpc}{$H+}
//todo: add a way to send customdata (OnSendCustomData)??
interface

uses
  Classes, SysUtils;

const
  //MessageTypes
  //mt (Message Type) and lt (Log Type) prefixes are used elsewhere
  //but mt is worse because there's already mtWarning and mtInformation
  //the existing lt* do not makes confusion
  ltInfo    = 0;
  ltError   = 1;
  ltWarning = 2;
  ltValue   = 3;
  ltEnterMethod = 4;
  ltExitMethod  = 5;
  ltConditional = 6;
  ltCheckpoint = 7;
  ltStrings = 8;
  ltCallStack = 9;
  ltObject = 10;
  ltException = 11;
  ltBitmap = 12;
  ltHeapInfo = 13;

  ltWatch = 20;



  ltClear=100;

  
type

  TDebugClass = 0..31;
  
  TLogMessage = record
    MsgType: Integer;
    MsgTime: TDateTime;
    MsgText: String;
    Data: TStream;
  end;

  { TLogChannel }

  TLogChannel = class
  private
    FActive: Boolean;
  public
    procedure Clear; virtual; abstract;
    procedure Deliver(const AMsg: TLogMessage);virtual;abstract;
    property Active: Boolean read FActive write FActive;
  end;
  
  { TChannelList }

  TChannelList = class
  private
    FList: TFpList;
    function GetCount: Integer; //inline;
    function GetItems(AIndex:Integer): TLogChannel; //inline;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AChannel: TLogChannel):Integer;
    procedure Remove(AChannel:TLogChannel);
    property Count: Integer read GetCount;
    property Items[AIndex:Integer]: TLogChannel read GetItems; default;
  end;

  { TLogger }

  TLogger = class
  private
    FDefaultClass: TDebugClass;
    FMaxStackCount: Integer;
    FChannels:TChannelList;
    FLogStack: TStrings;
    FCheckList: TStrings;
    procedure GetCallStack(AStream:TStream);
    //todo: add SendStrings??
    procedure SendString(AMsgType: Integer;const AText:String);
    procedure SendStream(AMsgType: Integer;const AText:String; AStream: TStream);
    procedure SetMaxStackCount(const AValue: Integer);
  public
    ActiveClasses: set of TDebugClass;//Made a public field to allow use of include/exclude functions
    constructor Create;
    destructor Destroy; override;
    function CalledBy(const AMethodName: String): Boolean;
    procedure Clear;
    //Send functions
    procedure Send(const AText: String); //inline;
    procedure Send(AClass: TDebugClass; const AText: String);
    procedure Send(const AText: String; Args: array of const); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; Args: array of const);
    procedure Send(const AText, AValue: String); //inline;
    procedure Send(AClass: TDebugClass; const AText,AValue: String);
    procedure Send(const AText: String; AValue: Integer); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; AValue: Integer);
    procedure Send(const AText: String; AValue: Double); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; AValue: Double);
    procedure Send(const AText: String; AValue: Boolean); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; AValue: Boolean);
    procedure Send(const AText: String; ARect: TRect); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; ARect: TRect);
    procedure Send(const AText: String; APoint: TPoint); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; APoint: TPoint);
    procedure Send(const AText: String; AStrList: TStrings); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; AStrList: TStrings);
    procedure Send(const AText: String; AObject: TObject); //inline;
    procedure Send(AClass: TDebugClass; const AText: String; AObject: TObject);
    procedure SendCallStack(const AText: String); //inline;
    procedure SendCallStack(AClass: TDebugClass; const AText: String);
    procedure SendException(const AText: String; AException: Exception); //inline;
    procedure SendException(AClass: TDebugClass; const AText: String; AException: Exception);
    procedure SendHeapInfo(const AText: String); //inline;
    procedure SendHeapInfo(AClass: TDebugClass; const AText: String);
    procedure SendIf(const AText: String; Expression: Boolean); //inline;
    procedure SendIf(AClass: TDebugClass; const AText: String; Expression: Boolean); //inline;
    procedure SendIf(const AText: String; Expression, IsTrue: Boolean); //inline;
    procedure SendIf(AClass: TDebugClass; const AText: String; Expression, IsTrue: Boolean);
    procedure SendWarning(const AText: String); //inline;
    procedure SendWarning(AClass: TDebugClass; const AText: String);
    procedure SendError(const AText: String); //inline;
    procedure SendError(AClass: TDebugClass; const AText: String);
    procedure AddCheckPoint;
    procedure AddCheckPoint(AClass: TDebugClass);
    procedure AddCheckPoint(const CheckName: String);
    procedure AddCheckPoint(AClass: TDebugClass; const CheckName: String);
    procedure ResetCheckPoint;
    procedure ResetCheckPoint(AClass: TDebugClass);
    procedure ResetCheckPoint(const CheckName: String);
    procedure ResetCheckPoint(AClass: TDebugClass;const CheckName: String);
    procedure EnterMethod(const AMethodName: String); //inline;
    procedure EnterMethod(AClass: TDebugClass; const AMethodName: String); //inline;
    procedure EnterMethod(Sender: TObject; const AMethodName: String); //inline;
    procedure EnterMethod(AClass: TDebugClass; Sender: TObject; const AMethodName: String);
    procedure ExitMethod(const AMethodName: String); //inline;
    procedure ExitMethod(Sender: TObject; const AMethodName: String); //inline;
    procedure ExitMethod(AClass: TDebugClass; const AMethodName: String); //inline;
    procedure ExitMethod(AClass: TDebugClass; Sender: TObject; const AMethodName: String);
    procedure Watch(const AText, AValue: String); //inline;
    procedure Watch(AClass: TDebugClass; const AText,AValue: String);
    procedure Watch(const AText: String; AValue: Integer); //inline;
    procedure Watch(AClass: TDebugClass; const AText: String; AValue: Integer);
    procedure Watch(const AText: String; AValue: Double); //inline;
    procedure Watch(AClass: TDebugClass; const AText: String; AValue: Double);
    procedure Watch(const AText: String; AValue: Boolean); //inline;
    procedure Watch(AClass: TDebugClass; const AText: String; AValue: Boolean);
    property Channels: TChannelList read FChannels;
    property DefaultClass: TDebugClass read FDefaultClass write FDefaultClass;
    property LogStack: TStrings read FLogStack;
    property MaxStackCount: Integer read FMaxStackCount write SetMaxStackCount;
  end;

implementation
//todo: create an common procedure to fill astream?
//      something like SetStream (var AStream: TStream; CallBackProcedureThatReturnsAString)??
const
  DefaultCheckName = 'CheckPoint';

function FormatNumber (Value: Integer):String;
var
  TempStr:String;
  i,Digits:Integer;
begin
  Digits:=0;
  Result:='';
  TempStr:=IntToStr(Value);
  for i := length(TempStr) downto 1 do
  begin
    //todo: implement using mod() -> get rids of digits
    if Digits = 3 then
    begin
      Digits:=0;
      Result:=ThousandSeparator+Result;
    end;
    Result:=TempStr[i]+Result;
    Inc(Digits);
  end;
end;

{ TLogger }

procedure TLogger.GetCallStack(AStream: TStream);
var
  i : Longint;
  prevbp : Pointer;
  caller_frame,
  caller_addr,
  bp : Pointer;
  S:String;
begin
  //routine adapted from fpc source

  //This trick skip SendCallstack item
  //bp:=get_frame;
  bp:= get_caller_frame(get_frame);
  try
    prevbp:=bp-1;
    i:=0;
    //is_dev:=do_isdevice(textrec(f).Handle);
    while bp > prevbp Do
     begin
       caller_addr := get_caller_addr(bp);
       caller_frame := get_caller_frame(bp);
       if (caller_addr=nil) then
         break;
       S:=BackTraceStrFunc(caller_addr)+LineEnding;
       AStream.WriteBuffer(S[1],Length(S));
       Inc(i);
       if (i>=FMaxStackCount) or (caller_frame=nil) then
         break;
       prevbp:=bp;
       bp:=caller_frame;
     end;
   except
     { prevent endless dump if an exception occured }
   end;
end;

procedure TLogger.SendString(AMsgType: Integer; const AText: String);
begin
  SendStream(AMsgType,AText,nil);
end;

procedure TLogger.SendStream(AMsgType: Integer; const AText: String;
  AStream: TStream);
var
  MsgRec: TLogMessage;
  i:Integer;
begin
  with MsgRec do
  begin
    MsgType:=AMsgType;
    MsgTime:=Now;
    MsgText:=AText;
    Data:=AStream;
  end;
  for i:= 0 to Channels.Count - 1 do
    if Channels[i].Active then
      Channels[i].Deliver(MsgRec);
end;

procedure TLogger.SetMaxStackCount(const AValue: Integer);
begin
  if AValue < 256 then
    FMaxStackCount:=AValue
  else
    FMaxStackCount:=256;
end;

constructor TLogger.Create;
begin
  FChannels:=TChannelList.Create;
  FMaxStackCount:=20;
  FLogStack:=TStringList.Create;
  FCheckList:=TStringList.Create;
  ActiveClasses:=[0];
end;

destructor TLogger.Destroy;
begin
  FChannels.Destroy;
  FLogStack.Destroy;
  FCheckList.Destroy;
end;

function TLogger.CalledBy(const AMethodName: String): Boolean;
begin
  Result:=FLogStack.IndexOf(UpperCase(AMethodName)) <> -1;
end;

procedure TLogger.Clear;
var
  i: Integer;
begin
  for i:= 0 to Channels.Count - 1 do
    if Channels[i].Active then
      Channels[i].Clear;
end;

procedure TLogger.Send(const AText: String);
begin
  Send(FDefaultClass,AText);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltInfo,AText);
end;

procedure TLogger.Send(const AText: String; Args: array of const);
begin
  Send(FDefaultClass,AText,Args);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String;
  Args: array of const);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltInfo, Format(AText,Args));
end;

procedure TLogger.Send(const AText, AValue: String);
begin
  Send(FDefaultClass,AText,AValue);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText, AValue: String);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltValue,AText+' = '+AValue);
end;

procedure TLogger.Send(const AText: String; AValue: Integer);
begin
  Send(FDefaultClass,AText,AValue);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String; AValue: Integer);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltValue,AText+' = '+IntToStr(AValue));
end;

procedure TLogger.Send(const AText: String; AValue: Double);
begin
  Send(FDefaultClass,AText,AValue);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String; AValue: Double
  );
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltValue,AText+' = '+FloatToStr(AValue));
end;

procedure TLogger.Send(const AText: String; AValue: Boolean);
begin
  Send(FDefaultClass,AText,AValue);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String; AValue: Boolean);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltValue,AText+' = '+BoolToStr(AValue));
end;

procedure TLogger.Send(const AText: String; ARect: TRect);
begin
  Send(FDefaultClass,AText,ARect);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String; ARect: TRect);
begin
  if not (AClass in ActiveClasses) then Exit;
  with ARect do
    SendString(ltValue,Format('%s = (Left: %d; Top: %d; Right: %d; Bottom: %d)',[AText,Left,Top,Right,Bottom]));
end;

procedure TLogger.Send(const AText: String; APoint: TPoint);
begin
  Send(FDefaultClass,AText,APoint);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String; APoint: TPoint
  );
begin
  if not (AClass in ActiveClasses) then Exit;
  with APoint do
    SendString(ltValue,Format('%s = (X: %d; Y: %d)',[AText,X,Y]));
end;

procedure TLogger.Send(const AText: String; AStrList: TStrings);
begin
  Send(FDefaultClass,AText,AStrList);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String;
  AStrList: TStrings);
var
  AStream:TStream;
begin
  if not (AClass in ActiveClasses) then Exit;
  AStream:=TMemoryStream.Create;
  try
    AStrList.SaveToStream(AStream);
    SendStream(ltStrings,AText,AStream);
  finally
    AStream.Destroy;
  end;
end;

procedure TLogger.Send(const AText: String; AObject: TObject);
begin
  Send(FDefaultClass,AText,AObject);
end;

procedure TLogger.Send(AClass: TDebugClass; const AText: String;
  AObject: TObject);
var
  TempStr: String;
  AStream: TStream;
begin
  if not (AClass in ActiveClasses) then Exit;
  AStream:=nil;
  TempStr:=AText+' (';
  if AObject <> nil then
  begin
    if AObject is TComponent then
    begin
      TempStr:= TempStr+ ('"'+TComponent(AObject).Name+'"/');
      AStream:=TMemoryStream.Create;
      AStream.WriteComponent(TComponent(AObject));
    end;
    TempStr:=TempStr+(AObject.ClassName+'/');
  end;
  TempStr:=TempStr+('$'+HexStr(PtrInt(AObject),SizeOf(PtrInt)*2)+')');

  SendStream(ltObject,TempStr,AStream);
  if AStream <> nil then
    AStream.Destroy;
end;

procedure TLogger.SendCallStack(const AText: String);
begin
  SendCallStack(FDefaultClass,AText);
end;

procedure TLogger.SendCallStack(AClass: TDebugClass; const AText: String);
var
  AStream: TStream;
begin
  if not (AClass in ActiveClasses) then Exit;
  AStream:=TMemoryStream.Create;
  try
    GetCallStack(AStream);
    SendStream(ltCallStack,AText,AStream);
  finally
    AStream.Destroy;
  end;
end;

procedure TLogger.SendException(const AText: String; AException: Exception);
begin
  SendException(FDefaultClass,AText,AException);
end;

procedure TLogger.SendException(AClass: TDebugClass; const AText: String;
  AException: Exception);
var
  AStream: TStream;
  i: Integer;
  Frames: PPointer;
  S:String;
begin
  if not (AClass in ActiveClasses) then Exit;
  AStream:=TMemoryStream.Create;
  if AException <> nil then
    S:=AException.ClassName+' - '+AException.Message+LineEnding;
  S:=S + BackTraceStrFunc(ExceptAddr);
  Frames:=ExceptFrames;
  for i:= 0 to ExceptFrameCount - 1 do
    S:=S + (LineEnding+BackTraceStrFunc(Frames[i]));
  AStream.WriteBuffer(S[1],Length(S));
  SendStream(ltException,AText,AStream);
  AStream.Destroy;
end;

procedure TLogger.SendHeapInfo(const AText: String);
begin
  SendHeapInfo(FDefaultClass,AText);
end;

procedure TLogger.SendHeapInfo(AClass: TDebugClass; const AText: String);
var
  AStream:TStream;
  S: String;
begin
  if not (AClass in ActiveClasses) then Exit;
  AStream:=TMemoryStream.Create;
  with GetFPCHeapStatus do
  begin
    S:='MaxHeapSize: '+FormatNumber(MaxHeapSize)+LineEnding
      +'MaxHeapUsed: '+FormatNumber(MaxHeapUsed)+LineEnding
      +'CurrHeapSize: '+FormatNumber(CurrHeapSize)+LineEnding
      +'CurrHeapUsed: '+FormatNumber(CurrHeapUsed)+LineEnding
      +'CurrHeapFree: '+FormatNumber(CurrHeapFree);
  end;
  AStream.WriteBuffer(S[1],Length(S));
  SendStream(ltHeapInfo,AText,AStream);
  AStream.Destroy;
end;

procedure TLogger.SendIf(const AText: String; Expression: Boolean);
begin
  SendIf(FDefaultClass,AText,Expression,True);
end;

procedure TLogger.SendIf(AClass: TDebugClass; const AText: String; Expression: Boolean
  );
begin
  SendIf(AClass,AText,Expression,True);
end;

procedure TLogger.SendIf(const AText: String; Expression, IsTrue: Boolean);
begin
  SendIf(FDefaultClass,AText,Expression,IsTrue);
end;

procedure TLogger.SendIf(AClass: TDebugClass; const AText: String; Expression,
  IsTrue: Boolean);
begin
  if not (AClass in ActiveClasses) or (Expression <> IsTrue) then Exit;
  SendString(ltConditional,AText);
end;

procedure TLogger.SendWarning(const AText: String);
begin
  SendWarning(FDefaultClass,AText);
end;

procedure TLogger.SendWarning(AClass: TDebugClass; const AText: String);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltWarning,AText);
end;

procedure TLogger.SendError(const AText: String);
begin
  SendError(FDefaultClass,AText);
end;

procedure TLogger.SendError(AClass: TDebugClass; const AText: String);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltError,AText);
end;

procedure TLogger.AddCheckPoint;
begin
  AddCheckPoint(FDefaultClass,DefaultCheckName);
end;

procedure TLogger.AddCheckPoint(AClass: TDebugClass);
begin
  AddCheckPoint(AClass,DefaultCheckName);
end;

procedure TLogger.AddCheckPoint(const CheckName: String);
begin
  AddCheckPoint(FDefaultClass,CheckName);
end;

procedure TLogger.AddCheckPoint(AClass: TDebugClass; const CheckName: String);
var
  i,j: Integer;
begin
  if not (AClass in ActiveClasses) then Exit;
  i:=FCheckList.IndexOf(CheckName);
  if i <> -1 then
  begin
    //Add a custom CheckList
    j:=PtrInt(FCheckList.Objects[i])+1;
    FCheckList.Objects[i]:=TObject(j);
  end
  else
  begin
    FCheckList.AddObject(CheckName,TObject(0));
    j:=0;
  end;
  SendString(ltCheckpoint,CheckName+' #'+IntToStr(j));
end;

procedure TLogger.ResetCheckPoint;
begin
  ResetCheckPoint(FDefaultClass,DefaultCheckName);
end;

procedure TLogger.ResetCheckPoint(AClass: TDebugClass);
begin
  ResetCheckPoint(AClass,DefaultCheckName);
end;

procedure TLogger.ResetCheckPoint(const CheckName: String);
begin
  ResetCheckPoint(FDefaultClass,CheckName);
end;

procedure TLogger.ResetCheckPoint(AClass: TDebugClass; const CheckName:String);
var
  i: Integer;
begin
  if not (AClass in ActiveClasses) then Exit;
  i:=FCheckList.IndexOf(CheckName);
  if i <> -1 then
    FCheckList.Objects[i]:=TObject(0);
end;

procedure TLogger.EnterMethod(const AMethodName: String);
begin
  EnterMethod(FDefaultClass,nil,AMethodName);
end;

procedure TLogger.EnterMethod(AClass: TDebugClass; const AMethodName: String);
begin
  EnterMethod(AClass,nil,AMethodName);
end;

procedure TLogger.EnterMethod(Sender: TObject; const AMethodName: String);
begin
  EnterMethod(FDefaultClass,Sender,AMethodName);
end;

procedure TLogger.EnterMethod(AClass: TDebugClass; Sender: TObject;
  const AMethodName: String);
begin
  if not (AClass in ActiveClasses) then Exit;
  FLogStack.Insert(0,UpperCase(AMethodName));
  if Sender <> nil then
  begin
    if Sender is TComponent then
      SendString(ltEnterMethod,TComponent(Sender).Name+'.'+AMethodName)
    else
      SendString(ltEnterMethod,Sender.ClassName+'.'+AMethodName);
  end
  else
    SendString(ltEnterMethod,AMethodName);
end;

procedure TLogger.ExitMethod(const AMethodName: String);
begin
  ExitMethod(FDefaultClass,nil,AMethodName);
end;

procedure TLogger.ExitMethod(Sender: TObject; const AMethodName: String);
begin
  ExitMethod(FDefaultClass,Sender,AMethodName);
end;

procedure TLogger.ExitMethod(AClass: TDebugClass; const AMethodName: String);
begin
  ExitMethod(AClass,nil,AMethodName);
end;

procedure TLogger.ExitMethod(AClass: TDebugClass; Sender: TObject;
  const AMethodName: String);
var
  i:Integer;
begin
  //ensure that ExitMethod will be called allways if there's a unpaired Entermethod
  //even if AClass is Active
  if FLogStack.Count = 0 then Exit;
  i:=FLogStack.IndexOf(UpperCase(AMethodName));
  if i <> -1 then
    FLogStack.Delete(i);
  if Sender <> nil then
  begin
    if Sender is TComponent then
      SendString(ltExitMethod,TComponent(Sender).Name+'.'+AMethodName)
    else
      SendString(ltExitMethod,Sender.ClassName+'.'+AMethodName);
  end
  else
    SendString(ltExitMethod,AMethodName);
end;

procedure TLogger.Watch(const AText, AValue: String);
begin
  Watch(FDefaultClass,AText,AValue);
end;

procedure TLogger.Watch(AClass: TDebugClass; const AText, AValue: String);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltWatch,AText+'='+AValue);
end;

procedure TLogger.Watch(const AText: String; AValue: Integer);
begin
  Watch(FDefaultClass,AText,AValue);
end;

procedure TLogger.Watch(AClass: TDebugClass; const AText: String;
  AValue: Integer);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltWatch,AText+'='+IntToStr(AValue));
end;

procedure TLogger.Watch(const AText: String; AValue: Double);
begin
  Watch(FDefaultClass,AText,AValue);
end;

procedure TLogger.Watch(AClass: TDebugClass; const AText: String; AValue: Double
  );
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltWatch,AText+'='+FloatToStr(AValue));
end;

procedure TLogger.Watch(const AText: String; AValue: Boolean);
begin
  Watch(FDefaultClass,AText,AValue);
end;

procedure TLogger.Watch(AClass: TDebugClass; const AText: String;
  AValue: Boolean);
begin
  if not (AClass in ActiveClasses) then Exit;
  SendString(ltWatch,AText+'='+BoolToStr(AValue));
end;

{ TChannelList }

function TChannelList.GetCount: Integer;
begin
  Result:=FList.Count;
end;

function TChannelList.GetItems(AIndex:Integer): TLogChannel;
begin
  Result:= TLogChannel(FList[AIndex]);
end;

constructor TChannelList.Create;
begin
  FList:=TFPList.Create;
end;

destructor TChannelList.Destroy;
var
  i:Integer;
begin
  //free the registered channels
  for i:=0 to FList.Count - 1 do
    Items[i].Destroy;
  FList.Destroy;
end;

function TChannelList.Add(AChannel: TLogChannel):Integer;
begin
  Result:=FList.Add(AChannel);
end;

procedure TChannelList.Remove(AChannel: TLogChannel);
begin
  FList.Remove(AChannel);
end;


end.

