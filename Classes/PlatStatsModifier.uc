//=============================================================================
// UDKMOBAStatsModifier
//
// Stores all stat changes from spells/items/etc, and can calculate those 
// changes to the stats.
//
// Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class PlatStatsModifier extends Object;

// Modifier type
enum EModifierType
{
	MODTYPE_Multiplication<DisplayName=Multiplication>,
	MODTYPE_Addition<DisplayName=Addition>,
	MODTYPE_Assignment<DisplayName=Assign (Lock)>,
};

// State name
enum EStatName
{       

    	STATNAME_Speed<DisplayName=Speed>,
        STATNAME_Visibility<DisplayName=Visibility>, // bool, default 1

};

// Stat change struct
struct SStatChange
{
	var(StatChange) EStatName StatName;
	var(StatChange) float Modification;
	var(StatChange) EModifierType ModificationType;
};

// Array of all active buffs on that we're managing
var array<PlatBuff> AllBuffs;

/**
 * Create a stat change for the given stat, optionally with an expiry time. Add this with a shell buff.
 *
 * @param		StatName			Stat name
 * @param		Modification		How much to modify the stat
 * @param		ModType				How to modify the stat
 * @param		Expiry				How long this stat change lasts for
 * @param		StaysOnDeath		If true, then this stat change persists after death
 * @network							Server and local client
 */
function AddStatChange(EStatName StatName, float Modification, EModifierType ModType, optional Actor Initiator,optional float Expiry = 0.f, optional bool StaysOnDeath = false)
{
	local PlatBuff NewBuff;
	local SStatChange NewStatChange;

	// Create the stat change
	NewStatChange.StatName = StatName;
	NewStatChange.Modification = Modification;
	NewStatChange.ModificationType = ModType;

	NewBuff = new() class'PlatBuff';
	NewBuff.StatChanges.AddItem(NewStatChange);
        NewBuff.Expiry =  Expiry;
	NewBuff.StaysOnDeath = StaysOnDeath;
        NewBuff.Initiator=Initiator;
	// Add the stat change to the array
	AddToBuffs(NewBuff);
}
/**
 * Delete a stat change for the given stat. Add this with a shell buff.
 *
 * @param		StatName			Stat name
 * @param		ModType				How to modify the stat
  * @network							Server and local client
 */
function DeleteStatChange(EStatName StatName,EModifierType ModType, optional Actor Initiator)
{

	local int i, j;


	// Iterate through the stat changes and append to find the total modification
	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{    
                                if(Initiator==None){
		              		if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == ModType)
		      	               	{
                                                AllBuffs.Remove(i, 1);
        		                      	--i;
                                                break;
                                        }
                                }else{
                                        if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == ModType&&Initiator==AllBuffs[i].Initiator)
		      	               	{
                                                AllBuffs.Remove(i, 1);
        		                      	--i;
                                                break;
                                        }

                                }
                        }
                }
        }
}
/**
 * Add given buff to the list, so it gets bundled into all our calculations
 *
 * @param		NewBuff		New buff to add to the array
 * @network					Server and local client
 */
private function AddToBuffs(PlatBuff NewBuff)
{
	local int i;

	// Attempt to insert the buff into the array; sorting on their Expiry time
	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			if (NewBuff.Expiry < AllBuffs[i].Expiry)
			{
				AllBuffs.InsertItem(i, NewBuff);
				return;
			}
		}
	}

	// Otherwise, add it to the end of the array
	AllBuffs.AddItem(NewBuff);
}

/**
 * Calculate all the changes that effect a stat, and return the result
 *
 * @param		StatName		Name of the stat to calculate
 * @param		BaseValue		Base value to append right at the start
 * @return						Returns the calcuated stat value
 * @network						Server and local client
 */
function float CalculateStat(EStatName StatName, optional coerce float BaseValue = 0.f)
{
	local float NewValue;

	// Different stats calculate in different ways!
	switch (StatName)
	{


		case STATNAME_Visibility:
		default:
			NewValue = BaseValue * CalculateMultipliedChanges(StatName) + CalculateAbsoluteChanges(StatName);
			break;
	}

	CalculatePreLockCaps(StatName, NewValue);
	CalculateAssignedChanges(StatName, NewValue);
	CalculateFinalCaps(StatName, NewValue);

	return NewValue;
}

/**
 * Find multiplicative changes, and multiply them together
 *
 * @param		StatName		Name of the stat to change
 * @return						Returns the calculated modifier
 * @network						Server and local client
 */
function float CalculateMultipliedChanges(EStatName StatName)
{
	local float TotalModification;
	local int i, j;

	TotalModification = 1.f;

	// Iterate through the stat changes and append to find the total modification
	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{
				if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == MODTYPE_Multiplication)
				{
					TotalModification *= AllBuffs[i].StatChanges[j].Modification;
					AllBuffs.Remove(i, 1);
			                --i;
				}
			}
		}
	}

	// Return the total modification
	return TotalModification;
}

/**
 * Find changes, and multiply them together in a diminishing fashion - multiplying them as
 * percentages. This makes 0.5 and 0.5 combine to form 0.75.
 *
 * @param		StatName		Name of the stat to change
 * @return						Returns the calculated modifier
 * @network						Server and local client
 */
function float CalculateChangesDiminishingly(EStatName StatName)
{
	local float TotalModification;
	local int i, j;

	TotalModification = 1.f;

	// Iterate through the stat changes and append to find the total modification
	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{
				if (AllBuffs[i].StatChanges[j].StatName == StatName)
				{
					TotalModification *= (1.f - AllBuffs[i].StatChanges[j].Modification);
				}
			}
		}
	}

	// Return the total modification
	return (1.f - TotalModification);
}

/**
 * Find changes of the given type, and return the smallest only (used for some non-stacking stats
 * like slows). Only really makes sense for additive and multiplicative changes.
 *
 * @param		StatName			Name of the stat to change
 * @param		ModificationType	Modification type to filter for
 * @return							Returns the smallest change
 * @network							Server and local client
 */
function float FindSmallestChange(EStatName StatName, EModifierType ModificationType)
{
	local float SmallestModification;
	local bool FoundSmallest;
	local int i, j;

	// Find the smallest modification
	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{
				if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == ModificationType)
				{
					if (!FoundSmallest)
					{
						FoundSmallest = true;
						SmallestModification = AllBuffs[i].StatChanges[j].Modification;
					}
					else if (AllBuffs[i].StatChanges[j].Modification < SmallestModification)
					{
						SmallestModification = AllBuffs[i].StatChanges[j].Modification;
					}
				}
			}
		}
	}

	// Return the smallest modification, if found
	if (FoundSmallest)
	{
		return SmallestModification;
	}

	// Return 0.f, if the smallest wasn't found and if the modification type was addition
	if (ModificationType == MODTYPE_Addition)
	{
		return 0.f;
	}

	// Otherwise, return 1.f as a fail safe option
	return 1.f;
}

/**
 * Find changes of the given type, and return the largest only (used for some non-stacking stats
 * like evasion). Only really makes sense for additive and multiplicative changes.
 *
 * @param		StatName				Name of the stat to change
 * @param		ModificationType		Modification type to filter for
 * @return								Returns the smallest change
 * @network								Server and local client
 */
function float FindLargestChange(EStatName StatName, EModifierType ModificationType)
{
	local float LargestModification;
	local bool FoundLargest;
	local int i, j;

	// Find the largest modification
	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{
				if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == ModificationType)
				{
					if (!FoundLargest)
					{
						FoundLargest = true;
						LargestModification = AllBuffs[i].StatChanges[j].Modification;
					}
					else if (AllBuffs[i].StatChanges[j].Modification < LargestModification)
					{
						LargestModification = AllBuffs[i].StatChanges[j].Modification;
					}
				}
			}
		}
	}

	// Return the largest modification if found
	if (FoundLargest)
	{
		return LargestModification;
	}

	// Return 0.f, if the largest wasn't found and if the modification type was addition
	if (ModificationType == MODTYPE_Addition)
	{
		return 0.f;
	}

	// Otherwise, return 1.f as a fail safe option
	return 1.f;
}

/**
 * Find absolute changes, and add them together
 *
 * @param		StatName		Name of the stat to change
 * @return						Returns the smallest change
 * @network						Server and local client
 */
function float CalculateAbsoluteChanges(EStatName StatName)
{
	local float TotalModification;
	local int i, j;

	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{
			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{
				if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == MODTYPE_Addition)
				{


					TotalModification += AllBuffs[i].StatChanges[j].Modification;
				}
			}
		}
	}

	return TotalModification;
}

/**
 * Find assigned (locked) changes, and apply them
 *
 * @param		StatName			Name of the stat to change
 * @param		PreviousValue		Outputs the stat change modification
 * @network							Server and local client
 */
function CalculateAssignedChanges(EStatName StatName, out float PreviousValue)
{
	local int i, j;

	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; ++i)
		{

			for (j = 0; j < AllBuffs[i].StatChanges.Length; ++j)
			{
                                //`log(AllBuffs[i].StatChanges[j].StatName@ AllBuffs[i].StatChanges[j].Modification );
				if (AllBuffs[i].StatChanges[j].StatName == StatName && AllBuffs[i].StatChanges[j].ModificationType == MODTYPE_Assignment)
				{
					PreviousValue = AllBuffs[i].StatChanges[j].Modification;
				}

			}
		}
	}
}

/**
 * Apply any caps to the range of a stat before locks (assignments) - caps stats within a sensible range
 *
 * @param		StatName			Name of the stat to change
 * @param		PreviousValue		Outputs the stat change modification
 * @network							Server and local client
 */
function CalculatePreLockCaps(EStatName StatName, out float PreviousValue)
{
	switch (StatName)
	{
		case STATNAME_Speed: // can't go below 100 or above 520 in DotA
		//	PreviousValue = FClamp(PreviousValue, 120.f, 830.f);
			break;


		default:
			break;
	}
}

/**
 * Apply any caps to the range of a stat AFTER locks (assignments) - stops stats from being invalid values.
 *
 * @param		StatName			Name of the stat to change
 * @param		PreviousValue		Outputs the stat change modification
 * @network							Server and local client
 */
function CalculateFinalCaps(EStatName StatName, out float PreviousValue)
{

	switch (StatName)
	{
	

		default:
			break;
	}
}

/**
 * Remove old buffs from the changes list
 *
 * @network		Server and local client
 */
function RemoveExpired()
{
	local int i;

	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; i++)
		{
			// Skip as it hasn't expired
			if (AllBuffs[i].Expiry==0||AllBuffs[i].Expiry >= class'WorldInfo'.static.GetWorldInfo().TimeSeconds)
			{
				continue;
			}

			// Remove the entry as it has expired
			AllBuffs.Remove(i, 1);
			--i;
		}
	}
}

/**
 * Remove all buffs that don't carry across on death from the changes list
 *
 * @network		Server and local client
 */
function ResetForDeath()
{
	local int i;

	if (AllBuffs.Length > 0)
	{
		for (i = 0; i < AllBuffs.Length; i++)
		{
			if (!AllBuffs[i].StaysOnDeath)
			{
				AllBuffs.RemoveItem(AllBuffs[i]);
			}
		}
	}
}

// Default properties block
defaultproperties
{
}