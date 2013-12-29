class PlatTurret extends Actor  placeable;
var (GamePlay)int InflictingDamage;

var (Mesh) editinline MeshComponent Mesh;
var (GamePlay)int Health;
var (GamePlay)int Touchness;
var (GamePlay)float Distance;
var (GamePlay)bool bAlwaysSee;
var (GamePlay) float ActivationTime;
var (GamePlay) float FireInterval;
var (GamePlay) class<DamageType>  InflictDamageType;
var (GamePlay) EWeaponFireType FireType;
var (GamePlay)  float  InstantHitMomentum;
var (Mesh) Name Muzzle;
var SeqAct_Interp LvlAnimation;
var Pawn Enemy;
function PostBeginPlay(){
        LvlAnimation =GetAttachedMatinee();
       // `log(LvlAnimation);

}

function SeqAct_Interp GetAttachedMatinee()
{
local Sequence GSeq;
local array<SequenceObject> SeqObjs;
local SequenceObject SeqObj;
local array<SequenceObject> LinkedObjects;
local SequenceObject LinkedObject;

GSeq = WorldInfo.GetGameSequence();

if(GSeq != None)
{
GSeq.FindSeqObjectsByClass(class'SeqAct_Interp', true, SeqObjs);
Foreach SeqObjs(SeqObj)
{
SeqAct_Interp(SeqObj).GetLinkedObjects(LinkedObjects, class'SeqVar_Object', true);
Foreach LinkedObjects(LinkedObject)
{
if (SeqVar_Object(LinkedObject).GetObjectValue() == self)
return SeqAct_Interp(SeqObj);
}
}
}
else
return none;
}




function GetEnemy(){
local PlayerController PC;
        if(Enemy==None){
                PC = WorldInfo.GetALocalPlayerController();
                if(PC!=None){
                        Enemy= PC.Pawn;
                }
        }
}
function TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
        Damage-=Touchness;
        if(Damage<0){
                Damage=1;
        }
        Health-=Damage;
        if(Health<=0){
                GotoState('Dead');
        }
        Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
}
function bool LookForPlayer(){
         local vector Direction,LookDir,AimDir,loc,norm,end;
                local TraceHitInfo hitInfo;
	        local Actor traceHit;
                local vector MuzzleLocation;
                local Rotator MuzzleRotation;
                MuzzleLocation  =GetTurretStartTraceLocation(MuzzleRotation);

                if(Enemy==None){
                        GetEnemy();
                }
                if(Enemy==None){
                        return false;
                }
                Direction=Enemy.Location-MuzzleLocation;
              //  DrawDebugSphere(MuzzleLocation,10,10,255,0,0);
            //    `log(VSizeSq2d(Direction));
                if(VSizeSq2d(Direction)>Distance*Distance){
                        return false;

                }
                //DrawDebugLine( MuzzleLocation+normal(Vector(MuzzleRotation))*1000,  MuzzleLocation, 255, 0, 0 );
               // `loG(normal(Vector(MuzzleRotation)));
                LookDir = Vector(MuzzleRotation);

	        LookDir = Normal(LookDir);
                AimDir = Direction ;

        	AimDir = Normal(AimDir);

                if((LookDir Dot AimDir) < 0.9){
                       return false;
                }
                if(bAlwaysSee){
                        return true;
                }
                else{
                        end = MuzzleLocation + normal(Direction)*Distance; // trace to "infinity"
	               traceHit = trace(loc, norm,end  ,MuzzleLocation, true,, hitInfo);
	             ///   DrawDebugLine(end,  MuzzleLocation, 0, 255, 0);
	               if(traceHit!=None){
                        //`log(traceHit);
                         if(traceHit.IsA('PlatPlayerPawn')){
                             ///  `log("true");
                              return true;
                         }
                        }
                }
                 return false;



}
auto state LookingAround{
    function BeginState(Name PreviousStateName){
       // `log("start");
        LvlAnimation.ForceActivateInput(0);
    }
        event Tick(float DeltaTime){

                if(LookForPlayer()){
                 GotoState('PrepareForAttack');
                }
        
        
        }
   function EndState(Name NextStateName){
        LvlAnimation.ForceActivateInput(3);
    }

}
state AfterAttack{
  event Tick(float DeltaTime){
                if(!LookForPlayer()){
                        ActivationTime-=DeltaTime;
                        if(ActivationTime<=0){
                                GotoState('LookingAround');
                        }
                }else{
                         GotoState('PrepareForAttack');
                }
         }

}
state PrepareForAttack{
        function BeginState(Name PreviousStateName){

        if(PreviousStateName!='PrepareForAttack'){

                ActivationTime=0;
        }

         }
         event Tick(float DeltaTime){
                if(LookForPlayer()){
                        ActivationTime+=DeltaTime;
                        if(ActivationTime>default.ActivationTime){
                                GotoState('Attacking');
                        }
                }else{
                         GotoState('AfterAttack');
                }
         }

}
state Attacking{


         event Tick(float DeltaTime){
             if(LookForPlayer()){

                     if(FireInterval>=default.FireInterval){
                        FireAtPlayer(Enemy);
                        FireInterval=0;
                     }else{
                        FireInterval+=DeltaTime;
                     }
                }else{
                
                         GotoState('AfterAttack');
                }
         }

}
state  Dead{

    
}
function FireAtPlayer(Pawn Target){

        switch(FireType){
                case EWFT_InstantHit:
                        InstantHitProceed();
                break;


        }

}
function vector GetTurretStartTraceLocation(out rotator  HitRotation){

        local vector Start;
          if(SkeletalMeshComponent(Mesh)!=None){

                    if(SkeletalMeshComponent (Mesh).GetSocketWorldLocationAndRotation(Muzzle,Start,HitRotation)){
                                return Start;
                    }
                    
        }
        HitRotation = Rotation;
        return Location;
}
function float GetTraceRange(){
        return Distance;

}

function InstantHitProceed(){

	local vector			StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local int				Idx;
        local ImpactInfo		RealImpact;
        local Rotator ShootRotation;

	// define range to use for CalcWeaponFire()
	StartTrace = GetTurretStartTraceLocation(ShootRotation);
	EndTrace = StartTrace + vector(ShootRotation) * GetTraceRange();
        //DrawDebugLine(StartTrace, EndTrace, 255, 0, 0);

	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);
	SetFlashLocation(RealImpact.HitLocation);
        for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessInstantHit(ImpactList[Idx]);
	}


}
function SetFlashLocation(vector HitLocation){

}
simulated function ProcessInstantHit(ImpactInfo Impact, optional int NumHits)
{
	local int TotalDamage;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if (Impact.HitActor != None)
	{
		// default damage model is just hits * base damage
		NumHits = Max(NumHits, 1);
		TotalDamage = InflictingDamage * NumHits;

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
	//	`log("dmg");
		//`log(Impact.HitActor);
		Impact.HitActor.TakeDamage( TotalDamage, Enemy.Controller,
						Impact.HitLocation, InstantHitMomentum * Impact.RayDir,
					           InflictDamageType, Impact.HitInfo, self );
	}
}

simulated static function bool PassThroughDamage(Actor HitActor)
{
    `log(HitActor);
	return (!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')))
		|| HitActor.IsA('InteractiveFoliageActor');
}
//copy from weapon.uc

simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local vector			HitLocation, HitNormal, Dir;
	local Actor				HitActor;
	local TraceHitInfo		HitInfo;
	local ImpactInfo		CurrentImpact;
	local PortalTeleporter	Portal;
	local float				HitDist;
	local bool				bOldBlockActors, bOldCollideActors;

	// Perform trace to retrieve hit info
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, TRUE, Extent, HitInfo, TRACEFLAG_Bullet);

	// If we didn't hit anything, then set the HitLocation as being the EndTrace location
	if( HitActor == None )
	{
		HitLocation	= EndTrace;
	}

	// Convert Trace Information to ImpactInfo type.
	CurrentImpact.HitActor		= HitActor;
	CurrentImpact.HitLocation	= HitLocation;
	CurrentImpact.HitNormal		= HitNormal;
	CurrentImpact.RayDir		= Normal(EndTrace-StartTrace);
	CurrentImpact.StartTrace	= StartTrace;
	CurrentImpact.HitInfo		= HitInfo;

	// Add this hit to the ImpactList
	ImpactList[ImpactList.Length] = CurrentImpact;

	// check to see if we've hit a trigger.
	// In this case, we want to add this actor to the list so we can give it damage, and then continue tracing through.
	if( HitActor != None )
	{
		if (PassThroughDamage(HitActor))
		{
			// disable collision temporarily for the actor we can pass-through
			HitActor.bProjTarget = false;
			bOldCollideActors = HitActor.bCollideActors;
			bOldBlockActors = HitActor.bBlockActors;
			if (HitActor.IsA('Pawn'))
			{
				// For pawns, we need to disable bCollideActors as well
				HitActor.SetCollision(false, false);

				// recurse another trace
				CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}
			else
			{
				if( bOldBlockActors )
				{
					HitActor.SetCollision(bOldCollideActors, false);
				}
				// recurse another trace and override CurrentImpact
				CurrentImpact = CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}

			// and reenable collision for the trigger
			HitActor.bProjTarget = true;
			HitActor.SetCollision(bOldCollideActors, bOldBlockActors);
		}
		else
		{
			// if we hit a PortalTeleporter, recurse through
			Portal = PortalTeleporter(HitActor);
			if( Portal != None && Portal.SisterPortal != None )
			{
				Dir = EndTrace - StartTrace;
				HitDist = VSize(HitLocation - StartTrace);
				// calculate new start and end points on the other side of the portal
				StartTrace = Portal.TransformHitLocation(HitLocation);
				EndTrace = StartTrace + Portal.TransformVectorDir(Normal(Dir) * (VSize(Dir) - HitDist));
				//@note: intentionally ignoring return value so our hit of the portal is used for effects
				//@todo: need to figure out how to replicate that there should be effects on the other side as well
				CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
			}
		}
	}

	return CurrentImpact;
}



defaultproperties
{
        Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+003.000000
		CollisionHeight=+007.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder
        Components.Add(CollisionCylinder)

	bCollideActors=true
        bBlockActors=true
	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		Scale=1.f
		bAllowAmbientOcclusion=false
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
	End Object
	Mesh=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent)
        InflictingDamage=10
        Health=100
        Physics=PHYS_Interpolating
}