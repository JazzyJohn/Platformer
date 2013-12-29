class PlatAIControler extends UDKBot;

var Actor Destination;

var (AI) float RotationSpeed;
var (AI) float RangeOFSeen;

var (AI) array<Actor>RoutePoint;
var (AI) float IdleTime;
var (AI) bool bRandomPatrol;
var int CurPoint;
var vector LastSeenLocation;
var int Alerntness;

var float NoticingOfPlayer;
var float LockingTime;
var bool bSeePlayer;

function Actor FindNextPoint(){
    local Actor NextPoint;
    if(bRandomPatrol){
        CurPoint =Rand(RoutePoint.length);
        NextPoint = RoutePoint[CurPoint];
    }else{
        NextPoint =  RoutePoint[CurPoint];
        CurPoint++;
        if(RoutePoint.length<=CurPoint){
                CurPoint=0;
        }
    }
    return NextPoint;
}

function bool FindPathToVector(vector TargetVector)
{
	
	// Clear previous contraints points
	NavigationHandle.ClearConstraints();

	// Define search restrictions
	class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle, TargetVector);
	class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, TargetVector);

	// Find path
	return NavigationHandle.FindPath();
}


function PostBeginPlay(){
        Super.PostBeginPlay();
        GoToState('WaitForPawn');

}
event Possess(Pawn inPawn, bool bVehicleTransition){
        Super.Possess(inPawn,bVehicleTransition);
        GoToState('Idle');
}
function name DecideWhatToDoNext(){
        if(RoutePoint.length>0){
                return 'Patrol';
        }else{
                return 'Idle';
        }

}
function bool ISEnenmyAlive(){
        return Enemy!=None&&!Enemy.bDeleteMe&&Enemy.Health>0;
}
event SeePlayer( Pawn Seen ){
    `log("SEEEN"@Seen.Controller);
        if(!ISEnenmyAlive()&&MirageControler(Seen.Controller)!=None){
                Enemy = Seen;
                GoToState('ShootToTarget');
        }
}
state Idle
{
local name NextAction;
       	event BeginState(name PreviousStateName)
		{
			AIPawn(Pawn).PlayIdleAnim();
		}

	event EndState(name NextStateName)
		{
			AIPawn(Pawn).StopCustomAnim();
		}
Begin:
        Sleep(IdleTime);
        NextAction=DecideWhatToDoNext();

        if(NextAction!='Idle'){
                GoToState(NextAction);
        }else{

                GOTO('Begin');
        }

}
state ShootToTarget
{
 simulated function Tick(float Delta){
        local name NextAction;
        if(!ISEnenmyAlive()){
                 Pawn.StopFire(0);
                 NextAction=DecideWhatToDoNext();
                 GoToState(NextAction);
        }
 }

 begin:
          Velocity = Vect(0,0,0);
          AIPawn(Pawn).RotatePawnTo(Rotator(Enemy.Location-Pawn.Location));
	  FinishRotation();
	  Pawn.StartFire(0);
}
state Patrol
{
local name NextAction;
local vector vFinalDestination,vTempDest;
    
Begin:
   vFinalDestination = FindNextPoint().Location;

        //	DrawDebugSphere(Pawn.Location,32,20,255,255,255,true);
       // 	DrawDebugSphere(vFinalDestination,32,20,0,255,255,true);
  if (PointReachable(vFinalDestination))
  {
	// then move directly to the actor
	AIPawn(Pawn).RotatePawnTo(Rotator(vFinalDestination-Pawn.Location));
	FinishRotation();
	MoveTo(vFinalDestination,none);
  }
  else{
        if( FindPathToVector( vFinalDestination ) )
	{

                		     NavigationHandle.SetFinalDestination( vFinalDestination );


				    // Движемся, пока не достигнем точки назначения
					while( NavigationHandle.GetNextMoveLocation( vTempDest, Pawn.GetCollisionRadius())
					&& !Pawn.ReachedPoint(vFinalDestination, none) )
						{
							if (!NavigationHandle.SuggestMovePreparation( vTempDest, self))
									{
                                                                                         if (PointReachable(vFinalDestination))
								                        {
												// then move directly to the actor
                                                                                                AIPawn(Pawn).RotatePawnTo(Rotator(vFinalDestination-Pawn.Location));
											        FinishRotation();
												MoveTo(vFinalDestination,none);
												break;
                                                                                        }else{
                                                                                                AIPawn(Pawn).RotatePawnTo(Rotator(vTempDest-Pawn.Location));
                                                                                                FinishRotation();
												MoveTo( vTempDest ,none);
                                                                                        }
									}
						}

        }
  }

     GoToState('Idle');
}
state WaitForPawn
{


}



defaultproperties
{
        NoticingOfPlayer=1.0
        Alerntness=0;
        LockingTime=10.0
        RangeOFSeen=500.0
        RotationSpeed=1.0
      
        IdleTime=1.8
}