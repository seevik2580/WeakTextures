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

### Text Settings
Configure default text appearance for this preset. These settings serve as **fallback values** for `CreateInstance()` calls:
- **Text Content**: Default text to display (can be empty for dynamic text)
- **Font**: Font family (supports LibSharedMedia fonts)
- **Font Size**: Text size in pixels
- **Font Outline**: "OUTLINE", "THICKOUTLINE", or "MONOCHROME"
- **Text Color**: RGBA color picker
- **Text Offset X/Y**: Position relative to texture center

**Note:** When using Advanced Triggers with `CreateInstance()`, these values are automatically used unless you override them. This allows you to configure styling in UI and keep Lua code minimal!

### Sound Settings
Configure default sound for this preset:
- **Sound**: Sound file or LibSharedMedia sound name (choose "None" for no sound)
- **Sound Channel**: "Master", "SFX", "Music", "Ambience", "Dialog"

**Note:** Default sound plays when preset is shown. In `CreateInstance()`, you can override with different sounds or use timeline to play sounds at specific times.

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

### UI Default Settings

Before diving into CreateInstance parameters, it's important to understand that **you can configure default values in the UI**:

**Display Settings Tab:**
1. **Text Settings** section in UI allows you to set:
   - **Default Font**: Font family (e.g., "Friz Quadrata TT")
   - **Default Font Size**: Text size in pixels
   - **Default Font Outline**: "OUTLINE", "THICKOUTLINE", or "MONOCHROME"
   - **Default Text Color**: RGBA color picker
   - **Default Text Offset X/Y**: Text positioning relative to frame center
   - **Default Text Content**: Static text to display (can be overridden per instance)

2. **Sound Settings** section in UI allows you to set:
   - **Default Sound**: Sound file or LSM sound name
   - **Default Sound Channel**: "Master", "SFX", "Music", etc.

**How UI Defaults Work:**
- These settings serve as **fallback values** for all instances of this preset
- If you don't specify a parameter in `CreateInstance()`, the UI default is used
- If you don't specify a parameter in timeline `update`, the CreateInstance value (or UI default) is used
- This means you can set font, color, and offset once in UI, then only override when needed

**Example:**
```lua
-- UI Settings: Font="Friz Quadrata TT", Size=24, Color=Red, OffsetY=100

-- This instance uses ALL UI defaults (font, size, color, offset)
WeakTexturesAPI:CreateInstance({
    text = "Using UI defaults"
})

-- This instance overrides only color, keeps UI font/size/offset
WeakTexturesAPI:CreateInstance({
    text = "Custom color",
    textColor = {r=0, g=1, b=0, a=1}  -- Green instead of UI red
})

-- Timeline: Changes text but keeps ALL other UI defaults
WeakTexturesAPI:CreateInstance({
    timeline = {
        {delay = 1, update = {text = "Step 1"}},  -- UI font/size/color/offset
        {delay = 2, update = {text = "Step 2"}},  -- Still UI defaults
        {delay = 3, destroy = true}
    }
})
```

### How CreateInstance Works

When you call `CreateInstance()`, the parameters you provide become **default values for the entire instance lifetime**:

1. **Initial Creation**: Frame is created with your specified parameters
2. **Timeline Events**: Only update the specific parameters you mention in each event
3. **Other Parameters**: Remain at their default values from CreateInstance (or preset defaults if not specified)

**Example:**
```lua
WeakTexturesAPI:CreateInstance({
    alpha = 0,      -- Start invisible
    fontSize = 24,  -- This fontSize applies to ALL timeline events unless overridden
    timeline = {
        {delay = 0.5, update = {alpha = 1}},              -- Fade in, fontSize stays 24
        {delay = 2.0, update = {text = "Hello"}},         -- Change text, fontSize still 24
        {delay = 3.0, update = {fontSize = 48}},          -- NOW fontSize changes to 48
        {delay = 5.0, destroy = true}
    }
})
```

**Important:** Timeline events do NOT restart animations! This makes timeline perfect for stop-motion animations where you want to change other properties (text, position, alpha) while animation continues to play.

### CreateInstance Parameters

```lua
WeakTexturesAPI:CreateInstance({
    -- Display properties
    width = 500,              -- Texture width in pixels
    height = 500,             -- Texture height in pixels
    anchor = "UIParent",      -- Parent frame name
    x = 0,                    -- Base position X (relative to anchor center)
    y = 100,                  -- Base position Y (relative to anchor center)
    offsetX = 50,             -- Additional offset X
    offsetY = -20,            -- Additional offset Y
    scale = 1.5,              -- Size multiplier
    angle = 45,               -- Rotation in degrees (0-360)
    alpha = 1.0,              -- Transparency (0.0-1.0)
    
    -- Texture settings
    texture = "WT_semaphor-red",  -- LSM texture name OR "Interface\\...\\texture.tga"
    color = {r=1, g=0.5, b=0.5, a=1},  -- Vertex color (tints the entire texture)
    type = "static"           -- or motion! you can change it on the fly
    
    -- Layering
    strata = "HIGH",          -- "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"
    frameLevel = 200,         -- Fine-tune layer within strata (0-999)
    
    -- Stop Motion animation (only for presets with type="motion")
    columns = 8,              -- Number of columns in sprite sheet
    rows = 4,                 -- Number of rows in sprite sheet
    totalFrames = 32,         -- Total animation frames to play
    fps = 24,                 -- Animation speed (frames per second)
    
    -- Text overlay
    text = "Hello",
    font = "Friz Quadrata TT",        -- LSM font name OR "Interface\\...\\font.ttf"
    fontSize = 24,
    fontOutline = "OUTLINE",          -- "", "OUTLINE", "THICKOUTLINE", "MONOCHROME"
    textColor = {r=1, g=1, b=1, a=1},
    textOffsetX = 0,
    textOffsetY = 50,
    textLeftPoint = "CENTER",         -- Anchor point on text
    textRightPoint = "CENTER",        -- Anchor point on frame
    
    -- Sound
    sound = "BigWigs: Alarm",         -- LSM sound name OR "Interface\\...\\sound.ogg"
    soundChannel = "Master",          -- "Master", "SFX", "Music", "Ambience", "Dialog"
    
    -- Timeline: Array of events that update parameters over time
    -- Each event fires at absolute time from CreateInstance call (not relative to previous event)
    -- Only updates specified parameters - others remain at their default values
    -- Does NOT restart animations - perfect for stop-motion!
    timeline = {
        {delay = 0.5, update = {alpha = 1}},  -- After 0.5s, fade in
        {delay = 2.0, update = {text = "New text", angle = 60, scale = 1.5}},  -- After 2s, change multiple params
        {delay = 5.0, update = {alpha = 0}},  -- After 5s, fade out
        {delay = 5.5, destroy = true}  -- After 5.5s, destroy instance
    }
})
```

**Timeline Events:**
Each timeline event can have:
- `delay` (number): Time in seconds from CreateInstance call when this event fires (absolute time, not relative!)
- `update` (table): Parameters to update (any parameter from CreateInstance)
- `destroy` (boolean): If true, destroys the instance immediately

**Timeline Features:**
- **Absolute Timing**: All delays are measured from CreateInstance call, not from previous event
- **Partial Updates**: Only updates parameters you specify - others keep their default values
- **No Animation Restart**: Changing parameters doesn't restart stop-motion animations
- **Destroy Precedence**: If timeline contains destroy event, preset's Duration auto-hide is ignored
- **Automatic Cleanup**: All timeline timers are canceled if instance is destroyed early

**Minimal Example - Timeline Only:**
```lua
-- Parameters from CreateInstance become defaults for ALL timeline events
WeakTexturesAPI:CreateInstance({
    fontSize = 24,     -- This fontSize applies to ALL timeline events below
    fontOutline = "THICKOUTLINE",  -- This too!
    timeline = {
        {delay = 0, update = {alpha = 0, texture = "Interface\\Icons\\inv_misc_questionmark"}},  -- Start invisible, fontSize = 24
        {delay = 0.5, update = {alpha = 1, text = "Hello!"}},  -- Fade in with text, fontSize still 24
        {delay = 2.0, update = {angle = 180, fontSize = 48}},  -- Rotate AND change fontSize to 48
        {delay = 3.0, destroy = true}  -- Destroy instance (ignores preset Duration)
    }
})
```

**All parameters are optional!** If you don't specify a parameter in CreateInstance:
1. **Text Parameters** (font, fontSize, fontOutline, textColor, textOffsetX/Y, text content): Use values from **Display Settings → Text Settings** in UI
2. **Sound Parameters** (sound, soundChannel): Use values from **Display Settings → Sound Settings** in UI
3. **Other Parameters** (width, height, alpha, scale, etc.): Use preset's default values from **Display Settings**

This means you can configure most styling in the UI and keep your Lua code minimal!

**Timeline Example - Smooth Fade:**
```lua
-- UI Settings: Font="PT Sans Narrow Bold", Size=30, Color=Cyan, Outline="THICKOUTLINE"
-- All timeline events will use these UI defaults unless overridden!

-- Helper function to generate fade events
local function fade(startDelay, duration, fromAlpha, toAlpha, steps)
    local events = {}
    local alphaStep = (toAlpha - fromAlpha) / steps
    local timeStep = duration / steps
    
    for i = 1, steps do
        local delay = startDelay + timeStep * i
        local alpha = fromAlpha + alphaStep * i
        table.insert(events, {delay = delay, update = {alpha = alpha}})
    end
    
    return events
end

-- Build timeline with smooth fade in and fade out
local timeline = {}

-- Fade in: 0 to 1 over 0.5s in 10 steps (UI font/color/size apply to all)
for _, event in ipairs(fade(0, 0.5, 0, 1, 10)) do
    table.insert(timeline, event)
end

-- Text change - UI font/color/size/outline still apply
table.insert(timeline, {delay = 3, update = {text = "Middle"}})

-- Override just fontSize for this event - UI font/color/outline still apply
table.insert(timeline, {delay = 4, update = {fontSize = 48}})

-- Fade out: 1 to 0 over 0.4s in 5 steps, starting at 5s
for _, event in ipairs(fade(5, 0.4, 1, 0, 5)) do
    table.insert(timeline, event)
end

-- Destroy - this prevents Duration auto-hide timer from running
table.insert(timeline, {delay = 5.5, destroy = true})

WeakTexturesAPI:CreateInstance({
    alpha = 0,           -- Initial alpha
    text = "Starting",   -- Initial text (uses UI font/color/size/offset)
    timeline = timeline
})
```

**Key Point:** Notice how we don't specify `font`, `fontSize`, `fontOutline`, `textColor`, or `textOffsetX/Y` in CreateInstance - they all come from UI Settings! Only `alpha` and `text` are specified.

**Why Timeline is Better:**
- **Cleaner Code**: One CreateInstance call instead of multiple C_Timer.NewTimer
- **Easier to Read**: Timeline array clearly shows all events and their timing
- **No Animation Restart**: Texture/parameter updates don't interrupt stop-motion animations
- **Automatic Cleanup**: Timeline timers are automatically canceled if instance is destroyed early
- **Better Performance**: All events scheduled at once, not created in callbacks
- **Destroy Precedence**: Timeline destroy event prevents preset Duration auto-hide from running

**LibSharedMedia (LSM) Support:**
- If parameter contains `/` or `\\` = treated as full path
- If no slashes = treated as LSM registered name
- **WT_** prefix: Your own custom textures registered in WeakTextures
- Other names: Shared resources from other addons (e.g., "BigWigs: Alarm", "StonesMedia kick")

### Multi-Instance Advanced Trigger Example - Notification System

**Note:** Due to Blizzard's AddOns restrictions (secrets), most combat-related values (health, damage, cooldowns) cannot be tracked by addons. Use non-combat related events and values instead. Chat events may have restrictions in instances depending on Blizzard's policies.

**Events to use:** `CHAT_MSG_WHISPER, CHAT_MSG_BN_WHISPER`
**Duration:** 3 (auto-hide after 3 seconds if no timeline destroy event)
```lua
function(e, ...)
    if e == "CHAT_MSG_WHISPER" then
        local message, sender = ...
        if string.find(message, "pi me") then
            WeakTexturesAPI:CreateInstance({
                text = "Requested PI from\n" .. sender,
                texture = "Interface\\ICONS\\spell_holy_powerinfusion",
                offsetY = 200,
                textColor = {r=1, g=0.5, b=1, a=1},
                sound = "BigWigs: Alarm",  -- LSM sound from BigWigs addon played on show
                timeline = {
                    {delay = 2, update = {text = "!PLEASE!", sound = "BigWigs: Raid Warning"}}, -- Text change and LSM sound from BigWigs addon played 2 seconds after first sound
                }
            })
        end
    end
end
```

**Note:** `WeakTexturesAPI:CreateInstance()` works in both single-instance and multi-instance modes:
- **Single-instance**: Reconfigures the existing frame with new properties
- **Multi-instance**: Creates a new separate frame instance

**Timeline in Multi-Instance:**
Each instance has its own independent timeline. Multiple instances can run simultaneously with different timelines.

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
    
    WeakTexturesAPI:CreateInstance({
        texture = texturePath  -- you can use full path or LSM names.
    })
    
    WeakTexturesAPI:RefreshPreset(true) -- instead of ordinary "return true", use this to refresh new texture defined in CreateInstance
end
```

### Single Instance Advanced Trigger Example - Pull Timer with Timeline

**Event to use:** `START_PLAYER_COUNTDOWN`
**Duration:** 0 (timeline handles cleanup with destroy event)
**UI Settings:** Font="Friz Quadrata TT", Size=24, Color=Red, Outline="THICKOUTLINE", Alpha=0, OffsetX=60

```lua
function(e, ...)
  local _, duration = ...
  local prefix = "Interface\\AddOns\\WeakTextures\\Media\\"
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
  
  -- Build timeline for countdown
  local timeline = {}
  
  -- Countdown events: 3, 2, 1
  for i = 3, 1, -1 do
    table.insert(timeline, {
        delay = duration - i,
        update = {
          alpha = 1,  -- Fade in when countdown starts
          texture = media.textures[i],
          text = tostring(i),
          sound = media.sounds[i],
        }
    })
  end
  
  -- "GO!" event when countdown expires
  table.insert(timeline, {
      delay = duration,
      update = {
        texture = media.textures[0],
        text = "GO!",
        fontSize = 50,
        textOffsetX = 100,
        textColor = {r=0, g=1, b=0, a=1},
      }
  })
  
  -- Hide 1 second after countdown ends
  table.insert(timeline, {
      delay = duration + 1,
      destroy = true
  })
  
  -- Create instance with timeline - START INVISIBLE because we set alpha 0 in UI
  WeakTexturesAPI:CreateInstance({
      timeline = timeline
  })
  
  WeakTexturesAPI:RefreshPreset(true) -- in single instance mode you have to refresh preset with new instance config
end
```

**Key Improvements with UI Defaults:**
- **Less Code**: No need to specify font, fontSize, textColor, fontOutline, textOffsetX in CreateInstance
- **Easier Configuration**: Change font/color/offset in UI without touching Lua code
- **Timeline Simplicity**: Timeline events only override what changes (texture, text, sound)
- **Consistent Styling**: All countdown numbers use same UI font/size/color settings

**Why Timeline + UI Defaults is Powerful:**
- **Minimal Code**: One CreateInstance with just the essentials
- **UI-Driven Styling**: Configure appearance in UI, not in Lua
- **Cleaner Timeline**: Only specify what actually changes per event
- **No Animation Restart**: Texture/parameter updates don't interrupt stop-motion
- **Automatic Cleanup**: Timeline timers canceled if destroyed early
- **Destroy Precedence**: Timeline destroy prevents Duration auto-hide

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

**Note:** With timeline system, you rarely need RefreshPreset anymore, yet you will still need it for single-instance refresh or initializing new CreateInstance config, then Timeline handles showing/hiding automatically with destroy events. in Multi-instance mode you dont need to call it.

```lua
-- Inside trigger function:
WeakTexturesAPI:RefreshPreset(true)  -- Apply changes from CreateInstances and Show preset 
WeakTexturesAPI:RefreshPreset(false) -- Hide preset and cancel all timers
```

**When to use RefreshPreset:**
- Simple triggers without timeline
- Manual show/hide control
- Canceling timeline early: `WeakTexturesAPI:RefreshPreset(false)` cancels all timeline timers

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
