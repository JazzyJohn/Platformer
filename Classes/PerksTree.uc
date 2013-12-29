class PerksTree extends Object editinlinenew;

var (GamePlay) editinline Perks PerkRoot;
var (GamePlay) name NameOFTree;
var (GamePlay) bool bStandAlone;
var int XP;
var int Level;
var (GamePlay) Array<int> LevelsXP;


function GiveXP(int Amount){
        XP+=Amount;
        if(LevelsXP[Level]<XP){
                LevelUp();
        }
}
function LevelUp(){
        Level++;
}
defaultproperties{
        Level=0;
        XP=0;
        LevelsXP(0)=100;
}