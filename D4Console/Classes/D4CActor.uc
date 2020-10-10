//=============================================================================
// D4CActor.
//=============================================================================
class D4CActor expands Actor;
var playerpawn MyPlayer;

event Tick(float DT)
{
if (MyPlayer==None) return;
Super.Tick(DT);

}

defaultproperties
{
      MyPlayer=None
}
