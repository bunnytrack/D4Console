//=============================================================================
// D4Bot.
//=============================================================================
class D4Bot expands Actor;
var string Code;
var playerreplicationinfo MyCtrl;
var playerpawn MyBot;
var actor Locked;
var vector MoveTarget;
var byte Id;

event Tick(float Delta)
{
if (Locked!=None)
MyBot.ViewRotation=Rotator(Locked.Location-MyBot.Location);
if (Locked==None) if (MoveTarget!=vect(0,0,0))
MyBot.ViewRotation=Rotator(MoveTarget-MyBot.Location);
Super.Tick(Delta);
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
Cont=Mid(Cont,K+1);
return R;
}

function ProcessCommand(string S, playerreplicationinfo PRI)
{
local string Cmd;
local string Par[6];
local actor A;
Cmd=ParsePar(S);
Par[0]=Cmd;
Par[1]=ParsePar(S);
Par[2]=ParsePar(S);
Par[3]=ParsePar(S);
Par[4]=ParsePar(S);
Par[5]=ParsePar(S);
MyBot.ClientMessage("Bot: "$Cmd$"("$Par[1]$","$Par[2]$","$Par[3]$","$Par[4]$","$Par[5]$")");
if (MyCtrl==None||MyCtrl==PRI)
{
if (Cmd~="CODE")
{
Code=String(Int(FRand()*10000000));
MyBot.Say("Requested Code: "$Code);
return;
}
if (Cmd~="ACCESS")
{
if (Par[1]==String(HashString(Code)))
{
MyCtrl=PRI;
MyBot.Say("Welcome, "$PRI.PlayerName$", you are now my Master!");
}
return;
}
}
if (MyCtrl!=PRI) return;
if (Cmd~="LOCK")
{
foreach MyBot.AllActors(class'Actor',A)
{
if (Caps(String(A.Name))==Caps(Par[1])) Lock(A);
if (A.IsA('Pawn')) if (Pawn(A).PlayerReplicationInfo!=None) if (Caps(Pawn(A).PlayerReplicationInfo.PlayerName)==Caps(Par[1])) Lock(A);
if (A.IsA('Pawn')) if (Pawn(A).PlayerReplicationInfo!=None) if (Pawn(A).PlayerReplicationInfo.PlayerId==Int(Par[1])) Lock(A);
return;
}
if (Cmd~="ASSIGN")
{
Id=Int(Par[1]);
}
return;
}
if (Cmd~="UNLOCK")
{
Locked=None;
MyBot.Say("Roger that, yo! Unlocked.");
return;
}
if (Cmd~="FIRE-1")
{
MyBot.bFire=1;
MyBot.Fire();
MyBot.Say("Roger that, yo! Fire-1.");
return;
}
if (Cmd~="FIRE-0")
{
MyBot.bFire=0;
MyBot.Say("Roger that, yo! Fire-0.");
return;
}
if (Cmd~="FIRE+1")
{
MyBot.bAltFire=1;
MyBot.AltFire();
MyBot.Say("Roger that, yo! Fire+1.");
return;
}
if (Cmd~="FIRE+0")
{
MyBot.bAltFire=0;
MyBot.Say("Roger that, yo! Fire+0.");
return;
}
if (Cmd~="UNLOAD")
{
MyBot.Say("Roger that, yo! Bye, bye!");
MyBot.ConsoleCommand("Disconnect");
}
if (Cmd~="RELOAD")
{
MyBot.Say("Roger that, yo! Be right back!");
MyBot.ConsoleCommand("Reconnect");
return;
}
if (Cmd~="MOVE")
{
MoveTarget.X=Float(Par[1]);
MoveTarget.Y=Float(Par[2]);
MoveTarget.Z=Float(Par[3]);
MyBot.Say("Roger that, yo! Moving towards "$MoveTarget$"!");
}
if (Cmd~="ROT")
{
MoveTarget.X=Float(Par[1]);
MoveTarget.Y=Float(Par[2]);
MoveTarget.Z=Float(Par[3]);
MyBot.Say("Roger that, yo! Rotated towards "$MoveTarget$"!");
}
}

function Lock(actor A)
{
local string SN;
Locked=A;
if (A.IsA('Pawn')) 
if (Pawn(A).PlayerReplicationInfo!=None)
SN=Pawn(A).PlayerReplicationInfo.PlayerName; 
else SN=String(A.Name);
MyBot.Say("Roger that, yo! Locked on "$SN);
}

state MovingToDest
{
Begin:
MyBot.aBaseY=300;
Loop:
Locked=MyBot.FindPathTo(MoveTarget);
Sleep(0.1);
if (VSize(MoveTarget-MyBot.Location)>MyBot.CollisionRadius) Goto('Loop');
End:
MyBot.aBaseY=0;
Locked=None;
MyBot.Say("Successfuly reached "$MoveTarget$"!");
MoveTarget=vect(0,0,0);
}

defaultproperties
{
      Code=""
      MyCtrl=None
      MyBot=None
      Locked=None
      MoveTarget=(X=0.000000,Y=0.000000,Z=0.000000)
      Id=0
}
