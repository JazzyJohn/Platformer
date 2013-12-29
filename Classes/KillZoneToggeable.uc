class KillZoneToggeable extends KillZone placeable;
var(GamePlay) bool bActive;

simulated function OnToggle(SeqAct_Toggle Action)
{
    if(Action.InputLinks[0].bHasImpulse)
        {
           bActive = true;
        }
        if(Action.InputLinks[1].bHasImpulse)
        {
                bActive =false;
        }
        if(Action.InputLinks[2].bHasImpulse)
        {
                bActive = !bActive;
        }
        `log(bActive);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{

        if(bActive){
         Super. Touch( Other,  OtherComp,  HitLocation,  HitNormal);

        }



}

defaultproperties{
        bActive =true
        curStep=0
}