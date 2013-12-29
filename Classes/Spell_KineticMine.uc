class Spell_KineticMine extends BaseMagic;
var ()float PowerCoef;
var() float TimeOFLast;
function bool ReadSpell(){
    local vector MousePlace;
     local Projectile	SpawnedProjectile;
    if(PlatControl(Instigator.Controller)!=None){
        MousePlace =PlatControl(Instigator.Controller).GetMouseTarget();

    }
    if(VSize(MousePlace)==0){
        return false;

    }

    SpawnedProjectile = Spawn(WeaponProjectiles[0], Self,, MousePlace);
    if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
    {
	   SpawnedProjectile.Init( Vect(0,0,0) );
    }
       Project_KineticMine(SpawnedProjectile). SetData(RoundedChargeTime*PowerCoef,TimeOFLast);
    DrawDebugSphere(MousePlace,32,20,255,255,255,true);
    return true;
}
defaultproperties
{
         TimeOFLast=10
        WeaponProjectiles(0)= class'Project_KineticMine'
}