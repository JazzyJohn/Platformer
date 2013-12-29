class PlatGame extends SPG_GameInfo;
function SpawnAI(Pawn pawn, vector targetloc){
    Spawn(pawn.Class,,,targetloc,, pawn);
}
event AddDefaultInventory(Pawn P)
{
	local SPG_InventoryManager SPG_InventoryManager;
            
	Super.AddDefaultInventory(P);

	// Ensure that we have a valid default weapon archetype
	if (DefaultWeaponArchetype != None)
	{
		// Get the inventory manager
		SPG_InventoryManager = SPG_InventoryManager(P.InvManager);
		if (SPG_InventoryManager != None)
		{
			// Create the inventory from the archetype
		//	SPG_InventoryManager.CreateInventoryArchetype(DefaultWeaponArchetype, false);
			//SPG_InventoryManager.CreateInventoryArchetype(DefaultWeaponArchetype, false);
		}
	}
}

defaultproperties
{
      HUDType=class'MouseInterfaceHUD'
    
    	DefaultWeaponArchetype=ExplosiveRevolver'PlatformerContent.Weapon.Gun.Gun'
	DefaultPawnArchetype=PlatPlayerPawn'PlatformerContent.Pawns.Player.PlayerPawnStd'
      PlayerControllerClass=class'Platformer.PlatControl'
}