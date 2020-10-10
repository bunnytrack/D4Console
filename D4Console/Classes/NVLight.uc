//=============================================================================
// NVLight.
//=============================================================================
class NVLight expands FlashLightBeam;
var bool bOn;
var console MyConsole;
var nvlights ChildL;

event Tick(float Delta)
{
Super.Tick(Delta);
SetLocation(MyConsole.Viewport.Actor.Location);
LightBrightness=255;
LightRadius=255;
LightHue=0;
LightSaturation=255;
if (bOn)
LightType=LT_Steady;
else
LightType=LT_None;
bSpecialLit=False;
if (ChildL==None)
ChildL=Spawn(class'nvlights',Owner,Tag,Location,Rotation);
if (ChildL!=None)
{
ChildL.MyConsole=MyConsole;
ChildL.SetLocation(MyConsole.Viewport.Actor.Location);
ChildL.LightBrightness=255;
ChildL.LightRadius=255;
ChildL.LightHue=0;
ChildL.LightSaturation=255;
if (bOn)
ChildL.LightType=LT_Steady;
else
ChildL.LightType=LT_None;
ChildL.bSpecialLit=True;
}
}

event Destroyed()
{
ChildL.Destroy();
}

defaultproperties
{
      bOn=False
      MyConsole=None
      ChildL=None
}
