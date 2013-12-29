class PlatSeq_GetPlayerStatus extends SequenceAction;
var float Health,Hungry,HungryDelta,Sanity,SanityDelta,Charge;
event Activated() {
        local PlayerController PC;
        local PlatPlayerPawn PlatPlayerPawn;
                PC = GetWorldInfo().GetALocalPlayerController();
        if(PC != none  ){
            PlatPlayerPawn =PlatPlayerPawn(PC.Pawn);
                if(PlatPlayerPawn!=None){
                        if(InputLinks[0].bHasImpulse){
                                Hungry=PlatPlayerPawn.Hungry;
                                HungryDelta=PlatPlayerPawn.HungryChangeRate;
                                Sanity=PlatPlayerPawn.Hungry;
                                SanityDelta=PlatPlayerPawn.SanityChangeRate;
                                 Health=PlatPlayerPawn.Health;
                                 if(PlatInvMan(PlatPlayerPawn.InvManager)!=None){
                                        Charge=PlatInvMan(PlatPlayerPawn.InvManager).GetBatteryCharge();
                                 }
                        }else{
                            if(InputLinks[1].bHasImpulse){
                                PlatPlayerPawn.Health= Health;

                            }
                            if(InputLinks[2].bHasImpulse){
                                PlatPlayerPawn.Hungry= Hungry;

                            }
                             if(InputLinks[3].bHasImpulse){
                                PlatPlayerPawn.HungryChangeRate= HungryDelta;

                            }
                             if(InputLinks[4].bHasImpulse){
                                PlatPlayerPawn.Sanity= Sanity;

                            }
                             if(InputLinks[5].bHasImpulse){
                                PlatPlayerPawn.SanityChangeRate= SanityDelta;
                            
                            }
                             if(InputLinks[6].bHasImpulse){
                                 if(PlatInvMan(PlatPlayerPawn.InvManager)!=None){
                                     PlatInvMan(PlatPlayerPawn.InvManager).LowerCharge(Charge);
                                 }
                            
                            }

                        }
                }
        }


}
defaultproperties
{
ObjName="PlayerInfo"
ObjCategory="PlatGame"
InputLinks(0)=(LinkDesc="Geting")
InputLinks(1)=(LinkDesc="Health")
InputLinks(2)=(LinkDesc="Changing Hungry")
InputLinks(3)=(LinkDesc="Changing HungryDelta")
InputLinks(4)=(LinkDesc="Changing Sanity")
InputLinks(5)=(LinkDesc="Changing SanityDelta")
InputLinks(6)=(LinkDesc="Changing Battery Charge")
VariableLinks(0)=(ExpectedType=class'SeqVar_Float',LinkDesc="Health",PropertyName=Health,bWriteable=true)
VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Hungry",PropertyName=Hungry,bWriteable=true)
VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="HungryDelta",PropertyName=HungryDelta,bWriteable=true)
VariableLinks(3)=(ExpectedType=class'SeqVar_Float',LinkDesc="Sanity",PropertyName=Sanity,bWriteable=true)
VariableLinks(4)=(ExpectedType=class'SeqVar_Float',LinkDesc="SanityDelta",PropertyName=SanityDelta,bWriteable=true)
VariableLinks(5)=(ExpectedType=class'SeqVar_Float',LinkDesc="Battery Charge",PropertyName=Charge,bWriteable=true)
}