//=============================================================================
// D4Decal.
// D4Decal with a big drawscale for decalling invisible walkaways and w/e
//=============================================================================
class D4Decal expands Decal;

simulated event PostBeginPlay()
{
//	AttachToSurface();
// Do not do attaching here
}

simulated function AttachToSurface()
{
	if(AttachDecal(100) == None)	// trace 100 units ahead in direction of current rotation
		Destroy();
}

defaultproperties
{
      Texture=Texture'Botpack.energymark'
      DrawScale=2.500000
}
