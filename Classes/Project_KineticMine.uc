class Project_KineticMine extends PlatProjectails;


simulated function PostBeginPlay(){

        Super.PostBeginPlay();
}
simulated function SetData(float NewDamage,float Timer){
        Damage=Damage*NewDamage;
        SetTimer(Timer,false,'Explode');
}
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
        Super.ProcessTouch(Other,HitLocation,  HitNormal);
        `log(Other);
}
defaultproperties
{       

	Begin Object  Name=CollisionCylinder
		CollisionRadius=200.0f
		CollisionHeight=50.0f
                collideActors=true
	End Object


        ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
        speed=0.0
        MaxSpeed=0.0
        Damage=10
        bCollideWorld=false
        MyDamageType=class'DMGKineticWave'
        DamageRadius=200.0
}