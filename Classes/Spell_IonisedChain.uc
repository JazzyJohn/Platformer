class Spell_IonisedChain extends BaseMagic;


var () int LuminiKoef;
var () Project_IonisedChain ChachedProj;
var () float MaxRadius;
function  bool ReadSpell(){
                local vector		StartTrace, AimDir;
                local float Distance,NewDistance;
                local Actor IterActor,ClosestActor;
           	StartTrace = Instigator.GetWeaponStartTraceLocation();

		// Spawn projectile
		Distance=MaxRadius*MaxRadius;
                foreach Instigator.VisibleActors ( class'Actor', IterActor,MaxRadius,StartTrace ){
                        NewDistance=VSizeSQ(StartTrace -IterActor.Location);
                        if(AiPawn(IterActor)!=None&&Instigator!=IterActor&&NewDistance<=Distance){
                                Distance=NewDistance;
                                ClosestActor=IterActor;
                        }

                }
                if(ClosestActor==None){
                        return false;
                }
                AimDir=Normal(ClosestActor.Location-StartTrace);

		ChachedProj = Project_IonisedChain(Spawn(WeaponProjectiles[0], Instigator,, StartTrace));

		if( ChachedProj != None && !ChachedProj.bDeleteMe )
		{
			ChachedProj.Init( AimDir );
		}

                ChachedProj.Target =ClosestActor;
                ChachedProj.MaxRadius =MaxRadius;
                return true;

}
function EndSpell(){
        ChachedProj.ShutDown();

}
defaultproperties
{
        bCharged=false
        ManaCostPerSec=10
        MaxRadius=1000
        WeaponProjectiles(0)= class'Project_IonisedChain'
        

}