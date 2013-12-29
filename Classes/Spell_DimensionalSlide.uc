class Spell_DimensionalSlide extends BaseMagic;


function bool ReadSpell(){

         PlatPawn(Instigator).StatsModifier.AddStatChange(STATNAME_Speed,200,MODTYPE_Addition,self);
             PlatPawn(Instigator).StatsModifier.AddStatChange(STATNAME_Visibility,0,MODTYPE_Assignment,self);
        return true;

}
function EndSpell(){
        PlatPawn(Instigator).StatsModifier.DeleteStatChange(STATNAME_Speed,MODTYPE_Addition,self);
        PlatPawn(Instigator).StatsModifier.DeleteStatChange(STATNAME_Visibility,MODTYPE_Assignment,self);
   
}
defaultproperties
{


}