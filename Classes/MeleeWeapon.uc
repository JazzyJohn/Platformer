class MeleeWeapon extends PlatWeapon;
var bool bWasHit;
var array<name> WeaponModeAnim;
simulated state WeaponFiring{

        simulated function Tick(float Delta){
                local Actor HitActor;
                local Rotator  FireRotation;
                local vector FireLocation,HitNormal,HitLocation;
                Super.Tick(Delta);
                if(CurrentFireMode>=InstantHitDamageTypes.Length){
                        return;
                }
               //`log(CurrentFireMode);
                if(!bWasHit){
                


                        SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation(MuzzleSocketName,FireLocation,FireRotation);
                        DrawDebugLine(FireLocation+Vector(FireRotation)*50, FireLocation, 255,0,255,true);
        	        ForEach instigator.TraceActors(class'Actor', HitActor, HitLocation, HitNormal, FireLocation+Vector(FireRotation)*WeaponRange,FireLocation)
                        {
                                 if (!HitActor.bStatic){
        		      	       HitActor.TakeDamage(InstantHitDamage[CurrentFireMode], instigator.Controller, HitLocation, HitNormal, InstantHitDamageTypes[CurrentFireMode],, self);
        		      	       //For Derived classes function
        		      	       AfterDamageEvent(HitActor);
        		      	       bWasHit= true;
        		      	               //`log("HIT");
                                }


                        }
                }

        }
        simulated function RefireCheckTimer()
	{
                //`log("NEWFIRE");
                bWasHit= false;

                Super.RefireCheckTimer();
	}
        simulated event EndState( Name NextStateName )
	{
                Super.EndState(NextStateName);
                PlatPawn(Instigator).StopCustomAnim();
                bWasHit= false;
        }
        simulated event BeginState( Name PreviousStateName )
	{
                PlatPawn(Instigator).PlayCustomAnim(WeaponModeAnim[CurrentFireMode]);
                Super.BeginState(PreviousStateName );
        }

}
simulated function AfterDamageEvent(Actor Victom);


defaultproperties
{
         bMeleeWeapon= true
        bWasHit=false
        WeaponRange=150
        WeaponFireTypes(0)=EWFT_Custom
        FiringStatesArray(0)=WeaponFiring
        InstantHitDamageTypes(0)=PlatMeleeDMG

}