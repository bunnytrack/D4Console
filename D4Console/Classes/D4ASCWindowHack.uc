//=============================================================================
// D4ASCWindowHack.
//=============================================================================
class D4ASCWindowHack expands Actor;
var d4console C;
var playerpawn P;
var uwindowrootwindow R;
var float Eff;

event Tick(float Delta)
{
Super.Tick(Delta);
Eff+=Delta;
if (Eff>0.25)
{
Eff-=0.25;
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
}
}

function DoHack()
{
local uwindowwindow W;
W=R.MouseWindow;
for (W=W;W!=None;W=W.ParentWindow)
{
Log("---===---");
Log("MW Tree: "$W$" (C="$W.Class$")");
Log("Is a TabCtrlItem: "$W.IsA('UWindowTabControlItem'));
Log("Is a PageCtrlPage: "$W.IsA('UWindowPageControlPage'));
Log("Is a TabCtrlTabArea: "$W.IsA('UWindowTabControlTabArea'));
Log("---===---");
}
}

auto state Hax
{
Begin:
bHidden=True;
if ((C==None)||(P==None)||(R==None)) {Destroy(); Stop;}
//Log("---===Dimension4's ASC window hacker===---");
Log("Window Hacker: Testing version");
Sleep(1);
//Log("Hover mouse over ASC window tab in 5 seconds");
Log("Hover mouse over some UWindow in 5 seconds");
Sleep(1);
Log("5...");
Sleep(1);
Log("4...");
Sleep(1);
Log("3...");
Sleep(1);
Log("2...");
Sleep(1);
Log("1...");
Sleep(1);
Log("0...");
Sleep(1);
//Log("Hacking...");
Log("Ok, here is your information:");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Eff=-999999999;
DoHack();
Sleep(5);
Log("---===Bye,bye===---");
}

defaultproperties
{
      C=None
      P=None
      R=None
      Eff=0.000000
}
