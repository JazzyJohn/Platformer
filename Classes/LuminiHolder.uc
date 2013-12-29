class LuminiHolder extends PointLightToggleable;


function InitLight(float Time,vector ProjLocation){
        local Float CollisionRadius,CollisionHeight,CollisionSize;
        if(IsTimerActive('Shutdown')){
                   ClearTimer('Shutdown');

        }
        `log("TIME TO OFF"@Time);
        SetTimer(Time,false,'Shutdown');
        Owner.GetBoundingCylinder( CollisionRadius, CollisionHeight) ;
        CollisionSize=FMax(CollisionRadius,CollisionHeight);
        SetLocation(Location+Normal(ProjLocation-Owner.Location)*CollisionSize);
        SetBase(owner);
}

simulated function Shutdown(){
        Destroy();

}


defaultproperties
{
       	bStatic=FALSE
        bNoDelete=false
        bMovable=TRUE
}
