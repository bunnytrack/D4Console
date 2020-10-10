//=============================================================================
// D4WindowDumper.
//=============================================================================
class D4WindowDumper expands Actor;
var d4console C;
var playerpawn P;
var uwindowrootwindow R;

function DumpAll()
{
Log("---===Window Dump===---===Window Dump===---");
Log("Focus: "$R.FocusedWindow$" @ "$R.FocusedWindow.Class);
Log("Hover: "$R.MouseWindow$" @ "$R.MouseWindow.Class);
Log("---===Window Dump===---===Window Dump===---");
}

auto state Dump
{
Begin:
if ((C==None)||(P==None)||(R==None)) {Destroy(); Stop;}
SetLocation(P.Location);
Texture=texture's_corpse';
C.CMsg("Window dumper initiated.");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("10");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("9");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("8");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("7");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("6");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("5");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("4");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("3");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("2");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.FTS("1");
Spawn(class'UT_ComboRing',Self,'',Location,Rotator(VRand()));
Sleep(1);
C.CMsg("Window dumper ACTIVATED.");
DumpAll();
Sleep(5);
C.EMsg("Window dumper DESTROYED.");
Destroy();
}

defaultproperties
{
      C=None
      P=None
      R=None
}
