-- =====================================================
-- WeakTextures API
-- Public functions accessible from macros and other addons
-- =====================================================
local _, wt = ...

WeakTexturesAPI = WeakTexturesAPI or {}

---Identify the preset name of the texture frame under the mouse cursor
---Usage in macro: /run WeakTexturesAPI:IdentifyPreset()
---@return string|nil presetName
function WeakTexturesAPI:IdentifyPreset()
    -- Get cursor position in screen coordinates
    local cursorX, cursorY = GetCursorPosition()
    
    -- Strata priority for sorting
    local strataPriority = {
        WORLD = 1,
        BACKGROUND = 2,
        LOW = 3,
        MEDIUM = 4,
        HIGH = 5,
        DIALOG = 6,
        FULLSCREEN = 7,
        FULLSCREEN_DIALOG = 8,
        TOOLTIP = 9
    }
    
    -- Collect all matching frames
    local matches = {}
    
    for presetName, container in pairs(wt.activeFramesByPreset) do
        if container and container.frame then
            local f = container.frame
            
            if f:IsVisible() then
                -- Get frame bounds in screen coordinates (already scaled)
                local left = f:GetLeft()
                local right = f:GetRight()
                local bottom = f:GetBottom()
                local top = f:GetTop()
                
                if left and right and bottom and top then
                    -- Get effective scale of this specific frame
                    local effectiveScale = f:GetEffectiveScale()
                    
                    -- Convert bounds to cursor coordinate space
                    left = left * effectiveScale
                    right = right * effectiveScale
                    bottom = bottom * effectiveScale
                    top = top * effectiveScale
                    
                    -- Check if cursor is within frame bounds
                    if cursorX >= left and cursorX <= right and cursorY >= bottom and cursorY <= top then
                        table.insert(matches, {
                            name = presetName,
                            strata = f:GetFrameStrata(),
                            level = f:GetFrameLevel()
                        })
                    end
                end
            end
        end
    end
    
    -- If no matches found
    if #matches == 0 then
        print("|cffff0000[WeakTextures]|r No WeakTextures preset found under cursor")
        return nil
    end
    
    -- Sort by strata (highest first), then by frame level (highest first)
    table.sort(matches, function(a, b)
        local aPriority = strataPriority[a.strata] or 0
        local bPriority = strataPriority[b.strata] or 0
        
        if aPriority ~= bPriority then
            return aPriority > bPriority
        else
            return a.level > b.level
        end
    end)
    
    -- Return the topmost (highest strata/level) preset
    local topPreset = matches[1].name
    print("|cffff0000[WeakTextures]|r Preset: |cff00ff00" .. topPreset .. "|r")
    return topPreset
end

---Get information about a specific preset
---@param presetName string
---@return table|nil
function WeakTexturesAPI:GetPresetInfo(presetName)
    if not WeakTexturesDB.presets[presetName] then
        return nil
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    local info = {
        name = presetName,
        enabled = preset.enabled,
        type = preset.type,
        group = preset.group,
        isActive = wt.activeFramesByPreset[presetName] ~= nil,
    }
    
    if preset.textures and preset.textures[1] then
        info.anchor = preset.textures[1].anchor
        info.width = preset.textures[1].width
        info.height = preset.textures[1].height
        info.x = preset.textures[1].x
        info.y = preset.textures[1].y
        info.scale = preset.scale
        info.alpha = preset.alpha
        info.strata = preset.strata
        info.level = preset.level

    end
    
    return info
end

---Get all active presets
---@return table
function WeakTexturesAPI:ListActivePresets()
    local activePresets = {}
    for presetName, _ in pairs(wt.activeFramesByPreset) do
        table.insert(activePresets, presetName)
    end
    
    wt:Debug("Active presets:", #activePresets)
    for i, presetName in ipairs(activePresets) do
        wt:Debug("  " .. i .. ".", presetName)
    end
    
    if #activePresets == 0 then
        wt:Debug("No active presets")
    end
    
    return activePresets
end

---Enable multi-instance mode for a preset
---Usage: /run WeakTexturesAPI:EnableMultiInstance("PresetName")
---@param presetName string
---@param maxInstances number
---@return boolean
function WeakTexturesAPI:EnableMultiInstance(presetName, maxInstances)
    if not WeakTexturesDB.presets[presetName] then
        wt:Debug("Preset '" .. presetName .. "' not found")
        return false
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    
    -- Migrate to v2 if needed
    if not wt:IsPresetV2(preset) then
        wt:MigratePresetToV2(preset)
    end
    
    -- Enable multi-instance mode
    preset.instancePool.enabled = true
    preset.instancePool.maxInstances = maxInstances or 10
    
    -- Enable text overlay with defaults
    preset.text.enabled = true
    
    wt:Debug("Multi-instance mode enabled for '" .. presetName .. "'")
    wt:Debug("  Max instances: " .. preset.instancePool.maxInstances)
    wt:Debug("  Text overlay: enabled")
    wt:Debug("  Use CreateInstance({text='...', sound='path'}) in trigger")
    
    return true
end

---Disable multi-instance mode for a preset
---Usage: /run WeakTexturesAPI:DisableMultiInstance("PresetName")
---@param presetName string
---@return boolean
function WeakTexturesAPI:DisableMultiInstance(presetName)
    if not WeakTexturesDB.presets[presetName] then
        wt:Debug("Preset '" .. presetName .. "' not found")
        return false
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    
    if not preset.instancePool then
        wt:Debug("Multi-instance mode already disabled for '" .. presetName .. "'")
        return false
    end
    
    -- Cleanup all active instances first
    wt:CleanupAllInstances(presetName)
    
    -- Disable multi-instance mode
    preset.instancePool.enabled = false
    
    wt:Debug("Multi-instance mode disabled for '" .. presetName .. "'")
    wt:Debug("  Preset will now use standard single-frame mode")
    
    return true
end

---Test CreateInstance from console
---Usage: /run WeakTexturesAPI:TestInstance("PresetName", "Test Text", "sound.ogg")
---@param presetName string
---@param text string
---@param sound string
function WeakTexturesAPI:TestInstance(presetName, text, sound)
    if not WeakTexturesDB.presets[presetName] then
        print("Preset '" .. presetName .. "' not found")
        return
    end
    
    wt:CreateInstance(presetName, {
        text = text or "TEST",
        sound = sound
    })
    
    print("CreateInstance called for '" .. presetName .. "'")
    if sound then
        print("  Sound: " .. sound)
    end
end

-- Create an instance with custom parameters - Only allowed from within trigger sandbox
-- Usage in trigger: 
-- WeakTexturesAPI:CreateInstance({
--   text = "...",
--   offsetX = 100,
--   offsetY = 100,
--   scale = 1.0,
--   alpha = 1.0,
--   font = "FontFullPath or FontName from LSM",
--   fontSize = 12,
--   fontOutline = "", -- or "OUTLINE", "THICKOUTLINE", "MONOCHROME"
--   textColor = {r, g, b, a},
--   textOffsetX = 0,
--   textOffsetY = 0,
--   textLeftPoint = "LEFT",
--   textRightPoint = "RIGHT",
--   texture = "TextureFullPath",
--   type = "static", -- or "motion" to switch animation type
--   columns = 8, -- for motion type
--   rows = 4, -- for motion type
--   totalFrames = 32, -- for motion type
--   fps = 30, -- for motion type
--   sound = "SoundFullPath",
--   soundChannel = "Master"
-- })
---@param data table 
---@return boolean
function WeakTexturesAPI:CreateInstance(data)
    local presetName = self._currentPreset
    
    if not presetName then
        wt:Debug("CreateInstance: Can only be called from within a trigger")
        return false
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then
        return false
    end
    
    if preset.instancePool and preset.instancePool.enabled then
        -- Multi-instance mode
        wt:CreateInstance(presetName, data or {})
        return true
    else
        -- Single-instance mode: apply overrides from data
        if data then
            -- Store temporary overrides for this preset
            if not preset.tempOverrides then
                preset.tempOverrides = {}
            end
            
            -- Also store as instance defaults (won't be cleared, used by timeline)
            if not preset.instanceDefaults then
                preset.instanceDefaults = {}
            end
            
            -- Store all override parameters (use ~= nil for values that can be 0 or false)
            if data.offsetX then 
                preset.tempOverrides.offsetX = data.offsetX 
                preset.instanceDefaults.offsetX = data.offsetX
            end
            if data.offsetY then 
                preset.tempOverrides.offsetY = data.offsetY 
                preset.instanceDefaults.offsetY = data.offsetY
            end
            if data.scale then 
                preset.tempOverrides.scale = data.scale 
                preset.instanceDefaults.scale = data.scale
            end
            if data.alpha ~= nil then 
                preset.tempOverrides.alpha = data.alpha 
                preset.instanceDefaults.alpha = data.alpha
            end
            
            -- Display properties
            if data.width then 
                preset.tempOverrides.width = data.width 
                preset.instanceDefaults.width = data.width
            end
            if data.height then 
                preset.tempOverrides.height = data.height 
                preset.instanceDefaults.height = data.height
            end
            if data.angle ~= nil then 
                preset.tempOverrides.angle = data.angle 
                preset.instanceDefaults.angle = data.angle
            end
            if data.anchor then 
                preset.tempOverrides.anchor = data.anchor 
                preset.instanceDefaults.anchor = data.anchor
            end
            if data.x ~= nil then 
                preset.tempOverrides.x = data.x 
                preset.instanceDefaults.x = data.x
            end
            if data.y ~= nil then 
                preset.tempOverrides.y = data.y 
                preset.instanceDefaults.y = data.y
            end
            
            -- Layering
            if data.strata then 
                preset.tempOverrides.strata = data.strata 
                preset.instanceDefaults.strata = data.strata
            end
            if data.frameLevel then 
                preset.tempOverrides.frameLevel = data.frameLevel 
                preset.instanceDefaults.frameLevel = data.frameLevel
            end
            
            -- Stop Motion animation parameters
            if data.columns then 
                preset.tempOverrides.columns = data.columns 
                preset.instanceDefaults.columns = data.columns
            end
            if data.rows then 
                preset.tempOverrides.rows = data.rows 
                preset.instanceDefaults.rows = data.rows
            end
            if data.totalFrames then 
                preset.tempOverrides.totalFrames = data.totalFrames 
                preset.instanceDefaults.totalFrames = data.totalFrames
            end
            if data.fps then 
                preset.tempOverrides.fps = data.fps 
                preset.instanceDefaults.fps = data.fps
            end
            
            -- Texture settings
            if data.texture then 
                preset.tempOverrides.texture = data.texture 
                preset.instanceDefaults.texture = data.texture
            end
            if data.color then 
                preset.tempOverrides.color = data.color 
                preset.instanceDefaults.color = data.color
            end
            
            -- Text overlay
            if data.text then 
                preset.tempOverrides.text = data.text 
                preset.instanceDefaults.text = data.text
            end
            if data.font then 
                preset.tempOverrides.font = data.font 
                preset.instanceDefaults.font = data.font
            end
            if data.fontSize then 
                preset.tempOverrides.fontSize = data.fontSize 
                preset.instanceDefaults.fontSize = data.fontSize
            end
            if data.fontOutline then 
                preset.tempOverrides.fontOutline = data.fontOutline 
                preset.instanceDefaults.fontOutline = data.fontOutline
            end
            if data.textColor then 
                preset.tempOverrides.textColor = data.textColor 
                preset.instanceDefaults.textColor = data.textColor
            end
            if data.textOffsetX then 
                preset.tempOverrides.textOffsetX = data.textOffsetX 
                preset.instanceDefaults.textOffsetX = data.textOffsetX
            end
            if data.textOffsetY then 
                preset.tempOverrides.textOffsetY = data.textOffsetY 
                preset.instanceDefaults.textOffsetY = data.textOffsetY
            end
            if data.textLeftPoint then 
                preset.tempOverrides.textLeftPoint = data.textLeftPoint 
                preset.instanceDefaults.textLeftPoint = data.textLeftPoint
            end
            if data.textRightPoint then 
                preset.tempOverrides.textRightPoint = data.textRightPoint 
                preset.instanceDefaults.textRightPoint = data.textRightPoint
            end
            
            -- Animation type (static vs motion)
            if data.type then
                preset.tempOverrides.type = data.type
                preset.instanceDefaults.type = data.type
            end
            
            -- Store sound to play when preset is shown (not immediately)
            if data.sound then
                preset.tempOverrides.sound = data.sound
                preset.tempOverrides.soundChannel = data.soundChannel or "Master"
                preset.instanceDefaults.sound = data.sound
                preset.instanceDefaults.soundChannel = data.soundChannel or "Master"
            end
            
            -- Store timeline for processing in RefreshPreset
            if data.timeline then
                preset.timeline = data.timeline
            end
        end
        return true
    end
end

---Refresh preset visibility based on a boolean value - Only allowed from within trigger sandbox
---Usage in trigger: WeakTexturesAPI:RefreshPreset(true) or WeakTexturesAPI:RefreshPreset(false)
---true for show or show and refresh attributes if WeakTexturesAPI:CreateInstance was used, false for hide
---@param showTexture boolean
---@return boolean
function WeakTexturesAPI:RefreshPreset(showTexture)
    local presetName = self._currentPreset
    
    if not presetName then
        wt:Debug("RefreshPreset: Can only be called from within a trigger")
        return false
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then
        return false
    end
    
    preset.lastTriggerResult = showTexture
    if showTexture then
        wt:ApplyPreset(presetName)
        
        -- Cancel existing timeline timers if any
        if preset.timelineTimers then
            for _, timer in ipairs(preset.timelineTimers) do
                timer:Cancel()
            end
            preset.timelineTimers = nil
        end
        
        -- Cancel existing auto-hide timer if any
        if preset.autoHideTimer then
            preset.autoHideTimer:Cancel()
            preset.autoHideTimer = nil
        end
        
        -- Check if timeline has destroy event (must be before timeline processing for auto-hide check)
        local hasDestroyEvent = false
        if preset.timeline then
            for _, evt in ipairs(preset.timeline) do
                if evt.destroy then
                    hasDestroyEvent = true
                    break
                end
            end
        end
        
        -- Process timeline if defined
        if preset.timeline then
            preset.timelineTimers = {}
            local duration = preset.duration or 0
            
            for i, event in ipairs(preset.timeline) do
                local delay = event.delay or 0
                
                -- Validate delay against duration
                if duration > 0 and delay > duration then
                    print(string.format("[WeakTextures] WARNING: Timeline event #%d has delay %.2fs which exceeds preset duration %.2fs", i, delay, duration))
                end
                
                local timer = C_Timer.NewTimer(delay, function()
                    -- Update parameters
                    if event.update then
                        local container = wt.activeFramesByPreset[presetName]
                        if container and container.frame then
                            -- Update existing frame without restarting animation
                            wt:UpdateExistingFrame(presetName, container, event.update)
                        end
                    end
                    
                    -- Destroy instance
                    if event.destroy then
                        WeakTexturesAPI._currentPreset = presetName
                        WeakTexturesAPI:RefreshPreset(false)
                        WeakTexturesAPI._currentPreset = nil
                        preset.timeline = nil
                        preset.timelineTimers = nil
                    end
                end)
                
                table.insert(preset.timelineTimers, timer)
            end
        end
        
        -- Start auto-hide timer if duration is set (but NOT if timeline has destroy event)
        local duration = preset.duration
        if duration and duration > 0 then
            if not (preset.timeline and hasDestroyEvent) then
                preset.autoHideTimer = C_Timer.NewTimer(duration, function()
                    wt:HideTextureFrame(presetName)
                    preset.autoHideTimer = nil
                    preset.timeline = nil
                    preset.timelineTimers = nil
                end)
            end
        end
    else
        wt:HideTextureFrame(presetName)
        
        -- Clear timeline state
        if preset.timelineTimers then
            for _, timer in ipairs(preset.timelineTimers) do
                timer:Cancel()
            end
            preset.timelineTimers = nil
        end
        preset.timeline = nil
    end
    
    return true
end

