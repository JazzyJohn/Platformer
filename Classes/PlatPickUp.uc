class PlatPickUp extends PickupFactory
 placeable;
var(PickUp) const archetype Inventory DefaultWeaponArchetype;
var (PickUp) PrimitiveComponent	PickupMeshNew;
var bool bImPickUp;

simulated event PreBeginPlay()
{
InventoryType =DefaultWeaponArchetype.Class;
Super.PreBeginPlay();

}
function AddParams(Inventory Inv);
function SpawnCopyFor( Pawn Recipient )
{
	local Inventory Inv;

	Inv = spawn(InventoryType,None,,,, DefaultWeaponArchetype);
	AddParams(Inv);
	if ( Inv != None )
	{
		Inv.GiveTo(Recipient);

                if(Inv.Owner==None){

                    bImPickUp=false;
                    Inv.Destroy();
                }else{
		Inv.AnnouncePickup(Recipient);
                        bImPickUp= true;
                }
	}
}
function GiveTo( Pawn P )
{
	SpawnCopyFor(P);
	if(bImPickUp){
	       PickedUpBy(P);
        }
}
auto state Pickup
{
    event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{


                 local PlatPlayerPawn P;
   `log("lol");
		// If touched by a player pawn, let him pick this up.
		P = PlatPlayerPawn(Other);

		if( P != None  )
		{
			GiveTo(P);
 		}

        }



}

defaultproperties
{

    Begin Object class=StaticMeshComponent name=HeathItemPickup
StaticMesh=StaticMesh'PlatformerContent.Weapon.Gun.GunPickUp_pCube1' //use your own static mesh at best
bAcceptsLights=true
AlwaysLoadOnClient=true
AlwaysLoadOnServer=true
CollideActors=false
BlockActors=false
Scale=1.0
End Object
PickupMesh=HeathItemPickup
PickupMeshNew=HeathItemPickup;
Components.Add(HeathItemPickup)

DefaultWeaponArchetype= ExplosiveRevolver'PlatformerContent.Weapon.Gun.Gun'



}