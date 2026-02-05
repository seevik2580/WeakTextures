# WeakTextures - Complete User Guide

## Table of Contents
1. [What is WeakTextures?](#what-is-weaktextures)
2. [Getting Started](#getting-started)
3. [Creating Your First Preset](#creating-your-first-preset)
4. [Display Settings](#display-settings)
5. [Load Conditions](#load-conditions)
6. [Advanced Conditions & Triggers](#advanced-conditions--triggers)
7. [Multi-Instance Mode](#multi-instance-mode)
8. [WeakTexturesAPI](#weaktexturesapi)
9. [Import & Export](#import--export)
10. [Profiles](#profiles)
11. [Search & Filters](#search--filters)
12. [Settings](#settings)
13. [Tips & Tricks](#tips--tricks)

---

## What is WeakTextures?

WeakTextures is a powerful World of Warcraft addon that allows you to display custom textures and animations on your screen based on various conditions. This is not WeakAuras and never will be! It was designed for displaying textures and maybe play some sounds. If you looking for addon that will tell you have to move from fire then you are in bad place.

**Use case:**
- Display custom textures for your UI. Set some load condition when you want your texture to be shown like Housing, Dead, Alive, Pet Battle, Rested, Vehicle or code your own Advanced custom trigger
    - advanced example: Pull timer. With your own countdown sounds, and textures like "Semaphor".


## Getting Started

### Opening WeakTextures
- Type `/weaktextures` in chat or click on Minimap button

### Main Interface
The addon window has two main sections:
- **Left Panel**: Preset list with groups, search, and filters
- **Right Panel**: Preset configuration with three tabs:
  - Display settings
  - Load Conditions
  - Advanced

---

## Creating Your First Preset

### Step 1: Create New Preset
1. Click **"Create new"** button at the bottom
2. Enter a **Preset Name** (e.g., "My First Texture")
3. Choose a **Group** or leave as "Ungrouped"

### Step 2: Configure Display Settings
1. **Texture Path**: Choose a texture from the dropdown or enter a custom path
   - Path formats: 
        - `Interface\AddOns\YourAddon\Textures\texture.tga`
        - `Interface/AddOns/YourAddon/Textures/texture.tga`
2. **Type**: Static (single image) or Stop Motion (animated sprite sheet)
3. **Strata**: Layer priority (BACKGROUND, LOW, MEDIUM, HIGH, etc.)
4. **Level**: Fine-tune layer within strata
5. **Anchor Frame**: Where the texture is attached (default: Screen (UIParent))
6. **Width & Height**: Size in pixels
7. **X & Y**: Position offset from anchor center
8. **Scale**: Multiplier for size (1.0 = 100%)
9. **Alpha**: Transparency (0.0 = invisible, 1.0 = solid)
10. **Angle**: Rotation in degrees

#### If **Stop Motion** type selected:
11. **Columns**: Number of columns in sprite sheet (horizontal frames)
12. **Rows**: Number of rows in sprite sheet (vertical frames)
13. **Total Frames**: Total number of animation frames in the sprite sheet
14. **FPS**: Animation speed in frames per second

### Step 3: Save
Click **"Save changes"** button

### Step 4: Position Your Texture
1. Click **"Unlock position"** to enter drag mode
2. Drag the texture to desired position
3. Use arrow buttons for fine adjustment
4. Resize using yellow grip (bottom-right corner)
5. Rotate using cyan grip (top-right corner)
6. Click **"Lock position"** or **"Save changes"** when done

---

## Display Settings

### Basic Information
- **Preset Name**: Unique identifier for this preset
- **Group**: Organize presets into folders. 
    - When creating new group with subgroups you have to write in format like this "GroupName/SubgroupName1/SubgroupName2/...."

### Texture and Frame Settings
- **Texture Path**: Path to your texture file
  - Supports TGA, PNG, BLP, JPEG file formats,
- **Type**: 
  - **Static**: Single image
  - **Stop Motion**: Animated sprite sheet (requires Columns, Rows, Total Frames, FPS)
- **Anchor Frame**: Parent frame (Screen, PlayerFrame, TargetFrame, etc.)
- **Strata**: Rendering layer priority
- **Level**: Fine-tune within strata

### Visual Settings
- **Width/Height**: Texture dimensions
- **X/Y Offset**: Position relative to anchor center
- **Scale**: Size multiplier (affects all dimensions)
- **Angle**: Rotation in degrees (0-360)
- **Alpha**: Opacity (0.0-1.0)

### Stop Motion Animation Settings
These fields appear only when **Type** is set to "Stop Motion":
- **Columns**: Number of horizontal frames in the sprite sheet
- **Rows**: Number of vertical frames in the sprite sheet
- **Total Frames**: Total animation frames to play
- **FPS**: Animation playback speed 

### Position Lock/Unlock
- **Unlock position**: Enable interactive positioning
  - Drag texture to move
  - Arrow buttons for precise movement
  - Yellow grip: resize
  - Cyan grip: rotate
- **Lock position**: Disable interactive mode and save

---

## Load Conditions

Control when your preset is visible based on character state and environment.

### Loading
- **Enabled**: Master switch - preset won't show if unchecked
- **Advanced Conditions**: Enable event-based triggers (see Advanced section)

### Character Conditions
- **Class**: Show only for specific classes
- **Spec**: Show only for specific specializations
- **Player Name**: Show only for specific character names (comma-separated)

### State Conditions (Three-State Checkboxes)
##### Legend
- Unchecked = ignore this condition
- Checked with green label = show when condition is true
- Checked with red label = show when condition is false
##### Conditions
- **Alive**: <span style="color:green">Player is alive</span> / <span style="color:red">Player is dead</span>
- **Combat**: <span style="color:green">Player is in combat</span> / <span style="color:red">Player is out of combat</span>
- **Rested**: <span style="color:green">Player is in rested zone</span> / <span style="color:red">Player is not in rested zone</span>
- **Instance**: <span style="color:green">Player is in any dungeon or raid or delve or any other instance types</span> / <span style="color:red">Player is not in any dungeon or raid or delve or any other instance types</span>
- **Encounter**: <span style="color:green">Player is in boss encounter</span> / <span style="color:red">Player is not in boss encounter</span>
- **Pet Battle**: <span style="color:green">Player is in pet battle</span> / <span style="color:red">Player is not in pet battle</span>
- **Vehicle**: <span style="color:green">Player is in vehicle</span> / <span style="color:red">Player is not in vehincle</span>
- **Home**: <span style="color:green">When at plot or inside house</span> / <span style="color:red">When not at plot or inside house</span>

### Zone Condition
- Enter zone name to show only in that zone
- Case-insensitive partial match. e.g. Orgrimmar

---

## Advanced Conditions & Triggers

Advanced conditions allow you to show/hide textures based on game events and custom Lua logic.

### Enabling Advanced Mode
1. Go to **Load Conditions** tab
2. Check **"Advanced Conditions"**
3. Switch to **Advanced** tab

### Events
**Events** are WoW game events that trigger your code to run. No custom evets. Only blizzard events are supported
**Format:** Comma-separated event names
```
PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED
```

**Common Events:**
- `PLAYER_REGEN_DISABLED`: Entered combat
- `PLAYER_REGEN_ENABLED`: Left combat
- `PLAYER_TARGET_CHANGED`: Changed target
- `PLAYER_SPECIALIZATION_CHANGED`: Changed spec

**Note:** `COMBAT_LOG_EVENT_UNFILTERED` is blacklisted because of addon limitations so we can no longer read CLEU.

Find more events: https://warcraft.wiki.gg/wiki/Events

### Trigger Function

The **Trigger Function** is Lua code that runs when events fire.
- Must **return true** to show texture
- Must **return false** to hide texture

**Basic Example - Show in Combat:**
**Events to use:** `PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED`
```lua
function(e)
    return InCombatLockdown()
end
```

**Example - Show When Target is Enemy:**
**Event to use** `PLAYER_TARGET_CHANGED`
```lua
function(e)
    return UnitCanAttack("player", "target")
end
```

### Duration
**Duration**: Auto-hide after X seconds when trigger returns true
- Leave at 0 for manual control
- Useful for temporary notifications

### Error Messages
- Error messages appear below the trigger editor
- Line numbers highlight errors in red

---

## Multi-Instance Mode

Multi-instance mode allows multiple copies of the same texture to appear simultaneously. This is useful for notification systems, timers, or any scenario where you need multiple independent texture instances on screen at once.

### Enabling Multi-Instance
1. Go to **Advanced** tab
2. Check **"Multi-Instance"**
3. Max instances: 10

### Using Multi-Instance in Triggers

Instead of returning true/false, create instances manually:

```lua
function(e)
    WeakTexturesAPI:CreateInstance({
        text = "Notification!",
        sound = "Interface\\AddOns\\YourAddon\\Media\\Sounds\\alert.ogg"
    })
end
```

### CreateInstance Parameters

```lua
WeakTexturesAPI:CreateInstance({
    text = "...",
    offsetX = 100,
    offsetY = 100,
    scale = 1.0,
    alpha = 1.0,
    font = "Friz Quadrata TT",  -- LSM font name OR "Interface\\...\\font.ttf" 
    fontSize = 12,
    fontOutline = "OUTLINE",  -- "", "OUTLINE", "THICKOUTLINE", "MONOCHROME"
    textColor = {r, g, b, a},
    textOffsetX = 0,
    textOffsetY = 0,
    textLeftPoint = "LEFT",
    textRightPoint = "RIGHT",
    texture = "WT_semaphor-red",  -- LSM texture name OR "Interface\\...\\texture.tga"
    sound = "BigWigs: Alarm",  -- LSM sound name OR "Interface\\...\\sound.ogg"
    soundChannel = "Master"
})
```

**LibSharedMedia (LSM) Support:**
- If parameter contains `/` or `\\` = treated as full path
- If no slashes = treated as LSM registered name
- **WT_** prefix: Your own custom textures registered in WeakTextures
- Other names: Shared resources from other addons (e.g., "BigWigs: Alarm", "StonesMedia kick")

### Multi-Instance Advanced Trigger Example - Notification System

**Note:** Due to Blizzard's AddOns restrictions (secrets), most combat-related values (health, damage, cooldowns) cannot be tracked by addons. Use non-combat related events and values instead.  Chat events may have restrictions in instances depending on Blizzard's policies.

**Events to use:** `CHAT_MSG_WHISPER, CHAT_MSG_BN_WHISPER`
**Duration:** 1
```lua
function(e, ...)
    if e == "CHAT_MSG_WHISPER" then
        local message, sender = ...
        if string.find(message, "pi me") then
            WeakTexturesAPI:CreateInstance({
                text = "Requested PI from\n" .. sender,
                texture = "Interface\\ICONS\\spell_holy_powerinfusion",
                offsetY = 200,
                textColor = {1, 0.5, 1, 1},
                sound = "BigWigs: Alarm"  -- LSM sound from BigWigs addon
            })
        end
    end
end
```

**Note:** `WeakTexturesAPI:CreateInstance()` works in both single-instance and multi-instance modes:
- **Single-instance**: Reconfigures the existing frame with new properties
- **Multi-instance**: Creates a new separate frame instance

### Single-Instance Advanced Trigger Example - Level Up Notification

**Event to use:** `PLAYER_LEVEL_UP`
```lua
function(e)
    local level = UnitLevel("player")
    WeakTexturesAPI:CreateInstance({
        text = "Level " .. level .. "!",
        offsetY = 0,
        scale = 1.5,
        textColor = {1, 0.84, 0, 1},
        sound = "Interface\\AddOns\\YourAddon\\Media\\Sounds\\levelup.ogg"
    })
    return true
end
```

### Single Instance Advanced Trigger Example - Dynamic Texture Based on Target Type

**Events to use:** `PLAYER_TARGET_CHANGED, UNIT_CLASSIFICATION_CHANGED`
```lua
function(e)
    if not UnitExists("target") then
        return false
    end
    
    local texPrefix = "Interface\\AddOns\\YourAddon\\Media\\"
    local targetType = {
        ["elite"] = texPrefix .. "Elite.tga",
        ["worldboss"] = texPrefix .. "Boss.tga",
        ["rareelite"] = texPrefix .. "RareElite.tga",
        ["rare"] = texPrefix .. "Rare.tga",
        ["normal"] = texPrefix .. "Normal.tga",
    }
    
    local classification = UnitClassification("target")
    local texturePath = targetType[classification] or targetType["normal"]
    
    -- Change texture using CreateInstance in single-instance mode
    WeakTexturesAPI:CreateInstance({
        texture = texturePath
    })
    
    return true
end
```

### Single Instance Advanced Trigger Example - Dynamic Texture Based on Pull Timer

**Event to use:** `START_PLAYER_COUNTDOWN`
```lua
function(e, ...)
    local _, duration = ...
    if duration == nil then
        duration = 10
    end
    
    local prefix = "Interface\\AddOns\\WeakTextures\\Media\\"
    
    -- Default for all CreateInstance
    local defaultConfig = {
        textOffsetX = 50,
        font = "Friz Quadrata TT",  -- LSM font name
        fontSize = 20,
        fontOutline = "THICKOUTLINE",
        textColor = {r=1, g=1, b=1, a=1},
        soundChannel = "MASTER"
    }
    
    local media = {
        textures = {
        [3] = prefix .. "Textures\\semaphor-red.png",
        [2] = prefix .. "Textures\\semaphor-yellow.png",
        [1] = prefix .. "Textures\\semaphor-yellow.png",
        [0] = prefix .. "Textures\\semaphor-green.png",
        },
        sounds = {
        [3] = prefix .. "Sounds\\3.ogg",
        [2] = prefix .. "Sounds\\2.ogg",
        [1] = prefix .. "Sounds\\1.ogg"
        }
    }
    
    local function config(overrides)
        local result = {}
        -- Copy default
        for k, v in pairs(defaultConfig) do
        result[k] = v
        end
        -- Rewrite values
        if overrides then
        for k, v in pairs(overrides) do
            result[k] = v
        end
        end
        return result
    end
    
    -- Countdown 3, 2, 1
    for i = 3, 1, -1 do
        C_Timer.After(duration - i, function()
            WeakTexturesAPI:CreateInstance(config({
                texture = media.textures[i],
                text = tostring(i),
                sound = media.sounds[i]
            }))
            WeakTexturesAPI:RefreshPreset(true) -- true will show changed parameters
        end)
    end
    
    -- When countdown expires
    C_Timer.After(duration, function()
        WeakTexturesAPI:CreateInstance(config({
                texture = media.textures[0],
                text = "GO!",
                fontSize = 50,  -- Override default
                textOffsetX=100, -- Override default
                textColor = {r=0, g=1, b=0, a=1}  -- Override default
        }))
        WeakTexturesAPI:RefreshPreset(true) -- true will show changed parameters
    end)
    
    -- Hide preset 1 second after countdown ends
    C_Timer.After(duration + 1, function()
        WeakTexturesAPI:RefreshPreset(false) -- false will hide preset
    end)  
end
```

---

## WeakTexturesAPI

Public API for interacting with WeakTextures from macros, other addons, or triggers.

### IdentifyPreset()
Identify which preset is under your mouse cursor.

```lua
/run WeakTexturesAPI:IdentifyPreset()
```

Prints the preset name to chat.

### GetPresetInfo(presetName)
Get information about a preset.

```lua
/run local info = WeakTexturesAPI:GetPresetInfo("MyPreset") ; print(info.enabled, info.type, info.width, info.height)
```

Returns table with: name, enabled, type, group, isActive, anchor, width, height, x, y, scale, alpha, strata, level

### ListActivePresets()
Returns all currently visible presets.

```lua
/run WeakTexturesAPI:ListActivePresets()
```

also prints if debug enabled

### EnableMultiInstance(presetName, maxInstances)
Enable multi-instance mode for a preset.

```lua
/run WeakTexturesAPI:EnableMultiInstance("MyPreset", 10) -- you can override max instances with this, default is 10
```

### DisableMultiInstance(presetName)
Disable multi-instance mode.

```lua
/run WeakTexturesAPI:DisableMultiInstance("MyPreset")
```

### TestInstance(presetName, text, sound)
Test creating an instance from console.

```lua
/run WeakTexturesAPI:TestInstance("MyPreset", "Test Text", "Interface\\AddOns\\...\\sound.ogg")
```

### CreateInstance(data)
Create an instance with custom parameters (use inside triggers).

**Note:** Can only be called from within a trigger function! The API automatically knows which preset is calling it.

```lua
-- Inside trigger function:
WeakTexturesAPI:CreateInstance({
  text = "Hello",
  offsetX = 50
})
```

### RefreshPreset(showTexture)
Show or hide preset based on boolean (use inside triggers). Good example is Pull timer where you want to dynamicaly change texture with countdown.

```lua
-- Inside trigger function:
WeakTexturesAPI:RefreshPreset(true)  -- Show and refresh with new params
WeakTexturesAPI:RefreshPreset(false) -- Hide
```

---

## Import & Export

Share presets with other players or backup your work.

### Exporting Presets

**Export Single Preset:**
1. Right-click preset in list
2. Select **"Export"**
3. Copy the string from the window

**Export Multiple Presets:**
1. Select first preset
2. Hold Ctrl and click additional presets
3. Right-click and select **"Export"**

**Export Entire Group:**
1. Right-click group name
2. Select **"Export Group"**
3. Copy the string

### Importing Presets

1. Click **"Import"** button
2. Paste the import string into the text box
3. Click **"Accept import"**

**Import Behavior:**
- If preset name exists, it will be renamed to "Name (Copy)"
- Groups are automatically created if they don't exist
- All settings are preserved

### Sharing Tips
- Use Pastebin or similar sites for long strings
- Include usage instructions with your presets
- Test imported presets before sharing

---

## Profiles

Profiles allow different characters to have different preset configurations.

### Default Profile
Every character starts with the "Default" profile containing all presets.

### Creating Profiles

**From Settings Panel:**
1. Click **"Settings"** button
2. Go to Profiles section
3. Enter new profile name
4. Click **"Create"**

**From Dropdown:**
1. Click profile dropdown (top-left)
2. Type new profile name
3. Click **"Create new profile"**

### Switching Profiles
Select profile from dropdown menu (top-left)

### Copying Profiles
1. Select source profile
2. Click **"Copy from"**
3. Select target profile
4. All presets are copied

### Deleting Profiles
1. Select profile to delete
2. Click **"Delete"**
3. Confirm deletion
4. Cannot delete "Default" profile

### Profile Use Cases
- **Multiple Characters**: Different presets per character
- **PvE vs PvP**: Different textures for different content
- **Role-Based**: Separate profiles for Tank/Healer/DPS
- **Testing**: Create test profile without affecting main setup
###### You need to manualy switch profile if you want one for PvP and another for PvE. There are no load conditions for profiles.

---

## Search & Filters

Quickly find presets in large collections.

### Search Box
Located at the bottom of the left panel.

**Features:**
- Type to search preset names
- Case-insensitive
- Real-time filtering
- Searches within groups

**Example:**
- Search "health" to find all health-related presets (if preset contains "health" word in name)

### Filter Panel
Click **"Filter"** button to open advanced filters.

**Filter Categories:**

### Character Filters
- **Class**: Show only presets for specific class
- **Spec**: Show only presets for specific spec (requires class selection)

### State Filters (Three-State)
- **Combat**: Filter by combat condition
- **Encounter**: Filter by boss encounter condition  
- **Alive**: Filter by alive/dead condition
- **Rested**: Filter by rested condition

### Environment Filters (Three-State)
- **Vehicle**: Filter by vehicle condition
- **Instance**: Filter by instance condition
- **Housing**: Filter by player housing condition

### Advanced Filter
- **Advanced**: Show only presets using advanced conditions

### Filter Behavior
- Multiple filters combine with AND logic
- Three-state filters: Unchecked = ignore, Checked with green label = must be true, Checked with red label = must be false
- Groups with no matching presets are hidden

### Clearing Filters
- Uncheck all filters

---

## Settings

Access global addon settings (not per-preset).

### Interface Settings
- **Language**: Choose addon interface language (English, Deutsch)
- **Font**: Custom font for addon UI
- **Scale**: UI scale multiplier

### Minimap Icon
- Toggle minimap button visibility
- Drag icon to reposition

### Profile Management
- Create/Delete/Copy profiles
- Switch active profile
- Export/Import entire profiles

### Debug Mode
- Enable debug messages in chat
- Useful for troubleshooting triggers
- Shows event firing and frame creation

### Reset
- **Clear all presets**: Delete all presets (cannot be undone!)

---

## Tips & Tricks

### Use magick to easily convert gifs into TGA grid
```
magick montage mygif.gif -coalesce \
    -resize 256x128^ \
    -gravity center \
    -background none \
    -extent 256x256 \
    -label '' \
    -tile 4x \
    -geometry +0+0 \
    mygif.tga
```

### Performance
- Use Advanced Conditions only when needed
- Avoid rapidly firing events when possible
- Limit number of active presets
- Use appropriate stratas to reduce overdraw

### Organization
- Use groups to organize presets by purpose
- Name presets descriptively
- Use prefixes: "Combat - ", "UI - ", "Class - "
- Export groups as backups

### Positioning
- Unlock multiple presets to compare positions
- Use grid addons for alignment
- Note X/Y coordinates for symmetrical layouts
- Test at different UI scales

### Trigger Best Practices
- Keep trigger functions simple
- Cache values when possible
- Use `_G.WT_variable` for persistence between events
- Return early to avoid unnecessary processing

### Debugging Triggers
1. Enable Debug Mode in Settings
2. Check chat for error messages
3. Use simple test cases first
4. Add print statements: `print("Value:", value)`

---

## Resources

- **Warcraft Wiki**: https://warcraft.wiki.gg/
- **Events Reference**: https://warcraft.wiki.gg/wiki/Events

# Common Issues

**Texture not showing:**
- Check "Enabled" checkbox
- Verify load conditions are met
- Check strata/level (might be behind other frames)
- Unlock position to verify texture exists
- Verify anchor for texture is visible

**Trigger not firing:**
- Check event names are correct
- Enable Debug Mode to see events
- Verify trigger function returns boolean
- Check error messages below trigger editor

**Import not working:**
- Verify string is complete (no truncation)
- Check for special characters
- Try importing single preset first

**Performance issues:**
- Reduce number of active presets
- Simplify trigger functions
- Avoid high-frequency events (some events updates rapidly)
- Use duration to auto-hide instead of constant checking

---

## Conclusion

WeakTextures is a flexible tool for creating custom visual elements in World of Warcraft. Start simple with static textures and basic conditions, then explore advanced triggers and multi-instance mode for complex behaviors.

**Remember:**
- Test thoroughly before relying on presets in important content
- If you are unsure with what you are doing i suggest create new profile to test it there.
- Export your presets regularly as backups
- Share your creations with others

Now go! Unleash your imagination and wish you happy texturing!
