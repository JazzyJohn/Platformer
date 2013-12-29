class Spell_Mirage extends BaseMagic;
var PlatPawn ChachedPawn;
var ()archetype PlatPawn Mirage;
function bool ReadSpell(){
    local vector MousePlace;
    local MirageControler Contr;
    if(PlatControl(Instigator.Controller)!=None){
        MousePlace =PlatControl(Instigator.Controller).GetMouseTarget();

    }
    if(VSize(MousePlace)==0){
        return false;

    }

    ChachedPawn = Spawn(Mirage.class, Self,, MousePlace,,Mirage);

    if(ChachedPawn==None){
         return false;
    }
    Contr= Spawn(class'MirageControler', Self);
    Contr.Possess(ChachedPawn,true);
    return true;
}
function EndSpell(){
        ChachedPawn.Controller.Unpossess();
        ChachedPawn.Destroy();

}


defaultproperties
{

}