class AIPawn extends PlatPawn placeable;

var(Pawn) const Name WeaponSocketName;


simulated function PostBeginPlay()
{
    	local int idx;
	Super.PostBeginPlay();

        idx = rand(WeaponsList.length);

        Weapon = Weapon(PlatAIInv(InvManager).CreateInventoryArchetype(WeaponsList[idx]));
        if(ArmorList.length>0){
                idx = rand(ArmorList.length);
                Armor = PlatArmor(PlatAIInv(InvManager).CreateInventoryArchetype(ArmorList[idx]));
        }
    //    `log(Weapon);
	/*SpawnDefaultController();
	if(PlatAIControler(Controller)!=None){
        	GroundSpeed = PlatAIControler(Controller).GroundSpeedUser[0];
         }*/
}
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{       

       Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

}
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

defaultproperties
{
    	InventoryManagerClass=class'PlatAIInv'
        ControllerClass = class'PlatAIControler'

	// Set physics to falling
	Physics=PHYS_Falling

	// Remove the sprite component as it is not needed
	Components.Remove(Sprite)

	// Create a light environment for the pawn






}