//=============================================================================
// sgLoader.
//=============================================================================
class sgLoader expands Actor;

function int GetRu(PlayerReplicationInfo PRI)
{
return 0;
}

function int GetMaxRu(PlayerReplicationInfo PRI)
{
return 0;
}

function int GetBuildCost(StationaryPawn Building)
{
return 0;
}

function int GetUpgradeCost(StationaryPawn Building)
{
return 0;
}

function int GetTeam(StationaryPawn Building)
{
return -1;
}

function pawn GetPlayerOwner(StationaryPawn Building)
{
return Building;
}

function string GetPlayerIP(StationaryPawn Building)
{
return "0.0.0.0";
}

function float GetBuildTime(StationaryPawn Building)
{
return 0;
}

function float GetGrade(StationaryPawn Building)
{
return 0;
}

function float GetEnergy(StationaryPawn Building)
{
return 0;
}

function float GetMaxEnergy(StationaryPawn Building)
{
return 0;
}

function float GetSCount(StationaryPawn Building)
{
return 0;
}

defaultproperties
{
}
