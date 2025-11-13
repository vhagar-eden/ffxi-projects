# PartyBuffs

Shows party members buffs icons without the necesity of targetting. (Doesn't work on trust and fellow)

Uses the modified icons of FFXIView of this version: https://github.com/KenshiDRK/XiView

## Commands:
```
//pb|partybuffs help (show a list of available commands)
```
```
//pb|partybuffs size 10 (sets the icon size to 10x10)
```
```
//pb|partybuffs size 20 (sets the icon size to 20x20)
```
```
//pb|partybuffs mode w|wlist|white|whitelist (sets whitelist mode)
```
```
//pb|partybuffs mode b|blist|black|blacklist (sets blacklist mode)
```
```
//pb|partybuffs self on|off
```
```
//pb|partybuffs debug on|off
```
## Vhagar's Eden Patch

### Fixes:

- Fixed issue with PartyBuffs not auto-loading properly.
- Fixed issues with PartyBuffs not working correctly after zoning, joining new parties, changing party members, etc.
- PartyBuffs now autoloads properly and never needs to be manually reloaded in order to work. It also handles zoning, and will update new parties, and new members of parties automatically.

### New Features:

- PartyBuffs now tracks your own buffs/debuffs and displays them along with your party!
- PartyBuffs now works even when playing solo and displays your buffs/debuffs next to your name!
- Buff Sorting added! You can now customize the order that buffs appear in the new sorting.lua file!

### Description:

I added some features that I felt were missing from the addon. Previously, the addon only tracked and displayed other party members buffs/debuffs, but not your own. Now it shows your own buffs/debuffs using the same filters and sorting as other party members. It also works when playing solo and automatically adjusts position accordingly. If you want to turn this feature off you can use - //partybuffs self on|off to toggle it on and off as you wish.

Also added sorting options within sorting.lua file found in the addon folder. In the file you will find "priority_left" and "priority_right" lists. Just follow the directions within and add the spell ID's you want to the lists. 

<br />

<img width="271" height="195" alt="Desktop Screenshot 2025 09 04 - 01 25 02 85" src="https://github.com/user-attachments/assets/01941ddb-3d36-4cf1-ad65-bcc07c970fe5" />
<img width="309" height="89" alt="Desktop Screenshot 2025 09 04 - 11 46 36 38" src="https://github.com/user-attachments/assets/68a3d13a-f76b-4439-8952-7660eab64fb7" />

## Download

You can download the latest release of this addon here - https://github.com/vhagar-eden/ffxi-projects/releases/tag/PartyBuffs_v3.7_Windower
