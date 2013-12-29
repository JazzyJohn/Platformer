class PlatWeapon extends SPG_Weapon ClassGroup(Plat);



var(Animations)	array<name>	WeaponAnim;
enum HandTypeENUM{
        HT_ANY,
        HT_LEFT,
        HT_RIGHT,
        HT_DUAL
};
var (Weapon) HandTypeENUM HandType;
var (GamePlay) int MagSize;
var (GamePlay) array<int> FireModeAmmoConsume;
var (GamePlay) name AmmoName;
var (GamePlay) float Weight;
var (GamePlay) archetype array<PlatInventory> ReverseEngeneringPart;
var (Weapon) float RealodTime;
var (GamePlay) bool bEnergy;
function ConsumeAmmo( byte FireModeNum ){
        MagSize-=FireModeAmmoConsume[FireModeNum];
}
state Reloading{
        ignores FireAmmunition;
}
simulated function StartFire(byte FireModeNum){
        FireModeNum=0;
        if(! AmmoCheck()){
                 return;
        }
       
        Super.StartFire(FireModeNum);
}
simulated function StopFire(byte FireModeNum){
        FireModeNum=0;
        Super.StopFire(FireModeNum);
}
function EWeaponFireType GeCurrenttFireTypes(byte FireMode){
 return WeaponFireTypes[FireMode];
}
function bool AmmoCheck(){

if(bEnergy){
         Reload();
         if(MagSize==0){
                return false;
         }
         return true;
}else{
        if(MagSize<0){
                Reload();
                return false;
        }
        return true;

}

}
simulated function FireAmmunition()
{
	// Use ammunition to fire
	ConsumeAmmo( CurrentFireMode );
        if(!AmmoCheck()){

                return;
        }
      switch( GeCurrenttFireTypes(CurrentFireMode)){
		case EWFT_InstantHit:
			InstantFire();
			break;

		case EWFT_Projectile:
			ProjectileFire();
			break;

		case EWFT_Custom:
			CustomFire();
			break;
	}

	NotifyWeaponFired( CurrentFireMode );

}
simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
        if(WeaponAnim.length>FireModeNum){
        PlayWeaponAnimation( WeaponAnim[0], GetFireInterval(FireModeNum) );
        }
        Super.PlayFireEffects(FireModeNum,HitLocation);
}
function int GetMagSize(){
        if(bEnergy){
                return PlatInvMan(PlatPlayerPawn(Owner).InvManager).GetBatteryCharge();
        }else{
         return default.MagSize;
        }
}
function Reload(){
        if(PlatPlayerPawn(Owner)!=None){
            if(bEnergy){
                MagSize =PlatInvMan(PlatPlayerPawn(Owner).InvManager).LowerCharge(default.MagSize);
            }else{
                MagSize =PlatInvMan(PlatPlayerPawn(Owner).InvManager).Reload(AmmoName,default.MagSize);
            }

        }else{
        MagSize=default.MagSize;

        }
        if(RealodTime!=0){
                GoToState('Reloading');
                SetTimer(RealodTime, false, 'CompliteReload');
        }
}

function CompliteReload(){
        if(IsInState('Reloading')){
                  GoToState('Active');
        }
}
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{

     //local vector			StartTrace, EndTrace;
     `log("AiShoot");
     // define range to use for CalcWeaponFire()
     //StartTrace = Instigator.GetWeaponStartTraceLocation();
  //  EndTrace = StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange();


    // DrawDebugLine(StartTrace, EndTrace, 255, 0, 0, TRUE);
     Super.ProcessInstantHit(FiringMode,Impact,NumHits);
}
simulated function rotator AddSpread(rotator BaseAim)
{
        
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;

	CurrentSpread = Spread[CurrentFireMode];
	if(PlatPlayerPawn(Owner)!=None){
                CurrentSpread+=PlatPlayerPawn(Owner).GetSanitySpread();
        }

	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = FRand() - 0.5;
		RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}

}


reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	local PlatPlayerPawn PlayerPawn;
	local AIPawn AIPawn;
        local name SocketName;


	Super.ClientGivenTo(NewOwner, bDoNotActivate);

	// Check that we have a new owner and the new owner has a mesh
	if (NewOwner != None && NewOwner.Mesh != None&&Mesh!=None)
	{
		// Cast the new owner into a SPG_PlayerPawn as we need the weapon socket name
		// If the cast succeeds, we check that the new owner's mesh has a socket by that name
		PlayerPawn = PlatPlayerPawn(NewOwner);
                AIPawn=AIPawn(NewOwner);

		if (PlayerPawn != None){
                    if(PlatInvMan(InvManager)!=None&&!PlatInvMan(InvManager).bRightHandPending){
                          SocketName =PlayerPawn.SecondWeaponSocketName;
                    }else{
                         SocketName =PlayerPawn.WeaponSocketName;
                    }

                    if(NewOwner.Mesh.GetSocketByName(SocketName) != None)
	               	{

			// Set the shadow parent of the weapon mesh to the new owner's skeletal mesh. This prevents doubling up
			// of shadows and also allows improves rendering performance
			Mesh.SetShadowParent(NewOwner.Mesh);
			// Set the light environment of the weapon mesh to the new owner's light environment. This improves
			// rendering performance
			Mesh.SetLightEnvironment(PlayerPawn.LightEnvironment);
			// Attach the weapon mesh to the new owner's skeletal meshes socket
			NewOwner.Mesh.AttachComponentToSocket(Mesh, SocketName);
			PlatInvMan(InvManager).EndSetingWeapon();
	               	}
                }else{
                    if(AIPawn!=None)
                         SocketName =AIPawn.WeaponSocketName;
                     if(NewOwner.Mesh.GetSocketByName(SocketName) != None)
	               	{

			// Set the shadow parent of the weapon mesh to the new owner's skeletal mesh. This prevents doubling up
			// of shadows and also allows improves rendering performance
			Mesh.SetShadowParent(NewOwner.Mesh);
			// Set the light environment of the weapon mesh to the new owner's light environment. This improves
			// rendering performance
			// Attach the weapon mesh to the new owner's skeletal meshes socket
			NewOwner.Mesh.AttachComponentToSocket(Mesh, SocketName);

	               	}
                
                
                }

	}
}
simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, AimDir;

        local Projectile	SpawnedProjectile;

	// tell remote clients that we fired, to trigger effects


	if( Role == ROLE_Authority )
	{


                  //  `log(WeaponSocket);
		// This is where we would start an instant trace. (what CalcWeaponFire uses)

        	StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim (StartTrace ));
		// Spawn projectile

		SpawnedProjectile = Spawn(GetProjectileClass(), Self,, StartTrace);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir );
		}
               // `log(SpawnedProjectile.class);
		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
}
function class<Projectile> GetProjectileClass()
{
	return (CurrentFireMode < Projectiles.length) ? Projectiles[CurrentFireMode] : None;
}



defaultproperties
{

     bEnergy= False
     FiringStatesArray(0)="WeaponFiring"
     WeaponFireTypes(0)=EWFT_Projectile
     InstantHitDamageTypes(0) = class'DMGBulletType'
     FireModeAmmoConsume(0) =1
}