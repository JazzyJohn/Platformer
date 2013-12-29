class PlatPawn extends Pawn;
// Dynamic light environment component to help speed up lighting calculations for the pawn
var(Pawn) const DynamicLightEnvironmentComponent LightEnvironment;
var PlatArmor Armor;
var AnimNodeSlot FullBodyAnimSlot;
var (AI) name IdleAnimationName;
var (GamePlay) archetype array<Weapon>  WeaponsList;
var (GamePlay) archetype array<PlatArmor>  ArmorList;
var (AI) int GroundSpeedUser;
var Controller CachedDamager;
var bool bInFly;
var float FallCoef;
//Stats

var PlatStatsModifier StatsModifier;
var bool bVisible;
simulated function PostBeginPlay(){
        StatsModifier=new class'PlatStatsModifier';

}
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
        local int DmgRed;
        local vector ActMomentum;
        DmgRed= 0;

        if(Armor!=None){
                DmgRed =Armor.GetArmorReduction(DamageType);

        }
        Damage+=DmgRed;

        if(Damage<=0){
                return;
        }
         if(ClassIsChildOf(DamageType,class'DMGKineticWave')){
                CachedDamager=InstigatedBy;
                if(Controller==InstigatedBy){
                        RETURN;
                }
                Controller.StopLatentExecution();
                SetPhysics(Phys_Falling);
                Velocity = Vect(0,0,0);
                Momentum =Normal(Location-DamageCauser.Location);
                bInFly=true;
                if(ActMomentum.Z<0.5){
                ActMomentum.Z=0.5;
                ActMomentum=Normal(Momentum);
                }
                Velocity=ActMomentum*Damage*100;
                `log("VELOCITY"@VELOCITY);
        }else{

        Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
        }
}
function  Tick(float DeltaTime){
        GroundSpeed =StatsModifier.CalculateStat(STATNAME_Speed,GroundSpeedUser);
        bVisible =StatsModifier.CalculateStat(STATNAME_Visibility,1)==1;
       

}
event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp ){
        Super.HitWall(  HitNormal,  Wall,  WallComp );
        `log("Wall");
        if(bInFly){
                bInFly=false;
                `log("HITWALL"@VSize(Velocity)*FallCoef);
                TakeDamage(VSize(Velocity)*FallCoef,CachedDamager,Location,vect(0,0,0),class'DmgType_Fell');
        }
}
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    
      `log(SkelComp@Mesh.AnimTreeTemplate);
    if (SkelComp == Mesh)
    {
        FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
        `log(FullBodyAnimSlot);

    }
    Super.PostInitAnimTree(SkelComp);
}
function PlayIdleAnim(){
         FullBodyAnimSlot.PlayCustomAnim(IdleAnimationName,1.0,,,true);
}
function PlayCustomAnim(name Anim){
         FullBodyAnimSlot.PlayCustomAnim(Anim,1.0,,,true);
}
function StopCustomAnim(){
   FullBodyAnimSlot.StopCustomAnim(0.1);
}
//Rotate function Need for Ai Class for spider for example

function RotatePawnTo(rotator DesireRotation){


        SetDesiredRotation(DesireRotation,true,true);
}
defaultproperties
{       
            bCollideWorld=true
                bDirectHitWall= true
        FallCoef= 1
        IdleAnimationName=Taunt_UB_Slit_Throat
        	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment
        // Create a skeletal mesh component for the pawn
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
		LightEnvironment=MyLightEnvironment
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
	GroundSpeedUser=300
}