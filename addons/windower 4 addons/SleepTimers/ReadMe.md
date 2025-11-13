# SleepTimers

<img align="right" width="141" height="60" alt="Desktop Screenshot 2025 11 12 - 23 28 25 02" src="https://github.com/user-attachments/assets/7edb8cbc-9102-4d80-ab60-99e3206a1342" />

**Version:** 1.34  
**Author:** Vhagar  

## Commands

Type `//sleeptimers` or `//st` for help

```
/st bard me|other none|mary|nurse|relic
/st showconfig
```

**Examples:**
```
/st bard me mary
```
Toggles `"marys_horn"` to `true` for `"your_bard"` in the config file, and updates your timers on next cast.  

```
/st bard other relic
```
Toggles `"gjallarhorn"` to `true` for `"other_bard"` in the config file, and updates their times on next cast.  

```
/st bard other none
```
Toggles all instruments to `false` for `"other_bard"` in your config, and resets their sleep timers to 30s for Lullaby.  

## About This Addon

The purpose of this addon is to give you the ability to track all of your sleep spells the way that **Debuffed** is supposed to on Windower.  

Unfortunately on Eden server, Debuffed addon for Windower doesn't track sleep spells the way it's supposed to. Even with multiple fixes applied to Debuffed, it still fails to track AoE targets, overwrites may not always work correctly, and some spells don't get removed from the list when a mob wakes up early due to partial resists or gets woken up by damage.  

I was not able to fix this functionality in Debuffed, so I made my own separate addon for tracking sleep spells that works correctly.

## Spells Currently Tracked

- Sleep  
- Sleepga  
- Sleep II  
- Sleepga II  
- Foe Lullaby  
- Horde Lullaby  
- Repose  

## Addon Features

- 💤 Tracks sleep and lullaby timers for enemies, showing real-time countdown bars, for both your sleep spells and others.  
- 🎵 Instrument toggles for both your bard and other bards, so you get correct lullaby timers on the fly. *(See commands above)*  
- 🔄 Correct overwrite logic for spells.  
- 💥 AoE handling – correctly detects both primary and secondary target hits of spells like Sleepga and Horde Lullaby.  
- 🧠 Resist checks – reads packet messages and only applies sleep timers on success, ignoring resisted or immune targets.  
- ⏰ Timer removal – robust, multi-layered 'wake-up' checks for mobs to correctly remove timers when mobs wake up early, whether due to partial resist or from taking damage.  
- 🖱️ Movable window – player can drag the window anywhere on the screen.  
- 💾 Auto-save position – addon remembers the window position by saving X and Y to config.lua.  
- 🌈 Color-coded timers – your own spells and timers will appear in **green**, while others' sleep spells and timers will appear in **yellow**.  
- ✅ Made specifically for **EdenXI** – uses correct packet IDs, spell IDs, and spell durations for this era.  

## To-Do List

Add support for BLU and COR abilities:  
- Light Shot  
- Sheep Song  
- Pinecone Bomb  
- Yawn  
- Soporific

## Download

You can download this addon from my releases page here - https://github.com/vhagar-eden/ffxi-projects/releases/tag/SleepTimers_v1.34_Windower
