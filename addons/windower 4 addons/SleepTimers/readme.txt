Addon: SleepTimers
Version: 1.34
Author: Vhagar

Commands:
Type //sleeptimers or //st for help
//st bard me|other none|mary|nurse|relic
//st showconfig - shows your current bard configuration

Examples:
//st bard me mary - toggles "marys_horn" to true for "your_bard" in the config file, and updates your timers on next cast
//st bard other relic - toggles "gjallarhorn" to 'true' for "other_bard" in the config file, and updates their times on next cast
//st bard other none - toggles all instruments to 'false' for "other_bard" in your config, and resets their sleep timers to 30s for Lullaby

About this addon: 
The purpose of this addon is to give you the ability to track all of your sleep spells the way that Debuffed is supposed to on Windower. Unfortunately on Eden server, Debuffed addon on for Windower doesn't track sleep spells the way it's supposed to. Even with multiple fixes applied to Debuffed, it still fails to track AoE targets, overwrites may not always work correctly, and some spells don't get removed from the list when a mob wakes up early due to partial resists or gets woken up by damage. I was not able to fix this functionality in Debuffed so I made my own serparate addon for tracking sleep spells that works correctly.

Spells currently tracked by this addon:
Sleep
Sleepga
Sleep II
Sleepga II
Foe Lullaby
Horde Lullaby
Repose

Addon Features:
Tracks sleep and lullaby timers for enemies, showing real-time countown bars, for both your sleep spells and others.
Instrument Toggles for both your bard and other bards, so you get correct lullaby timers on the fly. (see commands above)
Correct overwrite logic for spells.
AOE Handling - correctly detects both primary and secondary target hits of spells like Sleepga and Horde Lullaby.
Resist Checks - reads packet messages and only applies sleep timers on success, ignores resisted or immune targets.
Timer Removal - robust, multi-layered 'wake-up' checks for mobs to correctly remove timers when mobs wake up early, whether due to partial resist or from taking damage.
Movable Window - player can drag the window anywhere on the screen.
Auto-Save Position - addon remembers the position by saving x and y to config.lua
Color-Coded Timers - your own spells and timers will appear in green text, while others sleep spells and timers will appear in yellow text.
Made specifically for EdenXI. Uses correct packet IDs and spell IDs for Eden and correct spell durations for this era, all built in.

To do list:
Add support for BLU and COR -
Light Shot
Sheep Song
Pinecone Bomb
Yawn
Soporific
