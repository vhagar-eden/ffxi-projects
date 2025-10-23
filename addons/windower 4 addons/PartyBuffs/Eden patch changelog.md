PartyBuffs — Changelog (v3.2 → v3.7 Vhagars Eden patch)

v3.2 — baseline (original provided by Eden)

Status: Original release
.
What it did:
Core PartyBuffs functionality: parse incoming buff packets (0x076), map buff IDs to icons, and display other party members’ buff icons near party window.
Supported whitelist/blacklist modes and used numeric sorting of buff IDs.
Created 32 image placeholders per party slot, and basic update/draw logic.
Known problems (that we addressed later):
Addon sometimes failed to initialize correctly at login (needed manual reload).
Party change detection could miss events, so new invites/zones could require a reload or another buff cast to show icons.
No self (player) buff row.

v3.3 — reliability fixes

What changed:
Added safer load-time logic and small scheduling fixes to reduce cases where the addon would be unloaded or not initialized at startup.
Introduced scheduled buff_sort() calls after key incoming chunk events (0x0DD / party changes) to make buff refreshes more reliable.

Why:
To reduce cases where the addon appeared to load but didn’t show icons until a manual reload or another buff was cast.

Impact:
Improved startup stability in some cases, but still not fully robust on Eden (edge cases remained).

v3.4 — prerender poller + zone/party handling (prerender-fix)

What changed:
Added a prerender poller: a lightweight loop that runs roughly once per second to check party composition and detect joins/leaves reliably even if packets are missed.
Rebuilt the member-name/id mapping using windower.ffxi.get_party() and used a party_signature() to detect changes.
On zone change/login/load, the addon seeds itself from the freshest 0x076 snapshot (via windower.packets.last_incoming(0x076)) when available.

Why:
Incoming packet-based detection alone was not always reliable. Polling for party changes ensured consistent detection without aggressive CPU use.

Impact:
Party joins/leaves are detected consistently without needing manual reloads.
Buffs now show more reliably after zoning and login.

v3.4-self-lite / v3.4-prerender-fix → (self row experiments)

What changed:
Experimental addition of a self row to display the player’s own buffs in the same style as party rows (initial attempt).
Attempted to integrate self filters & sorting with existing logic.

Issues found:
Filters for self and others were broken in the first experiment; ghost icons appeared (leftover images were not cleared properly when buffs expired or were filtered).
Too much shared state between self and party logic caused unexpected side effects.

Next step:
Rework to keep self row logic separate/isolated from party logic (prevent ghost icons, maintain filters).

v3.4-self-lite (refactor) — self row kept isolated

What changed:
Rewrote self-row logic to be isolated:
Dedicated self_images (32 image objects).
Dedicated self_vec (32-slot buffer).
Dedicated UpdateSelf() drawing function separate from party drawing.
apply_filters_to_vec() and sort_vec() operate only on the self data.
Made UpdateSelf() run each prerender tick to keep player buffs accurate and avoid ghost icons.
Kept party member code unchanged to avoid regressions.

Why:
Isolating self logic removed cross-talk that caused ghost icons and filtering bugs.

Impact:
Self-row displays reliably, is filtered/sorted independently, and no longer leaves ghost icons when buffs expire.

v3.5 — self-row toggle + polish

What changed:
Added config setting: defaults.self_row = true persisted via config.load and settings:save().
New command: //pb self on|off — immediately enables/disables the self row and persists the choice.
Added helper hide_self_row() to cleanly clear/hide the 32 self image objects when disabled.
Integrated the toggle so UpdateSelf() only runs when settings.self_row is true (and hide_self_row() otherwise).
Ensured that on load/login/zone/status change, the self row respects the saved setting.

Why:
Gives users the option to toggle self buffs on/off.

Impact:
You can now toggle the self row at runtime; the addon remembers the setting between sessions.

v3.6 — priority sorting (sorting.lua) — configurable left/right priorities

What changed:
Introduced an optional external sorting.lua file (in the addon folder) that returns two arrays:
priority_left — buff IDs you want prioritized on one side
priority_right — buff IDs you want prioritized on the other side
Implemented sort_with_priority(vec):
Builds a presence map of buff IDs.
Pulls priority_left entries (in listed order), then middle (remaining IDs sorted numerically), then priority_right (in listed order).
Pads to 32 entries with 1000 as blanks so images clear reliably (preventing ghosts).
Integrated sort_with_priority for both:
Party members: we construct a 32-vector from possibly-sparse buff tables and replace the buff table with the sorted vector for display.
Self row: self vectors are passed through the same priority sorting for consistent behavior.

Why:
Gives users the ability to sort the buffs/debuffs that appear in the list next to their names.
External sorting.lua keeps customization outside core code and editable without touching main addon.

Impact:
You can now list buffs to prioritize left or right by edit to sorting.lua. Sorting is applied for both self and party rows.

v3.7 — final polish: left/right direction fix + final tweaks (Vhagars Eden patch)

What changed:
Fixed a visual inversion: the initial priority implementation produced swapped sides (priority_right appeared left and vice versa) due to how screen X coordinates decrease to the left.
Swapped how sort_with_priority combines lists so they appear as intended.

Ensured consistent behavior across:
Party members rows
Self row
All update events (load/login/zone/prerender/status change)

Minor polish:
Ensure pcall(require, 'sorting') gracefully falls back to numeric-only sorting when sorting.lua is absent.
Exposed small debug messages (//pb debug on|off) to trace party signatures and priority sorting behavior during testing.
Confirmed padding and clearing prevent ghost icons in all observed cases.

Why:
The naming priority_left/priority_right is user-facing/intentional; users expected items in priority_right to appear visually on the right side. The coordinate system meant our first combine order produced the opposite effect.

Impact:
Final release matches users expectation: priority arrays in sorting.lua now place icons on the correct screen side.
Addon is stable, robust on Eden, and configurable.
