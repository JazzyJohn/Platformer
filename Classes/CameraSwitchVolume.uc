class CameraSwitchVolume extends Volume placeable;
var (Target) Actor Target;
var (Target) Vector CamOffset;
var (Target) bool bVerticalHold;
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{

        local PlatControl PC;
        local Pawn P;
        P = Pawn(Other);
        if(P!=None){
            PC =PlatControl(P.Controller);
            if(PC!=None){
                if(Target!=None){
                        PC.SetViewTargetWithBlend(Target,1);
                }
                 if(PlatCamera(PC.PlayerCamera)!=None){
                    PlatCamera(PC.PlayerCamera).ChangeOffset(CamOffset,self);
                 }

            }
        }



        Super.Touch(Other,OtherComp,HitLocation,HitNormal);

}
event UnTouch(Actor Other)
{
        local PlatControl PC;
        local Pawn P;
        P = Pawn(Other);
        if(P!=None){
        PC =PlatControl(P.Controller);
            if(PC!=None){
               PC.SetViewTargetWithBlend(P,1);
                 if(PlatCamera(PC.PlayerCamera)!=None){
                    PlatCamera(PC.PlayerCamera).ResetOffset(self);
                 }

        }
        }
      Super.UnTouch(Other);


}

defaultproperties
{

}