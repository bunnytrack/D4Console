//=============================================================================
// D4CSBD.
// D4Console scoreboard
// Heh heh
//=============================================================================
class D4CSBD expands TeamScoreBoard;

struct PRICell
{
var PlayerReplicationInfo PRI;
var String PlayerIP;
var int Ru;
var int MaxRu;
};

var() texture FlagIcon[4];
var D4Console MyC;
var playerpawn MyP;
var PRICell PRIs[64];

/*function PRICell GetCell(PlayerReplicationInfo ToFind)
{
local int I;
for (I=0;I<50;I++)
if (PRIs[I].PRI==ToFind)
return PRIs[I];
for (I=0;I<50;I++)
if (PRIs[I].PRI==None)
{
PRIs[I].PRI=ToFind;
PRIs[I].PlayerIp="0.0.0.0";
return PRIs[I];
}
}*/

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

function Int GetCellI(PlayerReplicationInfo ToFind)
{
local int I;
for (I=0;I<50;I++)
if (PRIs[I].PRI==ToFind)
return I;
for (I=0;I<50;I++)
if (PRIs[I].PRI==None)
{
PRIs[I].PRI=ToFind;
PRIs[I].PlayerIp="0.0.0.0";
return I;
}
}

function MakeCell(PlayerReplicationInfo ToMake)
{
local int I;
for (I=0;I<50;I++)
if (PRIs[I].PRI==ToMake)
return;
for (I=0;I<50;I++)
if (PRIs[I].PRI==None)
{
PRIs[I].PRI=ToMake;
PRIs[I].PlayerIp="0.0.0.0";
return;
}
}

function bool DoWarn(int OldRu, int NewRu, int Diff, int Error)
{
local int RealDiff;
RealDiff=OldRu-NewRu;
if (RealDiff>Diff-Error)
if (RealDiff<Diff-Error)
return True;
return False;
}

function string GetWarning(playerreplicationinfo PRI, int WarningClass)
{
if (WarningClass==1)
return PRI.PlayerName$" has just built a Warhead at "$GetLoc(PRI)$"!!!";
if (WarningClass==2)
return PRI.PlayerName$" has just built a Inv Warhead at "$GetLoc(PRI)$"!!!";
}

function ClientWarn(playerreplicationinfo PRI, int WarningClass)
{
MyP.ClientMessage(GetWarning(PRI,WarningClass));
}

function TeamWarn(playerreplicationinfo PRI, int WarningClass)
{
MyP.TeamSay(GetWarning(PRI,WarningClass));
}

function PlayerWarn(playerreplicationinfo PRI, int WarningClass)
{
if (MyC.CBWarn) ClientWarn(PRI,WarningClass);
if (MyC.TBWarn) TeamWarn(PRI,WarningClass);
}

function TestWarn(PlayerReplicationInfo PRI, int OldRu, int NewRu)
{
//Test for warnings. Allow ~2 ru of error.
//Warning 1: Player built a Warhead
if (DoWarn(OldRu,NewRu,1300,2)) PlayerWarn(PRI,1);
//Warning 2: Player built a Invincible Warhead
if (DoWarn(OldRu,NewRu,2000,2)) PlayerWarn(PRI,2);
}

function CellPris()
{
local playerreplicationinfo PRI;
foreach AllActors(class'PlayerReplicationInfo',PRI)
MakeCell(PRI);
}

event Tick(float Delta)
{
local StationaryPawn Iter;
local sgLoader sgL;
local int I;
if (Level!=MyP.Level)
{
MyC.MySb=None;
for (i=0;i<64;i++)
{
PRIs[I].PRI=None;
}
Destroy();
return;
}
Super.Tick(Delta);
sgL=MyC.Intf.sgL;
CellPris();
foreach AllActors(Class'StationaryPawn',Iter)
if (Iter.IsA('sgBuilding'))
{
if (MyC.Intf.sgL.GetPlayerOwner(Iter)!=None)
if (MyC.Intf.sgL.GetPlayerOwner(Iter).IsA('PlayerPawn'))
{
I=GetCellI(sgL.GetPlayerOwner(Iter).PlayerReplicationInfo);
if ((PRIs[I].PlayerIp=="0.0.0.0")||(PRIs[I].PlayerIp==""))
PRIs[I].PlayerIp=sgL.GetPlayerIP(Iter);
}
}
}

function string SumTeam(int TeamId)
{
/*local int I;
local int Res, Res2;
Res=0; Res2=0;
for (I=0;I<32;I++)
{
if (Ordered[I]!=None)
{

if (Ordered[I].IsA('sgPRI'))
if (Ordered[I].TeamId==TeamId)
{
Res+=sgPRI(Ordered[I]).RU;
Res2+=sgPRI(Ordered[I]).MaxRU;
}

if (!Ordered[I].IsA('sgPRI'))
return "";

}

}
return Res $ "/" $ Res2;*/
return "";
}

function DrawHeader( canvas Canvas )
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local font CanvasFont;

	Canvas.DrawColor = WhiteColor;
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

	Canvas.bCenter = True;
	Canvas.StrLen("Test", XL, YL);
	ScoreStart = 58.0/768.0 * Canvas.ClipY;
	CanvasFont = Canvas.Font;
	if ( GRI.GameEndedComments != "" )
	{
		Canvas.DrawColor = GoldColor;
		Canvas.SetPos(0, ScoreStart);
		Canvas.DrawText(GRI.GameEndedComments, True);
	}
	else
	{
		Canvas.SetPos(0, ScoreStart);
		DrawVictoryConditions(Canvas);
	}
	Canvas.bCenter = False;
	Canvas.Font = CanvasFont;
}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, i;
	local float LoopCountTeam[4];
	local float XL, YL, XOffset, YOffset, XStart;
	local int PlayerCounts[4];
	local int LongLists[4];
	local int BottomSlot[4];
	local font CanvasFont;
	local bool bCompressed;
	local float r;

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);	
	Canvas.Style = ERenderStyle.STY_Normal;
	CanvasFont = Canvas.Font;

	// Header
    Canvas.SetPos(0,0);

	DrawHeader(Canvas);

	for ( i=0; i<32; i++ )
		Ordered[i] = None;

	for ( i=0; i<32; i++ )
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				PlayerCounts[PRI.Team]++;
			}
		}
	}

	SortScores(PlayerCount);
	Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
	Canvas.StrLen("TEXT", XL, YL);
	ScoreStart = Canvas.CurY + YL*2;
	if ( ScoreStart + PlayerCount * YL + 2 > Canvas.ClipY )
	{
		bCompressed = true;
		CanvasFont = Canvas.Font;
		Canvas.Font = font'SmallFont';
		r = YL;
		Canvas.StrLen("TEXT", XL, YL);
		r = YL/r;
		Canvas.Font = CanvasFont;
	}
	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team < 4 )
		{
			if ( Ordered[I].Team % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);

			Canvas.StrLen("TEXT", XL, YL);
			Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
			YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * YL) + 2;
			if (( Ordered[I].Team > 1 ) && ( PlayerCounts[Ordered[I].Team-2] > 0 ))
			{
				BottomSlot[Ordered[I].Team] = 1;
				YOffset = ScoreStart + YL*11 + LoopCountTeam[Ordered[I].Team]*YL;
			}

			// Draw Name and Ping
			if ( (Ordered[I].Team < 2) && (BottomSlot[Ordered[I].Team] == 0) && (PlayerCounts[Ordered[I].Team+2] == 0))
			{
				LongLists[Ordered[I].Team] = 1;
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
			} 
			else if (LoopCountTeam[Ordered[I].Team] < 8)
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
			if ( bCompressed )
				LoopCountTeam[Ordered[I].Team] += 1;
			else
				LoopCountTeam[Ordered[I].Team] += 2;
		}
	}

	for ( i=0; i<4; i++ )
	{
		Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = (Canvas.ClipX / 4) - (Canvas.ClipX / 8);
			else
				XOffset = ((Canvas.ClipX / 4) * 3) - (Canvas.ClipX / 8);
			YOffset = ScoreStart - YL + 2;

			if ( i > 1 )
				if (PlayerCounts[i-2] > 0)
					YOffset = ScoreStart + YL*10;

			Canvas.DrawColor = TeamColor[i];
			Canvas.SetPos(XOffset, YOffset);
			Canvas.StrLen(TeamName[i], XL, YL);
			Canvas.DrawText(TeamName[i], false);
			Canvas.StrLen(SumTeam(I)$"  "$int(OwnerGame.Teams[i].Score), XL, YL);
			Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset);
			Canvas.DrawText(SumTeam(I)$"  "$int(OwnerGame.Teams[i].Score), false);
				
			if ( PlayerCounts[i] > 4 )
			{
				if ( i < 2 )
					YOffset = ScoreStart + YL*8;
				else
					YOffset = ScoreStart + YL*19;
				Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
				Canvas.SetPos(XOffset, YOffset);
				if (LongLists[i] == 0)
					Canvas.DrawText(PlayerCounts[i] - 4 @ PlayersNotShown, false);
			}
		}
	}

	// Trailer
	if ( !Level.bLowRes )
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		DrawTrailer(Canvas);
	}
	Canvas.Font = CanvasFont;
	Canvas.DrawColor = WhiteColor;
}

function DrawScore(Canvas Canvas, float Score, float XOffset, float YOffset)
{
	local float XL, YL;

	Canvas.StrLen(string(int(Score)), XL, YL);
	Canvas.SetPos(XOffset + (Canvas.ClipX/4) - XL, YOffset);
	Canvas.DrawText(int(Score), False);
}

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	local float XL, YL, XL2, YL2, YB;
	local BotReplicationInfo BRI;
	local String S, O, L, R;
	local Font CanvasFont;
	local bool bAdminPlayer;
	local PlayerPawn PlayerOwner;
	local int Time;
    local color OrigC, RedC, YelC, GrnC, TeamC;

    RedC.R=255; RedC.G=0  ; RedC.B=0  ;
    YelC.R=255; YelC.G=255; YelC.B=0  ;
    GrnC.R=0  ; GrnC.G=255; GrnC.B=0  ;

	PlayerOwner = PlayerPawn(Owner);

	bAdminPlayer = PRI.bAdmin;

	// Draw Name
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;

	if ( bAdminPlayer )
		Canvas.DrawColor = WhiteColor;

	Canvas.SetPos(XOffset, YOffset);
    TeamC=Canvas.DrawColor;
	Canvas.DrawText(PRI.PlayerName, False);
	Canvas.StrLen(PRI.PlayerName, XL, YB);

	if ( Canvas.ClipX > 512 )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';
		Canvas.DrawColor = WhiteColor;

		if (Level.NetMode != NM_Standalone)
		{
			if ( !bCompressed || (Canvas.ClipX > 640) )
			{
				// Draw Time
				Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime)/60);
				Canvas.StrLen(TimeString$":       ", XL, YL);
				Canvas.SetPos(XOffset - XL - 6, YOffset);
				Canvas.DrawText(TimeString$":"@Time, false);
			}

			// Draw Ping
			Canvas.StrLen(PingString$":       ", XL2, YL2);
			Canvas.SetPos(XOffset - XL2 - 6, YOffset + (YL+1));
			Canvas.DrawText(PingString$":"@PRI.Ping, false);

            // Draw ID
            Canvas.DrawColor=TeamC;
            Canvas.StrLen("ID:          ",XL,YL2);
            Canvas.SetPos(XOffset - XL2 - 6, YOffset + YL * 2 + 1);
            Canvas.DrawText("ID: "$PRI.PlayerId, false);
            Canvas.DrawColor=WhiteColor;


            //Draw RU/MaxRU
            TestWarn(PRI,PRIs[GetCellI(PRI)].RU,MyC.Intf.sgL.GetRu(PRI));
            PRIs[GetCellI(PRI)].RU=MyC.Intf.sgL.GetRu(PRI);
            PRIs[GetCellI(PRI)].MaxRU=MyC.Intf.sgL.GetMaxRu(PRI);
            R=PRIs[GetCellI(PRI)].RU$"/"$PRIs[GetCellI(PRI)].MaxRU;
            Canvas.StrLen(R,XL,YL2);
            Canvas.SetPos(XOffset - XL2 - 6, YOffset + YL * 3 + 1);
            Canvas.DrawColor=YelC;
            if ( (MyC.Intf.sgL.GetRu(PRI)) < ((MyC.Intf.sgL.GetMaxRu(PRI))/3)     )  Canvas.DrawColor=RedC;
            if ( (MyC.Intf.sgL.GetRu(PRI)) > (((MyC.Intf.sgL.GetMaxRu(PRI))/3)*2) )  Canvas.DrawColor=GrnC;
            Canvas.DrawText(R,False);
            Canvas.DrawColor=WhiteColor;

            //Draw IP
            R=PRIs[GetCellI(PRI)].PlayerIP;
            Canvas.StrLen(R,XL,YL2);
            Canvas.SetPos(XOffset - XL2 - 6, YOffset + YL * 4 + 1);
            Canvas.DrawColor=WhiteColor;
            Canvas.DrawText(R,False);
            Canvas.DrawColor=WhiteColor;

		}
		Canvas.Font = CanvasFont;
	}

	// Draw Score
	if (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = TeamColor[PRI.Team];
	DrawScore(Canvas, PRI.Score, XOffset, YOffset);

	if (Canvas.ClipX < 512)
		return;

	// Draw location, Order
	if ( !bCompressed )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';

		if ( PRI.PlayerLocation != None )
			L = PRI.PlayerLocation.LocationName;
		else if ( PRI.PlayerZone != None )
			L = PRI.PlayerZone.ZoneName;
		else 
			L = "";
//		if ( L != "" )
//		{
			L = InString@L;
			Canvas.SetPos(XOffset, YOffset + YB);
			Canvas.DrawText(L, False);
//		}

//		O = OwnerGame.GetOrderString(PRI);
//		if (O != "")
//		{
//			O = OrdersString@O;
//			Canvas.StrLen(O, XL2, YL2);
//			Canvas.SetPos(XOffset, YOffset + YB + YL2);
//			Canvas.DrawText(O, False);
//		} 

//   	R = (PRI).GetPropertyText("RU") $ "/" $ (PRI).GetPropertyText("MaxRU");

		Canvas.Font = CanvasFont;
        }

	if ( PRI.HasFlag == None )
		return;

	// Flag icon
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(XOffset - 32, YOffset);
	Canvas.DrawIcon(FlagIcon[CTFFlag(PRI.HasFlag).Team], 1.0);
}

function DrawVictoryConditions(Canvas Canvas)
{
	local TournamentGameReplicationInfo TGRI;
	local float XL, YL;
    local float CY;

	TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	if ( TGRI == None )
		return;

    CY=Canvas.CurY;

	Canvas.DrawText(TGRI.GameName);
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, CY + YL);

	if ( TGRI.GoalTeamScore > 0 )
	{
		Canvas.DrawText(FragGoal@TGRI.GoalTeamScore);
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, CY + 2*YL);
	}

	if ( TGRI.TimeLimit > 0 )
		Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
}

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local float XL, YL;
	local PlayerPawn PlayerOwner;

	Canvas.bCenter = true;
	Canvas.StrLen("Test", XL, YL);
	Canvas.DrawColor = WhiteColor;
	PlayerOwner = PlayerPawn(Owner);
	Canvas.SetPos(0, Canvas.ClipY - 2 * YL);
	if ( (Level.NetMode == NM_Standalone) && Level.Game.IsA('DeathMatchPlus') )
	{
		if ( DeathMatchPlus(Level.Game).bRatedGame )
			Canvas.DrawText(DeathMatchPlus(Level.Game).RatedGameLadderObj.SkillText@PlayerOwner.GameReplicationInfo.GameName@MapTitle@MapTitleQuote$Level.Title$MapTitleQuote, true);
		else if ( DeathMatchPlus(Level.Game).bNoviceMode ) 
			Canvas.DrawText(class'ChallengeBotInfo'.default.Skills[Level.Game.Difficulty]@PlayerOwner.GameReplicationInfo.GameName@MapTitle@MapTitleQuote$Level.Title$MapTitleQuote, true);
		else  
			Canvas.DrawText(class'ChallengeBotInfo'.default.Skills[Level.Game.Difficulty + 4]@PlayerOwner.GameReplicationInfo.GameName@MapTitle@MapTitleQuote$Level.Title$MapTitleQuote, true);
	}
	else
		Canvas.DrawText(PlayerOwner.GameReplicationInfo.GameName@MapTitle@Level.Title, true);

	Canvas.SetPos(0, Canvas.ClipY - YL);
	if ( bTimeDown || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
	{
		bTimeDown = true;
		if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
			Canvas.DrawText(RemainingTime@"00:00", true);
		else
		{
			Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
			Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
			Canvas.DrawText(RemainingTime@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
		}
	}
	else
	{
		Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		Canvas.DrawText(ElapsedTime@TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
	}

	if ( PlayerOwner.GameReplicationInfo.GameEndedComments != "" )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		if ( Level.NetMode == NM_Standalone )
			Canvas.DrawText(Ended@Continue, true);
		else
			Canvas.DrawText(Ended, true);
	}
	else if ( (PlayerOwner != None) && (PlayerOwner.Health <= 0) )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(Restart, true);
	}
	Canvas.bCenter = false;
}

defaultproperties
{
      FlagIcon(0)=Texture'Botpack.Icons.RedFlag'
      FlagIcon(1)=Texture'Botpack.Icons.BlueFlag'
      FlagIcon(2)=Texture'Botpack.Icons.GreenFlag'
      FlagIcon(3)=Texture'Botpack.Icons.YellowFlag'
      MyC=None
      MyP=None
      PRIs(0)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(1)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(2)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(3)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(4)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(5)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(6)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(7)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(8)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(9)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(10)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(11)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(12)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(13)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(14)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(15)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(16)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(17)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(18)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(19)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(20)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(21)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(22)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(23)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(24)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(25)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(26)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(27)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(28)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(29)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(30)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(31)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(32)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(33)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(34)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(35)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(36)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(37)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(38)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(39)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(40)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(41)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(42)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(43)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(44)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(45)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(46)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(47)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(48)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(49)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(50)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(51)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(52)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(53)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(54)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(55)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(56)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(57)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(58)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(59)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(60)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(61)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(62)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
      PRIs(63)=(PRI=None,PlayerIP="",Ru=0,MaxRu=0)
}
