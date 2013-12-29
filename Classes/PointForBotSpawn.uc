class PointForBotSpawn extends Actor placeable;
var() array<Actor> RoutePoint;
struct PAwnToSpawn{
    var () archetype AIPawn AIPawn;
    var () archetype PlatAIControler PlatAIControler;

};
var() array<PAwnToSpawn> ListOfPawn;
var () bool bIsRandomPatrol;

function PostBeginPlay(){
        Super.PostBeginPlay();
        SpawnPawn();   
}

function SpawnPawn(){
        local AIPawn  NewPawn;
        local PlatAIControler NewAI;
        local int i;
        i = Rand(ListOfPawn.length);
        NewPawn = Spawn(ListOfPawn[i].AIPawn.class,,,Location,,ListOfPawn[i].AIPawn);
        if(ListOfPawn[i].PlatAIControler==None){
                NewAI= Spawn(class'PlatAIControler');

        }else{
                 NewAI= Spawn(class'PlatAIControler',,,,,ListOfPawn[i].PlatAIControler);
        }
        NewAI.Possess(NewPawn,true);
        NewAI.RoutePoint = RoutePoint;
        NewAI.bRandomPatrol=bIsRandomPatrol;
    
}

defaultproperties
{

        Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Ambientcreatures'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Sprite)

}

