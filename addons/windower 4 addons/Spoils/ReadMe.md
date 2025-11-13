# Spoils addon for Windower 4

**Spoils** is a lightweight replacement for the broken *Treasure Pool* addon. It displays your current treasure pool in a compact, draggable window right on your screen — no need to type commands or open menus.

### ✨ Features

* Shows all items currently in the treasure pool
* Automatically updates when items drop, are lotted, or distributed
* Drag the display anywhere — position is saved automatically
* Minimal resource usage and clean, readable layout
* Simply type `//lua load Spoils` in game to load the addon

### 📁 Installation

1. Extract or clone this addon into your Windower `addons` folder:

   ```
   Windower/addons/Spoils/
   ```
2. Start Windower and in-game type:

   ```
   //lua load Spoils
   ```
3. Autoload the addon by adding this line:

   ```
   lua load Spoils
   ```

   to your `init.txt` file located at:

   ```
   Windower/scripts/init.txt
   ```

### ⚙️ Settings

The window position is saved automatically to:

```
Windower/addons/Spoils/settings/position.lua
```

### 💬 Commands

* `//spoils clear` — manually clear the display (if needed)
