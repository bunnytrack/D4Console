//=============================================================================
// D4Helper.
// That stuff can be saved into D4Console.ini file.
//=============================================================================
class D4Helper expands Actor;
var(Radar) bool bDrawOnRadar;
var(Radar) bool bDrawOn2DRadar;
var(Radar) bool bSimple2DRadar;
var(Radar) bool bDrawOn3DRadar;
var(Radar) bool bSimple3DRadar;
var(Radar) color RadarColor;
var int UId;

function R2DDraw(canvas C, int X, int Y);
function R3DDraw(canvas C, int X, int Y);

function RenderMe2D(canvas C, int X, int Y)
{
_I2DDraw(C,X,Y);
}

function RenderMe3D(canvas C, int X, int Y)
{
_I3DDraw(C,X,Y);
}

function _I2DDraw(canvas C, int X, int Y)
{
if (bSimple2DRadar)
{
C.DrawColor=RadarColor;
C.SetPos(X-1,Y-1);
C.DrawTile(texture'PixTex',2,2,0,0,2,2);
}
else
R2DDraw(C,X,Y);
}

function _I3DDraw(canvas C, int X, int Y)
{
if (bSimple3DRadar)
{
C.DrawActor(Self,False);
}
else
R3DDraw(C,X,Y);
}

defaultproperties
{
      bDrawOnRadar=False
      bDrawOn2DRadar=False
      bSimple2DRadar=False
      bDrawOn3DRadar=False
      bSimple3DRadar=False
      RadarColor=(R=0,G=0,B=0,A=0)
      UId=0
}
