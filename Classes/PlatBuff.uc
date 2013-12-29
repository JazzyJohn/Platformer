class PlatBuff extends Object
	editinlinenew
	hidecategories(Object)
	DependsOn(PlatStatsModifier);

// Stat changes
var(Buff) array<SStatChange> StatChanges;
// The name of the icon to display with any pawn effected by this buff - if any.
var(Buff) string BuffIcon;
// How long the buff will last (in seconds)
var(Buff) float Expiry;
// Whether this buff is removed when the target dies (true = not removed)
var(Buff) bool StaysOnDeath;

//Who put that Buff
var Actor Initiator;
// Default properties block
defaultproperties
{
    

}