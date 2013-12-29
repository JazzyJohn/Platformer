class PlatAmountPickUp extends PlatPickUp
placeable;
var (PickUp) int Amount;
function AddParams(Inventory Inv){
        if(Amount!=0&&PlatInventory(Inv)!=None){
                PlatInventory(Inv).Amount=Amount;
        }
}
defaultproperties
{
}