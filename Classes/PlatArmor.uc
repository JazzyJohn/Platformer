class PlatArmor extends PlatInventory;
var (GamePlay) int DamageReduction;
var (GamePlay) array< class<DamageType> > DamageTypeExeption;
var (GamePlay) array<int> DamageTypeExeptionValue;
var (GamePlay) SkeletalMesh PlayerMesh;
function float GetArmorReduction(class<DamageType> DmgTypeInflict){
         local int TotalReduction, Index;

           TotalReduction =DamageReduction;
      for (Index = 0; Index < DamageTypeExeption.Length; Index++)
		{
			if (ClassIsChildOf(DmgTypeInflict,DamageTypeExeption[Index]))
			{
                           TotalReduction+= DamageTypeExeptionValue[Index];
                        }
                }


         return TotalReduction;

}
defaultproperties
{

}