class PumpGun extends PlatWeapon ;
var (GamePlay) float PumpTime;
simulated function StartFire(byte FireModeNum){
        PumpTime=0;

        Super.StartFire(FireModeNum);
}

 simulated function FireAmmunition()
{
        if(MagSize<=0){
                 Reload();

                 return;
        }
        if(PumpTime<default.PumpTime){
                return;
        }
        PumpTime=0;
        Super.FireAmmunition();
}

  event Tick(float deltaTime){


        }
state WeaponFiring{

        event Tick(float deltaTime){
                PumpTime+= deltaTime;

        }
}
defaultproperties{

}