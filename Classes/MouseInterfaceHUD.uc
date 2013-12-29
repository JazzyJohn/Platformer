class MouseInterfaceHUD extends HUD;

// The texture which represents the cursor on the screen
var const Texture2D CursorTexture;
// The color of the cursor
var const Color CursorColor;
var bool bHiddenMouse;
var PlatPlayerPawn PlatPlayerPawn;
var vector WeaponInCamLoc;
var vector MousePointInWorldDir;
var vector MousePointInWorld;
var vector WeaponInWorld;
event PostRender()
{
  local MouseInterfacePlayerInput MouseInterfacePlayerInput;

	local float XL, YL;
	local String Text;

	local vector2D mousepos;
  // Ensure that we have a valid PlayerOwner and CursorTexture

  if (PlayerOwner != None && CursorTexture != None)
  {
    // Cast to get the MouseInterfacePlayerInput
    MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

    if (MouseInterfacePlayerInput != None&&!bHiddenMouse)
    {


      // Set the canvas position to the mouse position
      Canvas.SetPos(MouseInterfacePlayerInput.MousePosition.X-12, MouseInterfacePlayerInput.MousePosition.Y-12);
      // Set the cursor color
      Canvas.DrawColor = CursorColor;
      // Draw the texture on the screen
      Canvas.DrawTile(CursorTexture, 25, 25, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
    }
  }
         mousepos.X=MouseInterfacePlayerInput.MousePosition.X;
        mousepos.Y=MouseInterfacePlayerInput.MousePosition.Y;

        // Ensure that PlayerOwner and PlayerOwner.Pawn are valid
	if (PlayerOwner != None && PlayerOwner.Pawn != None)
	{
                if(PlatPlayerPawn==None){
                PlatPlayerPawn = PlatPlayerPawn( PlayerOwner.Pawn );
                
                }
		// Set the text to say Health: and the numerical value of the player pawn's health
		Text = "Health: "$PlatPlayerPawn.Health;
		// Set the font
		Canvas.Font = class'Engine'.static.GetMediumFont();
		// Set the current drawing color
		Canvas.SetDrawColor(255, 255, 255);
		// Get the dimensions of the text in the font assigned
		Canvas.StrLen(Text, XL, YL);
		// Set the current drawing position to the be at the bottom left position with a padding of 4 pixels
		Canvas.SetPos(4, Canvas.ClipY - YL - 4);
		// Draw the text onto the screen
		Canvas.DrawText(Text);
			Text = "Hungry: "$FFloor(PlatPlayerPawn.Hungry);
		// Set the font
		Canvas.Font = class'Engine'.static.GetMediumFont();
		// Set the current drawing color
		Canvas.SetDrawColor(255, 255, 255);
		// Get the dimensions of the text in the font assigned
		Canvas.StrLen(Text, XL, YL);
		// Set the current drawing position to the be at the bottom left position with a padding of 4 pixels
		Canvas.SetPos(4, Canvas.ClipY - 2*YL - 4);
		// Draw the text onto the screen
		Canvas.DrawText(Text);
			Text = "Sanity: "$FFloor(PlatPlayerPawn.Sanity);
		// Set the font
		Canvas.Font = class'Engine'.static.GetMediumFont();
		// Set the current drawing color
		Canvas.SetDrawColor(255, 255, 255);
		// Get the dimensions of the text in the font assigned
		Canvas.StrLen(Text, XL, YL);
		// Set the current drawing position to the be at the bottom left position with a padding of 4 pixels
		Canvas.SetPos(4, Canvas.ClipY - 3*YL - 4);
		// Draw the text onto the screen
		Canvas.DrawText(Text);
			Text = "Charge: "$FFloor(PlatInvMan(PlatPlayerPawn.InvManager).GetBatteryCharge());
		// Set the font
		Canvas.Font = class'Engine'.static.GetMediumFont();
		// Set the current drawing color
		Canvas.SetDrawColor(255, 255, 255);
		// Get the dimensions of the text in the font assigned
		Canvas.StrLen(Text, XL, YL);
		// Set the current drawing position to the be at the bottom left position with a padding of 4 pixels
		Canvas.SetPos(4, Canvas.ClipY - 4*YL - 4);
		// Draw the text onto the screen
		Canvas.DrawText(Text);
		if(PlatPlayerPawn!=None){
                	PlatPlayerPawn.Mesh.GetSocketWorldLocationAndRotation(PlatPlayerPawn.WeaponSocketName,WeaponInWorld);

			if(Canvas!=None){
                        	 WeaponInCamLoc=Canvas.Project(WeaponInWorld);
                        	  Canvas.DeProject(mousepos,MousePointInWorld,MousePointInWorldDir);
                          //`log("world"@WeaponInWorld);
                          //`log("screen"@WeaponInCamLoc);
                        }
                        if(PlatPlayerPawn.Weapon!=None&&PlatWeapon(PlatPlayerPawn.Weapon)!=None){
                                		Text = PlatWeapon(PlatPlayerPawn.Weapon).MagSize$"/"$PlatWeapon(PlatPlayerPawn.Weapon).GetMagSize();
	                                       	// Set the font
	                                       	Canvas.Font = class'Engine'.static.GetMediumFont();
	                                       	// Set the current drawing color
	                                       	Canvas.SetDrawColor(255, 255, 255);
	                                       	// Get the dimensions of the text in the font assigned
	                                       	Canvas.StrLen(Text, XL, YL);
	                                       	// Set the current drawing position to the be at the bottom left position with a padding of 4 pixels
                        	               	Canvas.SetPos(4, Canvas.ClipY - 5*YL - 4);
		                              // Draw the text onto the screen
	                                        Canvas.DrawText(Text);


                        }

                }

	}
  Super.PostRender();
}

defaultproperties
{
  CursorColor=(R=255,G=255,B=255,A=255)
  CursorTexture=Texture2D'PlatformerContent.Texture.crosshair'
}