class Project_LumenescentWave extends PlatProjectails;
var float TimeOfLumini;
var float TimeOfTravel;

simulated function PostBeginPlay(){
        SetTimer(TimeOfTravel,false,'Shutdown');
        Super.PostBeginPlay();
}
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
        local LuminiHolder Holder;
        foreach Other.ChildActors ( class'LuminiHolder' , Holder){
                Holder.InitLight(TimeOfLumini,Location);
                return;

        }

        Holder =Spawn(class'LuminiHolder',Other,, Other.Location);

        Holder.InitLight(TimeOfLumini,Location);
}


defaultproperties
{
        Begin Object Name=CollisionCylinder
		CollisionRadius=500.0f
		HiddenGame=false
		CollisionHeight=500.0f
        End Object
        TimeOfTravel=10
        ProjFlightTemplate=ParticleSystem'PlatformerContent.Particle.LightWave'
        speed=600.0
        MaxSpeed=600.0
        bCollideWorld=false

}