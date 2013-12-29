class Battery  extends StaticMeshComponent editinlinenew;

var (GamePlay) int Charge;
function int GetCharge(){
        return Charge;

}

function int LowerCharge(int Need){
        if(Need>Charge){
                return 0;
        }
        Charge-=Need;
        return Need;

}
defaultproperties
{
        Charge=100;

}