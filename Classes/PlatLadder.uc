class PlatLadder extends PhysicsVolume
placeable;
var (Target) array<Actor> LaderPoint;
var (Target) array<Actor> LaderExit;
var (Target) bool bEnable;
simulated function OnToggle(SeqAct_Toggle Action)
{
    if(Action.InputLinks[0].bHasImpulse)
        {
           bEnable = true;
        }
        if(Action.InputLinks[1].bHasImpulse)
        {
                bEnable =false;
        }
        if(Action.InputLinks[2].bHasImpulse)
        {
                bEnable = !bEnable;
        }
}

simulated event PawnEnteredVolume(Pawn P)
{

 `log( P);


	if ( !P.CanGrabLadder() )
		return;


	else if ( !P.bDeleteMe && (P.Controller != None)&& 	PlatControl(P.Controller)!=None){
                
		PlatControl(P.Controller).CanUse(self);

         }

         Super.PawnEnteredVolume(P);
}
simulated event PawnLeavingVolume(Pawn P)
{



	 if ( !P.bDeleteMe && (P.Controller != None) && 	PlatControl(P.Controller)!=None){

	       PlatControl(P.Controller).CancelUse(self);

         }

         Super.PawnEnteredVolume(P);
}
function Actor GetClosest(Actor pawn){
        local Actor Actor;
        local float Destanation;
        local int Index,MinIndex;
        Destanation=-1;
         foreach LaderPoint(Actor,Index){
                if(VSizeSq(Actor.Location-Pawn.Location)<Destanation||Destanation==-1){
                    Destanation=VSizeSq(Actor.Location-Pawn.Location);
                        MinIndex=Index;
                }

         }
         return LaderPoint[MinIndex];
}
function Actor GetFarest(Actor pawn){
        local Actor Actor;
        local float Destanation;
        local int Index,MinIndex;
        Destanation=-1;
         foreach LaderPoint(Actor,Index){
                if(VSizeSq(Actor.Location-Pawn.Location)>Destanation||Destanation==-1){
                    Destanation=VSizeSq(Actor.Location-Pawn.Location);
                        MinIndex=Index;
                }

         }
         return LaderPoint[MinIndex];
}
function Actor GetClosestExit(Actor pawn){
        local Actor Actor;
        local float Destanation;
        local int Index,MinIndex;
        Destanation=-1;
         foreach LaderExit(Actor,Index){


                if(VSizeSq(Actor.Location-Pawn.Location)<Destanation||Destanation==-1){
                      Destanation=VSizeSq(Actor.Location-Pawn.Location);
                        MinIndex=Index;
                }

         }
         return LaderExit[MinIndex];
}
defaultproperties
{

}