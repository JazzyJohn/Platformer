class PlatPlayerPawn extends PlatPawn;
var() const archetype InventoryManager DefaultInventoryManager;

var Weapon SecondWeapon;
var(Pawn) const Name SecondWeaponSocketName;
var float Hungry;
var float HpHungryMod;
var float HungryChangeRate;
var float HungryThreshold;
var float DeltaForHealth;
var float Sanity;
var float SanitySpreadMod;
var float SanityThreshold;
var float SanityChangeRate;
var int Level;
var int EXP;
var float InLight;
var (Pawn)array<int> LevelXP;


// How fast a pawn turns
var(Pawn) const float TurnRate;
// How high the pawn jumps
var(Pawn) const float JumpHeight;
// Socket to use for attaching weapons
var(Pawn) const Name WeaponSocketName;
// Height to set the collision cylinder when crouching


// Reference to the aim node aim offset node
var AnimNodeAimOffset AimNode;
// Reference to the gun recoil skel controller node
var GameSkelCtrl_Recoil GunRecoilNode;
// Internal int which stores the desired yaw of the pawn
var int DesiredYaw;
// Internal int which store the current yaw of the pawn
var int CurrentYaw;
// Internal int which stores the current pitch of the pawn
var int CurrentPitch;


simulated event PostBeginPlay()
{
    local int i;
    InvManager = Spawn(InventoryManagerClass, Self,,,,DefaultInventoryManager);
    InvManager.SetupFor( Self );
    	// Set the desired and current yaw to the same as what the pawn spawned in
	DesiredYaw = Rotation.Yaw;
	CurrentYaw = Rotation.Yaw;


    super.PostBeginPlay();
      `log("Inventory@@@@@@@"@InvManager);
    for(i=0;i<WeaponsList.length;i++){
        PlatInvMan(InvManager).CreateInventoryArchetype(WeaponsList[i]);
    }


}



function GiveXP(int amount, optional name Perks=''){
        EXP+=amount;
        LvlCheck();
        if(Perks!=''){
              PlatInvMan(InvManager).GiveXP(amount,Perks);
        }
}
function LvlCheck(){
        if(LevelXP[Level]<=Exp){
                LevelUp();
        }
}
function LevelUp(){
        Level++;

}
function Tick(float DeltaTime){
        Hungry+=HungryChangeRate*DeltaTime;
        if(Hungry<0){
                Hungry=0;
        }
        if(Hungry>default.Hungry){
                Hungry=default.Hungry;
        }
        Sanity+=SanityChangeRate*DeltaTime;
        if(Sanity<0){
                Sanity=0;
        }
        if(Sanity>default.Sanity){
                Sanity=default.Sanity;
        }
        if(Hungry<=HungryThreshold){
                DeltaForHealth-=HpHungryMod*DeltaTime;
        }
        if(DeltaForHealth<=-1){
                Health -=1;
                DeltaForHealth=0;
        }
        Super.Tick(DeltaTime);
         `log(GroundSpeed@bVisible@SecondWeapon);
}

function float GetSanitySpread(){
        if(SanityThreshold>Sanity){
              return SanitySpreadMod*(SanityThreshold-Sanity);
        }
        return 0;
}


function bool isRightAvaible(){
  if(SecondWeapon==None&& PlatWeapon(Weapon)!=None&& PlatWeapon(Weapon).HandType<HT_DUAL){
        return true;
  }
  return false;
}
simulated function StartFire(byte FireModeNum)
{
	if( bNoWeaponFIring )
	{
		return;
	}
	`log(Weapon@SecondWeapon@Weapon.GetStateName()@SecondWeapon.GetStateName());

	if( SecondWeapon!=None ){
        	switch(FireModeNum)
        	{
                        case 0:
                               if( Weapon != None )
	                       {

                        	       Weapon.StartFire(0);
                                }else  {
                                    SecondWeapon.StartFire(0);
                                }


                        break;
                        case 1:
                                if(SecondWeapon!=None){

                                        SecondWeapon.StartFire(0);
                                }

                        break;
                }

	}else{
                  if(Weapon!=None){
`log(FireModeNum);
                        Weapon.StartFire(FireModeNum);

                      
                  }
        
        }
}
simulated function StopFire(byte FireModeNum)
{
	if( SecondWeapon!=None ){
        	switch(FireModeNum)
        	{
                        case 0:
                               if( Weapon != None )
	                       {

                        	       Weapon.StopFire(0);
                                }else  {
                                    SecondWeapon.StartFire(0);
                                }

                        break;
                        case 1:
                                if(SecondWeapon!=None){

                                        SecondWeapon.StopFire(0);
                                }

                        break;
                }

	}else{
                  if(Weapon!=None){

                        Weapon.StopFire(FireModeNum);

                      
                  }
        
        }
}

simulated function FaceRotation(Rotator NewRotation, float DeltaTime)
{
	local Rotator FacingRotation;

	// Set the desired yaw the new rotation yaw
	if (NewRotation.Yaw != 0)
	{
		DesiredYaw = NewRotation.Yaw;

	}

	// If the current yaw doesn't match the desired yaw, then interpolate towards it
	if (CurrentYaw != DesiredYaw)
	{
		CurrentYaw = Lerp(CurrentYaw, DesiredYaw, TurnRate * DeltaTime);
	}

	// If we have a valid aim offset node
	if (AimNode != None)
	{
		// Clamp the current pitch to the view pitch min and view pitch max
		if(NewRotation.Pitch<0){
                        NewRotation.Pitch=NewRotation.Pitch;
                }else{
                         NewRotation.Pitch=NewRotation.Pitch;
                }

		CurrentPitch = Clamp(NewRotation.Pitch, ViewPitchMin, ViewPitchMax);

		if (CurrentPitch > 0.f)
		{
			// Handle when we're aiming up
			AimNode.Aim.Y = float(CurrentPitch) / ViewPitchMax;
		}
		else if (CurrentPitch < 0.f)
		{
			// Handle when we're aiming down
			AimNode.Aim.Y = float(CurrentPitch) / ViewPitchMin;

			if (AimNode.Aim.Y > 0.f)
			{
				AimNode.Aim.Y *= -1.f;
			}
		}
		else
		{
			// Handle when we're aiming straight forward
			AimNode.Aim.Y = 0.f;
		}
	}


	// Update the facing rotation
	FacingRotation.Pitch = 0;
	FacingRotation.Yaw = CurrentYaw;
	FacingRotation.Roll = 0;

	SetRotation(FacingRotation);
}


/**
 * Destructor which always gets called when the pawn is destroyed. This is useful for cleaning up any
 * object reference we may have
 *
 * @network				Server and client
 */
simulated event Destroyed()
{
	Super.Destroyed();

	AimNode = None;
	GunRecoilNode = None;
}

/**
 * Called when the actor has finished initializing a skeletal mesh component's anim tree. This is usually a good
 * place to start grabbing anim nodes or skeletal controllers
 *
 * @param	SkelComp	Skeletal mesh component that has had its anim tree initialized.
 * @network				Server and client
 */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	if (SkelComp == Mesh)
	{
		// Find the aim offset node
		AimNode = AnimNodeAimOffset(Mesh.FindAnimNode('AimNode'));
		// Find the gun recoil skeletal control node
		GunRecoilNode = GameSkelCtrl_Recoil(Mesh.FindSkelControl('GunRecoilNode'));
	}
}

/**
 * Adjusts weapon aiming direction.
 * Gives Pawn a chance to modify its aiming. For example aim error, auto aiming, adhesion, AI help...
 * Requested by weapon prior to firing.
 *
 * @param	W				Weapon about to fire
 * @param	StartFireLoc	World location of weapon fire start trace, or projectile spawn loc.
 * @return					Rotation to fire from
 * @network					Server and client
 */
simulated function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local SPG_Weapon SPG_Weapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	SPG_Weapon = SPG_Weapon(Weapon);
	if (SPG_Weapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(SPG_Weapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(SPG_Weapon.MuzzleSocketName) != None)
		{			
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(SPG_Weapon.MuzzleSocketName, SocketLocation, SocketRotation);
			return SocketRotation;
		}
	}

	return Rotation;
}

/**
 * Return world location to start a weapon fire trace from.
 *
 * @param	CurrentWeapon		Weapon about to fire
 * @return						World location where to start weapon fire traces from
 * @network						Server and client
 */
simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local SPG_Weapon SPG_Weapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	SPG_Weapon = SPG_Weapon(Weapon);
	if (SPG_Weapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(SPG_Weapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(SPG_Weapon.MuzzleSocketName) != None)
		{
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(SPG_Weapon.MuzzleSocketName, SocketLocation, SocketRotation);
			return SocketLocation;
		}
	}

	return Location;
}



/**
 * Appends to the Z velocity when the pawn wants to jump.
 *
 * @param	bUpdating	True if updating
 * @network			Server
 */
function bool DoJump(bool bUpdating)
{
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
 	{
		if (Physics == PHYS_Spider)
		{
			Velocity = JumpHeight * Floor;
		}
		else if (Physics == PHYS_Ladder)
		{

			Velocity.Z = 0.f;
		}
		else
		{
			Velocity.Z = JumpHeight;
		}

		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			Velocity.Z += Base.Velocity.Z;
		}

		SetPhysics(PHYS_Falling);
		return true;
	}

	return false;
}
defaultproperties
{

    	InventoryManagerClass=class'PlatInvMan'

        Hungry=100
        HpHungryMod=1
        HungryChangeRate=-0.1
        HungryThreshold=0
        Sanity=100
        SanitySpreadMod=1
        SanityThreshold=50
        SanityChangeRate=0
        Level=0
        EXP=0
        LevelXP(0)=100
        InLight=0.5
        /* Begin Object class=StaticMeshComponent Name=TheMesh
		StaticMesh = StaticMesh'PlatformerDecoration.SimpelBox.Box'
		HiddenGame=True
		HiddenEditor=False
		Scale=1
	End Object
	Components.Add(TheMesh)
	CollisionComponent=TheMesh*/
	// Remove the sprite component as it is not needed
	Components.Remove(Sprite)




	bCanClimbLadders = true
	JumpHeight=520.f
	AirControl=+0.5
        MaxFallSpeed=+2400.0
        CrouchedPct=+0.4
        CrouchHeight=45.0
        CrouchRadius=25.0
        bCanCrouch=true
      
        GroundSpeedUser=600

        bBlockActors= false
	bCanPickupInventory=true
}

