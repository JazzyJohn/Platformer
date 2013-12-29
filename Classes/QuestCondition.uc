class QuestCondition extends Object editinlinenew;
var  bool bDone;
var (Quest) int Goal;
var  int Current;

function ChangeGoal(optional int Amount){
        if(Amount==0){
                Goal++;
        }else{
                Goal+= Amount;
        }

}

defaultproperties{

}