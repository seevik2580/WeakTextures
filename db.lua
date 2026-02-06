local _, wt = ...

---@type WeakTexturesProfiles
WeakTexturesProfiles = WeakTexturesProfiles or {}

-- Initialize per-character data
WeakTexturesCharacter = WeakTexturesCharacter or {
    activeProfile = "Default"
}

-- Initialize WeakTexturesSettings if not exists
WeakTexturesSettings = WeakTexturesSettings or {
    debugEnabled = false,
    showTooltips = true,
    confirmDelete = true,
    font = "PT Sans Narrow Bold",
    fontBold = "PT Sans Narrow Bold",
    autoRegisterCustomTextures = true,
    frameScale = 1.3,
    firstRun = true,
}

-- Default text appearance constants (consistent across single & multi-instance modes)
wt.TEXT_DEFAULT_COLOR = { r = 1, g = 0.82, b = 0, a = 1 }  -- Gold like GameFontNormal
wt.TEXT_DEFAULT_OUTLINE = "OUTLINE"
wt.TEXT_DEFAULT_SIZE = 10
wt.TEXT_DEFAULT_OFFSET_X = 0
wt.TEXT_DEFAULT_OFFSET_Y = 0

-- Store registered custom textures
WeakTexturesCustomTextures = WeakTexturesCustomTextures or {}

---@type WeakTexturesDB
WeakTexturesDB = WeakTexturesDB or { presets = {}, groups = {}, ADDON_EVENTS = {} }

wt.debugEnabled = WeakTexturesSettings.debugEnabled

---Migrate preset from v1 to v2 format
---@param preset table
function wt:MigratePresetToV2(preset)
    if preset.version and preset.version >= 2 then
        return -- Already v2
    end
    
    -- Add text configuration
    if not preset.text then
        preset.text = {
            enabled = false,
            content = "",
            font = "Fonts\\FRIZQT__.TTF",
            size = 48,
            color = { r = 1, g = 1, b = 1, a = 1 },
            offsetX = 0,
            offsetY = 125,
            outline = "OUTLINE"
        }
    end
    
    -- Add sounds configuration
    if not preset.sounds then
        preset.sounds = {}
    end
    
    -- Add instance pool configuration
    if not preset.instancePool then
        preset.instancePool = {
            enabled = false,
            maxInstances = 10
        }
    end
    
    -- Mark as v2
    preset.version = 2
end

---Check if preset uses v2 features
---@param preset table
---@return boolean
function wt:IsPresetV2(preset)
    return preset.version == 2 or 
           preset.text ~= nil or 
           preset.sounds ~= nil or 
           preset.instancePool ~= nil
end
