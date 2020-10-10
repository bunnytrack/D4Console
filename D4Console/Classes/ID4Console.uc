//=============================================================================
// iD4Console.
// Interface actor for D4Console
//=============================================================================
class ID4Console expands Actor;
var D4Console Cn;
var PlayerPawn Pl;
var sgLoader sgL;
var TargetMark TM;
var actor HitA;
var float NegDelta;

var vector D1, D2;
var bool bDrawDrop;

var actor Keyz[500];

var config string CP;

var d4drawactor DA;

simulated function Welcome()
{
	local string Message,LastName;
	local playerreplicationinfo PRI;
	local bool bFirstName;
	local int n,lst;
	
	Message = "Hey ";
	bFirstName = True;
	n = 0;

	foreach AllActors(class'PlayerReplicationInfo',PRI)
	{
		if ( PRI.PlayerName != Pl.GetHumanName())		// Don't say hello to yourself, psychopath.
		{
			if ( bFirstName )
			{
			Message = Message$PRI.PlayerName;
			bFirstName = False;
			n++;
			}
			
			else
			{
			Message = Message$", "$PRI.PlayerName;
			n++;
			LastName = PRI.PlayerName;
			}
		}
	}

	if ( n == 2)	// Only two others are present. Use the 'and' conjunction for good grammar. me smart no?
	{
	Message = "Hey ";
	bFirstName = True;
	n=0;
	
		foreach AllActors(class'PlayerReplicationInfo',PRI)
		{
			if ( PRI.PlayerName != Pl.GetHumanName())		// Don't say hello to yourself, psychopath.
			{
				if (bFirstName)
				{
				Message = Message$PRI.PlayerName;
				bFirstName = False;
				n++;
				}
				
				else
				{
				Message = Message$" and "$PRI.PlayerName;
				n++;
				}
			}
		}
	}
	
	if ( N > 2 )
	{
	Lst = InStr(Message,LastName);
	Message = Left(Message,Lst);
	Message = Message$" and ";
	Message = Message$LastName;
	}
	
	Message = Message$".";
	
	if (CP != "")
	Message = Message$" "$CP;
	
	if (n>0)
	Pl.ConsoleCommand("Say "$Message);
}

function bool DoKey(inventory K)
{
/*local inventory I;
if (K==None) return False;
for (I=Pl.Inventory;I!=None;I=I.Inventory)
if (I.IsA('Key'))
if (I.Tag==K.Tag)
return False;
return True;*/
local float HorS, VertS;
local vector TV;
if (K==None) return False;
if (!K.IsA('Key')) return False;
TV=K.Location-Pl.Location;
TV.Z=0;
HorS=VSize(TV);
VertS=Abs(K.Location.Z-Pl.Location.Z);
if (HorS<(K.CollisionRadius+Pl.CollisionRadius))
if (VertS<(K.CollisionHeight+Pl.CollisionHeight))
{AllocKey(K); return False;}
if (KeyFree(K)) return True;
else return False;
}

function bool KeyFree(actor K)
{
local int I;
for (I=0;I<500;I++)
if (Keyz[I]==K)
return False;
return True;
}

function bool AllocKey(actor K)
{
local int I;
if (!KeyFree(K)) return False;
for (I=0;I<500;I++)
if (Keyz[I]==None)
{Keyz[I]=K; return True;}
return False;
}

function ResetKeys()
{
local int I;
for (I=0;I<500;I++)
Keyz[I]=None;
}

function Dummy();

function Color GetPlayerColor(playerpawn P)
{
if (P.PlayerReplicationInfo==None) return MakeC(0,0,0);
if (P.PlayerReplicationInfo.Team==Pl.PlayerReplicationInfo.Team) return MakeC(0,255,0);
if (P.PlayerReplicationInfo.Team!=Pl.PlayerReplicationInfo.Team) return MakeC(255,0,0);
}

function DrawRadar(canvas Canvas)
{
local actor P;
local texture RadarTex;
local vector EnemyToPlayer;
local float ZDif, Len, Angle, X, Y;
local rotator RotEnemyToPlayer, MyRot;

		Canvas.SetPos(-6,Canvas.ClipY/1.5);
		
Canvas.DrawColor=MakeC(64,64,64,64);

//		if (bTranslucentRadar)
		Canvas.Style = 3;
//		else
//		Canvas.Style = 1;
		
		Canvas.DrawIcon(texture'RadarHUD',1.5);
		
		Canvas.Style = 1;
		
		Canvas.SetPos(84,Canvas.ClipY/1.5 + 88);
		Canvas.DrawIcon(texture'crosshair2',1);
	
			foreach RadiusActors(class'Actor',P,4000,Pl.Location)		// radarrad was 4000, 4000 is default
			{
				if (p!=None && P!=Pl)
				{
                    RadarTex=texture'PixTex';
                    if (P.IsA('Key') && DoKey(Inventory(P)))
						Canvas.DrawColor=MakeC(255,255,0);
					else if (P.IsA('D4Helper'))
						Dummy();
					else if (P.IsA('PlayerPawn'))
						Canvas.DrawColor=GetPlayerColor(PlayerPawn(P));
					else if (P.IsA('GuidedWarshell'))
						Canvas.DrawColor=MakeC(255,0,255);
					else if (P.IsA('Warshell'))
						Canvas.DrawColor=MakeC(128,0,128);
					else Continue;
					EnemyToPlayer = P.Location - Pl.Location;
					ZDif = EnemyToPlayer.Z;
     				ZDif/=2000;
					if( ZDif<-0.5 )
						ZDif = -0.5;
					else if( ZDif>1 )
						ZDif = 1;
					ZDif+=1;
					ZDif*=4;
					EnemyToPlayer.Z = 0;
					Len = VSize(EnemyToPlayer);						// Distance from player.
					RotEnemyToPlayer = Rotator(EnemyToPlayer);
					MyRot = Rotator(Vector(Pl.Rotation));
					if ( MyRot.Yaw < 0 )
					MyRot.Yaw += 65535;
					if ( RotEnemyToPlayer.Yaw < 0 )
					RotEnemyToPlayer.Yaw += 65535;
					Angle = MyRot.Yaw - RotEnemyToPlayer.Yaw;
					if (Angle < 0)
					Angle+=65535;
					X = ( -Sin( (Angle/65535)*2*Pi ) * Len ); //* ( RadarRadius/4000 );
					Y = ( Cos( (Angle/65535)*2*Pi ) * Len ); //* (RadarRadius/4000);	
					if ( Len > 3450 )		// default is 3450
					RadarTex = None;
					if ( RadarTex != None )
					{
					if (P.IsA('D4Helper'))
					D4Helper(P).RenderMe2D(Canvas,(X/43)+90,(Canvas.ClipY/1.5)-(Y/43)+93);
					else
					{
					X-=1;
					Y-=1;
					Canvas.SetPos( (X/43)+90,(Canvas.ClipY/1.5)-(Y/43)+93);
//					Canvas.DrawTile(radartex,ZDif,ZDif,0,0,ZDif,ZDif);
					Canvas.DrawTile(radartex,2,2,0,0,2,2);
					}
					}
				}
			}
}

function Drop1()
{
D1=Pl.Location;
}

function Drop2()
{
D2=Pl.Location;
}

function DropD()
{
bDrawDrop=!bDrawDrop;
}

function DrawDrop(canvas C)
{
if (!bDrawDrop) return;
/*C.DrawColor.R=255;
C.DrawColor.G=255;
C.DrawColor.B=64;
C.DrawColor.A=0;
Draw3DLine(C,D1,D2);*/
//Draw3DBeam(C,D1,D2,Cn.SFX3[5],256,1,False);
}

event PostBeginPlay()
{
Super.PostBeginPlay();
Init();
}

simulated static function bool WorldToScreen(Vector WorldLocation, Pawn ThePlayer,
     float ScreenWidth, float ScreenHeight, out float X, out float Y)
{
   local vector EyePos, RelativeToPlayer;
   local float Scale;

   EyePos = ThePlayer.Location;
   EyePos.Z += ThePlayer.BaseEyeHeight; // Maybe ThePlayer.EyeHeight instead?

   RelativeToPlayer = (WorldLocation - EyePos) << ThePlayer.ViewRotation;

   if (RelativeToPlayer.X < 0.01)
      return false;

   Scale = (ScreenWidth / 2) / Tan(ThePlayer.FovAngle/2/180*Pi);

   X = RelativeToPlayer.Y / RelativeToPlayer.X * Scale + ScreenWidth / 2;
   Y = - RelativeToPlayer.Z / RelativeToPlayer.X * Scale + ScreenHeight / 2;

   return true;
}

function DrawPixel(canvas C, int X, int Y)
{
C.SetPos(X,Y);
C.DrawTile(texture'PixTex',1,1,0,0,1,1);
}

function vector Vec(float X, float Y, float Z)
{
local vector V;
V.X=X;
V.Y=Y;
V.Z=Z;
return V;
}

function Draw2DLine(canvas C, int X1, int Y1, int X2, int Y2)
{
local float VS;
local int XD, YD;
local float XP, YP;
local int I;
XD=Abs(X1-X2);
YD=Abs(Y1-Y2);
VS=Sqrt(XD*XD+YD*YD);
XP=(X2-X1)/VS;
YP=(Y2-Y1)/VS;
for (I=0;I<VS*10;I++)
{
C.SetPos(X1+XP*(I/10),Y1+YP*(I/10));
C.DrawTile(texture'PixTex',1,1,0,0,1,1);
}
}

function Draw3DLine(canvas C, vector P1, vector P2, optional bool ClearZ)
{
local float X,Y,Ox,Oy;
local int IPts;
local float FPts;
local vector Delta;
local vector Dir;
local int I;
local bool bDraw;
Delta=P2-P1;
FPts=500;
Dir=Delta/FPts;
IPts=Int(FPts);
OX=0; OY=0;
for (I=0;I<IPts;I++)
{
if (!ClearZ)
if (!FastTrace(P1+Dir*I,Pl.Location+Pl.EyeHeight*vect(0,0,1))) Continue;
if (!WorldToScreen(P1+Dir*I,PL,C.ClipX,C.ClipY,X,Y)) Continue;
//C.SetPos(X,Y);
//C.DrawTile(texture'PixTex',1,1,0,0,1,1);
//if (OX>0) if (OY>0)
//Draw2DLine(C,OX,OY,X,Y);
OX=X;
OY=Y;
}
}

function Draw3DHCyl(canvas C, vector L, float Rad)
{
local rotator R;
local int I;
local vector P;
local float X,Y;
R=Rot(0,0,0);
for (I=0;I<65536;I+=64)
{
R.Yaw=I;
P=L+Vector(R)*Rad;
if (WorldToScreen(P,PL,C.ClipX,C.ClipY,X,Y))
{
C.SetPos(X,Y);
C.DrawTile(texture'PixTex',1,1,0,0,1,1);
}
}
}

function Draw3DStuff(canvas C)
{
//C.DrawColor.R=255;
//C.DrawColor.G=255;
//C.DrawColor.B=64;
//C.DrawColor.A=0;
//Draw3DHCyl(C,Pl.Location+Pl.CollisionHeight*vect(0,0,-1),Pl.CollisionRadius);
}

event Tick(float Delta)
{
local vector HL,HN;
local actor HA;
local vector Eh,Beh,StT;
if (Pl==None)
if (Owner!=None)
if (Owner.IsA('PlayerPawn'))
Pl=PlayerPawn(Owner);
if (Cn==None)
if (Pl!=None)
if (Pl.Player!=None)
if (Pl.Player.Console!=None)
if (Pl.Player.Console.IsA('D4Console'))
Cn=D4Console(Pl.Player.Console);
HA=Pl.Trace(Hl,Hn,(Pl.Location+Pl.BaseEyeHeight*vect(0,0,1))+Vector(Pl.ViewRotation)*60000,(Pl.Location+Pl.BaseEyeHeight*vect(0,0,1)));
HitA=HA;
if (HitA!=None)
if (HitA.IsA('LevelInfo')) HitA=None;
Super.Tick(Delta);
if (sgL==None)
sgL=Spawn(class'sgLoader',Self);
if (sgL!=None)
sgL.bHidden=True;
bHidden=True;
if (TM==None)
TM=Spawn(Class'TargetMark',Self);
if (TM!=None)
{
TM.SetLocation(HL);
}
if (DA!=None) if (DA.Level!=Level) {DA.Destroy(); DA=None;}
if (DA==None) DA=Spawn(class'D4DrawActor');
}

event Destroyed()
{
Super.Destroyed();
if (TM!=None)
TM.Destroy();

}

function sgCreateLoader(string LdrClass)
{
local class<sgLoader> NewClass;
NewClass=class<sgLoader>(DynamicLoadObject(LdrClass,class'Class'));
if (NewClass==None)
{
Pl.ClientMessage("Failed to initialize loader");
return;
}
if (sgL!=None)
sgL.Destroy();
sgL=Spawn(NewClass,Self);
Pl.ClientMessage("Successfully loaded sgLoader: "$sgL.Class);
}

event ConsoleTick(float Delta)
{

}

function Init()
{

}

function DrawVal(canvas C, string Cap, string Val, color CapC, color ValC, optional bool ShiftLoc, optional string AfterPar, optional bool NoDots)
{
local float OX, OY, CW, CH, VW, VH, Sh;
local color OC;
local string bs;
if (nodots)
bs="";
else
bs=": ";
OC=C.DrawColor;
OX=C.CurX;
OY=C.CurY;
C.StrLen(Cap$bs,CW,CH);
C.StrLen(Val,VW,VH);

C.DrawColor=CapC;
C.SetPos(OX,OY);
C.DrawText(Cap$bs,True);

C.DrawColor=ValC;
C.SetPos(OX+CW,OY);
C.DrawText(Val,True);

C.DrawColor=CapC;
C.SetPos(OX+CW+VW,OY);
C.DrawText(AfterPar,True);

C.DrawColor=OC;

if (ShiftLoc) Sh=CH-NegDelta; else Sh=0;

C.SetPos(OX,OY+Sh);
}

function color MakeC(byte R, byte G, byte B, optional byte A)
{
local color C;
C.R=R;
C.G=G;
C.B=B;
C.A=A;
return C;
}

function color MCC(string Col)
{
return MakeTC(Col,0,0);
}

function color MVC(string Col)
{
return MakeTC(Col,128,0);
}

function color MakeTC(string Col, optional int LT, optional byte A)
{
if (Col=="") return MakeC(0,0,0,0);
if (col~="l") return MakeC(LT,LT,LT,A);
if (col~="r") return MakeC(255,LT,LT,A);
if (col~="o") return MakeC(255,128,LT/2,A);
if (col~="y") return MakeC(255,255,LT,A);
if (col~="g") return MakeC(LT,255,LT,A);
if (col~="b") return MakeC(LT,LT,255,A);
if (col~="c") return MakeC(LT,255,255,A);
if (col~="p") return MakeC(255,LT,255,A);
if (col~="w") return MakeC(255,255,255,A);
}


function RenderMe(canvas C)
{
if (HitA!=None)
{

}
DrawRadar(C);
Draw3DStuff(C);
}

function DrawMap(canvas C)
{
local vector V, X, Y, Z;
local rotator R;
local int F;
local bool BH;
if (!Cn.bDrawMap) return;
R=Pl.Rotation;
R.Pitch=0;
GetAxes(R,X,Y,Z);
//X=Depth
//Y=X >
//Z=Y ^
V=Pl.Location;
V+=Cn.DMVect.X*X;
V+=Cn.DMVect.Y*Y;
V+=Cn.DMVect.Z*Z;
R.Yaw=Pl.Rotation.Yaw;
R.Pitch=-16384;
R.Roll=0;
R+=Cn.DMRot;
F=Cn.DMFov;
if (F==0) F=90;
if (F<10) F=10;
if (F>120) F=120;
//native(480) final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );
BH=Pl.bBehindView;
Pl.bBehindView=True;
C.DrawPortal(C.ClipX/2-150,100,300,250,Pl,V,R,F,True);
Pl.bBehindView=BH;
}

function RenderMeReq(canvas C)
{
if (TM!=None)
Tm.bHidden=((!Cn.bHide) && (Cn.bShowTM));
//if (TM!=None)
//if (Tm.bHidden==False)
//C.DrawActor(TM,False);
DrawDrop(C);
}

function PrePostR(canvas C)
{
DrawMap(C);
}

function PostPostR(canvas C)
{

}

function PreVisualR(canvas C)
{

}

function PostVisualR(canvas C)
{
RenderMe(C);
}

function PreGuiR(canvas C)
{

}

function PostGuiR(canvas C)
{
RenderMeReq(C);
}

defaultproperties
{
      Cn=None
      Pl=None
      sgL=None
      TM=None
      HitA=None
      NegDelta=0.000000
      d1=(X=0.000000,Y=0.000000,Z=0.000000)
      d2=(X=0.000000,Y=0.000000,Z=0.000000)
      bDrawDrop=False
      Keyz(0)=None
      Keyz(1)=None
      Keyz(2)=None
      Keyz(3)=None
      Keyz(4)=None
      Keyz(5)=None
      Keyz(6)=None
      Keyz(7)=None
      Keyz(8)=None
      Keyz(9)=None
      Keyz(10)=None
      Keyz(11)=None
      Keyz(12)=None
      Keyz(13)=None
      Keyz(14)=None
      Keyz(15)=None
      Keyz(16)=None
      Keyz(17)=None
      Keyz(18)=None
      Keyz(19)=None
      Keyz(20)=None
      Keyz(21)=None
      Keyz(22)=None
      Keyz(23)=None
      Keyz(24)=None
      Keyz(25)=None
      Keyz(26)=None
      Keyz(27)=None
      Keyz(28)=None
      Keyz(29)=None
      Keyz(30)=None
      Keyz(31)=None
      Keyz(32)=None
      Keyz(33)=None
      Keyz(34)=None
      Keyz(35)=None
      Keyz(36)=None
      Keyz(37)=None
      Keyz(38)=None
      Keyz(39)=None
      Keyz(40)=None
      Keyz(41)=None
      Keyz(42)=None
      Keyz(43)=None
      Keyz(44)=None
      Keyz(45)=None
      Keyz(46)=None
      Keyz(47)=None
      Keyz(48)=None
      Keyz(49)=None
      Keyz(50)=None
      Keyz(51)=None
      Keyz(52)=None
      Keyz(53)=None
      Keyz(54)=None
      Keyz(55)=None
      Keyz(56)=None
      Keyz(57)=None
      Keyz(58)=None
      Keyz(59)=None
      Keyz(60)=None
      Keyz(61)=None
      Keyz(62)=None
      Keyz(63)=None
      Keyz(64)=None
      Keyz(65)=None
      Keyz(66)=None
      Keyz(67)=None
      Keyz(68)=None
      Keyz(69)=None
      Keyz(70)=None
      Keyz(71)=None
      Keyz(72)=None
      Keyz(73)=None
      Keyz(74)=None
      Keyz(75)=None
      Keyz(76)=None
      Keyz(77)=None
      Keyz(78)=None
      Keyz(79)=None
      Keyz(80)=None
      Keyz(81)=None
      Keyz(82)=None
      Keyz(83)=None
      Keyz(84)=None
      Keyz(85)=None
      Keyz(86)=None
      Keyz(87)=None
      Keyz(88)=None
      Keyz(89)=None
      Keyz(90)=None
      Keyz(91)=None
      Keyz(92)=None
      Keyz(93)=None
      Keyz(94)=None
      Keyz(95)=None
      Keyz(96)=None
      Keyz(97)=None
      Keyz(98)=None
      Keyz(99)=None
      Keyz(100)=None
      Keyz(101)=None
      Keyz(102)=None
      Keyz(103)=None
      Keyz(104)=None
      Keyz(105)=None
      Keyz(106)=None
      Keyz(107)=None
      Keyz(108)=None
      Keyz(109)=None
      Keyz(110)=None
      Keyz(111)=None
      Keyz(112)=None
      Keyz(113)=None
      Keyz(114)=None
      Keyz(115)=None
      Keyz(116)=None
      Keyz(117)=None
      Keyz(118)=None
      Keyz(119)=None
      Keyz(120)=None
      Keyz(121)=None
      Keyz(122)=None
      Keyz(123)=None
      Keyz(124)=None
      Keyz(125)=None
      Keyz(126)=None
      Keyz(127)=None
      Keyz(128)=None
      Keyz(129)=None
      Keyz(130)=None
      Keyz(131)=None
      Keyz(132)=None
      Keyz(133)=None
      Keyz(134)=None
      Keyz(135)=None
      Keyz(136)=None
      Keyz(137)=None
      Keyz(138)=None
      Keyz(139)=None
      Keyz(140)=None
      Keyz(141)=None
      Keyz(142)=None
      Keyz(143)=None
      Keyz(144)=None
      Keyz(145)=None
      Keyz(146)=None
      Keyz(147)=None
      Keyz(148)=None
      Keyz(149)=None
      Keyz(150)=None
      Keyz(151)=None
      Keyz(152)=None
      Keyz(153)=None
      Keyz(154)=None
      Keyz(155)=None
      Keyz(156)=None
      Keyz(157)=None
      Keyz(158)=None
      Keyz(159)=None
      Keyz(160)=None
      Keyz(161)=None
      Keyz(162)=None
      Keyz(163)=None
      Keyz(164)=None
      Keyz(165)=None
      Keyz(166)=None
      Keyz(167)=None
      Keyz(168)=None
      Keyz(169)=None
      Keyz(170)=None
      Keyz(171)=None
      Keyz(172)=None
      Keyz(173)=None
      Keyz(174)=None
      Keyz(175)=None
      Keyz(176)=None
      Keyz(177)=None
      Keyz(178)=None
      Keyz(179)=None
      Keyz(180)=None
      Keyz(181)=None
      Keyz(182)=None
      Keyz(183)=None
      Keyz(184)=None
      Keyz(185)=None
      Keyz(186)=None
      Keyz(187)=None
      Keyz(188)=None
      Keyz(189)=None
      Keyz(190)=None
      Keyz(191)=None
      Keyz(192)=None
      Keyz(193)=None
      Keyz(194)=None
      Keyz(195)=None
      Keyz(196)=None
      Keyz(197)=None
      Keyz(198)=None
      Keyz(199)=None
      Keyz(200)=None
      Keyz(201)=None
      Keyz(202)=None
      Keyz(203)=None
      Keyz(204)=None
      Keyz(205)=None
      Keyz(206)=None
      Keyz(207)=None
      Keyz(208)=None
      Keyz(209)=None
      Keyz(210)=None
      Keyz(211)=None
      Keyz(212)=None
      Keyz(213)=None
      Keyz(214)=None
      Keyz(215)=None
      Keyz(216)=None
      Keyz(217)=None
      Keyz(218)=None
      Keyz(219)=None
      Keyz(220)=None
      Keyz(221)=None
      Keyz(222)=None
      Keyz(223)=None
      Keyz(224)=None
      Keyz(225)=None
      Keyz(226)=None
      Keyz(227)=None
      Keyz(228)=None
      Keyz(229)=None
      Keyz(230)=None
      Keyz(231)=None
      Keyz(232)=None
      Keyz(233)=None
      Keyz(234)=None
      Keyz(235)=None
      Keyz(236)=None
      Keyz(237)=None
      Keyz(238)=None
      Keyz(239)=None
      Keyz(240)=None
      Keyz(241)=None
      Keyz(242)=None
      Keyz(243)=None
      Keyz(244)=None
      Keyz(245)=None
      Keyz(246)=None
      Keyz(247)=None
      Keyz(248)=None
      Keyz(249)=None
      Keyz(250)=None
      Keyz(251)=None
      Keyz(252)=None
      Keyz(253)=None
      Keyz(254)=None
      Keyz(255)=None
      Keyz(256)=None
      Keyz(257)=None
      Keyz(258)=None
      Keyz(259)=None
      Keyz(260)=None
      Keyz(261)=None
      Keyz(262)=None
      Keyz(263)=None
      Keyz(264)=None
      Keyz(265)=None
      Keyz(266)=None
      Keyz(267)=None
      Keyz(268)=None
      Keyz(269)=None
      Keyz(270)=None
      Keyz(271)=None
      Keyz(272)=None
      Keyz(273)=None
      Keyz(274)=None
      Keyz(275)=None
      Keyz(276)=None
      Keyz(277)=None
      Keyz(278)=None
      Keyz(279)=None
      Keyz(280)=None
      Keyz(281)=None
      Keyz(282)=None
      Keyz(283)=None
      Keyz(284)=None
      Keyz(285)=None
      Keyz(286)=None
      Keyz(287)=None
      Keyz(288)=None
      Keyz(289)=None
      Keyz(290)=None
      Keyz(291)=None
      Keyz(292)=None
      Keyz(293)=None
      Keyz(294)=None
      Keyz(295)=None
      Keyz(296)=None
      Keyz(297)=None
      Keyz(298)=None
      Keyz(299)=None
      Keyz(300)=None
      Keyz(301)=None
      Keyz(302)=None
      Keyz(303)=None
      Keyz(304)=None
      Keyz(305)=None
      Keyz(306)=None
      Keyz(307)=None
      Keyz(308)=None
      Keyz(309)=None
      Keyz(310)=None
      Keyz(311)=None
      Keyz(312)=None
      Keyz(313)=None
      Keyz(314)=None
      Keyz(315)=None
      Keyz(316)=None
      Keyz(317)=None
      Keyz(318)=None
      Keyz(319)=None
      Keyz(320)=None
      Keyz(321)=None
      Keyz(322)=None
      Keyz(323)=None
      Keyz(324)=None
      Keyz(325)=None
      Keyz(326)=None
      Keyz(327)=None
      Keyz(328)=None
      Keyz(329)=None
      Keyz(330)=None
      Keyz(331)=None
      Keyz(332)=None
      Keyz(333)=None
      Keyz(334)=None
      Keyz(335)=None
      Keyz(336)=None
      Keyz(337)=None
      Keyz(338)=None
      Keyz(339)=None
      Keyz(340)=None
      Keyz(341)=None
      Keyz(342)=None
      Keyz(343)=None
      Keyz(344)=None
      Keyz(345)=None
      Keyz(346)=None
      Keyz(347)=None
      Keyz(348)=None
      Keyz(349)=None
      Keyz(350)=None
      Keyz(351)=None
      Keyz(352)=None
      Keyz(353)=None
      Keyz(354)=None
      Keyz(355)=None
      Keyz(356)=None
      Keyz(357)=None
      Keyz(358)=None
      Keyz(359)=None
      Keyz(360)=None
      Keyz(361)=None
      Keyz(362)=None
      Keyz(363)=None
      Keyz(364)=None
      Keyz(365)=None
      Keyz(366)=None
      Keyz(367)=None
      Keyz(368)=None
      Keyz(369)=None
      Keyz(370)=None
      Keyz(371)=None
      Keyz(372)=None
      Keyz(373)=None
      Keyz(374)=None
      Keyz(375)=None
      Keyz(376)=None
      Keyz(377)=None
      Keyz(378)=None
      Keyz(379)=None
      Keyz(380)=None
      Keyz(381)=None
      Keyz(382)=None
      Keyz(383)=None
      Keyz(384)=None
      Keyz(385)=None
      Keyz(386)=None
      Keyz(387)=None
      Keyz(388)=None
      Keyz(389)=None
      Keyz(390)=None
      Keyz(391)=None
      Keyz(392)=None
      Keyz(393)=None
      Keyz(394)=None
      Keyz(395)=None
      Keyz(396)=None
      Keyz(397)=None
      Keyz(398)=None
      Keyz(399)=None
      Keyz(400)=None
      Keyz(401)=None
      Keyz(402)=None
      Keyz(403)=None
      Keyz(404)=None
      Keyz(405)=None
      Keyz(406)=None
      Keyz(407)=None
      Keyz(408)=None
      Keyz(409)=None
      Keyz(410)=None
      Keyz(411)=None
      Keyz(412)=None
      Keyz(413)=None
      Keyz(414)=None
      Keyz(415)=None
      Keyz(416)=None
      Keyz(417)=None
      Keyz(418)=None
      Keyz(419)=None
      Keyz(420)=None
      Keyz(421)=None
      Keyz(422)=None
      Keyz(423)=None
      Keyz(424)=None
      Keyz(425)=None
      Keyz(426)=None
      Keyz(427)=None
      Keyz(428)=None
      Keyz(429)=None
      Keyz(430)=None
      Keyz(431)=None
      Keyz(432)=None
      Keyz(433)=None
      Keyz(434)=None
      Keyz(435)=None
      Keyz(436)=None
      Keyz(437)=None
      Keyz(438)=None
      Keyz(439)=None
      Keyz(440)=None
      Keyz(441)=None
      Keyz(442)=None
      Keyz(443)=None
      Keyz(444)=None
      Keyz(445)=None
      Keyz(446)=None
      Keyz(447)=None
      Keyz(448)=None
      Keyz(449)=None
      Keyz(450)=None
      Keyz(451)=None
      Keyz(452)=None
      Keyz(453)=None
      Keyz(454)=None
      Keyz(455)=None
      Keyz(456)=None
      Keyz(457)=None
      Keyz(458)=None
      Keyz(459)=None
      Keyz(460)=None
      Keyz(461)=None
      Keyz(462)=None
      Keyz(463)=None
      Keyz(464)=None
      Keyz(465)=None
      Keyz(466)=None
      Keyz(467)=None
      Keyz(468)=None
      Keyz(469)=None
      Keyz(470)=None
      Keyz(471)=None
      Keyz(472)=None
      Keyz(473)=None
      Keyz(474)=None
      Keyz(475)=None
      Keyz(476)=None
      Keyz(477)=None
      Keyz(478)=None
      Keyz(479)=None
      Keyz(480)=None
      Keyz(481)=None
      Keyz(482)=None
      Keyz(483)=None
      Keyz(484)=None
      Keyz(485)=None
      Keyz(486)=None
      Keyz(487)=None
      Keyz(488)=None
      Keyz(489)=None
      Keyz(490)=None
      Keyz(491)=None
      Keyz(492)=None
      Keyz(493)=None
      Keyz(494)=None
      Keyz(495)=None
      Keyz(496)=None
      Keyz(497)=None
      Keyz(498)=None
      Keyz(499)=None
      CP="Konekt!"
      da=None
}
