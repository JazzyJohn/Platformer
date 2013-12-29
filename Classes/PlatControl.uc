class PlatControl extends SPG_PlayerController;
var vector MouseClickWorldLocation,MouseClickWorldNormal;
// Default state that pawn is walking
var Actor targetForUse;
var vector cachedLocation;
var Actor Destination;
var Actor LaderDestanation;
var PlatLadder  Ladder;
function UpdateRotation(float DeltaTime)
{
	local Rotator DeltaRot;

	// Set the delta rotation to that of the desired rotation, as the desired rotation represents
	// the rotation derived from the acceleration of the pawn
	DeltaRot = DesiredRotation;

       //  `log("pith"@(SPG_PlayerPawn(Pawn).AimNode.Aim.Y));
    //   DeltaRot.Pitch = PlayerInput.aLookUp;//Rotator(pawn.GetBaseAimRotation()-DesiredRotation).Pitch;
	// Never need to roll the delta rotation

	DeltaRot.Roll = 0;

	// Shake the camera if necessary
	ViewShake(DeltaTime);

	// If we have a pawn, update its facing rotation
	if (Pawn != None)
	{
		Pawn.FaceRotation(DeltaRot, DeltaTime);
	}
}
function LadderRotate(vector Target){
	local Rotator DeltaRot;
	DeltaRot.Roll=0;
	DeltaRot.Pitch =0;
	DeltaRot.Yaw = Rotator(Target).Yaw;
	Pawn.FaceRotation(DeltaRot,0);

}
function CanUse(Actor newtargetForUse){
        targetForUse =newtargetForUse;
}
function CancelUse(Actor newtargetForUse){
        targetForUse= None;

}

exec function ShowInventory(){
        if(Pawn!=None&&PlatInvMan(Pawn.InvManager)!=None){
                PlatInvMan(Pawn.InvManager).ShowInventory();

        }

}
exec function HideInventory(){
        if(Pawn!=None&&PlatInvMan(Pawn.InvManager)!=None){
                PlatInvMan(Pawn.InvManager).HideInventory();
        }
}
exec function UseTarget(){
    `log("use");
        if(targetForUse!=None){
                if(targetForUse.IsA('PlatLadder')){
                    if(IsInState('LadderStart')||IsInState('PlatLadder')||IsInState('LadderFinish')){
                        return;
                    }

                      //`log("LadderStart");
                        Ladder= PlatLadder(targetForUse);
                        if(Ladder.bEnable){
                                GoToState('LadderStart');
                        }

                }
        }
}
exec function ToggleInventory(){
  if(IsInState('InInventory')){
      	GotoState('PlayerWalking');
  }
  else if(IsInState('PlayerWalking')){
	GotoState('InInventory');

  } else{
        //`log("no inv");
  }
}
exec function LookForward(){
        if(MouseInterfaceHUD(MyHUD)!=None&&MouseInterfacePlayerInput(PlayerInput)!=None){
           // `log("LOL");
                PlatCamera(PlayerCamera).ToggleForward(MouseInterfaceHUD(MyHUD).WeaponInCamLoc.X-MouseInterfacePlayerInput(PlayerInput).MousePosition.X);
        }
}

exec function StartAltFire( optional Byte FireModeNum )
{

	StartFire(1);
}
function OnToggleInput(SeqAct_ToggleInput inAction)
{
    local MouseInterfaceHUD hud;
    hud =MouseInterfaceHUD(myHUD);
    if(hud!=None){
        if(inAction.InputLinks[0].bHasImpulse)
                 hud.bHiddenMouse =false;
         else if(inAction.InputLinks[1].bHasImpulse)
             hud.bHiddenMouse =true;
        else
             hud.bHiddenMouse =!hud.bHiddenMouse;
    }
    Super.OnToggleInput(inAction);

}
function PostRender(){


}
state LadderFinish{
       ignores PlayerMove,StartFire,CheckJumpOrDuck;
         function BeginState(Name PreviousStateName){
        Pawn.SetPhysics(PHYS_Flying);

        }
         function PlayerTick(float DeltaTime){

                `log("FinishTick");
           if(Pawn.ReachedDestination(Destination)){
                GotoState('PlayerWalking');

           }else{

                 GotoState('LadderFinish');
           }
     }
     function EndState(name NextStateName)
     {
                Destination=None;
     }
Begin:
  //If we just began or we have reached the Destination
  //pick a new destination - at random

    Destination =Ladder.GetClosestExit(Pawn);
  LadderRotate(Destination.Location-Pawn.Location);
   Pawn.Velocity =Normal(Destination.Location-Pawn.Location)* Pawn.GroundSpeed;
//`log(Destination);
  //fire off next decision loop


}
function MoveToPoint(Actor NewDestination){
        Destination =NewDestination;
         GotoState('MovePlayerTo');
}

state MovePlayerTo{
         ignores PlayerMove, StartFire,CheckJumpOrDuck;
        function BeginState(Name PreviousStateName)
        {
                Pawn.SetPhysics(PHYS_Flying);
        }
        function PlayerTick(float DeltaTime)
        {
           if(Pawn.ReachedDestination(Destination)){
                GotoState('PlayerWalking');
           }else{
                 GotoState('MovePlayerTo');
           }
        }
        function EndState(name NextStateName)
        {
                Destination=None;
        }
    Begin:


       LadderRotate(Destination.Location-Pawn.Location);
        Pawn.Velocity =Normal(Destination.Location-Pawn.Location)* Pawn.GroundSpeed;



}
state LadderStart{
     ignores PlayerMove, StartFire,CheckJumpOrDuck;
      function BeginState(Name PreviousStateName){
        Pawn.SetPhysics(PHYS_Flying);

        }
     function PlayerTick(float DeltaTime)
     {
                `log("StrTick");
           if(Pawn.ReachedDestination(Destination)){

                GotoState('PlatLadder');

           }else{

                 GotoState('LadderStart');
           }
     }
      function EndState(name NextStateName)
     {
                Destination=None;
     }
Begin:
  //If we just began or we have reached the Destination
  //pick a new destination - at random

    Destination = Ladder.GetClosest(Pawn);
    LadderRotate(Destination.Location-Pawn.Location);
   Pawn.Velocity =Normal(Destination.Location-Pawn.Location)* Pawn.GroundSpeed;
  //Find a path to the destination and move to the next node in the path
 // MoveToward(Destination, Destination);
  //fire off next decision loop

}
state FallFromLadder{
    ignores PlayerMove,StartFire,CheckJumpOrDuck;
         function BeginState(Name PreviousStateName){
           Pawn.SetPhysics(PHYS_Walking);

        }

         function PlayerTick(float DeltaTime){
             `log("FallTick");
            if(Pawn.ReachedDestination(Destination)){
                GotoState('PlayerWalking');

           }else{

                 GotoState('FallFromLadder');
           }
     }
     function EndState(name NextStateName)
     {
                Destination=None;
     }
Begin:
  //If we just began or we have reached the Destination
  //pick a new destination - at random

    Destination = Ladder.GetClosestExit(Pawn);
  LadderRotate(Destination.Location-Pawn.Location);
   Pawn.Velocity =Normal(Destination.Location-Pawn.Location)* Pawn.GroundSpeed;
//`log(Destination);
  //fire off next decision loop


}
state InInventory{
        function BeginState(Name PreviousStateName){

                 ShowInventory();
        }
        function PlayerMove(float DeltaTime)
	{

        }
        exec function StartFire(optional byte FireModeNum)
        {

                `Log("no fire for you pal");

        }
         function  EndState(Name PreviousStateName){


                 HideInventory();
        }
}
function CheckLook(){
        local MouseInterfaceHUD MouseInterfaceHUD;
	local Actor traceHit;
        MouseInterfaceHUD=MouseInterfaceHUD(MyHUD);
        traceHit =Trace(MouseClickWorldLocation, MouseClickWorldNormal, MouseInterfaceHUD.MousePointInWorld + (MouseInterfaceHUD.MousePointInWorldDir * 2000), MouseInterfaceHUD.MousePointInWorld,true);
        if(traceHit==None||!ClassIsChildOf(traceHit.class,class'PlatPawn')){
                MouseClickWorldLocation= Vect(0,0,0);
        }
       // `log(traceHit);
}
function Vector GetMouseTarget(){
        local MouseInterfaceHUD MouseInterfaceHUD;
        local vector PickLocation,PickNormal;
        MouseInterfaceHUD=MouseInterfaceHUD(MyHUD);
        Trace(PickLocation, PickNormal, MouseInterfaceHUD.MousePointInWorld + (MouseInterfaceHUD.MousePointInWorldDir * 2000), MouseInterfaceHUD.MousePointInWorld,true);
        return PickLocation;
}
auto state PlayerWalking

{
	/**
	 * Handle player moving. Called once per tick
	 *
	 * @param	DeltaTime	Time since the last tick
	 * @network				Server and client
	 */
	 exec function StartFire(optional byte FireModeNum)
        {

        super.StartFire(FireModeNum);

        }
         function BeginState(Name PreviousStateName){
             if(Pawn!=None){
                   Pawn.SetPhysics(PHYS_Walking);
             }
        }
	function PlayerMove(float DeltaTime)
	{
                local Vector X, Y, Z, NewAccel,NewRota, CameraLocation;
		local Rotator OldRotation, CameraRotation;
		local bool bSaveJump;
 	        local float Side,PitchFl;
                local MouseInterfacePlayerInput LocalInput  ;
                local MouseInterfaceHUD MouseInterfaceHUD;
                Side=0;
                PitchFl=0;
                LocalInput=MouseInterfacePlayerInput(PlayerInput);
		// If we don't have a pawn to control, then we should go to the dead state
		if (Pawn == None)
		{
			GotoState('Dead');
		}
		else
		{
   // Grab the camera view point as we want to have movement aligned to the camera
			PlayerCamera.GetCameraViewPoint(CameraLocation, CameraRotation);
			// Get the individual axes of the rotation
			GetAxes(CameraRotation, X, Y, Z);

			// Update acceleration

                        //trigonometry aim
                        MouseInterfaceHUD=MouseInterfaceHUD(MyHUD);
                        CheckLook();
                        NewRota=  MouseClickWorldLocation-MouseInterfaceHUD.WeaponInWorld;

                      ///  DrawDebugLine(MouseClickWorldLocation, MouseInterfaceHUD.WeaponInWorld, 255, 0, 0, TRUE);
                        if(VSizeSq(MouseClickWorldLocation)!=0&&Abs(Rotator(NewRota).Yaw)<16000){


                                PitchFl=(Atan2(MouseClickWorldLocation.Z-MouseInterfaceHUD.WeaponInWorld.Z,VSize2D(NewRota)))/Pi*2*Pawn.ViewPitchMax;

                                //`log( "sfter"@MouseClickWorldLocation.Y);
                                  //`log( "Pitch"@DesiredRotation.Pitch);
                        }else{

                        if(MouseInterfaceHUD!=None&&LocalInput!= None){
                                Side=MouseInterfaceHUD.WeaponInCamLoc.X-LocalInput.MousePosition.X ;
                                 PitchFl=MouseInterfaceHUD.WeaponInCamLoc.Y-LocalInput.MousePosition.Y ;
                                if(Side==0){
                                Side=1;
                                  }
                         //`log("befiore"@ PitchFl);
                            // `log( "atan"@Atan2(PitchFl,Abs(Side)));
                        PitchFl=Atan2(PitchFl,Abs(Side))/Pi*2*Pawn.ViewPitchMax;
                      //  `log( "sfter"@PitchFl);
                        if(Side>0){
                                Side=-1;
                        }else{
                                Side=1;
                        }


                       }

                        	NewRota = Pawn.AccelRate *Side* Normal( Y);


                        }

                        //`log(MouseClickWorldLocation);


     	                  DesiredRotation = Rotator(NewRota);
                          DesiredRotation.Pitch = PitchFl;






			// Update rotation
			OldRotation = Rotation;
			UpdateRotation(DeltaTime);
                        NewAccel=  Y*PlayerInput.aStrafe;

			// Update crouch
			Pawn.ShouldCrouch(bool(bDuck));

			// Handle jumping
			if (bPressedJump && Pawn.CannotJumpNow())
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			// Update the movement, either replicate it or process it
			if (Role < ROLE_Authority)
			{
				ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
			}

			bPressedJump = bSaveJump;
		}
	}
}

state PlatLadder
{

       ignores CheckJumpOrDuck;
        function BeginState(Name PreviousStateName){
         Pawn.SetPhysics(PHYS_Spider);
          LaderDestanation =Ladder.GetFarest(Pawn);

        }
        exec function StartFire( optional byte FireModeNum )
        {

        }
       	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration	= NewAccel;


	}
        function PlayerMove( float DeltaTime )
	{
                local Vector X, Y, Z, NewAccel, CameraLocation;
		local Rotator OldRotation, CameraRotation;



        // If we don't have a pawn to control, then we should go to the dead state
		if (Pawn == None)
		{
			GotoState('Dead');
		}
		else
		{
   // Grab the camera view point as we want to have movement aligned to the camera
  	PlayerCamera.GetCameraViewPoint(CameraLocation, CameraRotation);
			// Get the individual axes of the rotation
			GetAxes(CameraRotation, X, Y, Z);

			// Update acceleration












			// Update rotation
			OldRotation = Rotation;
			UpdateRotation(DeltaTime);
                        //NewAccel.Z=  -PlayerInput.aStrafe*Pawn.AccelRate;
                       // NewAccel.X =0;
                       // NewAccel.Y =0;
                      NewAccel=Normal(LaderDestanation.Location - Pawn.Location)*Pawn.AccelRate;
			// Update crouch
                       // `log(NewAccel);

			// Handle jumpingSS
		/*	if (bPressedJump){
                        	GotoState('FallFromLadder');
                        }*/
                        if(Pawn.ReachedDestination(LaderDestanation)){
                              `log("FinishReach");
                                GotoState('LadderFinish');
                        }
			// Update the movement, either replicate it or process it
			if (Role < ROLE_Authority)
			{
				ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
			}
                }
	}
	 function EndState(name NextStateName){



        }
}

defaultproperties
{
    CameraClass =class'PlatCamera'
     InputClass=class'MouseInterfacePlayerInput'

}