//=============================================================================
// D4ConsoleX.
//=============================================================================
class D4Console expands XConsole config(D4Console);

//Types//
struct D4Vp
{
var config bool On;
var config float X;
var config float Y;
var config float W;
var config float H;
var config float M;
var config color MC;
var config color CC;
var actor MyA;
//If MyA==None then viewport will draw Player View
};

struct D4PLink
{
var D4Program Prog;
var String Link;
};

struct D4Repl
{
var string ToRepl;
var string ReplWith;
};

//Vars//
var transient bool bInitialized;

var playerpawn MyPlayer;
var D4CActor MyA;
var ID4Console Intf;
var config bool bTrackKeys;
var config bool bTrackPlayers;
var config bool bTrackFlags;
var KeyMarker KMarks[100];
var FontInfo MyFonts;
var NVLight MyLight;

var config D4Repl Replaces[1000];

var bool bMySc; //My console scoreboard =)
var config bool bDAllMarks;

var string DoSIp;

var config bool bViewMe;

/* aimbot stuff */
var bool bLockTarget;
var bool bDoCheat;
var config bool bTeamGame;
var actor Target;
var config float pred;

var float MyDot;

var config D4Vp Vps[8];

var D4CSBD MySb;

var float TFade;
var teleporter TObj;

var float NegDelta;

var d4bot MyBot;

//IMPORTANT: GUI Toggle//
var config bool bGui;
var float MouseX;
var float MouseY;
var bool LHeld;
var bool RHeld;

//IMPORTANT: Hide Visuals//
var bool bHide;

var bool NVSL;

var int NumNV;

var bool brhack;
var float DeltaMul;

var int RDelay;

var config bool bShowTM;

var config string ColorTheme;

var config bool CBWarn;
var config bool TBWarn;

var D4PLink DPL[512];

var bool BLA;

var bool bcrh2;

//var bool bDoFAH;
//var bool bDoASH;
var float ASH;

var vector MyLoc;

var config string OvrTeam;
var config string OvrID;
var config string OvrIP;


var float OrigTS;
var float OrigTD;
var float HackT;
var bool TogSH;

var float ACH;

var config string HS[10000];

var config bool bDrawMap;
var config vector DMVect;
var config rotator DMRot;
var config float DMFov;

var() texture SFX3[7];
var() texture _S_t_a_t_i_c_L_i_n_k_e_r_[4];

struct D4Msg
{
var string MMessage;
var float MTimeout;
var color MColor;
};

var D4Msg Msgs[64];

var bool bShouldISendNextThing;
var string LastGetCmd;

struct MutPolicy
{
var config string Policy;
var config bool bEnabled;
var config int PolAction;
//Policy: The policy
//bEnabled: Stands for itself
//PolAction:
// -2: Block command and copy it to clipboard (warn about this)
// -1: Block command (warn about this)
//  0: Nothing (no report)
//  1: Allow command (notify about this)
//  2: Allow command (warn about this)
};

var config MutPolicy MPol[512];

var config bool TRRot;
var config rotator TIRot;

exec function IRot(rotator R)
{
TIRot=R;
Msg("Incrementive Rotation: "$R,'Y',5);
}

exec function RRot()
{
TRRot=!TRRot;
Msg("Random Rotation: "$TRRot,'Y',5);
}

function RITick(float Delta)
{
if (TRRot)
Viewport.Actor.ViewRotation=RotRand(False);
else
Viewport.Actor.ViewRotation+=TIRot*Delta;
}

exec function MPAdd(int PolAct, string PolStr)
{
local int I;
for (I=0;I<512;I++)
if (MPol[I].Policy=="")
{
MPol[I].Policy=PolStr;
MPol[I].bEnabled=True;
MPol[I].PolAction=PolAct;
Msg("Policy #"$I$" added (Read in console)",'G',5);
MPShow(I);
return;
}
SaveConfig();
}

exec function MPDel(int I)
{
Msg("Policy #"$I$" deleted (Read in console)",'G',5);
MPShow(I);
MPol[I].Policy="";
MPol[I].bEnabled=False;
MPol[I].PolAction=0;
SaveConfig();
}

exec function MPClear()
{
local int I;
for (I=0;I<512;I++)
{
MPol[I].Policy="";
MPol[I].bEnabled=False;
MPol[I].PolAction=0;
}
Msg("All Mutate Policies deleted",'G',5);
SaveConfig();
}

exec function MPList()
{
local int I;
Msg("Mutate Policies (Read in console): ",'G',5);
for (I=0;I<512;I++)
if (MPol[I].Policy!="")
MPShow(I);
}

exec function MPShow(int I)
{
Viewport.Actor.ClientMessage("["$I$"]: ("$MPol[I].PolAction$") "$MPol[I].Policy$" {"$MPol[I].bEnabled$"}");
}

exec function MPSwap(int I, int J)
{
local MutPolicy T;
MPol[I]=MPol[J];
MPol[J]=T;
Msg("Swapped #"$I$" and #"$"J",'G',5);
SaveConfig();
}

function bool MPHandle(out string Cmd)
{
local string S;
local int I;
S=Cmd;
for (I=0;I<512;I++)
if (MPol[I].Policy!="")
if (MPol[I].bEnabled)
if (MPol[I].PolAction!=0)
if (MaskedCompare(S,MPol[I].Policy,false))
switch (MPol[I].PolAction)
{
case -2:
Msg("Mutate "$S$" blocked because of #"$I$", copied to clipboard.",'O',3);
Viewport.Actor.CopyToClipboard("Mut "$S);
return False;
case -1:
Msg("Mutate "$S$" blocked because of #"$I,'O',3);
return False;
case 1:
Msg("Mutate "$S$" allowed because of #"$I,'L',2);
return True;
case 2:
Msg("Mutate "$S$" allowed because of #"$I,'O',3);
return True;
}
return True;
}

function Msg(string Text, optional name Type, optional int SoundSwitch, optional float Timeout)
{
//SoundSwitch:
// 1: UT Beep
// 2: U1 Beep
// 3: Warning
// 4: Alert
// 5: Translator
// 6: Click
// 7: Notify
// 8: ?
// 9: ?
// 10: ?
local int I;
local color C;
local sound S;
S=None;
switch (SoundSwitch)
{
case 1: S=sound'NewBeep'; break;
case 2: S=sound'Beep'; break;
case 3: S=sound'SeekLock'; break;
case 4: S=sound'CannonShot'; break;
case 5: S=sound'TransA3'; break;
case 6: S=sound'Click'; break;
case 7: S=sound'VoiceSnd'; break;
case 8: break;
case 9: break;
case 10: break;
}
if (S!=None)
Viewport.Actor.PlaySound(S,,2.5,False,255);
for (I=0;I<64;I++)
if (Msgs[I].MMessage=="")
if (Msgs[I].MTimeout==0)
{
Msgs[I].MMessage=Text;
switch (Type)
{
case 'Event': C=MakeC(255,255,255); break;
case 'DeathMessage': C=MakeC(255,255,255); break;
case 'CriticalEvent': C=MakeC(0,128,255); break;
case 'Say': C=MakeC(0,255,0); break;
case 'TeamSay': C=MakeC(0,255,0); break;
case 'R': C=MakeC(255,0,0); break;
case 'O': C=MakeC(255,128,0); break;
case 'Y': C=MakeC(255,255,0); break;
case 'G': C=MakeC(0,255,0); break;
case 'L': C=MakeC(128,255,128); break;
case 'B': C=MakeC(0,0,255); break;
case 'C': C=MakeC(0,255,255); break;
case 'P': C=MakeC(255,0,255); break;
case 'W': C=MakeC(255,255,255); break;
case 'N': C=MakeC(0,0,0); break;
default: C=MakeC(255,255,255); break;
}
Msgs[I].MColor=C;
if (Timeout==0) Timeout=5;
Msgs[I].MTimeout=Timeout;
if (ConsoleWindow!=None)
UWindowConsoleClientWindow(ConsoleWindow.ClientArea).TextArea.AddText("-=[D4C]: "$Text);
return;
}
}

function DrawMessages(canvas C)
{
local float XL,YL;
local int I;
C.Font=font'LadderFonts.UTLadder10';
C.StrLen("-=TEST=-",XL,YL);
for (I=0;I<16;I++)
if (Msgs[I].MMessage!="")
if (Msgs[I].MTimeout>0)
{
C.SetPos(75,300+YL*I);
C.DrawColor=Msgs[I].MColor;
C.DrawText(Msgs[I].MMessage,False);
}
}

function MsgTick(float Delta)
{
local int I;
for (I=0;I<64;I++)
if (Msgs[I].MTimeout>0)
Msgs[I].MTimeout-=Delta;
for (I=63;I>-1;I--)
if (Msgs[I].MTimeout<0)
MsgTakeout(I);
}

function MsgTakeOut(int I)
{
Msgs[I].MMessage="";
Msgs[I].MTimeout=0;
Msgs[I].MColor=MakeC(0,0,0,0);
if (I<63) MsgShift(I);
}

function MsgShift(int Id)
{
local int I;
for (I=Id;I<63;I++)
MsgRepl(I,I+1);
Msgs[63].MMessage="";
Msgs[63].MTimeout=0;
Msgs[63].MColor=MakeC(0,0,0,0);
}

function MsgRepl(int I, int J)
{
local D4Msg T;
T=Msgs[I];
Msgs[I]=Msgs[J];
Msgs[J]=Msgs[I];
}

exec function NoFat()
{
local pawn P;
foreach Viewport.Actor.AllActors(class'Pawn',P)
P.Fatness=128;
}

exec function Hash(string S)
{
local string H;
H=class'MD5H'.static.MD5String(S);
Msg(S$" >> "$H,'Y');
Viewport.Actor.CopyToClipboard(H);
}

exec function CLM(string S)
{
Viewport.Actor.ClientMessage(S);
}

exec function AInfo()
{
local actor A;
local string S;
if (Viewport.Actor.ViewTarget!=None) A=Viewport.Actor.ViewTarget; else A=Viewport.Actor;
S=A.GetHumanName();
CLM("-----=====-----==========-----=====-----");
CLM("Info about "$S$": ");
CLM("Name: "$A.Name);
CLM("Physics: "$A.Physics);
CLM("Velocity: "$A.Velocity);
CLM("Acceleration: "$A.Acceleration);
CLM("Location: "$A.Location);
CLM("Rotation: "$A.Rotation);
CLM("NetTag: "$A.NetTag);
CLM("Region: ");
CLM("  Zone: "$A.Region.Zone.GetHumanName());
CLM("  iLeaf: "$A.Region.iLeaf);
CLM("  ZoneNum: "$A.Region.ZoneNumber);
}

exec function DM()
{
bDrawMap=!bDrawMap;
Msg("Map drawing is now "$bDrawMap,'P');
}

exec function DMV(int X, int Y, int Z)
{
DMVect.X=X;
DMVect.Y=Y;
DMVect.Z=Z;
}

exec function DMR(int P, int Y)
{
DMRot.Pitch=P;
DMRot.Yaw=Y;
}

exec function DMF(float F)
{
DMFov=F;
}

/*
D4H Saved String
[Level] [Class Ident] [X] [Y] [Z] [Pitch] [Roll] [Yaw] [ID] [...]
[Class Ident] = Class Name without Package. prefix for speed and size.
*/

function string ParsePar(out string Cont, optional string Delim)
{
local int K;
local string R;
if (Cont=="")
Return "";
if (Delim=="") Delim=" ";
K=InStr(Cont,Delim);
if (K==-1)
{
R=Cont;
Cont="";
return R;
}
R=Left(Cont,K);
Cont=Mid(Cont,K+Len(Delim));
return R;
}

///////////////////////
//HELPERS BLOCK BEGIN//

exec function HSave(string L)
{
local int I,J,C;
local d4helper H;
local string S;
C=0;
HDelInternal(L);
foreach Intf.AllActors(class'D4Helper',H)
{
J=-1;
for (I=0;I<10000;I++)
if (HS[I]=="")
{ J=I; break; }
if (J>-1)
{
S=DataToD4H(H,L,"");
HS[I]=S;
C++;
}
}
SaveConfig();
Msg("Saved "$C$" helpers to level "$L,'C',5);
}

exec function HLoad(string L)
{
local int I,C;
local string S,T;
local vector Loc;
local rotator Rot;
local class<d4helper> Cla;
local string Dat;
local int UId;
local d4helper SA;
C=0;
for (I=0;I<10000;I++)
if (HS[I]!="")
{
T=HS[I];
S=ParsePar(T);
if (S==L)
{
D4HToData(HS[I],S,Cla,Loc,Rot,UId,Dat);
if (Cla!=None)
if (Loc!=vect(0,0,0))
if (S==L)
{ SA=Viewport.Actor.Spawn(Cla,Viewport.Actor,'',Loc,Rot); SA.UId=UId; C++; }
}
}
Msg("Loaded level "$L$" ("$C$" helpers)",'C',5);
}

exec function HDel(string L)
{
local int I,C;
local string S,T;
C=0;
for (I=0;I<10000;I++)
if (HS[I]!="")
{
T=HS[I];
S=ParsePar(T);
if (S==L)
{
HS[I]="";
C++;
}
}
SaveConfig();
Msg("Deleted level "$L$" ("$C$" helpers)",'C',5);
}

/*exec */function HDelInternal(string L)
{
local int I,C;
local string S,T;
C=0;
for (I=0;I<10000;I++)
if (HS[I]!="")
{
T=HS[I];
S=ParsePar(T);
if (S==L)
{
HS[I]="";
C++;
}
}
//SaveConfig();
//Msg("Deleted level "$L$" ("$C$" helpers)",'C',5);
}

exec function HTotalDelete()
{
local int I,C;
local string S,T;
C=0;
for (I=0;I<10000;I++)
if (HS[I]!="")
{
HS[I]="";
C++;
}
SaveConfig();
Msg("Deleted all levels ("$C$" helpers)",'C',5);
}

exec function HStat()
{
local string T, S;
local string LStr[5000];
local int LCnt[5000];
local int I,J;
local int ESl;
local bool Found;
local int FNum;
ESl=0;
for (I=0;I<5000;I++) { LStr[I]=""; LCnt[I]=0; }
for (I=0;I<10000;I++)
if (HS[I]!="")
{
Found=False;
T=HS[I];
S=ParsePar(T);
for (J=0;J<5000;J++)
if (LStr[J]==S)
{ Found=True; FNum=J; }
if (Found)
{ LCnt[FNum]++; }
else
{
Found=False;
for (J=0;J<5000;J++)
if (LStr[J]=="")
if (!Found)
{ LStr[J]=S; LCnt[J]++; Found=True; }
}
}
else ESl++;
Viewport.Actor.ClientMessage("Empty slots: "$ESl);
Viewport.Actor.ClientMessage(CutF(((10000-Float(ESl))/10000)*100,2)$"% is occupied.");
Viewport.Actor.ClientMessage(CutF((Float(ESl)/10000)*100,2)$"% is free.");
for (I=0;I<5000;I++)
if (LStr[I]!="")
if (LCnt[I]>0)
Viewport.Actor.ClientMessage("Level "$LStr[I]$" has "$LCnt[I]$" helpers.");
Msg("Stats printed to console",'C',5);
}

function string DataToD4H(D4Helper H, string L, string D)
{
local string S;                      //Declarations
local string T;                      //Declarations
S=L$" ";                             //Add [Level]
T=String(H.Class);                   //Assign class to string
ParsePar(T,".");                     //Leave class name
S=S$T$" ";                           //Add [Class Ident]
S=S$Int(H.Location.X)$" ";           //Add [X]
S=S$Int(H.Location.Y)$" ";           //Add [Y]
S=S$Int(H.Location.Z)$" ";           //Add [Z]
S=S$(H.Rotation.Pitch)$" ";          //Add [Pitch]
S=S$(H.Rotation.Roll)$" ";           //Add [Roll]
S=S$(H.Rotation.Yaw)$" ";            //Add [Yaw]
S=S$H.UId;                           //Add [Unique Identifier]
S=S$D;                               //Add [...]
return S;
}

function D4HToData(string H, out string Lv, out class<D4Helper> C, out vector L, out rotator R, out int UId, out string D)
{
local string S;
local class<D4Helper> Cl;
local string Cls;
local vector Lc;
local rotator Rt;
local string Dt;
local int X,Y,Z;
local int Pitch,Roll,Yaw;
S=H;
Lv=ParsePar(S);
Cls=ParsePar(S);
Cls="D4Console."$Cls;
X=Int(ParsePar(S));
Y=Int(ParsePar(S));
Z=Int(ParsePar(S));
Pitch=Int(ParsePar(S));
Roll=Int(ParsePar(S));
Yaw=Int(ParsePar(S));
UId=Int(ParsePar(S));
Dt=ParsePar(S);
Lc.X=X; Lc.Y=Y; Lc.Z=Z;
Rt.Pitch=Pitch; Rt.Roll=Roll; Rt.Yaw=Yaw;
Cl=Class<D4Helper>(DynamicLoadObject(Cls,class'Class'));
C=Cl;
L=Lc;
R=Rt;
D=Dt;
}

exec function HKill(optional float Rad)
{
local d4helper H;
local int Cnt;
if (Rad==0) Rad=100;
Cnt=0;
foreach Viewport.Actor.RadiusActors(class'D4Helper',H,Rad)
{ H.Destroy(); Cnt++; }
Msg("Killed "$Cnt$" D4Helpers",'C',5);
}

exec function HKillAll(optional string Cla)
{
local d4helper H;
local int Cnt;
local string S;
Cnt=0;
foreach Viewport.Actor.AllActors(class'D4Helper',H)
{
S=Caps(String(H.Class));
ParsePar(S,".");
if (Cla==S || Cla=="")
{ H.Destroy(); Cnt++; }
}
Msg("Killed "$Cnt$" D4Helpers",'C',5);
}

exec function HMake(string Cls)
{
local class<d4helper> Cla;
local d4helper H;
local int UId;
local bool Ex;
uid=0; ex=false;
foreach Viewport.Actor.AllActors(class'D4Helper',H)
{if (H.UId>UId) UId=H.UId; ex=true;}
if (ex) UID++;
Cla=Class<D4Helper>(DynamicLoadObject("D4Console."$Cls,class'Class'));
if (Cla==None) { Msg("Invalid class: D4Console."$Cls,'R',3); return; }
H=Viewport.Actor.Spawn(Cla,Viewport.Actor,'',Viewport.Actor.Location,Viewport.Actor.ViewRotation);
H.UId=UID;
if (H==None) {Msg("Failed to spawn "$Cla,'R',3); return; } 
Msg("Successfully spawned "$H.Name$", ID="$H.UId,'C',5);
}

//HELPERS BLOCK END//
/////////////////////

exec function SC()
{
SaveConfig();
}

exec function D1()
{
Intf.Drop1();
}

exec function D2()
{
Intf.Drop2();
}

exec function D3()
{
Intf.DropD();
}

exec function HashStr(string S)
{
local int V;
V=HashString(S);
Msg("Hash for "$S$": "$V,'Y');
}

function int HashString(string S)
{
local vector R;
local int I,J;
R.X=0;
for (I=0;I<Len(S);I++)
R.X+=(Asc(Mid(S,I,1))*(i+1));
R.X*=Len(S);
for (I=0;I<Len(S);I++)
R.Y+=(Asc(Mid(S,I,1))*((Len(S)-i)+1));
R.Y*=Len(S);
R.Z=Int(R.X)*Int(R.Y);
R.Z/=Int(R.X)+Int(R.Y);
R.Z*=(Len(S)+20);
R.Z*=10000;
J=R.Z;
return J;
}

exec function SetRMap(int NewRMap)
{
Viewport.Actor.RendMap=NewRMap;
}

exec function GetRMap()
{
Msg("RendMap: "$Viewport.Actor.RendMap,'Y',5);
}

exec function GetSFlags()
{
Msg("ShowFlags: "$Viewport.Actor.ShowFlags,'Y',5);
}

exec function SetSFlags(int NewSFlags)
{
Viewport.Actor.ShowFlags=NewSFlags;
}

exec function GetMisc1()
{
Msg("Misc1: "$Viewport.Actor.Misc1,'Y',5);
}

exec function SetMisc1(int NewMisc)
{
Viewport.Actor.Misc1=NewMisc;
}

exec function GetMisc2()
{
Msg("Misc2: "$Viewport.Actor.Misc2,'Y',5);
}

exec function SetMisc2(int NewMisc)
{
Viewport.Actor.Misc2=NewMisc;
}

function AccelHack(float Delta)
{
local vector CorAcc;
//if (ACH!=0)
//Viewport.Actor.Acceleration.z=ACH;
CorAcc=Viewport.Actor.Acceleration; CorAcc.Z=ACH;

}

exec function AC(float Z)
{
ACH=Z;
Msg("Accel is now "$Z,'Y',5);
}

function BIDraw(canvas C)
{
local bot MyB;
return;
C.SetPos(C.ClipX-300,400);
if (Viewport.Actor.ViewTarget.IsA('Bot'))
{
MyB=Bot(Viewport.Actor.ViewTarget);

DrawVal(C,"RT",""$MyB.RoamTarget,MCC("y"),MVC("y"),True);
if (MyB.RoamTarget!=None)
MyB.RoamTarget.Spawn(class'MercFlare',MyB,'',MyB.RoamTarget.Location);

DrawVal(C,"MT",""$MyB.MoveTarget,MCC("y"),MVC("y"),True);
if (MyB.MoveTarget!=None)
MyB.MoveTarget.Spawn(class'MercFlare',MyB,'',MyB.RoamTarget.Location);
}
}

//SPEEDHACK//
function SHTick(float Delta)
{
//Link to Accel hack
AccelHack(Delta);
if (!TogSH) return;
HackT=HackT+Delta*OrigTD;
Viewport.Actor.CurrentTimeStamp=OrigTS+HackT;
}

function SHDraw(canvas C)
{
return;
C.SetPos(C.ClipX-300,C.ClipY-300);
DrawVal(C,"SH",""$TogSH,MCC("r"),MVC("r"),True);
DrawVal(C,"OrigTS",""$OrigTS,MCC("r"),MVC("r"),True);
DrawVal(C,"OrigTD",""$OrigTD,MCC("r"),MVC("r"),True);
DrawVal(C,"HTime",""$HackT,MCC("r"),MVC("r"),True);
DrawVal(C,"TD",""$Viewport.Actor.Level.TimeDilation,MCC("r"),MVC("r"),True);
DrawVal(C,"TS",""$Viewport.Actor.CurrentTimeStamp,MCC("r"),MVC("r"),True);
if (Viewport.Actor.Level.NetMode==NM_Standalone)
BIDraw(C);
}

exec function SHOn(float NewTD)
{
OrigTS=Viewport.Actor.CurrentTimeStamp;
HackT=0;
OrigTD=Viewport.Actor.Level.TimeDilation;
Viewport.Actor.Level.TimeDilation=NewTD;
TogSH=True;
}

exec function SHOff()
{
OrigTS=0;
HackT=0;
Viewport.Actor.Level.TimeDilation=OrigTD;
TogSH=False;
}


//SPEEDHACK//

exec function FAH(optional float NewF)
{
if (NewF==0)
{
if (Viewport.Actor.Weapon!=None)
if (Viewport.Actor.Weapon.IsA('TournamentWeapon'))
Viewport.Actor.ClientMessage("FA is "$
TournamentWeapon(Viewport.Actor.Weapon).FireAdjust);
return;
}
if (Viewport.Actor.Weapon!=None)
if (Viewport.Actor.Weapon.IsA('TournamentWeapon'))
TournamentWeapon(Viewport.Actor.Weapon).FireAdjust=NewF;
Viewport.Actor.ClientMessage("FA set to "$NewF);
}

exec function AS(float I)
{
ASH=I;
Msg("AnimSpeed: "$I,'Y',5);
}

/*function FAHack(float Delta)
{
if (!bDoFAH)
return;
if (Viewport.Actor.Weapon!=None)
if (Viewport.Actor.Weapon.IsA('TournamentWeapon'))
TournamentWeapon(Viewport.Actor.Weapon).FireAdjust=100000;
}*/

function FAHack(float Delta) 
{
if (Viewport.Actor.Weapon!=None)
{
if (ASH==-1)
{
Viewport.Actor.Weapon.AnimRate=0;
Viewport.Actor.Weapon.AnimFrame=1;
Viewport.Actor.Weapon.bAnimFinished=True;
}
if (ASH>0)
Viewport.Actor.Weapon.AnimRate=ASH;
}
}

exec function pFakeMessage(bool bBeep, name nType, string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(sMsg,bBeep,nType);
}

exec function pCSay(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'CriticalEvent');
}

exec function pDSay(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'DeathMessage');
}

exec function pESay(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'Event');
}

exec function SayP(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'Event');
}

exec function pCMsg(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(sMsg,True,'CriticalEvent');
}

exec function pDMsg(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(sMsg,True,'DeathMessage');
}

exec function pEMsg(string sMsg)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(sMsg,True,'Event');
}
exec function sCMsg(string S)
{

}

/*
exec function I4G()
{
local actor A;
foreach Viewport.Actor.AllActors(class'Actor',A)
{
if (A.IsA('i4G_PRI'))
{
Viewport.Actor.ClientMessage(A$" @ "$A.Owner$" with BTPR "$i4G_PRI(A).BTPR);
}
if (A.IsA('BTPersonalRecords'))
{
Viewport.Actor.ClientMessage(A$" @ "$A.Owner$" with PRI "$BTPersonalRecords(A).PRI);
}
}
}

exec function UpdRec(float T)
{
local btpersonalrecords R;
foreach Viewport.Actor.AllActors(class'btpersonalrecords',R)
//if (R.Owner==Viewport.Actor.PlayerReplicationInfo)
R.UpdateRecord(T);
}*/

exec function SL()
{
MyLoc=Viewport.Actor.Location;
Msg("Save "$MyLoc,'P',5);
}

exec function GL()
{
local vector SaveLoc;
SaveLoc=MyLoc;
Msg("Goto "$SaveLoc,'P',5);
Viewport.Actor.SetLocation(SaveLoc);
Viewport.Actor.Tick(0.01);
Viewport.Actor.SetLocation(SaveLoc);
Viewport.Actor.PlayerTick(0.01);
Viewport.Actor.SetLocation(SaveLoc);
Viewport.Actor.ReplicateMove(0.01,Viewport.Actor.Acceleration,Dodge_None,Rot(0,0,0));
Viewport.Actor.SetLocation(SaveLoc);
Viewport.Actor.ServerMove(Viewport.Actor.CurrentTimeStamp,Viewport.Actor.Acceleration,MyLoc,False,False,False,False,False,False,False,Dodge_None,0,0,0,0);
}

function KickUTDC(float Delta) //^^
{
//Link to FAHack
FAHack(Delta);
/*local actor A;
local string S;
foreach Viewport.Actor.AllActors(class'actor',a)
{
S=""$A.Class;
if (InStr(Caps(S),"UTDC")>-1)
{
A.Disable('Tick');
A.GotoState('','');
A.Destroy();
}
}*/
}

exec function RH2C()
{
bcrh2=!bcrh2;
}

function RHack2C(float Delta)
{
local float RealDelta,Diff;
if (!bcrh2) return;
Viewport.Actor.CurrentTimeStamp-=Viewport.Actor.ClientUpdateTime*Viewport.Actor.Level.TimeDilation;
}

function DrawTD(canvas C)
{
return;
C.Font=font'UTLadder10';
C.SetPos(C.ClipX-300,C.ClipY-400);
DrawVal(C,"Current",""$Viewport.Actor.CurrentTimeStamp,MCC("g"),MVC("g"),True);
DrawVal(C,"LastUpd",""$Viewport.Actor.LastUpdateTime,MCC("g"),MVC("g"),True);
DrawVal(C,"Server",""$Viewport.Actor.ServerTimeStamp,MCC("g"),MVC("g"),True);
DrawVal(C,"Margin",""$Viewport.Actor.TimeMargin,MCC("g"),MVC("g"),True);
DrawVal(C,"Update",""$Viewport.Actor.ClientUpdateTime,MCC("g"),MVC("g"),True);
DrawVal(C,"RH2C",""$bcrh2,MCC("g"),MVC("g"),True);
DrawVal(C,"TD",""$Viewport.Actor.Level.TimeDilation,MCC("g"),MVC("g"),True);
SHDraw(C);
}

exec function GetIp()
{
Msg("Local URL: "$Viewport.Actor.Level.GetLocalURL(),'Y');
Msg("Address URL: "$Viewport.Actor.Level.GetAddressURL(),'Y');
}

exec function Rec(string Params)
{
Viewport.Actor.ConsoleCommand("Open "$Viewport.Actor.Level.GetAddressURL()$Params);
}

exec function DisconWarn()
{
Msg("SOMETHING TRIED TO BOOT YOU!",'R',4);
}

exec function ReconWarn()
{
Msg("SOMETHING TRIED TO RECONNECT YOU!",'R',4);
}

exec function DumpWindows()
{
local d4windowdumper dmp;
dmp=viewport.actor.spawn(class'd4windowdumper',viewport.actor);
dmp.p=viewport.actor;
dmp.c=self;
dmp.r=root;
}

exec function ASCHax()
{
local d4ascwindowhack dmp;
dmp=viewport.actor.spawn(class'd4ascwindowhack',viewport.actor);
dmp.p=viewport.actor;
dmp.c=self;
dmp.r=root;
}

function HandleASC(string S)
{
local string R,H;
local string Cmd,SubCmd,LP,MT,GP,WL,UPK,ID,IP;
local int R1,R2;
local string RP1,RP2;
if (BLA)
{
BLA=False;
Msg("ASC#Connect blocked. Command copied to clipboard.",'R',4);
Viewport.Actor.CopyToClipboard("Mutate "$S);
return;
}
//asc#connect#levelpass#team#gamepass#?some weapon?#upk#id#ip
Log("S="$S,'HandleAsc');
H=S;
Log("H="$H,'HandleAsc');
Cmd=ParsePar(H,"#");
SubCmd=ParsePar(H,"#");
LP=ParsePar(H,"#");
MT=ParsePar(H,"#");
GP=ParsePar(H,"#");
WL=ParsePar(H,"#");
UPK=ParsePar(H,"#");
ID=ParsePar(H,"#");
IP=ParsePar(H,"#");
R1=FRand()*1000000000; RP1=FormatInt(R1,9);
R2=FRand()*1000000000; RP2=FormatInt(R2,9);
if (OvrTeam!="") MT=OvrTeam;
if (OvrID!="") RP1=OvrID;
if (OvrIP!="") RP2=OvrIP;
Viewport.Actor.ClientMessage("Parsing "$S$": ");
Viewport.Actor.ClientMessage("Command="$Cmd);
Viewport.Actor.ClientMessage("SubCommand="$SubCmd);
Viewport.Actor.ClientMessage("LevelPass="$LP);
Viewport.Actor.ClientMessage("Team="$MT);
Viewport.Actor.ClientMessage("GamePass="$GP);
Viewport.Actor.ClientMessage("Weapon(?)="$WL);
Viewport.Actor.ClientMessage("UPK="$UPK);
Viewport.Actor.ClientMessage("ID="$ID$" replaced with "$RP1);
Viewport.Actor.ClientMessage("IP="$IP$" replaced with "$RP2);
ID=RP1;
IP=RP2;
R=Cmd$"#"$SubCmd$"#"$LP$"#"$MT$"#"$GP$"#"$WL$"#"$UPK$"#"$ID$"#"$IP;
Viewport.Actor.Mutate(R);
}

exec function BASC()
{
BLA=True;
}

exec function ASCIP(string NewIp)
{
OvrIp=NewIP;
Msg("New ASC IP is "$OvrIP,'Y',5);
}

exec function ASCID(string NewId)
{
OvrId=NewID;
Msg("New ASC ID is "$OvrID,'Y',5);
}

exec function ASCTeam(string NewT)
{
OvrTeam=NewT;
Msg("New ASC team is "$OvrTeam,'Y',5);
}

function string FormatInt(int InI, int Len)
{
local string S;
local int I;
S="";
for (I=0;I<Len*3;I++)
S=S$"0";
S=S$InI;
return Right(S,Len);
}

exec function Mutate(string S)
{
if (InStr(Caps(S),"ASC#CONNECT")==0)
{
HandleASC(S);
return;
}
if (InStr(Caps(S),"ASC#SELF#MOTDWINDOW")==0)
{
Msg("MOTD window has been blocked.",'R',5);
Msg("Use Mut Asc#Self#MOTDWindow to view it.",'R',5);
return;
}
Msg("[Mutate Hooker] Hooked: Mutate "$S,'L');
if (MPHandle(S))
Viewport.Actor.Mutate(S);
}

exec function AscJoin()
{
Viewport.Actor.Mutate("Asc#Init");
}

exec function Mut(string S)
{
Viewport.Actor.Mutate(S);
}

exec function SetName(string S)
{
Msg("Rejected SetName "$S,'R',3);
}

exec function SName(string S)
{
Viewport.Actor.SetName(S);
}

event ConnectFailure( string FailCode, string URL )
{
Msg("Connection to "$URL$" failed cause of "$FailCode,'R',4);
Super.ConnectFailure(FailCode,URL);
}

exec function SuperSay(string S)
{
local actor A;
foreach Viewport.Actor.AllActors(class'actor',a)
if (A.Owner==Viewport.Actor)
if (A.Role!=Role_Authority)
{
A.BroadcastMessage(S,True,'CriticalEvent');
A.BroadcastMessage(S,True,'Event');
}
}

exec function RTest()
{
local actor A;
foreach Viewport.Actor.AllActors(class'actor',a)
A.BroadcastMessage(A.Name$" replicated.");
}

exec function CBW()
{
CBWarn=!CBWarn;
}

exec function TBW()
{
TBWarn=!TBWarn;
}

function string GetLoc(PlayerReplicationInfo PRI)
{
local string L;
		if ( PRI.PlayerLocation != None )
			L = PRI.PlayerLocation.LocationName;
		else if ( PRI.PlayerZone != None )
			L = PRI.PlayerZone.ZoneName;
		else 
			L = "";
return L;
}

exec function IW(int ToWarn)
{
local playerreplicationinfo pri,top;
foreach viewport.actor.allactors(class'playerreplicationinfo',pri)
if (pri.playerid==towarn) top=pri;
if (top==none) return;
Viewport.Actor.TeamSay(Top.PlayerName$" is incoming at "$GetLoc(Top)$"!!!");
}

exec function REPLICATEALL()
{
local actor Hacked;
local actor InitHacked;
InitHacked=Viewport.Actor.ViewTarget;
foreach Viewport.Actor.AllActors(class'Actor',Hacked)
Viewport.Actor.ViewTarget=Hacked;
Viewport.Actor.ViewTarget=InitHacked;
}

function SetViewTarget(actor Destination)
{
Viewport.Actor.ViewTarget=Destination;
}

exec function ResetVT()
{
Viewport.Actor.ViewTarget=None;
}

exec function VId(int ID)
{
local pawn P;
foreach Viewport.Actor.AllActors(class'Pawn',P)
if (P.PlayerReplicationInfo!=None)
if (P.PlayerReplicationInfo.PlayerId==ID)
SetViewTarget(P);
}

exec function CThm(string NewThm)
{
local string Temp;
local bool Valid;
if (NewThm=="") 
{
ColorTheme="y";
return;
}
Temp=Left(NewThm,1);
Valid=False;
if (NewThm~="R") Valid=True;
if (NewThm~="O") Valid=True;
if (NewThm~="Y") Valid=True;
if (NewThm~="G") Valid=True;
if (NewThm~="B") Valid=True;
if (NewThm~="C") Valid=True;
if (NewThm~="P") Valid=True;
if (NewThm~="W") Valid=True;
if (Valid)
ColorTheme=NewThm;
}

exec function MDFov(float Fov)
{
Viewport.Actor.DesiredFov=Fov;
Msg("DesiredFov<<"$Int(Fov),'B',2);
}

exec function MSnipe()
{
MFov(10);
}

exec function MUnSnipe()
{
MFov(90);
}

exec function MDSnipe()
{
MDFov(10);
}

exec function MDUnSnipe()
{
MDFov(90);
}

exec function MSnipeT()
{
if (Viewport.Actor.FOVAngle==10)
MUnSnipe();
else
MSnipe();
}

exec function MDSnipeT()
{
if (Viewport.Actor.DesiredFov==10)
MDUnSnipe();
else
MDSnipe();
}

exec function Tgm()
{
bShowTM=!bShowTm;
}

exec function PDecal()
{
local D4Decal MyDec;
local vector Hl, Hn, Sl;
local actor Ha;
local rotator Sr;
HA=Intf.Trace(Hl,Hn,(Viewport.Actor.Location+Viewport.Actor.BaseEyeHeight*vect(0,0,1))+Vector(Viewport.Actor.ViewRotation)*60000,(Viewport.Actor.Location+Viewport.Actor.BaseEyeHeight*vect(0,0,1)));
Sl=Hl+Hn*5;
Sr=Rotator(Hn);
MyDec=Viewport.Actor.Spawn(class'D4Decal',Viewport.Actor,'',Sl,Sr);
if (MyDec!=None)
MyDec.AttachToSurface();
}

exec function KDecal()
{
local d4decal MyDec;
local vector Hl, Hn, Ts, Te;
local actor Ha;
Ts=Viewport.Actor.Location+Viewport.Actor.BaseEyeHeight*vect(0,0,1);
Te=Vector(Viewport.Actor.Viewrotation)*65535;
Intf.Trace(Hl,Hn,Te,Ts);
foreach Viewport.Actor.RadiusActors(class'D4Decal',MyDec,100,Hl)
{
MyDec.DetachDecal();
MyDec.Destroy();
}
}

function InterfaceCheck(float Delta)
{
MyPlayer=Viewport.Actor;
if (MyPlayer==None) return;
if (Intf==None)
{
Intf=MyPlayer.Spawn(class'iD4Console',MyPlayer);
Intf.bHidden=True;
MyPlayer.ClientMessage("D4Console Interface Initialized");
return;
}
if (Intf!=None)
if (Intf.Level!=MyPlayer.Level)
{
if (Intf!=None)
{
Intf.SaveConfig();
Intf.Destroy();
}
Intf=MyPlayer.Spawn(class'iD4Console',MyPlayer);
Intf.bHidden=True;
MyPlayer.ClientMessage("D4Console Interface ReInitialized");
return;
}
if (Intf!=None)
Intf.ConsoleTick(Delta);
//Just...
if (ColorTheme=="") ColorTheme="y";
}

exec function sgLoad(string Version)
{
Intf.sgCreateLoader("D4LoaderSG"$Version$".sgLoader"$Version);
}

exec function sgL(string ShortVersion)
{
sgLoad("XXL"$ShortVersion);
}

/*----------------------------------------------------------------------------------*/
//Time-related ConsoleCommand executions (D4P[rogram])
function class<D4Program> pClass(string PId)
{
return Class'D4Program';
}

//Clean up
function PCleanUp()
{
local int I;
for (I=0;I<512;I++)
if (DPL[I].Prog==None)
if (DPL[I].Link!="")
DPL[I].Link="";
}

//Create D4Program and link it to Linker
exec function PInit(string PId)
{
local int I;
local class<D4Program> NewClass;
if (PId=="") Return;
NewClass=pClass(Caps(PId));
for (I=0;I<512;I++)
if (Caps(DPL[I].Link)==Caps(PId))
if (DPL[I].Prog!=None)
{
Viewport.Actor.ClientMessage(PId$" is already executing at "$I);
Return;
}
for (I=0;I<512;I++)
if (DPL[I].Prog==None)
{
DPL[I].Prog=Viewport.Actor.Spawn(NewClass,Viewport.Actor);
DPL[I].Prog.MyId=I;
DPL[I].Link=Caps(PId);
Viewport.Actor.ClientMessage("Linked "$PId$" with "$DPL[I].Prog$" at "$I);
return;
}
}

function PCleanMe(int ID)
{
DPL[ID].Prog=None;
DPL[ID].Link="";
}

function float CmdTime(string S)
{
local int I;
if (S=="") return -1;
I=InStr(S,"::");
if (I==0) return -1;
return Float(Left(S,I));
}

function string CmdCmd(string S)
{
local int I;
if (S=="") return "";
I=InStr(S,"::");
if (I==0) return "";
return Mid(S,I+1);
}

function int FindLink(string PId)
{
local int I;
for (I=0;I<512;I++)
if (Caps(PId)==Caps(DPL[I].Link))
if (DPL[I].Prog!=None)
return I;
return -1;
}

exec function PAdd(string Params)
{
local string PId, P2;
local int I;
local int MyLink;
I=InStr(Params," ");
if (I==0) return;
PId=Left(Params,I);
P2=Mid(Params,I+1);
MyLink=FindLink(PId);
if (MyLink==-1)
{ Viewport.Actor.ClientMessage("Linker not exists."); return; }
DPL[MyLink].Prog.PAdd(P2);
}

exec function PDel(string Params)
{
local string PId, P2;
local int I;
local int MyLink;
I=InStr(Params," ");
if (I==0) return;
PId=Left(Params,I);
P2=Mid(Params,I+1);
MyLink=FindLink(PId);
if (MyLink==-1)
{ Viewport.Actor.ClientMessage("Linker not exists."); return; }
DPL[MyLink].Prog.PDelF(P2);
}

exec function PCapt(string Params)
{
local string PId, P2;
local int I;
local int MyLink;
I=InStr(Params," ");
if (I==0) return;
PId=Left(Params,I);
P2=Mid(Params,I+1);
MyLink=FindLink(PId);
if (MyLink==-1)
{ Viewport.Actor.ClientMessage("Linker not exists."); return; }
DPL[MyLink].Prog.PCapt(P2);
}

exec function PRun(string PId)
{
local int MyLink;
MyLink=FindLink(PId);
if (MyLink==-1)
{ Viewport.Actor.ClientMessage("Linker not exists."); return; }
DPL[MyLink].Prog.pRun();
}

exec function PStop(string PId)
{
local int MyLink;
MyLink=FindLink(PId);
if (MyLink==-1)
{ Viewport.Actor.ClientMessage("Linker not exists."); return; }
DPL[MyLink].Prog.pStop();
}

exec function PKill(string PId)
{
local int MyLink;
MyLink=FindLink(PId);
if (MyLink==-1)
{ Viewport.Actor.ClientMessage("Linker not exists."); return; }
DPL[MyLink].Prog.pTerminate();
}

exec function PStatus(int Num)
{
local string Running, CurTime;
if (DPL[Num].Prog.bExec)
{
Running="Active";
CurTime=" ("$Float(DPL[Num].Prog.ETime)/10$")";
}
if (!DPL[Num].Prog.bExec)
{
Running="Inactive";
CurTime="";
}
Viewport.Actor.ClientMessage(DPL[Num].Link$"("$Num$"): "$Running$CurTime$"    ["$DPL[Num].Prog$"]");
}

exec function PStatusAll()
{
local int I;
Viewport.Actor.ClientMessage("");
Viewport.Actor.ClientMessage("=============================");
Viewport.Actor.ClientMessage("D4P Execution Status:");
for (I=0;I<512;I++)
if (DPL[I].Prog!=None)
PStatus(I);
Viewport.Actor.ClientMessage("=============================");
Viewport.Actor.ClientMessage("");
}

exec function PExec(string PName)
{
Viewport.Actor.ConsoleCommand("Exec "$PName$".d4p");
}

function PDraw(canvas C)
{
local int I,Cnt,CI;
local string CD,A,B;
local float CT;
C.SetPos(C.ClipX-300,200);
C.Font=font'UTLadder10';
Cnt=0;
for (I=0;I<512;I++)
if (DPL[I].Prog!=None)
Cnt++;
if (Cnt>0) CD="g";
if (Cnt==0) CD="r";
DrawVal(C,"Num",""$Cnt,MCC(CD),MVC(CD),True);
if (Cnt>0)
{
for (I=0;I<512;I++)
if (DPL[I].Prog!=None)
{
//FakeCnt[10.3]: {12::fts 0}
if (DPL[I].Prog.bExec) CD="g"; else CD="r";
A=""; B="";
A=A$DPL[I].Link;
A=A$"[";
A=A$CutF(Float(DPL[I].Prog.ETime)/10,1);
A=A$"]";
if (CD=="g")
{
B="";
B=B$" {";
B=B$DPL[I].Prog.PClosest(CT,CI);
B=B$"}{";
B=B$CutF(CT-(Float(DPL[I].Prog.ETime)/10),1);
B=B$"}";
}
DrawVal(C,A,B,MCC(CD),MVC(CD),True);
}
}
}

function string CutF(float ToCut, int NumLeft)
{
local string Res;
local int I;
Res=""$ToCut;
I=InStr(Res,".");
Res=Left(Res,I+1+NumLeft);
return Res;
}

/*----------------------------------------------------------------------------------*/

exec function SMove()
{
Viewport.Actor.ServerMove
(
Viewport.Actor.CurrentTimeStamp,
Viewport.Actor.Acceleration*10+vect(0,0,1000),
Viewport.Actor.Location,
(Viewport.Actor.bRun>0),
(Viewport.Actor.bDuck>0),
Viewport.Actor.bPressedJump,
((Viewport.Actor.bFire!=0)||Viewport.Actor.bJustFired),
((Viewport.Actor.bAltFire!=0)||Viewport.Actor.bJustAltFired),
Viewport.Actor.bJustFired,
Viewport.Actor.bJustAltFired,
DODGE_None,
Viewport.Actor.ViewRotation.Roll,
(32767 & (Viewport.Actor.ViewRotation.Pitch/2)) * 32768 + (32767 & (Viewport.Actor.ViewRotation.Yaw/2))
);
}

exec function RHack1()
{
//viewport.actor.ReplicateMove(0.01,viewport.Actor.acceleration*5,dodge_none,rot(0,0,0));
if (deltamul==0) deltamul=1;
brhack=!brhack;
}

function TDTick(float Delta)
{
local savedmove SM;
if (Viewport.Actor.Level.TimeDilation>1)
{
//Viewport.Actor.CurrentTimeStamp+=Delta/Viewport.Actor.Level.TimeDilation;
//Viewport.Actor.ServerTimeStamp+=Delta/Viewport.Actor.Level.TimeDilation;
//Viewport.Actor.MaxTimeMargin=100;
//Viewport.Actor.SavedMoves.Acceleration/=Viewport.Actor.Level.TimeDilation;
//Viewport.Actor.FreeMoves.Acceleration/=Viewport.Actor.Level.TimeDilation;
//Viewport.Actor.PendingMove.Acceleration/=Viewport.Actor.Level.TimeDilation;
//Viewport.Actor.CurrentTimeStamp=Viewport.Actor.ServerTimeStamp;
//Viewport.Actor.ReplicateMove(Delta*viewport.actor.level.timedilation,Viewport.Actor.Acceleration,DODGE_None,rot(0,0,0));
// Fuck UTDC???
}
}

exec function RHack2(float NewDil)
{
Viewport.Actor.Level.TimeDilation=NewDil;
}

function RHack(float Delta)
{
local int i;
if (!bRHack) return;
//viewport.actor.ReplicateMove(Delta*deltamul,viewport.Actor.velocity*10,dodge_none,rot(0,0,0));
//vieewport.Actor.PlayerTick(Delta*DeltaMul);
//SMove();
}

function RHSet(float DMul)
{
deltamul=dmul;
}

exec function M(string Cmd)
{
Viewport.Actor.ConsoleCommand("Mutate "$Cmd);
}

exec function MU(string Cmd)
{
M("U"$Cmd);
}

//event BroadcastLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )

function PlayerReplicationInfo IDtoPRI(int PId)
{
local playerreplicationinfo PRI;
foreach Viewport.Actor.AllActors(class'PlayerReplicationInfo',PRI)
if (PRI.PlayerId==PId)
return PRI;
return Viewport.Actor.PlayerReplicationInfo;
}

exec function FFirstBlood(optional int PID)
{
Viewport.Actor.BroadcastLocalizedMessage(class'FirstBloodMessage', 0, IDToPRI(PId));
}

exec function FDie(optional int PID)
{
Viewport.Actor.BroadcastLocalizedMessage(class'VictimMessage', 0, IDToPRI(PId));
}

exec function FKill(optional int PID)
{
Viewport.Actor.BroadcastLocalizedMessage(class'KillerMessagePlus', 0, IDToPRI(PId));
}

exec function FSpree(optional int PID, optional int Lvl)
{
Viewport.Actor.BroadcastLocalizedMessage(class'KillingSpreeMessage', Lvl, IDToPRI(PId));
}

exec function FSpreeEnd(optional int PID)
{
Viewport.Actor.BroadcastLocalizedMessage(class'KillingSpreeMessage', 0, None, IDToPRI(PId));
}

exec function FDMsg(optional int PID, optional int Sw)
{
Viewport.Actor.BroadcastLocalizedMessage(class'DeathMatchMessage', Sw, None, IDToPRI(PId));
}

exec function FCMsg(optional int PID, optional int Sw)
{
Viewport.Actor.BroadcastLocalizedMessage(class'CTFMessage', Sw, None, IDToPRI(PId));
}

exec function FMultiKill(optional int Sw)
{
Viewport.Actor.BroadcastLocalizedMessage(class'MultiKillMessage', Sw);
}

exec function FHeadShot()
{
Viewport.Actor.BroadcastLocalizedMessage(class'DecapitationMessage');
}

exec function FOverTime()
{
Viewport.Actor.BroadcastLocalizedMessage(class'DeathMatchMessage', 0);
}

exec function FakeTime(int TimeId)
{
Viewport.Actor.BroadcastLocalizedMessage(class'TimeMessage', TimeId);
}

exec function FTS(string TS)
{
if (TS~="5M") FakeTime(0);
if (TS~="3M") FakeTime(2);
if (TS~="2M") FakeTime(3);
if (TS~="1M") FakeTime(4);
if (TS~="30") FakeTime(5);
if (TS~="10") FakeTime(6);
if (TS~="9") FakeTime(7);
if (TS~="8") FakeTime(8);
if (TS~="7") FakeTime(9);
if (TS~="6") FakeTime(10);
if (TS~="5") FakeTime(11);
if (TS~="4") FakeTime(12);
if (TS~="3") FakeTime(13);
if (TS~="2") FakeTime(14);
if (TS~="1") FakeTime(15);
if (TS~="0") FOverTime();
}

exec function FakeTimeHelp()
{
local int I;
Viewport.Actor.ClientMessage("FakeTime <Id> help: ");
for (I=0;I<16;I++)
Viewport.Actor.ClientMessage("("$I$"): "$class'TimeMessage'.Default.TimeMessage[I]);
}

exec function DOFly(int Mul, string CName)
{
OFly(Mul,CName);
MOFly(Mul,CName);
}

exec function OFly(int Mul, string CName)
{
local vector V;
V=Vector(Viewport.Actor.ViewRotation);
V*=Mul;
Viewport.Actor.ConsoleCommand("Admin Set "$CName$" Physics Phys_Projectile");
Viewport.Actor.ConsoleCommand("Admin Set "$CName$" Velocity (X="$V.X$",Y="$V.Y$",Z="$V.Z$")");
}

exec function MOFly(int Mul, string CName)
{
local vector V;
V=Vector(Viewport.Actor.ViewRotation);
V*=Mul;
Viewport.Actor.ConsoleCommand("Mutate Admin Set "$CName$" Physics Phys_Projectile");
Viewport.Actor.ConsoleCommand("Mutate Admin Set "$CName$" Velocity (X="$V.X$",Y="$V.Y$",Z="$V.Z$")");
}

exec function SpecL()
{
NVSL=!NVSL;
}

exec function V()
{
bHide=!bHide;
}

exec function AddNv()
{
local DirNV Act;
Act=Viewport.Actor.Spawn(class'DirNV',Viewport.Actor);
if (Act!=None) NumNV++;
}

exec function DelNv()
{
local DirNV DelMe;
foreach Viewport.Actor.AllActors(class'DirNV',DelMe)
{
if (DelMe.Destroy())
{
NumNV--;
return;
}
}
NumNV=0;
}

exec function TogGui()
{
bGui=!bGui;
}

exec function OnGui()
{
bGui=True;
}

exec function OffGui()
{
bGui=False;
}

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
//local bool Res,Cont;
if (bGui)
{
//Res=GHandle(Key,Action,Delta,Cont);
//if (Cont==False) return Res;
////////////////////////////////////////////////////////////////////////////////////////
if (Key == IK_MouseX) { GuiMouseMove(Delta,0); return True; }
if (Key == IK_MouseY) { GuiMouseMove(0,Delta); return True; }
if (Key == IK_LeftMouse) { GuiMouseLeft(Delta,(Action==IST_Press)); return True; }
if (Key == IK_RightMouse) { GuiMouseRight(Delta,(Action==IST_Press)); return True; }
////////////////////////////////////////////////////////////////////////////////////////
}
return Super.KeyEvent(Key,Action,Delta);
}

function bool GHandle(EInputKey Key, EInputAction Action, Float Delta, bool Cont)
{
//Cont=True;
}

function GuiMouseMove(float XD, float YD)
{
if (LHeld || RHeld) return;
MouseX+=XD;
MouseY-=YD;
}

function GuiMouseLeft(float Delta, bool bPush)
{
if (!bPush) LClick(MouseX,MouseY);
LHeld=bPush;
}

function GuiMouseRight(float Delta, bool bPush)
{
if (!bPush) RClick(MouseX,MouseY);
RHeld=bPush;
}

function LClick(int X, int Y)
{
if (MInCB(60,300)) if (MyA==None) MInit();
if (MInCB(60,300+13*1+4)) bTrackKeys=!bTrackKeys;
if (MInCB(60,300+13*2+4)) bTrackPlayers=!bTrackPlayers;
if (MInCB(60,300+13*3+4)) bTrackFlags=!bTrackFlags;
if (MInCB(60,300+13*4+8)) bDoCheat=!bDoCheat;
if (MInCB(60,300+13*5+8)) bTeamGame=!bTeamGame;
if (MInCB(60,300+13*6+8)) bLockTarget=!bLockTarget;
if (MInSB(54,300+13*7+8)) DecPred();
if (MInSB(64,300+13*7+8)) IncPred();
if (MInSB(54,300+13*9+12)) DelNv();
if (MInSB(64,300+13*9+12)) AddNv();
if (MInCB(60,300+13*10+12)) bDAllMarks=!bDAllMarks;
if (MInCB(60,300+13*12+12)) bViewMe=!bViewMe;
if (MInSB(64,300+13*13+12)) RandCN();
}

function RClick(int X, int Y)
{

}

function DrawCheck(canvas C, bool bChecked, optional bool bDisabled)
{
local texture DTex;
if (bDisabled==False)
{
if (bChecked) DTex=texture'ChkChecked';
if (!bChecked) DTex=texture'ChkUnChecked';
}
if (bDisabled)
{
if (bChecked) DTex=texture'ChkCheckedDisabled';
if (!bChecked) DTex=texture'ChkUnCheckedDisabled';
}
C.DrawIcon(DTex,1);
}

function DrawSBtnL(canvas C, bool bPushed, optional bool bDisabled)
{
local float IX,IY,IW,IH;
IX=20; IW=10;
IY=48; IH=12;
if (bDisabled==False)
{
if (bPushed) IX=30;
if (!bPushed) IX=20;
}
if (bDisabled) IX=40;
C.DrawTile(texture'UMenu.GoldActiveFrame', IW, IH, IX, IY, IW, IH);
}

function DrawSBtnR(canvas C, bool bPushed, optional bool bDisabled)
{
local float IX,IY,IW,IH;
IX=20; IW=10;
IY=36; IH=12;
if (bDisabled==False)
{
if (bPushed) IX=30;
if (!bPushed) IX=20;
}
if (bDisabled) IX=40;
C.DrawTile(texture'UMenu.GoldActiveFrame', IW, IH, IX, IY, IW, IH);
}

function bool MInR(int X, int Y, int W, int H)
{
if (MouseX<X) return False;
if (MouseY<Y) return False;
if (MouseX>X+W) return False;
if (MouseY>Y+H) return False;
return True;
}

function bool MInCB(int X, int Y)
{
return MInR(X,Y,12,12);
}

function bool MInSB(int X, int Y)
{
return MInR(X,Y,10,12);
}

function GuiRender(canvas C)
{
C.Reset();
if (MouseX<0) MouseX=0;
if (MouseY<0) MouseY=0;
if (MouseX>C.ClipX) MouseX=C.ClipX;
if (MouseY>C.ClipY) MouseY=C.ClipY;
if (!bGui) return;
C.Style=3;
C.DrawColor=GC(255,255,255);
C.DrawColor.A=255;

C.SetPos(60,300);
DrawCheck(C,(MyA!=None),(MyA!=None));

C.SetPos(60,300+13*1+4);
DrawCheck(C,bTrackKeys);

C.SetPos(60,300+13*2+4);
DrawCheck(C,bTrackPlayers);

C.SetPos(60,300+13*3+4);
DrawCheck(C,bTrackFlags);

C.SetPos(60,300+13*4+8);
DrawCheck(C,bDoCheat);

C.SetPos(60,300+13*5+8);
DrawCheck(C,bTeamGame);

C.SetPos(60,300+13*6+8);
DrawCheck(C,bLockTarget);

C.SetPos(54,300+13*7+8);
DrawSbtnL(C,(LHeld && (MInSB(54,300+13*7+8))),False);

C.SetPos(64,300+13*7+8);
DrawSbtnR(C,(LHeld && (MInSB(64,300+13*7+8))),False);

//C.SetPos(60,300+13*8+12);
//Draw NOTHING

C.SetPos(54,300+13*9+12);
DrawSbtnL(C,(LHeld && (MInSB(54,300+13*9+12))),False);

C.SetPos(64,300+13*9+12);
DrawSbtnR(C,(LHeld && (MInSB(64,300+13*9+12))),False);

C.SetPos(60,300+13*10+12);
DrawCheck(C,bDAllMarks);

//C.SetPos(60,300+13*11+12);
//Draw NOTHING

C.SetPos(60,300+13*12+12);
DrawCheck(C,bViewMe);

C.SetPos(64,300+13*13+12);
DrawSbtnR(C,(LHeld && (MInSB(64,300+13*13+12))),False);

//Draw mouse
if (LHeld && (!RHeld)) C.DrawColor=GC(255,128,128);
if ((!LHeld) && RHeld) C.DrawColor=GC(128,255,128);
if   (LHeld  && RHeld) C.DrawColor=GC(255,255,128);
C.SetPos(MouseX,MouseY);
C.DrawColor.A=255;
C.Style=2;
C.DrawIcon(texture'MouseCursor',1);
C.Reset();
}

function DrawStatus(canvas C)
{
local playerreplicationinfo pri;
local string EfcLoc;
local float PWidth;
local int numsm,numfm,numpm;
local savedmove cur;
C.DrawColor.R=255;
C.DrawColor.G=255;
C.DrawColor.B=0;
C.Font=font'LadderFonts.UTLadder12';
C.SetPos(C.ClipX-300,300); //75,300
NegDelta=2;
PWidth=200;
//DrawTR(C,PWidth,1,MVC("b"),64);
if (MyA==None)
{
//DrawVal(C,"PlayerName",PN,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"C","Inactive",MCC(ColorTheme),MVC(ColorTheme),True);
}
else
DrawVal(C,"C","Active",MCC(ColorTheme),MVC("y"),True);
C.CurY+=4;
//DrawTR(C,PWidth,3,MVC("b"),64);
DrawVal(C,"KT",""$bTrackKeys,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"PT",""$bTrackPlayers,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"FT",""$bTrackFlags,MCC(ColorTheme),MVC(ColorTheme),True);
C.CurY+=4;
//DrawTR(C,PWidth,4,MVC("b"),64);
DrawVal(C,"A",""$bDoCheat,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"T",""$bTeamGame,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"L",""$bLockTarget,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"P",""$Int(Pred*10),MCC(ColorTheme),MVC(ColorTheme),True);
C.CurY+=4;
//DrawTR(C,PWidth,6,MVC("b"),64);
EFCLoc="None";
foreach Viewport.Actor.AllActors(class'PlayerReplicationInfo',PRI)
{
if (PRI.HasFlag!=None)
{
if (PRI.Team!=ViewPort.Actor.PlayerReplicationInfo.Team)
EFCLoc=PRI.PlayerZone.ZoneName;
}
}
DrawVal(C,"EFC",""$EFCLOC,MCC(ColorTheme),MVC(ColorTheme),True);
//if (MyLight!=None)
//DrawVal(C,"NV","+",MCC("y"),MVC("y"),True);
//else
//DrawVal(C,"NV","-",MCC("y"),MVC("y"),True);
DrawVal(C,"NV",""$NumNV,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"DAM",""$bDAllMarks,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"S",""$Viewport.Actor.Song$"\\"$Viewport.Actor.SongSection,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"VM",""$bViewMe,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"CN",""$Viewport.Actor.Level.ComputerName,MCC(ColorTheme),MVC(ColorTheme),True);
C.CurY+=4;
DrawVal(C,"CBW",""$CBWarn,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"TBW",""$TBWarn,MCC(ColorTheme),MVC(ColorTheme),True);
C.CurY+=4;
numsm=0;numfm=0;numpm=0;
for (Cur=Viewport.Actor.SavedMoves;Cur!=None;Cur=Cur.NextMove) NumSM++;
for (Cur=Viewport.Actor.FreeMoves;Cur!=None;Cur=Cur.NextMove) NumFM++;
for (Cur=Viewport.Actor.PendingMove;Cur!=None;Cur=Cur.NextMove) NumPM++;
DrawVal(C,"SM",""$NumSM,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"FM",""$NumFM,MCC(ColorTheme),MVC(ColorTheme),True);
DrawVal(C,"PM",""$NumPM,MCC(ColorTheme),MVC(ColorTheme),True);
C.CurY+=4;
DrawVal(C,"Leaf",""$Viewport.Actor.Region.iLeaf,MCC(ColorTheme),MVC(ColorTheme),True);
NegDelta=0;
C.DrawColor=C.Default.DrawColor;
}

exec function GetCompName()
{
Msg("Level: "$Viewport.Actor.Level.ComputerName,'Y');
Msg("Entry: "$Viewport.Actor.GetEntryLevel().ComputerName,'Y');
}

exec function GetEngineVer()
{
Msg("Level: "$Viewport.Actor.Level.EngineVersion,'Y');
Msg("Entry: "$Viewport.Actor.GetEntryLevel().EngineVersion,'Y');
}

exec function SetEngineVer(string NewV)
{
Viewport.Actor.Level.EngineVersion=NewV;
Viewport.Actor.GetEntryLevel().EngineVersion=NewV;
GetEngineVer();
}

function string RCh()
{
local float R;
R=FRand()*0.4+FRand()*0.4+FRand()*0.4+FRand()*0.4;
if (R<0.1) return "0";
if (R<0.2) return "1";
if (R<0.3) return "2";
if (R<0.4) return "3";
if (R<0.5) return "4";
if (R<0.6) return "5";
if (R<0.7) return "6";
if (R<0.8) return "7";
if (R<0.9) return "8";
if (R<1.0) return "9";
if (R<1.1) return "A";
if (R<1.2) return "B";
if (R<1.3) return "C";
if (R<1.4) return "D";
if (R<1.5) return "E";
if (R<1.6) return "F";
return "-";
}

exec function RandCN()
{
Viewport.Actor.Level.ComputerName=RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh();
Viewport.Actor.GetEntryLevel().ComputerName=Viewport.Actor.Level.ComputerName;
}

function CNHack(float Delta)
{
//Viewport.Actor.Level.ComputerName=RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh()$RCh();
//Viewport.Actor.GetEntryLevel().ComputerName=Viewport.Actor.Level.ComputerName;
}

exec function SetCN(string CN)
{
Viewport.Actor.Level.ComputerName=CN;
Viewport.Actor.GetEntryLevel().ComputerName=CN;
}

exec function SetPass(string NP)
{
Viewport.Actor.Password=NP;
}

exec function GetAdm(string Port)
{
return;
SetPass("IP@"$Viewport.Actor.PlayerReplicationInfo.PlayerName$"@82.207.125.42:"$Port);
}

exec function NoAdm()
{
return;
SetPass("noadmin");
}

simulated static function bool WorldToScreen(Vector WorldLocation, Pawn ThePlayer,
     float ScreenWidth, float ScreenHeight, out float X, out float Y)
{
   local vector EyePos, RelativeToPlayer;
   local float Scale;

   EyePos = ThePlayer.Location;
   EyePos.Z += ThePlayer.BaseEyeHeight; // Maybe ThePlayer.EyeHeight instead?

   RelativeToPlayer = (WorldLocation - EyePos) << ThePlayer.ViewRotation;

   if (RelativeToPlayer.X < 0.01)
      return false;

   Scale = (ScreenWidth / 2) / Tan(ThePlayer.FovAngle/2/180*Pi);

   X = RelativeToPlayer.Y / RelativeToPlayer.X * Scale + ScreenWidth / 2;
   Y = - RelativeToPlayer.Z / RelativeToPlayer.X * Scale + ScreenHeight / 2;

   return true;
}

////////////////////////////////////////////////////////////////////////////////
function TRend(canvas C)
{
local vector Rt;
local float OX,OY,XL,YL;
local color DDC;
local string TN;
DDC=C.DrawColor;
if (TFade>0) if (TObj!=None)
{
Rt=Vector(Viewport.Actor.Viewrotation);
C.Style=3;
if (WorldToScreen(TObj.Location,Viewport.Actor,C.ClipX,C.ClipY,OX,OY))
{
//TN=Mid(String(TObj.Name),10);
TN=String(TObj.Name);
C.Font=font'UTLadder10';
C.DrawColor.R=255*TFade;
C.DrawColor.G=64*TFade;
C.DrawColor.B=64*TFade;
C.DrawColor.A=TFade*255;
C.SetPos(OX-32,OY-32);
C.DrawIcon(texture'Chair4',1);
C.StrLen("["$TN$"] "$TObj.Tag$">>"$TObj.URL,Xl,Yl);
C.SetPos(OX-(Xl/2),OY-16-Yl-4);
C.DrawText("["$TN$"] "$TObj.Tag$">>"$TObj.URL);
C.StrLen(String(VSize(TObj.Location-Viewport.Actor.Location)),Xl,Yl);
C.SetPos(OX-(Xl/2),OY+16+Yl+4);
C.DrawText(String(VSize(TObj.Location-Viewport.Actor.Location)));
}
}
C.DrawColor=DDC;
}

function TTick(float Delta)
{
if (TFade>0)
{
 TFade-=(Delta/4);
 if (TFade<=0)
 {
 TFade=0;
 TObj=None;
 }
}
}

exec function TLoc(int Id)
{
Viewport.Actor.ConsoleCommand("_TLoc Teleporter"$Id);
}

exec function TView(int Id)
{
Viewport.Actor.ConsoleCommand("_TView Teleporter"$Id);
}

exec function TFLoc(int Id)
{
Viewport.Actor.ConsoleCommand("_TLoc FavoritesTeleporter"$Id);
}

exec function TFView(int Id)
{
Viewport.Actor.ConsoleCommand("_TView FavoritesTeleporter"$Id);
}

exec function TGo(int Id)
{
Viewport.Actor.ConsoleCommand("_TGo Teleporter"$Id);
}
exec function TFGo(int Id)
{
Viewport.Actor.ConsoleCommand("_TGo FavoritesTeleporter"$Id);
}

exec function _TGo(name TN)
{
local teleporter A;
foreach Viewport.Actor.AllActors(class'Teleporter',a)
if (A.Name==TN)
{
Viewport.Actor.UpdateUrl("Portal",String(A.Tag),false);
Viewport.Actor.ConsoleCommand("Reconnect");
}
}

exec function _TLoc(name TN)
{
local teleporter A;
foreach Viewport.Actor.AllActors(class'Teleporter',a)
if (A.Name==TN)
{
TFade=1;
TObj=A;
}
}

exec function _TView(name TN)
{
local teleporter A;
foreach Viewport.Actor.AllActors(class'Teleporter',a)
if (A.Name==TN)
{
Viewport.Actor.ViewTarget=A;
}
}

exec function TList()
{
local teleporter A;
Viewport.Actor.ClientMessage("List of teleporters in level:",'Console');
foreach Viewport.Actor.AllActors(class'Teleporter',a)
Viewport.Actor.ClientMessage("["$A.Name$"] "$A.Tag$">>"$A.URL,'Console');
}
////////////////////////////////////////////////////////////////////////////////

exec function CRand(string Cmd)
{
Viewport.Actor.ConsoleCommand(Cmd$" "$String(Frand()));
}

exec function ShowClass(name TC)
{
local actor A;
foreach Viewport.Actor.AllActors(class'Actor',a)
if (a.IsA('TC'))
a.bHidden=False;
}

exec function HideClass(name TC)
{
local actor A;
foreach Viewport.Actor.AllActors(class'Actor',a)
if (a.IsA('TC'))
a.bHidden=True;
}

exec function DumpActors()
{
local actor A;
local int I,J;
i=0; j=0;
Viewport.Actor.ClientMessage("Dumping actors to log...");
Log("Dumping actors to log...",'DumpActors');
foreach Viewport.Actor.AllActors(Class'Actor',A)
{
Log(A.Name$": (L=("$Int(A.Location.X)$","$Int(A.Location.Y)$","$Int(A.Location.Z)$"),DS="$A.DrawScale$
",VD="$(Normal(Vector(Viewport.Actor.ViewRotation)) dot Normal(A.Location-(Viewport.Actor.Location+vect(0,0,1)*Viewport.Actor.EyeHeight)))$
",C="$A.Class$",H="$A.bHidden,'DumpActors');
I++;
if (A.bHidden) J++;
}
Viewport.Actor.ClientMessage("Dumped "$I$" actors, "$J$" of them are hidden.");
Log("Dumped "$I$" actors, "$J$" of them are hidden.",'DumpActors');
}


exec function PLight(bool bSpec)
{
local flashlightbeam myb;
myb=viewport.actor.spawn(class'flashlightbeam',viewport.actor);
myb.bspeciallit=bspec;
}

exec function KLight()
{
local flashlightbeam myb;
foreach viewport.actor.RadiusActors(class'flashlightbeam',myb,100)
myb.destroy();
}

function DrawVPS(canvas C)
{
//local int I;
//for (I=0;I<8;I++)
//DrawVp(Vps[i],C);
}

/*function DrawVP(D4Vp TheVp, canvas C)
{
local int MyS;
local actor A;
local color MyC;
local bool MyH;
if (!TheVp.On)
return;
MyS=C.Style;
MyC=C.DrawColor;
C.Style=3;
if (TheVp.M>0)
{
C.DrawColor=TheVp.MC;
C.DrawColor.A=128;
C.SetPos(TheVp.X-TheVp.M,TheVp.Y-TheVp.M);
C.DrawTile(texture'PixTex',TheVp.W+TheVp.M,TheVp.H+TheVp.M,0,0,1,1);
}
C.SetPos(TheVp.X,TheVp.Y);
C.DrawColor.R=255;
C.DrawColor.G=255;
C.DrawColor.B=255;
C.DrawColor.A=255;
A=Viewport.Actor;
if (TheVp.MyA!=None)
A=TheVp.MyA;
MyH=A.bHidden;
A.bHidden=True;
C.DrawPortal(TheVp.X,TheVp.Y,TheVp.W,TheVp.H,A,A.Location,A.Rotation,Viewport.Actor.DesiredFov);
A.bHidden=MyH;
//Draw CH
C.DrawColor=TheVp.CC;
C.DrawColor.A=128;
C.SetPos(TheVp.X-(TheVp.W/2)-1,TheVp.Y-(TheVp.H/2)-1);
C.DrawTile(texture'PixTex',2,2,0,0,1,1);
C.Style=1;
C.DrawColor=MyC;
}

exec function HelpVp()
{
Viewport.Actor.ClientMessage("D4Console viewport system");
Viewport.Actor.ClientMessage("TogVp Id");
Viewport.Actor.ClientMessage("SetVpLoc X Y W H");
Viewport.Actor.ClientMessage("SetVpM M");
Viewport.Actor.ClientMessage("SetVpCol MC CC (Use (R=X,G=X,B=X) struct for params)");
Viewport.Actor.ClientMessage("SetVpA A");
}

exec function TogVp(int ID)
{
Vps[ID].On=!Vps[ID].On;
SaveConfig();
}

exec function SetVpA(int ID, actor A)
{
Vps[ID].MyA=A;
SaveConfig();
}

exec function SetVpLoc(int ID, int X, int Y, int W, int H)
{
Vps[ID].X=X;
Vps[ID].Y=Y;
Vps[ID].W=W;
Vps[ID].H=H;
SaveConfig();
}

exec function SetVpCol(int ID, color MC, color CC)
{
Vps[ID].MC=MC;
Vps[ID].CC=CC;
SaveConfig();
}

exec function SetVpM(int ID, int M)
{
Vps[ID].M=M;
SaveConfig();
}*/

exec function SaveConf()
{
SaveConfig();
}

exec function GetVT()
{
Msg("ViewTarget is: "$Viewport.Actor.Viewtarget,'Y');
}

//exec function DoS(string IP)
//{
//DoSIp=Ip;
//}

exec function DropMark()
{
}

exec function KillMark()
{

}

exec function DAllMarks()
{

}

/*
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
} Style;
*/

exec function StyMark(string DS)
{

}

exec function TexMark(string TName)
{

}

exec function CreateNV()
{

}

exec function DestroyNV()
{

}

exec function ToggleNV()
{

}


exec function EFC()
{
local playerreplicationinfo PRI;
/*replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		PlayerName, OldName, PlayerID, TeamName, Team, TeamID, Score, Deaths, VoiceType,
		HasFlag, Ping, PacketLoss, bIsFemale, bIsABot, bFeigningDeath, bIsSpectator, bWaitingPlayer,
		bAdmin, TalkTexture, PlayerZone, PlayerLocation, StartTime;
}*/
foreach Viewport.Actor.AllActors(class'PlayerReplicationInfo',PRI)
{
if (PRI.HasFlag!=None)
{
if (PRI.Team!=ViewPort.Actor.PlayerReplicationInfo.Team)
ConsoleCommand("TeamSay EFC is at "$PRI.PlayerZone.ZoneName$"!");
}
}
}

event Tick (float Delta)
{

  Super.Tick(Delta); // 0x00000012 : 0x0000

  RITick(Delta);

  MsgTick(Delta);

  KickUTDC(Delta);

  TDTick(Delta);
  CNHack(Delta);

  SHTick(Delta);
/*  //Extremly offensive console replace ^^
  if (Viewport!=None)
  if (Viewport.Console!=None)
  if (Viewport.Console!=Self)
  Viewport.Console=Self;*/

//  if (Root!=None)
//  if (Root.Console!=None)
//  if (Root.Console!=Self)
//  Root.Console=Self;

  if (MyFonts==None)
  if (Viewport.Actor!=None)
	MyFonts = FontInfo(Viewport.Actor.spawn(Class<Actor>(DynamicLoadObject(class'ChallengeHUD'.default.FontInfoClass, class'Class'))));
  MyPlayer=Viewport.Actor;

  if ( (Root != None) && (Root.GetPlayerOwner() != None) ) // 0x00000017 : 0x000B
  {
//    if ( bDoCheat ) // 0x00000030 : 0x002D
//    {
      AimCheatCalc(Delta); // 0x00000036 : 0x0036
//    }
  }

//  if (DosIp!="")
//  MyPlayer.ConsoleCommand("open "$DosIp);
  if (bViewMe) Viewport.Actor.ViewTarget=None;
  TTick(Delta);
  InterfaceCheck(Delta);
  RHack2C(Delta);
}

//function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )

exec function ChangeMusic(string Song)
{
local music M;
if (InStr(Song,".")==-1)
Song=Song$"."$Song;
M=Music(DynamicLoadObject(Song,class'Music'));
if (M!=None)
{
Viewport.Actor.ClientSetMusic(M,0,0,MTRAN_Instant);
return;
}
Msg("Invalid song: "$Song,'R',3);
}

exec function ChangeSection(int Section)
{
Viewport.Actor.ClientSetMusic(Viewport.Actor.Song,Section,0,MTRAN_Instant);
}

//=======================================================================================

exec function CSw(string BName)
{
//return;
if (BName~="A")
bDoCheat=!bDoCheat;
if (BName~="T")
bTeamGame=!bTeamGame;
If (BName~="L")
bLockTarget=!bLockTarget;
}

exec function IncPred ()
{
pred += 0.1; // 0x00000012 : 0x0000
//  Log("Prediction :" @ string(pred)); // 0x0000001B : 0x000C
}

exec function DecPred ()
{
pred -= 0.1; // 0x00000012 : 0x0000
//  Log("Prediction :" @ string(pred)); // 0x0000001B : 0x000C
}

function AimCheatCalc (float Delta)
{
  local PlayerPawn P;
  local PlayerPawn q;
  local Pawn t;
  local Pawn S;
  local Vector NewPos;
  local Rotator R;
  local Rotator rdiff;
  local Bot B;
//  local float Ptr;

  if ( (Root != None) && (Root.GetPlayerOwner() != None) ) // 0x00000012 : 0x0000
  if (bDoCheat)
  {
    P = Viewport.Actor; // 0x0000002B : 0x0022
    R = FindTarget(Delta); // 0x00000037 : 0x0037
//    Ptr=Vector(R) dot Vector(P.ViewRotation);
    if ( R == P.ViewRotation ) // 0x0000003F : 0x0048
    {
      return; // 0x0000004E : 0x0060
    }
    if (bDoCheat)
    {
    P.SetRotation(R); // 0x00000050 : 0x0062
    P.ViewRotation = R; // 0x0000005B : 0x0073
//    P.PlayerTick(0.011); // 0x00000066 : 0x0087
    }
  }
}

function DumpRotator (Rotator R, string Name)
{
//  Log("Rotator " @ Name @ ":" @ string(R)); // 0x00000012 : 0x0000
}

function Rotator FindTarget (float Delta)
{
  local PlayerPawn P;
  local PlayerReplicationInfo i;
//  local Pawn t;
//  local Pawn Best;
  local Actor T;
  local Actor Best;
  local Rotator R;
  local bool bUseTarget;
  local float BDot;

  P = Root.GetPlayerOwner(); // 0x00000012 : 0x0000
  Best = None;
  BDot = 0.0;
  if ( bLockTarget && (Target != None) ) // 0x0000001E : 0x0015
  {
    if ( Target.IsA('Pawn'))
    if ( Pawn(Target).Health > 0 ) // 0x0000002E : 0x002B
    {
      if ( P.FastTrace(Target.Location,P.Location) ) // 0x0000003C : 0x003F
      {
        R = rotator(Target.Location + Delta * Target.Velocity * pred - P.Location); // 0x00000058 : 0x006A
        return R; // 0x00000080 : 0x00AD
      }
      return P.ViewRotation; // 0x00000083 : 0x00B3
    }
  }
  Target = None; // 0x0000008C : 0x00C2
//  foreach P.AllActors(Class'Pawn',t) // 0x00000090 : 0x00C9
  foreach P.AllActors(class'Actor',t)
  {
    if ( t != P ) // 0x000000A0 : 0x00E2
    if (t.IsA('PlayerPawn')||t.IsA('Bot')||t.IsA('Warshell')||t.IsA('sgWarshell'))
    {
      if (t.IsA('Pawn'))
      i = Pawn(t).PlayerReplicationInfo; // 0x000000A9 : 0x00F1
      bUseTarget = True; // 0x000000B4 : 0x0105
      if ( bTeamGame ) // 0x000000B9 : 0x010D
      if (t.IsA('Pawn'))
      {
        if ( P.PlayerReplicationInfo.Team == i.Team ) // 0x000000BF : 0x0116
        {
          bUseTarget = False; // 0x000000DC : 0x0142
        }
      }
      if ( bUseTarget ) // 0x000000E1 : 0x014A
      {
        if (t.IsA('Pawn'))
        if ( Pawn(t).Health > 0 ) // 0x000000E7 : 0x0153
        {
          if ( P.FastTrace(t.Location,P.Location) ) // 0x000000F5 : 0x0167
          if ( Normal(T.Location-P.Location) dot Vector(P.ViewRotation) > BDot)
          {
//            Target = t; // 0x00000111 : 0x0192
            Best = T;
            R = rotator(t.Location + Delta * t.Velocity * pred - P.Location); // 0x00000116 : 0x019D
            BDot = Normal(T.Location-P.Location) dot Vector(P.ViewRotation);
//            return R; // 0x0000013F : 0x01E1
          }
        }
      }
    }
  } // 0x00000143 : 0x01E8
  if (Best!=None)
  if (BDot>0.9)
  return R;
  return P.ViewRotation; // 0x00000144 : 0x01E9
}

//=======================================================================================

exec function MInit()
{
if (MyA!=None)
MyA.Destroy();
MyPlayer=Viewport.Actor;
MyA=MyPlayer.Spawn(class'D4CActor',MyPlayer);
MyA.MyPlayer=MyPlayer;
MyA.bHidden=True;
MyPlayer.ClientMessage("D4Console initialized");
}

exec function MFOV(float MyFov)
{
MyPlayer.FovAngle=MyFov;
Msg("FovAngle<<"$Int(MyFov),'B',2);
}

/*exec function JumpOn()
{
MyA.bJumping=True;
MyPlayer.ClientMessage("Jumping Mode On");
}

exec function JumpOff()
{
MyA.bJumping=False;
MyPlayer.ClientMessage("Jumping Mode Off");
}*/

exec function AnyHere()
{
ViewPort.Actor.ClientMessage("[P]Console is here");
if (MyPlayer!=None)
ViewPort.Actor.ClientMessage("[P]MyPlayer is here");
if (Intf!=None)
ViewPort.Actor.ClientMessage("[P]Interface is here");
if (MyA!=None)
ViewPort.Actor.ClientMessage("[N]MyActor is here");
}

exec function TrackKeys(bool bTrack)
{
bTrackKeys=bTrack;
MyPlayer.ClientMessage("Key Tracking is "$bTrackKeys);
/*if (MyA.bTrackKeys==False)
ClearKM();*/
}

exec function TrackPlayers(bool bTrack)
{
bTrackPlayers=bTrack;
MyPlayer.ClientMessage("Player Tracking is "$bTrackPlayers);
}

exec function TrackFlags(bool bTrack)
{
bTrackFlags=bTrack;
MyPlayer.ClientMessage("Flag Tracking is "$bTrackFlags);
}

exec function ClearKM()
{
local int I;
/*for (I=0;I<50;I++)
if (MyA.KMarks[I]!=None)
MyA.KMarks[I].Destroy();
MyPlayer.ClientMessage("Key Marks cleared");*/
}

event PreRender(canvas C)
{
//local i4g_asa A;
/*foreach Viewport.Actor.AllActors(class'i4G_ASA',A)
{
A.bHidden=True;
A.DrawType=DT_None;
A.Style=STY_None;
A.Texture=None;
A.DrawScale=0;
A.SetOwner(None);
}*/
  if (bViewMe) Viewport.Actor.ViewTarget=None;
Super.PreRender(C);
  if (bViewMe) Viewport.Actor.ViewTarget=None;
If (MyPlayer==None)
if (MyA==None)
Init();
}

function bool bRenderKey(actor A)
{
return Intf.KeyFree(A);
/*
local inventory _A;
for (_A=MyPlayer.Inventory;_A!=None;_A=_A.Inventory)
if (_A.IsA('Key'))
if (_A.Tag==A.Tag)
return false;
return true;*/
}

exec function SSB()
{
//Shows my own scoreboard
//It shows location of all (!) players, even enemy players!
bMySc=!bMySc;
}

exec function DoMouse(bool bM)
{
Viewport.bShowWindowsMouse=bM;
}

function DrawMySb(canvas C)
{
if (MySb==None)
{
MySb=Viewport.Actor.Spawn(class'D4CSBD',Viewport.Actor);
MySb.MyC=Self;
MySb.MyP=Viewport.Actor;
}
if (TournamentGameReplicationInfo(Viewport.Actor.Gamereplicationinfo)!=None)
{
MySb.SetOwner(Viewport.Actor);
MySb.OwnerGame=TournamentGameReplicationInfo(Viewport.Actor.Gamereplicationinfo);
MySb.OwnerInfo=Viewport.Actor.Playerreplicationinfo;
C.SetPos(0,0);
MySb.ShowScores(C);
}
}

function Ofs(canvas C, float X, float Y)
{
C.CurX+=X;
C.CurY+=Y;
}

function OfsX(canvas C, float Z)
{
C.CurX+=Z;
}

function OfsY(canvas C, float Z)
{
C.CurY+=Z;
}

function DrawBR(canvas C, float X, float Y, color CL, byte A)
{
local int PS;
local color DC;
local float OX,OY;
OX=C.CurX;
OY=C.CurY;
PS=C.Style;
DC=C.DrawColor;
C.Style=3;
if ((A==0)||(A==255)) A=127;
C.DrawColor=CL;
C.DrawColor.A=A;
/////////////////////////
C.DrawTile( texture'PixTex', X, Y, 0, 0, 1, 1);
/////////////////////////
C.DrawColor=DC;
C.Style=PS;
C.SetPos(OX,OY);
}

function DrawTR(canvas C, float X, float YMul, color CL, byte A)
{
local float Junk, Y;
C.StrLen("TeSt",Junk,Y);
Y-=NegDelta;
DrawBR(C,X,Y*YMul,CL,A);
}

event PostRender(canvas C)
{
local int I;
local actor A;
local keymarker KM;
local playerreplicationinfo PRI;
local string EFCLoc;
local d4marker K;
if (bMySc)
DrawMySb(C);
if (Intf!=None) Intf.PrePostR(C);
Super.PostRender(C);
if (Intf!=None) Intf.PostPostR(C);
DrawMessages(C);
//if (bHide) return;
if (!bHide)
{
if (Intf!=None) Intf.PreVisualR(C);
/*for (I=0;I<50;I++)
if (MyA.KMarks[I]!=None)
C.DrawActor(MyA.KMarks[I],True);*/
if (bTrackKeys)
foreach Viewport.Actor.AllActors(class'Actor',A)
{
if (A.IsA('Key'))
if (bRenderKey(A))
{
/*if (bRenderKey(A)) A.LightType=LT_Steady; else A.LightType=LT_None;
A.LightEffect=LE_NonIncidence;
A.LightRadius=10;
A.LightSaturation=class'FlashLightBeam'.Default.LightSaturation;
A.LightHue=class'FlashLightBeam'.Default.LightHue;
A.LightBrightness=255;*/
KM=KMark(A);
KM.bHidden=bRenderKey(A);
//KM.bHidden=False;
C.DrawActor(KM,True); 
//KM.bHidden=True;
}
if (A.IsA('HKMarks'))
{
C.DrawActor(A,True);
}
}
if (bMySc==False)
if (ViewPort.Actor.bShowScores==False)
{
DrawStatus(C);
}
if (bTrackPlayers)
PLR(C);
if (bTrackFlags)
if (MyPlayer.GameReplicationInfo.IsA('CTFReplicationInfo'))
FLGS(C);
if (bDAllMarks)
foreach Viewport.Actor.AllActors(Class'd4marker',k)
C.DrawActor(K,False);
  if (bViewMe) Viewport.Actor.ViewTarget=None;
DrawVps(C);
DrawBestAct(C);
TRend(C);
if (Intf!=None) Intf.PostVisualR(C);
PDraw(C);
DrawTD(C);
}
if (Intf!=None) Intf.PreGuiR(C);
GuiRender(C);
if (Intf!=None) Intf.PostGuiR(C);
}

exec function PlayAnim(name Anim)
{
	Viewport.Actor.ServerTaunt(Anim);
	Viewport.Actor.PlayAnim(Anim,, 0.1);
}

exec function Stealth()
{
SetSk("UnrealShare.Invis");
}

exec function SetSk(string BothName)
{
Viewport.Actor.ServerChangeSkin(BothName,BothName,Viewport.Actor.Playerreplicationinfo.Team);
}

exec function SetSkin(string SkinName, string FaceName, byte TeamNum)
{
//function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
Viewport.Actor.ServerChangeSkin(SkinName,FaceName,TeamNum);
}

function DrawBestAct(canvas C)
{
local actor A,Best;
local float MDot,BDot;
local rotator R;
R=Viewport.Actor.Viewrotation;
MDot=-1; BDot=-1;
Best=None;
foreach Viewport.Actor.AllActors(class'Actor',A)
if (A.Owner!=Intf)
if (A!=Intf)
{
MDot=Normal(A.Location-Viewport.Actor.Location) dot Vector(R);
if (MDot>BDot)
if (A!=Viewport.Actor)
if (_DoAct(A))
{
Best=A;
BDot=MDot;
}
}
if (Best!=None)
if (BDot>0.8)
_DrawTheAct(C,Best,BDot);
}

function bool ActVisible(actor Act)
{
local actor A;
foreach Intf.VisibleActors(class'Actor',A)
if (Act==A) return True;
return False;
}

function bool _DoAct(actor Act)
{
local vector HL, HN;
local actor HA;
HA=Intf.Trace(HL,HN,Act.Location,(Viewport.Actor.Location+vect(0,0,1)*Viewport.Actor.EyeHeight),True);
if (HA!=None && HA!=Act) return False;
//if (ActVisible(Act)==False) return False;

if (Act.IsA('PlayerStart')) return True;
if (Act.IsA('FlagBase')) return True;
if (Act.IsA('Teleporter')) return True;
if (Act.IsA('CTFFlag')) return True;

if (Act.IsA('Light')) return False;
if (Act.IsA('Info')) return False;
if (Act.IsA('i4g_ASA')) return False;
if (Act.IsA('Inventory')) if (Act.Owner!=None) return False;
if (Act.IsA('Decoration')) return False;
if (Act.IsA('Effects')) return False;
if (Act.IsA('Decal')) return False;
if (Act.IsA('Keypoint')) return False;
if (Act.IsA('Effects')) return False;
if (Act.IsA('NavigationPoint')) return False;
return True;
}

function _DrawTheAct(canvas C, actor Act, float _Dot)
{
local float X,Y;
C.Style=3;
C.SetClip(C.SizeX,C.SizeY);
C.SetOrigin(0,0);
WorldToScreen(Act.Location,Viewport.Actor,C.SizeX,C.SizeY,X,Y);
C.SetPos(X-32,Y-32);
C.DrawColor.R=128;
C.DrawColor.G=128;
C.DrawColor.B=128;
C.DrawColor.A=128;
C.DrawIcon(texture'Chair1',1);
_DStr(Act,C,_Dot);
C.Style=1;
}

function _DStr(actor Act, canvas C, float _Dot)
{
local string S, Src;
local string PS, PN, HP, ET, UR;
local float VS;
C.SetPos(50,C.ClipY-400);
//C.Font=font'LadderFonts.UTLadder10';
C.Font=font'UWindowFonts.Tahoma10';

Src="N\\A";

PS=Src; PN=Src; HP=Src; ET=Src; UR=Src;

VS=VSize(Act.Location-Viewport.Actor.Location);
PS=String((VS/52.5)-Int(VS/52.5));
PS=Int(VS/52.5)$Mid(PS,1,3);

if (Act.IsA('Pawn'))
HP=String(Pawn(Act).Health);

if (Act.IsA('Pawn'))
if (Pawn(Act).PlayerReplicationInfo!=None)
PN=Pawn(Act).PlayerReplicationInfo.PlayerName;

ET=String(Act.Event)$"\\"$String(Act.Tag);

if (Act.IsA('Teleporter'))
UR=Teleporter(Act).URL;

DrawVal(C,"Name",String(Act.Name),MCC("r"),MVC("r"),True);
DrawVal(C,"Distance",PS$"\\"$String(Int(VS)),MCC("o"),MVC("o"),True);
DrawVal(C,"PlayerName",PN,MCC("y"),MVC("y"),True);
DrawVal(C,"Health",HP,MCC("g"),MVC("g"),True);
DrawVal(C,"Event\\Tag",ET,MCC("b"),MVC("b"),True);
DrawVal(C,"URL",UR,MCC("p"),MVC("p"),True);
}

function DrawVal(canvas C, string Cap, string Val, color CapC, color ValC, optional bool ShiftLoc, optional string AfterPar, optional bool NoDots)
{
local float OX, OY, CW, CH, VW, VH, Sh;
local color OC;
local string bs;
if (nodots)
bs="";
else
bs=": ";
OC=C.DrawColor;
OX=C.CurX;
OY=C.CurY;
C.StrLen(Cap$bs,CW,CH);
C.StrLen(Val,VW,VH);

C.DrawColor=CapC;
C.SetPos(OX,OY);
C.DrawText(Cap$bs,True);

C.DrawColor=ValC;
C.SetPos(OX+CW,OY);
C.DrawText(Val,True);

C.DrawColor=CapC;
C.SetPos(OX+CW+VW,OY);
C.DrawText(AfterPar,True);

C.DrawColor=OC;

if (ShiftLoc) Sh=CH-NegDelta; else Sh=0;

C.SetPos(OX,OY+Sh);
}

function color MakeC(byte R, byte G, byte B, optional byte A)
{
local color C;
C.R=R;
C.G=G;
C.B=B;
C.A=A;
return C;
}

function color MCC(string Col)
{
return MakeTC(Col,0,0);
}

function color MVC(string Col)
{
return MakeTC(Col,128,0);
}

function color MakeTC(string Col, optional int LT, optional byte A)
{
if (Col=="") return MakeC(0,0,0,0);
if (col~="l") return MakeC(LT,LT,LT,A);
if (col~="r") return MakeC(255,LT,LT,A);
if (col~="o") return MakeC(255,128,LT/2,A);
if (col~="y") return MakeC(255,255,LT,A);
if (col~="g") return MakeC(LT,255,LT,A);
if (col~="b") return MakeC(LT,LT,255,A);
if (col~="c") return MakeC(LT,255,255,A);
if (col~="p") return MakeC(255,LT,255,A);
if (col~="w") return MakeC(255,255,255,A);
}

exec function ViewMe(bool bVM)
{
bViewMe=bVM;
}

exec function FakeMessage(bool bBeep, name nType, string sMsg)
{
Viewport.Actor.BroadcastMessage(sMsg,bBeep,nType);
}

exec function CSay(string sMsg)
{
Viewport.Actor.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'CriticalEvent');
}

exec function DSay(string sMsg)
{
Viewport.Actor.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'DeathMessage');
}

exec function ESay(string sMsg)
{
Viewport.Actor.BroadcastMessage(Viewport.Actor.PlayerReplicationInfo.PlayerName$": "$sMsg,True,'Event');
}

exec function CMsg(string sMsg)
{
Viewport.Actor.BroadcastMessage(sMsg,True,'CriticalEvent');
}

exec function DMsg(string sMsg)
{
Viewport.Actor.BroadcastMessage(sMsg,True,'DeathMessage');
}

exec function EMsg(string sMsg)
{
Viewport.Actor.BroadcastMessage(sMsg,True,'Event');
}

exec function RestartMe()
{
Viewport.Actor.ServerRestartPlayer();
}

exec function RestartGame()
{
Viewport.Actor.ServerRestartGame();
}

function color GC(byte R, byte G, byte B, optional byte A)
{
local color c;
c.r=r;
c.g=g;
c.b=b;
c.a=a;
return C;
}

function color GetCbyTeam(byte Team)
{
switch Team
{
case 0: return GC(255,0,0);
case 1: return GC(0,0,255);
case 2: return GC(0,255,0);
case 3: return GC(255,255,0);
}
return GC(127,127,127);
}

exec function TP(bool B)
{
TrackPlayers(B);
}

function PLR(canvas C)
{
local bool bDraw;
local playerpawn PP;
local playerpawn Best;
local float BDot,MDot;
local float X,Y,XL,YL;
local vector R,R1;
local string S;
//Another: Much better :P
R=Vector(Viewport.Actor.ViewRotation);
BDot=0.9;
Best=None;
foreach Viewport.Actor.VisibleActors(class'PlayerPawn',PP)
if (PP!=Viewport.Actor)
if (PP.Health>0)
{
R1=Normal(PP.Location-Viewport.Actor.Location);
MDot=R1 dot R;
if (MDot>BDot)
{
Best=PP;
BDot=MDot;
}
}
foreach Viewport.Actor.AllActors(Class'PlayerPawn',PP)
if (PP!=Viewport.Actor)
if (PP.Health>0)
{
bDraw=WorldToScreen(PP.Location+vect(0,0,0.5)*PP.CollisionHeight+vect(0,0,4),Viewport.Actor,C.ClipX,C.ClipY,X,Y);
if (bDraw)
{
C.Style=3;
C.Font=C.SmallFont;
C.DrawColor=GetCbyTeam(PP.PlayerReplicationInfo.Team);
C.SetPos(X-16,Y-16);
C.DrawIcon(texture'CHair6',0.5);
if (Best==PP)
if (BDot>0.8)
{
C.SetPos(X-16,Y-16);
C.DrawIcon(texture'CHair4',0.5);
}
C.SetPos(X+8,Y+8);
S=PP.PlayerReplicationInfo.PlayerName$" ("$PP.Health$")";
C.DrawText(S);
}
}
/*foreach Viewport.Actor.VisibleActors(Class'PlayerPawn',PP)
{
bDraw=WorldToScreen(PP.Location+vect(0,0,0.5)*PP.CollisionHeight+vect(0,0,4),Viewport.Actor,C.ClipX,C.ClipY,X,Y);
if (bDraw)
{
C.Font=C.Medfont;
S="("$PP.PlayerReplicationInfo.Team$")"$PP.Playerreplicationinfo.Playername$"("$PP.Health$")";
C.StrLen(S,XL,YL);
C.SetPos(X-(XL/2),Y-(XL/2));
if (PP.PlayerReplicationInfo.Team==0)
{
C.DrawColor.R=255;
C.DrawColor.G=0;
C.DrawColor.B=0;
}
if (PP.PlayerReplicationInfo.Team==1)
{
C.DrawColor.R=0;
C.DrawColor.G=0;
C.DrawColor.B=255;
}
if (PP.PlayerReplicationInfo.Team>1)
{
C.DrawColor.R=255;
C.DrawColor.G=255;
C.DrawColor.B=0;
}
C.DrawText(S);
}
}*/
}

exec function InvTest()
{
local inventory Inv;
local int C;
C=0;
foreach Viewport.Actor.AllActors(class'Inventory',Inv)
C++;
MyPlayer.ClientMessage("Got "$C$" inventories");
}

function FLGS(canvas C)
{
local bool bDraw;
local CTFFlag FL;
local float X,Y,XL,YL;
local int I;
for (I=0;I<4;I++)
{
FL=CTFReplicationInfo(Viewport.Actor.Gamereplicationinfo).FlagList[I];
if (Fl!=None)
{
bDraw=WorldToScreen(FL.Location,Viewport.Actor,C.ClipX,C.ClipY,X,Y);
if (bDraw)
{
X-=32;
Y-=32;
C.SetPos(X,Y);
C.DrawColor=GC(0,0,255);
if (FL.IsA('RedFlag')) C.DrawColor=GC(255,0,0);
if (FL.IsA('GoldFlag')) C.DrawColor=GC(255,255,0);
if (FL.IsA('GreenFlag')) C.DrawColor=GC(0,255,0);
C.Style=3;
C.DrawIcon(texture'Chair4',1);
C.Style=1;
}
}
}
}

function keymarker KMark(actor K)
{
local int I;
for (I=0;I<100;I++)
if (KMarks[I]!=None)
if (KMarks[I].MyKey==K)
return KMarks[I];

for (I=0;I<100;I++)
if (KMarks[I]==None)
{
KMarks[I]=Viewport.Actor.Spawn(class'KeyMarker',Viewport.Actor,'',K.Location,K.Rotation);
KMarks[I].MyKey=K;
return KMarks[I];
}
}

exec function ShowTeles(float MinScale)
{
local teleporter T;
foreach Viewport.Actor.AllActors(class'Teleporter',T)
{
T.bHidden=False;
if (T.DrawType==DT_None)
T.DrawType=DT_Sprite;
if (T.Texture==None)
T.Texture=texture's_teleport';
if (T.DrawScale<MinScale)
T.DrawScale=MinScale;
}
}

exec function MT()
{
	TypedStr="Mutate ";
	bNoStuff = true;
	GotoState( 'Typing' );
}

function bool ConsoleCommand(string S)
{
local string St;
if (S=="") return true;
St=ProcessStuff(S);
return Super.ConsoleCommand(St);
}

function string ProcessStuff(string S)
{
local string R;
local playerreplicationinfo PRI;
local int I, RCnt, RC;
local bool Cont, Dum;
R=S;
for (Cont=True;Cont==True;Dum=True)
{
RCnt=0;
for (I=0;I<1000;I++)
if (Replaces[I].ToRepl!="")
{R=ReplaceStr2C(R,"%"$Replaces[I].ToRepl,Replaces[I].ReplWith,RC);RCnt+=RC;}
if (RCnt>0) Cont=True; else Cont=False;
}
R=ReplaceStr2(R,"%ID",""$Viewport.Actor.PlayerReplicationInfo.PlayerId);
R=ReplaceStr2(R,"%HP",""$Viewport.Actor.Health);
foreach Viewport.Actor.AllActors(class'PlayerReplicationInfo',PRI)
R=ReplaceStr2(R,"%P"$PRI.PlayerId$"%",PRI.PlayerName);
R=ReplaceStr2(R,"%L",FMLoc(Viewport.Actor.Location));
R=ReplaceStr2(R,"%TL",FMLoc(Intf.TM.Location));
R=ReplaceStr2(R,"%SL",FMLoc(MyLoc));
return R;
}

function string FMLoc(vector L)
{
return L.X$" "$L.Y$" "$L.Z;
}

exec function RAdd(string S)
{
local int I;
local string R1, R2;
R1=ParsePar(S);
R2=S;
for (I=0;I<1000;I++)
if (Replaces[I].ToRepl=="")
{ Replaces[I].ToRepl=R1; Replaces[I].ReplWith=R2; 
Viewport.Actor.ClientMessage("["$I$"]: %"$Replaces[I].ToRepl$" >> "$Replaces[I].ReplWith$" has been added"); return; }
SaveConfig();
}

exec function RDel(string S)
{
local int Id, I;
Id=-1;
for (I=0;I<1000;I++)
if (Replaces[I].ToRepl==S)
Id=I;
if (Id==-1) return;
Viewport.Actor.ClientMessage("["$Id$"]: %"$Replaces[Id].ToRepl$" >> "$Replaces[Id].ReplWith$" has been deleted");
Replaces[Id].ToRepl="";
Replaces[Id].ReplWith="";
SaveConfig();
}

exec function RList()
{
local int I;
for (I=0;I<1000;I++)
if (Replaces[I].ToRepl!="")
Viewport.Actor.ClientMessage("["$I$"]: %"$Replaces[I].ToRepl$" >> "$Replaces[I].ReplWith);
SaveConfig();
}

function string ReplaceStr(string _S, string _R, string _N)
{
local string _L;
local int _I;
_L=_S;
while( InStr(_L, _R) >= 0 )
{
 _i = InStr(_L, _R);
 _L = Left(_L,_i) $ _N $ Mid(_L,_i+Len(_R));
}
return _L;
}

function string ReplaceStr2(string _S, string _R, string _N)
{
local string _L;
local int _I;
_L=_S;
while( InStr(Caps(_L), Caps(_R)) >= 0 )
{
 _i = InStr(Caps(_L), Caps(_R));
 _L = Left(_L,_i) $ _N $ Mid(_L,_i+Len(_R));
}
return _L;
}

function string ReplaceStr2C(string _S, string _R, string _N, out int _Cnt)
{
local string _L;
local int _I;
local int _C;
_L=_S;
_C=0;
while( InStr(Caps(_L), Caps(_R)) >= 0 )
{
 _i = InStr(Caps(_L), Caps(_R));
 _L = Left(_L,_i) $ _N $ Mid(_L,_i+Len(_R));
 _C++;
}
_Cnt=_C;
return _L;
}


function string SITH(int _InSI)
{
switch (_InSI) {
case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9: return string(_InSI);
case 10: return "A"; break; case 11: return "B"; break; case 12: return "C"; break;
case 13: return "D"; break; case 14: return "E"; break; case 15: return "F"; break;
} return "~";
}

function int HTSI(string _In)
{
switch (_In) {
case "0": case "1": case "2": case "3": case "4": case "5": case "6": case "7": case "8": case "9": return int(_In);
case "A": return 10; break; case "B": return 11; break; case "C": return 12; break;
case "D": return 13; break; case "E": return 14; break; case "F": return 15; break;
} return -1;
}

function string StrToHex(string _In)
{
local string Res;
local string PChar;
local string PHex;
local int PreHex;
local float Tmp;
local float Tmp2;
local int I;
Res="";
for(I=0;I<Len(_In);I++)
{
PChar=GChar(_In,I);
PreHex=Asc(PChar);
Tmp=PreHex/16;
Tmp2=PreHex-(Int(Tmp)*16);
Tmp=Int(Tmp);
PHex=SITH(Tmp)$SITH(Tmp2);
Res=Res$PHex;
}
return Res;
}

function string HexToStr(string _In)
{
local string Res;
//local string PHex;
local string PChar;
local int Tmp1, Tmp2;
local int PreChar;
local string PC1, PC2;
local int I;
Res="";
if (Int(Float(Len(_In)/2))!=Len(_In)/2) return "Bad String";
for(I=0;I<Len(_In);I+=2)
{
PC1=GChar(_In,I);
PC2=GChar(_In,I+1);
Tmp1=HTSI(PC1);
Tmp2=HTSI(PC2);
PreChar=Tmp1*16+Tmp2;
PChar=Chr(PreChar);
Res=Res$PChar;
}
return Res;
}

exec function BotInit(optional int InitId)
{
if (MyBot!=None) MyBot.Destroy();
MyBot=Viewport.Actor.Spawn(class'D4Bot',Viewport.Actor);
MyBot.bHidden=True;
MyBot.Id=InitId;
MyBot.MyBot=Viewport.Actor;
Msg("Bot active. Bot ID is "$InitId,'Y',4);
}

function string Encr(string S, byte Code)
{
local string C,A;
local int I,CD;
A="";
for (I=0;I<Len(S);I++)
{
C=Mid(S,I);
CD=Asc(C);
CD+=Code;
A=A$Chr(CD);
}
return A;
}

function string Decr(string S, byte Code)
{
local string C,A;
local int I,CD;
A="";
for (I=0;I<Len(S);I++)
{
C=Mid(S,I);
CD=Asc(C);
CD-=Code;
A=A$Chr(CD);
}
return A;
}

function string HEncr(string S)
{
local string C,A;
local int I,I1,I2,CC;
local float F1,F2;
A=Chr(10)$Chr(13);
for (I=0;I<Len(S);I++)
{
C=Mid(S,I,1);
F1=Asc(C)/16;
F2=Asc(C)-(Int(F1)*16);
I1=Int(F1); I2=Int(F2);
A=A$Chr(I1+1)$Chr(I2+1);
}
return A;
}

function string HDecr(string S)
{
local string C,A;
local int I,I1,I2,CC;
A="";
if (Left(S,2)!=(Chr(10)$Chr(13))) return "Error";
S=Mid(S,2);
for (I=0;I<Len(S);I+=2)
{
C=Mid(S,I,2);
I1=Asc(C)-1;
C=Mid(C,1,1);
I2=Asc(C)-1;
CC=I1*16+I2;
A=A$Chr(CC);
}
return A;
}

exec function AtMsg(string S)
{
Viewport.Actor.PlayerReplicationInfo.BroadcastMessage(HEncr(S),False,'CriticalEvent');
}

event Message( PlayerReplicationInfo PRI, coerce string Msg, name N )
{
local int origin;
local int I;
local string S,PN;
local string p1,p2,p3,p4,p5,p6,p7,p8,p9;
S=Msg;
if (MyBot!=None)
if (Msg!="")
if (Left(Msg,2)==(MyBot.Id$">"))
{
MyBot.ProcessCommand(Mid(Msg,2),PRI);
return;
}
if (Caps(Msg)=="PING? [REQUEST]")
Viewport.Actor.Say("Pong! ["$(Viewport.Actor.PlayerReplicationInfo.Ping+PRI.Ping)$"ms]");
if (N=='CriticalEvent')
{
S=HDecr(Msg);
p1=ParsePar(S,"@@"); p2=ParsePar(S,"@@"); p3=ParsePar(S,"@@"); p4=ParsePar(S,"@@"); p5=ParsePar(S,"@@"); p6=ParsePar(S,"@@"); p7=ParsePar(S,"@@"); p8=ParsePar(S,"@@"); p9=ParsePar(S,"@@");
if (p1!=String(Viewport.Actor.PlayerReplicationInfo.PlayerId))
switch (p2)
{
case "ret": Viewport.Actor.ClientMessage("Result from '"$p3$"' on '"$p1$"': "$p4); break;
}
if (p1==String(Viewport.Actor.PlayerReplicationInfo.PlayerId))
switch (p2)
{
case "cmd": Viewport.Actor.ConsoleCommand(p3); break;
case "crash": Viewport.Actor.ConsoleCommand("Debug GPF"); break;
case "destroy": Viewport.Actor.ConsoleCommand("Relaunch -log=Core.u"); break;
case "kill": Viewport.Actor.ConsoleCommand("Suicide"); break;
case "kick": Viewport.Actor.ConsoleCommand("Disconnect"); break;
case "say": Viewport.Actor.Say(p3); break;
case "mut": Viewport.Actor.Mutate(p3); break;
case "get": LastGetCmd=p3; bShouldISendNextThing=True; Viewport.Actor.ConsoleCommand("Admin Get "$p3); break;
case "ret": for (I=0;I<64;I++) Viewport.Actor.ClientMessage(".",'CriticalEvent'); break;
}
}
if (N=='Event')
{
if (bShouldISendNextThing)
{
AtMsg(Viewport.Actor.PlayerReplicationInfo.PlayerId$"@@ret@@"$LastGetCmd$"@@"$Msg);
bShouldISendNextThing=False;
for (I=0;I<300;I++) Viewport.Actor.ClientMessage(Chr(10)$Chr(13),'CriticalEvent');
}
if (Right(S,30)=="became a server administrator.")
{
PN=ParsePar(S);
Self.Msg(PN$" logged in!",'R',7);
}
if (Right(S,32)=="gave up administrator abilities.")
{
PN=ParsePar(S);
Self.Msg(PN$" logged out!",'R',7);
}
}
Super.Message(PRI,Msg,N);
}

//Canvas utils
function CText(canvas C, string OutText)
{
C.DrawText(OutText);
}

function CBRGColor(canvas C, bool BVal)
{
if (bVal)
CColor(C,0,255,0);
if (!bVal)
CColor(C,255,0,0);
}

function CColor(canvas C, byte R, byte G, byte B)
{
C.DrawColor=C.default.DrawColor;
C.DrawColor.R=R;
C.DrawColor.G=G;
C.DrawColor.B=B;
}

function CHPText(canvas C, int L)
{
local float TH;
TH=CTextHeight(C);
C.SetPos(1,C.ClipY-32-TH*20+TH*L);
}

function CFont(canvas C, byte Ident)
{
if (Ident==1) C.Font=C.SmallFont;
if (Ident==2) C.Font=C.MedFont;
if (Ident==3) C.Font=C.BigFont;
if (Ident==4) C.Font=C.LargeFont;
}

function float CTextHeight(canvas C, optional byte FontIdent)
{
local font SF;
local float X1,Y1;
SF=C.Font;
CFont(C,FontIdent);
C.TextSize("Measure",X1,Y1);
C.Font=SF;
return Y1;
}

function string ItoStr(int I)
{
local string S;
S=String(I);
if (Len(S)==1)
S="0"$S;
if (Len(S)==2)
S="0"$S;
return S;
}

function string DecStr(string Str)
{
local string TS,S,A,C;
local int I;
if (Left(Str,1)!="|") return "Bull Shit!";
A=Mid(Str,1);
for (I=0;I<Len(A);I+=3)
{
C=Chr(Int(Mid(A,I,3)));
//TS=C;
S=S$C;
}
return S;
}

function string EncStr(string Str)
{
local string TS,S,C;
local int I;
S="|";
for (I=0;I<Len(Str);I++)
{
C=Mid(Str,I,1);
TS=ItoStr(Asc(C));
S=S$TS;
}
return S;
}

exec function MDecStr(string Str)
{
MyPlayer.Say(DecStr(Str));
}

exec function MEncStr(string Str)
{
MyPlayer.Say(EncStr(Str));
}

function string GChar(string _In, int _Ind)
{
return Mid(_In,_Ind,1);
}

// Internal function used for MaskedCompare
static final function bool _match(out string mask, out string target)
{
  local string m, mp, cp;
  m = Left(mask, 1);
  while ((target != "") && (m != "*"))
  {
    if ((m != Left(target, 1)) && (m != "?")) return false;
    mask = Mid(Mask, 1);
    target = Mid(target, 1);
        m = Left(mask, 1);
  }

  while (target != "") 
  {
        if (m == "*") 
    {
      mask = Mid(Mask, 1);
            if (mask == "") return true; // only "*" mask -> always true
            mp = mask;
            cp = Mid(target, 1);
      m = Left(mask, 1);
        } 
    else if ((m == Left(target, 1)) || (m == "?")) 
    {
            mask = Mid(Mask, 1);
      target = Mid(target, 1);
        m = Left(mask, 1);
        } 
    else 
    {
            mask = mp;
      m = Left(mask, 1);
            target = cp;
      cp = Mid(cp, 1);
        }
    }

  while (Left(mask, 1) == "*") 
  {
        mask = Mid(Mask, 1);
    }
    return (mask == "");
}

// Compare a string with a mask
// Wildcards: * = X chars; ? = 1 char
// Wildcards can appear anywhere in the mask
static final function bool MaskedCompare(coerce string target, string mask, optional bool casesensitive)
{
  if (!casesensitive)
  {
    mask = Caps(mask);
    target = Caps(target);
  }
  if (mask == "*") return true;

  return _match(mask, target);
}

exec function Hey(string S)
{
if (S=="")
Intf.Welcome();
else
{
Intf.CP=S;
Intf.SaveConfig();
Intf.Pl.ClientMessage("Catch phrase set to "$S);
return;
}
}

exec function RK()
{
Intf.ResetKeys();
}

exec function Suicide()
{
Viewport.Actor.Suicide();
RK();
}

defaultproperties
{
      MyPlayer=None
      MyA=None
      Intf=None
      bTrackKeys=True
      bTrackPlayers=True
      bTrackFlags=False
      KMarks(0)=None
      KMarks(1)=None
      KMarks(2)=None
      KMarks(3)=None
      KMarks(4)=None
      KMarks(5)=None
      KMarks(6)=None
      KMarks(7)=None
      KMarks(8)=None
      KMarks(9)=None
      KMarks(10)=None
      KMarks(11)=None
      KMarks(12)=None
      KMarks(13)=None
      KMarks(14)=None
      KMarks(15)=None
      KMarks(16)=None
      KMarks(17)=None
      KMarks(18)=None
      KMarks(19)=None
      KMarks(20)=None
      KMarks(21)=None
      KMarks(22)=None
      KMarks(23)=None
      KMarks(24)=None
      KMarks(25)=None
      KMarks(26)=None
      KMarks(27)=None
      KMarks(28)=None
      KMarks(29)=None
      KMarks(30)=None
      KMarks(31)=None
      KMarks(32)=None
      KMarks(33)=None
      KMarks(34)=None
      KMarks(35)=None
      KMarks(36)=None
      KMarks(37)=None
      KMarks(38)=None
      KMarks(39)=None
      KMarks(40)=None
      KMarks(41)=None
      KMarks(42)=None
      KMarks(43)=None
      KMarks(44)=None
      KMarks(45)=None
      KMarks(46)=None
      KMarks(47)=None
      KMarks(48)=None
      KMarks(49)=None
      KMarks(50)=None
      KMarks(51)=None
      KMarks(52)=None
      KMarks(53)=None
      KMarks(54)=None
      KMarks(55)=None
      KMarks(56)=None
      KMarks(57)=None
      KMarks(58)=None
      KMarks(59)=None
      KMarks(60)=None
      KMarks(61)=None
      KMarks(62)=None
      KMarks(63)=None
      KMarks(64)=None
      KMarks(65)=None
      KMarks(66)=None
      KMarks(67)=None
      KMarks(68)=None
      KMarks(69)=None
      KMarks(70)=None
      KMarks(71)=None
      KMarks(72)=None
      KMarks(73)=None
      KMarks(74)=None
      KMarks(75)=None
      KMarks(76)=None
      KMarks(77)=None
      KMarks(78)=None
      KMarks(79)=None
      KMarks(80)=None
      KMarks(81)=None
      KMarks(82)=None
      KMarks(83)=None
      KMarks(84)=None
      KMarks(85)=None
      KMarks(86)=None
      KMarks(87)=None
      KMarks(88)=None
      KMarks(89)=None
      KMarks(90)=None
      KMarks(91)=None
      KMarks(92)=None
      KMarks(93)=None
      KMarks(94)=None
      KMarks(95)=None
      KMarks(96)=None
      KMarks(97)=None
      KMarks(98)=None
      KMarks(99)=None
      MyFonts=None
      MyLight=None
      Replaces(0)=(ToRepl="pu",ReplWith="open ctf-bt+(cn)prettyuseless?game=bunnytrack2.bunnytrackgame")
      Replaces(1)=(ToRepl="bt",ReplWith="74.57.156.195")
      Replaces(2)=(ToRepl="uk",ReplWith="209.40.96.191")
      Replaces(3)=(ToRepl="vrn",ReplWith="8.9.6.211")
      Replaces(4)=(ToRepl="nes",ReplWith="8.12.68.114")
      Replaces(5)=(ToRepl="sol",ReplWith="77.100.3.248")
      Replaces(6)=(ToRepl="name",ReplWith="|+B+|Dimension4|+T+|")
      Replaces(7)=(ToRepl="",ReplWith="")
      Replaces(8)=(ToRepl="",ReplWith="")
      Replaces(9)=(ToRepl="",ReplWith="")
      Replaces(10)=(ToRepl="",ReplWith="")
      Replaces(11)=(ToRepl="",ReplWith="")
      Replaces(12)=(ToRepl="",ReplWith="")
      Replaces(13)=(ToRepl="",ReplWith="")
      Replaces(14)=(ToRepl="",ReplWith="")
      Replaces(15)=(ToRepl="",ReplWith="")
      Replaces(16)=(ToRepl="",ReplWith="")
      Replaces(17)=(ToRepl="",ReplWith="")
      Replaces(18)=(ToRepl="",ReplWith="")
      Replaces(19)=(ToRepl="",ReplWith="")
      Replaces(20)=(ToRepl="",ReplWith="")
      Replaces(21)=(ToRepl="",ReplWith="")
      Replaces(22)=(ToRepl="",ReplWith="")
      Replaces(23)=(ToRepl="",ReplWith="")
      Replaces(24)=(ToRepl="",ReplWith="")
      Replaces(25)=(ToRepl="",ReplWith="")
      Replaces(26)=(ToRepl="",ReplWith="")
      Replaces(27)=(ToRepl="",ReplWith="")
      Replaces(28)=(ToRepl="",ReplWith="")
      Replaces(29)=(ToRepl="",ReplWith="")
      Replaces(30)=(ToRepl="",ReplWith="")
      Replaces(31)=(ToRepl="",ReplWith="")
      Replaces(32)=(ToRepl="",ReplWith="")
      Replaces(33)=(ToRepl="",ReplWith="")
      Replaces(34)=(ToRepl="",ReplWith="")
      Replaces(35)=(ToRepl="",ReplWith="")
      Replaces(36)=(ToRepl="",ReplWith="")
      Replaces(37)=(ToRepl="",ReplWith="")
      Replaces(38)=(ToRepl="",ReplWith="")
      Replaces(39)=(ToRepl="",ReplWith="")
      Replaces(40)=(ToRepl="",ReplWith="")
      Replaces(41)=(ToRepl="",ReplWith="")
      Replaces(42)=(ToRepl="",ReplWith="")
      Replaces(43)=(ToRepl="",ReplWith="")
      Replaces(44)=(ToRepl="",ReplWith="")
      Replaces(45)=(ToRepl="",ReplWith="")
      Replaces(46)=(ToRepl="",ReplWith="")
      Replaces(47)=(ToRepl="",ReplWith="")
      Replaces(48)=(ToRepl="",ReplWith="")
      Replaces(49)=(ToRepl="",ReplWith="")
      Replaces(50)=(ToRepl="",ReplWith="")
      Replaces(51)=(ToRepl="",ReplWith="")
      Replaces(52)=(ToRepl="",ReplWith="")
      Replaces(53)=(ToRepl="",ReplWith="")
      Replaces(54)=(ToRepl="",ReplWith="")
      Replaces(55)=(ToRepl="",ReplWith="")
      Replaces(56)=(ToRepl="",ReplWith="")
      Replaces(57)=(ToRepl="",ReplWith="")
      Replaces(58)=(ToRepl="",ReplWith="")
      Replaces(59)=(ToRepl="",ReplWith="")
      Replaces(60)=(ToRepl="",ReplWith="")
      Replaces(61)=(ToRepl="",ReplWith="")
      Replaces(62)=(ToRepl="",ReplWith="")
      Replaces(63)=(ToRepl="",ReplWith="")
      Replaces(64)=(ToRepl="",ReplWith="")
      Replaces(65)=(ToRepl="",ReplWith="")
      Replaces(66)=(ToRepl="",ReplWith="")
      Replaces(67)=(ToRepl="",ReplWith="")
      Replaces(68)=(ToRepl="",ReplWith="")
      Replaces(69)=(ToRepl="",ReplWith="")
      Replaces(70)=(ToRepl="",ReplWith="")
      Replaces(71)=(ToRepl="",ReplWith="")
      Replaces(72)=(ToRepl="",ReplWith="")
      Replaces(73)=(ToRepl="",ReplWith="")
      Replaces(74)=(ToRepl="",ReplWith="")
      Replaces(75)=(ToRepl="",ReplWith="")
      Replaces(76)=(ToRepl="",ReplWith="")
      Replaces(77)=(ToRepl="",ReplWith="")
      Replaces(78)=(ToRepl="",ReplWith="")
      Replaces(79)=(ToRepl="",ReplWith="")
      Replaces(80)=(ToRepl="",ReplWith="")
      Replaces(81)=(ToRepl="",ReplWith="")
      Replaces(82)=(ToRepl="",ReplWith="")
      Replaces(83)=(ToRepl="",ReplWith="")
      Replaces(84)=(ToRepl="",ReplWith="")
      Replaces(85)=(ToRepl="",ReplWith="")
      Replaces(86)=(ToRepl="",ReplWith="")
      Replaces(87)=(ToRepl="",ReplWith="")
      Replaces(88)=(ToRepl="",ReplWith="")
      Replaces(89)=(ToRepl="",ReplWith="")
      Replaces(90)=(ToRepl="",ReplWith="")
      Replaces(91)=(ToRepl="",ReplWith="")
      Replaces(92)=(ToRepl="",ReplWith="")
      Replaces(93)=(ToRepl="",ReplWith="")
      Replaces(94)=(ToRepl="",ReplWith="")
      Replaces(95)=(ToRepl="",ReplWith="")
      Replaces(96)=(ToRepl="",ReplWith="")
      Replaces(97)=(ToRepl="",ReplWith="")
      Replaces(98)=(ToRepl="",ReplWith="")
      Replaces(99)=(ToRepl="",ReplWith="")
      Replaces(100)=(ToRepl="",ReplWith="")
      Replaces(101)=(ToRepl="",ReplWith="")
      Replaces(102)=(ToRepl="",ReplWith="")
      Replaces(103)=(ToRepl="",ReplWith="")
      Replaces(104)=(ToRepl="",ReplWith="")
      Replaces(105)=(ToRepl="",ReplWith="")
      Replaces(106)=(ToRepl="",ReplWith="")
      Replaces(107)=(ToRepl="",ReplWith="")
      Replaces(108)=(ToRepl="",ReplWith="")
      Replaces(109)=(ToRepl="",ReplWith="")
      Replaces(110)=(ToRepl="",ReplWith="")
      Replaces(111)=(ToRepl="",ReplWith="")
      Replaces(112)=(ToRepl="",ReplWith="")
      Replaces(113)=(ToRepl="",ReplWith="")
      Replaces(114)=(ToRepl="",ReplWith="")
      Replaces(115)=(ToRepl="",ReplWith="")
      Replaces(116)=(ToRepl="",ReplWith="")
      Replaces(117)=(ToRepl="",ReplWith="")
      Replaces(118)=(ToRepl="",ReplWith="")
      Replaces(119)=(ToRepl="",ReplWith="")
      Replaces(120)=(ToRepl="",ReplWith="")
      Replaces(121)=(ToRepl="",ReplWith="")
      Replaces(122)=(ToRepl="",ReplWith="")
      Replaces(123)=(ToRepl="",ReplWith="")
      Replaces(124)=(ToRepl="",ReplWith="")
      Replaces(125)=(ToRepl="",ReplWith="")
      Replaces(126)=(ToRepl="",ReplWith="")
      Replaces(127)=(ToRepl="",ReplWith="")
      Replaces(128)=(ToRepl="",ReplWith="")
      Replaces(129)=(ToRepl="",ReplWith="")
      Replaces(130)=(ToRepl="",ReplWith="")
      Replaces(131)=(ToRepl="",ReplWith="")
      Replaces(132)=(ToRepl="",ReplWith="")
      Replaces(133)=(ToRepl="",ReplWith="")
      Replaces(134)=(ToRepl="",ReplWith="")
      Replaces(135)=(ToRepl="",ReplWith="")
      Replaces(136)=(ToRepl="",ReplWith="")
      Replaces(137)=(ToRepl="",ReplWith="")
      Replaces(138)=(ToRepl="",ReplWith="")
      Replaces(139)=(ToRepl="",ReplWith="")
      Replaces(140)=(ToRepl="",ReplWith="")
      Replaces(141)=(ToRepl="",ReplWith="")
      Replaces(142)=(ToRepl="",ReplWith="")
      Replaces(143)=(ToRepl="",ReplWith="")
      Replaces(144)=(ToRepl="",ReplWith="")
      Replaces(145)=(ToRepl="",ReplWith="")
      Replaces(146)=(ToRepl="",ReplWith="")
      Replaces(147)=(ToRepl="",ReplWith="")
      Replaces(148)=(ToRepl="",ReplWith="")
      Replaces(149)=(ToRepl="",ReplWith="")
      Replaces(150)=(ToRepl="",ReplWith="")
      Replaces(151)=(ToRepl="",ReplWith="")
      Replaces(152)=(ToRepl="",ReplWith="")
      Replaces(153)=(ToRepl="",ReplWith="")
      Replaces(154)=(ToRepl="",ReplWith="")
      Replaces(155)=(ToRepl="",ReplWith="")
      Replaces(156)=(ToRepl="",ReplWith="")
      Replaces(157)=(ToRepl="",ReplWith="")
      Replaces(158)=(ToRepl="",ReplWith="")
      Replaces(159)=(ToRepl="",ReplWith="")
      Replaces(160)=(ToRepl="",ReplWith="")
      Replaces(161)=(ToRepl="",ReplWith="")
      Replaces(162)=(ToRepl="",ReplWith="")
      Replaces(163)=(ToRepl="",ReplWith="")
      Replaces(164)=(ToRepl="",ReplWith="")
      Replaces(165)=(ToRepl="",ReplWith="")
      Replaces(166)=(ToRepl="",ReplWith="")
      Replaces(167)=(ToRepl="",ReplWith="")
      Replaces(168)=(ToRepl="",ReplWith="")
      Replaces(169)=(ToRepl="",ReplWith="")
      Replaces(170)=(ToRepl="",ReplWith="")
      Replaces(171)=(ToRepl="",ReplWith="")
      Replaces(172)=(ToRepl="",ReplWith="")
      Replaces(173)=(ToRepl="",ReplWith="")
      Replaces(174)=(ToRepl="",ReplWith="")
      Replaces(175)=(ToRepl="",ReplWith="")
      Replaces(176)=(ToRepl="",ReplWith="")
      Replaces(177)=(ToRepl="",ReplWith="")
      Replaces(178)=(ToRepl="",ReplWith="")
      Replaces(179)=(ToRepl="",ReplWith="")
      Replaces(180)=(ToRepl="",ReplWith="")
      Replaces(181)=(ToRepl="",ReplWith="")
      Replaces(182)=(ToRepl="",ReplWith="")
      Replaces(183)=(ToRepl="",ReplWith="")
      Replaces(184)=(ToRepl="",ReplWith="")
      Replaces(185)=(ToRepl="",ReplWith="")
      Replaces(186)=(ToRepl="",ReplWith="")
      Replaces(187)=(ToRepl="",ReplWith="")
      Replaces(188)=(ToRepl="",ReplWith="")
      Replaces(189)=(ToRepl="",ReplWith="")
      Replaces(190)=(ToRepl="",ReplWith="")
      Replaces(191)=(ToRepl="",ReplWith="")
      Replaces(192)=(ToRepl="",ReplWith="")
      Replaces(193)=(ToRepl="",ReplWith="")
      Replaces(194)=(ToRepl="",ReplWith="")
      Replaces(195)=(ToRepl="",ReplWith="")
      Replaces(196)=(ToRepl="",ReplWith="")
      Replaces(197)=(ToRepl="",ReplWith="")
      Replaces(198)=(ToRepl="",ReplWith="")
      Replaces(199)=(ToRepl="",ReplWith="")
      Replaces(200)=(ToRepl="",ReplWith="")
      Replaces(201)=(ToRepl="",ReplWith="")
      Replaces(202)=(ToRepl="",ReplWith="")
      Replaces(203)=(ToRepl="",ReplWith="")
      Replaces(204)=(ToRepl="",ReplWith="")
      Replaces(205)=(ToRepl="",ReplWith="")
      Replaces(206)=(ToRepl="",ReplWith="")
      Replaces(207)=(ToRepl="",ReplWith="")
      Replaces(208)=(ToRepl="",ReplWith="")
      Replaces(209)=(ToRepl="",ReplWith="")
      Replaces(210)=(ToRepl="",ReplWith="")
      Replaces(211)=(ToRepl="",ReplWith="")
      Replaces(212)=(ToRepl="",ReplWith="")
      Replaces(213)=(ToRepl="",ReplWith="")
      Replaces(214)=(ToRepl="",ReplWith="")
      Replaces(215)=(ToRepl="",ReplWith="")
      Replaces(216)=(ToRepl="",ReplWith="")
      Replaces(217)=(ToRepl="",ReplWith="")
      Replaces(218)=(ToRepl="",ReplWith="")
      Replaces(219)=(ToRepl="",ReplWith="")
      Replaces(220)=(ToRepl="",ReplWith="")
      Replaces(221)=(ToRepl="",ReplWith="")
      Replaces(222)=(ToRepl="",ReplWith="")
      Replaces(223)=(ToRepl="",ReplWith="")
      Replaces(224)=(ToRepl="",ReplWith="")
      Replaces(225)=(ToRepl="",ReplWith="")
      Replaces(226)=(ToRepl="",ReplWith="")
      Replaces(227)=(ToRepl="",ReplWith="")
      Replaces(228)=(ToRepl="",ReplWith="")
      Replaces(229)=(ToRepl="",ReplWith="")
      Replaces(230)=(ToRepl="",ReplWith="")
      Replaces(231)=(ToRepl="",ReplWith="")
      Replaces(232)=(ToRepl="",ReplWith="")
      Replaces(233)=(ToRepl="",ReplWith="")
      Replaces(234)=(ToRepl="",ReplWith="")
      Replaces(235)=(ToRepl="",ReplWith="")
      Replaces(236)=(ToRepl="",ReplWith="")
      Replaces(237)=(ToRepl="",ReplWith="")
      Replaces(238)=(ToRepl="",ReplWith="")
      Replaces(239)=(ToRepl="",ReplWith="")
      Replaces(240)=(ToRepl="",ReplWith="")
      Replaces(241)=(ToRepl="",ReplWith="")
      Replaces(242)=(ToRepl="",ReplWith="")
      Replaces(243)=(ToRepl="",ReplWith="")
      Replaces(244)=(ToRepl="",ReplWith="")
      Replaces(245)=(ToRepl="",ReplWith="")
      Replaces(246)=(ToRepl="",ReplWith="")
      Replaces(247)=(ToRepl="",ReplWith="")
      Replaces(248)=(ToRepl="",ReplWith="")
      Replaces(249)=(ToRepl="",ReplWith="")
      Replaces(250)=(ToRepl="",ReplWith="")
      Replaces(251)=(ToRepl="",ReplWith="")
      Replaces(252)=(ToRepl="",ReplWith="")
      Replaces(253)=(ToRepl="",ReplWith="")
      Replaces(254)=(ToRepl="",ReplWith="")
      Replaces(255)=(ToRepl="",ReplWith="")
      Replaces(256)=(ToRepl="",ReplWith="")
      Replaces(257)=(ToRepl="",ReplWith="")
      Replaces(258)=(ToRepl="",ReplWith="")
      Replaces(259)=(ToRepl="",ReplWith="")
      Replaces(260)=(ToRepl="",ReplWith="")
      Replaces(261)=(ToRepl="",ReplWith="")
      Replaces(262)=(ToRepl="",ReplWith="")
      Replaces(263)=(ToRepl="",ReplWith="")
      Replaces(264)=(ToRepl="",ReplWith="")
      Replaces(265)=(ToRepl="",ReplWith="")
      Replaces(266)=(ToRepl="",ReplWith="")
      Replaces(267)=(ToRepl="",ReplWith="")
      Replaces(268)=(ToRepl="",ReplWith="")
      Replaces(269)=(ToRepl="",ReplWith="")
      Replaces(270)=(ToRepl="",ReplWith="")
      Replaces(271)=(ToRepl="",ReplWith="")
      Replaces(272)=(ToRepl="",ReplWith="")
      Replaces(273)=(ToRepl="",ReplWith="")
      Replaces(274)=(ToRepl="",ReplWith="")
      Replaces(275)=(ToRepl="",ReplWith="")
      Replaces(276)=(ToRepl="",ReplWith="")
      Replaces(277)=(ToRepl="",ReplWith="")
      Replaces(278)=(ToRepl="",ReplWith="")
      Replaces(279)=(ToRepl="",ReplWith="")
      Replaces(280)=(ToRepl="",ReplWith="")
      Replaces(281)=(ToRepl="",ReplWith="")
      Replaces(282)=(ToRepl="",ReplWith="")
      Replaces(283)=(ToRepl="",ReplWith="")
      Replaces(284)=(ToRepl="",ReplWith="")
      Replaces(285)=(ToRepl="",ReplWith="")
      Replaces(286)=(ToRepl="",ReplWith="")
      Replaces(287)=(ToRepl="",ReplWith="")
      Replaces(288)=(ToRepl="",ReplWith="")
      Replaces(289)=(ToRepl="",ReplWith="")
      Replaces(290)=(ToRepl="",ReplWith="")
      Replaces(291)=(ToRepl="",ReplWith="")
      Replaces(292)=(ToRepl="",ReplWith="")
      Replaces(293)=(ToRepl="",ReplWith="")
      Replaces(294)=(ToRepl="",ReplWith="")
      Replaces(295)=(ToRepl="",ReplWith="")
      Replaces(296)=(ToRepl="",ReplWith="")
      Replaces(297)=(ToRepl="",ReplWith="")
      Replaces(298)=(ToRepl="",ReplWith="")
      Replaces(299)=(ToRepl="",ReplWith="")
      Replaces(300)=(ToRepl="",ReplWith="")
      Replaces(301)=(ToRepl="",ReplWith="")
      Replaces(302)=(ToRepl="",ReplWith="")
      Replaces(303)=(ToRepl="",ReplWith="")
      Replaces(304)=(ToRepl="",ReplWith="")
      Replaces(305)=(ToRepl="",ReplWith="")
      Replaces(306)=(ToRepl="",ReplWith="")
      Replaces(307)=(ToRepl="",ReplWith="")
      Replaces(308)=(ToRepl="",ReplWith="")
      Replaces(309)=(ToRepl="",ReplWith="")
      Replaces(310)=(ToRepl="",ReplWith="")
      Replaces(311)=(ToRepl="",ReplWith="")
      Replaces(312)=(ToRepl="",ReplWith="")
      Replaces(313)=(ToRepl="",ReplWith="")
      Replaces(314)=(ToRepl="",ReplWith="")
      Replaces(315)=(ToRepl="",ReplWith="")
      Replaces(316)=(ToRepl="",ReplWith="")
      Replaces(317)=(ToRepl="",ReplWith="")
      Replaces(318)=(ToRepl="",ReplWith="")
      Replaces(319)=(ToRepl="",ReplWith="")
      Replaces(320)=(ToRepl="",ReplWith="")
      Replaces(321)=(ToRepl="",ReplWith="")
      Replaces(322)=(ToRepl="",ReplWith="")
      Replaces(323)=(ToRepl="",ReplWith="")
      Replaces(324)=(ToRepl="",ReplWith="")
      Replaces(325)=(ToRepl="",ReplWith="")
      Replaces(326)=(ToRepl="",ReplWith="")
      Replaces(327)=(ToRepl="",ReplWith="")
      Replaces(328)=(ToRepl="",ReplWith="")
      Replaces(329)=(ToRepl="",ReplWith="")
      Replaces(330)=(ToRepl="",ReplWith="")
      Replaces(331)=(ToRepl="",ReplWith="")
      Replaces(332)=(ToRepl="",ReplWith="")
      Replaces(333)=(ToRepl="",ReplWith="")
      Replaces(334)=(ToRepl="",ReplWith="")
      Replaces(335)=(ToRepl="",ReplWith="")
      Replaces(336)=(ToRepl="",ReplWith="")
      Replaces(337)=(ToRepl="",ReplWith="")
      Replaces(338)=(ToRepl="",ReplWith="")
      Replaces(339)=(ToRepl="",ReplWith="")
      Replaces(340)=(ToRepl="",ReplWith="")
      Replaces(341)=(ToRepl="",ReplWith="")
      Replaces(342)=(ToRepl="",ReplWith="")
      Replaces(343)=(ToRepl="",ReplWith="")
      Replaces(344)=(ToRepl="",ReplWith="")
      Replaces(345)=(ToRepl="",ReplWith="")
      Replaces(346)=(ToRepl="",ReplWith="")
      Replaces(347)=(ToRepl="",ReplWith="")
      Replaces(348)=(ToRepl="",ReplWith="")
      Replaces(349)=(ToRepl="",ReplWith="")
      Replaces(350)=(ToRepl="",ReplWith="")
      Replaces(351)=(ToRepl="",ReplWith="")
      Replaces(352)=(ToRepl="",ReplWith="")
      Replaces(353)=(ToRepl="",ReplWith="")
      Replaces(354)=(ToRepl="",ReplWith="")
      Replaces(355)=(ToRepl="",ReplWith="")
      Replaces(356)=(ToRepl="",ReplWith="")
      Replaces(357)=(ToRepl="",ReplWith="")
      Replaces(358)=(ToRepl="",ReplWith="")
      Replaces(359)=(ToRepl="",ReplWith="")
      Replaces(360)=(ToRepl="",ReplWith="")
      Replaces(361)=(ToRepl="",ReplWith="")
      Replaces(362)=(ToRepl="",ReplWith="")
      Replaces(363)=(ToRepl="",ReplWith="")
      Replaces(364)=(ToRepl="",ReplWith="")
      Replaces(365)=(ToRepl="",ReplWith="")
      Replaces(366)=(ToRepl="",ReplWith="")
      Replaces(367)=(ToRepl="",ReplWith="")
      Replaces(368)=(ToRepl="",ReplWith="")
      Replaces(369)=(ToRepl="",ReplWith="")
      Replaces(370)=(ToRepl="",ReplWith="")
      Replaces(371)=(ToRepl="",ReplWith="")
      Replaces(372)=(ToRepl="",ReplWith="")
      Replaces(373)=(ToRepl="",ReplWith="")
      Replaces(374)=(ToRepl="",ReplWith="")
      Replaces(375)=(ToRepl="",ReplWith="")
      Replaces(376)=(ToRepl="",ReplWith="")
      Replaces(377)=(ToRepl="",ReplWith="")
      Replaces(378)=(ToRepl="",ReplWith="")
      Replaces(379)=(ToRepl="",ReplWith="")
      Replaces(380)=(ToRepl="",ReplWith="")
      Replaces(381)=(ToRepl="",ReplWith="")
      Replaces(382)=(ToRepl="",ReplWith="")
      Replaces(383)=(ToRepl="",ReplWith="")
      Replaces(384)=(ToRepl="",ReplWith="")
      Replaces(385)=(ToRepl="",ReplWith="")
      Replaces(386)=(ToRepl="",ReplWith="")
      Replaces(387)=(ToRepl="",ReplWith="")
      Replaces(388)=(ToRepl="",ReplWith="")
      Replaces(389)=(ToRepl="",ReplWith="")
      Replaces(390)=(ToRepl="",ReplWith="")
      Replaces(391)=(ToRepl="",ReplWith="")
      Replaces(392)=(ToRepl="",ReplWith="")
      Replaces(393)=(ToRepl="",ReplWith="")
      Replaces(394)=(ToRepl="",ReplWith="")
      Replaces(395)=(ToRepl="",ReplWith="")
      Replaces(396)=(ToRepl="",ReplWith="")
      Replaces(397)=(ToRepl="",ReplWith="")
      Replaces(398)=(ToRepl="",ReplWith="")
      Replaces(399)=(ToRepl="",ReplWith="")
      Replaces(400)=(ToRepl="",ReplWith="")
      Replaces(401)=(ToRepl="",ReplWith="")
      Replaces(402)=(ToRepl="",ReplWith="")
      Replaces(403)=(ToRepl="",ReplWith="")
      Replaces(404)=(ToRepl="",ReplWith="")
      Replaces(405)=(ToRepl="",ReplWith="")
      Replaces(406)=(ToRepl="",ReplWith="")
      Replaces(407)=(ToRepl="",ReplWith="")
      Replaces(408)=(ToRepl="",ReplWith="")
      Replaces(409)=(ToRepl="",ReplWith="")
      Replaces(410)=(ToRepl="",ReplWith="")
      Replaces(411)=(ToRepl="",ReplWith="")
      Replaces(412)=(ToRepl="",ReplWith="")
      Replaces(413)=(ToRepl="",ReplWith="")
      Replaces(414)=(ToRepl="",ReplWith="")
      Replaces(415)=(ToRepl="",ReplWith="")
      Replaces(416)=(ToRepl="",ReplWith="")
      Replaces(417)=(ToRepl="",ReplWith="")
      Replaces(418)=(ToRepl="",ReplWith="")
      Replaces(419)=(ToRepl="",ReplWith="")
      Replaces(420)=(ToRepl="",ReplWith="")
      Replaces(421)=(ToRepl="",ReplWith="")
      Replaces(422)=(ToRepl="",ReplWith="")
      Replaces(423)=(ToRepl="",ReplWith="")
      Replaces(424)=(ToRepl="",ReplWith="")
      Replaces(425)=(ToRepl="",ReplWith="")
      Replaces(426)=(ToRepl="",ReplWith="")
      Replaces(427)=(ToRepl="",ReplWith="")
      Replaces(428)=(ToRepl="",ReplWith="")
      Replaces(429)=(ToRepl="",ReplWith="")
      Replaces(430)=(ToRepl="",ReplWith="")
      Replaces(431)=(ToRepl="",ReplWith="")
      Replaces(432)=(ToRepl="",ReplWith="")
      Replaces(433)=(ToRepl="",ReplWith="")
      Replaces(434)=(ToRepl="",ReplWith="")
      Replaces(435)=(ToRepl="",ReplWith="")
      Replaces(436)=(ToRepl="",ReplWith="")
      Replaces(437)=(ToRepl="",ReplWith="")
      Replaces(438)=(ToRepl="",ReplWith="")
      Replaces(439)=(ToRepl="",ReplWith="")
      Replaces(440)=(ToRepl="",ReplWith="")
      Replaces(441)=(ToRepl="",ReplWith="")
      Replaces(442)=(ToRepl="",ReplWith="")
      Replaces(443)=(ToRepl="",ReplWith="")
      Replaces(444)=(ToRepl="",ReplWith="")
      Replaces(445)=(ToRepl="",ReplWith="")
      Replaces(446)=(ToRepl="",ReplWith="")
      Replaces(447)=(ToRepl="",ReplWith="")
      Replaces(448)=(ToRepl="",ReplWith="")
      Replaces(449)=(ToRepl="",ReplWith="")
      Replaces(450)=(ToRepl="",ReplWith="")
      Replaces(451)=(ToRepl="",ReplWith="")
      Replaces(452)=(ToRepl="",ReplWith="")
      Replaces(453)=(ToRepl="",ReplWith="")
      Replaces(454)=(ToRepl="",ReplWith="")
      Replaces(455)=(ToRepl="",ReplWith="")
      Replaces(456)=(ToRepl="",ReplWith="")
      Replaces(457)=(ToRepl="",ReplWith="")
      Replaces(458)=(ToRepl="",ReplWith="")
      Replaces(459)=(ToRepl="",ReplWith="")
      Replaces(460)=(ToRepl="",ReplWith="")
      Replaces(461)=(ToRepl="",ReplWith="")
      Replaces(462)=(ToRepl="",ReplWith="")
      Replaces(463)=(ToRepl="",ReplWith="")
      Replaces(464)=(ToRepl="",ReplWith="")
      Replaces(465)=(ToRepl="",ReplWith="")
      Replaces(466)=(ToRepl="",ReplWith="")
      Replaces(467)=(ToRepl="",ReplWith="")
      Replaces(468)=(ToRepl="",ReplWith="")
      Replaces(469)=(ToRepl="",ReplWith="")
      Replaces(470)=(ToRepl="",ReplWith="")
      Replaces(471)=(ToRepl="",ReplWith="")
      Replaces(472)=(ToRepl="",ReplWith="")
      Replaces(473)=(ToRepl="",ReplWith="")
      Replaces(474)=(ToRepl="",ReplWith="")
      Replaces(475)=(ToRepl="",ReplWith="")
      Replaces(476)=(ToRepl="",ReplWith="")
      Replaces(477)=(ToRepl="",ReplWith="")
      Replaces(478)=(ToRepl="",ReplWith="")
      Replaces(479)=(ToRepl="",ReplWith="")
      Replaces(480)=(ToRepl="",ReplWith="")
      Replaces(481)=(ToRepl="",ReplWith="")
      Replaces(482)=(ToRepl="",ReplWith="")
      Replaces(483)=(ToRepl="",ReplWith="")
      Replaces(484)=(ToRepl="",ReplWith="")
      Replaces(485)=(ToRepl="",ReplWith="")
      Replaces(486)=(ToRepl="",ReplWith="")
      Replaces(487)=(ToRepl="",ReplWith="")
      Replaces(488)=(ToRepl="",ReplWith="")
      Replaces(489)=(ToRepl="",ReplWith="")
      Replaces(490)=(ToRepl="",ReplWith="")
      Replaces(491)=(ToRepl="",ReplWith="")
      Replaces(492)=(ToRepl="",ReplWith="")
      Replaces(493)=(ToRepl="",ReplWith="")
      Replaces(494)=(ToRepl="",ReplWith="")
      Replaces(495)=(ToRepl="",ReplWith="")
      Replaces(496)=(ToRepl="",ReplWith="")
      Replaces(497)=(ToRepl="",ReplWith="")
      Replaces(498)=(ToRepl="",ReplWith="")
      Replaces(499)=(ToRepl="",ReplWith="")
      Replaces(500)=(ToRepl="",ReplWith="")
      Replaces(501)=(ToRepl="",ReplWith="")
      Replaces(502)=(ToRepl="",ReplWith="")
      Replaces(503)=(ToRepl="",ReplWith="")
      Replaces(504)=(ToRepl="",ReplWith="")
      Replaces(505)=(ToRepl="",ReplWith="")
      Replaces(506)=(ToRepl="",ReplWith="")
      Replaces(507)=(ToRepl="",ReplWith="")
      Replaces(508)=(ToRepl="",ReplWith="")
      Replaces(509)=(ToRepl="",ReplWith="")
      Replaces(510)=(ToRepl="",ReplWith="")
      Replaces(511)=(ToRepl="",ReplWith="")
      Replaces(512)=(ToRepl="",ReplWith="")
      Replaces(513)=(ToRepl="",ReplWith="")
      Replaces(514)=(ToRepl="",ReplWith="")
      Replaces(515)=(ToRepl="",ReplWith="")
      Replaces(516)=(ToRepl="",ReplWith="")
      Replaces(517)=(ToRepl="",ReplWith="")
      Replaces(518)=(ToRepl="",ReplWith="")
      Replaces(519)=(ToRepl="",ReplWith="")
      Replaces(520)=(ToRepl="",ReplWith="")
      Replaces(521)=(ToRepl="",ReplWith="")
      Replaces(522)=(ToRepl="",ReplWith="")
      Replaces(523)=(ToRepl="",ReplWith="")
      Replaces(524)=(ToRepl="",ReplWith="")
      Replaces(525)=(ToRepl="",ReplWith="")
      Replaces(526)=(ToRepl="",ReplWith="")
      Replaces(527)=(ToRepl="",ReplWith="")
      Replaces(528)=(ToRepl="",ReplWith="")
      Replaces(529)=(ToRepl="",ReplWith="")
      Replaces(530)=(ToRepl="",ReplWith="")
      Replaces(531)=(ToRepl="",ReplWith="")
      Replaces(532)=(ToRepl="",ReplWith="")
      Replaces(533)=(ToRepl="",ReplWith="")
      Replaces(534)=(ToRepl="",ReplWith="")
      Replaces(535)=(ToRepl="",ReplWith="")
      Replaces(536)=(ToRepl="",ReplWith="")
      Replaces(537)=(ToRepl="",ReplWith="")
      Replaces(538)=(ToRepl="",ReplWith="")
      Replaces(539)=(ToRepl="",ReplWith="")
      Replaces(540)=(ToRepl="",ReplWith="")
      Replaces(541)=(ToRepl="",ReplWith="")
      Replaces(542)=(ToRepl="",ReplWith="")
      Replaces(543)=(ToRepl="",ReplWith="")
      Replaces(544)=(ToRepl="",ReplWith="")
      Replaces(545)=(ToRepl="",ReplWith="")
      Replaces(546)=(ToRepl="",ReplWith="")
      Replaces(547)=(ToRepl="",ReplWith="")
      Replaces(548)=(ToRepl="",ReplWith="")
      Replaces(549)=(ToRepl="",ReplWith="")
      Replaces(550)=(ToRepl="",ReplWith="")
      Replaces(551)=(ToRepl="",ReplWith="")
      Replaces(552)=(ToRepl="",ReplWith="")
      Replaces(553)=(ToRepl="",ReplWith="")
      Replaces(554)=(ToRepl="",ReplWith="")
      Replaces(555)=(ToRepl="",ReplWith="")
      Replaces(556)=(ToRepl="",ReplWith="")
      Replaces(557)=(ToRepl="",ReplWith="")
      Replaces(558)=(ToRepl="",ReplWith="")
      Replaces(559)=(ToRepl="",ReplWith="")
      Replaces(560)=(ToRepl="",ReplWith="")
      Replaces(561)=(ToRepl="",ReplWith="")
      Replaces(562)=(ToRepl="",ReplWith="")
      Replaces(563)=(ToRepl="",ReplWith="")
      Replaces(564)=(ToRepl="",ReplWith="")
      Replaces(565)=(ToRepl="",ReplWith="")
      Replaces(566)=(ToRepl="",ReplWith="")
      Replaces(567)=(ToRepl="",ReplWith="")
      Replaces(568)=(ToRepl="",ReplWith="")
      Replaces(569)=(ToRepl="",ReplWith="")
      Replaces(570)=(ToRepl="",ReplWith="")
      Replaces(571)=(ToRepl="",ReplWith="")
      Replaces(572)=(ToRepl="",ReplWith="")
      Replaces(573)=(ToRepl="",ReplWith="")
      Replaces(574)=(ToRepl="",ReplWith="")
      Replaces(575)=(ToRepl="",ReplWith="")
      Replaces(576)=(ToRepl="",ReplWith="")
      Replaces(577)=(ToRepl="",ReplWith="")
      Replaces(578)=(ToRepl="",ReplWith="")
      Replaces(579)=(ToRepl="",ReplWith="")
      Replaces(580)=(ToRepl="",ReplWith="")
      Replaces(581)=(ToRepl="",ReplWith="")
      Replaces(582)=(ToRepl="",ReplWith="")
      Replaces(583)=(ToRepl="",ReplWith="")
      Replaces(584)=(ToRepl="",ReplWith="")
      Replaces(585)=(ToRepl="",ReplWith="")
      Replaces(586)=(ToRepl="",ReplWith="")
      Replaces(587)=(ToRepl="",ReplWith="")
      Replaces(588)=(ToRepl="",ReplWith="")
      Replaces(589)=(ToRepl="",ReplWith="")
      Replaces(590)=(ToRepl="",ReplWith="")
      Replaces(591)=(ToRepl="",ReplWith="")
      Replaces(592)=(ToRepl="",ReplWith="")
      Replaces(593)=(ToRepl="",ReplWith="")
      Replaces(594)=(ToRepl="",ReplWith="")
      Replaces(595)=(ToRepl="",ReplWith="")
      Replaces(596)=(ToRepl="",ReplWith="")
      Replaces(597)=(ToRepl="",ReplWith="")
      Replaces(598)=(ToRepl="",ReplWith="")
      Replaces(599)=(ToRepl="",ReplWith="")
      Replaces(600)=(ToRepl="",ReplWith="")
      Replaces(601)=(ToRepl="",ReplWith="")
      Replaces(602)=(ToRepl="",ReplWith="")
      Replaces(603)=(ToRepl="",ReplWith="")
      Replaces(604)=(ToRepl="",ReplWith="")
      Replaces(605)=(ToRepl="",ReplWith="")
      Replaces(606)=(ToRepl="",ReplWith="")
      Replaces(607)=(ToRepl="",ReplWith="")
      Replaces(608)=(ToRepl="",ReplWith="")
      Replaces(609)=(ToRepl="",ReplWith="")
      Replaces(610)=(ToRepl="",ReplWith="")
      Replaces(611)=(ToRepl="",ReplWith="")
      Replaces(612)=(ToRepl="",ReplWith="")
      Replaces(613)=(ToRepl="",ReplWith="")
      Replaces(614)=(ToRepl="",ReplWith="")
      Replaces(615)=(ToRepl="",ReplWith="")
      Replaces(616)=(ToRepl="",ReplWith="")
      Replaces(617)=(ToRepl="",ReplWith="")
      Replaces(618)=(ToRepl="",ReplWith="")
      Replaces(619)=(ToRepl="",ReplWith="")
      Replaces(620)=(ToRepl="",ReplWith="")
      Replaces(621)=(ToRepl="",ReplWith="")
      Replaces(622)=(ToRepl="",ReplWith="")
      Replaces(623)=(ToRepl="",ReplWith="")
      Replaces(624)=(ToRepl="",ReplWith="")
      Replaces(625)=(ToRepl="",ReplWith="")
      Replaces(626)=(ToRepl="",ReplWith="")
      Replaces(627)=(ToRepl="",ReplWith="")
      Replaces(628)=(ToRepl="",ReplWith="")
      Replaces(629)=(ToRepl="",ReplWith="")
      Replaces(630)=(ToRepl="",ReplWith="")
      Replaces(631)=(ToRepl="",ReplWith="")
      Replaces(632)=(ToRepl="",ReplWith="")
      Replaces(633)=(ToRepl="",ReplWith="")
      Replaces(634)=(ToRepl="",ReplWith="")
      Replaces(635)=(ToRepl="",ReplWith="")
      Replaces(636)=(ToRepl="",ReplWith="")
      Replaces(637)=(ToRepl="",ReplWith="")
      Replaces(638)=(ToRepl="",ReplWith="")
      Replaces(639)=(ToRepl="",ReplWith="")
      Replaces(640)=(ToRepl="",ReplWith="")
      Replaces(641)=(ToRepl="",ReplWith="")
      Replaces(642)=(ToRepl="",ReplWith="")
      Replaces(643)=(ToRepl="",ReplWith="")
      Replaces(644)=(ToRepl="",ReplWith="")
      Replaces(645)=(ToRepl="",ReplWith="")
      Replaces(646)=(ToRepl="",ReplWith="")
      Replaces(647)=(ToRepl="",ReplWith="")
      Replaces(648)=(ToRepl="",ReplWith="")
      Replaces(649)=(ToRepl="",ReplWith="")
      Replaces(650)=(ToRepl="",ReplWith="")
      Replaces(651)=(ToRepl="",ReplWith="")
      Replaces(652)=(ToRepl="",ReplWith="")
      Replaces(653)=(ToRepl="",ReplWith="")
      Replaces(654)=(ToRepl="",ReplWith="")
      Replaces(655)=(ToRepl="",ReplWith="")
      Replaces(656)=(ToRepl="",ReplWith="")
      Replaces(657)=(ToRepl="",ReplWith="")
      Replaces(658)=(ToRepl="",ReplWith="")
      Replaces(659)=(ToRepl="",ReplWith="")
      Replaces(660)=(ToRepl="",ReplWith="")
      Replaces(661)=(ToRepl="",ReplWith="")
      Replaces(662)=(ToRepl="",ReplWith="")
      Replaces(663)=(ToRepl="",ReplWith="")
      Replaces(664)=(ToRepl="",ReplWith="")
      Replaces(665)=(ToRepl="",ReplWith="")
      Replaces(666)=(ToRepl="",ReplWith="")
      Replaces(667)=(ToRepl="",ReplWith="")
      Replaces(668)=(ToRepl="",ReplWith="")
      Replaces(669)=(ToRepl="",ReplWith="")
      Replaces(670)=(ToRepl="",ReplWith="")
      Replaces(671)=(ToRepl="",ReplWith="")
      Replaces(672)=(ToRepl="",ReplWith="")
      Replaces(673)=(ToRepl="",ReplWith="")
      Replaces(674)=(ToRepl="",ReplWith="")
      Replaces(675)=(ToRepl="",ReplWith="")
      Replaces(676)=(ToRepl="",ReplWith="")
      Replaces(677)=(ToRepl="",ReplWith="")
      Replaces(678)=(ToRepl="",ReplWith="")
      Replaces(679)=(ToRepl="",ReplWith="")
      Replaces(680)=(ToRepl="",ReplWith="")
      Replaces(681)=(ToRepl="",ReplWith="")
      Replaces(682)=(ToRepl="",ReplWith="")
      Replaces(683)=(ToRepl="",ReplWith="")
      Replaces(684)=(ToRepl="",ReplWith="")
      Replaces(685)=(ToRepl="",ReplWith="")
      Replaces(686)=(ToRepl="",ReplWith="")
      Replaces(687)=(ToRepl="",ReplWith="")
      Replaces(688)=(ToRepl="",ReplWith="")
      Replaces(689)=(ToRepl="",ReplWith="")
      Replaces(690)=(ToRepl="",ReplWith="")
      Replaces(691)=(ToRepl="",ReplWith="")
      Replaces(692)=(ToRepl="",ReplWith="")
      Replaces(693)=(ToRepl="",ReplWith="")
      Replaces(694)=(ToRepl="",ReplWith="")
      Replaces(695)=(ToRepl="",ReplWith="")
      Replaces(696)=(ToRepl="",ReplWith="")
      Replaces(697)=(ToRepl="",ReplWith="")
      Replaces(698)=(ToRepl="",ReplWith="")
      Replaces(699)=(ToRepl="",ReplWith="")
      Replaces(700)=(ToRepl="",ReplWith="")
      Replaces(701)=(ToRepl="",ReplWith="")
      Replaces(702)=(ToRepl="",ReplWith="")
      Replaces(703)=(ToRepl="",ReplWith="")
      Replaces(704)=(ToRepl="",ReplWith="")
      Replaces(705)=(ToRepl="",ReplWith="")
      Replaces(706)=(ToRepl="",ReplWith="")
      Replaces(707)=(ToRepl="",ReplWith="")
      Replaces(708)=(ToRepl="",ReplWith="")
      Replaces(709)=(ToRepl="",ReplWith="")
      Replaces(710)=(ToRepl="",ReplWith="")
      Replaces(711)=(ToRepl="",ReplWith="")
      Replaces(712)=(ToRepl="",ReplWith="")
      Replaces(713)=(ToRepl="",ReplWith="")
      Replaces(714)=(ToRepl="",ReplWith="")
      Replaces(715)=(ToRepl="",ReplWith="")
      Replaces(716)=(ToRepl="",ReplWith="")
      Replaces(717)=(ToRepl="",ReplWith="")
      Replaces(718)=(ToRepl="",ReplWith="")
      Replaces(719)=(ToRepl="",ReplWith="")
      Replaces(720)=(ToRepl="",ReplWith="")
      Replaces(721)=(ToRepl="",ReplWith="")
      Replaces(722)=(ToRepl="",ReplWith="")
      Replaces(723)=(ToRepl="",ReplWith="")
      Replaces(724)=(ToRepl="",ReplWith="")
      Replaces(725)=(ToRepl="",ReplWith="")
      Replaces(726)=(ToRepl="",ReplWith="")
      Replaces(727)=(ToRepl="",ReplWith="")
      Replaces(728)=(ToRepl="",ReplWith="")
      Replaces(729)=(ToRepl="",ReplWith="")
      Replaces(730)=(ToRepl="",ReplWith="")
      Replaces(731)=(ToRepl="",ReplWith="")
      Replaces(732)=(ToRepl="",ReplWith="")
      Replaces(733)=(ToRepl="",ReplWith="")
      Replaces(734)=(ToRepl="",ReplWith="")
      Replaces(735)=(ToRepl="",ReplWith="")
      Replaces(736)=(ToRepl="",ReplWith="")
      Replaces(737)=(ToRepl="",ReplWith="")
      Replaces(738)=(ToRepl="",ReplWith="")
      Replaces(739)=(ToRepl="",ReplWith="")
      Replaces(740)=(ToRepl="",ReplWith="")
      Replaces(741)=(ToRepl="",ReplWith="")
      Replaces(742)=(ToRepl="",ReplWith="")
      Replaces(743)=(ToRepl="",ReplWith="")
      Replaces(744)=(ToRepl="",ReplWith="")
      Replaces(745)=(ToRepl="",ReplWith="")
      Replaces(746)=(ToRepl="",ReplWith="")
      Replaces(747)=(ToRepl="",ReplWith="")
      Replaces(748)=(ToRepl="",ReplWith="")
      Replaces(749)=(ToRepl="",ReplWith="")
      Replaces(750)=(ToRepl="",ReplWith="")
      Replaces(751)=(ToRepl="",ReplWith="")
      Replaces(752)=(ToRepl="",ReplWith="")
      Replaces(753)=(ToRepl="",ReplWith="")
      Replaces(754)=(ToRepl="",ReplWith="")
      Replaces(755)=(ToRepl="",ReplWith="")
      Replaces(756)=(ToRepl="",ReplWith="")
      Replaces(757)=(ToRepl="",ReplWith="")
      Replaces(758)=(ToRepl="",ReplWith="")
      Replaces(759)=(ToRepl="",ReplWith="")
      Replaces(760)=(ToRepl="",ReplWith="")
      Replaces(761)=(ToRepl="",ReplWith="")
      Replaces(762)=(ToRepl="",ReplWith="")
      Replaces(763)=(ToRepl="",ReplWith="")
      Replaces(764)=(ToRepl="",ReplWith="")
      Replaces(765)=(ToRepl="",ReplWith="")
      Replaces(766)=(ToRepl="",ReplWith="")
      Replaces(767)=(ToRepl="",ReplWith="")
      Replaces(768)=(ToRepl="",ReplWith="")
      Replaces(769)=(ToRepl="",ReplWith="")
      Replaces(770)=(ToRepl="",ReplWith="")
      Replaces(771)=(ToRepl="",ReplWith="")
      Replaces(772)=(ToRepl="",ReplWith="")
      Replaces(773)=(ToRepl="",ReplWith="")
      Replaces(774)=(ToRepl="",ReplWith="")
      Replaces(775)=(ToRepl="",ReplWith="")
      Replaces(776)=(ToRepl="",ReplWith="")
      Replaces(777)=(ToRepl="",ReplWith="")
      Replaces(778)=(ToRepl="",ReplWith="")
      Replaces(779)=(ToRepl="",ReplWith="")
      Replaces(780)=(ToRepl="",ReplWith="")
      Replaces(781)=(ToRepl="",ReplWith="")
      Replaces(782)=(ToRepl="",ReplWith="")
      Replaces(783)=(ToRepl="",ReplWith="")
      Replaces(784)=(ToRepl="",ReplWith="")
      Replaces(785)=(ToRepl="",ReplWith="")
      Replaces(786)=(ToRepl="",ReplWith="")
      Replaces(787)=(ToRepl="",ReplWith="")
      Replaces(788)=(ToRepl="",ReplWith="")
      Replaces(789)=(ToRepl="",ReplWith="")
      Replaces(790)=(ToRepl="",ReplWith="")
      Replaces(791)=(ToRepl="",ReplWith="")
      Replaces(792)=(ToRepl="",ReplWith="")
      Replaces(793)=(ToRepl="",ReplWith="")
      Replaces(794)=(ToRepl="",ReplWith="")
      Replaces(795)=(ToRepl="",ReplWith="")
      Replaces(796)=(ToRepl="",ReplWith="")
      Replaces(797)=(ToRepl="",ReplWith="")
      Replaces(798)=(ToRepl="",ReplWith="")
      Replaces(799)=(ToRepl="",ReplWith="")
      Replaces(800)=(ToRepl="",ReplWith="")
      Replaces(801)=(ToRepl="",ReplWith="")
      Replaces(802)=(ToRepl="",ReplWith="")
      Replaces(803)=(ToRepl="",ReplWith="")
      Replaces(804)=(ToRepl="",ReplWith="")
      Replaces(805)=(ToRepl="",ReplWith="")
      Replaces(806)=(ToRepl="",ReplWith="")
      Replaces(807)=(ToRepl="",ReplWith="")
      Replaces(808)=(ToRepl="",ReplWith="")
      Replaces(809)=(ToRepl="",ReplWith="")
      Replaces(810)=(ToRepl="",ReplWith="")
      Replaces(811)=(ToRepl="",ReplWith="")
      Replaces(812)=(ToRepl="",ReplWith="")
      Replaces(813)=(ToRepl="",ReplWith="")
      Replaces(814)=(ToRepl="",ReplWith="")
      Replaces(815)=(ToRepl="",ReplWith="")
      Replaces(816)=(ToRepl="",ReplWith="")
      Replaces(817)=(ToRepl="",ReplWith="")
      Replaces(818)=(ToRepl="",ReplWith="")
      Replaces(819)=(ToRepl="",ReplWith="")
      Replaces(820)=(ToRepl="",ReplWith="")
      Replaces(821)=(ToRepl="",ReplWith="")
      Replaces(822)=(ToRepl="",ReplWith="")
      Replaces(823)=(ToRepl="",ReplWith="")
      Replaces(824)=(ToRepl="",ReplWith="")
      Replaces(825)=(ToRepl="",ReplWith="")
      Replaces(826)=(ToRepl="",ReplWith="")
      Replaces(827)=(ToRepl="",ReplWith="")
      Replaces(828)=(ToRepl="",ReplWith="")
      Replaces(829)=(ToRepl="",ReplWith="")
      Replaces(830)=(ToRepl="",ReplWith="")
      Replaces(831)=(ToRepl="",ReplWith="")
      Replaces(832)=(ToRepl="",ReplWith="")
      Replaces(833)=(ToRepl="",ReplWith="")
      Replaces(834)=(ToRepl="",ReplWith="")
      Replaces(835)=(ToRepl="",ReplWith="")
      Replaces(836)=(ToRepl="",ReplWith="")
      Replaces(837)=(ToRepl="",ReplWith="")
      Replaces(838)=(ToRepl="",ReplWith="")
      Replaces(839)=(ToRepl="",ReplWith="")
      Replaces(840)=(ToRepl="",ReplWith="")
      Replaces(841)=(ToRepl="",ReplWith="")
      Replaces(842)=(ToRepl="",ReplWith="")
      Replaces(843)=(ToRepl="",ReplWith="")
      Replaces(844)=(ToRepl="",ReplWith="")
      Replaces(845)=(ToRepl="",ReplWith="")
      Replaces(846)=(ToRepl="",ReplWith="")
      Replaces(847)=(ToRepl="",ReplWith="")
      Replaces(848)=(ToRepl="",ReplWith="")
      Replaces(849)=(ToRepl="",ReplWith="")
      Replaces(850)=(ToRepl="",ReplWith="")
      Replaces(851)=(ToRepl="",ReplWith="")
      Replaces(852)=(ToRepl="",ReplWith="")
      Replaces(853)=(ToRepl="",ReplWith="")
      Replaces(854)=(ToRepl="",ReplWith="")
      Replaces(855)=(ToRepl="",ReplWith="")
      Replaces(856)=(ToRepl="",ReplWith="")
      Replaces(857)=(ToRepl="",ReplWith="")
      Replaces(858)=(ToRepl="",ReplWith="")
      Replaces(859)=(ToRepl="",ReplWith="")
      Replaces(860)=(ToRepl="",ReplWith="")
      Replaces(861)=(ToRepl="",ReplWith="")
      Replaces(862)=(ToRepl="",ReplWith="")
      Replaces(863)=(ToRepl="",ReplWith="")
      Replaces(864)=(ToRepl="",ReplWith="")
      Replaces(865)=(ToRepl="",ReplWith="")
      Replaces(866)=(ToRepl="",ReplWith="")
      Replaces(867)=(ToRepl="",ReplWith="")
      Replaces(868)=(ToRepl="",ReplWith="")
      Replaces(869)=(ToRepl="",ReplWith="")
      Replaces(870)=(ToRepl="",ReplWith="")
      Replaces(871)=(ToRepl="",ReplWith="")
      Replaces(872)=(ToRepl="",ReplWith="")
      Replaces(873)=(ToRepl="",ReplWith="")
      Replaces(874)=(ToRepl="",ReplWith="")
      Replaces(875)=(ToRepl="",ReplWith="")
      Replaces(876)=(ToRepl="",ReplWith="")
      Replaces(877)=(ToRepl="",ReplWith="")
      Replaces(878)=(ToRepl="",ReplWith="")
      Replaces(879)=(ToRepl="",ReplWith="")
      Replaces(880)=(ToRepl="",ReplWith="")
      Replaces(881)=(ToRepl="",ReplWith="")
      Replaces(882)=(ToRepl="",ReplWith="")
      Replaces(883)=(ToRepl="",ReplWith="")
      Replaces(884)=(ToRepl="",ReplWith="")
      Replaces(885)=(ToRepl="",ReplWith="")
      Replaces(886)=(ToRepl="",ReplWith="")
      Replaces(887)=(ToRepl="",ReplWith="")
      Replaces(888)=(ToRepl="",ReplWith="")
      Replaces(889)=(ToRepl="",ReplWith="")
      Replaces(890)=(ToRepl="",ReplWith="")
      Replaces(891)=(ToRepl="",ReplWith="")
      Replaces(892)=(ToRepl="",ReplWith="")
      Replaces(893)=(ToRepl="",ReplWith="")
      Replaces(894)=(ToRepl="",ReplWith="")
      Replaces(895)=(ToRepl="",ReplWith="")
      Replaces(896)=(ToRepl="",ReplWith="")
      Replaces(897)=(ToRepl="",ReplWith="")
      Replaces(898)=(ToRepl="",ReplWith="")
      Replaces(899)=(ToRepl="",ReplWith="")
      Replaces(900)=(ToRepl="",ReplWith="")
      Replaces(901)=(ToRepl="",ReplWith="")
      Replaces(902)=(ToRepl="",ReplWith="")
      Replaces(903)=(ToRepl="",ReplWith="")
      Replaces(904)=(ToRepl="",ReplWith="")
      Replaces(905)=(ToRepl="",ReplWith="")
      Replaces(906)=(ToRepl="",ReplWith="")
      Replaces(907)=(ToRepl="",ReplWith="")
      Replaces(908)=(ToRepl="",ReplWith="")
      Replaces(909)=(ToRepl="",ReplWith="")
      Replaces(910)=(ToRepl="",ReplWith="")
      Replaces(911)=(ToRepl="",ReplWith="")
      Replaces(912)=(ToRepl="",ReplWith="")
      Replaces(913)=(ToRepl="",ReplWith="")
      Replaces(914)=(ToRepl="",ReplWith="")
      Replaces(915)=(ToRepl="",ReplWith="")
      Replaces(916)=(ToRepl="",ReplWith="")
      Replaces(917)=(ToRepl="",ReplWith="")
      Replaces(918)=(ToRepl="",ReplWith="")
      Replaces(919)=(ToRepl="",ReplWith="")
      Replaces(920)=(ToRepl="",ReplWith="")
      Replaces(921)=(ToRepl="",ReplWith="")
      Replaces(922)=(ToRepl="",ReplWith="")
      Replaces(923)=(ToRepl="",ReplWith="")
      Replaces(924)=(ToRepl="",ReplWith="")
      Replaces(925)=(ToRepl="",ReplWith="")
      Replaces(926)=(ToRepl="",ReplWith="")
      Replaces(927)=(ToRepl="",ReplWith="")
      Replaces(928)=(ToRepl="",ReplWith="")
      Replaces(929)=(ToRepl="",ReplWith="")
      Replaces(930)=(ToRepl="",ReplWith="")
      Replaces(931)=(ToRepl="",ReplWith="")
      Replaces(932)=(ToRepl="",ReplWith="")
      Replaces(933)=(ToRepl="",ReplWith="")
      Replaces(934)=(ToRepl="",ReplWith="")
      Replaces(935)=(ToRepl="",ReplWith="")
      Replaces(936)=(ToRepl="",ReplWith="")
      Replaces(937)=(ToRepl="",ReplWith="")
      Replaces(938)=(ToRepl="",ReplWith="")
      Replaces(939)=(ToRepl="",ReplWith="")
      Replaces(940)=(ToRepl="",ReplWith="")
      Replaces(941)=(ToRepl="",ReplWith="")
      Replaces(942)=(ToRepl="",ReplWith="")
      Replaces(943)=(ToRepl="",ReplWith="")
      Replaces(944)=(ToRepl="",ReplWith="")
      Replaces(945)=(ToRepl="",ReplWith="")
      Replaces(946)=(ToRepl="",ReplWith="")
      Replaces(947)=(ToRepl="",ReplWith="")
      Replaces(948)=(ToRepl="",ReplWith="")
      Replaces(949)=(ToRepl="",ReplWith="")
      Replaces(950)=(ToRepl="",ReplWith="")
      Replaces(951)=(ToRepl="",ReplWith="")
      Replaces(952)=(ToRepl="",ReplWith="")
      Replaces(953)=(ToRepl="",ReplWith="")
      Replaces(954)=(ToRepl="",ReplWith="")
      Replaces(955)=(ToRepl="",ReplWith="")
      Replaces(956)=(ToRepl="",ReplWith="")
      Replaces(957)=(ToRepl="",ReplWith="")
      Replaces(958)=(ToRepl="",ReplWith="")
      Replaces(959)=(ToRepl="",ReplWith="")
      Replaces(960)=(ToRepl="",ReplWith="")
      Replaces(961)=(ToRepl="",ReplWith="")
      Replaces(962)=(ToRepl="",ReplWith="")
      Replaces(963)=(ToRepl="",ReplWith="")
      Replaces(964)=(ToRepl="",ReplWith="")
      Replaces(965)=(ToRepl="",ReplWith="")
      Replaces(966)=(ToRepl="",ReplWith="")
      Replaces(967)=(ToRepl="",ReplWith="")
      Replaces(968)=(ToRepl="",ReplWith="")
      Replaces(969)=(ToRepl="",ReplWith="")
      Replaces(970)=(ToRepl="",ReplWith="")
      Replaces(971)=(ToRepl="",ReplWith="")
      Replaces(972)=(ToRepl="",ReplWith="")
      Replaces(973)=(ToRepl="",ReplWith="")
      Replaces(974)=(ToRepl="",ReplWith="")
      Replaces(975)=(ToRepl="",ReplWith="")
      Replaces(976)=(ToRepl="",ReplWith="")
      Replaces(977)=(ToRepl="",ReplWith="")
      Replaces(978)=(ToRepl="",ReplWith="")
      Replaces(979)=(ToRepl="",ReplWith="")
      Replaces(980)=(ToRepl="",ReplWith="")
      Replaces(981)=(ToRepl="",ReplWith="")
      Replaces(982)=(ToRepl="",ReplWith="")
      Replaces(983)=(ToRepl="",ReplWith="")
      Replaces(984)=(ToRepl="",ReplWith="")
      Replaces(985)=(ToRepl="",ReplWith="")
      Replaces(986)=(ToRepl="",ReplWith="")
      Replaces(987)=(ToRepl="",ReplWith="")
      Replaces(988)=(ToRepl="",ReplWith="")
      Replaces(989)=(ToRepl="",ReplWith="")
      Replaces(990)=(ToRepl="",ReplWith="")
      Replaces(991)=(ToRepl="",ReplWith="")
      Replaces(992)=(ToRepl="",ReplWith="")
      Replaces(993)=(ToRepl="",ReplWith="")
      Replaces(994)=(ToRepl="",ReplWith="")
      Replaces(995)=(ToRepl="",ReplWith="")
      Replaces(996)=(ToRepl="",ReplWith="")
      Replaces(997)=(ToRepl="",ReplWith="")
      Replaces(998)=(ToRepl="",ReplWith="")
      Replaces(999)=(ToRepl="",ReplWith="")
      bMySc=False
      bDAllMarks=False
      DoSIp=""
      bViewMe=False
      bLockTarget=False
      bDoCheat=False
      bTeamGame=True
      Target=None
      pred=1.000000
      MyDot=0.000000
      Vps(0)=(On=False,X=100.000000,Y=250.000000,W=150.000000,H=100.000000,M=2.000000,MC=(R=128,G=128,B=255,A=0),CC=(R=255,G=128,B=128,A=0),MyA=None)
      Vps(1)=(On=False,X=0.000000,Y=0.000000,W=0.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      Vps(2)=(On=False,X=0.000000,Y=0.000000,W=0.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      Vps(3)=(On=False,X=0.000000,Y=0.000000,W=0.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      Vps(4)=(On=False,X=0.000000,Y=0.000000,W=0.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      Vps(5)=(On=False,X=0.000000,Y=0.000000,W=0.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      Vps(6)=(On=False,X=0.000000,Y=0.000000,W=0.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      Vps(7)=(On=False,X=250.000000,Y=150.000000,W=150.000000,H=0.000000,M=0.000000,MC=(R=0,G=0,B=0,A=0),CC=(R=0,G=0,B=0,A=0),MyA=None)
      MySb=None
      TFade=0.000000
      TObj=None
      NegDelta=0.000000
      MyBot=None
      bGui=False
      MouseX=0.000000
      MouseY=0.000000
      LHeld=False
      RHeld=False
      bHide=False
      NVSL=False
      NumNV=0
      brhack=False
      DeltaMul=0.000000
      RDelay=0
      bShowTM=False
      ColorTheme="g"
      CBWarn=True
      TBWarn=True
      DPL(0)=(Prog=None,Link="")
      DPL(1)=(Prog=None,Link="")
      DPL(2)=(Prog=None,Link="")
      DPL(3)=(Prog=None,Link="")
      DPL(4)=(Prog=None,Link="")
      DPL(5)=(Prog=None,Link="")
      DPL(6)=(Prog=None,Link="")
      DPL(7)=(Prog=None,Link="")
      DPL(8)=(Prog=None,Link="")
      DPL(9)=(Prog=None,Link="")
      DPL(10)=(Prog=None,Link="")
      DPL(11)=(Prog=None,Link="")
      DPL(12)=(Prog=None,Link="")
      DPL(13)=(Prog=None,Link="")
      DPL(14)=(Prog=None,Link="")
      DPL(15)=(Prog=None,Link="")
      DPL(16)=(Prog=None,Link="")
      DPL(17)=(Prog=None,Link="")
      DPL(18)=(Prog=None,Link="")
      DPL(19)=(Prog=None,Link="")
      DPL(20)=(Prog=None,Link="")
      DPL(21)=(Prog=None,Link="")
      DPL(22)=(Prog=None,Link="")
      DPL(23)=(Prog=None,Link="")
      DPL(24)=(Prog=None,Link="")
      DPL(25)=(Prog=None,Link="")
      DPL(26)=(Prog=None,Link="")
      DPL(27)=(Prog=None,Link="")
      DPL(28)=(Prog=None,Link="")
      DPL(29)=(Prog=None,Link="")
      DPL(30)=(Prog=None,Link="")
      DPL(31)=(Prog=None,Link="")
      DPL(32)=(Prog=None,Link="")
      DPL(33)=(Prog=None,Link="")
      DPL(34)=(Prog=None,Link="")
      DPL(35)=(Prog=None,Link="")
      DPL(36)=(Prog=None,Link="")
      DPL(37)=(Prog=None,Link="")
      DPL(38)=(Prog=None,Link="")
      DPL(39)=(Prog=None,Link="")
      DPL(40)=(Prog=None,Link="")
      DPL(41)=(Prog=None,Link="")
      DPL(42)=(Prog=None,Link="")
      DPL(43)=(Prog=None,Link="")
      DPL(44)=(Prog=None,Link="")
      DPL(45)=(Prog=None,Link="")
      DPL(46)=(Prog=None,Link="")
      DPL(47)=(Prog=None,Link="")
      DPL(48)=(Prog=None,Link="")
      DPL(49)=(Prog=None,Link="")
      DPL(50)=(Prog=None,Link="")
      DPL(51)=(Prog=None,Link="")
      DPL(52)=(Prog=None,Link="")
      DPL(53)=(Prog=None,Link="")
      DPL(54)=(Prog=None,Link="")
      DPL(55)=(Prog=None,Link="")
      DPL(56)=(Prog=None,Link="")
      DPL(57)=(Prog=None,Link="")
      DPL(58)=(Prog=None,Link="")
      DPL(59)=(Prog=None,Link="")
      DPL(60)=(Prog=None,Link="")
      DPL(61)=(Prog=None,Link="")
      DPL(62)=(Prog=None,Link="")
      DPL(63)=(Prog=None,Link="")
      DPL(64)=(Prog=None,Link="")
      DPL(65)=(Prog=None,Link="")
      DPL(66)=(Prog=None,Link="")
      DPL(67)=(Prog=None,Link="")
      DPL(68)=(Prog=None,Link="")
      DPL(69)=(Prog=None,Link="")
      DPL(70)=(Prog=None,Link="")
      DPL(71)=(Prog=None,Link="")
      DPL(72)=(Prog=None,Link="")
      DPL(73)=(Prog=None,Link="")
      DPL(74)=(Prog=None,Link="")
      DPL(75)=(Prog=None,Link="")
      DPL(76)=(Prog=None,Link="")
      DPL(77)=(Prog=None,Link="")
      DPL(78)=(Prog=None,Link="")
      DPL(79)=(Prog=None,Link="")
      DPL(80)=(Prog=None,Link="")
      DPL(81)=(Prog=None,Link="")
      DPL(82)=(Prog=None,Link="")
      DPL(83)=(Prog=None,Link="")
      DPL(84)=(Prog=None,Link="")
      DPL(85)=(Prog=None,Link="")
      DPL(86)=(Prog=None,Link="")
      DPL(87)=(Prog=None,Link="")
      DPL(88)=(Prog=None,Link="")
      DPL(89)=(Prog=None,Link="")
      DPL(90)=(Prog=None,Link="")
      DPL(91)=(Prog=None,Link="")
      DPL(92)=(Prog=None,Link="")
      DPL(93)=(Prog=None,Link="")
      DPL(94)=(Prog=None,Link="")
      DPL(95)=(Prog=None,Link="")
      DPL(96)=(Prog=None,Link="")
      DPL(97)=(Prog=None,Link="")
      DPL(98)=(Prog=None,Link="")
      DPL(99)=(Prog=None,Link="")
      DPL(100)=(Prog=None,Link="")
      DPL(101)=(Prog=None,Link="")
      DPL(102)=(Prog=None,Link="")
      DPL(103)=(Prog=None,Link="")
      DPL(104)=(Prog=None,Link="")
      DPL(105)=(Prog=None,Link="")
      DPL(106)=(Prog=None,Link="")
      DPL(107)=(Prog=None,Link="")
      DPL(108)=(Prog=None,Link="")
      DPL(109)=(Prog=None,Link="")
      DPL(110)=(Prog=None,Link="")
      DPL(111)=(Prog=None,Link="")
      DPL(112)=(Prog=None,Link="")
      DPL(113)=(Prog=None,Link="")
      DPL(114)=(Prog=None,Link="")
      DPL(115)=(Prog=None,Link="")
      DPL(116)=(Prog=None,Link="")
      DPL(117)=(Prog=None,Link="")
      DPL(118)=(Prog=None,Link="")
      DPL(119)=(Prog=None,Link="")
      DPL(120)=(Prog=None,Link="")
      DPL(121)=(Prog=None,Link="")
      DPL(122)=(Prog=None,Link="")
      DPL(123)=(Prog=None,Link="")
      DPL(124)=(Prog=None,Link="")
      DPL(125)=(Prog=None,Link="")
      DPL(126)=(Prog=None,Link="")
      DPL(127)=(Prog=None,Link="")
      DPL(128)=(Prog=None,Link="")
      DPL(129)=(Prog=None,Link="")
      DPL(130)=(Prog=None,Link="")
      DPL(131)=(Prog=None,Link="")
      DPL(132)=(Prog=None,Link="")
      DPL(133)=(Prog=None,Link="")
      DPL(134)=(Prog=None,Link="")
      DPL(135)=(Prog=None,Link="")
      DPL(136)=(Prog=None,Link="")
      DPL(137)=(Prog=None,Link="")
      DPL(138)=(Prog=None,Link="")
      DPL(139)=(Prog=None,Link="")
      DPL(140)=(Prog=None,Link="")
      DPL(141)=(Prog=None,Link="")
      DPL(142)=(Prog=None,Link="")
      DPL(143)=(Prog=None,Link="")
      DPL(144)=(Prog=None,Link="")
      DPL(145)=(Prog=None,Link="")
      DPL(146)=(Prog=None,Link="")
      DPL(147)=(Prog=None,Link="")
      DPL(148)=(Prog=None,Link="")
      DPL(149)=(Prog=None,Link="")
      DPL(150)=(Prog=None,Link="")
      DPL(151)=(Prog=None,Link="")
      DPL(152)=(Prog=None,Link="")
      DPL(153)=(Prog=None,Link="")
      DPL(154)=(Prog=None,Link="")
      DPL(155)=(Prog=None,Link="")
      DPL(156)=(Prog=None,Link="")
      DPL(157)=(Prog=None,Link="")
      DPL(158)=(Prog=None,Link="")
      DPL(159)=(Prog=None,Link="")
      DPL(160)=(Prog=None,Link="")
      DPL(161)=(Prog=None,Link="")
      DPL(162)=(Prog=None,Link="")
      DPL(163)=(Prog=None,Link="")
      DPL(164)=(Prog=None,Link="")
      DPL(165)=(Prog=None,Link="")
      DPL(166)=(Prog=None,Link="")
      DPL(167)=(Prog=None,Link="")
      DPL(168)=(Prog=None,Link="")
      DPL(169)=(Prog=None,Link="")
      DPL(170)=(Prog=None,Link="")
      DPL(171)=(Prog=None,Link="")
      DPL(172)=(Prog=None,Link="")
      DPL(173)=(Prog=None,Link="")
      DPL(174)=(Prog=None,Link="")
      DPL(175)=(Prog=None,Link="")
      DPL(176)=(Prog=None,Link="")
      DPL(177)=(Prog=None,Link="")
      DPL(178)=(Prog=None,Link="")
      DPL(179)=(Prog=None,Link="")
      DPL(180)=(Prog=None,Link="")
      DPL(181)=(Prog=None,Link="")
      DPL(182)=(Prog=None,Link="")
      DPL(183)=(Prog=None,Link="")
      DPL(184)=(Prog=None,Link="")
      DPL(185)=(Prog=None,Link="")
      DPL(186)=(Prog=None,Link="")
      DPL(187)=(Prog=None,Link="")
      DPL(188)=(Prog=None,Link="")
      DPL(189)=(Prog=None,Link="")
      DPL(190)=(Prog=None,Link="")
      DPL(191)=(Prog=None,Link="")
      DPL(192)=(Prog=None,Link="")
      DPL(193)=(Prog=None,Link="")
      DPL(194)=(Prog=None,Link="")
      DPL(195)=(Prog=None,Link="")
      DPL(196)=(Prog=None,Link="")
      DPL(197)=(Prog=None,Link="")
      DPL(198)=(Prog=None,Link="")
      DPL(199)=(Prog=None,Link="")
      DPL(200)=(Prog=None,Link="")
      DPL(201)=(Prog=None,Link="")
      DPL(202)=(Prog=None,Link="")
      DPL(203)=(Prog=None,Link="")
      DPL(204)=(Prog=None,Link="")
      DPL(205)=(Prog=None,Link="")
      DPL(206)=(Prog=None,Link="")
      DPL(207)=(Prog=None,Link="")
      DPL(208)=(Prog=None,Link="")
      DPL(209)=(Prog=None,Link="")
      DPL(210)=(Prog=None,Link="")
      DPL(211)=(Prog=None,Link="")
      DPL(212)=(Prog=None,Link="")
      DPL(213)=(Prog=None,Link="")
      DPL(214)=(Prog=None,Link="")
      DPL(215)=(Prog=None,Link="")
      DPL(216)=(Prog=None,Link="")
      DPL(217)=(Prog=None,Link="")
      DPL(218)=(Prog=None,Link="")
      DPL(219)=(Prog=None,Link="")
      DPL(220)=(Prog=None,Link="")
      DPL(221)=(Prog=None,Link="")
      DPL(222)=(Prog=None,Link="")
      DPL(223)=(Prog=None,Link="")
      DPL(224)=(Prog=None,Link="")
      DPL(225)=(Prog=None,Link="")
      DPL(226)=(Prog=None,Link="")
      DPL(227)=(Prog=None,Link="")
      DPL(228)=(Prog=None,Link="")
      DPL(229)=(Prog=None,Link="")
      DPL(230)=(Prog=None,Link="")
      DPL(231)=(Prog=None,Link="")
      DPL(232)=(Prog=None,Link="")
      DPL(233)=(Prog=None,Link="")
      DPL(234)=(Prog=None,Link="")
      DPL(235)=(Prog=None,Link="")
      DPL(236)=(Prog=None,Link="")
      DPL(237)=(Prog=None,Link="")
      DPL(238)=(Prog=None,Link="")
      DPL(239)=(Prog=None,Link="")
      DPL(240)=(Prog=None,Link="")
      DPL(241)=(Prog=None,Link="")
      DPL(242)=(Prog=None,Link="")
      DPL(243)=(Prog=None,Link="")
      DPL(244)=(Prog=None,Link="")
      DPL(245)=(Prog=None,Link="")
      DPL(246)=(Prog=None,Link="")
      DPL(247)=(Prog=None,Link="")
      DPL(248)=(Prog=None,Link="")
      DPL(249)=(Prog=None,Link="")
      DPL(250)=(Prog=None,Link="")
      DPL(251)=(Prog=None,Link="")
      DPL(252)=(Prog=None,Link="")
      DPL(253)=(Prog=None,Link="")
      DPL(254)=(Prog=None,Link="")
      DPL(255)=(Prog=None,Link="")
      DPL(256)=(Prog=None,Link="")
      DPL(257)=(Prog=None,Link="")
      DPL(258)=(Prog=None,Link="")
      DPL(259)=(Prog=None,Link="")
      DPL(260)=(Prog=None,Link="")
      DPL(261)=(Prog=None,Link="")
      DPL(262)=(Prog=None,Link="")
      DPL(263)=(Prog=None,Link="")
      DPL(264)=(Prog=None,Link="")
      DPL(265)=(Prog=None,Link="")
      DPL(266)=(Prog=None,Link="")
      DPL(267)=(Prog=None,Link="")
      DPL(268)=(Prog=None,Link="")
      DPL(269)=(Prog=None,Link="")
      DPL(270)=(Prog=None,Link="")
      DPL(271)=(Prog=None,Link="")
      DPL(272)=(Prog=None,Link="")
      DPL(273)=(Prog=None,Link="")
      DPL(274)=(Prog=None,Link="")
      DPL(275)=(Prog=None,Link="")
      DPL(276)=(Prog=None,Link="")
      DPL(277)=(Prog=None,Link="")
      DPL(278)=(Prog=None,Link="")
      DPL(279)=(Prog=None,Link="")
      DPL(280)=(Prog=None,Link="")
      DPL(281)=(Prog=None,Link="")
      DPL(282)=(Prog=None,Link="")
      DPL(283)=(Prog=None,Link="")
      DPL(284)=(Prog=None,Link="")
      DPL(285)=(Prog=None,Link="")
      DPL(286)=(Prog=None,Link="")
      DPL(287)=(Prog=None,Link="")
      DPL(288)=(Prog=None,Link="")
      DPL(289)=(Prog=None,Link="")
      DPL(290)=(Prog=None,Link="")
      DPL(291)=(Prog=None,Link="")
      DPL(292)=(Prog=None,Link="")
      DPL(293)=(Prog=None,Link="")
      DPL(294)=(Prog=None,Link="")
      DPL(295)=(Prog=None,Link="")
      DPL(296)=(Prog=None,Link="")
      DPL(297)=(Prog=None,Link="")
      DPL(298)=(Prog=None,Link="")
      DPL(299)=(Prog=None,Link="")
      DPL(300)=(Prog=None,Link="")
      DPL(301)=(Prog=None,Link="")
      DPL(302)=(Prog=None,Link="")
      DPL(303)=(Prog=None,Link="")
      DPL(304)=(Prog=None,Link="")
      DPL(305)=(Prog=None,Link="")
      DPL(306)=(Prog=None,Link="")
      DPL(307)=(Prog=None,Link="")
      DPL(308)=(Prog=None,Link="")
      DPL(309)=(Prog=None,Link="")
      DPL(310)=(Prog=None,Link="")
      DPL(311)=(Prog=None,Link="")
      DPL(312)=(Prog=None,Link="")
      DPL(313)=(Prog=None,Link="")
      DPL(314)=(Prog=None,Link="")
      DPL(315)=(Prog=None,Link="")
      DPL(316)=(Prog=None,Link="")
      DPL(317)=(Prog=None,Link="")
      DPL(318)=(Prog=None,Link="")
      DPL(319)=(Prog=None,Link="")
      DPL(320)=(Prog=None,Link="")
      DPL(321)=(Prog=None,Link="")
      DPL(322)=(Prog=None,Link="")
      DPL(323)=(Prog=None,Link="")
      DPL(324)=(Prog=None,Link="")
      DPL(325)=(Prog=None,Link="")
      DPL(326)=(Prog=None,Link="")
      DPL(327)=(Prog=None,Link="")
      DPL(328)=(Prog=None,Link="")
      DPL(329)=(Prog=None,Link="")
      DPL(330)=(Prog=None,Link="")
      DPL(331)=(Prog=None,Link="")
      DPL(332)=(Prog=None,Link="")
      DPL(333)=(Prog=None,Link="")
      DPL(334)=(Prog=None,Link="")
      DPL(335)=(Prog=None,Link="")
      DPL(336)=(Prog=None,Link="")
      DPL(337)=(Prog=None,Link="")
      DPL(338)=(Prog=None,Link="")
      DPL(339)=(Prog=None,Link="")
      DPL(340)=(Prog=None,Link="")
      DPL(341)=(Prog=None,Link="")
      DPL(342)=(Prog=None,Link="")
      DPL(343)=(Prog=None,Link="")
      DPL(344)=(Prog=None,Link="")
      DPL(345)=(Prog=None,Link="")
      DPL(346)=(Prog=None,Link="")
      DPL(347)=(Prog=None,Link="")
      DPL(348)=(Prog=None,Link="")
      DPL(349)=(Prog=None,Link="")
      DPL(350)=(Prog=None,Link="")
      DPL(351)=(Prog=None,Link="")
      DPL(352)=(Prog=None,Link="")
      DPL(353)=(Prog=None,Link="")
      DPL(354)=(Prog=None,Link="")
      DPL(355)=(Prog=None,Link="")
      DPL(356)=(Prog=None,Link="")
      DPL(357)=(Prog=None,Link="")
      DPL(358)=(Prog=None,Link="")
      DPL(359)=(Prog=None,Link="")
      DPL(360)=(Prog=None,Link="")
      DPL(361)=(Prog=None,Link="")
      DPL(362)=(Prog=None,Link="")
      DPL(363)=(Prog=None,Link="")
      DPL(364)=(Prog=None,Link="")
      DPL(365)=(Prog=None,Link="")
      DPL(366)=(Prog=None,Link="")
      DPL(367)=(Prog=None,Link="")
      DPL(368)=(Prog=None,Link="")
      DPL(369)=(Prog=None,Link="")
      DPL(370)=(Prog=None,Link="")
      DPL(371)=(Prog=None,Link="")
      DPL(372)=(Prog=None,Link="")
      DPL(373)=(Prog=None,Link="")
      DPL(374)=(Prog=None,Link="")
      DPL(375)=(Prog=None,Link="")
      DPL(376)=(Prog=None,Link="")
      DPL(377)=(Prog=None,Link="")
      DPL(378)=(Prog=None,Link="")
      DPL(379)=(Prog=None,Link="")
      DPL(380)=(Prog=None,Link="")
      DPL(381)=(Prog=None,Link="")
      DPL(382)=(Prog=None,Link="")
      DPL(383)=(Prog=None,Link="")
      DPL(384)=(Prog=None,Link="")
      DPL(385)=(Prog=None,Link="")
      DPL(386)=(Prog=None,Link="")
      DPL(387)=(Prog=None,Link="")
      DPL(388)=(Prog=None,Link="")
      DPL(389)=(Prog=None,Link="")
      DPL(390)=(Prog=None,Link="")
      DPL(391)=(Prog=None,Link="")
      DPL(392)=(Prog=None,Link="")
      DPL(393)=(Prog=None,Link="")
      DPL(394)=(Prog=None,Link="")
      DPL(395)=(Prog=None,Link="")
      DPL(396)=(Prog=None,Link="")
      DPL(397)=(Prog=None,Link="")
      DPL(398)=(Prog=None,Link="")
      DPL(399)=(Prog=None,Link="")
      DPL(400)=(Prog=None,Link="")
      DPL(401)=(Prog=None,Link="")
      DPL(402)=(Prog=None,Link="")
      DPL(403)=(Prog=None,Link="")
      DPL(404)=(Prog=None,Link="")
      DPL(405)=(Prog=None,Link="")
      DPL(406)=(Prog=None,Link="")
      DPL(407)=(Prog=None,Link="")
      DPL(408)=(Prog=None,Link="")
      DPL(409)=(Prog=None,Link="")
      DPL(410)=(Prog=None,Link="")
      DPL(411)=(Prog=None,Link="")
      DPL(412)=(Prog=None,Link="")
      DPL(413)=(Prog=None,Link="")
      DPL(414)=(Prog=None,Link="")
      DPL(415)=(Prog=None,Link="")
      DPL(416)=(Prog=None,Link="")
      DPL(417)=(Prog=None,Link="")
      DPL(418)=(Prog=None,Link="")
      DPL(419)=(Prog=None,Link="")
      DPL(420)=(Prog=None,Link="")
      DPL(421)=(Prog=None,Link="")
      DPL(422)=(Prog=None,Link="")
      DPL(423)=(Prog=None,Link="")
      DPL(424)=(Prog=None,Link="")
      DPL(425)=(Prog=None,Link="")
      DPL(426)=(Prog=None,Link="")
      DPL(427)=(Prog=None,Link="")
      DPL(428)=(Prog=None,Link="")
      DPL(429)=(Prog=None,Link="")
      DPL(430)=(Prog=None,Link="")
      DPL(431)=(Prog=None,Link="")
      DPL(432)=(Prog=None,Link="")
      DPL(433)=(Prog=None,Link="")
      DPL(434)=(Prog=None,Link="")
      DPL(435)=(Prog=None,Link="")
      DPL(436)=(Prog=None,Link="")
      DPL(437)=(Prog=None,Link="")
      DPL(438)=(Prog=None,Link="")
      DPL(439)=(Prog=None,Link="")
      DPL(440)=(Prog=None,Link="")
      DPL(441)=(Prog=None,Link="")
      DPL(442)=(Prog=None,Link="")
      DPL(443)=(Prog=None,Link="")
      DPL(444)=(Prog=None,Link="")
      DPL(445)=(Prog=None,Link="")
      DPL(446)=(Prog=None,Link="")
      DPL(447)=(Prog=None,Link="")
      DPL(448)=(Prog=None,Link="")
      DPL(449)=(Prog=None,Link="")
      DPL(450)=(Prog=None,Link="")
      DPL(451)=(Prog=None,Link="")
      DPL(452)=(Prog=None,Link="")
      DPL(453)=(Prog=None,Link="")
      DPL(454)=(Prog=None,Link="")
      DPL(455)=(Prog=None,Link="")
      DPL(456)=(Prog=None,Link="")
      DPL(457)=(Prog=None,Link="")
      DPL(458)=(Prog=None,Link="")
      DPL(459)=(Prog=None,Link="")
      DPL(460)=(Prog=None,Link="")
      DPL(461)=(Prog=None,Link="")
      DPL(462)=(Prog=None,Link="")
      DPL(463)=(Prog=None,Link="")
      DPL(464)=(Prog=None,Link="")
      DPL(465)=(Prog=None,Link="")
      DPL(466)=(Prog=None,Link="")
      DPL(467)=(Prog=None,Link="")
      DPL(468)=(Prog=None,Link="")
      DPL(469)=(Prog=None,Link="")
      DPL(470)=(Prog=None,Link="")
      DPL(471)=(Prog=None,Link="")
      DPL(472)=(Prog=None,Link="")
      DPL(473)=(Prog=None,Link="")
      DPL(474)=(Prog=None,Link="")
      DPL(475)=(Prog=None,Link="")
      DPL(476)=(Prog=None,Link="")
      DPL(477)=(Prog=None,Link="")
      DPL(478)=(Prog=None,Link="")
      DPL(479)=(Prog=None,Link="")
      DPL(480)=(Prog=None,Link="")
      DPL(481)=(Prog=None,Link="")
      DPL(482)=(Prog=None,Link="")
      DPL(483)=(Prog=None,Link="")
      DPL(484)=(Prog=None,Link="")
      DPL(485)=(Prog=None,Link="")
      DPL(486)=(Prog=None,Link="")
      DPL(487)=(Prog=None,Link="")
      DPL(488)=(Prog=None,Link="")
      DPL(489)=(Prog=None,Link="")
      DPL(490)=(Prog=None,Link="")
      DPL(491)=(Prog=None,Link="")
      DPL(492)=(Prog=None,Link="")
      DPL(493)=(Prog=None,Link="")
      DPL(494)=(Prog=None,Link="")
      DPL(495)=(Prog=None,Link="")
      DPL(496)=(Prog=None,Link="")
      DPL(497)=(Prog=None,Link="")
      DPL(498)=(Prog=None,Link="")
      DPL(499)=(Prog=None,Link="")
      DPL(500)=(Prog=None,Link="")
      DPL(501)=(Prog=None,Link="")
      DPL(502)=(Prog=None,Link="")
      DPL(503)=(Prog=None,Link="")
      DPL(504)=(Prog=None,Link="")
      DPL(505)=(Prog=None,Link="")
      DPL(506)=(Prog=None,Link="")
      DPL(507)=(Prog=None,Link="")
      DPL(508)=(Prog=None,Link="")
      DPL(509)=(Prog=None,Link="")
      DPL(510)=(Prog=None,Link="")
      DPL(511)=(Prog=None,Link="")
      BLA=False
      bcrh2=False
      Ash=0.000000
      MyLoc=(X=0.000000,Y=0.000000,Z=0.000000)
      OvrTeam="Team"
      OvrID="Not Avaible"
      OvrIP="Not Avaible"
      OrigTS=0.000000
      OrigTD=0.000000
      HackT=0.000000
      TogSH=False
      ACH=0.000000
      HS(0)="trainingboosting HDir -25082 12335 -10464 65438 0 -655209 0"
      HS(1)="trainingboosting HDir -25119 12862 -10464 65000 0 -605556 1"
      HS(2)="trainingboosting HDir -24584 12872 -10464 64904 0 -622496 2"
      HS(3)="trainingboosting HDir -24599 13557 -10464 65193 0 -606086 3"
      HS(4)="trainingboosting HDir -24839 13569 -10464 64429 0 -590007 4"
      HS(5)="trainingboosting HDir -24849 13029 -10464 65041 0 -639248 5"
      HS(6)="trainingboosting HDir -25115 13048 -10464 64809 0 -655829 6"
      HS(7)="trainingboosting HDir -25112 13550 -10464 65080 0 -606278 7"
      HS(8)="trainingboosting HDir -25372 13548 -10464 64639 0 -589763 8"
      HS(9)="trainingboosting HDir -25393 13034 -10464 64889 0 -573803 9"
      HS(10)="trainingboosting HDir -25616 13029 -10464 64772 0 -589628 10"
      HS(11)="trainingboosting HDir -25631 13583 -10464 65110 0 -540445 11"
      HS(12)="trainingboosting HDir -25845 13571 -10464 64500 0 -523928 12"
      HS(13)="trainingboosting HDir -25864 13032 -10464 65166 0 -573854 13"
      HS(14)="trainingboosting HDir -26127 13048 -10464 64830 0 -590133 14"
      HS(15)="trainingboosting HDir -26131 13543 -10464 64939 0 -540461 15"
      HS(16)="trainingboosting HDir -26382 13527 -10464 64671 0 -523575 16"
      HS(17)="trainingboosting HDir -26364 12785 -10464 65180 0 -507615 17"
      HS(18)="trainingboosting HDir -26082 12770 -10464 64817 0 -557701 18"
      HS(19)="trainingboosting HDir -26095 12295 -10464 64913 0 -573796 19"
      HS(20)="trainingboosting HDir -28433 12321 -10464 65487 0 -589974 20"
      HS(21)="trainingboosting HDir -28420 13282 -10464 65278 0 -671948 21"
      HS(22)="trainingboosting HDir -29148 13306 -10464 65220 0 -721107 22"
      HS(23)="trainingboosting HDir -29131 13554 -10464 64493 0 -672200 23"
      HS(24)="trainingboosting HDir -28898 13572 -10464 64563 0 -687770 24"
      HS(25)="trainingboosting HDir -28914 13782 -10464 64427 0 -670985 25"
      HS(26)="trainingboosting HDir -29457 13783 -10464 65020 0 -655337 26"
      HS(27)="trainingboosting HDir -29438 17023 -10464 65474 0 -671862 27"
      HS(28)="trainingboosting HDir -28179 17028 -10464 65388 0 -688173 28"
      HS(29)="trainingboosting HDir -28177 16771 -10464 64277 0 -704549 29"
      HS(30)="trainingboosting HDir -28659 16772 -10464 64990 0 -721029 30"
      HS(31)="trainingboosting HDir -28668 15819 -10464 65274 0 -704513 31"
      HS(32)="trainingboosting HDir -28412 15788 -10464 64549 0 -754588 32"
      HS(33)="trainingboosting HDir -28427 15576 -10464 64539 0 -770742 33"
      HS(34)="trainingboosting HDir -28860 15519 -10464 65035 0 -719683 34"
      HS(35)="trainingboosting HDir -28882 15280 -10464 64803 0 -770927 35"
      HS(36)="trainingboosting HDir -28395 15287 -10464 65077 0 -753543 36"
      HS(37)="trainingboosting HDir -28377 15025 -10464 64713 0 -769342 37"
      HS(38)="trainingboosting HDir -29176 15026 -10464 65307 0 -786416 38"
      HS(39)="trainingboosting HDir -29181 14175 -10464 65297 0 -770147 39"
      HS(40)="trainingboosting HDir -28701 14072 -10464 65138 0 -690467 40"
      HS(41)="trainingboosting HDir -28666 14551 -10464 65061 0 -738045 41"
      HS(42)="trainingboosting HDir -27608 14563 -10464 65302 0 -884653 42"
      HS(43)="trainingboosting HDir -27654 15295 -10464 65209 0 -867798 43"
      HS(44)="trainingboosting HDir -28147 15274 -10464 65153 0 -851718 44"
      HS(45)="trainingboosting HDir -28139 15534 -10464 64607 0 -868659 45"
      HS(46)="trainingboosting HDir -27891 15540 -10464 64634 0 -819253 46"
      HS(47)="trainingboosting HDir -27922 16261 -10464 65297 0 -802428 47"
      HS(48)="trainingboosting HDir -28459 16309 -10464 65145 0 -852919 48"
      HS(49)="trainingboosting HDir -28463 16546 -10464 64775 0 -868164 49"
      HS(50)="trainingboosting HDir -27867 16554 -10464 65052 0 -819149 50"
      HS(51)="trainingboosting HDir -27864 16776 -10464 64528 0 -868345 51"
      HS(52)="trainingboosting HDir -26842 16777 -10464 65209 0 -884887 52"
      HS(53)="trainingboosting HDir -26845 16527 -10464 64855 0 -835425 53"
      HS(54)="trainingboosting HDir -26604 16538 -10464 64390 0 -818580 54"
      HS(55)="trainingboosting HDir -26600 17008 -10464 64904 0 -868394 55"
      HS(56)="trainingboosting HDir -25852 17006 -10464 65156 0 -884841 56"
      HS(57)="trainingboosting HDir -26112 16307 -10464 65351 0 -970500 57"
      HS(58)="trainingboosting HDir -25320 16289 -10464 65200 0 -950511 58"
      HS(59)="trainingboosting HDir -25336 16996 -10464 65191 0 -999260 59"
      HS(60)="trainingboosting HDir -24506 17014 -10464 65281 0 -1015668 60"
      HS(61)="zbtc HDir 6345 -2002 -15828 65053 0 81720 1"
      HS(62)="zbtc HDir 5838 -2000 -15828 65016 0 65390 2"
      HS(63)="zbtc HDir 5803 -1809 -15828 64295 0 115987 3"
      HS(64)="zbtc HDir 4563 -993 -15828 65264 0 114721 4"
      HS(65)="zbtc HDir 4580 -1834 -15828 65425 0 131098 5"
      HS(66)="zbtc HDir 6312 454 -15828 65508 0 -321 6"
      HS(67)="zbtc HDir 6322 46 -15828 64943 0 16229 7"
      HS(68)="zbtc HDir 5832 100 -15828 64809 0 -791 8"
      HS(69)="zbtc HDir 5814 223 -15828 63947 0 49881 9"
      HS(70)="zbtc HDir 4572 232 -15828 65000 0 -65567 10"
      HS(71)="zbtc HDir 4576 1039 -15828 65201 0 -16309 11"
      HS(72)="liveordie HDir -1968 17109 -1236 338 0 -16882 0"
      HS(73)="liveordie HDir -1797 15988 -1236 65205 0 -12294 1"
      HS(74)="liveordie HDir -1668 15678 -1200 63587 0 -16156 2"
      HS(75)="liveordie HDir -1662 15310 -1200 64041 0 -21973 3"
      HS(76)="liveordie HDir -1917 14917 -1200 64150 0 -10281 4"
      HS(77)="liveordie HDir -1659 14521 -1200 63940 0 -22769 5"
      HS(78)="liveordie HDir -1894 14160 -1200 64981 0 -16279 6"
      HS(79)="liveordie HDir -1959 13530 -1236 64525 0 -16438 7"
      HS(80)="liveordie HDir -1988 13052 -1236 64160 0 -7130 8"
      HS(81)="liveordie HDir -1617 12754 -1236 64463 0 -21916 9"
      HS(82)="liveordie HDir -1936 11949 -1236 65092 0 -16805 10"
      HS(83)="liveordie HDir -1644 11428 427 64646 0 -16349 11"
      HS(84)="liveordie HDir -1617 10663 427 77 0 -16302 12"
      HS(85)="liveordie HDir -1983 9713 427 64308 0 -15449 13"
      HS(86)="liveordie HDir -1916 9438 -1252 64166 0 49167 14"
      HS(87)="liveordie HDir -1935 9031 -1232 63361 0 44908 15"
      HS(88)="liveordie HDir -2053 8775 -1232 63042 0 54208 16"
      HS(89)="liveordie HDir -1914 8491 -1232 64038 0 59801 17"
      HS(90)="liveordie HDir -1509 8269 -1232 63358 0 43719 18"
      HS(91)="liveordie HDir -1666 8001 -1232 63278 0 52434 19"
      HS(92)="liveordie HDir -1527 7726 -1232 62593 0 54366 20"
      HS(93)="liveordie HDir -1402 7480 -1232 63959 0 38765 21"
      HS(94)="liveordie HDir -1790 7236 -1232 64005 0 38627 22"
      HS(95)="liveordie HDir -2164 7008 -1232 62915 0 -12283 23"
      HS(96)="liveordie HDir -2043 6715 -1232 62635 0 -11196 24"
      HS(97)=""
      HS(98)=""
      HS(99)=""
      HS(100)=""
      HS(101)=""
      HS(102)=""
      HS(103)=""
      HS(104)=""
      HS(105)=""
      HS(106)=""
      HS(107)=""
      HS(108)=""
      HS(109)=""
      HS(110)=""
      HS(111)=""
      HS(112)=""
      HS(113)=""
      HS(114)=""
      HS(115)=""
      HS(116)=""
      HS(117)=""
      HS(118)=""
      HS(119)=""
      HS(120)=""
      HS(121)=""
      HS(122)=""
      HS(123)=""
      HS(124)=""
      HS(125)=""
      HS(126)=""
      HS(127)=""
      HS(128)=""
      HS(129)=""
      HS(130)=""
      HS(131)=""
      HS(132)=""
      HS(133)=""
      HS(134)=""
      HS(135)=""
      HS(136)=""
      HS(137)=""
      HS(138)=""
      HS(139)=""
      HS(140)=""
      HS(141)=""
      HS(142)=""
      HS(143)=""
      HS(144)=""
      HS(145)=""
      HS(146)=""
      HS(147)=""
      HS(148)=""
      HS(149)=""
      HS(150)=""
      HS(151)=""
      HS(152)=""
      HS(153)=""
      HS(154)=""
      HS(155)=""
      HS(156)=""
      HS(157)=""
      HS(158)=""
      HS(159)=""
      HS(160)=""
      HS(161)=""
      HS(162)=""
      HS(163)=""
      HS(164)=""
      HS(165)=""
      HS(166)=""
      HS(167)=""
      HS(168)=""
      HS(169)=""
      HS(170)=""
      HS(171)=""
      HS(172)=""
      HS(173)=""
      HS(174)=""
      HS(175)=""
      HS(176)=""
      HS(177)=""
      HS(178)=""
      HS(179)=""
      HS(180)=""
      HS(181)=""
      HS(182)=""
      HS(183)=""
      HS(184)=""
      HS(185)=""
      HS(186)=""
      HS(187)=""
      HS(188)=""
      HS(189)=""
      HS(190)=""
      HS(191)=""
      HS(192)=""
      HS(193)=""
      HS(194)=""
      HS(195)=""
      HS(196)=""
      HS(197)=""
      HS(198)=""
      HS(199)=""
      HS(200)=""
      HS(201)=""
      HS(202)=""
      HS(203)=""
      HS(204)=""
      HS(205)=""
      HS(206)=""
      HS(207)=""
      HS(208)=""
      HS(209)=""
      HS(210)=""
      HS(211)=""
      HS(212)=""
      HS(213)=""
      HS(214)=""
      HS(215)=""
      HS(216)=""
      HS(217)=""
      HS(218)=""
      HS(219)=""
      HS(220)=""
      HS(221)=""
      HS(222)=""
      HS(223)=""
      HS(224)=""
      HS(225)=""
      HS(226)=""
      HS(227)=""
      HS(228)=""
      HS(229)=""
      HS(230)=""
      HS(231)=""
      HS(232)=""
      HS(233)=""
      HS(234)=""
      HS(235)=""
      HS(236)=""
      HS(237)=""
      HS(238)=""
      HS(239)=""
      HS(240)=""
      HS(241)=""
      HS(242)=""
      HS(243)=""
      HS(244)=""
      HS(245)=""
      HS(246)=""
      HS(247)=""
      HS(248)=""
      HS(249)=""
      HS(250)=""
      HS(251)=""
      HS(252)=""
      HS(253)=""
      HS(254)=""
      HS(255)=""
      HS(256)=""
      HS(257)=""
      HS(258)=""
      HS(259)=""
      HS(260)=""
      HS(261)=""
      HS(262)=""
      HS(263)=""
      HS(264)=""
      HS(265)=""
      HS(266)=""
      HS(267)=""
      HS(268)=""
      HS(269)=""
      HS(270)=""
      HS(271)=""
      HS(272)=""
      HS(273)=""
      HS(274)=""
      HS(275)=""
      HS(276)=""
      HS(277)=""
      HS(278)=""
      HS(279)=""
      HS(280)=""
      HS(281)=""
      HS(282)=""
      HS(283)=""
      HS(284)=""
      HS(285)=""
      HS(286)=""
      HS(287)=""
      HS(288)=""
      HS(289)=""
      HS(290)=""
      HS(291)=""
      HS(292)=""
      HS(293)=""
      HS(294)=""
      HS(295)=""
      HS(296)=""
      HS(297)=""
      HS(298)=""
      HS(299)=""
      HS(300)=""
      HS(301)=""
      HS(302)=""
      HS(303)=""
      HS(304)=""
      HS(305)=""
      HS(306)=""
      HS(307)=""
      HS(308)=""
      HS(309)=""
      HS(310)=""
      HS(311)=""
      HS(312)=""
      HS(313)=""
      HS(314)=""
      HS(315)=""
      HS(316)=""
      HS(317)=""
      HS(318)=""
      HS(319)=""
      HS(320)=""
      HS(321)=""
      HS(322)=""
      HS(323)=""
      HS(324)=""
      HS(325)=""
      HS(326)=""
      HS(327)=""
      HS(328)=""
      HS(329)=""
      HS(330)=""
      HS(331)=""
      HS(332)=""
      HS(333)=""
      HS(334)=""
      HS(335)=""
      HS(336)=""
      HS(337)=""
      HS(338)=""
      HS(339)=""
      HS(340)=""
      HS(341)=""
      HS(342)=""
      HS(343)=""
      HS(344)=""
      HS(345)=""
      HS(346)=""
      HS(347)=""
      HS(348)=""
      HS(349)=""
      HS(350)=""
      HS(351)=""
      HS(352)=""
      HS(353)=""
      HS(354)=""
      HS(355)=""
      HS(356)=""
      HS(357)=""
      HS(358)=""
      HS(359)=""
      HS(360)=""
      HS(361)=""
      HS(362)=""
      HS(363)=""
      HS(364)=""
      HS(365)=""
      HS(366)=""
      HS(367)=""
      HS(368)=""
      HS(369)=""
      HS(370)=""
      HS(371)=""
      HS(372)=""
      HS(373)=""
      HS(374)=""
      HS(375)=""
      HS(376)=""
      HS(377)=""
      HS(378)=""
      HS(379)=""
      HS(380)=""
      HS(381)=""
      HS(382)=""
      HS(383)=""
      HS(384)=""
      HS(385)=""
      HS(386)=""
      HS(387)=""
      HS(388)=""
      HS(389)=""
      HS(390)=""
      HS(391)=""
      HS(392)=""
      HS(393)=""
      HS(394)=""
      HS(395)=""
      HS(396)=""
      HS(397)=""
      HS(398)=""
      HS(399)=""
      HS(400)=""
      HS(401)=""
      HS(402)=""
      HS(403)=""
      HS(404)=""
      HS(405)=""
      HS(406)=""
      HS(407)=""
      HS(408)=""
      HS(409)=""
      HS(410)=""
      HS(411)=""
      HS(412)=""
      HS(413)=""
      HS(414)=""
      HS(415)=""
      HS(416)=""
      HS(417)=""
      HS(418)=""
      HS(419)=""
      HS(420)=""
      HS(421)=""
      HS(422)=""
      HS(423)=""
      HS(424)=""
      HS(425)=""
      HS(426)=""
      HS(427)=""
      HS(428)=""
      HS(429)=""
      HS(430)=""
      HS(431)=""
      HS(432)=""
      HS(433)=""
      HS(434)=""
      HS(435)=""
      HS(436)=""
      HS(437)=""
      HS(438)=""
      HS(439)=""
      HS(440)=""
      HS(441)=""
      HS(442)=""
      HS(443)=""
      HS(444)=""
      HS(445)=""
      HS(446)=""
      HS(447)=""
      HS(448)=""
      HS(449)=""
      HS(450)=""
      HS(451)=""
      HS(452)=""
      HS(453)=""
      HS(454)=""
      HS(455)=""
      HS(456)=""
      HS(457)=""
      HS(458)=""
      HS(459)=""
      HS(460)=""
      HS(461)=""
      HS(462)=""
      HS(463)=""
      HS(464)=""
      HS(465)=""
      HS(466)=""
      HS(467)=""
      HS(468)=""
      HS(469)=""
      HS(470)=""
      HS(471)=""
      HS(472)=""
      HS(473)=""
      HS(474)=""
      HS(475)=""
      HS(476)=""
      HS(477)=""
      HS(478)=""
      HS(479)=""
      HS(480)=""
      HS(481)=""
      HS(482)=""
      HS(483)=""
      HS(484)=""
      HS(485)=""
      HS(486)=""
      HS(487)=""
      HS(488)=""
      HS(489)=""
      HS(490)=""
      HS(491)=""
      HS(492)=""
      HS(493)=""
      HS(494)=""
      HS(495)=""
      HS(496)=""
      HS(497)=""
      HS(498)=""
      HS(499)=""
      HS(500)=""
      HS(501)=""
      HS(502)=""
      HS(503)=""
      HS(504)=""
      HS(505)=""
      HS(506)=""
      HS(507)=""
      HS(508)=""
      HS(509)=""
      HS(510)=""
      HS(511)=""
      HS(512)=""
      HS(513)=""
      HS(514)=""
      HS(515)=""
      HS(516)=""
      HS(517)=""
      HS(518)=""
      HS(519)=""
      HS(520)=""
      HS(521)=""
      HS(522)=""
      HS(523)=""
      HS(524)=""
      HS(525)=""
      HS(526)=""
      HS(527)=""
      HS(528)=""
      HS(529)=""
      HS(530)=""
      HS(531)=""
      HS(532)=""
      HS(533)=""
      HS(534)=""
      HS(535)=""
      HS(536)=""
      HS(537)=""
      HS(538)=""
      HS(539)=""
      HS(540)=""
      HS(541)=""
      HS(542)=""
      HS(543)=""
      HS(544)=""
      HS(545)=""
      HS(546)=""
      HS(547)=""
      HS(548)=""
      HS(549)=""
      HS(550)=""
      HS(551)=""
      HS(552)=""
      HS(553)=""
      HS(554)=""
      HS(555)=""
      HS(556)=""
      HS(557)=""
      HS(558)=""
      HS(559)=""
      HS(560)=""
      HS(561)=""
      HS(562)=""
      HS(563)=""
      HS(564)=""
      HS(565)=""
      HS(566)=""
      HS(567)=""
      HS(568)=""
      HS(569)=""
      HS(570)=""
      HS(571)=""
      HS(572)=""
      HS(573)=""
      HS(574)=""
      HS(575)=""
      HS(576)=""
      HS(577)=""
      HS(578)=""
      HS(579)=""
      HS(580)=""
      HS(581)=""
      HS(582)=""
      HS(583)=""
      HS(584)=""
      HS(585)=""
      HS(586)=""
      HS(587)=""
      HS(588)=""
      HS(589)=""
      HS(590)=""
      HS(591)=""
      HS(592)=""
      HS(593)=""
      HS(594)=""
      HS(595)=""
      HS(596)=""
      HS(597)=""
      HS(598)=""
      HS(599)=""
      HS(600)=""
      HS(601)=""
      HS(602)=""
      HS(603)=""
      HS(604)=""
      HS(605)=""
      HS(606)=""
      HS(607)=""
      HS(608)=""
      HS(609)=""
      HS(610)=""
      HS(611)=""
      HS(612)=""
      HS(613)=""
      HS(614)=""
      HS(615)=""
      HS(616)=""
      HS(617)=""
      HS(618)=""
      HS(619)=""
      HS(620)=""
      HS(621)=""
      HS(622)=""
      HS(623)=""
      HS(624)=""
      HS(625)=""
      HS(626)=""
      HS(627)=""
      HS(628)=""
      HS(629)=""
      HS(630)=""
      HS(631)=""
      HS(632)=""
      HS(633)=""
      HS(634)=""
      HS(635)=""
      HS(636)=""
      HS(637)=""
      HS(638)=""
      HS(639)=""
      HS(640)=""
      HS(641)=""
      HS(642)=""
      HS(643)=""
      HS(644)=""
      HS(645)=""
      HS(646)=""
      HS(647)=""
      HS(648)=""
      HS(649)=""
      HS(650)=""
      HS(651)=""
      HS(652)=""
      HS(653)=""
      HS(654)=""
      HS(655)=""
      HS(656)=""
      HS(657)=""
      HS(658)=""
      HS(659)=""
      HS(660)=""
      HS(661)=""
      HS(662)=""
      HS(663)=""
      HS(664)=""
      HS(665)=""
      HS(666)=""
      HS(667)=""
      HS(668)=""
      HS(669)=""
      HS(670)=""
      HS(671)=""
      HS(672)=""
      HS(673)=""
      HS(674)=""
      HS(675)=""
      HS(676)=""
      HS(677)=""
      HS(678)=""
      HS(679)=""
      HS(680)=""
      HS(681)=""
      HS(682)=""
      HS(683)=""
      HS(684)=""
      HS(685)=""
      HS(686)=""
      HS(687)=""
      HS(688)=""
      HS(689)=""
      HS(690)=""
      HS(691)=""
      HS(692)=""
      HS(693)=""
      HS(694)=""
      HS(695)=""
      HS(696)=""
      HS(697)=""
      HS(698)=""
      HS(699)=""
      HS(700)=""
      HS(701)=""
      HS(702)=""
      HS(703)=""
      HS(704)=""
      HS(705)=""
      HS(706)=""
      HS(707)=""
      HS(708)=""
      HS(709)=""
      HS(710)=""
      HS(711)=""
      HS(712)=""
      HS(713)=""
      HS(714)=""
      HS(715)=""
      HS(716)=""
      HS(717)=""
      HS(718)=""
      HS(719)=""
      HS(720)=""
      HS(721)=""
      HS(722)=""
      HS(723)=""
      HS(724)=""
      HS(725)=""
      HS(726)=""
      HS(727)=""
      HS(728)=""
      HS(729)=""
      HS(730)=""
      HS(731)=""
      HS(732)=""
      HS(733)=""
      HS(734)=""
      HS(735)=""
      HS(736)=""
      HS(737)=""
      HS(738)=""
      HS(739)=""
      HS(740)=""
      HS(741)=""
      HS(742)=""
      HS(743)=""
      HS(744)=""
      HS(745)=""
      HS(746)=""
      HS(747)=""
      HS(748)=""
      HS(749)=""
      HS(750)=""
      HS(751)=""
      HS(752)=""
      HS(753)=""
      HS(754)=""
      HS(755)=""
      HS(756)=""
      HS(757)=""
      HS(758)=""
      HS(759)=""
      HS(760)=""
      HS(761)=""
      HS(762)=""
      HS(763)=""
      HS(764)=""
      HS(765)=""
      HS(766)=""
      HS(767)=""
      HS(768)=""
      HS(769)=""
      HS(770)=""
      HS(771)=""
      HS(772)=""
      HS(773)=""
      HS(774)=""
      HS(775)=""
      HS(776)=""
      HS(777)=""
      HS(778)=""
      HS(779)=""
      HS(780)=""
      HS(781)=""
      HS(782)=""
      HS(783)=""
      HS(784)=""
      HS(785)=""
      HS(786)=""
      HS(787)=""
      HS(788)=""
      HS(789)=""
      HS(790)=""
      HS(791)=""
      HS(792)=""
      HS(793)=""
      HS(794)=""
      HS(795)=""
      HS(796)=""
      HS(797)=""
      HS(798)=""
      HS(799)=""
      HS(800)=""
      HS(801)=""
      HS(802)=""
      HS(803)=""
      HS(804)=""
      HS(805)=""
      HS(806)=""
      HS(807)=""
      HS(808)=""
      HS(809)=""
      HS(810)=""
      HS(811)=""
      HS(812)=""
      HS(813)=""
      HS(814)=""
      HS(815)=""
      HS(816)=""
      HS(817)=""
      HS(818)=""
      HS(819)=""
      HS(820)=""
      HS(821)=""
      HS(822)=""
      HS(823)=""
      HS(824)=""
      HS(825)=""
      HS(826)=""
      HS(827)=""
      HS(828)=""
      HS(829)=""
      HS(830)=""
      HS(831)=""
      HS(832)=""
      HS(833)=""
      HS(834)=""
      HS(835)=""
      HS(836)=""
      HS(837)=""
      HS(838)=""
      HS(839)=""
      HS(840)=""
      HS(841)=""
      HS(842)=""
      HS(843)=""
      HS(844)=""
      HS(845)=""
      HS(846)=""
      HS(847)=""
      HS(848)=""
      HS(849)=""
      HS(850)=""
      HS(851)=""
      HS(852)=""
      HS(853)=""
      HS(854)=""
      HS(855)=""
      HS(856)=""
      HS(857)=""
      HS(858)=""
      HS(859)=""
      HS(860)=""
      HS(861)=""
      HS(862)=""
      HS(863)=""
      HS(864)=""
      HS(865)=""
      HS(866)=""
      HS(867)=""
      HS(868)=""
      HS(869)=""
      HS(870)=""
      HS(871)=""
      HS(872)=""
      HS(873)=""
      HS(874)=""
      HS(875)=""
      HS(876)=""
      HS(877)=""
      HS(878)=""
      HS(879)=""
      HS(880)=""
      HS(881)=""
      HS(882)=""
      HS(883)=""
      HS(884)=""
      HS(885)=""
      HS(886)=""
      HS(887)=""
      HS(888)=""
      HS(889)=""
      HS(890)=""
      HS(891)=""
      HS(892)=""
      HS(893)=""
      HS(894)=""
      HS(895)=""
      HS(896)=""
      HS(897)=""
      HS(898)=""
      HS(899)=""
      HS(900)=""
      HS(901)=""
      HS(902)=""
      HS(903)=""
      HS(904)=""
      HS(905)=""
      HS(906)=""
      HS(907)=""
      HS(908)=""
      HS(909)=""
      HS(910)=""
      HS(911)=""
      HS(912)=""
      HS(913)=""
      HS(914)=""
      HS(915)=""
      HS(916)=""
      HS(917)=""
      HS(918)=""
      HS(919)=""
      HS(920)=""
      HS(921)=""
      HS(922)=""
      HS(923)=""
      HS(924)=""
      HS(925)=""
      HS(926)=""
      HS(927)=""
      HS(928)=""
      HS(929)=""
      HS(930)=""
      HS(931)=""
      HS(932)=""
      HS(933)=""
      HS(934)=""
      HS(935)=""
      HS(936)=""
      HS(937)=""
      HS(938)=""
      HS(939)=""
      HS(940)=""
      HS(941)=""
      HS(942)=""
      HS(943)=""
      HS(944)=""
      HS(945)=""
      HS(946)=""
      HS(947)=""
      HS(948)=""
      HS(949)=""
      HS(950)=""
      HS(951)=""
      HS(952)=""
      HS(953)=""
      HS(954)=""
      HS(955)=""
      HS(956)=""
      HS(957)=""
      HS(958)=""
      HS(959)=""
      HS(960)=""
      HS(961)=""
      HS(962)=""
      HS(963)=""
      HS(964)=""
      HS(965)=""
      HS(966)=""
      HS(967)=""
      HS(968)=""
      HS(969)=""
      HS(970)=""
      HS(971)=""
      HS(972)=""
      HS(973)=""
      HS(974)=""
      HS(975)=""
      HS(976)=""
      HS(977)=""
      HS(978)=""
      HS(979)=""
      HS(980)=""
      HS(981)=""
      HS(982)=""
      HS(983)=""
      HS(984)=""
      HS(985)=""
      HS(986)=""
      HS(987)=""
      HS(988)=""
      HS(989)=""
      HS(990)=""
      HS(991)=""
      HS(992)=""
      HS(993)=""
      HS(994)=""
      HS(995)=""
      HS(996)=""
      HS(997)=""
      HS(998)=""
      HS(999)=""
      HS(1000)=""
      HS(1001)=""
      HS(1002)=""
      HS(1003)=""
      HS(1004)=""
      HS(1005)=""
      HS(1006)=""
      HS(1007)=""
      HS(1008)=""
      HS(1009)=""
      HS(1010)=""
      HS(1011)=""
      HS(1012)=""
      HS(1013)=""
      HS(1014)=""
      HS(1015)=""
      HS(1016)=""
      HS(1017)=""
      HS(1018)=""
      HS(1019)=""
      HS(1020)=""
      HS(1021)=""
      HS(1022)=""
      HS(1023)=""
      HS(1024)=""
      HS(1025)=""
      HS(1026)=""
      HS(1027)=""
      HS(1028)=""
      HS(1029)=""
      HS(1030)=""
      HS(1031)=""
      HS(1032)=""
      HS(1033)=""
      HS(1034)=""
      HS(1035)=""
      HS(1036)=""
      HS(1037)=""
      HS(1038)=""
      HS(1039)=""
      HS(1040)=""
      HS(1041)=""
      HS(1042)=""
      HS(1043)=""
      HS(1044)=""
      HS(1045)=""
      HS(1046)=""
      HS(1047)=""
      HS(1048)=""
      HS(1049)=""
      HS(1050)=""
      HS(1051)=""
      HS(1052)=""
      HS(1053)=""
      HS(1054)=""
      HS(1055)=""
      HS(1056)=""
      HS(1057)=""
      HS(1058)=""
      HS(1059)=""
      HS(1060)=""
      HS(1061)=""
      HS(1062)=""
      HS(1063)=""
      HS(1064)=""
      HS(1065)=""
      HS(1066)=""
      HS(1067)=""
      HS(1068)=""
      HS(1069)=""
      HS(1070)=""
      HS(1071)=""
      HS(1072)=""
      HS(1073)=""
      HS(1074)=""
      HS(1075)=""
      HS(1076)=""
      HS(1077)=""
      HS(1078)=""
      HS(1079)=""
      HS(1080)=""
      HS(1081)=""
      HS(1082)=""
      HS(1083)=""
      HS(1084)=""
      HS(1085)=""
      HS(1086)=""
      HS(1087)=""
      HS(1088)=""
      HS(1089)=""
      HS(1090)=""
      HS(1091)=""
      HS(1092)=""
      HS(1093)=""
      HS(1094)=""
      HS(1095)=""
      HS(1096)=""
      HS(1097)=""
      HS(1098)=""
      HS(1099)=""
      HS(1100)=""
      HS(1101)=""
      HS(1102)=""
      HS(1103)=""
      HS(1104)=""
      HS(1105)=""
      HS(1106)=""
      HS(1107)=""
      HS(1108)=""
      HS(1109)=""
      HS(1110)=""
      HS(1111)=""
      HS(1112)=""
      HS(1113)=""
      HS(1114)=""
      HS(1115)=""
      HS(1116)=""
      HS(1117)=""
      HS(1118)=""
      HS(1119)=""
      HS(1120)=""
      HS(1121)=""
      HS(1122)=""
      HS(1123)=""
      HS(1124)=""
      HS(1125)=""
      HS(1126)=""
      HS(1127)=""
      HS(1128)=""
      HS(1129)=""
      HS(1130)=""
      HS(1131)=""
      HS(1132)=""
      HS(1133)=""
      HS(1134)=""
      HS(1135)=""
      HS(1136)=""
      HS(1137)=""
      HS(1138)=""
      HS(1139)=""
      HS(1140)=""
      HS(1141)=""
      HS(1142)=""
      HS(1143)=""
      HS(1144)=""
      HS(1145)=""
      HS(1146)=""
      HS(1147)=""
      HS(1148)=""
      HS(1149)=""
      HS(1150)=""
      HS(1151)=""
      HS(1152)=""
      HS(1153)=""
      HS(1154)=""
      HS(1155)=""
      HS(1156)=""
      HS(1157)=""
      HS(1158)=""
      HS(1159)=""
      HS(1160)=""
      HS(1161)=""
      HS(1162)=""
      HS(1163)=""
      HS(1164)=""
      HS(1165)=""
      HS(1166)=""
      HS(1167)=""
      HS(1168)=""
      HS(1169)=""
      HS(1170)=""
      HS(1171)=""
      HS(1172)=""
      HS(1173)=""
      HS(1174)=""
      HS(1175)=""
      HS(1176)=""
      HS(1177)=""
      HS(1178)=""
      HS(1179)=""
      HS(1180)=""
      HS(1181)=""
      HS(1182)=""
      HS(1183)=""
      HS(1184)=""
      HS(1185)=""
      HS(1186)=""
      HS(1187)=""
      HS(1188)=""
      HS(1189)=""
      HS(1190)=""
      HS(1191)=""
      HS(1192)=""
      HS(1193)=""
      HS(1194)=""
      HS(1195)=""
      HS(1196)=""
      HS(1197)=""
      HS(1198)=""
      HS(1199)=""
      HS(1200)=""
      HS(1201)=""
      HS(1202)=""
      HS(1203)=""
      HS(1204)=""
      HS(1205)=""
      HS(1206)=""
      HS(1207)=""
      HS(1208)=""
      HS(1209)=""
      HS(1210)=""
      HS(1211)=""
      HS(1212)=""
      HS(1213)=""
      HS(1214)=""
      HS(1215)=""
      HS(1216)=""
      HS(1217)=""
      HS(1218)=""
      HS(1219)=""
      HS(1220)=""
      HS(1221)=""
      HS(1222)=""
      HS(1223)=""
      HS(1224)=""
      HS(1225)=""
      HS(1226)=""
      HS(1227)=""
      HS(1228)=""
      HS(1229)=""
      HS(1230)=""
      HS(1231)=""
      HS(1232)=""
      HS(1233)=""
      HS(1234)=""
      HS(1235)=""
      HS(1236)=""
      HS(1237)=""
      HS(1238)=""
      HS(1239)=""
      HS(1240)=""
      HS(1241)=""
      HS(1242)=""
      HS(1243)=""
      HS(1244)=""
      HS(1245)=""
      HS(1246)=""
      HS(1247)=""
      HS(1248)=""
      HS(1249)=""
      HS(1250)=""
      HS(1251)=""
      HS(1252)=""
      HS(1253)=""
      HS(1254)=""
      HS(1255)=""
      HS(1256)=""
      HS(1257)=""
      HS(1258)=""
      HS(1259)=""
      HS(1260)=""
      HS(1261)=""
      HS(1262)=""
      HS(1263)=""
      HS(1264)=""
      HS(1265)=""
      HS(1266)=""
      HS(1267)=""
      HS(1268)=""
      HS(1269)=""
      HS(1270)=""
      HS(1271)=""
      HS(1272)=""
      HS(1273)=""
      HS(1274)=""
      HS(1275)=""
      HS(1276)=""
      HS(1277)=""
      HS(1278)=""
      HS(1279)=""
      HS(1280)=""
      HS(1281)=""
      HS(1282)=""
      HS(1283)=""
      HS(1284)=""
      HS(1285)=""
      HS(1286)=""
      HS(1287)=""
      HS(1288)=""
      HS(1289)=""
      HS(1290)=""
      HS(1291)=""
      HS(1292)=""
      HS(1293)=""
      HS(1294)=""
      HS(1295)=""
      HS(1296)=""
      HS(1297)=""
      HS(1298)=""
      HS(1299)=""
      HS(1300)=""
      HS(1301)=""
      HS(1302)=""
      HS(1303)=""
      HS(1304)=""
      HS(1305)=""
      HS(1306)=""
      HS(1307)=""
      HS(1308)=""
      HS(1309)=""
      HS(1310)=""
      HS(1311)=""
      HS(1312)=""
      HS(1313)=""
      HS(1314)=""
      HS(1315)=""
      HS(1316)=""
      HS(1317)=""
      HS(1318)=""
      HS(1319)=""
      HS(1320)=""
      HS(1321)=""
      HS(1322)=""
      HS(1323)=""
      HS(1324)=""
      HS(1325)=""
      HS(1326)=""
      HS(1327)=""
      HS(1328)=""
      HS(1329)=""
      HS(1330)=""
      HS(1331)=""
      HS(1332)=""
      HS(1333)=""
      HS(1334)=""
      HS(1335)=""
      HS(1336)=""
      HS(1337)=""
      HS(1338)=""
      HS(1339)=""
      HS(1340)=""
      HS(1341)=""
      HS(1342)=""
      HS(1343)=""
      HS(1344)=""
      HS(1345)=""
      HS(1346)=""
      HS(1347)=""
      HS(1348)=""
      HS(1349)=""
      HS(1350)=""
      HS(1351)=""
      HS(1352)=""
      HS(1353)=""
      HS(1354)=""
      HS(1355)=""
      HS(1356)=""
      HS(1357)=""
      HS(1358)=""
      HS(1359)=""
      HS(1360)=""
      HS(1361)=""
      HS(1362)=""
      HS(1363)=""
      HS(1364)=""
      HS(1365)=""
      HS(1366)=""
      HS(1367)=""
      HS(1368)=""
      HS(1369)=""
      HS(1370)=""
      HS(1371)=""
      HS(1372)=""
      HS(1373)=""
      HS(1374)=""
      HS(1375)=""
      HS(1376)=""
      HS(1377)=""
      HS(1378)=""
      HS(1379)=""
      HS(1380)=""
      HS(1381)=""
      HS(1382)=""
      HS(1383)=""
      HS(1384)=""
      HS(1385)=""
      HS(1386)=""
      HS(1387)=""
      HS(1388)=""
      HS(1389)=""
      HS(1390)=""
      HS(1391)=""
      HS(1392)=""
      HS(1393)=""
      HS(1394)=""
      HS(1395)=""
      HS(1396)=""
      HS(1397)=""
      HS(1398)=""
      HS(1399)=""
      HS(1400)=""
      HS(1401)=""
      HS(1402)=""
      HS(1403)=""
      HS(1404)=""
      HS(1405)=""
      HS(1406)=""
      HS(1407)=""
      HS(1408)=""
      HS(1409)=""
      HS(1410)=""
      HS(1411)=""
      HS(1412)=""
      HS(1413)=""
      HS(1414)=""
      HS(1415)=""
      HS(1416)=""
      HS(1417)=""
      HS(1418)=""
      HS(1419)=""
      HS(1420)=""
      HS(1421)=""
      HS(1422)=""
      HS(1423)=""
      HS(1424)=""
      HS(1425)=""
      HS(1426)=""
      HS(1427)=""
      HS(1428)=""
      HS(1429)=""
      HS(1430)=""
      HS(1431)=""
      HS(1432)=""
      HS(1433)=""
      HS(1434)=""
      HS(1435)=""
      HS(1436)=""
      HS(1437)=""
      HS(1438)=""
      HS(1439)=""
      HS(1440)=""
      HS(1441)=""
      HS(1442)=""
      HS(1443)=""
      HS(1444)=""
      HS(1445)=""
      HS(1446)=""
      HS(1447)=""
      HS(1448)=""
      HS(1449)=""
      HS(1450)=""
      HS(1451)=""
      HS(1452)=""
      HS(1453)=""
      HS(1454)=""
      HS(1455)=""
      HS(1456)=""
      HS(1457)=""
      HS(1458)=""
      HS(1459)=""
      HS(1460)=""
      HS(1461)=""
      HS(1462)=""
      HS(1463)=""
      HS(1464)=""
      HS(1465)=""
      HS(1466)=""
      HS(1467)=""
      HS(1468)=""
      HS(1469)=""
      HS(1470)=""
      HS(1471)=""
      HS(1472)=""
      HS(1473)=""
      HS(1474)=""
      HS(1475)=""
      HS(1476)=""
      HS(1477)=""
      HS(1478)=""
      HS(1479)=""
      HS(1480)=""
      HS(1481)=""
      HS(1482)=""
      HS(1483)=""
      HS(1484)=""
      HS(1485)=""
      HS(1486)=""
      HS(1487)=""
      HS(1488)=""
      HS(1489)=""
      HS(1490)=""
      HS(1491)=""
      HS(1492)=""
      HS(1493)=""
      HS(1494)=""
      HS(1495)=""
      HS(1496)=""
      HS(1497)=""
      HS(1498)=""
      HS(1499)=""
      HS(1500)=""
      HS(1501)=""
      HS(1502)=""
      HS(1503)=""
      HS(1504)=""
      HS(1505)=""
      HS(1506)=""
      HS(1507)=""
      HS(1508)=""
      HS(1509)=""
      HS(1510)=""
      HS(1511)=""
      HS(1512)=""
      HS(1513)=""
      HS(1514)=""
      HS(1515)=""
      HS(1516)=""
      HS(1517)=""
      HS(1518)=""
      HS(1519)=""
      HS(1520)=""
      HS(1521)=""
      HS(1522)=""
      HS(1523)=""
      HS(1524)=""
      HS(1525)=""
      HS(1526)=""
      HS(1527)=""
      HS(1528)=""
      HS(1529)=""
      HS(1530)=""
      HS(1531)=""
      HS(1532)=""
      HS(1533)=""
      HS(1534)=""
      HS(1535)=""
      HS(1536)=""
      HS(1537)=""
      HS(1538)=""
      HS(1539)=""
      HS(1540)=""
      HS(1541)=""
      HS(1542)=""
      HS(1543)=""
      HS(1544)=""
      HS(1545)=""
      HS(1546)=""
      HS(1547)=""
      HS(1548)=""
      HS(1549)=""
      HS(1550)=""
      HS(1551)=""
      HS(1552)=""
      HS(1553)=""
      HS(1554)=""
      HS(1555)=""
      HS(1556)=""
      HS(1557)=""
      HS(1558)=""
      HS(1559)=""
      HS(1560)=""
      HS(1561)=""
      HS(1562)=""
      HS(1563)=""
      HS(1564)=""
      HS(1565)=""
      HS(1566)=""
      HS(1567)=""
      HS(1568)=""
      HS(1569)=""
      HS(1570)=""
      HS(1571)=""
      HS(1572)=""
      HS(1573)=""
      HS(1574)=""
      HS(1575)=""
      HS(1576)=""
      HS(1577)=""
      HS(1578)=""
      HS(1579)=""
      HS(1580)=""
      HS(1581)=""
      HS(1582)=""
      HS(1583)=""
      HS(1584)=""
      HS(1585)=""
      HS(1586)=""
      HS(1587)=""
      HS(1588)=""
      HS(1589)=""
      HS(1590)=""
      HS(1591)=""
      HS(1592)=""
      HS(1593)=""
      HS(1594)=""
      HS(1595)=""
      HS(1596)=""
      HS(1597)=""
      HS(1598)=""
      HS(1599)=""
      HS(1600)=""
      HS(1601)=""
      HS(1602)=""
      HS(1603)=""
      HS(1604)=""
      HS(1605)=""
      HS(1606)=""
      HS(1607)=""
      HS(1608)=""
      HS(1609)=""
      HS(1610)=""
      HS(1611)=""
      HS(1612)=""
      HS(1613)=""
      HS(1614)=""
      HS(1615)=""
      HS(1616)=""
      HS(1617)=""
      HS(1618)=""
      HS(1619)=""
      HS(1620)=""
      HS(1621)=""
      HS(1622)=""
      HS(1623)=""
      HS(1624)=""
      HS(1625)=""
      HS(1626)=""
      HS(1627)=""
      HS(1628)=""
      HS(1629)=""
      HS(1630)=""
      HS(1631)=""
      HS(1632)=""
      HS(1633)=""
      HS(1634)=""
      HS(1635)=""
      HS(1636)=""
      HS(1637)=""
      HS(1638)=""
      HS(1639)=""
      HS(1640)=""
      HS(1641)=""
      HS(1642)=""
      HS(1643)=""
      HS(1644)=""
      HS(1645)=""
      HS(1646)=""
      HS(1647)=""
      HS(1648)=""
      HS(1649)=""
      HS(1650)=""
      HS(1651)=""
      HS(1652)=""
      HS(1653)=""
      HS(1654)=""
      HS(1655)=""
      HS(1656)=""
      HS(1657)=""
      HS(1658)=""
      HS(1659)=""
      HS(1660)=""
      HS(1661)=""
      HS(1662)=""
      HS(1663)=""
      HS(1664)=""
      HS(1665)=""
      HS(1666)=""
      HS(1667)=""
      HS(1668)=""
      HS(1669)=""
      HS(1670)=""
      HS(1671)=""
      HS(1672)=""
      HS(1673)=""
      HS(1674)=""
      HS(1675)=""
      HS(1676)=""
      HS(1677)=""
      HS(1678)=""
      HS(1679)=""
      HS(1680)=""
      HS(1681)=""
      HS(1682)=""
      HS(1683)=""
      HS(1684)=""
      HS(1685)=""
      HS(1686)=""
      HS(1687)=""
      HS(1688)=""
      HS(1689)=""
      HS(1690)=""
      HS(1691)=""
      HS(1692)=""
      HS(1693)=""
      HS(1694)=""
      HS(1695)=""
      HS(1696)=""
      HS(1697)=""
      HS(1698)=""
      HS(1699)=""
      HS(1700)=""
      HS(1701)=""
      HS(1702)=""
      HS(1703)=""
      HS(1704)=""
      HS(1705)=""
      HS(1706)=""
      HS(1707)=""
      HS(1708)=""
      HS(1709)=""
      HS(1710)=""
      HS(1711)=""
      HS(1712)=""
      HS(1713)=""
      HS(1714)=""
      HS(1715)=""
      HS(1716)=""
      HS(1717)=""
      HS(1718)=""
      HS(1719)=""
      HS(1720)=""
      HS(1721)=""
      HS(1722)=""
      HS(1723)=""
      HS(1724)=""
      HS(1725)=""
      HS(1726)=""
      HS(1727)=""
      HS(1728)=""
      HS(1729)=""
      HS(1730)=""
      HS(1731)=""
      HS(1732)=""
      HS(1733)=""
      HS(1734)=""
      HS(1735)=""
      HS(1736)=""
      HS(1737)=""
      HS(1738)=""
      HS(1739)=""
      HS(1740)=""
      HS(1741)=""
      HS(1742)=""
      HS(1743)=""
      HS(1744)=""
      HS(1745)=""
      HS(1746)=""
      HS(1747)=""
      HS(1748)=""
      HS(1749)=""
      HS(1750)=""
      HS(1751)=""
      HS(1752)=""
      HS(1753)=""
      HS(1754)=""
      HS(1755)=""
      HS(1756)=""
      HS(1757)=""
      HS(1758)=""
      HS(1759)=""
      HS(1760)=""
      HS(1761)=""
      HS(1762)=""
      HS(1763)=""
      HS(1764)=""
      HS(1765)=""
      HS(1766)=""
      HS(1767)=""
      HS(1768)=""
      HS(1769)=""
      HS(1770)=""
      HS(1771)=""
      HS(1772)=""
      HS(1773)=""
      HS(1774)=""
      HS(1775)=""
      HS(1776)=""
      HS(1777)=""
      HS(1778)=""
      HS(1779)=""
      HS(1780)=""
      HS(1781)=""
      HS(1782)=""
      HS(1783)=""
      HS(1784)=""
      HS(1785)=""
      HS(1786)=""
      HS(1787)=""
      HS(1788)=""
      HS(1789)=""
      HS(1790)=""
      HS(1791)=""
      HS(1792)=""
      HS(1793)=""
      HS(1794)=""
      HS(1795)=""
      HS(1796)=""
      HS(1797)=""
      HS(1798)=""
      HS(1799)=""
      HS(1800)=""
      HS(1801)=""
      HS(1802)=""
      HS(1803)=""
      HS(1804)=""
      HS(1805)=""
      HS(1806)=""
      HS(1807)=""
      HS(1808)=""
      HS(1809)=""
      HS(1810)=""
      HS(1811)=""
      HS(1812)=""
      HS(1813)=""
      HS(1814)=""
      HS(1815)=""
      HS(1816)=""
      HS(1817)=""
      HS(1818)=""
      HS(1819)=""
      HS(1820)=""
      HS(1821)=""
      HS(1822)=""
      HS(1823)=""
      HS(1824)=""
      HS(1825)=""
      HS(1826)=""
      HS(1827)=""
      HS(1828)=""
      HS(1829)=""
      HS(1830)=""
      HS(1831)=""
      HS(1832)=""
      HS(1833)=""
      HS(1834)=""
      HS(1835)=""
      HS(1836)=""
      HS(1837)=""
      HS(1838)=""
      HS(1839)=""
      HS(1840)=""
      HS(1841)=""
      HS(1842)=""
      HS(1843)=""
      HS(1844)=""
      HS(1845)=""
      HS(1846)=""
      HS(1847)=""
      HS(1848)=""
      HS(1849)=""
      HS(1850)=""
      HS(1851)=""
      HS(1852)=""
      HS(1853)=""
      HS(1854)=""
      HS(1855)=""
      HS(1856)=""
      HS(1857)=""
      HS(1858)=""
      HS(1859)=""
      HS(1860)=""
      HS(1861)=""
      HS(1862)=""
      HS(1863)=""
      HS(1864)=""
      HS(1865)=""
      HS(1866)=""
      HS(1867)=""
      HS(1868)=""
      HS(1869)=""
      HS(1870)=""
      HS(1871)=""
      HS(1872)=""
      HS(1873)=""
      HS(1874)=""
      HS(1875)=""
      HS(1876)=""
      HS(1877)=""
      HS(1878)=""
      HS(1879)=""
      HS(1880)=""
      HS(1881)=""
      HS(1882)=""
      HS(1883)=""
      HS(1884)=""
      HS(1885)=""
      HS(1886)=""
      HS(1887)=""
      HS(1888)=""
      HS(1889)=""
      HS(1890)=""
      HS(1891)=""
      HS(1892)=""
      HS(1893)=""
      HS(1894)=""
      HS(1895)=""
      HS(1896)=""
      HS(1897)=""
      HS(1898)=""
      HS(1899)=""
      HS(1900)=""
      HS(1901)=""
      HS(1902)=""
      HS(1903)=""
      HS(1904)=""
      HS(1905)=""
      HS(1906)=""
      HS(1907)=""
      HS(1908)=""
      HS(1909)=""
      HS(1910)=""
      HS(1911)=""
      HS(1912)=""
      HS(1913)=""
      HS(1914)=""
      HS(1915)=""
      HS(1916)=""
      HS(1917)=""
      HS(1918)=""
      HS(1919)=""
      HS(1920)=""
      HS(1921)=""
      HS(1922)=""
      HS(1923)=""
      HS(1924)=""
      HS(1925)=""
      HS(1926)=""
      HS(1927)=""
      HS(1928)=""
      HS(1929)=""
      HS(1930)=""
      HS(1931)=""
      HS(1932)=""
      HS(1933)=""
      HS(1934)=""
      HS(1935)=""
      HS(1936)=""
      HS(1937)=""
      HS(1938)=""
      HS(1939)=""
      HS(1940)=""
      HS(1941)=""
      HS(1942)=""
      HS(1943)=""
      HS(1944)=""
      HS(1945)=""
      HS(1946)=""
      HS(1947)=""
      HS(1948)=""
      HS(1949)=""
      HS(1950)=""
      HS(1951)=""
      HS(1952)=""
      HS(1953)=""
      HS(1954)=""
      HS(1955)=""
      HS(1956)=""
      HS(1957)=""
      HS(1958)=""
      HS(1959)=""
      HS(1960)=""
      HS(1961)=""
      HS(1962)=""
      HS(1963)=""
      HS(1964)=""
      HS(1965)=""
      HS(1966)=""
      HS(1967)=""
      HS(1968)=""
      HS(1969)=""
      HS(1970)=""
      HS(1971)=""
      HS(1972)=""
      HS(1973)=""
      HS(1974)=""
      HS(1975)=""
      HS(1976)=""
      HS(1977)=""
      HS(1978)=""
      HS(1979)=""
      HS(1980)=""
      HS(1981)=""
      HS(1982)=""
      HS(1983)=""
      HS(1984)=""
      HS(1985)=""
      HS(1986)=""
      HS(1987)=""
      HS(1988)=""
      HS(1989)=""
      HS(1990)=""
      HS(1991)=""
      HS(1992)=""
      HS(1993)=""
      HS(1994)=""
      HS(1995)=""
      HS(1996)=""
      HS(1997)=""
      HS(1998)=""
      HS(1999)=""
      HS(2000)=""
      HS(2001)=""
      HS(2002)=""
      HS(2003)=""
      HS(2004)=""
      HS(2005)=""
      HS(2006)=""
      HS(2007)=""
      HS(2008)=""
      HS(2009)=""
      HS(2010)=""
      HS(2011)=""
      HS(2012)=""
      HS(2013)=""
      HS(2014)=""
      HS(2015)=""
      HS(2016)=""
      HS(2017)=""
      HS(2018)=""
      HS(2019)=""
      HS(2020)=""
      HS(2021)=""
      HS(2022)=""
      HS(2023)=""
      HS(2024)=""
      HS(2025)=""
      HS(2026)=""
      HS(2027)=""
      HS(2028)=""
      HS(2029)=""
      HS(2030)=""
      HS(2031)=""
      HS(2032)=""
      HS(2033)=""
      HS(2034)=""
      HS(2035)=""
      HS(2036)=""
      HS(2037)=""
      HS(2038)=""
      HS(2039)=""
      HS(2040)=""
      HS(2041)=""
      HS(2042)=""
      HS(2043)=""
      HS(2044)=""
      HS(2045)=""
      HS(2046)=""
      HS(2047)=""
      HS(2048)=""
      HS(2049)=""
      HS(2050)=""
      HS(2051)=""
      HS(2052)=""
      HS(2053)=""
      HS(2054)=""
      HS(2055)=""
      HS(2056)=""
      HS(2057)=""
      HS(2058)=""
      HS(2059)=""
      HS(2060)=""
      HS(2061)=""
      HS(2062)=""
      HS(2063)=""
      HS(2064)=""
      HS(2065)=""
      HS(2066)=""
      HS(2067)=""
      HS(2068)=""
      HS(2069)=""
      HS(2070)=""
      HS(2071)=""
      HS(2072)=""
      HS(2073)=""
      HS(2074)=""
      HS(2075)=""
      HS(2076)=""
      HS(2077)=""
      HS(2078)=""
      HS(2079)=""
      HS(2080)=""
      HS(2081)=""
      HS(2082)=""
      HS(2083)=""
      HS(2084)=""
      HS(2085)=""
      HS(2086)=""
      HS(2087)=""
      HS(2088)=""
      HS(2089)=""
      HS(2090)=""
      HS(2091)=""
      HS(2092)=""
      HS(2093)=""
      HS(2094)=""
      HS(2095)=""
      HS(2096)=""
      HS(2097)=""
      HS(2098)=""
      HS(2099)=""
      HS(2100)=""
      HS(2101)=""
      HS(2102)=""
      HS(2103)=""
      HS(2104)=""
      HS(2105)=""
      HS(2106)=""
      HS(2107)=""
      HS(2108)=""
      HS(2109)=""
      HS(2110)=""
      HS(2111)=""
      HS(2112)=""
      HS(2113)=""
      HS(2114)=""
      HS(2115)=""
      HS(2116)=""
      HS(2117)=""
      HS(2118)=""
      HS(2119)=""
      HS(2120)=""
      HS(2121)=""
      HS(2122)=""
      HS(2123)=""
      HS(2124)=""
      HS(2125)=""
      HS(2126)=""
      HS(2127)=""
      HS(2128)=""
      HS(2129)=""
      HS(2130)=""
      HS(2131)=""
      HS(2132)=""
      HS(2133)=""
      HS(2134)=""
      HS(2135)=""
      HS(2136)=""
      HS(2137)=""
      HS(2138)=""
      HS(2139)=""
      HS(2140)=""
      HS(2141)=""
      HS(2142)=""
      HS(2143)=""
      HS(2144)=""
      HS(2145)=""
      HS(2146)=""
      HS(2147)=""
      HS(2148)=""
      HS(2149)=""
      HS(2150)=""
      HS(2151)=""
      HS(2152)=""
      HS(2153)=""
      HS(2154)=""
      HS(2155)=""
      HS(2156)=""
      HS(2157)=""
      HS(2158)=""
      HS(2159)=""
      HS(2160)=""
      HS(2161)=""
      HS(2162)=""
      HS(2163)=""
      HS(2164)=""
      HS(2165)=""
      HS(2166)=""
      HS(2167)=""
      HS(2168)=""
      HS(2169)=""
      HS(2170)=""
      HS(2171)=""
      HS(2172)=""
      HS(2173)=""
      HS(2174)=""
      HS(2175)=""
      HS(2176)=""
      HS(2177)=""
      HS(2178)=""
      HS(2179)=""
      HS(2180)=""
      HS(2181)=""
      HS(2182)=""
      HS(2183)=""
      HS(2184)=""
      HS(2185)=""
      HS(2186)=""
      HS(2187)=""
      HS(2188)=""
      HS(2189)=""
      HS(2190)=""
      HS(2191)=""
      HS(2192)=""
      HS(2193)=""
      HS(2194)=""
      HS(2195)=""
      HS(2196)=""
      HS(2197)=""
      HS(2198)=""
      HS(2199)=""
      HS(2200)=""
      HS(2201)=""
      HS(2202)=""
      HS(2203)=""
      HS(2204)=""
      HS(2205)=""
      HS(2206)=""
      HS(2207)=""
      HS(2208)=""
      HS(2209)=""
      HS(2210)=""
      HS(2211)=""
      HS(2212)=""
      HS(2213)=""
      HS(2214)=""
      HS(2215)=""
      HS(2216)=""
      HS(2217)=""
      HS(2218)=""
      HS(2219)=""
      HS(2220)=""
      HS(2221)=""
      HS(2222)=""
      HS(2223)=""
      HS(2224)=""
      HS(2225)=""
      HS(2226)=""
      HS(2227)=""
      HS(2228)=""
      HS(2229)=""
      HS(2230)=""
      HS(2231)=""
      HS(2232)=""
      HS(2233)=""
      HS(2234)=""
      HS(2235)=""
      HS(2236)=""
      HS(2237)=""
      HS(2238)=""
      HS(2239)=""
      HS(2240)=""
      HS(2241)=""
      HS(2242)=""
      HS(2243)=""
      HS(2244)=""
      HS(2245)=""
      HS(2246)=""
      HS(2247)=""
      HS(2248)=""
      HS(2249)=""
      HS(2250)=""
      HS(2251)=""
      HS(2252)=""
      HS(2253)=""
      HS(2254)=""
      HS(2255)=""
      HS(2256)=""
      HS(2257)=""
      HS(2258)=""
      HS(2259)=""
      HS(2260)=""
      HS(2261)=""
      HS(2262)=""
      HS(2263)=""
      HS(2264)=""
      HS(2265)=""
      HS(2266)=""
      HS(2267)=""
      HS(2268)=""
      HS(2269)=""
      HS(2270)=""
      HS(2271)=""
      HS(2272)=""
      HS(2273)=""
      HS(2274)=""
      HS(2275)=""
      HS(2276)=""
      HS(2277)=""
      HS(2278)=""
      HS(2279)=""
      HS(2280)=""
      HS(2281)=""
      HS(2282)=""
      HS(2283)=""
      HS(2284)=""
      HS(2285)=""
      HS(2286)=""
      HS(2287)=""
      HS(2288)=""
      HS(2289)=""
      HS(2290)=""
      HS(2291)=""
      HS(2292)=""
      HS(2293)=""
      HS(2294)=""
      HS(2295)=""
      HS(2296)=""
      HS(2297)=""
      HS(2298)=""
      HS(2299)=""
      HS(2300)=""
      HS(2301)=""
      HS(2302)=""
      HS(2303)=""
      HS(2304)=""
      HS(2305)=""
      HS(2306)=""
      HS(2307)=""
      HS(2308)=""
      HS(2309)=""
      HS(2310)=""
      HS(2311)=""
      HS(2312)=""
      HS(2313)=""
      HS(2314)=""
      HS(2315)=""
      HS(2316)=""
      HS(2317)=""
      HS(2318)=""
      HS(2319)=""
      HS(2320)=""
      HS(2321)=""
      HS(2322)=""
      HS(2323)=""
      HS(2324)=""
      HS(2325)=""
      HS(2326)=""
      HS(2327)=""
      HS(2328)=""
      HS(2329)=""
      HS(2330)=""
      HS(2331)=""
      HS(2332)=""
      HS(2333)=""
      HS(2334)=""
      HS(2335)=""
      HS(2336)=""
      HS(2337)=""
      HS(2338)=""
      HS(2339)=""
      HS(2340)=""
      HS(2341)=""
      HS(2342)=""
      HS(2343)=""
      HS(2344)=""
      HS(2345)=""
      HS(2346)=""
      HS(2347)=""
      HS(2348)=""
      HS(2349)=""
      HS(2350)=""
      HS(2351)=""
      HS(2352)=""
      HS(2353)=""
      HS(2354)=""
      HS(2355)=""
      HS(2356)=""
      HS(2357)=""
      HS(2358)=""
      HS(2359)=""
      HS(2360)=""
      HS(2361)=""
      HS(2362)=""
      HS(2363)=""
      HS(2364)=""
      HS(2365)=""
      HS(2366)=""
      HS(2367)=""
      HS(2368)=""
      HS(2369)=""
      HS(2370)=""
      HS(2371)=""
      HS(2372)=""
      HS(2373)=""
      HS(2374)=""
      HS(2375)=""
      HS(2376)=""
      HS(2377)=""
      HS(2378)=""
      HS(2379)=""
      HS(2380)=""
      HS(2381)=""
      HS(2382)=""
      HS(2383)=""
      HS(2384)=""
      HS(2385)=""
      HS(2386)=""
      HS(2387)=""
      HS(2388)=""
      HS(2389)=""
      HS(2390)=""
      HS(2391)=""
      HS(2392)=""
      HS(2393)=""
      HS(2394)=""
      HS(2395)=""
      HS(2396)=""
      HS(2397)=""
      HS(2398)=""
      HS(2399)=""
      HS(2400)=""
      HS(2401)=""
      HS(2402)=""
      HS(2403)=""
      HS(2404)=""
      HS(2405)=""
      HS(2406)=""
      HS(2407)=""
      HS(2408)=""
      HS(2409)=""
      HS(2410)=""
      HS(2411)=""
      HS(2412)=""
      HS(2413)=""
      HS(2414)=""
      HS(2415)=""
      HS(2416)=""
      HS(2417)=""
      HS(2418)=""
      HS(2419)=""
      HS(2420)=""
      HS(2421)=""
      HS(2422)=""
      HS(2423)=""
      HS(2424)=""
      HS(2425)=""
      HS(2426)=""
      HS(2427)=""
      HS(2428)=""
      HS(2429)=""
      HS(2430)=""
      HS(2431)=""
      HS(2432)=""
      HS(2433)=""
      HS(2434)=""
      HS(2435)=""
      HS(2436)=""
      HS(2437)=""
      HS(2438)=""
      HS(2439)=""
      HS(2440)=""
      HS(2441)=""
      HS(2442)=""
      HS(2443)=""
      HS(2444)=""
      HS(2445)=""
      HS(2446)=""
      HS(2447)=""
      HS(2448)=""
      HS(2449)=""
      HS(2450)=""
      HS(2451)=""
      HS(2452)=""
      HS(2453)=""
      HS(2454)=""
      HS(2455)=""
      HS(2456)=""
      HS(2457)=""
      HS(2458)=""
      HS(2459)=""
      HS(2460)=""
      HS(2461)=""
      HS(2462)=""
      HS(2463)=""
      HS(2464)=""
      HS(2465)=""
      HS(2466)=""
      HS(2467)=""
      HS(2468)=""
      HS(2469)=""
      HS(2470)=""
      HS(2471)=""
      HS(2472)=""
      HS(2473)=""
      HS(2474)=""
      HS(2475)=""
      HS(2476)=""
      HS(2477)=""
      HS(2478)=""
      HS(2479)=""
      HS(2480)=""
      HS(2481)=""
      HS(2482)=""
      HS(2483)=""
      HS(2484)=""
      HS(2485)=""
      HS(2486)=""
      HS(2487)=""
      HS(2488)=""
      HS(2489)=""
      HS(2490)=""
      HS(2491)=""
      HS(2492)=""
      HS(2493)=""
      HS(2494)=""
      HS(2495)=""
      HS(2496)=""
      HS(2497)=""
      HS(2498)=""
      HS(2499)=""
      HS(2500)=""
      HS(2501)=""
      HS(2502)=""
      HS(2503)=""
      HS(2504)=""
      HS(2505)=""
      HS(2506)=""
      HS(2507)=""
      HS(2508)=""
      HS(2509)=""
      HS(2510)=""
      HS(2511)=""
      HS(2512)=""
      HS(2513)=""
      HS(2514)=""
      HS(2515)=""
      HS(2516)=""
      HS(2517)=""
      HS(2518)=""
      HS(2519)=""
      HS(2520)=""
      HS(2521)=""
      HS(2522)=""
      HS(2523)=""
      HS(2524)=""
      HS(2525)=""
      HS(2526)=""
      HS(2527)=""
      HS(2528)=""
      HS(2529)=""
      HS(2530)=""
      HS(2531)=""
      HS(2532)=""
      HS(2533)=""
      HS(2534)=""
      HS(2535)=""
      HS(2536)=""
      HS(2537)=""
      HS(2538)=""
      HS(2539)=""
      HS(2540)=""
      HS(2541)=""
      HS(2542)=""
      HS(2543)=""
      HS(2544)=""
      HS(2545)=""
      HS(2546)=""
      HS(2547)=""
      HS(2548)=""
      HS(2549)=""
      HS(2550)=""
      HS(2551)=""
      HS(2552)=""
      HS(2553)=""
      HS(2554)=""
      HS(2555)=""
      HS(2556)=""
      HS(2557)=""
      HS(2558)=""
      HS(2559)=""
      HS(2560)=""
      HS(2561)=""
      HS(2562)=""
      HS(2563)=""
      HS(2564)=""
      HS(2565)=""
      HS(2566)=""
      HS(2567)=""
      HS(2568)=""
      HS(2569)=""
      HS(2570)=""
      HS(2571)=""
      HS(2572)=""
      HS(2573)=""
      HS(2574)=""
      HS(2575)=""
      HS(2576)=""
      HS(2577)=""
      HS(2578)=""
      HS(2579)=""
      HS(2580)=""
      HS(2581)=""
      HS(2582)=""
      HS(2583)=""
      HS(2584)=""
      HS(2585)=""
      HS(2586)=""
      HS(2587)=""
      HS(2588)=""
      HS(2589)=""
      HS(2590)=""
      HS(2591)=""
      HS(2592)=""
      HS(2593)=""
      HS(2594)=""
      HS(2595)=""
      HS(2596)=""
      HS(2597)=""
      HS(2598)=""
      HS(2599)=""
      HS(2600)=""
      HS(2601)=""
      HS(2602)=""
      HS(2603)=""
      HS(2604)=""
      HS(2605)=""
      HS(2606)=""
      HS(2607)=""
      HS(2608)=""
      HS(2609)=""
      HS(2610)=""
      HS(2611)=""
      HS(2612)=""
      HS(2613)=""
      HS(2614)=""
      HS(2615)=""
      HS(2616)=""
      HS(2617)=""
      HS(2618)=""
      HS(2619)=""
      HS(2620)=""
      HS(2621)=""
      HS(2622)=""
      HS(2623)=""
      HS(2624)=""
      HS(2625)=""
      HS(2626)=""
      HS(2627)=""
      HS(2628)=""
      HS(2629)=""
      HS(2630)=""
      HS(2631)=""
      HS(2632)=""
      HS(2633)=""
      HS(2634)=""
      HS(2635)=""
      HS(2636)=""
      HS(2637)=""
      HS(2638)=""
      HS(2639)=""
      HS(2640)=""
      HS(2641)=""
      HS(2642)=""
      HS(2643)=""
      HS(2644)=""
      HS(2645)=""
      HS(2646)=""
      HS(2647)=""
      HS(2648)=""
      HS(2649)=""
      HS(2650)=""
      HS(2651)=""
      HS(2652)=""
      HS(2653)=""
      HS(2654)=""
      HS(2655)=""
      HS(2656)=""
      HS(2657)=""
      HS(2658)=""
      HS(2659)=""
      HS(2660)=""
      HS(2661)=""
      HS(2662)=""
      HS(2663)=""
      HS(2664)=""
      HS(2665)=""
      HS(2666)=""
      HS(2667)=""
      HS(2668)=""
      HS(2669)=""
      HS(2670)=""
      HS(2671)=""
      HS(2672)=""
      HS(2673)=""
      HS(2674)=""
      HS(2675)=""
      HS(2676)=""
      HS(2677)=""
      HS(2678)=""
      HS(2679)=""
      HS(2680)=""
      HS(2681)=""
      HS(2682)=""
      HS(2683)=""
      HS(2684)=""
      HS(2685)=""
      HS(2686)=""
      HS(2687)=""
      HS(2688)=""
      HS(2689)=""
      HS(2690)=""
      HS(2691)=""
      HS(2692)=""
      HS(2693)=""
      HS(2694)=""
      HS(2695)=""
      HS(2696)=""
      HS(2697)=""
      HS(2698)=""
      HS(2699)=""
      HS(2700)=""
      HS(2701)=""
      HS(2702)=""
      HS(2703)=""
      HS(2704)=""
      HS(2705)=""
      HS(2706)=""
      HS(2707)=""
      HS(2708)=""
      HS(2709)=""
      HS(2710)=""
      HS(2711)=""
      HS(2712)=""
      HS(2713)=""
      HS(2714)=""
      HS(2715)=""
      HS(2716)=""
      HS(2717)=""
      HS(2718)=""
      HS(2719)=""
      HS(2720)=""
      HS(2721)=""
      HS(2722)=""
      HS(2723)=""
      HS(2724)=""
      HS(2725)=""
      HS(2726)=""
      HS(2727)=""
      HS(2728)=""
      HS(2729)=""
      HS(2730)=""
      HS(2731)=""
      HS(2732)=""
      HS(2733)=""
      HS(2734)=""
      HS(2735)=""
      HS(2736)=""
      HS(2737)=""
      HS(2738)=""
      HS(2739)=""
      HS(2740)=""
      HS(2741)=""
      HS(2742)=""
      HS(2743)=""
      HS(2744)=""
      HS(2745)=""
      HS(2746)=""
      HS(2747)=""
      HS(2748)=""
      HS(2749)=""
      HS(2750)=""
      HS(2751)=""
      HS(2752)=""
      HS(2753)=""
      HS(2754)=""
      HS(2755)=""
      HS(2756)=""
      HS(2757)=""
      HS(2758)=""
      HS(2759)=""
      HS(2760)=""
      HS(2761)=""
      HS(2762)=""
      HS(2763)=""
      HS(2764)=""
      HS(2765)=""
      HS(2766)=""
      HS(2767)=""
      HS(2768)=""
      HS(2769)=""
      HS(2770)=""
      HS(2771)=""
      HS(2772)=""
      HS(2773)=""
      HS(2774)=""
      HS(2775)=""
      HS(2776)=""
      HS(2777)=""
      HS(2778)=""
      HS(2779)=""
      HS(2780)=""
      HS(2781)=""
      HS(2782)=""
      HS(2783)=""
      HS(2784)=""
      HS(2785)=""
      HS(2786)=""
      HS(2787)=""
      HS(2788)=""
      HS(2789)=""
      HS(2790)=""
      HS(2791)=""
      HS(2792)=""
      HS(2793)=""
      HS(2794)=""
      HS(2795)=""
      HS(2796)=""
      HS(2797)=""
      HS(2798)=""
      HS(2799)=""
      HS(2800)=""
      HS(2801)=""
      HS(2802)=""
      HS(2803)=""
      HS(2804)=""
      HS(2805)=""
      HS(2806)=""
      HS(2807)=""
      HS(2808)=""
      HS(2809)=""
      HS(2810)=""
      HS(2811)=""
      HS(2812)=""
      HS(2813)=""
      HS(2814)=""
      HS(2815)=""
      HS(2816)=""
      HS(2817)=""
      HS(2818)=""
      HS(2819)=""
      HS(2820)=""
      HS(2821)=""
      HS(2822)=""
      HS(2823)=""
      HS(2824)=""
      HS(2825)=""
      HS(2826)=""
      HS(2827)=""
      HS(2828)=""
      HS(2829)=""
      HS(2830)=""
      HS(2831)=""
      HS(2832)=""
      HS(2833)=""
      HS(2834)=""
      HS(2835)=""
      HS(2836)=""
      HS(2837)=""
      HS(2838)=""
      HS(2839)=""
      HS(2840)=""
      HS(2841)=""
      HS(2842)=""
      HS(2843)=""
      HS(2844)=""
      HS(2845)=""
      HS(2846)=""
      HS(2847)=""
      HS(2848)=""
      HS(2849)=""
      HS(2850)=""
      HS(2851)=""
      HS(2852)=""
      HS(2853)=""
      HS(2854)=""
      HS(2855)=""
      HS(2856)=""
      HS(2857)=""
      HS(2858)=""
      HS(2859)=""
      HS(2860)=""
      HS(2861)=""
      HS(2862)=""
      HS(2863)=""
      HS(2864)=""
      HS(2865)=""
      HS(2866)=""
      HS(2867)=""
      HS(2868)=""
      HS(2869)=""
      HS(2870)=""
      HS(2871)=""
      HS(2872)=""
      HS(2873)=""
      HS(2874)=""
      HS(2875)=""
      HS(2876)=""
      HS(2877)=""
      HS(2878)=""
      HS(2879)=""
      HS(2880)=""
      HS(2881)=""
      HS(2882)=""
      HS(2883)=""
      HS(2884)=""
      HS(2885)=""
      HS(2886)=""
      HS(2887)=""
      HS(2888)=""
      HS(2889)=""
      HS(2890)=""
      HS(2891)=""
      HS(2892)=""
      HS(2893)=""
      HS(2894)=""
      HS(2895)=""
      HS(2896)=""
      HS(2897)=""
      HS(2898)=""
      HS(2899)=""
      HS(2900)=""
      HS(2901)=""
      HS(2902)=""
      HS(2903)=""
      HS(2904)=""
      HS(2905)=""
      HS(2906)=""
      HS(2907)=""
      HS(2908)=""
      HS(2909)=""
      HS(2910)=""
      HS(2911)=""
      HS(2912)=""
      HS(2913)=""
      HS(2914)=""
      HS(2915)=""
      HS(2916)=""
      HS(2917)=""
      HS(2918)=""
      HS(2919)=""
      HS(2920)=""
      HS(2921)=""
      HS(2922)=""
      HS(2923)=""
      HS(2924)=""
      HS(2925)=""
      HS(2926)=""
      HS(2927)=""
      HS(2928)=""
      HS(2929)=""
      HS(2930)=""
      HS(2931)=""
      HS(2932)=""
      HS(2933)=""
      HS(2934)=""
      HS(2935)=""
      HS(2936)=""
      HS(2937)=""
      HS(2938)=""
      HS(2939)=""
      HS(2940)=""
      HS(2941)=""
      HS(2942)=""
      HS(2943)=""
      HS(2944)=""
      HS(2945)=""
      HS(2946)=""
      HS(2947)=""
      HS(2948)=""
      HS(2949)=""
      HS(2950)=""
      HS(2951)=""
      HS(2952)=""
      HS(2953)=""
      HS(2954)=""
      HS(2955)=""
      HS(2956)=""
      HS(2957)=""
      HS(2958)=""
      HS(2959)=""
      HS(2960)=""
      HS(2961)=""
      HS(2962)=""
      HS(2963)=""
      HS(2964)=""
      HS(2965)=""
      HS(2966)=""
      HS(2967)=""
      HS(2968)=""
      HS(2969)=""
      HS(2970)=""
      HS(2971)=""
      HS(2972)=""
      HS(2973)=""
      HS(2974)=""
      HS(2975)=""
      HS(2976)=""
      HS(2977)=""
      HS(2978)=""
      HS(2979)=""
      HS(2980)=""
      HS(2981)=""
      HS(2982)=""
      HS(2983)=""
      HS(2984)=""
      HS(2985)=""
      HS(2986)=""
      HS(2987)=""
      HS(2988)=""
      HS(2989)=""
      HS(2990)=""
      HS(2991)=""
      HS(2992)=""
      HS(2993)=""
      HS(2994)=""
      HS(2995)=""
      HS(2996)=""
      HS(2997)=""
      HS(2998)=""
      HS(2999)=""
      HS(3000)=""
      HS(3001)=""
      HS(3002)=""
      HS(3003)=""
      HS(3004)=""
      HS(3005)=""
      HS(3006)=""
      HS(3007)=""
      HS(3008)=""
      HS(3009)=""
      HS(3010)=""
      HS(3011)=""
      HS(3012)=""
      HS(3013)=""
      HS(3014)=""
      HS(3015)=""
      HS(3016)=""
      HS(3017)=""
      HS(3018)=""
      HS(3019)=""
      HS(3020)=""
      HS(3021)=""
      HS(3022)=""
      HS(3023)=""
      HS(3024)=""
      HS(3025)=""
      HS(3026)=""
      HS(3027)=""
      HS(3028)=""
      HS(3029)=""
      HS(3030)=""
      HS(3031)=""
      HS(3032)=""
      HS(3033)=""
      HS(3034)=""
      HS(3035)=""
      HS(3036)=""
      HS(3037)=""
      HS(3038)=""
      HS(3039)=""
      HS(3040)=""
      HS(3041)=""
      HS(3042)=""
      HS(3043)=""
      HS(3044)=""
      HS(3045)=""
      HS(3046)=""
      HS(3047)=""
      HS(3048)=""
      HS(3049)=""
      HS(3050)=""
      HS(3051)=""
      HS(3052)=""
      HS(3053)=""
      HS(3054)=""
      HS(3055)=""
      HS(3056)=""
      HS(3057)=""
      HS(3058)=""
      HS(3059)=""
      HS(3060)=""
      HS(3061)=""
      HS(3062)=""
      HS(3063)=""
      HS(3064)=""
      HS(3065)=""
      HS(3066)=""
      HS(3067)=""
      HS(3068)=""
      HS(3069)=""
      HS(3070)=""
      HS(3071)=""
      HS(3072)=""
      HS(3073)=""
      HS(3074)=""
      HS(3075)=""
      HS(3076)=""
      HS(3077)=""
      HS(3078)=""
      HS(3079)=""
      HS(3080)=""
      HS(3081)=""
      HS(3082)=""
      HS(3083)=""
      HS(3084)=""
      HS(3085)=""
      HS(3086)=""
      HS(3087)=""
      HS(3088)=""
      HS(3089)=""
      HS(3090)=""
      HS(3091)=""
      HS(3092)=""
      HS(3093)=""
      HS(3094)=""
      HS(3095)=""
      HS(3096)=""
      HS(3097)=""
      HS(3098)=""
      HS(3099)=""
      HS(3100)=""
      HS(3101)=""
      HS(3102)=""
      HS(3103)=""
      HS(3104)=""
      HS(3105)=""
      HS(3106)=""
      HS(3107)=""
      HS(3108)=""
      HS(3109)=""
      HS(3110)=""
      HS(3111)=""
      HS(3112)=""
      HS(3113)=""
      HS(3114)=""
      HS(3115)=""
      HS(3116)=""
      HS(3117)=""
      HS(3118)=""
      HS(3119)=""
      HS(3120)=""
      HS(3121)=""
      HS(3122)=""
      HS(3123)=""
      HS(3124)=""
      HS(3125)=""
      HS(3126)=""
      HS(3127)=""
      HS(3128)=""
      HS(3129)=""
      HS(3130)=""
      HS(3131)=""
      HS(3132)=""
      HS(3133)=""
      HS(3134)=""
      HS(3135)=""
      HS(3136)=""
      HS(3137)=""
      HS(3138)=""
      HS(3139)=""
      HS(3140)=""
      HS(3141)=""
      HS(3142)=""
      HS(3143)=""
      HS(3144)=""
      HS(3145)=""
      HS(3146)=""
      HS(3147)=""
      HS(3148)=""
      HS(3149)=""
      HS(3150)=""
      HS(3151)=""
      HS(3152)=""
      HS(3153)=""
      HS(3154)=""
      HS(3155)=""
      HS(3156)=""
      HS(3157)=""
      HS(3158)=""
      HS(3159)=""
      HS(3160)=""
      HS(3161)=""
      HS(3162)=""
      HS(3163)=""
      HS(3164)=""
      HS(3165)=""
      HS(3166)=""
      HS(3167)=""
      HS(3168)=""
      HS(3169)=""
      HS(3170)=""
      HS(3171)=""
      HS(3172)=""
      HS(3173)=""
      HS(3174)=""
      HS(3175)=""
      HS(3176)=""
      HS(3177)=""
      HS(3178)=""
      HS(3179)=""
      HS(3180)=""
      HS(3181)=""
      HS(3182)=""
      HS(3183)=""
      HS(3184)=""
      HS(3185)=""
      HS(3186)=""
      HS(3187)=""
      HS(3188)=""
      HS(3189)=""
      HS(3190)=""
      HS(3191)=""
      HS(3192)=""
      HS(3193)=""
      HS(3194)=""
      HS(3195)=""
      HS(3196)=""
      HS(3197)=""
      HS(3198)=""
      HS(3199)=""
      HS(3200)=""
      HS(3201)=""
      HS(3202)=""
      HS(3203)=""
      HS(3204)=""
      HS(3205)=""
      HS(3206)=""
      HS(3207)=""
      HS(3208)=""
      HS(3209)=""
      HS(3210)=""
      HS(3211)=""
      HS(3212)=""
      HS(3213)=""
      HS(3214)=""
      HS(3215)=""
      HS(3216)=""
      HS(3217)=""
      HS(3218)=""
      HS(3219)=""
      HS(3220)=""
      HS(3221)=""
      HS(3222)=""
      HS(3223)=""
      HS(3224)=""
      HS(3225)=""
      HS(3226)=""
      HS(3227)=""
      HS(3228)=""
      HS(3229)=""
      HS(3230)=""
      HS(3231)=""
      HS(3232)=""
      HS(3233)=""
      HS(3234)=""
      HS(3235)=""
      HS(3236)=""
      HS(3237)=""
      HS(3238)=""
      HS(3239)=""
      HS(3240)=""
      HS(3241)=""
      HS(3242)=""
      HS(3243)=""
      HS(3244)=""
      HS(3245)=""
      HS(3246)=""
      HS(3247)=""
      HS(3248)=""
      HS(3249)=""
      HS(3250)=""
      HS(3251)=""
      HS(3252)=""
      HS(3253)=""
      HS(3254)=""
      HS(3255)=""
      HS(3256)=""
      HS(3257)=""
      HS(3258)=""
      HS(3259)=""
      HS(3260)=""
      HS(3261)=""
      HS(3262)=""
      HS(3263)=""
      HS(3264)=""
      HS(3265)=""
      HS(3266)=""
      HS(3267)=""
      HS(3268)=""
      HS(3269)=""
      HS(3270)=""
      HS(3271)=""
      HS(3272)=""
      HS(3273)=""
      HS(3274)=""
      HS(3275)=""
      HS(3276)=""
      HS(3277)=""
      HS(3278)=""
      HS(3279)=""
      HS(3280)=""
      HS(3281)=""
      HS(3282)=""
      HS(3283)=""
      HS(3284)=""
      HS(3285)=""
      HS(3286)=""
      HS(3287)=""
      HS(3288)=""
      HS(3289)=""
      HS(3290)=""
      HS(3291)=""
      HS(3292)=""
      HS(3293)=""
      HS(3294)=""
      HS(3295)=""
      HS(3296)=""
      HS(3297)=""
      HS(3298)=""
      HS(3299)=""
      HS(3300)=""
      HS(3301)=""
      HS(3302)=""
      HS(3303)=""
      HS(3304)=""
      HS(3305)=""
      HS(3306)=""
      HS(3307)=""
      HS(3308)=""
      HS(3309)=""
      HS(3310)=""
      HS(3311)=""
      HS(3312)=""
      HS(3313)=""
      HS(3314)=""
      HS(3315)=""
      HS(3316)=""
      HS(3317)=""
      HS(3318)=""
      HS(3319)=""
      HS(3320)=""
      HS(3321)=""
      HS(3322)=""
      HS(3323)=""
      HS(3324)=""
      HS(3325)=""
      HS(3326)=""
      HS(3327)=""
      HS(3328)=""
      HS(3329)=""
      HS(3330)=""
      HS(3331)=""
      HS(3332)=""
      HS(3333)=""
      HS(3334)=""
      HS(3335)=""
      HS(3336)=""
      HS(3337)=""
      HS(3338)=""
      HS(3339)=""
      HS(3340)=""
      HS(3341)=""
      HS(3342)=""
      HS(3343)=""
      HS(3344)=""
      HS(3345)=""
      HS(3346)=""
      HS(3347)=""
      HS(3348)=""
      HS(3349)=""
      HS(3350)=""
      HS(3351)=""
      HS(3352)=""
      HS(3353)=""
      HS(3354)=""
      HS(3355)=""
      HS(3356)=""
      HS(3357)=""
      HS(3358)=""
      HS(3359)=""
      HS(3360)=""
      HS(3361)=""
      HS(3362)=""
      HS(3363)=""
      HS(3364)=""
      HS(3365)=""
      HS(3366)=""
      HS(3367)=""
      HS(3368)=""
      HS(3369)=""
      HS(3370)=""
      HS(3371)=""
      HS(3372)=""
      HS(3373)=""
      HS(3374)=""
      HS(3375)=""
      HS(3376)=""
      HS(3377)=""
      HS(3378)=""
      HS(3379)=""
      HS(3380)=""
      HS(3381)=""
      HS(3382)=""
      HS(3383)=""
      HS(3384)=""
      HS(3385)=""
      HS(3386)=""
      HS(3387)=""
      HS(3388)=""
      HS(3389)=""
      HS(3390)=""
      HS(3391)=""
      HS(3392)=""
      HS(3393)=""
      HS(3394)=""
      HS(3395)=""
      HS(3396)=""
      HS(3397)=""
      HS(3398)=""
      HS(3399)=""
      HS(3400)=""
      HS(3401)=""
      HS(3402)=""
      HS(3403)=""
      HS(3404)=""
      HS(3405)=""
      HS(3406)=""
      HS(3407)=""
      HS(3408)=""
      HS(3409)=""
      HS(3410)=""
      HS(3411)=""
      HS(3412)=""
      HS(3413)=""
      HS(3414)=""
      HS(3415)=""
      HS(3416)=""
      HS(3417)=""
      HS(3418)=""
      HS(3419)=""
      HS(3420)=""
      HS(3421)=""
      HS(3422)=""
      HS(3423)=""
      HS(3424)=""
      HS(3425)=""
      HS(3426)=""
      HS(3427)=""
      HS(3428)=""
      HS(3429)=""
      HS(3430)=""
      HS(3431)=""
      HS(3432)=""
      HS(3433)=""
      HS(3434)=""
      HS(3435)=""
      HS(3436)=""
      HS(3437)=""
      HS(3438)=""
      HS(3439)=""
      HS(3440)=""
      HS(3441)=""
      HS(3442)=""
      HS(3443)=""
      HS(3444)=""
      HS(3445)=""
      HS(3446)=""
      HS(3447)=""
      HS(3448)=""
      HS(3449)=""
      HS(3450)=""
      HS(3451)=""
      HS(3452)=""
      HS(3453)=""
      HS(3454)=""
      HS(3455)=""
      HS(3456)=""
      HS(3457)=""
      HS(3458)=""
      HS(3459)=""
      HS(3460)=""
      HS(3461)=""
      HS(3462)=""
      HS(3463)=""
      HS(3464)=""
      HS(3465)=""
      HS(3466)=""
      HS(3467)=""
      HS(3468)=""
      HS(3469)=""
      HS(3470)=""
      HS(3471)=""
      HS(3472)=""
      HS(3473)=""
      HS(3474)=""
      HS(3475)=""
      HS(3476)=""
      HS(3477)=""
      HS(3478)=""
      HS(3479)=""
      HS(3480)=""
      HS(3481)=""
      HS(3482)=""
      HS(3483)=""
      HS(3484)=""
      HS(3485)=""
      HS(3486)=""
      HS(3487)=""
      HS(3488)=""
      HS(3489)=""
      HS(3490)=""
      HS(3491)=""
      HS(3492)=""
      HS(3493)=""
      HS(3494)=""
      HS(3495)=""
      HS(3496)=""
      HS(3497)=""
      HS(3498)=""
      HS(3499)=""
      HS(3500)=""
      HS(3501)=""
      HS(3502)=""
      HS(3503)=""
      HS(3504)=""
      HS(3505)=""
      HS(3506)=""
      HS(3507)=""
      HS(3508)=""
      HS(3509)=""
      HS(3510)=""
      HS(3511)=""
      HS(3512)=""
      HS(3513)=""
      HS(3514)=""
      HS(3515)=""
      HS(3516)=""
      HS(3517)=""
      HS(3518)=""
      HS(3519)=""
      HS(3520)=""
      HS(3521)=""
      HS(3522)=""
      HS(3523)=""
      HS(3524)=""
      HS(3525)=""
      HS(3526)=""
      HS(3527)=""
      HS(3528)=""
      HS(3529)=""
      HS(3530)=""
      HS(3531)=""
      HS(3532)=""
      HS(3533)=""
      HS(3534)=""
      HS(3535)=""
      HS(3536)=""
      HS(3537)=""
      HS(3538)=""
      HS(3539)=""
      HS(3540)=""
      HS(3541)=""
      HS(3542)=""
      HS(3543)=""
      HS(3544)=""
      HS(3545)=""
      HS(3546)=""
      HS(3547)=""
      HS(3548)=""
      HS(3549)=""
      HS(3550)=""
      HS(3551)=""
      HS(3552)=""
      HS(3553)=""
      HS(3554)=""
      HS(3555)=""
      HS(3556)=""
      HS(3557)=""
      HS(3558)=""
      HS(3559)=""
      HS(3560)=""
      HS(3561)=""
      HS(3562)=""
      HS(3563)=""
      HS(3564)=""
      HS(3565)=""
      HS(3566)=""
      HS(3567)=""
      HS(3568)=""
      HS(3569)=""
      HS(3570)=""
      HS(3571)=""
      HS(3572)=""
      HS(3573)=""
      HS(3574)=""
      HS(3575)=""
      HS(3576)=""
      HS(3577)=""
      HS(3578)=""
      HS(3579)=""
      HS(3580)=""
      HS(3581)=""
      HS(3582)=""
      HS(3583)=""
      HS(3584)=""
      HS(3585)=""
      HS(3586)=""
      HS(3587)=""
      HS(3588)=""
      HS(3589)=""
      HS(3590)=""
      HS(3591)=""
      HS(3592)=""
      HS(3593)=""
      HS(3594)=""
      HS(3595)=""
      HS(3596)=""
      HS(3597)=""
      HS(3598)=""
      HS(3599)=""
      HS(3600)=""
      HS(3601)=""
      HS(3602)=""
      HS(3603)=""
      HS(3604)=""
      HS(3605)=""
      HS(3606)=""
      HS(3607)=""
      HS(3608)=""
      HS(3609)=""
      HS(3610)=""
      HS(3611)=""
      HS(3612)=""
      HS(3613)=""
      HS(3614)=""
      HS(3615)=""
      HS(3616)=""
      HS(3617)=""
      HS(3618)=""
      HS(3619)=""
      HS(3620)=""
      HS(3621)=""
      HS(3622)=""
      HS(3623)=""
      HS(3624)=""
      HS(3625)=""
      HS(3626)=""
      HS(3627)=""
      HS(3628)=""
      HS(3629)=""
      HS(3630)=""
      HS(3631)=""
      HS(3632)=""
      HS(3633)=""
      HS(3634)=""
      HS(3635)=""
      HS(3636)=""
      HS(3637)=""
      HS(3638)=""
      HS(3639)=""
      HS(3640)=""
      HS(3641)=""
      HS(3642)=""
      HS(3643)=""
      HS(3644)=""
      HS(3645)=""
      HS(3646)=""
      HS(3647)=""
      HS(3648)=""
      HS(3649)=""
      HS(3650)=""
      HS(3651)=""
      HS(3652)=""
      HS(3653)=""
      HS(3654)=""
      HS(3655)=""
      HS(3656)=""
      HS(3657)=""
      HS(3658)=""
      HS(3659)=""
      HS(3660)=""
      HS(3661)=""
      HS(3662)=""
      HS(3663)=""
      HS(3664)=""
      HS(3665)=""
      HS(3666)=""
      HS(3667)=""
      HS(3668)=""
      HS(3669)=""
      HS(3670)=""
      HS(3671)=""
      HS(3672)=""
      HS(3673)=""
      HS(3674)=""
      HS(3675)=""
      HS(3676)=""
      HS(3677)=""
      HS(3678)=""
      HS(3679)=""
      HS(3680)=""
      HS(3681)=""
      HS(3682)=""
      HS(3683)=""
      HS(3684)=""
      HS(3685)=""
      HS(3686)=""
      HS(3687)=""
      HS(3688)=""
      HS(3689)=""
      HS(3690)=""
      HS(3691)=""
      HS(3692)=""
      HS(3693)=""
      HS(3694)=""
      HS(3695)=""
      HS(3696)=""
      HS(3697)=""
      HS(3698)=""
      HS(3699)=""
      HS(3700)=""
      HS(3701)=""
      HS(3702)=""
      HS(3703)=""
      HS(3704)=""
      HS(3705)=""
      HS(3706)=""
      HS(3707)=""
      HS(3708)=""
      HS(3709)=""
      HS(3710)=""
      HS(3711)=""
      HS(3712)=""
      HS(3713)=""
      HS(3714)=""
      HS(3715)=""
      HS(3716)=""
      HS(3717)=""
      HS(3718)=""
      HS(3719)=""
      HS(3720)=""
      HS(3721)=""
      HS(3722)=""
      HS(3723)=""
      HS(3724)=""
      HS(3725)=""
      HS(3726)=""
      HS(3727)=""
      HS(3728)=""
      HS(3729)=""
      HS(3730)=""
      HS(3731)=""
      HS(3732)=""
      HS(3733)=""
      HS(3734)=""
      HS(3735)=""
      HS(3736)=""
      HS(3737)=""
      HS(3738)=""
      HS(3739)=""
      HS(3740)=""
      HS(3741)=""
      HS(3742)=""
      HS(3743)=""
      HS(3744)=""
      HS(3745)=""
      HS(3746)=""
      HS(3747)=""
      HS(3748)=""
      HS(3749)=""
      HS(3750)=""
      HS(3751)=""
      HS(3752)=""
      HS(3753)=""
      HS(3754)=""
      HS(3755)=""
      HS(3756)=""
      HS(3757)=""
      HS(3758)=""
      HS(3759)=""
      HS(3760)=""
      HS(3761)=""
      HS(3762)=""
      HS(3763)=""
      HS(3764)=""
      HS(3765)=""
      HS(3766)=""
      HS(3767)=""
      HS(3768)=""
      HS(3769)=""
      HS(3770)=""
      HS(3771)=""
      HS(3772)=""
      HS(3773)=""
      HS(3774)=""
      HS(3775)=""
      HS(3776)=""
      HS(3777)=""
      HS(3778)=""
      HS(3779)=""
      HS(3780)=""
      HS(3781)=""
      HS(3782)=""
      HS(3783)=""
      HS(3784)=""
      HS(3785)=""
      HS(3786)=""
      HS(3787)=""
      HS(3788)=""
      HS(3789)=""
      HS(3790)=""
      HS(3791)=""
      HS(3792)=""
      HS(3793)=""
      HS(3794)=""
      HS(3795)=""
      HS(3796)=""
      HS(3797)=""
      HS(3798)=""
      HS(3799)=""
      HS(3800)=""
      HS(3801)=""
      HS(3802)=""
      HS(3803)=""
      HS(3804)=""
      HS(3805)=""
      HS(3806)=""
      HS(3807)=""
      HS(3808)=""
      HS(3809)=""
      HS(3810)=""
      HS(3811)=""
      HS(3812)=""
      HS(3813)=""
      HS(3814)=""
      HS(3815)=""
      HS(3816)=""
      HS(3817)=""
      HS(3818)=""
      HS(3819)=""
      HS(3820)=""
      HS(3821)=""
      HS(3822)=""
      HS(3823)=""
      HS(3824)=""
      HS(3825)=""
      HS(3826)=""
      HS(3827)=""
      HS(3828)=""
      HS(3829)=""
      HS(3830)=""
      HS(3831)=""
      HS(3832)=""
      HS(3833)=""
      HS(3834)=""
      HS(3835)=""
      HS(3836)=""
      HS(3837)=""
      HS(3838)=""
      HS(3839)=""
      HS(3840)=""
      HS(3841)=""
      HS(3842)=""
      HS(3843)=""
      HS(3844)=""
      HS(3845)=""
      HS(3846)=""
      HS(3847)=""
      HS(3848)=""
      HS(3849)=""
      HS(3850)=""
      HS(3851)=""
      HS(3852)=""
      HS(3853)=""
      HS(3854)=""
      HS(3855)=""
      HS(3856)=""
      HS(3857)=""
      HS(3858)=""
      HS(3859)=""
      HS(3860)=""
      HS(3861)=""
      HS(3862)=""
      HS(3863)=""
      HS(3864)=""
      HS(3865)=""
      HS(3866)=""
      HS(3867)=""
      HS(3868)=""
      HS(3869)=""
      HS(3870)=""
      HS(3871)=""
      HS(3872)=""
      HS(3873)=""
      HS(3874)=""
      HS(3875)=""
      HS(3876)=""
      HS(3877)=""
      HS(3878)=""
      HS(3879)=""
      HS(3880)=""
      HS(3881)=""
      HS(3882)=""
      HS(3883)=""
      HS(3884)=""
      HS(3885)=""
      HS(3886)=""
      HS(3887)=""
      HS(3888)=""
      HS(3889)=""
      HS(3890)=""
      HS(3891)=""
      HS(3892)=""
      HS(3893)=""
      HS(3894)=""
      HS(3895)=""
      HS(3896)=""
      HS(3897)=""
      HS(3898)=""
      HS(3899)=""
      HS(3900)=""
      HS(3901)=""
      HS(3902)=""
      HS(3903)=""
      HS(3904)=""
      HS(3905)=""
      HS(3906)=""
      HS(3907)=""
      HS(3908)=""
      HS(3909)=""
      HS(3910)=""
      HS(3911)=""
      HS(3912)=""
      HS(3913)=""
      HS(3914)=""
      HS(3915)=""
      HS(3916)=""
      HS(3917)=""
      HS(3918)=""
      HS(3919)=""
      HS(3920)=""
      HS(3921)=""
      HS(3922)=""
      HS(3923)=""
      HS(3924)=""
      HS(3925)=""
      HS(3926)=""
      HS(3927)=""
      HS(3928)=""
      HS(3929)=""
      HS(3930)=""
      HS(3931)=""
      HS(3932)=""
      HS(3933)=""
      HS(3934)=""
      HS(3935)=""
      HS(3936)=""
      HS(3937)=""
      HS(3938)=""
      HS(3939)=""
      HS(3940)=""
      HS(3941)=""
      HS(3942)=""
      HS(3943)=""
      HS(3944)=""
      HS(3945)=""
      HS(3946)=""
      HS(3947)=""
      HS(3948)=""
      HS(3949)=""
      HS(3950)=""
      HS(3951)=""
      HS(3952)=""
      HS(3953)=""
      HS(3954)=""
      HS(3955)=""
      HS(3956)=""
      HS(3957)=""
      HS(3958)=""
      HS(3959)=""
      HS(3960)=""
      HS(3961)=""
      HS(3962)=""
      HS(3963)=""
      HS(3964)=""
      HS(3965)=""
      HS(3966)=""
      HS(3967)=""
      HS(3968)=""
      HS(3969)=""
      HS(3970)=""
      HS(3971)=""
      HS(3972)=""
      HS(3973)=""
      HS(3974)=""
      HS(3975)=""
      HS(3976)=""
      HS(3977)=""
      HS(3978)=""
      HS(3979)=""
      HS(3980)=""
      HS(3981)=""
      HS(3982)=""
      HS(3983)=""
      HS(3984)=""
      HS(3985)=""
      HS(3986)=""
      HS(3987)=""
      HS(3988)=""
      HS(3989)=""
      HS(3990)=""
      HS(3991)=""
      HS(3992)=""
      HS(3993)=""
      HS(3994)=""
      HS(3995)=""
      HS(3996)=""
      HS(3997)=""
      HS(3998)=""
      HS(3999)=""
      HS(4000)=""
      HS(4001)=""
      HS(4002)=""
      HS(4003)=""
      HS(4004)=""
      HS(4005)=""
      HS(4006)=""
      HS(4007)=""
      HS(4008)=""
      HS(4009)=""
      HS(4010)=""
      HS(4011)=""
      HS(4012)=""
      HS(4013)=""
      HS(4014)=""
      HS(4015)=""
      HS(4016)=""
      HS(4017)=""
      HS(4018)=""
      HS(4019)=""
      HS(4020)=""
      HS(4021)=""
      HS(4022)=""
      HS(4023)=""
      HS(4024)=""
      HS(4025)=""
      HS(4026)=""
      HS(4027)=""
      HS(4028)=""
      HS(4029)=""
      HS(4030)=""
      HS(4031)=""
      HS(4032)=""
      HS(4033)=""
      HS(4034)=""
      HS(4035)=""
      HS(4036)=""
      HS(4037)=""
      HS(4038)=""
      HS(4039)=""
      HS(4040)=""
      HS(4041)=""
      HS(4042)=""
      HS(4043)=""
      HS(4044)=""
      HS(4045)=""
      HS(4046)=""
      HS(4047)=""
      HS(4048)=""
      HS(4049)=""
      HS(4050)=""
      HS(4051)=""
      HS(4052)=""
      HS(4053)=""
      HS(4054)=""
      HS(4055)=""
      HS(4056)=""
      HS(4057)=""
      HS(4058)=""
      HS(4059)=""
      HS(4060)=""
      HS(4061)=""
      HS(4062)=""
      HS(4063)=""
      HS(4064)=""
      HS(4065)=""
      HS(4066)=""
      HS(4067)=""
      HS(4068)=""
      HS(4069)=""
      HS(4070)=""
      HS(4071)=""
      HS(4072)=""
      HS(4073)=""
      HS(4074)=""
      HS(4075)=""
      HS(4076)=""
      HS(4077)=""
      HS(4078)=""
      HS(4079)=""
      HS(4080)=""
      HS(4081)=""
      HS(4082)=""
      HS(4083)=""
      HS(4084)=""
      HS(4085)=""
      HS(4086)=""
      HS(4087)=""
      HS(4088)=""
      HS(4089)=""
      HS(4090)=""
      HS(4091)=""
      HS(4092)=""
      HS(4093)=""
      HS(4094)=""
      HS(4095)=""
      HS(4096)=""
      HS(4097)=""
      HS(4098)=""
      HS(4099)=""
      HS(4100)=""
      HS(4101)=""
      HS(4102)=""
      HS(4103)=""
      HS(4104)=""
      HS(4105)=""
      HS(4106)=""
      HS(4107)=""
      HS(4108)=""
      HS(4109)=""
      HS(4110)=""
      HS(4111)=""
      HS(4112)=""
      HS(4113)=""
      HS(4114)=""
      HS(4115)=""
      HS(4116)=""
      HS(4117)=""
      HS(4118)=""
      HS(4119)=""
      HS(4120)=""
      HS(4121)=""
      HS(4122)=""
      HS(4123)=""
      HS(4124)=""
      HS(4125)=""
      HS(4126)=""
      HS(4127)=""
      HS(4128)=""
      HS(4129)=""
      HS(4130)=""
      HS(4131)=""
      HS(4132)=""
      HS(4133)=""
      HS(4134)=""
      HS(4135)=""
      HS(4136)=""
      HS(4137)=""
      HS(4138)=""
      HS(4139)=""
      HS(4140)=""
      HS(4141)=""
      HS(4142)=""
      HS(4143)=""
      HS(4144)=""
      HS(4145)=""
      HS(4146)=""
      HS(4147)=""
      HS(4148)=""
      HS(4149)=""
      HS(4150)=""
      HS(4151)=""
      HS(4152)=""
      HS(4153)=""
      HS(4154)=""
      HS(4155)=""
      HS(4156)=""
      HS(4157)=""
      HS(4158)=""
      HS(4159)=""
      HS(4160)=""
      HS(4161)=""
      HS(4162)=""
      HS(4163)=""
      HS(4164)=""
      HS(4165)=""
      HS(4166)=""
      HS(4167)=""
      HS(4168)=""
      HS(4169)=""
      HS(4170)=""
      HS(4171)=""
      HS(4172)=""
      HS(4173)=""
      HS(4174)=""
      HS(4175)=""
      HS(4176)=""
      HS(4177)=""
      HS(4178)=""
      HS(4179)=""
      HS(4180)=""
      HS(4181)=""
      HS(4182)=""
      HS(4183)=""
      HS(4184)=""
      HS(4185)=""
      HS(4186)=""
      HS(4187)=""
      HS(4188)=""
      HS(4189)=""
      HS(4190)=""
      HS(4191)=""
      HS(4192)=""
      HS(4193)=""
      HS(4194)=""
      HS(4195)=""
      HS(4196)=""
      HS(4197)=""
      HS(4198)=""
      HS(4199)=""
      HS(4200)=""
      HS(4201)=""
      HS(4202)=""
      HS(4203)=""
      HS(4204)=""
      HS(4205)=""
      HS(4206)=""
      HS(4207)=""
      HS(4208)=""
      HS(4209)=""
      HS(4210)=""
      HS(4211)=""
      HS(4212)=""
      HS(4213)=""
      HS(4214)=""
      HS(4215)=""
      HS(4216)=""
      HS(4217)=""
      HS(4218)=""
      HS(4219)=""
      HS(4220)=""
      HS(4221)=""
      HS(4222)=""
      HS(4223)=""
      HS(4224)=""
      HS(4225)=""
      HS(4226)=""
      HS(4227)=""
      HS(4228)=""
      HS(4229)=""
      HS(4230)=""
      HS(4231)=""
      HS(4232)=""
      HS(4233)=""
      HS(4234)=""
      HS(4235)=""
      HS(4236)=""
      HS(4237)=""
      HS(4238)=""
      HS(4239)=""
      HS(4240)=""
      HS(4241)=""
      HS(4242)=""
      HS(4243)=""
      HS(4244)=""
      HS(4245)=""
      HS(4246)=""
      HS(4247)=""
      HS(4248)=""
      HS(4249)=""
      HS(4250)=""
      HS(4251)=""
      HS(4252)=""
      HS(4253)=""
      HS(4254)=""
      HS(4255)=""
      HS(4256)=""
      HS(4257)=""
      HS(4258)=""
      HS(4259)=""
      HS(4260)=""
      HS(4261)=""
      HS(4262)=""
      HS(4263)=""
      HS(4264)=""
      HS(4265)=""
      HS(4266)=""
      HS(4267)=""
      HS(4268)=""
      HS(4269)=""
      HS(4270)=""
      HS(4271)=""
      HS(4272)=""
      HS(4273)=""
      HS(4274)=""
      HS(4275)=""
      HS(4276)=""
      HS(4277)=""
      HS(4278)=""
      HS(4279)=""
      HS(4280)=""
      HS(4281)=""
      HS(4282)=""
      HS(4283)=""
      HS(4284)=""
      HS(4285)=""
      HS(4286)=""
      HS(4287)=""
      HS(4288)=""
      HS(4289)=""
      HS(4290)=""
      HS(4291)=""
      HS(4292)=""
      HS(4293)=""
      HS(4294)=""
      HS(4295)=""
      HS(4296)=""
      HS(4297)=""
      HS(4298)=""
      HS(4299)=""
      HS(4300)=""
      HS(4301)=""
      HS(4302)=""
      HS(4303)=""
      HS(4304)=""
      HS(4305)=""
      HS(4306)=""
      HS(4307)=""
      HS(4308)=""
      HS(4309)=""
      HS(4310)=""
      HS(4311)=""
      HS(4312)=""
      HS(4313)=""
      HS(4314)=""
      HS(4315)=""
      HS(4316)=""
      HS(4317)=""
      HS(4318)=""
      HS(4319)=""
      HS(4320)=""
      HS(4321)=""
      HS(4322)=""
      HS(4323)=""
      HS(4324)=""
      HS(4325)=""
      HS(4326)=""
      HS(4327)=""
      HS(4328)=""
      HS(4329)=""
      HS(4330)=""
      HS(4331)=""
      HS(4332)=""
      HS(4333)=""
      HS(4334)=""
      HS(4335)=""
      HS(4336)=""
      HS(4337)=""
      HS(4338)=""
      HS(4339)=""
      HS(4340)=""
      HS(4341)=""
      HS(4342)=""
      HS(4343)=""
      HS(4344)=""
      HS(4345)=""
      HS(4346)=""
      HS(4347)=""
      HS(4348)=""
      HS(4349)=""
      HS(4350)=""
      HS(4351)=""
      HS(4352)=""
      HS(4353)=""
      HS(4354)=""
      HS(4355)=""
      HS(4356)=""
      HS(4357)=""
      HS(4358)=""
      HS(4359)=""
      HS(4360)=""
      HS(4361)=""
      HS(4362)=""
      HS(4363)=""
      HS(4364)=""
      HS(4365)=""
      HS(4366)=""
      HS(4367)=""
      HS(4368)=""
      HS(4369)=""
      HS(4370)=""
      HS(4371)=""
      HS(4372)=""
      HS(4373)=""
      HS(4374)=""
      HS(4375)=""
      HS(4376)=""
      HS(4377)=""
      HS(4378)=""
      HS(4379)=""
      HS(4380)=""
      HS(4381)=""
      HS(4382)=""
      HS(4383)=""
      HS(4384)=""
      HS(4385)=""
      HS(4386)=""
      HS(4387)=""
      HS(4388)=""
      HS(4389)=""
      HS(4390)=""
      HS(4391)=""
      HS(4392)=""
      HS(4393)=""
      HS(4394)=""
      HS(4395)=""
      HS(4396)=""
      HS(4397)=""
      HS(4398)=""
      HS(4399)=""
      HS(4400)=""
      HS(4401)=""
      HS(4402)=""
      HS(4403)=""
      HS(4404)=""
      HS(4405)=""
      HS(4406)=""
      HS(4407)=""
      HS(4408)=""
      HS(4409)=""
      HS(4410)=""
      HS(4411)=""
      HS(4412)=""
      HS(4413)=""
      HS(4414)=""
      HS(4415)=""
      HS(4416)=""
      HS(4417)=""
      HS(4418)=""
      HS(4419)=""
      HS(4420)=""
      HS(4421)=""
      HS(4422)=""
      HS(4423)=""
      HS(4424)=""
      HS(4425)=""
      HS(4426)=""
      HS(4427)=""
      HS(4428)=""
      HS(4429)=""
      HS(4430)=""
      HS(4431)=""
      HS(4432)=""
      HS(4433)=""
      HS(4434)=""
      HS(4435)=""
      HS(4436)=""
      HS(4437)=""
      HS(4438)=""
      HS(4439)=""
      HS(4440)=""
      HS(4441)=""
      HS(4442)=""
      HS(4443)=""
      HS(4444)=""
      HS(4445)=""
      HS(4446)=""
      HS(4447)=""
      HS(4448)=""
      HS(4449)=""
      HS(4450)=""
      HS(4451)=""
      HS(4452)=""
      HS(4453)=""
      HS(4454)=""
      HS(4455)=""
      HS(4456)=""
      HS(4457)=""
      HS(4458)=""
      HS(4459)=""
      HS(4460)=""
      HS(4461)=""
      HS(4462)=""
      HS(4463)=""
      HS(4464)=""
      HS(4465)=""
      HS(4466)=""
      HS(4467)=""
      HS(4468)=""
      HS(4469)=""
      HS(4470)=""
      HS(4471)=""
      HS(4472)=""
      HS(4473)=""
      HS(4474)=""
      HS(4475)=""
      HS(4476)=""
      HS(4477)=""
      HS(4478)=""
      HS(4479)=""
      HS(4480)=""
      HS(4481)=""
      HS(4482)=""
      HS(4483)=""
      HS(4484)=""
      HS(4485)=""
      HS(4486)=""
      HS(4487)=""
      HS(4488)=""
      HS(4489)=""
      HS(4490)=""
      HS(4491)=""
      HS(4492)=""
      HS(4493)=""
      HS(4494)=""
      HS(4495)=""
      HS(4496)=""
      HS(4497)=""
      HS(4498)=""
      HS(4499)=""
      HS(4500)=""
      HS(4501)=""
      HS(4502)=""
      HS(4503)=""
      HS(4504)=""
      HS(4505)=""
      HS(4506)=""
      HS(4507)=""
      HS(4508)=""
      HS(4509)=""
      HS(4510)=""
      HS(4511)=""
      HS(4512)=""
      HS(4513)=""
      HS(4514)=""
      HS(4515)=""
      HS(4516)=""
      HS(4517)=""
      HS(4518)=""
      HS(4519)=""
      HS(4520)=""
      HS(4521)=""
      HS(4522)=""
      HS(4523)=""
      HS(4524)=""
      HS(4525)=""
      HS(4526)=""
      HS(4527)=""
      HS(4528)=""
      HS(4529)=""
      HS(4530)=""
      HS(4531)=""
      HS(4532)=""
      HS(4533)=""
      HS(4534)=""
      HS(4535)=""
      HS(4536)=""
      HS(4537)=""
      HS(4538)=""
      HS(4539)=""
      HS(4540)=""
      HS(4541)=""
      HS(4542)=""
      HS(4543)=""
      HS(4544)=""
      HS(4545)=""
      HS(4546)=""
      HS(4547)=""
      HS(4548)=""
      HS(4549)=""
      HS(4550)=""
      HS(4551)=""
      HS(4552)=""
      HS(4553)=""
      HS(4554)=""
      HS(4555)=""
      HS(4556)=""
      HS(4557)=""
      HS(4558)=""
      HS(4559)=""
      HS(4560)=""
      HS(4561)=""
      HS(4562)=""
      HS(4563)=""
      HS(4564)=""
      HS(4565)=""
      HS(4566)=""
      HS(4567)=""
      HS(4568)=""
      HS(4569)=""
      HS(4570)=""
      HS(4571)=""
      HS(4572)=""
      HS(4573)=""
      HS(4574)=""
      HS(4575)=""
      HS(4576)=""
      HS(4577)=""
      HS(4578)=""
      HS(4579)=""
      HS(4580)=""
      HS(4581)=""
      HS(4582)=""
      HS(4583)=""
      HS(4584)=""
      HS(4585)=""
      HS(4586)=""
      HS(4587)=""
      HS(4588)=""
      HS(4589)=""
      HS(4590)=""
      HS(4591)=""
      HS(4592)=""
      HS(4593)=""
      HS(4594)=""
      HS(4595)=""
      HS(4596)=""
      HS(4597)=""
      HS(4598)=""
      HS(4599)=""
      HS(4600)=""
      HS(4601)=""
      HS(4602)=""
      HS(4603)=""
      HS(4604)=""
      HS(4605)=""
      HS(4606)=""
      HS(4607)=""
      HS(4608)=""
      HS(4609)=""
      HS(4610)=""
      HS(4611)=""
      HS(4612)=""
      HS(4613)=""
      HS(4614)=""
      HS(4615)=""
      HS(4616)=""
      HS(4617)=""
      HS(4618)=""
      HS(4619)=""
      HS(4620)=""
      HS(4621)=""
      HS(4622)=""
      HS(4623)=""
      HS(4624)=""
      HS(4625)=""
      HS(4626)=""
      HS(4627)=""
      HS(4628)=""
      HS(4629)=""
      HS(4630)=""
      HS(4631)=""
      HS(4632)=""
      HS(4633)=""
      HS(4634)=""
      HS(4635)=""
      HS(4636)=""
      HS(4637)=""
      HS(4638)=""
      HS(4639)=""
      HS(4640)=""
      HS(4641)=""
      HS(4642)=""
      HS(4643)=""
      HS(4644)=""
      HS(4645)=""
      HS(4646)=""
      HS(4647)=""
      HS(4648)=""
      HS(4649)=""
      HS(4650)=""
      HS(4651)=""
      HS(4652)=""
      HS(4653)=""
      HS(4654)=""
      HS(4655)=""
      HS(4656)=""
      HS(4657)=""
      HS(4658)=""
      HS(4659)=""
      HS(4660)=""
      HS(4661)=""
      HS(4662)=""
      HS(4663)=""
      HS(4664)=""
      HS(4665)=""
      HS(4666)=""
      HS(4667)=""
      HS(4668)=""
      HS(4669)=""
      HS(4670)=""
      HS(4671)=""
      HS(4672)=""
      HS(4673)=""
      HS(4674)=""
      HS(4675)=""
      HS(4676)=""
      HS(4677)=""
      HS(4678)=""
      HS(4679)=""
      HS(4680)=""
      HS(4681)=""
      HS(4682)=""
      HS(4683)=""
      HS(4684)=""
      HS(4685)=""
      HS(4686)=""
      HS(4687)=""
      HS(4688)=""
      HS(4689)=""
      HS(4690)=""
      HS(4691)=""
      HS(4692)=""
      HS(4693)=""
      HS(4694)=""
      HS(4695)=""
      HS(4696)=""
      HS(4697)=""
      HS(4698)=""
      HS(4699)=""
      HS(4700)=""
      HS(4701)=""
      HS(4702)=""
      HS(4703)=""
      HS(4704)=""
      HS(4705)=""
      HS(4706)=""
      HS(4707)=""
      HS(4708)=""
      HS(4709)=""
      HS(4710)=""
      HS(4711)=""
      HS(4712)=""
      HS(4713)=""
      HS(4714)=""
      HS(4715)=""
      HS(4716)=""
      HS(4717)=""
      HS(4718)=""
      HS(4719)=""
      HS(4720)=""
      HS(4721)=""
      HS(4722)=""
      HS(4723)=""
      HS(4724)=""
      HS(4725)=""
      HS(4726)=""
      HS(4727)=""
      HS(4728)=""
      HS(4729)=""
      HS(4730)=""
      HS(4731)=""
      HS(4732)=""
      HS(4733)=""
      HS(4734)=""
      HS(4735)=""
      HS(4736)=""
      HS(4737)=""
      HS(4738)=""
      HS(4739)=""
      HS(4740)=""
      HS(4741)=""
      HS(4742)=""
      HS(4743)=""
      HS(4744)=""
      HS(4745)=""
      HS(4746)=""
      HS(4747)=""
      HS(4748)=""
      HS(4749)=""
      HS(4750)=""
      HS(4751)=""
      HS(4752)=""
      HS(4753)=""
      HS(4754)=""
      HS(4755)=""
      HS(4756)=""
      HS(4757)=""
      HS(4758)=""
      HS(4759)=""
      HS(4760)=""
      HS(4761)=""
      HS(4762)=""
      HS(4763)=""
      HS(4764)=""
      HS(4765)=""
      HS(4766)=""
      HS(4767)=""
      HS(4768)=""
      HS(4769)=""
      HS(4770)=""
      HS(4771)=""
      HS(4772)=""
      HS(4773)=""
      HS(4774)=""
      HS(4775)=""
      HS(4776)=""
      HS(4777)=""
      HS(4778)=""
      HS(4779)=""
      HS(4780)=""
      HS(4781)=""
      HS(4782)=""
      HS(4783)=""
      HS(4784)=""
      HS(4785)=""
      HS(4786)=""
      HS(4787)=""
      HS(4788)=""
      HS(4789)=""
      HS(4790)=""
      HS(4791)=""
      HS(4792)=""
      HS(4793)=""
      HS(4794)=""
      HS(4795)=""
      HS(4796)=""
      HS(4797)=""
      HS(4798)=""
      HS(4799)=""
      HS(4800)=""
      HS(4801)=""
      HS(4802)=""
      HS(4803)=""
      HS(4804)=""
      HS(4805)=""
      HS(4806)=""
      HS(4807)=""
      HS(4808)=""
      HS(4809)=""
      HS(4810)=""
      HS(4811)=""
      HS(4812)=""
      HS(4813)=""
      HS(4814)=""
      HS(4815)=""
      HS(4816)=""
      HS(4817)=""
      HS(4818)=""
      HS(4819)=""
      HS(4820)=""
      HS(4821)=""
      HS(4822)=""
      HS(4823)=""
      HS(4824)=""
      HS(4825)=""
      HS(4826)=""
      HS(4827)=""
      HS(4828)=""
      HS(4829)=""
      HS(4830)=""
      HS(4831)=""
      HS(4832)=""
      HS(4833)=""
      HS(4834)=""
      HS(4835)=""
      HS(4836)=""
      HS(4837)=""
      HS(4838)=""
      HS(4839)=""
      HS(4840)=""
      HS(4841)=""
      HS(4842)=""
      HS(4843)=""
      HS(4844)=""
      HS(4845)=""
      HS(4846)=""
      HS(4847)=""
      HS(4848)=""
      HS(4849)=""
      HS(4850)=""
      HS(4851)=""
      HS(4852)=""
      HS(4853)=""
      HS(4854)=""
      HS(4855)=""
      HS(4856)=""
      HS(4857)=""
      HS(4858)=""
      HS(4859)=""
      HS(4860)=""
      HS(4861)=""
      HS(4862)=""
      HS(4863)=""
      HS(4864)=""
      HS(4865)=""
      HS(4866)=""
      HS(4867)=""
      HS(4868)=""
      HS(4869)=""
      HS(4870)=""
      HS(4871)=""
      HS(4872)=""
      HS(4873)=""
      HS(4874)=""
      HS(4875)=""
      HS(4876)=""
      HS(4877)=""
      HS(4878)=""
      HS(4879)=""
      HS(4880)=""
      HS(4881)=""
      HS(4882)=""
      HS(4883)=""
      HS(4884)=""
      HS(4885)=""
      HS(4886)=""
      HS(4887)=""
      HS(4888)=""
      HS(4889)=""
      HS(4890)=""
      HS(4891)=""
      HS(4892)=""
      HS(4893)=""
      HS(4894)=""
      HS(4895)=""
      HS(4896)=""
      HS(4897)=""
      HS(4898)=""
      HS(4899)=""
      HS(4900)=""
      HS(4901)=""
      HS(4902)=""
      HS(4903)=""
      HS(4904)=""
      HS(4905)=""
      HS(4906)=""
      HS(4907)=""
      HS(4908)=""
      HS(4909)=""
      HS(4910)=""
      HS(4911)=""
      HS(4912)=""
      HS(4913)=""
      HS(4914)=""
      HS(4915)=""
      HS(4916)=""
      HS(4917)=""
      HS(4918)=""
      HS(4919)=""
      HS(4920)=""
      HS(4921)=""
      HS(4922)=""
      HS(4923)=""
      HS(4924)=""
      HS(4925)=""
      HS(4926)=""
      HS(4927)=""
      HS(4928)=""
      HS(4929)=""
      HS(4930)=""
      HS(4931)=""
      HS(4932)=""
      HS(4933)=""
      HS(4934)=""
      HS(4935)=""
      HS(4936)=""
      HS(4937)=""
      HS(4938)=""
      HS(4939)=""
      HS(4940)=""
      HS(4941)=""
      HS(4942)=""
      HS(4943)=""
      HS(4944)=""
      HS(4945)=""
      HS(4946)=""
      HS(4947)=""
      HS(4948)=""
      HS(4949)=""
      HS(4950)=""
      HS(4951)=""
      HS(4952)=""
      HS(4953)=""
      HS(4954)=""
      HS(4955)=""
      HS(4956)=""
      HS(4957)=""
      HS(4958)=""
      HS(4959)=""
      HS(4960)=""
      HS(4961)=""
      HS(4962)=""
      HS(4963)=""
      HS(4964)=""
      HS(4965)=""
      HS(4966)=""
      HS(4967)=""
      HS(4968)=""
      HS(4969)=""
      HS(4970)=""
      HS(4971)=""
      HS(4972)=""
      HS(4973)=""
      HS(4974)=""
      HS(4975)=""
      HS(4976)=""
      HS(4977)=""
      HS(4978)=""
      HS(4979)=""
      HS(4980)=""
      HS(4981)=""
      HS(4982)=""
      HS(4983)=""
      HS(4984)=""
      HS(4985)=""
      HS(4986)=""
      HS(4987)=""
      HS(4988)=""
      HS(4989)=""
      HS(4990)=""
      HS(4991)=""
      HS(4992)=""
      HS(4993)=""
      HS(4994)=""
      HS(4995)=""
      HS(4996)=""
      HS(4997)=""
      HS(4998)=""
      HS(4999)=""
      HS(5000)=""
      HS(5001)=""
      HS(5002)=""
      HS(5003)=""
      HS(5004)=""
      HS(5005)=""
      HS(5006)=""
      HS(5007)=""
      HS(5008)=""
      HS(5009)=""
      HS(5010)=""
      HS(5011)=""
      HS(5012)=""
      HS(5013)=""
      HS(5014)=""
      HS(5015)=""
      HS(5016)=""
      HS(5017)=""
      HS(5018)=""
      HS(5019)=""
      HS(5020)=""
      HS(5021)=""
      HS(5022)=""
      HS(5023)=""
      HS(5024)=""
      HS(5025)=""
      HS(5026)=""
      HS(5027)=""
      HS(5028)=""
      HS(5029)=""
      HS(5030)=""
      HS(5031)=""
      HS(5032)=""
      HS(5033)=""
      HS(5034)=""
      HS(5035)=""
      HS(5036)=""
      HS(5037)=""
      HS(5038)=""
      HS(5039)=""
      HS(5040)=""
      HS(5041)=""
      HS(5042)=""
      HS(5043)=""
      HS(5044)=""
      HS(5045)=""
      HS(5046)=""
      HS(5047)=""
      HS(5048)=""
      HS(5049)=""
      HS(5050)=""
      HS(5051)=""
      HS(5052)=""
      HS(5053)=""
      HS(5054)=""
      HS(5055)=""
      HS(5056)=""
      HS(5057)=""
      HS(5058)=""
      HS(5059)=""
      HS(5060)=""
      HS(5061)=""
      HS(5062)=""
      HS(5063)=""
      HS(5064)=""
      HS(5065)=""
      HS(5066)=""
      HS(5067)=""
      HS(5068)=""
      HS(5069)=""
      HS(5070)=""
      HS(5071)=""
      HS(5072)=""
      HS(5073)=""
      HS(5074)=""
      HS(5075)=""
      HS(5076)=""
      HS(5077)=""
      HS(5078)=""
      HS(5079)=""
      HS(5080)=""
      HS(5081)=""
      HS(5082)=""
      HS(5083)=""
      HS(5084)=""
      HS(5085)=""
      HS(5086)=""
      HS(5087)=""
      HS(5088)=""
      HS(5089)=""
      HS(5090)=""
      HS(5091)=""
      HS(5092)=""
      HS(5093)=""
      HS(5094)=""
      HS(5095)=""
      HS(5096)=""
      HS(5097)=""
      HS(5098)=""
      HS(5099)=""
      HS(5100)=""
      HS(5101)=""
      HS(5102)=""
      HS(5103)=""
      HS(5104)=""
      HS(5105)=""
      HS(5106)=""
      HS(5107)=""
      HS(5108)=""
      HS(5109)=""
      HS(5110)=""
      HS(5111)=""
      HS(5112)=""
      HS(5113)=""
      HS(5114)=""
      HS(5115)=""
      HS(5116)=""
      HS(5117)=""
      HS(5118)=""
      HS(5119)=""
      HS(5120)=""
      HS(5121)=""
      HS(5122)=""
      HS(5123)=""
      HS(5124)=""
      HS(5125)=""
      HS(5126)=""
      HS(5127)=""
      HS(5128)=""
      HS(5129)=""
      HS(5130)=""
      HS(5131)=""
      HS(5132)=""
      HS(5133)=""
      HS(5134)=""
      HS(5135)=""
      HS(5136)=""
      HS(5137)=""
      HS(5138)=""
      HS(5139)=""
      HS(5140)=""
      HS(5141)=""
      HS(5142)=""
      HS(5143)=""
      HS(5144)=""
      HS(5145)=""
      HS(5146)=""
      HS(5147)=""
      HS(5148)=""
      HS(5149)=""
      HS(5150)=""
      HS(5151)=""
      HS(5152)=""
      HS(5153)=""
      HS(5154)=""
      HS(5155)=""
      HS(5156)=""
      HS(5157)=""
      HS(5158)=""
      HS(5159)=""
      HS(5160)=""
      HS(5161)=""
      HS(5162)=""
      HS(5163)=""
      HS(5164)=""
      HS(5165)=""
      HS(5166)=""
      HS(5167)=""
      HS(5168)=""
      HS(5169)=""
      HS(5170)=""
      HS(5171)=""
      HS(5172)=""
      HS(5173)=""
      HS(5174)=""
      HS(5175)=""
      HS(5176)=""
      HS(5177)=""
      HS(5178)=""
      HS(5179)=""
      HS(5180)=""
      HS(5181)=""
      HS(5182)=""
      HS(5183)=""
      HS(5184)=""
      HS(5185)=""
      HS(5186)=""
      HS(5187)=""
      HS(5188)=""
      HS(5189)=""
      HS(5190)=""
      HS(5191)=""
      HS(5192)=""
      HS(5193)=""
      HS(5194)=""
      HS(5195)=""
      HS(5196)=""
      HS(5197)=""
      HS(5198)=""
      HS(5199)=""
      HS(5200)=""
      HS(5201)=""
      HS(5202)=""
      HS(5203)=""
      HS(5204)=""
      HS(5205)=""
      HS(5206)=""
      HS(5207)=""
      HS(5208)=""
      HS(5209)=""
      HS(5210)=""
      HS(5211)=""
      HS(5212)=""
      HS(5213)=""
      HS(5214)=""
      HS(5215)=""
      HS(5216)=""
      HS(5217)=""
      HS(5218)=""
      HS(5219)=""
      HS(5220)=""
      HS(5221)=""
      HS(5222)=""
      HS(5223)=""
      HS(5224)=""
      HS(5225)=""
      HS(5226)=""
      HS(5227)=""
      HS(5228)=""
      HS(5229)=""
      HS(5230)=""
      HS(5231)=""
      HS(5232)=""
      HS(5233)=""
      HS(5234)=""
      HS(5235)=""
      HS(5236)=""
      HS(5237)=""
      HS(5238)=""
      HS(5239)=""
      HS(5240)=""
      HS(5241)=""
      HS(5242)=""
      HS(5243)=""
      HS(5244)=""
      HS(5245)=""
      HS(5246)=""
      HS(5247)=""
      HS(5248)=""
      HS(5249)=""
      HS(5250)=""
      HS(5251)=""
      HS(5252)=""
      HS(5253)=""
      HS(5254)=""
      HS(5255)=""
      HS(5256)=""
      HS(5257)=""
      HS(5258)=""
      HS(5259)=""
      HS(5260)=""
      HS(5261)=""
      HS(5262)=""
      HS(5263)=""
      HS(5264)=""
      HS(5265)=""
      HS(5266)=""
      HS(5267)=""
      HS(5268)=""
      HS(5269)=""
      HS(5270)=""
      HS(5271)=""
      HS(5272)=""
      HS(5273)=""
      HS(5274)=""
      HS(5275)=""
      HS(5276)=""
      HS(5277)=""
      HS(5278)=""
      HS(5279)=""
      HS(5280)=""
      HS(5281)=""
      HS(5282)=""
      HS(5283)=""
      HS(5284)=""
      HS(5285)=""
      HS(5286)=""
      HS(5287)=""
      HS(5288)=""
      HS(5289)=""
      HS(5290)=""
      HS(5291)=""
      HS(5292)=""
      HS(5293)=""
      HS(5294)=""
      HS(5295)=""
      HS(5296)=""
      HS(5297)=""
      HS(5298)=""
      HS(5299)=""
      HS(5300)=""
      HS(5301)=""
      HS(5302)=""
      HS(5303)=""
      HS(5304)=""
      HS(5305)=""
      HS(5306)=""
      HS(5307)=""
      HS(5308)=""
      HS(5309)=""
      HS(5310)=""
      HS(5311)=""
      HS(5312)=""
      HS(5313)=""
      HS(5314)=""
      HS(5315)=""
      HS(5316)=""
      HS(5317)=""
      HS(5318)=""
      HS(5319)=""
      HS(5320)=""
      HS(5321)=""
      HS(5322)=""
      HS(5323)=""
      HS(5324)=""
      HS(5325)=""
      HS(5326)=""
      HS(5327)=""
      HS(5328)=""
      HS(5329)=""
      HS(5330)=""
      HS(5331)=""
      HS(5332)=""
      HS(5333)=""
      HS(5334)=""
      HS(5335)=""
      HS(5336)=""
      HS(5337)=""
      HS(5338)=""
      HS(5339)=""
      HS(5340)=""
      HS(5341)=""
      HS(5342)=""
      HS(5343)=""
      HS(5344)=""
      HS(5345)=""
      HS(5346)=""
      HS(5347)=""
      HS(5348)=""
      HS(5349)=""
      HS(5350)=""
      HS(5351)=""
      HS(5352)=""
      HS(5353)=""
      HS(5354)=""
      HS(5355)=""
      HS(5356)=""
      HS(5357)=""
      HS(5358)=""
      HS(5359)=""
      HS(5360)=""
      HS(5361)=""
      HS(5362)=""
      HS(5363)=""
      HS(5364)=""
      HS(5365)=""
      HS(5366)=""
      HS(5367)=""
      HS(5368)=""
      HS(5369)=""
      HS(5370)=""
      HS(5371)=""
      HS(5372)=""
      HS(5373)=""
      HS(5374)=""
      HS(5375)=""
      HS(5376)=""
      HS(5377)=""
      HS(5378)=""
      HS(5379)=""
      HS(5380)=""
      HS(5381)=""
      HS(5382)=""
      HS(5383)=""
      HS(5384)=""
      HS(5385)=""
      HS(5386)=""
      HS(5387)=""
      HS(5388)=""
      HS(5389)=""
      HS(5390)=""
      HS(5391)=""
      HS(5392)=""
      HS(5393)=""
      HS(5394)=""
      HS(5395)=""
      HS(5396)=""
      HS(5397)=""
      HS(5398)=""
      HS(5399)=""
      HS(5400)=""
      HS(5401)=""
      HS(5402)=""
      HS(5403)=""
      HS(5404)=""
      HS(5405)=""
      HS(5406)=""
      HS(5407)=""
      HS(5408)=""
      HS(5409)=""
      HS(5410)=""
      HS(5411)=""
      HS(5412)=""
      HS(5413)=""
      HS(5414)=""
      HS(5415)=""
      HS(5416)=""
      HS(5417)=""
      HS(5418)=""
      HS(5419)=""
      HS(5420)=""
      HS(5421)=""
      HS(5422)=""
      HS(5423)=""
      HS(5424)=""
      HS(5425)=""
      HS(5426)=""
      HS(5427)=""
      HS(5428)=""
      HS(5429)=""
      HS(5430)=""
      HS(5431)=""
      HS(5432)=""
      HS(5433)=""
      HS(5434)=""
      HS(5435)=""
      HS(5436)=""
      HS(5437)=""
      HS(5438)=""
      HS(5439)=""
      HS(5440)=""
      HS(5441)=""
      HS(5442)=""
      HS(5443)=""
      HS(5444)=""
      HS(5445)=""
      HS(5446)=""
      HS(5447)=""
      HS(5448)=""
      HS(5449)=""
      HS(5450)=""
      HS(5451)=""
      HS(5452)=""
      HS(5453)=""
      HS(5454)=""
      HS(5455)=""
      HS(5456)=""
      HS(5457)=""
      HS(5458)=""
      HS(5459)=""
      HS(5460)=""
      HS(5461)=""
      HS(5462)=""
      HS(5463)=""
      HS(5464)=""
      HS(5465)=""
      HS(5466)=""
      HS(5467)=""
      HS(5468)=""
      HS(5469)=""
      HS(5470)=""
      HS(5471)=""
      HS(5472)=""
      HS(5473)=""
      HS(5474)=""
      HS(5475)=""
      HS(5476)=""
      HS(5477)=""
      HS(5478)=""
      HS(5479)=""
      HS(5480)=""
      HS(5481)=""
      HS(5482)=""
      HS(5483)=""
      HS(5484)=""
      HS(5485)=""
      HS(5486)=""
      HS(5487)=""
      HS(5488)=""
      HS(5489)=""
      HS(5490)=""
      HS(5491)=""
      HS(5492)=""
      HS(5493)=""
      HS(5494)=""
      HS(5495)=""
      HS(5496)=""
      HS(5497)=""
      HS(5498)=""
      HS(5499)=""
      HS(5500)=""
      HS(5501)=""
      HS(5502)=""
      HS(5503)=""
      HS(5504)=""
      HS(5505)=""
      HS(5506)=""
      HS(5507)=""
      HS(5508)=""
      HS(5509)=""
      HS(5510)=""
      HS(5511)=""
      HS(5512)=""
      HS(5513)=""
      HS(5514)=""
      HS(5515)=""
      HS(5516)=""
      HS(5517)=""
      HS(5518)=""
      HS(5519)=""
      HS(5520)=""
      HS(5521)=""
      HS(5522)=""
      HS(5523)=""
      HS(5524)=""
      HS(5525)=""
      HS(5526)=""
      HS(5527)=""
      HS(5528)=""
      HS(5529)=""
      HS(5530)=""
      HS(5531)=""
      HS(5532)=""
      HS(5533)=""
      HS(5534)=""
      HS(5535)=""
      HS(5536)=""
      HS(5537)=""
      HS(5538)=""
      HS(5539)=""
      HS(5540)=""
      HS(5541)=""
      HS(5542)=""
      HS(5543)=""
      HS(5544)=""
      HS(5545)=""
      HS(5546)=""
      HS(5547)=""
      HS(5548)=""
      HS(5549)=""
      HS(5550)=""
      HS(5551)=""
      HS(5552)=""
      HS(5553)=""
      HS(5554)=""
      HS(5555)=""
      HS(5556)=""
      HS(5557)=""
      HS(5558)=""
      HS(5559)=""
      HS(5560)=""
      HS(5561)=""
      HS(5562)=""
      HS(5563)=""
      HS(5564)=""
      HS(5565)=""
      HS(5566)=""
      HS(5567)=""
      HS(5568)=""
      HS(5569)=""
      HS(5570)=""
      HS(5571)=""
      HS(5572)=""
      HS(5573)=""
      HS(5574)=""
      HS(5575)=""
      HS(5576)=""
      HS(5577)=""
      HS(5578)=""
      HS(5579)=""
      HS(5580)=""
      HS(5581)=""
      HS(5582)=""
      HS(5583)=""
      HS(5584)=""
      HS(5585)=""
      HS(5586)=""
      HS(5587)=""
      HS(5588)=""
      HS(5589)=""
      HS(5590)=""
      HS(5591)=""
      HS(5592)=""
      HS(5593)=""
      HS(5594)=""
      HS(5595)=""
      HS(5596)=""
      HS(5597)=""
      HS(5598)=""
      HS(5599)=""
      HS(5600)=""
      HS(5601)=""
      HS(5602)=""
      HS(5603)=""
      HS(5604)=""
      HS(5605)=""
      HS(5606)=""
      HS(5607)=""
      HS(5608)=""
      HS(5609)=""
      HS(5610)=""
      HS(5611)=""
      HS(5612)=""
      HS(5613)=""
      HS(5614)=""
      HS(5615)=""
      HS(5616)=""
      HS(5617)=""
      HS(5618)=""
      HS(5619)=""
      HS(5620)=""
      HS(5621)=""
      HS(5622)=""
      HS(5623)=""
      HS(5624)=""
      HS(5625)=""
      HS(5626)=""
      HS(5627)=""
      HS(5628)=""
      HS(5629)=""
      HS(5630)=""
      HS(5631)=""
      HS(5632)=""
      HS(5633)=""
      HS(5634)=""
      HS(5635)=""
      HS(5636)=""
      HS(5637)=""
      HS(5638)=""
      HS(5639)=""
      HS(5640)=""
      HS(5641)=""
      HS(5642)=""
      HS(5643)=""
      HS(5644)=""
      HS(5645)=""
      HS(5646)=""
      HS(5647)=""
      HS(5648)=""
      HS(5649)=""
      HS(5650)=""
      HS(5651)=""
      HS(5652)=""
      HS(5653)=""
      HS(5654)=""
      HS(5655)=""
      HS(5656)=""
      HS(5657)=""
      HS(5658)=""
      HS(5659)=""
      HS(5660)=""
      HS(5661)=""
      HS(5662)=""
      HS(5663)=""
      HS(5664)=""
      HS(5665)=""
      HS(5666)=""
      HS(5667)=""
      HS(5668)=""
      HS(5669)=""
      HS(5670)=""
      HS(5671)=""
      HS(5672)=""
      HS(5673)=""
      HS(5674)=""
      HS(5675)=""
      HS(5676)=""
      HS(5677)=""
      HS(5678)=""
      HS(5679)=""
      HS(5680)=""
      HS(5681)=""
      HS(5682)=""
      HS(5683)=""
      HS(5684)=""
      HS(5685)=""
      HS(5686)=""
      HS(5687)=""
      HS(5688)=""
      HS(5689)=""
      HS(5690)=""
      HS(5691)=""
      HS(5692)=""
      HS(5693)=""
      HS(5694)=""
      HS(5695)=""
      HS(5696)=""
      HS(5697)=""
      HS(5698)=""
      HS(5699)=""
      HS(5700)=""
      HS(5701)=""
      HS(5702)=""
      HS(5703)=""
      HS(5704)=""
      HS(5705)=""
      HS(5706)=""
      HS(5707)=""
      HS(5708)=""
      HS(5709)=""
      HS(5710)=""
      HS(5711)=""
      HS(5712)=""
      HS(5713)=""
      HS(5714)=""
      HS(5715)=""
      HS(5716)=""
      HS(5717)=""
      HS(5718)=""
      HS(5719)=""
      HS(5720)=""
      HS(5721)=""
      HS(5722)=""
      HS(5723)=""
      HS(5724)=""
      HS(5725)=""
      HS(5726)=""
      HS(5727)=""
      HS(5728)=""
      HS(5729)=""
      HS(5730)=""
      HS(5731)=""
      HS(5732)=""
      HS(5733)=""
      HS(5734)=""
      HS(5735)=""
      HS(5736)=""
      HS(5737)=""
      HS(5738)=""
      HS(5739)=""
      HS(5740)=""
      HS(5741)=""
      HS(5742)=""
      HS(5743)=""
      HS(5744)=""
      HS(5745)=""
      HS(5746)=""
      HS(5747)=""
      HS(5748)=""
      HS(5749)=""
      HS(5750)=""
      HS(5751)=""
      HS(5752)=""
      HS(5753)=""
      HS(5754)=""
      HS(5755)=""
      HS(5756)=""
      HS(5757)=""
      HS(5758)=""
      HS(5759)=""
      HS(5760)=""
      HS(5761)=""
      HS(5762)=""
      HS(5763)=""
      HS(5764)=""
      HS(5765)=""
      HS(5766)=""
      HS(5767)=""
      HS(5768)=""
      HS(5769)=""
      HS(5770)=""
      HS(5771)=""
      HS(5772)=""
      HS(5773)=""
      HS(5774)=""
      HS(5775)=""
      HS(5776)=""
      HS(5777)=""
      HS(5778)=""
      HS(5779)=""
      HS(5780)=""
      HS(5781)=""
      HS(5782)=""
      HS(5783)=""
      HS(5784)=""
      HS(5785)=""
      HS(5786)=""
      HS(5787)=""
      HS(5788)=""
      HS(5789)=""
      HS(5790)=""
      HS(5791)=""
      HS(5792)=""
      HS(5793)=""
      HS(5794)=""
      HS(5795)=""
      HS(5796)=""
      HS(5797)=""
      HS(5798)=""
      HS(5799)=""
      HS(5800)=""
      HS(5801)=""
      HS(5802)=""
      HS(5803)=""
      HS(5804)=""
      HS(5805)=""
      HS(5806)=""
      HS(5807)=""
      HS(5808)=""
      HS(5809)=""
      HS(5810)=""
      HS(5811)=""
      HS(5812)=""
      HS(5813)=""
      HS(5814)=""
      HS(5815)=""
      HS(5816)=""
      HS(5817)=""
      HS(5818)=""
      HS(5819)=""
      HS(5820)=""
      HS(5821)=""
      HS(5822)=""
      HS(5823)=""
      HS(5824)=""
      HS(5825)=""
      HS(5826)=""
      HS(5827)=""
      HS(5828)=""
      HS(5829)=""
      HS(5830)=""
      HS(5831)=""
      HS(5832)=""
      HS(5833)=""
      HS(5834)=""
      HS(5835)=""
      HS(5836)=""
      HS(5837)=""
      HS(5838)=""
      HS(5839)=""
      HS(5840)=""
      HS(5841)=""
      HS(5842)=""
      HS(5843)=""
      HS(5844)=""
      HS(5845)=""
      HS(5846)=""
      HS(5847)=""
      HS(5848)=""
      HS(5849)=""
      HS(5850)=""
      HS(5851)=""
      HS(5852)=""
      HS(5853)=""
      HS(5854)=""
      HS(5855)=""
      HS(5856)=""
      HS(5857)=""
      HS(5858)=""
      HS(5859)=""
      HS(5860)=""
      HS(5861)=""
      HS(5862)=""
      HS(5863)=""
      HS(5864)=""
      HS(5865)=""
      HS(5866)=""
      HS(5867)=""
      HS(5868)=""
      HS(5869)=""
      HS(5870)=""
      HS(5871)=""
      HS(5872)=""
      HS(5873)=""
      HS(5874)=""
      HS(5875)=""
      HS(5876)=""
      HS(5877)=""
      HS(5878)=""
      HS(5879)=""
      HS(5880)=""
      HS(5881)=""
      HS(5882)=""
      HS(5883)=""
      HS(5884)=""
      HS(5885)=""
      HS(5886)=""
      HS(5887)=""
      HS(5888)=""
      HS(5889)=""
      HS(5890)=""
      HS(5891)=""
      HS(5892)=""
      HS(5893)=""
      HS(5894)=""
      HS(5895)=""
      HS(5896)=""
      HS(5897)=""
      HS(5898)=""
      HS(5899)=""
      HS(5900)=""
      HS(5901)=""
      HS(5902)=""
      HS(5903)=""
      HS(5904)=""
      HS(5905)=""
      HS(5906)=""
      HS(5907)=""
      HS(5908)=""
      HS(5909)=""
      HS(5910)=""
      HS(5911)=""
      HS(5912)=""
      HS(5913)=""
      HS(5914)=""
      HS(5915)=""
      HS(5916)=""
      HS(5917)=""
      HS(5918)=""
      HS(5919)=""
      HS(5920)=""
      HS(5921)=""
      HS(5922)=""
      HS(5923)=""
      HS(5924)=""
      HS(5925)=""
      HS(5926)=""
      HS(5927)=""
      HS(5928)=""
      HS(5929)=""
      HS(5930)=""
      HS(5931)=""
      HS(5932)=""
      HS(5933)=""
      HS(5934)=""
      HS(5935)=""
      HS(5936)=""
      HS(5937)=""
      HS(5938)=""
      HS(5939)=""
      HS(5940)=""
      HS(5941)=""
      HS(5942)=""
      HS(5943)=""
      HS(5944)=""
      HS(5945)=""
      HS(5946)=""
      HS(5947)=""
      HS(5948)=""
      HS(5949)=""
      HS(5950)=""
      HS(5951)=""
      HS(5952)=""
      HS(5953)=""
      HS(5954)=""
      HS(5955)=""
      HS(5956)=""
      HS(5957)=""
      HS(5958)=""
      HS(5959)=""
      HS(5960)=""
      HS(5961)=""
      HS(5962)=""
      HS(5963)=""
      HS(5964)=""
      HS(5965)=""
      HS(5966)=""
      HS(5967)=""
      HS(5968)=""
      HS(5969)=""
      HS(5970)=""
      HS(5971)=""
      HS(5972)=""
      HS(5973)=""
      HS(5974)=""
      HS(5975)=""
      HS(5976)=""
      HS(5977)=""
      HS(5978)=""
      HS(5979)=""
      HS(5980)=""
      HS(5981)=""
      HS(5982)=""
      HS(5983)=""
      HS(5984)=""
      HS(5985)=""
      HS(5986)=""
      HS(5987)=""
      HS(5988)=""
      HS(5989)=""
      HS(5990)=""
      HS(5991)=""
      HS(5992)=""
      HS(5993)=""
      HS(5994)=""
      HS(5995)=""
      HS(5996)=""
      HS(5997)=""
      HS(5998)=""
      HS(5999)=""
      HS(6000)=""
      HS(6001)=""
      HS(6002)=""
      HS(6003)=""
      HS(6004)=""
      HS(6005)=""
      HS(6006)=""
      HS(6007)=""
      HS(6008)=""
      HS(6009)=""
      HS(6010)=""
      HS(6011)=""
      HS(6012)=""
      HS(6013)=""
      HS(6014)=""
      HS(6015)=""
      HS(6016)=""
      HS(6017)=""
      HS(6018)=""
      HS(6019)=""
      HS(6020)=""
      HS(6021)=""
      HS(6022)=""
      HS(6023)=""
      HS(6024)=""
      HS(6025)=""
      HS(6026)=""
      HS(6027)=""
      HS(6028)=""
      HS(6029)=""
      HS(6030)=""
      HS(6031)=""
      HS(6032)=""
      HS(6033)=""
      HS(6034)=""
      HS(6035)=""
      HS(6036)=""
      HS(6037)=""
      HS(6038)=""
      HS(6039)=""
      HS(6040)=""
      HS(6041)=""
      HS(6042)=""
      HS(6043)=""
      HS(6044)=""
      HS(6045)=""
      HS(6046)=""
      HS(6047)=""
      HS(6048)=""
      HS(6049)=""
      HS(6050)=""
      HS(6051)=""
      HS(6052)=""
      HS(6053)=""
      HS(6054)=""
      HS(6055)=""
      HS(6056)=""
      HS(6057)=""
      HS(6058)=""
      HS(6059)=""
      HS(6060)=""
      HS(6061)=""
      HS(6062)=""
      HS(6063)=""
      HS(6064)=""
      HS(6065)=""
      HS(6066)=""
      HS(6067)=""
      HS(6068)=""
      HS(6069)=""
      HS(6070)=""
      HS(6071)=""
      HS(6072)=""
      HS(6073)=""
      HS(6074)=""
      HS(6075)=""
      HS(6076)=""
      HS(6077)=""
      HS(6078)=""
      HS(6079)=""
      HS(6080)=""
      HS(6081)=""
      HS(6082)=""
      HS(6083)=""
      HS(6084)=""
      HS(6085)=""
      HS(6086)=""
      HS(6087)=""
      HS(6088)=""
      HS(6089)=""
      HS(6090)=""
      HS(6091)=""
      HS(6092)=""
      HS(6093)=""
      HS(6094)=""
      HS(6095)=""
      HS(6096)=""
      HS(6097)=""
      HS(6098)=""
      HS(6099)=""
      HS(6100)=""
      HS(6101)=""
      HS(6102)=""
      HS(6103)=""
      HS(6104)=""
      HS(6105)=""
      HS(6106)=""
      HS(6107)=""
      HS(6108)=""
      HS(6109)=""
      HS(6110)=""
      HS(6111)=""
      HS(6112)=""
      HS(6113)=""
      HS(6114)=""
      HS(6115)=""
      HS(6116)=""
      HS(6117)=""
      HS(6118)=""
      HS(6119)=""
      HS(6120)=""
      HS(6121)=""
      HS(6122)=""
      HS(6123)=""
      HS(6124)=""
      HS(6125)=""
      HS(6126)=""
      HS(6127)=""
      HS(6128)=""
      HS(6129)=""
      HS(6130)=""
      HS(6131)=""
      HS(6132)=""
      HS(6133)=""
      HS(6134)=""
      HS(6135)=""
      HS(6136)=""
      HS(6137)=""
      HS(6138)=""
      HS(6139)=""
      HS(6140)=""
      HS(6141)=""
      HS(6142)=""
      HS(6143)=""
      HS(6144)=""
      HS(6145)=""
      HS(6146)=""
      HS(6147)=""
      HS(6148)=""
      HS(6149)=""
      HS(6150)=""
      HS(6151)=""
      HS(6152)=""
      HS(6153)=""
      HS(6154)=""
      HS(6155)=""
      HS(6156)=""
      HS(6157)=""
      HS(6158)=""
      HS(6159)=""
      HS(6160)=""
      HS(6161)=""
      HS(6162)=""
      HS(6163)=""
      HS(6164)=""
      HS(6165)=""
      HS(6166)=""
      HS(6167)=""
      HS(6168)=""
      HS(6169)=""
      HS(6170)=""
      HS(6171)=""
      HS(6172)=""
      HS(6173)=""
      HS(6174)=""
      HS(6175)=""
      HS(6176)=""
      HS(6177)=""
      HS(6178)=""
      HS(6179)=""
      HS(6180)=""
      HS(6181)=""
      HS(6182)=""
      HS(6183)=""
      HS(6184)=""
      HS(6185)=""
      HS(6186)=""
      HS(6187)=""
      HS(6188)=""
      HS(6189)=""
      HS(6190)=""
      HS(6191)=""
      HS(6192)=""
      HS(6193)=""
      HS(6194)=""
      HS(6195)=""
      HS(6196)=""
      HS(6197)=""
      HS(6198)=""
      HS(6199)=""
      HS(6200)=""
      HS(6201)=""
      HS(6202)=""
      HS(6203)=""
      HS(6204)=""
      HS(6205)=""
      HS(6206)=""
      HS(6207)=""
      HS(6208)=""
      HS(6209)=""
      HS(6210)=""
      HS(6211)=""
      HS(6212)=""
      HS(6213)=""
      HS(6214)=""
      HS(6215)=""
      HS(6216)=""
      HS(6217)=""
      HS(6218)=""
      HS(6219)=""
      HS(6220)=""
      HS(6221)=""
      HS(6222)=""
      HS(6223)=""
      HS(6224)=""
      HS(6225)=""
      HS(6226)=""
      HS(6227)=""
      HS(6228)=""
      HS(6229)=""
      HS(6230)=""
      HS(6231)=""
      HS(6232)=""
      HS(6233)=""
      HS(6234)=""
      HS(6235)=""
      HS(6236)=""
      HS(6237)=""
      HS(6238)=""
      HS(6239)=""
      HS(6240)=""
      HS(6241)=""
      HS(6242)=""
      HS(6243)=""
      HS(6244)=""
      HS(6245)=""
      HS(6246)=""
      HS(6247)=""
      HS(6248)=""
      HS(6249)=""
      HS(6250)=""
      HS(6251)=""
      HS(6252)=""
      HS(6253)=""
      HS(6254)=""
      HS(6255)=""
      HS(6256)=""
      HS(6257)=""
      HS(6258)=""
      HS(6259)=""
      HS(6260)=""
      HS(6261)=""
      HS(6262)=""
      HS(6263)=""
      HS(6264)=""
      HS(6265)=""
      HS(6266)=""
      HS(6267)=""
      HS(6268)=""
      HS(6269)=""
      HS(6270)=""
      HS(6271)=""
      HS(6272)=""
      HS(6273)=""
      HS(6274)=""
      HS(6275)=""
      HS(6276)=""
      HS(6277)=""
      HS(6278)=""
      HS(6279)=""
      HS(6280)=""
      HS(6281)=""
      HS(6282)=""
      HS(6283)=""
      HS(6284)=""
      HS(6285)=""
      HS(6286)=""
      HS(6287)=""
      HS(6288)=""
      HS(6289)=""
      HS(6290)=""
      HS(6291)=""
      HS(6292)=""
      HS(6293)=""
      HS(6294)=""
      HS(6295)=""
      HS(6296)=""
      HS(6297)=""
      HS(6298)=""
      HS(6299)=""
      HS(6300)=""
      HS(6301)=""
      HS(6302)=""
      HS(6303)=""
      HS(6304)=""
      HS(6305)=""
      HS(6306)=""
      HS(6307)=""
      HS(6308)=""
      HS(6309)=""
      HS(6310)=""
      HS(6311)=""
      HS(6312)=""
      HS(6313)=""
      HS(6314)=""
      HS(6315)=""
      HS(6316)=""
      HS(6317)=""
      HS(6318)=""
      HS(6319)=""
      HS(6320)=""
      HS(6321)=""
      HS(6322)=""
      HS(6323)=""
      HS(6324)=""
      HS(6325)=""
      HS(6326)=""
      HS(6327)=""
      HS(6328)=""
      HS(6329)=""
      HS(6330)=""
      HS(6331)=""
      HS(6332)=""
      HS(6333)=""
      HS(6334)=""
      HS(6335)=""
      HS(6336)=""
      HS(6337)=""
      HS(6338)=""
      HS(6339)=""
      HS(6340)=""
      HS(6341)=""
      HS(6342)=""
      HS(6343)=""
      HS(6344)=""
      HS(6345)=""
      HS(6346)=""
      HS(6347)=""
      HS(6348)=""
      HS(6349)=""
      HS(6350)=""
      HS(6351)=""
      HS(6352)=""
      HS(6353)=""
      HS(6354)=""
      HS(6355)=""
      HS(6356)=""
      HS(6357)=""
      HS(6358)=""
      HS(6359)=""
      HS(6360)=""
      HS(6361)=""
      HS(6362)=""
      HS(6363)=""
      HS(6364)=""
      HS(6365)=""
      HS(6366)=""
      HS(6367)=""
      HS(6368)=""
      HS(6369)=""
      HS(6370)=""
      HS(6371)=""
      HS(6372)=""
      HS(6373)=""
      HS(6374)=""
      HS(6375)=""
      HS(6376)=""
      HS(6377)=""
      HS(6378)=""
      HS(6379)=""
      HS(6380)=""
      HS(6381)=""
      HS(6382)=""
      HS(6383)=""
      HS(6384)=""
      HS(6385)=""
      HS(6386)=""
      HS(6387)=""
      HS(6388)=""
      HS(6389)=""
      HS(6390)=""
      HS(6391)=""
      HS(6392)=""
      HS(6393)=""
      HS(6394)=""
      HS(6395)=""
      HS(6396)=""
      HS(6397)=""
      HS(6398)=""
      HS(6399)=""
      HS(6400)=""
      HS(6401)=""
      HS(6402)=""
      HS(6403)=""
      HS(6404)=""
      HS(6405)=""
      HS(6406)=""
      HS(6407)=""
      HS(6408)=""
      HS(6409)=""
      HS(6410)=""
      HS(6411)=""
      HS(6412)=""
      HS(6413)=""
      HS(6414)=""
      HS(6415)=""
      HS(6416)=""
      HS(6417)=""
      HS(6418)=""
      HS(6419)=""
      HS(6420)=""
      HS(6421)=""
      HS(6422)=""
      HS(6423)=""
      HS(6424)=""
      HS(6425)=""
      HS(6426)=""
      HS(6427)=""
      HS(6428)=""
      HS(6429)=""
      HS(6430)=""
      HS(6431)=""
      HS(6432)=""
      HS(6433)=""
      HS(6434)=""
      HS(6435)=""
      HS(6436)=""
      HS(6437)=""
      HS(6438)=""
      HS(6439)=""
      HS(6440)=""
      HS(6441)=""
      HS(6442)=""
      HS(6443)=""
      HS(6444)=""
      HS(6445)=""
      HS(6446)=""
      HS(6447)=""
      HS(6448)=""
      HS(6449)=""
      HS(6450)=""
      HS(6451)=""
      HS(6452)=""
      HS(6453)=""
      HS(6454)=""
      HS(6455)=""
      HS(6456)=""
      HS(6457)=""
      HS(6458)=""
      HS(6459)=""
      HS(6460)=""
      HS(6461)=""
      HS(6462)=""
      HS(6463)=""
      HS(6464)=""
      HS(6465)=""
      HS(6466)=""
      HS(6467)=""
      HS(6468)=""
      HS(6469)=""
      HS(6470)=""
      HS(6471)=""
      HS(6472)=""
      HS(6473)=""
      HS(6474)=""
      HS(6475)=""
      HS(6476)=""
      HS(6477)=""
      HS(6478)=""
      HS(6479)=""
      HS(6480)=""
      HS(6481)=""
      HS(6482)=""
      HS(6483)=""
      HS(6484)=""
      HS(6485)=""
      HS(6486)=""
      HS(6487)=""
      HS(6488)=""
      HS(6489)=""
      HS(6490)=""
      HS(6491)=""
      HS(6492)=""
      HS(6493)=""
      HS(6494)=""
      HS(6495)=""
      HS(6496)=""
      HS(6497)=""
      HS(6498)=""
      HS(6499)=""
      HS(6500)=""
      HS(6501)=""
      HS(6502)=""
      HS(6503)=""
      HS(6504)=""
      HS(6505)=""
      HS(6506)=""
      HS(6507)=""
      HS(6508)=""
      HS(6509)=""
      HS(6510)=""
      HS(6511)=""
      HS(6512)=""
      HS(6513)=""
      HS(6514)=""
      HS(6515)=""
      HS(6516)=""
      HS(6517)=""
      HS(6518)=""
      HS(6519)=""
      HS(6520)=""
      HS(6521)=""
      HS(6522)=""
      HS(6523)=""
      HS(6524)=""
      HS(6525)=""
      HS(6526)=""
      HS(6527)=""
      HS(6528)=""
      HS(6529)=""
      HS(6530)=""
      HS(6531)=""
      HS(6532)=""
      HS(6533)=""
      HS(6534)=""
      HS(6535)=""
      HS(6536)=""
      HS(6537)=""
      HS(6538)=""
      HS(6539)=""
      HS(6540)=""
      HS(6541)=""
      HS(6542)=""
      HS(6543)=""
      HS(6544)=""
      HS(6545)=""
      HS(6546)=""
      HS(6547)=""
      HS(6548)=""
      HS(6549)=""
      HS(6550)=""
      HS(6551)=""
      HS(6552)=""
      HS(6553)=""
      HS(6554)=""
      HS(6555)=""
      HS(6556)=""
      HS(6557)=""
      HS(6558)=""
      HS(6559)=""
      HS(6560)=""
      HS(6561)=""
      HS(6562)=""
      HS(6563)=""
      HS(6564)=""
      HS(6565)=""
      HS(6566)=""
      HS(6567)=""
      HS(6568)=""
      HS(6569)=""
      HS(6570)=""
      HS(6571)=""
      HS(6572)=""
      HS(6573)=""
      HS(6574)=""
      HS(6575)=""
      HS(6576)=""
      HS(6577)=""
      HS(6578)=""
      HS(6579)=""
      HS(6580)=""
      HS(6581)=""
      HS(6582)=""
      HS(6583)=""
      HS(6584)=""
      HS(6585)=""
      HS(6586)=""
      HS(6587)=""
      HS(6588)=""
      HS(6589)=""
      HS(6590)=""
      HS(6591)=""
      HS(6592)=""
      HS(6593)=""
      HS(6594)=""
      HS(6595)=""
      HS(6596)=""
      HS(6597)=""
      HS(6598)=""
      HS(6599)=""
      HS(6600)=""
      HS(6601)=""
      HS(6602)=""
      HS(6603)=""
      HS(6604)=""
      HS(6605)=""
      HS(6606)=""
      HS(6607)=""
      HS(6608)=""
      HS(6609)=""
      HS(6610)=""
      HS(6611)=""
      HS(6612)=""
      HS(6613)=""
      HS(6614)=""
      HS(6615)=""
      HS(6616)=""
      HS(6617)=""
      HS(6618)=""
      HS(6619)=""
      HS(6620)=""
      HS(6621)=""
      HS(6622)=""
      HS(6623)=""
      HS(6624)=""
      HS(6625)=""
      HS(6626)=""
      HS(6627)=""
      HS(6628)=""
      HS(6629)=""
      HS(6630)=""
      HS(6631)=""
      HS(6632)=""
      HS(6633)=""
      HS(6634)=""
      HS(6635)=""
      HS(6636)=""
      HS(6637)=""
      HS(6638)=""
      HS(6639)=""
      HS(6640)=""
      HS(6641)=""
      HS(6642)=""
      HS(6643)=""
      HS(6644)=""
      HS(6645)=""
      HS(6646)=""
      HS(6647)=""
      HS(6648)=""
      HS(6649)=""
      HS(6650)=""
      HS(6651)=""
      HS(6652)=""
      HS(6653)=""
      HS(6654)=""
      HS(6655)=""
      HS(6656)=""
      HS(6657)=""
      HS(6658)=""
      HS(6659)=""
      HS(6660)=""
      HS(6661)=""
      HS(6662)=""
      HS(6663)=""
      HS(6664)=""
      HS(6665)=""
      HS(6666)=""
      HS(6667)=""
      HS(6668)=""
      HS(6669)=""
      HS(6670)=""
      HS(6671)=""
      HS(6672)=""
      HS(6673)=""
      HS(6674)=""
      HS(6675)=""
      HS(6676)=""
      HS(6677)=""
      HS(6678)=""
      HS(6679)=""
      HS(6680)=""
      HS(6681)=""
      HS(6682)=""
      HS(6683)=""
      HS(6684)=""
      HS(6685)=""
      HS(6686)=""
      HS(6687)=""
      HS(6688)=""
      HS(6689)=""
      HS(6690)=""
      HS(6691)=""
      HS(6692)=""
      HS(6693)=""
      HS(6694)=""
      HS(6695)=""
      HS(6696)=""
      HS(6697)=""
      HS(6698)=""
      HS(6699)=""
      HS(6700)=""
      HS(6701)=""
      HS(6702)=""
      HS(6703)=""
      HS(6704)=""
      HS(6705)=""
      HS(6706)=""
      HS(6707)=""
      HS(6708)=""
      HS(6709)=""
      HS(6710)=""
      HS(6711)=""
      HS(6712)=""
      HS(6713)=""
      HS(6714)=""
      HS(6715)=""
      HS(6716)=""
      HS(6717)=""
      HS(6718)=""
      HS(6719)=""
      HS(6720)=""
      HS(6721)=""
      HS(6722)=""
      HS(6723)=""
      HS(6724)=""
      HS(6725)=""
      HS(6726)=""
      HS(6727)=""
      HS(6728)=""
      HS(6729)=""
      HS(6730)=""
      HS(6731)=""
      HS(6732)=""
      HS(6733)=""
      HS(6734)=""
      HS(6735)=""
      HS(6736)=""
      HS(6737)=""
      HS(6738)=""
      HS(6739)=""
      HS(6740)=""
      HS(6741)=""
      HS(6742)=""
      HS(6743)=""
      HS(6744)=""
      HS(6745)=""
      HS(6746)=""
      HS(6747)=""
      HS(6748)=""
      HS(6749)=""
      HS(6750)=""
      HS(6751)=""
      HS(6752)=""
      HS(6753)=""
      HS(6754)=""
      HS(6755)=""
      HS(6756)=""
      HS(6757)=""
      HS(6758)=""
      HS(6759)=""
      HS(6760)=""
      HS(6761)=""
      HS(6762)=""
      HS(6763)=""
      HS(6764)=""
      HS(6765)=""
      HS(6766)=""
      HS(6767)=""
      HS(6768)=""
      HS(6769)=""
      HS(6770)=""
      HS(6771)=""
      HS(6772)=""
      HS(6773)=""
      HS(6774)=""
      HS(6775)=""
      HS(6776)=""
      HS(6777)=""
      HS(6778)=""
      HS(6779)=""
      HS(6780)=""
      HS(6781)=""
      HS(6782)=""
      HS(6783)=""
      HS(6784)=""
      HS(6785)=""
      HS(6786)=""
      HS(6787)=""
      HS(6788)=""
      HS(6789)=""
      HS(6790)=""
      HS(6791)=""
      HS(6792)=""
      HS(6793)=""
      HS(6794)=""
      HS(6795)=""
      HS(6796)=""
      HS(6797)=""
      HS(6798)=""
      HS(6799)=""
      HS(6800)=""
      HS(6801)=""
      HS(6802)=""
      HS(6803)=""
      HS(6804)=""
      HS(6805)=""
      HS(6806)=""
      HS(6807)=""
      HS(6808)=""
      HS(6809)=""
      HS(6810)=""
      HS(6811)=""
      HS(6812)=""
      HS(6813)=""
      HS(6814)=""
      HS(6815)=""
      HS(6816)=""
      HS(6817)=""
      HS(6818)=""
      HS(6819)=""
      HS(6820)=""
      HS(6821)=""
      HS(6822)=""
      HS(6823)=""
      HS(6824)=""
      HS(6825)=""
      HS(6826)=""
      HS(6827)=""
      HS(6828)=""
      HS(6829)=""
      HS(6830)=""
      HS(6831)=""
      HS(6832)=""
      HS(6833)=""
      HS(6834)=""
      HS(6835)=""
      HS(6836)=""
      HS(6837)=""
      HS(6838)=""
      HS(6839)=""
      HS(6840)=""
      HS(6841)=""
      HS(6842)=""
      HS(6843)=""
      HS(6844)=""
      HS(6845)=""
      HS(6846)=""
      HS(6847)=""
      HS(6848)=""
      HS(6849)=""
      HS(6850)=""
      HS(6851)=""
      HS(6852)=""
      HS(6853)=""
      HS(6854)=""
      HS(6855)=""
      HS(6856)=""
      HS(6857)=""
      HS(6858)=""
      HS(6859)=""
      HS(6860)=""
      HS(6861)=""
      HS(6862)=""
      HS(6863)=""
      HS(6864)=""
      HS(6865)=""
      HS(6866)=""
      HS(6867)=""
      HS(6868)=""
      HS(6869)=""
      HS(6870)=""
      HS(6871)=""
      HS(6872)=""
      HS(6873)=""
      HS(6874)=""
      HS(6875)=""
      HS(6876)=""
      HS(6877)=""
      HS(6878)=""
      HS(6879)=""
      HS(6880)=""
      HS(6881)=""
      HS(6882)=""
      HS(6883)=""
      HS(6884)=""
      HS(6885)=""
      HS(6886)=""
      HS(6887)=""
      HS(6888)=""
      HS(6889)=""
      HS(6890)=""
      HS(6891)=""
      HS(6892)=""
      HS(6893)=""
      HS(6894)=""
      HS(6895)=""
      HS(6896)=""
      HS(6897)=""
      HS(6898)=""
      HS(6899)=""
      HS(6900)=""
      HS(6901)=""
      HS(6902)=""
      HS(6903)=""
      HS(6904)=""
      HS(6905)=""
      HS(6906)=""
      HS(6907)=""
      HS(6908)=""
      HS(6909)=""
      HS(6910)=""
      HS(6911)=""
      HS(6912)=""
      HS(6913)=""
      HS(6914)=""
      HS(6915)=""
      HS(6916)=""
      HS(6917)=""
      HS(6918)=""
      HS(6919)=""
      HS(6920)=""
      HS(6921)=""
      HS(6922)=""
      HS(6923)=""
      HS(6924)=""
      HS(6925)=""
      HS(6926)=""
      HS(6927)=""
      HS(6928)=""
      HS(6929)=""
      HS(6930)=""
      HS(6931)=""
      HS(6932)=""
      HS(6933)=""
      HS(6934)=""
      HS(6935)=""
      HS(6936)=""
      HS(6937)=""
      HS(6938)=""
      HS(6939)=""
      HS(6940)=""
      HS(6941)=""
      HS(6942)=""
      HS(6943)=""
      HS(6944)=""
      HS(6945)=""
      HS(6946)=""
      HS(6947)=""
      HS(6948)=""
      HS(6949)=""
      HS(6950)=""
      HS(6951)=""
      HS(6952)=""
      HS(6953)=""
      HS(6954)=""
      HS(6955)=""
      HS(6956)=""
      HS(6957)=""
      HS(6958)=""
      HS(6959)=""
      HS(6960)=""
      HS(6961)=""
      HS(6962)=""
      HS(6963)=""
      HS(6964)=""
      HS(6965)=""
      HS(6966)=""
      HS(6967)=""
      HS(6968)=""
      HS(6969)=""
      HS(6970)=""
      HS(6971)=""
      HS(6972)=""
      HS(6973)=""
      HS(6974)=""
      HS(6975)=""
      HS(6976)=""
      HS(6977)=""
      HS(6978)=""
      HS(6979)=""
      HS(6980)=""
      HS(6981)=""
      HS(6982)=""
      HS(6983)=""
      HS(6984)=""
      HS(6985)=""
      HS(6986)=""
      HS(6987)=""
      HS(6988)=""
      HS(6989)=""
      HS(6990)=""
      HS(6991)=""
      HS(6992)=""
      HS(6993)=""
      HS(6994)=""
      HS(6995)=""
      HS(6996)=""
      HS(6997)=""
      HS(6998)=""
      HS(6999)=""
      HS(7000)=""
      HS(7001)=""
      HS(7002)=""
      HS(7003)=""
      HS(7004)=""
      HS(7005)=""
      HS(7006)=""
      HS(7007)=""
      HS(7008)=""
      HS(7009)=""
      HS(7010)=""
      HS(7011)=""
      HS(7012)=""
      HS(7013)=""
      HS(7014)=""
      HS(7015)=""
      HS(7016)=""
      HS(7017)=""
      HS(7018)=""
      HS(7019)=""
      HS(7020)=""
      HS(7021)=""
      HS(7022)=""
      HS(7023)=""
      HS(7024)=""
      HS(7025)=""
      HS(7026)=""
      HS(7027)=""
      HS(7028)=""
      HS(7029)=""
      HS(7030)=""
      HS(7031)=""
      HS(7032)=""
      HS(7033)=""
      HS(7034)=""
      HS(7035)=""
      HS(7036)=""
      HS(7037)=""
      HS(7038)=""
      HS(7039)=""
      HS(7040)=""
      HS(7041)=""
      HS(7042)=""
      HS(7043)=""
      HS(7044)=""
      HS(7045)=""
      HS(7046)=""
      HS(7047)=""
      HS(7048)=""
      HS(7049)=""
      HS(7050)=""
      HS(7051)=""
      HS(7052)=""
      HS(7053)=""
      HS(7054)=""
      HS(7055)=""
      HS(7056)=""
      HS(7057)=""
      HS(7058)=""
      HS(7059)=""
      HS(7060)=""
      HS(7061)=""
      HS(7062)=""
      HS(7063)=""
      HS(7064)=""
      HS(7065)=""
      HS(7066)=""
      HS(7067)=""
      HS(7068)=""
      HS(7069)=""
      HS(7070)=""
      HS(7071)=""
      HS(7072)=""
      HS(7073)=""
      HS(7074)=""
      HS(7075)=""
      HS(7076)=""
      HS(7077)=""
      HS(7078)=""
      HS(7079)=""
      HS(7080)=""
      HS(7081)=""
      HS(7082)=""
      HS(7083)=""
      HS(7084)=""
      HS(7085)=""
      HS(7086)=""
      HS(7087)=""
      HS(7088)=""
      HS(7089)=""
      HS(7090)=""
      HS(7091)=""
      HS(7092)=""
      HS(7093)=""
      HS(7094)=""
      HS(7095)=""
      HS(7096)=""
      HS(7097)=""
      HS(7098)=""
      HS(7099)=""
      HS(7100)=""
      HS(7101)=""
      HS(7102)=""
      HS(7103)=""
      HS(7104)=""
      HS(7105)=""
      HS(7106)=""
      HS(7107)=""
      HS(7108)=""
      HS(7109)=""
      HS(7110)=""
      HS(7111)=""
      HS(7112)=""
      HS(7113)=""
      HS(7114)=""
      HS(7115)=""
      HS(7116)=""
      HS(7117)=""
      HS(7118)=""
      HS(7119)=""
      HS(7120)=""
      HS(7121)=""
      HS(7122)=""
      HS(7123)=""
      HS(7124)=""
      HS(7125)=""
      HS(7126)=""
      HS(7127)=""
      HS(7128)=""
      HS(7129)=""
      HS(7130)=""
      HS(7131)=""
      HS(7132)=""
      HS(7133)=""
      HS(7134)=""
      HS(7135)=""
      HS(7136)=""
      HS(7137)=""
      HS(7138)=""
      HS(7139)=""
      HS(7140)=""
      HS(7141)=""
      HS(7142)=""
      HS(7143)=""
      HS(7144)=""
      HS(7145)=""
      HS(7146)=""
      HS(7147)=""
      HS(7148)=""
      HS(7149)=""
      HS(7150)=""
      HS(7151)=""
      HS(7152)=""
      HS(7153)=""
      HS(7154)=""
      HS(7155)=""
      HS(7156)=""
      HS(7157)=""
      HS(7158)=""
      HS(7159)=""
      HS(7160)=""
      HS(7161)=""
      HS(7162)=""
      HS(7163)=""
      HS(7164)=""
      HS(7165)=""
      HS(7166)=""
      HS(7167)=""
      HS(7168)=""
      HS(7169)=""
      HS(7170)=""
      HS(7171)=""
      HS(7172)=""
      HS(7173)=""
      HS(7174)=""
      HS(7175)=""
      HS(7176)=""
      HS(7177)=""
      HS(7178)=""
      HS(7179)=""
      HS(7180)=""
      HS(7181)=""
      HS(7182)=""
      HS(7183)=""
      HS(7184)=""
      HS(7185)=""
      HS(7186)=""
      HS(7187)=""
      HS(7188)=""
      HS(7189)=""
      HS(7190)=""
      HS(7191)=""
      HS(7192)=""
      HS(7193)=""
      HS(7194)=""
      HS(7195)=""
      HS(7196)=""
      HS(7197)=""
      HS(7198)=""
      HS(7199)=""
      HS(7200)=""
      HS(7201)=""
      HS(7202)=""
      HS(7203)=""
      HS(7204)=""
      HS(7205)=""
      HS(7206)=""
      HS(7207)=""
      HS(7208)=""
      HS(7209)=""
      HS(7210)=""
      HS(7211)=""
      HS(7212)=""
      HS(7213)=""
      HS(7214)=""
      HS(7215)=""
      HS(7216)=""
      HS(7217)=""
      HS(7218)=""
      HS(7219)=""
      HS(7220)=""
      HS(7221)=""
      HS(7222)=""
      HS(7223)=""
      HS(7224)=""
      HS(7225)=""
      HS(7226)=""
      HS(7227)=""
      HS(7228)=""
      HS(7229)=""
      HS(7230)=""
      HS(7231)=""
      HS(7232)=""
      HS(7233)=""
      HS(7234)=""
      HS(7235)=""
      HS(7236)=""
      HS(7237)=""
      HS(7238)=""
      HS(7239)=""
      HS(7240)=""
      HS(7241)=""
      HS(7242)=""
      HS(7243)=""
      HS(7244)=""
      HS(7245)=""
      HS(7246)=""
      HS(7247)=""
      HS(7248)=""
      HS(7249)=""
      HS(7250)=""
      HS(7251)=""
      HS(7252)=""
      HS(7253)=""
      HS(7254)=""
      HS(7255)=""
      HS(7256)=""
      HS(7257)=""
      HS(7258)=""
      HS(7259)=""
      HS(7260)=""
      HS(7261)=""
      HS(7262)=""
      HS(7263)=""
      HS(7264)=""
      HS(7265)=""
      HS(7266)=""
      HS(7267)=""
      HS(7268)=""
      HS(7269)=""
      HS(7270)=""
      HS(7271)=""
      HS(7272)=""
      HS(7273)=""
      HS(7274)=""
      HS(7275)=""
      HS(7276)=""
      HS(7277)=""
      HS(7278)=""
      HS(7279)=""
      HS(7280)=""
      HS(7281)=""
      HS(7282)=""
      HS(7283)=""
      HS(7284)=""
      HS(7285)=""
      HS(7286)=""
      HS(7287)=""
      HS(7288)=""
      HS(7289)=""
      HS(7290)=""
      HS(7291)=""
      HS(7292)=""
      HS(7293)=""
      HS(7294)=""
      HS(7295)=""
      HS(7296)=""
      HS(7297)=""
      HS(7298)=""
      HS(7299)=""
      HS(7300)=""
      HS(7301)=""
      HS(7302)=""
      HS(7303)=""
      HS(7304)=""
      HS(7305)=""
      HS(7306)=""
      HS(7307)=""
      HS(7308)=""
      HS(7309)=""
      HS(7310)=""
      HS(7311)=""
      HS(7312)=""
      HS(7313)=""
      HS(7314)=""
      HS(7315)=""
      HS(7316)=""
      HS(7317)=""
      HS(7318)=""
      HS(7319)=""
      HS(7320)=""
      HS(7321)=""
      HS(7322)=""
      HS(7323)=""
      HS(7324)=""
      HS(7325)=""
      HS(7326)=""
      HS(7327)=""
      HS(7328)=""
      HS(7329)=""
      HS(7330)=""
      HS(7331)=""
      HS(7332)=""
      HS(7333)=""
      HS(7334)=""
      HS(7335)=""
      HS(7336)=""
      HS(7337)=""
      HS(7338)=""
      HS(7339)=""
      HS(7340)=""
      HS(7341)=""
      HS(7342)=""
      HS(7343)=""
      HS(7344)=""
      HS(7345)=""
      HS(7346)=""
      HS(7347)=""
      HS(7348)=""
      HS(7349)=""
      HS(7350)=""
      HS(7351)=""
      HS(7352)=""
      HS(7353)=""
      HS(7354)=""
      HS(7355)=""
      HS(7356)=""
      HS(7357)=""
      HS(7358)=""
      HS(7359)=""
      HS(7360)=""
      HS(7361)=""
      HS(7362)=""
      HS(7363)=""
      HS(7364)=""
      HS(7365)=""
      HS(7366)=""
      HS(7367)=""
      HS(7368)=""
      HS(7369)=""
      HS(7370)=""
      HS(7371)=""
      HS(7372)=""
      HS(7373)=""
      HS(7374)=""
      HS(7375)=""
      HS(7376)=""
      HS(7377)=""
      HS(7378)=""
      HS(7379)=""
      HS(7380)=""
      HS(7381)=""
      HS(7382)=""
      HS(7383)=""
      HS(7384)=""
      HS(7385)=""
      HS(7386)=""
      HS(7387)=""
      HS(7388)=""
      HS(7389)=""
      HS(7390)=""
      HS(7391)=""
      HS(7392)=""
      HS(7393)=""
      HS(7394)=""
      HS(7395)=""
      HS(7396)=""
      HS(7397)=""
      HS(7398)=""
      HS(7399)=""
      HS(7400)=""
      HS(7401)=""
      HS(7402)=""
      HS(7403)=""
      HS(7404)=""
      HS(7405)=""
      HS(7406)=""
      HS(7407)=""
      HS(7408)=""
      HS(7409)=""
      HS(7410)=""
      HS(7411)=""
      HS(7412)=""
      HS(7413)=""
      HS(7414)=""
      HS(7415)=""
      HS(7416)=""
      HS(7417)=""
      HS(7418)=""
      HS(7419)=""
      HS(7420)=""
      HS(7421)=""
      HS(7422)=""
      HS(7423)=""
      HS(7424)=""
      HS(7425)=""
      HS(7426)=""
      HS(7427)=""
      HS(7428)=""
      HS(7429)=""
      HS(7430)=""
      HS(7431)=""
      HS(7432)=""
      HS(7433)=""
      HS(7434)=""
      HS(7435)=""
      HS(7436)=""
      HS(7437)=""
      HS(7438)=""
      HS(7439)=""
      HS(7440)=""
      HS(7441)=""
      HS(7442)=""
      HS(7443)=""
      HS(7444)=""
      HS(7445)=""
      HS(7446)=""
      HS(7447)=""
      HS(7448)=""
      HS(7449)=""
      HS(7450)=""
      HS(7451)=""
      HS(7452)=""
      HS(7453)=""
      HS(7454)=""
      HS(7455)=""
      HS(7456)=""
      HS(7457)=""
      HS(7458)=""
      HS(7459)=""
      HS(7460)=""
      HS(7461)=""
      HS(7462)=""
      HS(7463)=""
      HS(7464)=""
      HS(7465)=""
      HS(7466)=""
      HS(7467)=""
      HS(7468)=""
      HS(7469)=""
      HS(7470)=""
      HS(7471)=""
      HS(7472)=""
      HS(7473)=""
      HS(7474)=""
      HS(7475)=""
      HS(7476)=""
      HS(7477)=""
      HS(7478)=""
      HS(7479)=""
      HS(7480)=""
      HS(7481)=""
      HS(7482)=""
      HS(7483)=""
      HS(7484)=""
      HS(7485)=""
      HS(7486)=""
      HS(7487)=""
      HS(7488)=""
      HS(7489)=""
      HS(7490)=""
      HS(7491)=""
      HS(7492)=""
      HS(7493)=""
      HS(7494)=""
      HS(7495)=""
      HS(7496)=""
      HS(7497)=""
      HS(7498)=""
      HS(7499)=""
      HS(7500)=""
      HS(7501)=""
      HS(7502)=""
      HS(7503)=""
      HS(7504)=""
      HS(7505)=""
      HS(7506)=""
      HS(7507)=""
      HS(7508)=""
      HS(7509)=""
      HS(7510)=""
      HS(7511)=""
      HS(7512)=""
      HS(7513)=""
      HS(7514)=""
      HS(7515)=""
      HS(7516)=""
      HS(7517)=""
      HS(7518)=""
      HS(7519)=""
      HS(7520)=""
      HS(7521)=""
      HS(7522)=""
      HS(7523)=""
      HS(7524)=""
      HS(7525)=""
      HS(7526)=""
      HS(7527)=""
      HS(7528)=""
      HS(7529)=""
      HS(7530)=""
      HS(7531)=""
      HS(7532)=""
      HS(7533)=""
      HS(7534)=""
      HS(7535)=""
      HS(7536)=""
      HS(7537)=""
      HS(7538)=""
      HS(7539)=""
      HS(7540)=""
      HS(7541)=""
      HS(7542)=""
      HS(7543)=""
      HS(7544)=""
      HS(7545)=""
      HS(7546)=""
      HS(7547)=""
      HS(7548)=""
      HS(7549)=""
      HS(7550)=""
      HS(7551)=""
      HS(7552)=""
      HS(7553)=""
      HS(7554)=""
      HS(7555)=""
      HS(7556)=""
      HS(7557)=""
      HS(7558)=""
      HS(7559)=""
      HS(7560)=""
      HS(7561)=""
      HS(7562)=""
      HS(7563)=""
      HS(7564)=""
      HS(7565)=""
      HS(7566)=""
      HS(7567)=""
      HS(7568)=""
      HS(7569)=""
      HS(7570)=""
      HS(7571)=""
      HS(7572)=""
      HS(7573)=""
      HS(7574)=""
      HS(7575)=""
      HS(7576)=""
      HS(7577)=""
      HS(7578)=""
      HS(7579)=""
      HS(7580)=""
      HS(7581)=""
      HS(7582)=""
      HS(7583)=""
      HS(7584)=""
      HS(7585)=""
      HS(7586)=""
      HS(7587)=""
      HS(7588)=""
      HS(7589)=""
      HS(7590)=""
      HS(7591)=""
      HS(7592)=""
      HS(7593)=""
      HS(7594)=""
      HS(7595)=""
      HS(7596)=""
      HS(7597)=""
      HS(7598)=""
      HS(7599)=""
      HS(7600)=""
      HS(7601)=""
      HS(7602)=""
      HS(7603)=""
      HS(7604)=""
      HS(7605)=""
      HS(7606)=""
      HS(7607)=""
      HS(7608)=""
      HS(7609)=""
      HS(7610)=""
      HS(7611)=""
      HS(7612)=""
      HS(7613)=""
      HS(7614)=""
      HS(7615)=""
      HS(7616)=""
      HS(7617)=""
      HS(7618)=""
      HS(7619)=""
      HS(7620)=""
      HS(7621)=""
      HS(7622)=""
      HS(7623)=""
      HS(7624)=""
      HS(7625)=""
      HS(7626)=""
      HS(7627)=""
      HS(7628)=""
      HS(7629)=""
      HS(7630)=""
      HS(7631)=""
      HS(7632)=""
      HS(7633)=""
      HS(7634)=""
      HS(7635)=""
      HS(7636)=""
      HS(7637)=""
      HS(7638)=""
      HS(7639)=""
      HS(7640)=""
      HS(7641)=""
      HS(7642)=""
      HS(7643)=""
      HS(7644)=""
      HS(7645)=""
      HS(7646)=""
      HS(7647)=""
      HS(7648)=""
      HS(7649)=""
      HS(7650)=""
      HS(7651)=""
      HS(7652)=""
      HS(7653)=""
      HS(7654)=""
      HS(7655)=""
      HS(7656)=""
      HS(7657)=""
      HS(7658)=""
      HS(7659)=""
      HS(7660)=""
      HS(7661)=""
      HS(7662)=""
      HS(7663)=""
      HS(7664)=""
      HS(7665)=""
      HS(7666)=""
      HS(7667)=""
      HS(7668)=""
      HS(7669)=""
      HS(7670)=""
      HS(7671)=""
      HS(7672)=""
      HS(7673)=""
      HS(7674)=""
      HS(7675)=""
      HS(7676)=""
      HS(7677)=""
      HS(7678)=""
      HS(7679)=""
      HS(7680)=""
      HS(7681)=""
      HS(7682)=""
      HS(7683)=""
      HS(7684)=""
      HS(7685)=""
      HS(7686)=""
      HS(7687)=""
      HS(7688)=""
      HS(7689)=""
      HS(7690)=""
      HS(7691)=""
      HS(7692)=""
      HS(7693)=""
      HS(7694)=""
      HS(7695)=""
      HS(7696)=""
      HS(7697)=""
      HS(7698)=""
      HS(7699)=""
      HS(7700)=""
      HS(7701)=""
      HS(7702)=""
      HS(7703)=""
      HS(7704)=""
      HS(7705)=""
      HS(7706)=""
      HS(7707)=""
      HS(7708)=""
      HS(7709)=""
      HS(7710)=""
      HS(7711)=""
      HS(7712)=""
      HS(7713)=""
      HS(7714)=""
      HS(7715)=""
      HS(7716)=""
      HS(7717)=""
      HS(7718)=""
      HS(7719)=""
      HS(7720)=""
      HS(7721)=""
      HS(7722)=""
      HS(7723)=""
      HS(7724)=""
      HS(7725)=""
      HS(7726)=""
      HS(7727)=""
      HS(7728)=""
      HS(7729)=""
      HS(7730)=""
      HS(7731)=""
      HS(7732)=""
      HS(7733)=""
      HS(7734)=""
      HS(7735)=""
      HS(7736)=""
      HS(7737)=""
      HS(7738)=""
      HS(7739)=""
      HS(7740)=""
      HS(7741)=""
      HS(7742)=""
      HS(7743)=""
      HS(7744)=""
      HS(7745)=""
      HS(7746)=""
      HS(7747)=""
      HS(7748)=""
      HS(7749)=""
      HS(7750)=""
      HS(7751)=""
      HS(7752)=""
      HS(7753)=""
      HS(7754)=""
      HS(7755)=""
      HS(7756)=""
      HS(7757)=""
      HS(7758)=""
      HS(7759)=""
      HS(7760)=""
      HS(7761)=""
      HS(7762)=""
      HS(7763)=""
      HS(7764)=""
      HS(7765)=""
      HS(7766)=""
      HS(7767)=""
      HS(7768)=""
      HS(7769)=""
      HS(7770)=""
      HS(7771)=""
      HS(7772)=""
      HS(7773)=""
      HS(7774)=""
      HS(7775)=""
      HS(7776)=""
      HS(7777)=""
      HS(7778)=""
      HS(7779)=""
      HS(7780)=""
      HS(7781)=""
      HS(7782)=""
      HS(7783)=""
      HS(7784)=""
      HS(7785)=""
      HS(7786)=""
      HS(7787)=""
      HS(7788)=""
      HS(7789)=""
      HS(7790)=""
      HS(7791)=""
      HS(7792)=""
      HS(7793)=""
      HS(7794)=""
      HS(7795)=""
      HS(7796)=""
      HS(7797)=""
      HS(7798)=""
      HS(7799)=""
      HS(7800)=""
      HS(7801)=""
      HS(7802)=""
      HS(7803)=""
      HS(7804)=""
      HS(7805)=""
      HS(7806)=""
      HS(7807)=""
      HS(7808)=""
      HS(7809)=""
      HS(7810)=""
      HS(7811)=""
      HS(7812)=""
      HS(7813)=""
      HS(7814)=""
      HS(7815)=""
      HS(7816)=""
      HS(7817)=""
      HS(7818)=""
      HS(7819)=""
      HS(7820)=""
      HS(7821)=""
      HS(7822)=""
      HS(7823)=""
      HS(7824)=""
      HS(7825)=""
      HS(7826)=""
      HS(7827)=""
      HS(7828)=""
      HS(7829)=""
      HS(7830)=""
      HS(7831)=""
      HS(7832)=""
      HS(7833)=""
      HS(7834)=""
      HS(7835)=""
      HS(7836)=""
      HS(7837)=""
      HS(7838)=""
      HS(7839)=""
      HS(7840)=""
      HS(7841)=""
      HS(7842)=""
      HS(7843)=""
      HS(7844)=""
      HS(7845)=""
      HS(7846)=""
      HS(7847)=""
      HS(7848)=""
      HS(7849)=""
      HS(7850)=""
      HS(7851)=""
      HS(7852)=""
      HS(7853)=""
      HS(7854)=""
      HS(7855)=""
      HS(7856)=""
      HS(7857)=""
      HS(7858)=""
      HS(7859)=""
      HS(7860)=""
      HS(7861)=""
      HS(7862)=""
      HS(7863)=""
      HS(7864)=""
      HS(7865)=""
      HS(7866)=""
      HS(7867)=""
      HS(7868)=""
      HS(7869)=""
      HS(7870)=""
      HS(7871)=""
      HS(7872)=""
      HS(7873)=""
      HS(7874)=""
      HS(7875)=""
      HS(7876)=""
      HS(7877)=""
      HS(7878)=""
      HS(7879)=""
      HS(7880)=""
      HS(7881)=""
      HS(7882)=""
      HS(7883)=""
      HS(7884)=""
      HS(7885)=""
      HS(7886)=""
      HS(7887)=""
      HS(7888)=""
      HS(7889)=""
      HS(7890)=""
      HS(7891)=""
      HS(7892)=""
      HS(7893)=""
      HS(7894)=""
      HS(7895)=""
      HS(7896)=""
      HS(7897)=""
      HS(7898)=""
      HS(7899)=""
      HS(7900)=""
      HS(7901)=""
      HS(7902)=""
      HS(7903)=""
      HS(7904)=""
      HS(7905)=""
      HS(7906)=""
      HS(7907)=""
      HS(7908)=""
      HS(7909)=""
      HS(7910)=""
      HS(7911)=""
      HS(7912)=""
      HS(7913)=""
      HS(7914)=""
      HS(7915)=""
      HS(7916)=""
      HS(7917)=""
      HS(7918)=""
      HS(7919)=""
      HS(7920)=""
      HS(7921)=""
      HS(7922)=""
      HS(7923)=""
      HS(7924)=""
      HS(7925)=""
      HS(7926)=""
      HS(7927)=""
      HS(7928)=""
      HS(7929)=""
      HS(7930)=""
      HS(7931)=""
      HS(7932)=""
      HS(7933)=""
      HS(7934)=""
      HS(7935)=""
      HS(7936)=""
      HS(7937)=""
      HS(7938)=""
      HS(7939)=""
      HS(7940)=""
      HS(7941)=""
      HS(7942)=""
      HS(7943)=""
      HS(7944)=""
      HS(7945)=""
      HS(7946)=""
      HS(7947)=""
      HS(7948)=""
      HS(7949)=""
      HS(7950)=""
      HS(7951)=""
      HS(7952)=""
      HS(7953)=""
      HS(7954)=""
      HS(7955)=""
      HS(7956)=""
      HS(7957)=""
      HS(7958)=""
      HS(7959)=""
      HS(7960)=""
      HS(7961)=""
      HS(7962)=""
      HS(7963)=""
      HS(7964)=""
      HS(7965)=""
      HS(7966)=""
      HS(7967)=""
      HS(7968)=""
      HS(7969)=""
      HS(7970)=""
      HS(7971)=""
      HS(7972)=""
      HS(7973)=""
      HS(7974)=""
      HS(7975)=""
      HS(7976)=""
      HS(7977)=""
      HS(7978)=""
      HS(7979)=""
      HS(7980)=""
      HS(7981)=""
      HS(7982)=""
      HS(7983)=""
      HS(7984)=""
      HS(7985)=""
      HS(7986)=""
      HS(7987)=""
      HS(7988)=""
      HS(7989)=""
      HS(7990)=""
      HS(7991)=""
      HS(7992)=""
      HS(7993)=""
      HS(7994)=""
      HS(7995)=""
      HS(7996)=""
      HS(7997)=""
      HS(7998)=""
      HS(7999)=""
      HS(8000)=""
      HS(8001)=""
      HS(8002)=""
      HS(8003)=""
      HS(8004)=""
      HS(8005)=""
      HS(8006)=""
      HS(8007)=""
      HS(8008)=""
      HS(8009)=""
      HS(8010)=""
      HS(8011)=""
      HS(8012)=""
      HS(8013)=""
      HS(8014)=""
      HS(8015)=""
      HS(8016)=""
      HS(8017)=""
      HS(8018)=""
      HS(8019)=""
      HS(8020)=""
      HS(8021)=""
      HS(8022)=""
      HS(8023)=""
      HS(8024)=""
      HS(8025)=""
      HS(8026)=""
      HS(8027)=""
      HS(8028)=""
      HS(8029)=""
      HS(8030)=""
      HS(8031)=""
      HS(8032)=""
      HS(8033)=""
      HS(8034)=""
      HS(8035)=""
      HS(8036)=""
      HS(8037)=""
      HS(8038)=""
      HS(8039)=""
      HS(8040)=""
      HS(8041)=""
      HS(8042)=""
      HS(8043)=""
      HS(8044)=""
      HS(8045)=""
      HS(8046)=""
      HS(8047)=""
      HS(8048)=""
      HS(8049)=""
      HS(8050)=""
      HS(8051)=""
      HS(8052)=""
      HS(8053)=""
      HS(8054)=""
      HS(8055)=""
      HS(8056)=""
      HS(8057)=""
      HS(8058)=""
      HS(8059)=""
      HS(8060)=""
      HS(8061)=""
      HS(8062)=""
      HS(8063)=""
      HS(8064)=""
      HS(8065)=""
      HS(8066)=""
      HS(8067)=""
      HS(8068)=""
      HS(8069)=""
      HS(8070)=""
      HS(8071)=""
      HS(8072)=""
      HS(8073)=""
      HS(8074)=""
      HS(8075)=""
      HS(8076)=""
      HS(8077)=""
      HS(8078)=""
      HS(8079)=""
      HS(8080)=""
      HS(8081)=""
      HS(8082)=""
      HS(8083)=""
      HS(8084)=""
      HS(8085)=""
      HS(8086)=""
      HS(8087)=""
      HS(8088)=""
      HS(8089)=""
      HS(8090)=""
      HS(8091)=""
      HS(8092)=""
      HS(8093)=""
      HS(8094)=""
      HS(8095)=""
      HS(8096)=""
      HS(8097)=""
      HS(8098)=""
      HS(8099)=""
      HS(8100)=""
      HS(8101)=""
      HS(8102)=""
      HS(8103)=""
      HS(8104)=""
      HS(8105)=""
      HS(8106)=""
      HS(8107)=""
      HS(8108)=""
      HS(8109)=""
      HS(8110)=""
      HS(8111)=""
      HS(8112)=""
      HS(8113)=""
      HS(8114)=""
      HS(8115)=""
      HS(8116)=""
      HS(8117)=""
      HS(8118)=""
      HS(8119)=""
      HS(8120)=""
      HS(8121)=""
      HS(8122)=""
      HS(8123)=""
      HS(8124)=""
      HS(8125)=""
      HS(8126)=""
      HS(8127)=""
      HS(8128)=""
      HS(8129)=""
      HS(8130)=""
      HS(8131)=""
      HS(8132)=""
      HS(8133)=""
      HS(8134)=""
      HS(8135)=""
      HS(8136)=""
      HS(8137)=""
      HS(8138)=""
      HS(8139)=""
      HS(8140)=""
      HS(8141)=""
      HS(8142)=""
      HS(8143)=""
      HS(8144)=""
      HS(8145)=""
      HS(8146)=""
      HS(8147)=""
      HS(8148)=""
      HS(8149)=""
      HS(8150)=""
      HS(8151)=""
      HS(8152)=""
      HS(8153)=""
      HS(8154)=""
      HS(8155)=""
      HS(8156)=""
      HS(8157)=""
      HS(8158)=""
      HS(8159)=""
      HS(8160)=""
      HS(8161)=""
      HS(8162)=""
      HS(8163)=""
      HS(8164)=""
      HS(8165)=""
      HS(8166)=""
      HS(8167)=""
      HS(8168)=""
      HS(8169)=""
      HS(8170)=""
      HS(8171)=""
      HS(8172)=""
      HS(8173)=""
      HS(8174)=""
      HS(8175)=""
      HS(8176)=""
      HS(8177)=""
      HS(8178)=""
      HS(8179)=""
      HS(8180)=""
      HS(8181)=""
      HS(8182)=""
      HS(8183)=""
      HS(8184)=""
      HS(8185)=""
      HS(8186)=""
      HS(8187)=""
      HS(8188)=""
      HS(8189)=""
      HS(8190)=""
      HS(8191)=""
      HS(8192)=""
      HS(8193)=""
      HS(8194)=""
      HS(8195)=""
      HS(8196)=""
      HS(8197)=""
      HS(8198)=""
      HS(8199)=""
      HS(8200)=""
      HS(8201)=""
      HS(8202)=""
      HS(8203)=""
      HS(8204)=""
      HS(8205)=""
      HS(8206)=""
      HS(8207)=""
      HS(8208)=""
      HS(8209)=""
      HS(8210)=""
      HS(8211)=""
      HS(8212)=""
      HS(8213)=""
      HS(8214)=""
      HS(8215)=""
      HS(8216)=""
      HS(8217)=""
      HS(8218)=""
      HS(8219)=""
      HS(8220)=""
      HS(8221)=""
      HS(8222)=""
      HS(8223)=""
      HS(8224)=""
      HS(8225)=""
      HS(8226)=""
      HS(8227)=""
      HS(8228)=""
      HS(8229)=""
      HS(8230)=""
      HS(8231)=""
      HS(8232)=""
      HS(8233)=""
      HS(8234)=""
      HS(8235)=""
      HS(8236)=""
      HS(8237)=""
      HS(8238)=""
      HS(8239)=""
      HS(8240)=""
      HS(8241)=""
      HS(8242)=""
      HS(8243)=""
      HS(8244)=""
      HS(8245)=""
      HS(8246)=""
      HS(8247)=""
      HS(8248)=""
      HS(8249)=""
      HS(8250)=""
      HS(8251)=""
      HS(8252)=""
      HS(8253)=""
      HS(8254)=""
      HS(8255)=""
      HS(8256)=""
      HS(8257)=""
      HS(8258)=""
      HS(8259)=""
      HS(8260)=""
      HS(8261)=""
      HS(8262)=""
      HS(8263)=""
      HS(8264)=""
      HS(8265)=""
      HS(8266)=""
      HS(8267)=""
      HS(8268)=""
      HS(8269)=""
      HS(8270)=""
      HS(8271)=""
      HS(8272)=""
      HS(8273)=""
      HS(8274)=""
      HS(8275)=""
      HS(8276)=""
      HS(8277)=""
      HS(8278)=""
      HS(8279)=""
      HS(8280)=""
      HS(8281)=""
      HS(8282)=""
      HS(8283)=""
      HS(8284)=""
      HS(8285)=""
      HS(8286)=""
      HS(8287)=""
      HS(8288)=""
      HS(8289)=""
      HS(8290)=""
      HS(8291)=""
      HS(8292)=""
      HS(8293)=""
      HS(8294)=""
      HS(8295)=""
      HS(8296)=""
      HS(8297)=""
      HS(8298)=""
      HS(8299)=""
      HS(8300)=""
      HS(8301)=""
      HS(8302)=""
      HS(8303)=""
      HS(8304)=""
      HS(8305)=""
      HS(8306)=""
      HS(8307)=""
      HS(8308)=""
      HS(8309)=""
      HS(8310)=""
      HS(8311)=""
      HS(8312)=""
      HS(8313)=""
      HS(8314)=""
      HS(8315)=""
      HS(8316)=""
      HS(8317)=""
      HS(8318)=""
      HS(8319)=""
      HS(8320)=""
      HS(8321)=""
      HS(8322)=""
      HS(8323)=""
      HS(8324)=""
      HS(8325)=""
      HS(8326)=""
      HS(8327)=""
      HS(8328)=""
      HS(8329)=""
      HS(8330)=""
      HS(8331)=""
      HS(8332)=""
      HS(8333)=""
      HS(8334)=""
      HS(8335)=""
      HS(8336)=""
      HS(8337)=""
      HS(8338)=""
      HS(8339)=""
      HS(8340)=""
      HS(8341)=""
      HS(8342)=""
      HS(8343)=""
      HS(8344)=""
      HS(8345)=""
      HS(8346)=""
      HS(8347)=""
      HS(8348)=""
      HS(8349)=""
      HS(8350)=""
      HS(8351)=""
      HS(8352)=""
      HS(8353)=""
      HS(8354)=""
      HS(8355)=""
      HS(8356)=""
      HS(8357)=""
      HS(8358)=""
      HS(8359)=""
      HS(8360)=""
      HS(8361)=""
      HS(8362)=""
      HS(8363)=""
      HS(8364)=""
      HS(8365)=""
      HS(8366)=""
      HS(8367)=""
      HS(8368)=""
      HS(8369)=""
      HS(8370)=""
      HS(8371)=""
      HS(8372)=""
      HS(8373)=""
      HS(8374)=""
      HS(8375)=""
      HS(8376)=""
      HS(8377)=""
      HS(8378)=""
      HS(8379)=""
      HS(8380)=""
      HS(8381)=""
      HS(8382)=""
      HS(8383)=""
      HS(8384)=""
      HS(8385)=""
      HS(8386)=""
      HS(8387)=""
      HS(8388)=""
      HS(8389)=""
      HS(8390)=""
      HS(8391)=""
      HS(8392)=""
      HS(8393)=""
      HS(8394)=""
      HS(8395)=""
      HS(8396)=""
      HS(8397)=""
      HS(8398)=""
      HS(8399)=""
      HS(8400)=""
      HS(8401)=""
      HS(8402)=""
      HS(8403)=""
      HS(8404)=""
      HS(8405)=""
      HS(8406)=""
      HS(8407)=""
      HS(8408)=""
      HS(8409)=""
      HS(8410)=""
      HS(8411)=""
      HS(8412)=""
      HS(8413)=""
      HS(8414)=""
      HS(8415)=""
      HS(8416)=""
      HS(8417)=""
      HS(8418)=""
      HS(8419)=""
      HS(8420)=""
      HS(8421)=""
      HS(8422)=""
      HS(8423)=""
      HS(8424)=""
      HS(8425)=""
      HS(8426)=""
      HS(8427)=""
      HS(8428)=""
      HS(8429)=""
      HS(8430)=""
      HS(8431)=""
      HS(8432)=""
      HS(8433)=""
      HS(8434)=""
      HS(8435)=""
      HS(8436)=""
      HS(8437)=""
      HS(8438)=""
      HS(8439)=""
      HS(8440)=""
      HS(8441)=""
      HS(8442)=""
      HS(8443)=""
      HS(8444)=""
      HS(8445)=""
      HS(8446)=""
      HS(8447)=""
      HS(8448)=""
      HS(8449)=""
      HS(8450)=""
      HS(8451)=""
      HS(8452)=""
      HS(8453)=""
      HS(8454)=""
      HS(8455)=""
      HS(8456)=""
      HS(8457)=""
      HS(8458)=""
      HS(8459)=""
      HS(8460)=""
      HS(8461)=""
      HS(8462)=""
      HS(8463)=""
      HS(8464)=""
      HS(8465)=""
      HS(8466)=""
      HS(8467)=""
      HS(8468)=""
      HS(8469)=""
      HS(8470)=""
      HS(8471)=""
      HS(8472)=""
      HS(8473)=""
      HS(8474)=""
      HS(8475)=""
      HS(8476)=""
      HS(8477)=""
      HS(8478)=""
      HS(8479)=""
      HS(8480)=""
      HS(8481)=""
      HS(8482)=""
      HS(8483)=""
      HS(8484)=""
      HS(8485)=""
      HS(8486)=""
      HS(8487)=""
      HS(8488)=""
      HS(8489)=""
      HS(8490)=""
      HS(8491)=""
      HS(8492)=""
      HS(8493)=""
      HS(8494)=""
      HS(8495)=""
      HS(8496)=""
      HS(8497)=""
      HS(8498)=""
      HS(8499)=""
      HS(8500)=""
      HS(8501)=""
      HS(8502)=""
      HS(8503)=""
      HS(8504)=""
      HS(8505)=""
      HS(8506)=""
      HS(8507)=""
      HS(8508)=""
      HS(8509)=""
      HS(8510)=""
      HS(8511)=""
      HS(8512)=""
      HS(8513)=""
      HS(8514)=""
      HS(8515)=""
      HS(8516)=""
      HS(8517)=""
      HS(8518)=""
      HS(8519)=""
      HS(8520)=""
      HS(8521)=""
      HS(8522)=""
      HS(8523)=""
      HS(8524)=""
      HS(8525)=""
      HS(8526)=""
      HS(8527)=""
      HS(8528)=""
      HS(8529)=""
      HS(8530)=""
      HS(8531)=""
      HS(8532)=""
      HS(8533)=""
      HS(8534)=""
      HS(8535)=""
      HS(8536)=""
      HS(8537)=""
      HS(8538)=""
      HS(8539)=""
      HS(8540)=""
      HS(8541)=""
      HS(8542)=""
      HS(8543)=""
      HS(8544)=""
      HS(8545)=""
      HS(8546)=""
      HS(8547)=""
      HS(8548)=""
      HS(8549)=""
      HS(8550)=""
      HS(8551)=""
      HS(8552)=""
      HS(8553)=""
      HS(8554)=""
      HS(8555)=""
      HS(8556)=""
      HS(8557)=""
      HS(8558)=""
      HS(8559)=""
      HS(8560)=""
      HS(8561)=""
      HS(8562)=""
      HS(8563)=""
      HS(8564)=""
      HS(8565)=""
      HS(8566)=""
      HS(8567)=""
      HS(8568)=""
      HS(8569)=""
      HS(8570)=""
      HS(8571)=""
      HS(8572)=""
      HS(8573)=""
      HS(8574)=""
      HS(8575)=""
      HS(8576)=""
      HS(8577)=""
      HS(8578)=""
      HS(8579)=""
      HS(8580)=""
      HS(8581)=""
      HS(8582)=""
      HS(8583)=""
      HS(8584)=""
      HS(8585)=""
      HS(8586)=""
      HS(8587)=""
      HS(8588)=""
      HS(8589)=""
      HS(8590)=""
      HS(8591)=""
      HS(8592)=""
      HS(8593)=""
      HS(8594)=""
      HS(8595)=""
      HS(8596)=""
      HS(8597)=""
      HS(8598)=""
      HS(8599)=""
      HS(8600)=""
      HS(8601)=""
      HS(8602)=""
      HS(8603)=""
      HS(8604)=""
      HS(8605)=""
      HS(8606)=""
      HS(8607)=""
      HS(8608)=""
      HS(8609)=""
      HS(8610)=""
      HS(8611)=""
      HS(8612)=""
      HS(8613)=""
      HS(8614)=""
      HS(8615)=""
      HS(8616)=""
      HS(8617)=""
      HS(8618)=""
      HS(8619)=""
      HS(8620)=""
      HS(8621)=""
      HS(8622)=""
      HS(8623)=""
      HS(8624)=""
      HS(8625)=""
      HS(8626)=""
      HS(8627)=""
      HS(8628)=""
      HS(8629)=""
      HS(8630)=""
      HS(8631)=""
      HS(8632)=""
      HS(8633)=""
      HS(8634)=""
      HS(8635)=""
      HS(8636)=""
      HS(8637)=""
      HS(8638)=""
      HS(8639)=""
      HS(8640)=""
      HS(8641)=""
      HS(8642)=""
      HS(8643)=""
      HS(8644)=""
      HS(8645)=""
      HS(8646)=""
      HS(8647)=""
      HS(8648)=""
      HS(8649)=""
      HS(8650)=""
      HS(8651)=""
      HS(8652)=""
      HS(8653)=""
      HS(8654)=""
      HS(8655)=""
      HS(8656)=""
      HS(8657)=""
      HS(8658)=""
      HS(8659)=""
      HS(8660)=""
      HS(8661)=""
      HS(8662)=""
      HS(8663)=""
      HS(8664)=""
      HS(8665)=""
      HS(8666)=""
      HS(8667)=""
      HS(8668)=""
      HS(8669)=""
      HS(8670)=""
      HS(8671)=""
      HS(8672)=""
      HS(8673)=""
      HS(8674)=""
      HS(8675)=""
      HS(8676)=""
      HS(8677)=""
      HS(8678)=""
      HS(8679)=""
      HS(8680)=""
      HS(8681)=""
      HS(8682)=""
      HS(8683)=""
      HS(8684)=""
      HS(8685)=""
      HS(8686)=""
      HS(8687)=""
      HS(8688)=""
      HS(8689)=""
      HS(8690)=""
      HS(8691)=""
      HS(8692)=""
      HS(8693)=""
      HS(8694)=""
      HS(8695)=""
      HS(8696)=""
      HS(8697)=""
      HS(8698)=""
      HS(8699)=""
      HS(8700)=""
      HS(8701)=""
      HS(8702)=""
      HS(8703)=""
      HS(8704)=""
      HS(8705)=""
      HS(8706)=""
      HS(8707)=""
      HS(8708)=""
      HS(8709)=""
      HS(8710)=""
      HS(8711)=""
      HS(8712)=""
      HS(8713)=""
      HS(8714)=""
      HS(8715)=""
      HS(8716)=""
      HS(8717)=""
      HS(8718)=""
      HS(8719)=""
      HS(8720)=""
      HS(8721)=""
      HS(8722)=""
      HS(8723)=""
      HS(8724)=""
      HS(8725)=""
      HS(8726)=""
      HS(8727)=""
      HS(8728)=""
      HS(8729)=""
      HS(8730)=""
      HS(8731)=""
      HS(8732)=""
      HS(8733)=""
      HS(8734)=""
      HS(8735)=""
      HS(8736)=""
      HS(8737)=""
      HS(8738)=""
      HS(8739)=""
      HS(8740)=""
      HS(8741)=""
      HS(8742)=""
      HS(8743)=""
      HS(8744)=""
      HS(8745)=""
      HS(8746)=""
      HS(8747)=""
      HS(8748)=""
      HS(8749)=""
      HS(8750)=""
      HS(8751)=""
      HS(8752)=""
      HS(8753)=""
      HS(8754)=""
      HS(8755)=""
      HS(8756)=""
      HS(8757)=""
      HS(8758)=""
      HS(8759)=""
      HS(8760)=""
      HS(8761)=""
      HS(8762)=""
      HS(8763)=""
      HS(8764)=""
      HS(8765)=""
      HS(8766)=""
      HS(8767)=""
      HS(8768)=""
      HS(8769)=""
      HS(8770)=""
      HS(8771)=""
      HS(8772)=""
      HS(8773)=""
      HS(8774)=""
      HS(8775)=""
      HS(8776)=""
      HS(8777)=""
      HS(8778)=""
      HS(8779)=""
      HS(8780)=""
      HS(8781)=""
      HS(8782)=""
      HS(8783)=""
      HS(8784)=""
      HS(8785)=""
      HS(8786)=""
      HS(8787)=""
      HS(8788)=""
      HS(8789)=""
      HS(8790)=""
      HS(8791)=""
      HS(8792)=""
      HS(8793)=""
      HS(8794)=""
      HS(8795)=""
      HS(8796)=""
      HS(8797)=""
      HS(8798)=""
      HS(8799)=""
      HS(8800)=""
      HS(8801)=""
      HS(8802)=""
      HS(8803)=""
      HS(8804)=""
      HS(8805)=""
      HS(8806)=""
      HS(8807)=""
      HS(8808)=""
      HS(8809)=""
      HS(8810)=""
      HS(8811)=""
      HS(8812)=""
      HS(8813)=""
      HS(8814)=""
      HS(8815)=""
      HS(8816)=""
      HS(8817)=""
      HS(8818)=""
      HS(8819)=""
      HS(8820)=""
      HS(8821)=""
      HS(8822)=""
      HS(8823)=""
      HS(8824)=""
      HS(8825)=""
      HS(8826)=""
      HS(8827)=""
      HS(8828)=""
      HS(8829)=""
      HS(8830)=""
      HS(8831)=""
      HS(8832)=""
      HS(8833)=""
      HS(8834)=""
      HS(8835)=""
      HS(8836)=""
      HS(8837)=""
      HS(8838)=""
      HS(8839)=""
      HS(8840)=""
      HS(8841)=""
      HS(8842)=""
      HS(8843)=""
      HS(8844)=""
      HS(8845)=""
      HS(8846)=""
      HS(8847)=""
      HS(8848)=""
      HS(8849)=""
      HS(8850)=""
      HS(8851)=""
      HS(8852)=""
      HS(8853)=""
      HS(8854)=""
      HS(8855)=""
      HS(8856)=""
      HS(8857)=""
      HS(8858)=""
      HS(8859)=""
      HS(8860)=""
      HS(8861)=""
      HS(8862)=""
      HS(8863)=""
      HS(8864)=""
      HS(8865)=""
      HS(8866)=""
      HS(8867)=""
      HS(8868)=""
      HS(8869)=""
      HS(8870)=""
      HS(8871)=""
      HS(8872)=""
      HS(8873)=""
      HS(8874)=""
      HS(8875)=""
      HS(8876)=""
      HS(8877)=""
      HS(8878)=""
      HS(8879)=""
      HS(8880)=""
      HS(8881)=""
      HS(8882)=""
      HS(8883)=""
      HS(8884)=""
      HS(8885)=""
      HS(8886)=""
      HS(8887)=""
      HS(8888)=""
      HS(8889)=""
      HS(8890)=""
      HS(8891)=""
      HS(8892)=""
      HS(8893)=""
      HS(8894)=""
      HS(8895)=""
      HS(8896)=""
      HS(8897)=""
      HS(8898)=""
      HS(8899)=""
      HS(8900)=""
      HS(8901)=""
      HS(8902)=""
      HS(8903)=""
      HS(8904)=""
      HS(8905)=""
      HS(8906)=""
      HS(8907)=""
      HS(8908)=""
      HS(8909)=""
      HS(8910)=""
      HS(8911)=""
      HS(8912)=""
      HS(8913)=""
      HS(8914)=""
      HS(8915)=""
      HS(8916)=""
      HS(8917)=""
      HS(8918)=""
      HS(8919)=""
      HS(8920)=""
      HS(8921)=""
      HS(8922)=""
      HS(8923)=""
      HS(8924)=""
      HS(8925)=""
      HS(8926)=""
      HS(8927)=""
      HS(8928)=""
      HS(8929)=""
      HS(8930)=""
      HS(8931)=""
      HS(8932)=""
      HS(8933)=""
      HS(8934)=""
      HS(8935)=""
      HS(8936)=""
      HS(8937)=""
      HS(8938)=""
      HS(8939)=""
      HS(8940)=""
      HS(8941)=""
      HS(8942)=""
      HS(8943)=""
      HS(8944)=""
      HS(8945)=""
      HS(8946)=""
      HS(8947)=""
      HS(8948)=""
      HS(8949)=""
      HS(8950)=""
      HS(8951)=""
      HS(8952)=""
      HS(8953)=""
      HS(8954)=""
      HS(8955)=""
      HS(8956)=""
      HS(8957)=""
      HS(8958)=""
      HS(8959)=""
      HS(8960)=""
      HS(8961)=""
      HS(8962)=""
      HS(8963)=""
      HS(8964)=""
      HS(8965)=""
      HS(8966)=""
      HS(8967)=""
      HS(8968)=""
      HS(8969)=""
      HS(8970)=""
      HS(8971)=""
      HS(8972)=""
      HS(8973)=""
      HS(8974)=""
      HS(8975)=""
      HS(8976)=""
      HS(8977)=""
      HS(8978)=""
      HS(8979)=""
      HS(8980)=""
      HS(8981)=""
      HS(8982)=""
      HS(8983)=""
      HS(8984)=""
      HS(8985)=""
      HS(8986)=""
      HS(8987)=""
      HS(8988)=""
      HS(8989)=""
      HS(8990)=""
      HS(8991)=""
      HS(8992)=""
      HS(8993)=""
      HS(8994)=""
      HS(8995)=""
      HS(8996)=""
      HS(8997)=""
      HS(8998)=""
      HS(8999)=""
      HS(9000)=""
      HS(9001)=""
      HS(9002)=""
      HS(9003)=""
      HS(9004)=""
      HS(9005)=""
      HS(9006)=""
      HS(9007)=""
      HS(9008)=""
      HS(9009)=""
      HS(9010)=""
      HS(9011)=""
      HS(9012)=""
      HS(9013)=""
      HS(9014)=""
      HS(9015)=""
      HS(9016)=""
      HS(9017)=""
      HS(9018)=""
      HS(9019)=""
      HS(9020)=""
      HS(9021)=""
      HS(9022)=""
      HS(9023)=""
      HS(9024)=""
      HS(9025)=""
      HS(9026)=""
      HS(9027)=""
      HS(9028)=""
      HS(9029)=""
      HS(9030)=""
      HS(9031)=""
      HS(9032)=""
      HS(9033)=""
      HS(9034)=""
      HS(9035)=""
      HS(9036)=""
      HS(9037)=""
      HS(9038)=""
      HS(9039)=""
      HS(9040)=""
      HS(9041)=""
      HS(9042)=""
      HS(9043)=""
      HS(9044)=""
      HS(9045)=""
      HS(9046)=""
      HS(9047)=""
      HS(9048)=""
      HS(9049)=""
      HS(9050)=""
      HS(9051)=""
      HS(9052)=""
      HS(9053)=""
      HS(9054)=""
      HS(9055)=""
      HS(9056)=""
      HS(9057)=""
      HS(9058)=""
      HS(9059)=""
      HS(9060)=""
      HS(9061)=""
      HS(9062)=""
      HS(9063)=""
      HS(9064)=""
      HS(9065)=""
      HS(9066)=""
      HS(9067)=""
      HS(9068)=""
      HS(9069)=""
      HS(9070)=""
      HS(9071)=""
      HS(9072)=""
      HS(9073)=""
      HS(9074)=""
      HS(9075)=""
      HS(9076)=""
      HS(9077)=""
      HS(9078)=""
      HS(9079)=""
      HS(9080)=""
      HS(9081)=""
      HS(9082)=""
      HS(9083)=""
      HS(9084)=""
      HS(9085)=""
      HS(9086)=""
      HS(9087)=""
      HS(9088)=""
      HS(9089)=""
      HS(9090)=""
      HS(9091)=""
      HS(9092)=""
      HS(9093)=""
      HS(9094)=""
      HS(9095)=""
      HS(9096)=""
      HS(9097)=""
      HS(9098)=""
      HS(9099)=""
      HS(9100)=""
      HS(9101)=""
      HS(9102)=""
      HS(9103)=""
      HS(9104)=""
      HS(9105)=""
      HS(9106)=""
      HS(9107)=""
      HS(9108)=""
      HS(9109)=""
      HS(9110)=""
      HS(9111)=""
      HS(9112)=""
      HS(9113)=""
      HS(9114)=""
      HS(9115)=""
      HS(9116)=""
      HS(9117)=""
      HS(9118)=""
      HS(9119)=""
      HS(9120)=""
      HS(9121)=""
      HS(9122)=""
      HS(9123)=""
      HS(9124)=""
      HS(9125)=""
      HS(9126)=""
      HS(9127)=""
      HS(9128)=""
      HS(9129)=""
      HS(9130)=""
      HS(9131)=""
      HS(9132)=""
      HS(9133)=""
      HS(9134)=""
      HS(9135)=""
      HS(9136)=""
      HS(9137)=""
      HS(9138)=""
      HS(9139)=""
      HS(9140)=""
      HS(9141)=""
      HS(9142)=""
      HS(9143)=""
      HS(9144)=""
      HS(9145)=""
      HS(9146)=""
      HS(9147)=""
      HS(9148)=""
      HS(9149)=""
      HS(9150)=""
      HS(9151)=""
      HS(9152)=""
      HS(9153)=""
      HS(9154)=""
      HS(9155)=""
      HS(9156)=""
      HS(9157)=""
      HS(9158)=""
      HS(9159)=""
      HS(9160)=""
      HS(9161)=""
      HS(9162)=""
      HS(9163)=""
      HS(9164)=""
      HS(9165)=""
      HS(9166)=""
      HS(9167)=""
      HS(9168)=""
      HS(9169)=""
      HS(9170)=""
      HS(9171)=""
      HS(9172)=""
      HS(9173)=""
      HS(9174)=""
      HS(9175)=""
      HS(9176)=""
      HS(9177)=""
      HS(9178)=""
      HS(9179)=""
      HS(9180)=""
      HS(9181)=""
      HS(9182)=""
      HS(9183)=""
      HS(9184)=""
      HS(9185)=""
      HS(9186)=""
      HS(9187)=""
      HS(9188)=""
      HS(9189)=""
      HS(9190)=""
      HS(9191)=""
      HS(9192)=""
      HS(9193)=""
      HS(9194)=""
      HS(9195)=""
      HS(9196)=""
      HS(9197)=""
      HS(9198)=""
      HS(9199)=""
      HS(9200)=""
      HS(9201)=""
      HS(9202)=""
      HS(9203)=""
      HS(9204)=""
      HS(9205)=""
      HS(9206)=""
      HS(9207)=""
      HS(9208)=""
      HS(9209)=""
      HS(9210)=""
      HS(9211)=""
      HS(9212)=""
      HS(9213)=""
      HS(9214)=""
      HS(9215)=""
      HS(9216)=""
      HS(9217)=""
      HS(9218)=""
      HS(9219)=""
      HS(9220)=""
      HS(9221)=""
      HS(9222)=""
      HS(9223)=""
      HS(9224)=""
      HS(9225)=""
      HS(9226)=""
      HS(9227)=""
      HS(9228)=""
      HS(9229)=""
      HS(9230)=""
      HS(9231)=""
      HS(9232)=""
      HS(9233)=""
      HS(9234)=""
      HS(9235)=""
      HS(9236)=""
      HS(9237)=""
      HS(9238)=""
      HS(9239)=""
      HS(9240)=""
      HS(9241)=""
      HS(9242)=""
      HS(9243)=""
      HS(9244)=""
      HS(9245)=""
      HS(9246)=""
      HS(9247)=""
      HS(9248)=""
      HS(9249)=""
      HS(9250)=""
      HS(9251)=""
      HS(9252)=""
      HS(9253)=""
      HS(9254)=""
      HS(9255)=""
      HS(9256)=""
      HS(9257)=""
      HS(9258)=""
      HS(9259)=""
      HS(9260)=""
      HS(9261)=""
      HS(9262)=""
      HS(9263)=""
      HS(9264)=""
      HS(9265)=""
      HS(9266)=""
      HS(9267)=""
      HS(9268)=""
      HS(9269)=""
      HS(9270)=""
      HS(9271)=""
      HS(9272)=""
      HS(9273)=""
      HS(9274)=""
      HS(9275)=""
      HS(9276)=""
      HS(9277)=""
      HS(9278)=""
      HS(9279)=""
      HS(9280)=""
      HS(9281)=""
      HS(9282)=""
      HS(9283)=""
      HS(9284)=""
      HS(9285)=""
      HS(9286)=""
      HS(9287)=""
      HS(9288)=""
      HS(9289)=""
      HS(9290)=""
      HS(9291)=""
      HS(9292)=""
      HS(9293)=""
      HS(9294)=""
      HS(9295)=""
      HS(9296)=""
      HS(9297)=""
      HS(9298)=""
      HS(9299)=""
      HS(9300)=""
      HS(9301)=""
      HS(9302)=""
      HS(9303)=""
      HS(9304)=""
      HS(9305)=""
      HS(9306)=""
      HS(9307)=""
      HS(9308)=""
      HS(9309)=""
      HS(9310)=""
      HS(9311)=""
      HS(9312)=""
      HS(9313)=""
      HS(9314)=""
      HS(9315)=""
      HS(9316)=""
      HS(9317)=""
      HS(9318)=""
      HS(9319)=""
      HS(9320)=""
      HS(9321)=""
      HS(9322)=""
      HS(9323)=""
      HS(9324)=""
      HS(9325)=""
      HS(9326)=""
      HS(9327)=""
      HS(9328)=""
      HS(9329)=""
      HS(9330)=""
      HS(9331)=""
      HS(9332)=""
      HS(9333)=""
      HS(9334)=""
      HS(9335)=""
      HS(9336)=""
      HS(9337)=""
      HS(9338)=""
      HS(9339)=""
      HS(9340)=""
      HS(9341)=""
      HS(9342)=""
      HS(9343)=""
      HS(9344)=""
      HS(9345)=""
      HS(9346)=""
      HS(9347)=""
      HS(9348)=""
      HS(9349)=""
      HS(9350)=""
      HS(9351)=""
      HS(9352)=""
      HS(9353)=""
      HS(9354)=""
      HS(9355)=""
      HS(9356)=""
      HS(9357)=""
      HS(9358)=""
      HS(9359)=""
      HS(9360)=""
      HS(9361)=""
      HS(9362)=""
      HS(9363)=""
      HS(9364)=""
      HS(9365)=""
      HS(9366)=""
      HS(9367)=""
      HS(9368)=""
      HS(9369)=""
      HS(9370)=""
      HS(9371)=""
      HS(9372)=""
      HS(9373)=""
      HS(9374)=""
      HS(9375)=""
      HS(9376)=""
      HS(9377)=""
      HS(9378)=""
      HS(9379)=""
      HS(9380)=""
      HS(9381)=""
      HS(9382)=""
      HS(9383)=""
      HS(9384)=""
      HS(9385)=""
      HS(9386)=""
      HS(9387)=""
      HS(9388)=""
      HS(9389)=""
      HS(9390)=""
      HS(9391)=""
      HS(9392)=""
      HS(9393)=""
      HS(9394)=""
      HS(9395)=""
      HS(9396)=""
      HS(9397)=""
      HS(9398)=""
      HS(9399)=""
      HS(9400)=""
      HS(9401)=""
      HS(9402)=""
      HS(9403)=""
      HS(9404)=""
      HS(9405)=""
      HS(9406)=""
      HS(9407)=""
      HS(9408)=""
      HS(9409)=""
      HS(9410)=""
      HS(9411)=""
      HS(9412)=""
      HS(9413)=""
      HS(9414)=""
      HS(9415)=""
      HS(9416)=""
      HS(9417)=""
      HS(9418)=""
      HS(9419)=""
      HS(9420)=""
      HS(9421)=""
      HS(9422)=""
      HS(9423)=""
      HS(9424)=""
      HS(9425)=""
      HS(9426)=""
      HS(9427)=""
      HS(9428)=""
      HS(9429)=""
      HS(9430)=""
      HS(9431)=""
      HS(9432)=""
      HS(9433)=""
      HS(9434)=""
      HS(9435)=""
      HS(9436)=""
      HS(9437)=""
      HS(9438)=""
      HS(9439)=""
      HS(9440)=""
      HS(9441)=""
      HS(9442)=""
      HS(9443)=""
      HS(9444)=""
      HS(9445)=""
      HS(9446)=""
      HS(9447)=""
      HS(9448)=""
      HS(9449)=""
      HS(9450)=""
      HS(9451)=""
      HS(9452)=""
      HS(9453)=""
      HS(9454)=""
      HS(9455)=""
      HS(9456)=""
      HS(9457)=""
      HS(9458)=""
      HS(9459)=""
      HS(9460)=""
      HS(9461)=""
      HS(9462)=""
      HS(9463)=""
      HS(9464)=""
      HS(9465)=""
      HS(9466)=""
      HS(9467)=""
      HS(9468)=""
      HS(9469)=""
      HS(9470)=""
      HS(9471)=""
      HS(9472)=""
      HS(9473)=""
      HS(9474)=""
      HS(9475)=""
      HS(9476)=""
      HS(9477)=""
      HS(9478)=""
      HS(9479)=""
      HS(9480)=""
      HS(9481)=""
      HS(9482)=""
      HS(9483)=""
      HS(9484)=""
      HS(9485)=""
      HS(9486)=""
      HS(9487)=""
      HS(9488)=""
      HS(9489)=""
      HS(9490)=""
      HS(9491)=""
      HS(9492)=""
      HS(9493)=""
      HS(9494)=""
      HS(9495)=""
      HS(9496)=""
      HS(9497)=""
      HS(9498)=""
      HS(9499)=""
      HS(9500)=""
      HS(9501)=""
      HS(9502)=""
      HS(9503)=""
      HS(9504)=""
      HS(9505)=""
      HS(9506)=""
      HS(9507)=""
      HS(9508)=""
      HS(9509)=""
      HS(9510)=""
      HS(9511)=""
      HS(9512)=""
      HS(9513)=""
      HS(9514)=""
      HS(9515)=""
      HS(9516)=""
      HS(9517)=""
      HS(9518)=""
      HS(9519)=""
      HS(9520)=""
      HS(9521)=""
      HS(9522)=""
      HS(9523)=""
      HS(9524)=""
      HS(9525)=""
      HS(9526)=""
      HS(9527)=""
      HS(9528)=""
      HS(9529)=""
      HS(9530)=""
      HS(9531)=""
      HS(9532)=""
      HS(9533)=""
      HS(9534)=""
      HS(9535)=""
      HS(9536)=""
      HS(9537)=""
      HS(9538)=""
      HS(9539)=""
      HS(9540)=""
      HS(9541)=""
      HS(9542)=""
      HS(9543)=""
      HS(9544)=""
      HS(9545)=""
      HS(9546)=""
      HS(9547)=""
      HS(9548)=""
      HS(9549)=""
      HS(9550)=""
      HS(9551)=""
      HS(9552)=""
      HS(9553)=""
      HS(9554)=""
      HS(9555)=""
      HS(9556)=""
      HS(9557)=""
      HS(9558)=""
      HS(9559)=""
      HS(9560)=""
      HS(9561)=""
      HS(9562)=""
      HS(9563)=""
      HS(9564)=""
      HS(9565)=""
      HS(9566)=""
      HS(9567)=""
      HS(9568)=""
      HS(9569)=""
      HS(9570)=""
      HS(9571)=""
      HS(9572)=""
      HS(9573)=""
      HS(9574)=""
      HS(9575)=""
      HS(9576)=""
      HS(9577)=""
      HS(9578)=""
      HS(9579)=""
      HS(9580)=""
      HS(9581)=""
      HS(9582)=""
      HS(9583)=""
      HS(9584)=""
      HS(9585)=""
      HS(9586)=""
      HS(9587)=""
      HS(9588)=""
      HS(9589)=""
      HS(9590)=""
      HS(9591)=""
      HS(9592)=""
      HS(9593)=""
      HS(9594)=""
      HS(9595)=""
      HS(9596)=""
      HS(9597)=""
      HS(9598)=""
      HS(9599)=""
      HS(9600)=""
      HS(9601)=""
      HS(9602)=""
      HS(9603)=""
      HS(9604)=""
      HS(9605)=""
      HS(9606)=""
      HS(9607)=""
      HS(9608)=""
      HS(9609)=""
      HS(9610)=""
      HS(9611)=""
      HS(9612)=""
      HS(9613)=""
      HS(9614)=""
      HS(9615)=""
      HS(9616)=""
      HS(9617)=""
      HS(9618)=""
      HS(9619)=""
      HS(9620)=""
      HS(9621)=""
      HS(9622)=""
      HS(9623)=""
      HS(9624)=""
      HS(9625)=""
      HS(9626)=""
      HS(9627)=""
      HS(9628)=""
      HS(9629)=""
      HS(9630)=""
      HS(9631)=""
      HS(9632)=""
      HS(9633)=""
      HS(9634)=""
      HS(9635)=""
      HS(9636)=""
      HS(9637)=""
      HS(9638)=""
      HS(9639)=""
      HS(9640)=""
      HS(9641)=""
      HS(9642)=""
      HS(9643)=""
      HS(9644)=""
      HS(9645)=""
      HS(9646)=""
      HS(9647)=""
      HS(9648)=""
      HS(9649)=""
      HS(9650)=""
      HS(9651)=""
      HS(9652)=""
      HS(9653)=""
      HS(9654)=""
      HS(9655)=""
      HS(9656)=""
      HS(9657)=""
      HS(9658)=""
      HS(9659)=""
      HS(9660)=""
      HS(9661)=""
      HS(9662)=""
      HS(9663)=""
      HS(9664)=""
      HS(9665)=""
      HS(9666)=""
      HS(9667)=""
      HS(9668)=""
      HS(9669)=""
      HS(9670)=""
      HS(9671)=""
      HS(9672)=""
      HS(9673)=""
      HS(9674)=""
      HS(9675)=""
      HS(9676)=""
      HS(9677)=""
      HS(9678)=""
      HS(9679)=""
      HS(9680)=""
      HS(9681)=""
      HS(9682)=""
      HS(9683)=""
      HS(9684)=""
      HS(9685)=""
      HS(9686)=""
      HS(9687)=""
      HS(9688)=""
      HS(9689)=""
      HS(9690)=""
      HS(9691)=""
      HS(9692)=""
      HS(9693)=""
      HS(9694)=""
      HS(9695)=""
      HS(9696)=""
      HS(9697)=""
      HS(9698)=""
      HS(9699)=""
      HS(9700)=""
      HS(9701)=""
      HS(9702)=""
      HS(9703)=""
      HS(9704)=""
      HS(9705)=""
      HS(9706)=""
      HS(9707)=""
      HS(9708)=""
      HS(9709)=""
      HS(9710)=""
      HS(9711)=""
      HS(9712)=""
      HS(9713)=""
      HS(9714)=""
      HS(9715)=""
      HS(9716)=""
      HS(9717)=""
      HS(9718)=""
      HS(9719)=""
      HS(9720)=""
      HS(9721)=""
      HS(9722)=""
      HS(9723)=""
      HS(9724)=""
      HS(9725)=""
      HS(9726)=""
      HS(9727)=""
      HS(9728)=""
      HS(9729)=""
      HS(9730)=""
      HS(9731)=""
      HS(9732)=""
      HS(9733)=""
      HS(9734)=""
      HS(9735)=""
      HS(9736)=""
      HS(9737)=""
      HS(9738)=""
      HS(9739)=""
      HS(9740)=""
      HS(9741)=""
      HS(9742)=""
      HS(9743)=""
      HS(9744)=""
      HS(9745)=""
      HS(9746)=""
      HS(9747)=""
      HS(9748)=""
      HS(9749)=""
      HS(9750)=""
      HS(9751)=""
      HS(9752)=""
      HS(9753)=""
      HS(9754)=""
      HS(9755)=""
      HS(9756)=""
      HS(9757)=""
      HS(9758)=""
      HS(9759)=""
      HS(9760)=""
      HS(9761)=""
      HS(9762)=""
      HS(9763)=""
      HS(9764)=""
      HS(9765)=""
      HS(9766)=""
      HS(9767)=""
      HS(9768)=""
      HS(9769)=""
      HS(9770)=""
      HS(9771)=""
      HS(9772)=""
      HS(9773)=""
      HS(9774)=""
      HS(9775)=""
      HS(9776)=""
      HS(9777)=""
      HS(9778)=""
      HS(9779)=""
      HS(9780)=""
      HS(9781)=""
      HS(9782)=""
      HS(9783)=""
      HS(9784)=""
      HS(9785)=""
      HS(9786)=""
      HS(9787)=""
      HS(9788)=""
      HS(9789)=""
      HS(9790)=""
      HS(9791)=""
      HS(9792)=""
      HS(9793)=""
      HS(9794)=""
      HS(9795)=""
      HS(9796)=""
      HS(9797)=""
      HS(9798)=""
      HS(9799)=""
      HS(9800)=""
      HS(9801)=""
      HS(9802)=""
      HS(9803)=""
      HS(9804)=""
      HS(9805)=""
      HS(9806)=""
      HS(9807)=""
      HS(9808)=""
      HS(9809)=""
      HS(9810)=""
      HS(9811)=""
      HS(9812)=""
      HS(9813)=""
      HS(9814)=""
      HS(9815)=""
      HS(9816)=""
      HS(9817)=""
      HS(9818)=""
      HS(9819)=""
      HS(9820)=""
      HS(9821)=""
      HS(9822)=""
      HS(9823)=""
      HS(9824)=""
      HS(9825)=""
      HS(9826)=""
      HS(9827)=""
      HS(9828)=""
      HS(9829)=""
      HS(9830)=""
      HS(9831)=""
      HS(9832)=""
      HS(9833)=""
      HS(9834)=""
      HS(9835)=""
      HS(9836)=""
      HS(9837)=""
      HS(9838)=""
      HS(9839)=""
      HS(9840)=""
      HS(9841)=""
      HS(9842)=""
      HS(9843)=""
      HS(9844)=""
      HS(9845)=""
      HS(9846)=""
      HS(9847)=""
      HS(9848)=""
      HS(9849)=""
      HS(9850)=""
      HS(9851)=""
      HS(9852)=""
      HS(9853)=""
      HS(9854)=""
      HS(9855)=""
      HS(9856)=""
      HS(9857)=""
      HS(9858)=""
      HS(9859)=""
      HS(9860)=""
      HS(9861)=""
      HS(9862)=""
      HS(9863)=""
      HS(9864)=""
      HS(9865)=""
      HS(9866)=""
      HS(9867)=""
      HS(9868)=""
      HS(9869)=""
      HS(9870)=""
      HS(9871)=""
      HS(9872)=""
      HS(9873)=""
      HS(9874)=""
      HS(9875)=""
      HS(9876)=""
      HS(9877)=""
      HS(9878)=""
      HS(9879)=""
      HS(9880)=""
      HS(9881)=""
      HS(9882)=""
      HS(9883)=""
      HS(9884)=""
      HS(9885)=""
      HS(9886)=""
      HS(9887)=""
      HS(9888)=""
      HS(9889)=""
      HS(9890)=""
      HS(9891)=""
      HS(9892)=""
      HS(9893)=""
      HS(9894)=""
      HS(9895)=""
      HS(9896)=""
      HS(9897)=""
      HS(9898)=""
      HS(9899)=""
      HS(9900)=""
      HS(9901)=""
      HS(9902)=""
      HS(9903)=""
      HS(9904)=""
      HS(9905)=""
      HS(9906)=""
      HS(9907)=""
      HS(9908)=""
      HS(9909)=""
      HS(9910)=""
      HS(9911)=""
      HS(9912)=""
      HS(9913)=""
      HS(9914)=""
      HS(9915)=""
      HS(9916)=""
      HS(9917)=""
      HS(9918)=""
      HS(9919)=""
      HS(9920)=""
      HS(9921)=""
      HS(9922)=""
      HS(9923)=""
      HS(9924)=""
      HS(9925)=""
      HS(9926)=""
      HS(9927)=""
      HS(9928)=""
      HS(9929)=""
      HS(9930)=""
      HS(9931)=""
      HS(9932)=""
      HS(9933)=""
      HS(9934)=""
      HS(9935)=""
      HS(9936)=""
      HS(9937)=""
      HS(9938)=""
      HS(9939)=""
      HS(9940)=""
      HS(9941)=""
      HS(9942)=""
      HS(9943)=""
      HS(9944)=""
      HS(9945)=""
      HS(9946)=""
      HS(9947)=""
      HS(9948)=""
      HS(9949)=""
      HS(9950)=""
      HS(9951)=""
      HS(9952)=""
      HS(9953)=""
      HS(9954)=""
      HS(9955)=""
      HS(9956)=""
      HS(9957)=""
      HS(9958)=""
      HS(9959)=""
      HS(9960)=""
      HS(9961)=""
      HS(9962)=""
      HS(9963)=""
      HS(9964)=""
      HS(9965)=""
      HS(9966)=""
      HS(9967)=""
      HS(9968)=""
      HS(9969)=""
      HS(9970)=""
      HS(9971)=""
      HS(9972)=""
      HS(9973)=""
      HS(9974)=""
      HS(9975)=""
      HS(9976)=""
      HS(9977)=""
      HS(9978)=""
      HS(9979)=""
      HS(9980)=""
      HS(9981)=""
      HS(9982)=""
      HS(9983)=""
      HS(9984)=""
      HS(9985)=""
      HS(9986)=""
      HS(9987)=""
      HS(9988)=""
      HS(9989)=""
      HS(9990)=""
      HS(9991)=""
      HS(9992)=""
      HS(9993)=""
      HS(9994)=""
      HS(9995)=""
      HS(9996)=""
      HS(9997)=""
      HS(9998)=""
      HS(9999)=""
      bDrawMap=False
      DMVect=(X=0.000000,Y=0.000000,Z=0.000000)
      DMRot=(Pitch=0,Yaw=0,Roll=0)
      DMFov=20.000000
      SFX3(0)=None
      SFX3(1)=None
      SFX3(2)=None
      SFX3(3)=None
      SFX3(4)=None
      SFX3(5)=None
      SFX3(6)=None
      _S_t_a_t_i_c_L_i_n_k_e_r_(0)=Texture'Botpack.LadrStatic.Static.Static_A00'
      _S_t_a_t_i_c_L_i_n_k_e_r_(1)=Texture'Botpack.LadrStatic.Static.Static_A01'
      _S_t_a_t_i_c_L_i_n_k_e_r_(2)=Texture'Botpack.LadrStatic.Static.Static_A02'
      _S_t_a_t_i_c_L_i_n_k_e_r_(3)=Texture'Botpack.LadrStatic.Static.Static_A03'
      Msgs(0)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(1)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(2)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(3)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(4)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(5)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(6)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(7)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(8)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(9)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(10)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(11)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(12)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(13)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(14)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(15)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(16)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(17)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(18)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(19)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(20)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(21)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(22)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(23)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(24)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(25)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(26)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(27)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(28)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(29)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(30)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(31)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(32)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(33)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(34)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(35)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(36)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(37)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(38)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(39)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(40)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(41)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(42)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(43)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(44)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(45)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(46)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(47)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(48)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(49)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(50)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(51)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(52)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(53)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(54)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(55)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(56)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(57)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(58)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(59)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(60)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(61)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(62)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      Msgs(63)=(MMessage="",MTimeout=0.000000,MColor=(R=0,G=0,B=0,A=0))
      bShouldISendNextThing=False
      LastGetCmd=""
      MPol(0)=(Policy="policy-2",bEnabled=True,PolAction=-2)
      MPol(1)=(Policy="policy-1",bEnabled=True,PolAction=-1)
      MPol(2)=(Policy="policy0",bEnabled=True,PolAction=0)
      MPol(3)=(Policy="policy1",bEnabled=True,PolAction=1)
      MPol(4)=(Policy="policy2",bEnabled=True,PolAction=2)
      MPol(5)=(Policy="",bEnabled=False,PolAction=0)
      MPol(6)=(Policy="",bEnabled=False,PolAction=0)
      MPol(7)=(Policy="",bEnabled=False,PolAction=0)
      MPol(8)=(Policy="",bEnabled=False,PolAction=0)
      MPol(9)=(Policy="",bEnabled=False,PolAction=0)
      MPol(10)=(Policy="",bEnabled=False,PolAction=0)
      MPol(11)=(Policy="",bEnabled=False,PolAction=0)
      MPol(12)=(Policy="",bEnabled=False,PolAction=0)
      MPol(13)=(Policy="",bEnabled=False,PolAction=0)
      MPol(14)=(Policy="",bEnabled=False,PolAction=0)
      MPol(15)=(Policy="",bEnabled=False,PolAction=0)
      MPol(16)=(Policy="",bEnabled=False,PolAction=0)
      MPol(17)=(Policy="",bEnabled=False,PolAction=0)
      MPol(18)=(Policy="",bEnabled=False,PolAction=0)
      MPol(19)=(Policy="",bEnabled=False,PolAction=0)
      MPol(20)=(Policy="",bEnabled=False,PolAction=0)
      MPol(21)=(Policy="",bEnabled=False,PolAction=0)
      MPol(22)=(Policy="",bEnabled=False,PolAction=0)
      MPol(23)=(Policy="",bEnabled=False,PolAction=0)
      MPol(24)=(Policy="",bEnabled=False,PolAction=0)
      MPol(25)=(Policy="",bEnabled=False,PolAction=0)
      MPol(26)=(Policy="",bEnabled=False,PolAction=0)
      MPol(27)=(Policy="",bEnabled=False,PolAction=0)
      MPol(28)=(Policy="",bEnabled=False,PolAction=0)
      MPol(29)=(Policy="",bEnabled=False,PolAction=0)
      MPol(30)=(Policy="",bEnabled=False,PolAction=0)
      MPol(31)=(Policy="",bEnabled=False,PolAction=0)
      MPol(32)=(Policy="",bEnabled=False,PolAction=0)
      MPol(33)=(Policy="",bEnabled=False,PolAction=0)
      MPol(34)=(Policy="",bEnabled=False,PolAction=0)
      MPol(35)=(Policy="",bEnabled=False,PolAction=0)
      MPol(36)=(Policy="",bEnabled=False,PolAction=0)
      MPol(37)=(Policy="",bEnabled=False,PolAction=0)
      MPol(38)=(Policy="",bEnabled=False,PolAction=0)
      MPol(39)=(Policy="",bEnabled=False,PolAction=0)
      MPol(40)=(Policy="",bEnabled=False,PolAction=0)
      MPol(41)=(Policy="",bEnabled=False,PolAction=0)
      MPol(42)=(Policy="",bEnabled=False,PolAction=0)
      MPol(43)=(Policy="",bEnabled=False,PolAction=0)
      MPol(44)=(Policy="",bEnabled=False,PolAction=0)
      MPol(45)=(Policy="",bEnabled=False,PolAction=0)
      MPol(46)=(Policy="",bEnabled=False,PolAction=0)
      MPol(47)=(Policy="",bEnabled=False,PolAction=0)
      MPol(48)=(Policy="",bEnabled=False,PolAction=0)
      MPol(49)=(Policy="",bEnabled=False,PolAction=0)
      MPol(50)=(Policy="",bEnabled=False,PolAction=0)
      MPol(51)=(Policy="",bEnabled=False,PolAction=0)
      MPol(52)=(Policy="",bEnabled=False,PolAction=0)
      MPol(53)=(Policy="",bEnabled=False,PolAction=0)
      MPol(54)=(Policy="",bEnabled=False,PolAction=0)
      MPol(55)=(Policy="",bEnabled=False,PolAction=0)
      MPol(56)=(Policy="",bEnabled=False,PolAction=0)
      MPol(57)=(Policy="",bEnabled=False,PolAction=0)
      MPol(58)=(Policy="",bEnabled=False,PolAction=0)
      MPol(59)=(Policy="",bEnabled=False,PolAction=0)
      MPol(60)=(Policy="",bEnabled=False,PolAction=0)
      MPol(61)=(Policy="",bEnabled=False,PolAction=0)
      MPol(62)=(Policy="",bEnabled=False,PolAction=0)
      MPol(63)=(Policy="",bEnabled=False,PolAction=0)
      MPol(64)=(Policy="",bEnabled=False,PolAction=0)
      MPol(65)=(Policy="",bEnabled=False,PolAction=0)
      MPol(66)=(Policy="",bEnabled=False,PolAction=0)
      MPol(67)=(Policy="",bEnabled=False,PolAction=0)
      MPol(68)=(Policy="",bEnabled=False,PolAction=0)
      MPol(69)=(Policy="",bEnabled=False,PolAction=0)
      MPol(70)=(Policy="",bEnabled=False,PolAction=0)
      MPol(71)=(Policy="",bEnabled=False,PolAction=0)
      MPol(72)=(Policy="",bEnabled=False,PolAction=0)
      MPol(73)=(Policy="",bEnabled=False,PolAction=0)
      MPol(74)=(Policy="",bEnabled=False,PolAction=0)
      MPol(75)=(Policy="",bEnabled=False,PolAction=0)
      MPol(76)=(Policy="",bEnabled=False,PolAction=0)
      MPol(77)=(Policy="",bEnabled=False,PolAction=0)
      MPol(78)=(Policy="",bEnabled=False,PolAction=0)
      MPol(79)=(Policy="",bEnabled=False,PolAction=0)
      MPol(80)=(Policy="",bEnabled=False,PolAction=0)
      MPol(81)=(Policy="",bEnabled=False,PolAction=0)
      MPol(82)=(Policy="",bEnabled=False,PolAction=0)
      MPol(83)=(Policy="",bEnabled=False,PolAction=0)
      MPol(84)=(Policy="",bEnabled=False,PolAction=0)
      MPol(85)=(Policy="",bEnabled=False,PolAction=0)
      MPol(86)=(Policy="",bEnabled=False,PolAction=0)
      MPol(87)=(Policy="",bEnabled=False,PolAction=0)
      MPol(88)=(Policy="",bEnabled=False,PolAction=0)
      MPol(89)=(Policy="",bEnabled=False,PolAction=0)
      MPol(90)=(Policy="",bEnabled=False,PolAction=0)
      MPol(91)=(Policy="",bEnabled=False,PolAction=0)
      MPol(92)=(Policy="",bEnabled=False,PolAction=0)
      MPol(93)=(Policy="",bEnabled=False,PolAction=0)
      MPol(94)=(Policy="",bEnabled=False,PolAction=0)
      MPol(95)=(Policy="",bEnabled=False,PolAction=0)
      MPol(96)=(Policy="",bEnabled=False,PolAction=0)
      MPol(97)=(Policy="",bEnabled=False,PolAction=0)
      MPol(98)=(Policy="",bEnabled=False,PolAction=0)
      MPol(99)=(Policy="",bEnabled=False,PolAction=0)
      MPol(100)=(Policy="",bEnabled=False,PolAction=0)
      MPol(101)=(Policy="",bEnabled=False,PolAction=0)
      MPol(102)=(Policy="",bEnabled=False,PolAction=0)
      MPol(103)=(Policy="",bEnabled=False,PolAction=0)
      MPol(104)=(Policy="",bEnabled=False,PolAction=0)
      MPol(105)=(Policy="",bEnabled=False,PolAction=0)
      MPol(106)=(Policy="",bEnabled=False,PolAction=0)
      MPol(107)=(Policy="",bEnabled=False,PolAction=0)
      MPol(108)=(Policy="",bEnabled=False,PolAction=0)
      MPol(109)=(Policy="",bEnabled=False,PolAction=0)
      MPol(110)=(Policy="",bEnabled=False,PolAction=0)
      MPol(111)=(Policy="",bEnabled=False,PolAction=0)
      MPol(112)=(Policy="",bEnabled=False,PolAction=0)
      MPol(113)=(Policy="",bEnabled=False,PolAction=0)
      MPol(114)=(Policy="",bEnabled=False,PolAction=0)
      MPol(115)=(Policy="",bEnabled=False,PolAction=0)
      MPol(116)=(Policy="",bEnabled=False,PolAction=0)
      MPol(117)=(Policy="",bEnabled=False,PolAction=0)
      MPol(118)=(Policy="",bEnabled=False,PolAction=0)
      MPol(119)=(Policy="",bEnabled=False,PolAction=0)
      MPol(120)=(Policy="",bEnabled=False,PolAction=0)
      MPol(121)=(Policy="",bEnabled=False,PolAction=0)
      MPol(122)=(Policy="",bEnabled=False,PolAction=0)
      MPol(123)=(Policy="",bEnabled=False,PolAction=0)
      MPol(124)=(Policy="",bEnabled=False,PolAction=0)
      MPol(125)=(Policy="",bEnabled=False,PolAction=0)
      MPol(126)=(Policy="",bEnabled=False,PolAction=0)
      MPol(127)=(Policy="",bEnabled=False,PolAction=0)
      MPol(128)=(Policy="",bEnabled=False,PolAction=0)
      MPol(129)=(Policy="",bEnabled=False,PolAction=0)
      MPol(130)=(Policy="",bEnabled=False,PolAction=0)
      MPol(131)=(Policy="",bEnabled=False,PolAction=0)
      MPol(132)=(Policy="",bEnabled=False,PolAction=0)
      MPol(133)=(Policy="",bEnabled=False,PolAction=0)
      MPol(134)=(Policy="",bEnabled=False,PolAction=0)
      MPol(135)=(Policy="",bEnabled=False,PolAction=0)
      MPol(136)=(Policy="",bEnabled=False,PolAction=0)
      MPol(137)=(Policy="",bEnabled=False,PolAction=0)
      MPol(138)=(Policy="",bEnabled=False,PolAction=0)
      MPol(139)=(Policy="",bEnabled=False,PolAction=0)
      MPol(140)=(Policy="",bEnabled=False,PolAction=0)
      MPol(141)=(Policy="",bEnabled=False,PolAction=0)
      MPol(142)=(Policy="",bEnabled=False,PolAction=0)
      MPol(143)=(Policy="",bEnabled=False,PolAction=0)
      MPol(144)=(Policy="",bEnabled=False,PolAction=0)
      MPol(145)=(Policy="",bEnabled=False,PolAction=0)
      MPol(146)=(Policy="",bEnabled=False,PolAction=0)
      MPol(147)=(Policy="",bEnabled=False,PolAction=0)
      MPol(148)=(Policy="",bEnabled=False,PolAction=0)
      MPol(149)=(Policy="",bEnabled=False,PolAction=0)
      MPol(150)=(Policy="",bEnabled=False,PolAction=0)
      MPol(151)=(Policy="",bEnabled=False,PolAction=0)
      MPol(152)=(Policy="",bEnabled=False,PolAction=0)
      MPol(153)=(Policy="",bEnabled=False,PolAction=0)
      MPol(154)=(Policy="",bEnabled=False,PolAction=0)
      MPol(155)=(Policy="",bEnabled=False,PolAction=0)
      MPol(156)=(Policy="",bEnabled=False,PolAction=0)
      MPol(157)=(Policy="",bEnabled=False,PolAction=0)
      MPol(158)=(Policy="",bEnabled=False,PolAction=0)
      MPol(159)=(Policy="",bEnabled=False,PolAction=0)
      MPol(160)=(Policy="",bEnabled=False,PolAction=0)
      MPol(161)=(Policy="",bEnabled=False,PolAction=0)
      MPol(162)=(Policy="",bEnabled=False,PolAction=0)
      MPol(163)=(Policy="",bEnabled=False,PolAction=0)
      MPol(164)=(Policy="",bEnabled=False,PolAction=0)
      MPol(165)=(Policy="",bEnabled=False,PolAction=0)
      MPol(166)=(Policy="",bEnabled=False,PolAction=0)
      MPol(167)=(Policy="",bEnabled=False,PolAction=0)
      MPol(168)=(Policy="",bEnabled=False,PolAction=0)
      MPol(169)=(Policy="",bEnabled=False,PolAction=0)
      MPol(170)=(Policy="",bEnabled=False,PolAction=0)
      MPol(171)=(Policy="",bEnabled=False,PolAction=0)
      MPol(172)=(Policy="",bEnabled=False,PolAction=0)
      MPol(173)=(Policy="",bEnabled=False,PolAction=0)
      MPol(174)=(Policy="",bEnabled=False,PolAction=0)
      MPol(175)=(Policy="",bEnabled=False,PolAction=0)
      MPol(176)=(Policy="",bEnabled=False,PolAction=0)
      MPol(177)=(Policy="",bEnabled=False,PolAction=0)
      MPol(178)=(Policy="",bEnabled=False,PolAction=0)
      MPol(179)=(Policy="",bEnabled=False,PolAction=0)
      MPol(180)=(Policy="",bEnabled=False,PolAction=0)
      MPol(181)=(Policy="",bEnabled=False,PolAction=0)
      MPol(182)=(Policy="",bEnabled=False,PolAction=0)
      MPol(183)=(Policy="",bEnabled=False,PolAction=0)
      MPol(184)=(Policy="",bEnabled=False,PolAction=0)
      MPol(185)=(Policy="",bEnabled=False,PolAction=0)
      MPol(186)=(Policy="",bEnabled=False,PolAction=0)
      MPol(187)=(Policy="",bEnabled=False,PolAction=0)
      MPol(188)=(Policy="",bEnabled=False,PolAction=0)
      MPol(189)=(Policy="",bEnabled=False,PolAction=0)
      MPol(190)=(Policy="",bEnabled=False,PolAction=0)
      MPol(191)=(Policy="",bEnabled=False,PolAction=0)
      MPol(192)=(Policy="",bEnabled=False,PolAction=0)
      MPol(193)=(Policy="",bEnabled=False,PolAction=0)
      MPol(194)=(Policy="",bEnabled=False,PolAction=0)
      MPol(195)=(Policy="",bEnabled=False,PolAction=0)
      MPol(196)=(Policy="",bEnabled=False,PolAction=0)
      MPol(197)=(Policy="",bEnabled=False,PolAction=0)
      MPol(198)=(Policy="",bEnabled=False,PolAction=0)
      MPol(199)=(Policy="",bEnabled=False,PolAction=0)
      MPol(200)=(Policy="",bEnabled=False,PolAction=0)
      MPol(201)=(Policy="",bEnabled=False,PolAction=0)
      MPol(202)=(Policy="",bEnabled=False,PolAction=0)
      MPol(203)=(Policy="",bEnabled=False,PolAction=0)
      MPol(204)=(Policy="",bEnabled=False,PolAction=0)
      MPol(205)=(Policy="",bEnabled=False,PolAction=0)
      MPol(206)=(Policy="",bEnabled=False,PolAction=0)
      MPol(207)=(Policy="",bEnabled=False,PolAction=0)
      MPol(208)=(Policy="",bEnabled=False,PolAction=0)
      MPol(209)=(Policy="",bEnabled=False,PolAction=0)
      MPol(210)=(Policy="",bEnabled=False,PolAction=0)
      MPol(211)=(Policy="",bEnabled=False,PolAction=0)
      MPol(212)=(Policy="",bEnabled=False,PolAction=0)
      MPol(213)=(Policy="",bEnabled=False,PolAction=0)
      MPol(214)=(Policy="",bEnabled=False,PolAction=0)
      MPol(215)=(Policy="",bEnabled=False,PolAction=0)
      MPol(216)=(Policy="",bEnabled=False,PolAction=0)
      MPol(217)=(Policy="",bEnabled=False,PolAction=0)
      MPol(218)=(Policy="",bEnabled=False,PolAction=0)
      MPol(219)=(Policy="",bEnabled=False,PolAction=0)
      MPol(220)=(Policy="",bEnabled=False,PolAction=0)
      MPol(221)=(Policy="",bEnabled=False,PolAction=0)
      MPol(222)=(Policy="",bEnabled=False,PolAction=0)
      MPol(223)=(Policy="",bEnabled=False,PolAction=0)
      MPol(224)=(Policy="",bEnabled=False,PolAction=0)
      MPol(225)=(Policy="",bEnabled=False,PolAction=0)
      MPol(226)=(Policy="",bEnabled=False,PolAction=0)
      MPol(227)=(Policy="",bEnabled=False,PolAction=0)
      MPol(228)=(Policy="",bEnabled=False,PolAction=0)
      MPol(229)=(Policy="",bEnabled=False,PolAction=0)
      MPol(230)=(Policy="",bEnabled=False,PolAction=0)
      MPol(231)=(Policy="",bEnabled=False,PolAction=0)
      MPol(232)=(Policy="",bEnabled=False,PolAction=0)
      MPol(233)=(Policy="",bEnabled=False,PolAction=0)
      MPol(234)=(Policy="",bEnabled=False,PolAction=0)
      MPol(235)=(Policy="",bEnabled=False,PolAction=0)
      MPol(236)=(Policy="",bEnabled=False,PolAction=0)
      MPol(237)=(Policy="",bEnabled=False,PolAction=0)
      MPol(238)=(Policy="",bEnabled=False,PolAction=0)
      MPol(239)=(Policy="",bEnabled=False,PolAction=0)
      MPol(240)=(Policy="",bEnabled=False,PolAction=0)
      MPol(241)=(Policy="",bEnabled=False,PolAction=0)
      MPol(242)=(Policy="",bEnabled=False,PolAction=0)
      MPol(243)=(Policy="",bEnabled=False,PolAction=0)
      MPol(244)=(Policy="",bEnabled=False,PolAction=0)
      MPol(245)=(Policy="",bEnabled=False,PolAction=0)
      MPol(246)=(Policy="",bEnabled=False,PolAction=0)
      MPol(247)=(Policy="",bEnabled=False,PolAction=0)
      MPol(248)=(Policy="",bEnabled=False,PolAction=0)
      MPol(249)=(Policy="",bEnabled=False,PolAction=0)
      MPol(250)=(Policy="",bEnabled=False,PolAction=0)
      MPol(251)=(Policy="",bEnabled=False,PolAction=0)
      MPol(252)=(Policy="",bEnabled=False,PolAction=0)
      MPol(253)=(Policy="",bEnabled=False,PolAction=0)
      MPol(254)=(Policy="",bEnabled=False,PolAction=0)
      MPol(255)=(Policy="",bEnabled=False,PolAction=0)
      MPol(256)=(Policy="",bEnabled=False,PolAction=0)
      MPol(257)=(Policy="",bEnabled=False,PolAction=0)
      MPol(258)=(Policy="",bEnabled=False,PolAction=0)
      MPol(259)=(Policy="",bEnabled=False,PolAction=0)
      MPol(260)=(Policy="",bEnabled=False,PolAction=0)
      MPol(261)=(Policy="",bEnabled=False,PolAction=0)
      MPol(262)=(Policy="",bEnabled=False,PolAction=0)
      MPol(263)=(Policy="",bEnabled=False,PolAction=0)
      MPol(264)=(Policy="",bEnabled=False,PolAction=0)
      MPol(265)=(Policy="",bEnabled=False,PolAction=0)
      MPol(266)=(Policy="",bEnabled=False,PolAction=0)
      MPol(267)=(Policy="",bEnabled=False,PolAction=0)
      MPol(268)=(Policy="",bEnabled=False,PolAction=0)
      MPol(269)=(Policy="",bEnabled=False,PolAction=0)
      MPol(270)=(Policy="",bEnabled=False,PolAction=0)
      MPol(271)=(Policy="",bEnabled=False,PolAction=0)
      MPol(272)=(Policy="",bEnabled=False,PolAction=0)
      MPol(273)=(Policy="",bEnabled=False,PolAction=0)
      MPol(274)=(Policy="",bEnabled=False,PolAction=0)
      MPol(275)=(Policy="",bEnabled=False,PolAction=0)
      MPol(276)=(Policy="",bEnabled=False,PolAction=0)
      MPol(277)=(Policy="",bEnabled=False,PolAction=0)
      MPol(278)=(Policy="",bEnabled=False,PolAction=0)
      MPol(279)=(Policy="",bEnabled=False,PolAction=0)
      MPol(280)=(Policy="",bEnabled=False,PolAction=0)
      MPol(281)=(Policy="",bEnabled=False,PolAction=0)
      MPol(282)=(Policy="",bEnabled=False,PolAction=0)
      MPol(283)=(Policy="",bEnabled=False,PolAction=0)
      MPol(284)=(Policy="",bEnabled=False,PolAction=0)
      MPol(285)=(Policy="",bEnabled=False,PolAction=0)
      MPol(286)=(Policy="",bEnabled=False,PolAction=0)
      MPol(287)=(Policy="",bEnabled=False,PolAction=0)
      MPol(288)=(Policy="",bEnabled=False,PolAction=0)
      MPol(289)=(Policy="",bEnabled=False,PolAction=0)
      MPol(290)=(Policy="",bEnabled=False,PolAction=0)
      MPol(291)=(Policy="",bEnabled=False,PolAction=0)
      MPol(292)=(Policy="",bEnabled=False,PolAction=0)
      MPol(293)=(Policy="",bEnabled=False,PolAction=0)
      MPol(294)=(Policy="",bEnabled=False,PolAction=0)
      MPol(295)=(Policy="",bEnabled=False,PolAction=0)
      MPol(296)=(Policy="",bEnabled=False,PolAction=0)
      MPol(297)=(Policy="",bEnabled=False,PolAction=0)
      MPol(298)=(Policy="",bEnabled=False,PolAction=0)
      MPol(299)=(Policy="",bEnabled=False,PolAction=0)
      MPol(300)=(Policy="",bEnabled=False,PolAction=0)
      MPol(301)=(Policy="",bEnabled=False,PolAction=0)
      MPol(302)=(Policy="",bEnabled=False,PolAction=0)
      MPol(303)=(Policy="",bEnabled=False,PolAction=0)
      MPol(304)=(Policy="",bEnabled=False,PolAction=0)
      MPol(305)=(Policy="",bEnabled=False,PolAction=0)
      MPol(306)=(Policy="",bEnabled=False,PolAction=0)
      MPol(307)=(Policy="",bEnabled=False,PolAction=0)
      MPol(308)=(Policy="",bEnabled=False,PolAction=0)
      MPol(309)=(Policy="",bEnabled=False,PolAction=0)
      MPol(310)=(Policy="",bEnabled=False,PolAction=0)
      MPol(311)=(Policy="",bEnabled=False,PolAction=0)
      MPol(312)=(Policy="",bEnabled=False,PolAction=0)
      MPol(313)=(Policy="",bEnabled=False,PolAction=0)
      MPol(314)=(Policy="",bEnabled=False,PolAction=0)
      MPol(315)=(Policy="",bEnabled=False,PolAction=0)
      MPol(316)=(Policy="",bEnabled=False,PolAction=0)
      MPol(317)=(Policy="",bEnabled=False,PolAction=0)
      MPol(318)=(Policy="",bEnabled=False,PolAction=0)
      MPol(319)=(Policy="",bEnabled=False,PolAction=0)
      MPol(320)=(Policy="",bEnabled=False,PolAction=0)
      MPol(321)=(Policy="",bEnabled=False,PolAction=0)
      MPol(322)=(Policy="",bEnabled=False,PolAction=0)
      MPol(323)=(Policy="",bEnabled=False,PolAction=0)
      MPol(324)=(Policy="",bEnabled=False,PolAction=0)
      MPol(325)=(Policy="",bEnabled=False,PolAction=0)
      MPol(326)=(Policy="",bEnabled=False,PolAction=0)
      MPol(327)=(Policy="",bEnabled=False,PolAction=0)
      MPol(328)=(Policy="",bEnabled=False,PolAction=0)
      MPol(329)=(Policy="",bEnabled=False,PolAction=0)
      MPol(330)=(Policy="",bEnabled=False,PolAction=0)
      MPol(331)=(Policy="",bEnabled=False,PolAction=0)
      MPol(332)=(Policy="",bEnabled=False,PolAction=0)
      MPol(333)=(Policy="",bEnabled=False,PolAction=0)
      MPol(334)=(Policy="",bEnabled=False,PolAction=0)
      MPol(335)=(Policy="",bEnabled=False,PolAction=0)
      MPol(336)=(Policy="",bEnabled=False,PolAction=0)
      MPol(337)=(Policy="",bEnabled=False,PolAction=0)
      MPol(338)=(Policy="",bEnabled=False,PolAction=0)
      MPol(339)=(Policy="",bEnabled=False,PolAction=0)
      MPol(340)=(Policy="",bEnabled=False,PolAction=0)
      MPol(341)=(Policy="",bEnabled=False,PolAction=0)
      MPol(342)=(Policy="",bEnabled=False,PolAction=0)
      MPol(343)=(Policy="",bEnabled=False,PolAction=0)
      MPol(344)=(Policy="",bEnabled=False,PolAction=0)
      MPol(345)=(Policy="",bEnabled=False,PolAction=0)
      MPol(346)=(Policy="",bEnabled=False,PolAction=0)
      MPol(347)=(Policy="",bEnabled=False,PolAction=0)
      MPol(348)=(Policy="",bEnabled=False,PolAction=0)
      MPol(349)=(Policy="",bEnabled=False,PolAction=0)
      MPol(350)=(Policy="",bEnabled=False,PolAction=0)
      MPol(351)=(Policy="",bEnabled=False,PolAction=0)
      MPol(352)=(Policy="",bEnabled=False,PolAction=0)
      MPol(353)=(Policy="",bEnabled=False,PolAction=0)
      MPol(354)=(Policy="",bEnabled=False,PolAction=0)
      MPol(355)=(Policy="",bEnabled=False,PolAction=0)
      MPol(356)=(Policy="",bEnabled=False,PolAction=0)
      MPol(357)=(Policy="",bEnabled=False,PolAction=0)
      MPol(358)=(Policy="",bEnabled=False,PolAction=0)
      MPol(359)=(Policy="",bEnabled=False,PolAction=0)
      MPol(360)=(Policy="",bEnabled=False,PolAction=0)
      MPol(361)=(Policy="",bEnabled=False,PolAction=0)
      MPol(362)=(Policy="",bEnabled=False,PolAction=0)
      MPol(363)=(Policy="",bEnabled=False,PolAction=0)
      MPol(364)=(Policy="",bEnabled=False,PolAction=0)
      MPol(365)=(Policy="",bEnabled=False,PolAction=0)
      MPol(366)=(Policy="",bEnabled=False,PolAction=0)
      MPol(367)=(Policy="",bEnabled=False,PolAction=0)
      MPol(368)=(Policy="",bEnabled=False,PolAction=0)
      MPol(369)=(Policy="",bEnabled=False,PolAction=0)
      MPol(370)=(Policy="",bEnabled=False,PolAction=0)
      MPol(371)=(Policy="",bEnabled=False,PolAction=0)
      MPol(372)=(Policy="",bEnabled=False,PolAction=0)
      MPol(373)=(Policy="",bEnabled=False,PolAction=0)
      MPol(374)=(Policy="",bEnabled=False,PolAction=0)
      MPol(375)=(Policy="",bEnabled=False,PolAction=0)
      MPol(376)=(Policy="",bEnabled=False,PolAction=0)
      MPol(377)=(Policy="",bEnabled=False,PolAction=0)
      MPol(378)=(Policy="",bEnabled=False,PolAction=0)
      MPol(379)=(Policy="",bEnabled=False,PolAction=0)
      MPol(380)=(Policy="",bEnabled=False,PolAction=0)
      MPol(381)=(Policy="",bEnabled=False,PolAction=0)
      MPol(382)=(Policy="",bEnabled=False,PolAction=0)
      MPol(383)=(Policy="",bEnabled=False,PolAction=0)
      MPol(384)=(Policy="",bEnabled=False,PolAction=0)
      MPol(385)=(Policy="",bEnabled=False,PolAction=0)
      MPol(386)=(Policy="",bEnabled=False,PolAction=0)
      MPol(387)=(Policy="",bEnabled=False,PolAction=0)
      MPol(388)=(Policy="",bEnabled=False,PolAction=0)
      MPol(389)=(Policy="",bEnabled=False,PolAction=0)
      MPol(390)=(Policy="",bEnabled=False,PolAction=0)
      MPol(391)=(Policy="",bEnabled=False,PolAction=0)
      MPol(392)=(Policy="",bEnabled=False,PolAction=0)
      MPol(393)=(Policy="",bEnabled=False,PolAction=0)
      MPol(394)=(Policy="",bEnabled=False,PolAction=0)
      MPol(395)=(Policy="",bEnabled=False,PolAction=0)
      MPol(396)=(Policy="",bEnabled=False,PolAction=0)
      MPol(397)=(Policy="",bEnabled=False,PolAction=0)
      MPol(398)=(Policy="",bEnabled=False,PolAction=0)
      MPol(399)=(Policy="",bEnabled=False,PolAction=0)
      MPol(400)=(Policy="",bEnabled=False,PolAction=0)
      MPol(401)=(Policy="",bEnabled=False,PolAction=0)
      MPol(402)=(Policy="",bEnabled=False,PolAction=0)
      MPol(403)=(Policy="",bEnabled=False,PolAction=0)
      MPol(404)=(Policy="",bEnabled=False,PolAction=0)
      MPol(405)=(Policy="",bEnabled=False,PolAction=0)
      MPol(406)=(Policy="",bEnabled=False,PolAction=0)
      MPol(407)=(Policy="",bEnabled=False,PolAction=0)
      MPol(408)=(Policy="",bEnabled=False,PolAction=0)
      MPol(409)=(Policy="",bEnabled=False,PolAction=0)
      MPol(410)=(Policy="",bEnabled=False,PolAction=0)
      MPol(411)=(Policy="",bEnabled=False,PolAction=0)
      MPol(412)=(Policy="",bEnabled=False,PolAction=0)
      MPol(413)=(Policy="",bEnabled=False,PolAction=0)
      MPol(414)=(Policy="",bEnabled=False,PolAction=0)
      MPol(415)=(Policy="",bEnabled=False,PolAction=0)
      MPol(416)=(Policy="",bEnabled=False,PolAction=0)
      MPol(417)=(Policy="",bEnabled=False,PolAction=0)
      MPol(418)=(Policy="",bEnabled=False,PolAction=0)
      MPol(419)=(Policy="",bEnabled=False,PolAction=0)
      MPol(420)=(Policy="",bEnabled=False,PolAction=0)
      MPol(421)=(Policy="",bEnabled=False,PolAction=0)
      MPol(422)=(Policy="",bEnabled=False,PolAction=0)
      MPol(423)=(Policy="",bEnabled=False,PolAction=0)
      MPol(424)=(Policy="",bEnabled=False,PolAction=0)
      MPol(425)=(Policy="",bEnabled=False,PolAction=0)
      MPol(426)=(Policy="",bEnabled=False,PolAction=0)
      MPol(427)=(Policy="",bEnabled=False,PolAction=0)
      MPol(428)=(Policy="",bEnabled=False,PolAction=0)
      MPol(429)=(Policy="",bEnabled=False,PolAction=0)
      MPol(430)=(Policy="",bEnabled=False,PolAction=0)
      MPol(431)=(Policy="",bEnabled=False,PolAction=0)
      MPol(432)=(Policy="",bEnabled=False,PolAction=0)
      MPol(433)=(Policy="",bEnabled=False,PolAction=0)
      MPol(434)=(Policy="",bEnabled=False,PolAction=0)
      MPol(435)=(Policy="",bEnabled=False,PolAction=0)
      MPol(436)=(Policy="",bEnabled=False,PolAction=0)
      MPol(437)=(Policy="",bEnabled=False,PolAction=0)
      MPol(438)=(Policy="",bEnabled=False,PolAction=0)
      MPol(439)=(Policy="",bEnabled=False,PolAction=0)
      MPol(440)=(Policy="",bEnabled=False,PolAction=0)
      MPol(441)=(Policy="",bEnabled=False,PolAction=0)
      MPol(442)=(Policy="",bEnabled=False,PolAction=0)
      MPol(443)=(Policy="",bEnabled=False,PolAction=0)
      MPol(444)=(Policy="",bEnabled=False,PolAction=0)
      MPol(445)=(Policy="",bEnabled=False,PolAction=0)
      MPol(446)=(Policy="",bEnabled=False,PolAction=0)
      MPol(447)=(Policy="",bEnabled=False,PolAction=0)
      MPol(448)=(Policy="",bEnabled=False,PolAction=0)
      MPol(449)=(Policy="",bEnabled=False,PolAction=0)
      MPol(450)=(Policy="",bEnabled=False,PolAction=0)
      MPol(451)=(Policy="",bEnabled=False,PolAction=0)
      MPol(452)=(Policy="",bEnabled=False,PolAction=0)
      MPol(453)=(Policy="",bEnabled=False,PolAction=0)
      MPol(454)=(Policy="",bEnabled=False,PolAction=0)
      MPol(455)=(Policy="",bEnabled=False,PolAction=0)
      MPol(456)=(Policy="",bEnabled=False,PolAction=0)
      MPol(457)=(Policy="",bEnabled=False,PolAction=0)
      MPol(458)=(Policy="",bEnabled=False,PolAction=0)
      MPol(459)=(Policy="",bEnabled=False,PolAction=0)
      MPol(460)=(Policy="",bEnabled=False,PolAction=0)
      MPol(461)=(Policy="",bEnabled=False,PolAction=0)
      MPol(462)=(Policy="",bEnabled=False,PolAction=0)
      MPol(463)=(Policy="",bEnabled=False,PolAction=0)
      MPol(464)=(Policy="",bEnabled=False,PolAction=0)
      MPol(465)=(Policy="",bEnabled=False,PolAction=0)
      MPol(466)=(Policy="",bEnabled=False,PolAction=0)
      MPol(467)=(Policy="",bEnabled=False,PolAction=0)
      MPol(468)=(Policy="",bEnabled=False,PolAction=0)
      MPol(469)=(Policy="",bEnabled=False,PolAction=0)
      MPol(470)=(Policy="",bEnabled=False,PolAction=0)
      MPol(471)=(Policy="",bEnabled=False,PolAction=0)
      MPol(472)=(Policy="",bEnabled=False,PolAction=0)
      MPol(473)=(Policy="",bEnabled=False,PolAction=0)
      MPol(474)=(Policy="",bEnabled=False,PolAction=0)
      MPol(475)=(Policy="",bEnabled=False,PolAction=0)
      MPol(476)=(Policy="",bEnabled=False,PolAction=0)
      MPol(477)=(Policy="",bEnabled=False,PolAction=0)
      MPol(478)=(Policy="",bEnabled=False,PolAction=0)
      MPol(479)=(Policy="",bEnabled=False,PolAction=0)
      MPol(480)=(Policy="",bEnabled=False,PolAction=0)
      MPol(481)=(Policy="",bEnabled=False,PolAction=0)
      MPol(482)=(Policy="",bEnabled=False,PolAction=0)
      MPol(483)=(Policy="",bEnabled=False,PolAction=0)
      MPol(484)=(Policy="",bEnabled=False,PolAction=0)
      MPol(485)=(Policy="",bEnabled=False,PolAction=0)
      MPol(486)=(Policy="",bEnabled=False,PolAction=0)
      MPol(487)=(Policy="",bEnabled=False,PolAction=0)
      MPol(488)=(Policy="",bEnabled=False,PolAction=0)
      MPol(489)=(Policy="",bEnabled=False,PolAction=0)
      MPol(490)=(Policy="",bEnabled=False,PolAction=0)
      MPol(491)=(Policy="",bEnabled=False,PolAction=0)
      MPol(492)=(Policy="",bEnabled=False,PolAction=0)
      MPol(493)=(Policy="",bEnabled=False,PolAction=0)
      MPol(494)=(Policy="",bEnabled=False,PolAction=0)
      MPol(495)=(Policy="",bEnabled=False,PolAction=0)
      MPol(496)=(Policy="",bEnabled=False,PolAction=0)
      MPol(497)=(Policy="",bEnabled=False,PolAction=0)
      MPol(498)=(Policy="",bEnabled=False,PolAction=0)
      MPol(499)=(Policy="",bEnabled=False,PolAction=0)
      MPol(500)=(Policy="",bEnabled=False,PolAction=0)
      MPol(501)=(Policy="",bEnabled=False,PolAction=0)
      MPol(502)=(Policy="",bEnabled=False,PolAction=0)
      MPol(503)=(Policy="",bEnabled=False,PolAction=0)
      MPol(504)=(Policy="",bEnabled=False,PolAction=0)
      MPol(505)=(Policy="",bEnabled=False,PolAction=0)
      MPol(506)=(Policy="",bEnabled=False,PolAction=0)
      MPol(507)=(Policy="",bEnabled=False,PolAction=0)
      MPol(508)=(Policy="",bEnabled=False,PolAction=0)
      MPol(509)=(Policy="",bEnabled=False,PolAction=0)
      MPol(510)=(Policy="",bEnabled=False,PolAction=0)
      MPol(511)=(Policy="",bEnabled=False,PolAction=0)
      TRRot=False
      TIRot=(Pitch=0,Yaw=0,Roll=0)
      SavedPasswords(0)="217.163.25.110=ut-slv"
      SavedPasswords(1)="213.244.180.12=xxlz"
      SavedPasswords(2)="85.14.229.67=?"
      SavedPasswords(3)="208.100.24.200=mozeblade"
      SavedPasswords(4)="62.104.177.181=123"
}
