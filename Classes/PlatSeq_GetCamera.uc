
class PlatSeq_GetCamera extends SequenceAction;
var Actor target;
var Vector CamOffset;
var Camera PlayerCamera;
 event Activated() {
        local PlayerController PC;

                PC = GetWorldInfo().GetALocalPlayerController();
        if(PC != none  ){
            if(target==None&&PC.Pawn!=None){
               PC.SetViewTargetWithBlend(PC.Pawn,1);
            }else{
                PC.SetViewTargetWithBlend(target,1);
            }
            if(PC.PlayerCamera!=None){
                PlayerCamera=PC.PlayerCamera;
                if(PlatCamera(PC.PlayerCamera)!=None)PlatCamera(PC.PlayerCamera).ChangeOffset(CamOffset);

            }
        }


}
defaultproperties
{
ObjName="GetCamera"
ObjCategory="PlatGame"

VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=target,bWriteable=true)
VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Offset",PropertyName=CamOffset,bWriteable=true)
VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Camera",PropertyName=PlayerCamera,bWriteable=false)
}