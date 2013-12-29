class StickMineGun extends PlatWeapon;

var array<Mine> CurrentMines;
var int mineCnt;
var (GamePlay) archetype Mine FiringMine;
function ExplodeMines(){
        local Mine Mine;
        foreach CurrentMines(Mine){
            if(Mine!=None){
                Mine.Explode();
            }
        }
        mineCnt=0;
}
function Reload(){
        ExplodeMines();
        Super.Reload();
}
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
        local Mine NewMine;
                local rotator Newrotation;
	if (Impact.HitActor != None)
	{
		// default damage model is just hits * base damage
		NumHits = Max(NumHits, 1);


		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}




		 DrawDebugLine(Impact.HitLocation,Impact.HitLocation+ Normal(Impact.HitNormal)*100, 255, 0, 0, TRUE);
		 Newrotation =Rotator(Impact.HitNormal);
		 Newrotation.Pitch-=20860;
		NewMine = Spawn(FiringMine.Class, ,,Impact.HitLocation, Newrotation, FiringMine);
		`log(NewMine.rotation);
		NewMine.Placer=Owner;
                CurrentMines[mineCnt]=NewMine;
                mineCnt++;
                NewMine.SetBase(Impact.HitActor);

	}
}
simulated function StartFire(byte FireModeNum){

       if(FireModeNum==1&&mineCnt!=0){
           `log("Boom");
                ExplodeMines();
       }else{
                mineCnt++;
                Super.StartFire(FireModeNum);
       }
}