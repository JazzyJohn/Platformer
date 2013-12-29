class Project_IonisedChain extends PlatProjectails;
var Actor Target;
var float MaxRadius;
var array<Actor> OldTarget;

function Tick(float Deltatime){
        SetRotation(Rotator(Normal(Target.Location-Location)));
        Velocity=Speed*Normal(Target.Location-Location);
        Super.Tick(DeltaTime);
        //`log(Target@Speed);

}
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
      if (Other != Instigator&&Target==Other)
	{

		if (!Other.bStatic && DamageRadius == 0.0)
		{
			Other.TakeDamage(Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		}
		FindTarget();

        }

}
 function FindTarget(){
         local float Distance,NewDistance;
                local Actor IterActor,ClosestActor,OldClosest;

		// Spawn projectile
		Distance=MaxRadius*MaxRadius;
                foreach VisibleActors ( class'Actor', IterActor,MaxRadius,Location ){
                        NewDistance=VSizeSQ(Location -IterActor.Location);

                        if(AiPawn(IterActor)!=None&&Target!=IterActor&&Owner!=IterActor&&self!=IterActor&&NewDistance<=Distance){

                                if(OldTarget.Find(IterActor)==-1){
                                        Distance=NewDistance;
                                        ClosestActor=IterActor;
                                }else{
                                        OldClosest=IterActor;
                                }
                        }

                }

                if(ClosestActor!=None){
                        Target=ClosestActor;

                }
                else{
                        OldTarget.length=0;
                        Target=OldClosest;

                }
                OldTarget[OldTarget.length]=Target;


}

defaultproperties
{
        Begin Object Name=CollisionCylinder
		CollisionRadius=5.0f
		CollisionHeight=5.0f
        End Object
        ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
        speed=600.0
        MaxSpeed=600.0
        Damage=100
        DamageRadius=0
        bCollideWorld=false

}