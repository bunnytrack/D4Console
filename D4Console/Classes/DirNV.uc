//=============================================================================
// Directed Night Vision light.
//=============================================================================
class DirNV expands FlashLightBeam;
var D4Console MyC;

event Tick(float Delta)
{
if (Owner!=None)
if (PlayerPawn(Owner)!=None)
if (PlayerPawn(Owner).Player!=None)
if (PlayerPawn(Owner).Player.Console!=None)
if (D4Console(PlayerPawn(Owner).Player.Console)!=None)
MyC=D4Console(PlayerPawn(Owner).Player.Console);
if (Owner==None) Destroy();
if (Owner==None) Return;
SetLocation(Owner.Location);
SetRotation(Owner.Rotation);
if (!Owner.IsA('PlayerPawn')) return;
SetRotation(PlayerPawn(Owner).ViewRotation);
if (MyC==None) return;
bSpecialLit=MyC.NVSL;
}

defaultproperties
{
      MyC=None
      LightBrightness=200
      LightRadius=255
}
