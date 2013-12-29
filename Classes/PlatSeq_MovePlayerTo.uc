
class PlatSeq_MovePlayerTo extends SequenceAction;
var  Actor target;

 event Activated() {
        local PlatControl PC;

                PC = PlatControl(GetWorldInfo().GetALocalPlayerController());
        if(PC != none &&target!=None ){
                Pc.MoveToPoint(target);
        }


}
defaultproperties
{
ObjName="MoveTo"
ObjCategory="PlatGame"

VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=target,bWriteable=true)

}