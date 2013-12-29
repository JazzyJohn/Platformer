class PlatInvMan extends PlatInvManBase         ;
var bool bRightHandPending;
var PlatPlayerPawn PlatInstigator;

var  float NumberOfDuals;
var (Bag) float MaxNumberofDual;
var  float Weight;
var (Bag) float MaxWeight;

var  array <Int> SkeletonSocketsOpen;
var (Bag) editinline MeshComponent BagMesh;
var (GamePlay) archetype PerksManager ArchPerksManager;
var   PerksManager PerksManager;
var (GamePlay) editinline GeneratorManager GenManager;
var (GamePlay) editinline Battery CurBattery;
function SetupFor(Pawn P)
{
        Super.SetupFor(P);
        if(P.Mesh!=None){
                P.Mesh.AttachComponentToSocket(BagMesh,'BackPack');
                BagMesh.SetHidden(true);
        }
        PlatInstigator=PlatPlayerPawn(p);
}
function int GetBatteryCharge(){
       return CurBattery.GetCharge();

}
function int LowerCharge(int Need){
        return CurBattery.LowerCharge(Need);
}
function GiveXP(int Amount, name Perk){
       PerksManager.GiveXP(Amount,Perk);

}
function PostBeginPlay(){
        local SkeletalMeshSocket ArrayItem;
        local PerksTree tree;
        local int Index;
        local SkeletalMesh Skeleton;


        if(SkeletalMeshComponent (BagMesh)!=None&& SkeletalMeshComponent (BagMesh).SkeletalMesh!=None){
              Skeleton =SkeletalMeshComponent (BagMesh).SkeletalMesh;
                foreach		Skeleton.Sockets(ArrayItem,Index)
                {
                    //`log(ArrayItem.SocketName);
                    SkeletonSocketsOpen[Index]=0;

                }
        }
        AttachComponent(BagMesh);
       PerksManager = new Class'PerksManager'(ArchPerksManager);

    
}

/*function OnDestroy(){
        PerksManager.Destroy();
        Super.OnDestroy();
}*/
function FinalAdd(Inventory NewItem, optional bool bDoNotActivate){

                        NewItem.SetOwner( Instigator );
	               	NewItem.Instigator = Instigator;
	               	NewItem.InvManager = Self;
                        NewItem.GivenTo( Instigator, bDoNotActivate);

}
function int Reload(name Ammo, int Amount){
        local Inventory Item;
        local PlatAmmoPack Pack;
    if(InventoryChain!=None){
        for (Item = InventoryChain; Item != None; Item = Item.Inventory)
        {
                Pack=PlatAmmoPack(Item);
                if(Pack!=None){

                        if(Pack.AmmoType==Ammo){
                            `log(Pack.Amount);
                                if(Pack.Amount>Amount){
                                        Pack.Amount-=Amount;
                                        Weight-=Amount*Pack.Weight;
                                        return Amount;
                                }else{
                                        Amount=Pack.Amount;
                                        Pack.Amount=0;
                                        if(Amount>0){
                                               Weight-=Amount*Pack.Weight;
                                                Pack .Destroy();
                                                return Amount;
                                        }else{
                                                return 0;
                                        }

                                }
                        }
                }
        }
    }
    return 0;
}
function ShowInventory(){
    local Inventory Item;

    if(InventoryChain!=None){
        for (Item = InventoryChain; Item != None; Item = Item.Inventory)
        {
               if(PlatInventory(Item)!=None){
                    PlatInventory(Item).Mesh.SetHidden(false);
                }

	}
    }
    // `log("Weight"@Weight);
     BagMesh.SetHidden(false);
     if( PlayerController(Instigator.Controller)!=None){
      //  PlayerController(Instigator.Controller).SetViewTarget(self);
        if(PlatCamera(PlayerController(Instigator.Controller).PlayerCamera)!=None){

                PlatCamera(PlayerController(Instigator.Controller).PlayerCamera).ShowInventory();
        }
     }
}
function HideInventory(){

local Inventory Item;

    if(InventoryChain!=None){
        for (Item = InventoryChain; Item != None; Item = Item.Inventory)
        {
                if(PlatInventory(Item)!=None){
                    PlatInventory(Item).Mesh.SetHidden(true);
                }

	}
    }
     BagMesh.SetHidden(true);
     if( PlayerController(Instigator.Controller)!=None){
      //  PlayerController(Instigator.Controller).SetViewTarget(Instigator);
        if(PlatCamera(PlayerController(Instigator.Controller).PlayerCamera)!=None){
                PlatCamera(PlayerController(Instigator.Controller).PlayerCamera).HideInventory();
        }
     }
}

simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate){

        local PlatWeapon NewWeapon;
        local PlatInventory NewInvItem;
        local Inventory Item, LastItem;

        local int ArrayItem;
        local SkeletalMesh Skeleton;
        local bool bInSlot;
        local int Index;
        local SkeletalMeshComponent SkeletalMeshComponent;
        SkeletalMeshComponent= SkeletalMeshComponent(BagMesh);

        NewWeapon =PlatWeapon(NewItem);
        NewInvItem=PlatInventory(NewItem);

        if(NewWeapon!=None){
                if(NewWeapon.HandType==HT_DUAL&&MaxNumberofDual<= NumberOfDuals){
                        return false;
                }else{
                        if(Weight+ NewWeapon.Weight>MaxWeight){
                                return false;

                        }
                        if( InventoryChain == None )
        		{
	               		InventoryChain = newItem;
        		}
		        else
        		{
	               		// Skip if already in the inventory.
		              	for (Item = InventoryChain; Item != None; Item = Item.Inventory)
        			{

	               			LastItem = Item;
		              	}
        			LastItem.Inventory = NewItem;
	               	}



        		if(PlatInstigator.Weapon==None||(NewWeapon.HandType<HT_DUAL&&PlatInstigator.isRightAvaible())){

                                FinalAdd(NewItem,false);
                        }else{
                                if(NewWeapon.Mesh==None){
                                        FinalAdd(NewItem,false);
                                        return true;
                                }
                                bInSlot =false;
                                
                                
                                

                                foreach SkeletonSocketsOpen(ArrayItem,Index)
                                {
                                        if(ArrayItem==0){
                                                 if(SkeletalMeshComponent (BagMesh)!=None&& SkeletalMeshComponent (BagMesh).SkeletalMesh!=None){
                                                        Skeleton =SkeletalMeshComponent (BagMesh).SkeletalMesh;
                                                        NewWeapon.Mesh.SetScale(NewWeapon.Mesh.Scale *SkeletalMeshComponent.Scale);
                                        	        SkeletalMeshComponent.AttachComponentToSocket(NewWeapon.Mesh, Skeleton.Sockets[Index].SocketName);
                                                }
                                                SkeletonSocketsOpen[Index]= 1;
                                                 bInSlot =true;
                                                break;
                                          }
                                }
                                if(!  bInSlot){
                                         if(LastItem!=None){
                                                 LastItem.Inventory= None;
                                          }
                                         return false;
                                }

                                FinalAdd(NewItem,true);
                        }
                        Weight+=NewWeapon.Weight;

		// Trigger inventory event
	               	Instigator.TriggerEventClass(class'SeqEvent_GetInventory', NewItem);
		        return TRUE;

                }
                return false;

        }
        if(NewInvItem!=None){

                if(Weight+ NewInvItem.Weight*NewInvItem.Amount>MaxWeight){

                        return false;

                }
                if( InventoryChain == None )
		{
			InventoryChain = newItem;
		}
		else
		{
			// Skip if already in the inventory.
			for (Item = InventoryChain; Item != None; Item = Item.Inventory)
			{
				if( Item == NewItem )
				{
                                         PlatInventory(Item).Amount +=NewInvItem.Amount;
                                        Weight+=NewInvItem.Weight*NewInvItem.Amount;

					return FALSE;
				}
				LastItem = Item;
			}
			LastItem.Inventory = NewItem;

		}
		

                foreach SkeletonSocketsOpen(ArrayItem,Index)
                {
                        if(ArrayItem==0){
                                  if(SkeletalMeshComponent (BagMesh)!=None&& SkeletalMeshComponent (BagMesh).SkeletalMesh!=None){
                                                       Skeleton =SkeletalMeshComponent (BagMesh).SkeletalMesh;
                                        	       SkeletalMeshComponent.AttachComponentToSocket(NewInvItem.Mesh, Skeleton.Sockets[Index].SocketName);
                                        	       NewInvItem.Mesh.SetHidden(true);
                                        }
                                 SkeletonSocketsOpen[Index]= 1;
                                 bInSlot =true;
                                 break;
                        }
                }
                if(!  bInSlot){
                        if(LastItem!=None){
                             `log("Bone");
                                LastItem.Inventory= None;
                        }
                         `log("BoneFail");
                        return false;
                }
                Weight+=NewInvItem.Weight*NewInvItem.Amount;
		FinalAdd(NewItem,true);
        }
        return true;

//return Super.AddInventory(NewItem,bDoNotActivate);

}

simulated function ClientWeaponSet(Weapon NewWeapon, bool bOptionalSet, optional bool bDoNotActivate)
{
	local PlatWeapon OldWeapon;
        `log(NewWeapon@"DualORNONE"@Instigator.Weapon@PlatInstigator.SecondWeapon);

	if( !bDoNotActivate )
	{
		OldWeapon = PlatWeapon(Instigator.Weapon);


		// If no current weapon, then set this one
		if( OldWeapon == None || OldWeapon.bDeleteMe || OldWeapon.IsInState('Inactive') ||(OldWeapon.HandType<HT_DUAL&&PlatInstigator.isRightAvaible()))
		{

                        `log("DualORNONE");
			InternalSetCurrentWeapon(NewWeapon);
			return;
		}

		if( OldWeapon == NewWeapon )
		{
			if( NewWeapon.IsInState('PendingClientWeaponSet') )
			{
				`Log("OldWeapon == NewWeapon - but in PendingClientWeaponSet, so reset." @ NewWeapon);
				InternalSetCurrentWeapon(NewWeapon);
			}
			else
			{
				`Log("OldWeapon == NewWeapon - abort" @ NewWeapon);
			}
			return;
		}

		if( bOptionalSet )
		{
			if( OldWeapon.DenyClientWeaponSet() ||
				(Instigator.IsHumanControlled() && PlayerController(Instigator.Controller).bNeverSwitchOnPickup) )
			{
				`Log("bOptionalSet && (DenyClientWeaponSet() || bNeverSwitchOnPickup) - abort" @ NewWeapon);

				LastAttemptedSwitchToWeapon = NewWeapon;
				return;
			}
		}

		if( PendingWeapon == None || !PendingWeapon.HasAnyAmmo() || PendingWeapon.GetWeaponRating() < NewWeapon.GetWeaponRating() )
		{
			// Compare switch priority and decide if we should switch to new weapon
			if( !Instigator.Weapon.HasAnyAmmo() || Instigator.Weapon.GetWeaponRating() < NewWeapon.GetWeaponRating() )
			{
				`Log("Switch to new weapon:" @ NewWeapon);
				InternalSetCurrentWeapon(NewWeapon);
				return;
			}
		}
	}


	NewWeapon.GotoState('Inactive');
}

/**
 * Set DesiredWeapon as Current (Active) Weapon.
 * Network: LocalPlayer
 *
 * @param	DesiredWeapon, Desired weapon to assign to player
 */
reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	// Switch to this weapon
	InternalSetCurrentWeapon(DesiredWeapon);

	// Tell the server we have changed the pending weapon
	if( Role < Role_Authority )
	{
		ServerSetCurrentWeapon(DesiredWeapon);
	}
}

simulated  function InternalSetCurrentWeapon(Weapon DesiredWeapon)
{
	local PlatWeapon PrevWeapon,SecondWeapon,DesWep;

        DesWep =PlatWeapon(DesiredWeapon);
	PrevWeapon = PlatWeapon(Instigator.Weapon);

	SecondWeapon = PlatWeapon(PlatInstigator.SecondWeapon);
	`log("INITIUAL WEAPON========="@PrevWeapon@SecondWeapon@DesWep@DesWep.HandType);
        if(PrevWeapon != None ){
            if(PrevWeapon.HandType==HT_DUAL){
                 PrevWeapon.TryPutdown();
                 bRightHandPending= true;
            }else if(DesWep.HandType==HT_DUAL){
                if(SecondWeapon!=None){
                        SecondWeapon.TryPutdown();
                        `log("OLOLOLOLO");

                        PlatInstigator.SecondWeapon=None;
                }
                PrevWeapon.TryPutdown();
                bRightHandPending= true;

            } else if(DesWep.HandType==HT_ANY||DesWep.HandType==HT_LEFT){
                if(SecondWeapon!=None){
                        SecondWeapon.TryPutdown();
                          `log("OLOLOLOLO");
                        PlatInstigator.SecondWeapon=None;
                }   
                bRightHandPending= false;
            
            }else {
                PrevWeapon.TryPutdown();
                bRightHandPending= true;

            }

        }else{

                if(DesWep.HandType==HT_LEFT){
                        if(SecondWeapon!=None){
                                SecondWeapon.TryPutdown();
                                  `log("OLOLOLOLO");
                                PlatInstigator.SecondWeapon=None;
                        }
                        bRightHandPending=false;
                }else{
                         bRightHandPending=true;
                }

        }
	SetPendingWeapon(DesiredWeapon);
        ChangedWeapon();
       `log("INITIUAL WEAPON========="@Instigator.Weapon@ PlatInstigator.SecondWeapon@DesWep@DesWep.HandType);

}
simulated function ChangedWeapon()
{
	local Weapon OldWeapon;
        `LOG(PendingWeapon);
        if(!bRightHandPending){
                 OldWeapon = PlatInstigator.SecondWeapon;
                 PlatInstigator.SecondWeapon =PendingWeapon;
            }else{
    	       OldWeapon = Instigator.Weapon;
        	// switch to Pending Weapon
               Instigator.Weapon = PendingWeapon;
        }

	// Play any Weapon Switch Animations
	Instigator.PlayWeaponSwitch(OldWeapon, PendingWeapon);



	// If we are going to an actual weapon, activate it.
	if( PendingWeapon != None )
	{
		// Setup the Weapon
		PendingWeapon.Instigator = Instigator;

		// Make some noise
		if( WorldInfo.Game != None )
		{
			Instigator.MakeNoise( 0.1, 'ChangedWeapon' );
		}

		// Activate the Weapon
		PendingWeapon.Activate();
		PendingWeapon = None;
	}

	// Notify of a weapon change
	if( Instigator.Controller != None )
	{
		Instigator.Controller.NotifyChangedWeapon(OldWeapon, Instigator.Weapon);
	}

}
function EndSetingWeapon(){
    bRightHandPending=false;
    PendingWeapon = None;
}

defaultproperties
{
    bRightHandPending= false;
}