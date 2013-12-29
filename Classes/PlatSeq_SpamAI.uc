class PlatSeq_SpamAI extends SequenceAction;
var Actor target;
var () archetype Pawn  pawn;
event Activated() {
  if(PlatGame(GetWorldInfo().Game)!=None){
        PlatGame(GetWorldInfo().Game).SpawnAI(pawn,target.Location);
   }
}
defaultproperties
{
ObjName="SpamAI"
ObjCategory="PlatGame"
VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target",PropertyName=target,bWriteable=true)
}