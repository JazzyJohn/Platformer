class ExplosiveRevolver extends PlatWeapon;
var (Weapon)ParticleSystem ProjExplosionTemplate;

simulated function Projectile ProjectileFire()
{

    local Projectile proj;

    proj =Super.ProjectileFire();

         ExplosiveRevolverProjectails(proj).ProjExplosionTemplate =ProjExplosionTemplate;

    return proj;
}
function EWeaponFireType GeCurrenttFireTypes(byte FireMode){
    if(MagSize==0){
        return EWFT_Projectile;
    }else{

 return WeaponFireTypes[FireMode];

    }
}


defaultproperties
{

       
        ProjExplosionTemplate =ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
        MagSize =6;

}
