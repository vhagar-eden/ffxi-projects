-- Define which buffs should always appear on the left or right.
-- Correct buff IDs can be found in Windower -> res -> buffs.lua
-- Any buffs not listed will appear in their default order

return {
	--the last buff listed in priority_left will appear furthest left
    priority_left = {
		7,	--petrification
    },
	--the first buff listed in priority_right will appear furthest right
    priority_right = {
        40,	--protect
		41,	--shell
		66, 444, 445, 446, --Copy Image 1, 2, 3, 4,
		33,	--haste
		43,	--refresh
		42, --regen
		37, --stoneskin
		36, --blink
		116, --phalanx
    }
}


