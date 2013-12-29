class PlatSeq_BatteryCharge extends SequenceAction;
var int Charge;
event Activated(){
        local PlayerController PC;
        local PlatPlayerPawn PlatPlayerPawn;
                PC = GetWorldInfo().GetALocalPlayerController();
        if(PC != none  ){
            PlatPlayerPawn =PlatPlayerPawn(PC.Pawn);
                if(PlatPlayerPawn!=None){
                        if(InputLinks[0].bHasImpulse){
                               if(PlatInvMan(PlatPlayerPawn.InvManager)!=None){
                                  Charge=PlatInvMan(PlatPlayerPawn.InvManager).GetBatteryCharge();
                               }
                        }else{
                                  if(InputLinks[1].bHasImpulse){
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
ObjName="BatteryCharge"
ObjCategory="PlatGame"
InputLinks(0)=(LinkDesc="Getting")
InputLinks(1)=(LinkDesc="Lowering")
VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Charge",PropertyName=Charge,bWriteable=true)
}