class KillZone extends Volume placeable;
var(GamePlay) bool bInstKill;
var (GamePlay) int DmgDeal;
var (GamePlay) class<DamageType> DamageType;
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{


        local Pawn P;
        local int Damage;
        P = Pawn(Other);
        if(P!=None){
                if(bInstKill){
                        Damage = P.Health*10;
                        P.TakeDamage(Damage,P.Controller,P.Location -Location,vect(0,0,0),DamageType);
                }else{
                
                         P.TakeDamage(DmgDeal,P.Controller,P.Location -Location,vect(0,0,0),DamageType);
                }
        }

}

defaultproperties{


}