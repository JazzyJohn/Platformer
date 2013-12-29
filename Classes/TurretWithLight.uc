class TurretWithLight extends PlatTurret placeable;
var() editconst const LightComponent	LightComponent;
var () color AttackColor;
var  color NormalColor;
function PostBeginPlay(){
        NormalColor =LightComponent.LightColor;
        Super.PostBeginPlay();
}
state AfterAttack{
   event Tick(float DeltaTime){
             local color c;
                if(!LookForPlayer()){
                        ActivationTime-=DeltaTime;
                        c.r= Lerp(LightComponent.LightColor.r,NormalColor.r,1-ActivationTime/default.ActivationTime);
                        c.g= Lerp(LightComponent.LightColor.g,NormalColor.g,1-ActivationTime/default.ActivationTime);
                        c.b= Lerp(LightComponent.LightColor.b,NormalColor.b,1-ActivationTime/default.ActivationTime);
                        LightComponent.SetLightProperties(,c);

                        if(ActivationTime<=0){
                                GotoState('LookingAround');
                        }
                }else{
                         GotoState('PrepareForAttack');
                }
         }
}
state PrepareForAttack{
        function BeginState(Name PreviousStateName){

        if(PreviousStateName!='PrepareForAttack'){

                ActivationTime=0;
        }

         }
         event Tick(float DeltaTime){
             local color c;
                if(LookForPlayer()){
                        ActivationTime+=DeltaTime;
                        c.r= Lerp(LightComponent.LightColor.r,AttackColor.r,ActivationTime/default.ActivationTime);
                        c.g= Lerp(LightComponent.LightColor.g,AttackColor.g,ActivationTime/default.ActivationTime);
                        c.b= Lerp(LightComponent.LightColor.b,AttackColor.b,ActivationTime/default.ActivationTime);
                        LightComponent.SetLightProperties(,c);

                        if(ActivationTime>default.ActivationTime){
                                GotoState('Attacking');
                        }
                }else{
                         GotoState('AfterAttack');
                }
         }

}


defaultproperties
{



	// Light radius visualization.
	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	// Inner cone visualization.
	Begin Object Class=DrawLightConeComponent Name=DrawInnerCone0
		ConeColor=(R=150,G=200,B=255)
	End Object
	Components.Add(DrawInnerCone0)

	// Outer cone visualization.
	Begin Object Class=DrawLightConeComponent Name=DrawOuterCone0
		ConeColor=(R=200,G=255,B=255)
	End Object
	Components.Add(DrawOuterCone0)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightSourceRadius0
		SphereColor=(R=231,G=239,B=0,A=255)
	End Object
	Components.Add(DrawLightSourceRadius0)

	// Light component.
	Begin Object Class=SpotLightComponent Name=SpotLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING
	    CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=FALSE
	    UseDirectLightMap=FALSE
	    LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
	    PreviewLightRadius=DrawLightRadius0
		PreviewInnerCone=DrawInnerCone0
		PreviewOuterCone=DrawOuterCone0
		PreviewLightSourceRadius=DrawLightSourceRadius0
	End Object
	LightComponent=SpotLightComponent0
	Components.Add(SpotLightComponent0)

	Begin Object Class=ArrowComponent Name=ArrowComponent0
		ArrowColor=(R=150,G=200,B=255)
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		bTreatAsASprite=True
		SpriteCategoryName="Lighting"
	End Object
	Components.Add(ArrowComponent0)
}