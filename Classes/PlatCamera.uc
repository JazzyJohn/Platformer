class PlatCamera extends SPG_Camera;
var vector DirectorOffset;
var vector DesireDirectorOffset;
var vector ForwardOffset;
var vector InventoryOffset;
var Rotator TempRotator;
var bool bInvMode;
var bool bForward;
var CameraSwitchVolume VolumeThatEffect;
function ChangeOffset(vector NewOffset,optional CameraSwitchVolume Volume){

        DesireDirectorOffset=NewOffset;
        VolumeThatEffect=Volume;
       // `log(DesireDirectorOffset);

}
function ResetOffset(optional CameraSwitchVolume Volume){
    if(Volume ==VolumeThatEffect){
       DesireDirectorOffset =default.DirectorOffset ;
       VolumeThatEffect =None;
    }

}
function ShowInventory(){
        local Vector NewPos;
        bInvMode=true;

        if(PlatCameraProperties(CameraProperties)!=None){
               // `log(TempRotator.Yaw);
                NewPos =PlatCameraProperties(CameraProperties).InventoryOffset;
                if(TempRotator.Yaw>0){
                       NewPos.Y= -NewPos.Y;
                }

                  DesireDirectorOffset=NewPos-CameraProperties.CameraOffset;
        }
        else{
                DesireDirectorOffset=Vect(0,0,300)-CameraProperties.CameraOffset;
        }
}
function HideInventory(){
        bInvMode=false;
        DesireDirectorOffset =default.DirectorOffset ;
}
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{

        local vector TempLocation,TotalOffset;
	// Early exit if:
	// - We have a pending view target
	// - OutVT currently equals ViewTarget
	// - Blending parameter is lock out going
	TotalOffset=DesireDirectorOffset +ForwardOffset;
	if(DirectorOffset!=TotalOffset){
                DirectorOffset.X= Lerp(DirectorOffset.X,TotalOffset.X,DeltaTime);
                 DirectorOffset.Y= Lerp(DirectorOffset.Y,TotalOffset.Y,DeltaTime);
                 DirectorOffset.Z= Lerp(DirectorOffset.Z,TotalOffset.Z,DeltaTime);
        }
   //`log(DirectorOffset);
	if (PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing)
	{
		return;
	}
        TempRotator=OutVT.Target.Rotation;
       //  `log(CameraProperties.CameraOffset);
	// Add the camera offset to the target's location to get the location of the camera
	OutVT.POV.Location = OutVT.Target.Location + CameraProperties.CameraOffset+DirectorOffset;
	// Make the camera point towards the target's location

               TempLocation=OutVT.Target.Location;
               TempLocation.Y+=DirectorOffset.Y;
               if(VolumeThatEffect!=None&&VolumeThatEffect.bVerticalHold){
                           TempLocation.Z+=DirectorOffset.Z;
               }
	       OutVT.POV.Rotation = Rotator(TempLocation- OutVT.POV.Location);

}
function ToggleForward(int Sign){
    bForward=!bForward;
    //`log(bForward);
    if(bForward){
        ForwardOffset =PlatCameraProperties(CameraProperties).ForwardOffset;
        if(Sign>0){
                ForwardOffset.Y =-ForwardOffset.Y;
        }

      ///   `log(ForwardOffset);
    }else{
         ForwardOffset =default.ForwardOffset;
    }
}
defaultproperties
{
        CameraProperties=PlatCameraProperties'PlatformerContent.Camera.CameraDefaul'
        bInvMode=False
        bForward =false;
}