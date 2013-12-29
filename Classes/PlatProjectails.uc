class PlatProjectails extends UDKProjectile;
var ParticleSystem ProjFlightTemplate;
var ParticleSystem ProjExplosionTemplate;
var ParticleSystemComponent	ProjEffects;
var float MaxEffectDistance;
var bool bWaitForEffects;
simulated function PostBeginPlay()
{
    // force ambient sound if not vehicle game mode
      Super.PostBeginPlay();
       SpawnFlightEffects();
}

simulated function SpawnFlightEffects()
{
                ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
		ProjEffects.SetAbsolute(false, false, false);
		ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		ProjEffects.OnSystemFinished = MyOnParticleSystemFinished;
		ProjEffects.bUpdateComponentInTick = true;
		AttachComponent(ProjEffects);

}
event TornOff()
{
	ShutDown();
	Super.TornOff();
}
simulated function Shutdown()
{
	local vector HitLocation, HitNormal;

	bShuttingDown=true;
	HitNormal = normal(Velocity * -1);
	Trace(HitLocation,HitNormal,(Location + (HitNormal*-32)), Location + (HitNormal*32),true,vect(0,0,0));

	SetPhysics(PHYS_None);

	if (ProjEffects!=None)
	{
		ProjEffects.DeactivateSystem();
	}



	HideProjectile();
	SetCollision(false,false);

	// If we have to wait for effects, tweak the death conditions

	if (bWaitForEffects)
	{

		LifeSpan = FMax(LifeSpan, 2.0);

	}
	else
	{
		Destroy();
	}
}
simulated function HideProjectile()
{
	local MeshComponent ComponentIt;
	foreach ComponentList(class'MeshComponent',ComponentIt)
	{
		ComponentIt.SetHidden(true);
	}
}


simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == ProjEffects)
	{
		if (bWaitForEffects)
		{
			if (bShuttingDown)
			{
				// it is not safe to destroy the actor here because other threads are doing stuff, so do it next tick
				LifeSpan = 0.01;
			}
			else
			{
				bWaitForEffects = false;
			}
		}
		// clear component and return to pool
		DetachComponent(ProjEffects);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjEffects);
		ProjEffects = None;
	}
}
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
    local ParticleSystemComponent ProjExplosion;
    if (ProjExplosionTemplate != None && EffectIsRelevant(Location, false, MaxEffectDistance))
	{
                ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(HitNormal), None);

        }


}
simulated function Explode(vector HitLocation, vector HitNormal)
{
        Super.Explode(HitLocation,HitNormal);
        SpawnExplosionEffects(HitLocation,HitNormal);
}
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