class PlatPoint extends Actor
	placeable;
defaultproperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		bTreatAsASprite=True
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Arrow)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Flag1'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Notes"
	End Object
	Components.Add(Sprite)

	bStatic=true
	bHidden=true
	bNoDelete=true
	bMovable=false
	bRouteBeginPlayEvenIfStatic=false
}