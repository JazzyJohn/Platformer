class BaseMagic extends PlatWeapon;
var float ChargeTime;
var int RoundedChargeTime;
var () int ManaCostPerSec;
var () bool bCharged;

function bool AmmoCheck(){
        return true;
}

function ConsumeAmmo( byte FireModeNum );


simulated function EndFire(byte FireModeNum)
{
        Super.EndFire(FireModeNum);
        ClearTimer('RefireCheckTimer');
        EndSpell();
        HandleFinishedFiring();
}

simulated function StopFire(byte FireModeNum){
        FireModeNum=0;

        Super.StopFire(FireModeNum);
}
simulated function FireAmmunition()
{

	// Use ammunition to fire
         RoundedChargeTime= Max(1,Round(ChargeTime));
	if(ReadSpell()){
	       if(bCharged){
                        Instigator.TakeDamage(ManaCostPerSec*RoundedChargeTime,Instigator.Controller,Instigator.Location,vect(0,0,0),class'DMGFeedBackType');

                }
        }
        else{
                StopFire(0);
        }

}
function  bool ReadSpell();
function EndSpell();
simulated state WeaponFiring{


        simulated event BeginState( Name PreviousStateName )
	{
		`LogInv("PreviousStateName:" @ PreviousStateName);
        	if(!bCharged){
		      FireAmmunition();
                }
                ChargeTime=0;
		TimeWeaponFiring( CurrentFireMode );
	}

        simulated function RefireCheckTimer()
	{
                // if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			`LogInv("Weapon put down requested during fire, put it down now");
			PutDownWeapon();
			return;
		}

		if(bCharged){
                        ChargeTime+=GetTimerRate('RefireCheckTimer');

                }else{

                        Instigator.TakeDamage(ManaCostPerSec*GetTimerRate('RefireCheckTimer'),Instigator.Controller,Instigator.Location,vect(0,0,0),class'DMGFeedBackType');
                }

                if( !ShouldRefire() )
		{
			HandleFinishedFiring();
			return;
		}


	}
        simulated event EndState( Name NextStateName )
	{
                if(bCharged){

                        FireAmmunition();

                }
                Super.EndState(NextStateName);

        }

}