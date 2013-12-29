class Spell_LumenescentWave extends BaseMagic;
var () int LuminiKoef;

function  bool ReadSpell(){
                local vector		StartTrace, AimDir;

                 local Projectile	SpawnedProjectile;

           	StartTrace = Instigator.GetWeaponStartTraceLocation();
		AimDir = Vector(GetAdjustedAim (StartTrace ));
		// Spawn projectile

		SpawnedProjectile = Spawn(WeaponProjectiles[0], Self,, StartTrace);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			SpawnedProjectile.Init( AimDir );
		}
            
		// Return it up the line

		Project_LumenescentWave(SpawnedProjectile).TimeOfLumini =RoundedChargeTime*LuminiKoef;
                return true;
}

defaultproperties
{
        bCharged=true
        ManaCostPerSec=2
        LuminiKoef=5
        WeaponProjectiles(0)= class'Project_LumenescentWave'

}