class MirageControler extends UDKBot;

function Unpossess(){
        Super.Unpossess();
        Destroy();
}

defaultproperties
{
        bIsPlayer=true;

}
