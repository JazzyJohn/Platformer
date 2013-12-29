class Mine extends Actor placeable;
var (GamePlay)int Damage;
var (GamePlay) int AreaDamage;
var Actor Placer;
var (Mesh)MeshComponent Mesh;
var ParticleSystem ProjExplosionTemplate;
var ParticleSystemComponent ProjExplosion;
var bool bWaitForEffects;
var bool bExplode;
var float MaxEffectDistance;
function Explode(){
        local Pawn Touch;
        if(bExplode){
                return;
        }
        SpawnFlightEffects();
        bExplode=true;
        if(Pawn(Placer)!=None){
               Base.TakeDamage(Damage,Pawn(Placer).Controller,Base.Location -Location,vect(0,0,0),class'DMGBulletType');
                foreach TouchingActors(class'Pawn', Touch){

             Touch.TakeDamage(AreaDamage,Pawn(Placer).Controller,Touch.Location -Location,vect(0,0,0),class'DMGBulletType');
          }
       }


}

event Tick(float delta){

}
simulated function SpawnFlightEffects()
{

      Mesh.SetHidden(true);

    if (ProjExplosionTemplate != None && EffectIsRelevant(Location, false, MaxEffectDistance))
	{
                ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, Location, Rotation, None);
               	ProjExplosion.OnSystemFinished = MyOnParticleSystemFinished;
               	AttachComponent(ProjExplosion);

                bWaitForEffects= true;
        }

}

simulated function MyOnParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == ProjExplosion)
	{


		LifeSpan = 0.01;
		// clear component and return to pool
		DetachComponent(ProjExplosion);
		WorldInfo.MyEmitterPool.OnParticleSystemFinished(ProjExplosion);
		ProjExplosion = None;
	}
}
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal){
 `log(Other);
}

defaultproperties
{
        bExplode = false
       MaxEffectDistance=1000
       Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=+00250.000000
		CollisionHeight=+00200.000000
		CollideActors=true
        	BlockActors=false
      	End Object
	CollisionComponent=CollisionCylinder
        Components.Add(CollisionCylinder)
	bCollideActors=true
        bBlockActors=false
        Begin Object class=StaticMeshComponent name=MineMesh
        StaticMesh=StaticMesh'PlatformerContent.Weapon.Gun.GunPickUp_pCube1' //use your own static mesh at best
        bAcceptsLights=true
        AlwaysLoadOnClient=true
        AlwaysLoadOnServer=true
        Scale=1.0
        End Object
        Mesh=MineMesh
        Components.Add(MineMesh)
        Damage=10
        ProjExplosionTemplate =ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'

}