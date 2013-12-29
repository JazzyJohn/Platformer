class ExplosiveRevolverProjectails extends PlatProjectails;

defaultproperties
{
    ProjFlightTemplate=	ParticleSystem'PlatformerContent.Weapon.Gun.RevolverSample'
    MaxEffectDistance=1000;
    speed=1000.0
    MaxSpeed=1000.0
    Damage=250.0
    DamageRadius=100.0
    MomentumTransfer=850
    MyDamageType=class'DMGBulletType'
    LifeSpan=8.0
    RotationRate=(Roll=50000)
    bCollideWorld=true


}