class BeamGun extends PlatWeapon;
var(Weapon) const ParticleSystemComponent BeamPart;
var (Weapon) array<int> InstatnHitMaxDmg;
var (Weapon) int MaxBeamTime;
var vector BeamLocation;
var float SecShoot;
var float TimeFromLastReload;
var float TimeFromLastDamadge;
simulated event PostBeginPlay()
{
	local SkeletalMeshComponent SkeletalMeshComponent;

	Super.PostBeginPlay();

	if (BeamPart != None)
	{
		SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
		if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(MuzzleSocketName) != None)
		{
			SkeletalMeshComponent.AttachComponentToSocket(BeamPart, MuzzleSocketName);




		}
	}
	Super.PostBeginPlay();
}

simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{

	local SkeletalMeshComponent SkeletalMeshComponent;
        local rotator BeamRot;
        local float distance;
        local vector NewLocation;

	if (BeamPart != None)
	{
		// Activate the muzzle flash
		BeamPart.ActivateSystem();

			SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
			SkeletalMeshComponent.GetSocketWorldLocationAndRotation(MuzzleSocketName, BeamLocation, BeamRot, 0 );
			///	`log(HitLocation-BeamLocation);
			NewLocation =vect(0,14000,0);
        	if(VSize(HitLocation)!=0){
                    distance = VSize(HitLocation-BeamLocation);

	              NewLocation.Y =distance;
                }else{

                }
                BeamPart.SetVectorParameter('Target',NewLocation);
	}
        Super.PlayFireEffects(FireModeNum,HitLocation);
}
state WeaponFiring{

        ignores FireAmmunition;
        event Tick(float deltaTime){
                SecShoot+= deltaTime;
                TimeFromLastReload+=deltaTime;
                TimeFromLastDamadge+=deltaTime;
                if(TimeFromLastReload>=FireInterval[CurrentFireMode]){
                        TimeFromLastReload =0;
                        ConsumeAmmo( CurrentFireMode );
                         if(!AmmoCheck()){

                              return;
                        }   
                }
                if(TimeFromLastDamadge>=FireInterval[CurrentFireMode]){
                       	InstantFire();

                }
        }

}
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{

local int TotalDamage;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
local vector			StartTrace, EndTrace;
local float coef;
     // define range to use for CalcWeaponFire()
     StartTrace = Instigator.GetWeaponStartTraceLocation();
    EndTrace = StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange();


     DrawDebugLine(StartTrace, EndTrace, 255, 0, 0, TRUE);
	if (Impact.HitActor != None)
	{
		// default damage model is just hits * base damage
                coef = SecShoot/MaxBeamTime;
                if(coef>1){
                        coef=1;
                }
		TotalDamage = lerp(InstantHitDamage[CurrentFireMode],InstatnHitMaxDmg[CurrentFireMode],coef);
                //`log(InstatnHitMaxDmg[CurrentFireMode]);
               // `log(coef);
                //`log(TotalDamage);
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
		Impact.HitActor.TakeDamage( TotalDamage, Instigator.Controller,
						Impact.HitLocation, InstantHitMomentum[FiringMode] * Impact.RayDir,
						InstantHitDamageTypes[FiringMode], Impact.HitInfo, self );
        	TimeFromLastDamadge=0;
	}


}
simulated function StopFireEffects(byte FireModeNum)
{

	if (BeamPart != None)
	{
		// Deactivate the muzzle flash
		BeamPart.DeactivateSystem();
	}
	Super.StopFireEffects(FireModeNum);
}
simulated function StartFire(byte FireModeNum){
    SecShoot=0;
    TimeFromLastReload=0;
    Super.StartFire(FireModeNum);
       
}
defaultproperties
{

        FireModeAmmoConsume(0) =1
        MaxBeamTime =100
}
