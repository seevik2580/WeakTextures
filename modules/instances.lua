-- =====================================================
-- WeakTextures Instance Management
-- Multi-instance frame pool system
-- =====================================================
local _, wt = ...

-- Initialize frame pools
wt.framePoolsByPreset = wt.framePoolsByPreset or {}

---Initialize frame pool for a preset
---@param presetName string
function wt:InitializeFramePool(presetName)
    if not self.framePoolsByPreset[presetName] then
        self.framePoolsByPreset[presetName] = {
            frames = {},
            activeCount = 0
        }
    end
end

---Get or create a frame from the pool
---@param presetName string
---@return table
function wt:AcquireFrame(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then return nil end
    
    self:InitializeFramePool(presetName)
    local pool = self.framePoolsByPreset[presetName]
    
    -- Try to find an inactive frame
    for _, container in ipairs(pool.frames) do
        if not container.active then
            container.active = true
            pool.activeCount = pool.activeCount + 1
            return container
        end
    end
    
    -- No free frame found, create a new one
    local container = self:CreateFrameContainer(presetName)
    table.insert(pool.frames, container)
    container.active = true
    pool.activeCount = pool.activeCount + 1
    
    return container
end

---Release a frame back to the pool
---@param presetName string
---@param container table
function wt:ReleaseFrame(presetName, container)
    if not container or not container.active then return end
    
    wt:Debug("ReleaseFrame: Hiding and releasing frame for", presetName, "Time:", GetTime())
    container.active = false
    container.frame:Hide()
    wt:Debug("ReleaseFrame: Frame hidden for", presetName, "IsShown=", container.frame:IsShown())
    
    -- Clear instance data
    if container.instanceData then
        wipe(container.instanceData)
    end
    
    -- Stop animation if running
    if container.animationTimer then
        container.animationTimer:Cancel()
        container.animationTimer = nil
    end
    
    -- Reset text
    if container.fontString then
        container.fontString:SetText("")
        container.fontString:Hide()
    end
    
    local pool = self.framePoolsByPreset[presetName]
    if pool then
        pool.activeCount = math.max(0, pool.activeCount - 1)
    end
end

---Create a new frame container for the pool
---@param presetName string
---@return table
function wt:CreateFrameContainer(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    
    -- Create main frame
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetParent(UIParent)  -- Explicit parent
    frame:SetFrameStrata(preset.strata or "MEDIUM")
    frame:SetFrameLevel(preset.frameLevel or 100)
    
    wt:Debug("CreateFrameContainer: Created frame for", presetName, "parent:", frame:GetParent():GetName() or "unnamed")
    
    -- Create texture
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(frame)
    
    -- Create optional font string for text
    local fontString = nil
    if preset.text and preset.text.enabled then
        fontString = frame:CreateFontString(nil, "OVERLAY")
        fontString:SetPoint("CENTER", frame, "CENTER", 
            preset.text.offsetX or 0, 
            preset.text.offsetY or 125)
        
        -- Set font
        local font = preset.text.font or "Fonts\\FRIZQT__.TTF"
        local size = preset.text.size or 48
        local outline = preset.text.outline or "OUTLINE"
        fontString:SetFont(font, size, outline)
        
        -- Set color
        if preset.text.color then
            fontString:SetTextColor(
                preset.text.color.r or 1,
                preset.text.color.g or 1,
                preset.text.color.b or 1,
                preset.text.color.a or 1
            )
        else
            fontString:SetTextColor(1, 1, 1, 1)
        end
        
        -- Set shadow
        fontString:SetShadowOffset(1, -1)
        fontString:SetShadowColor(0, 0, 0, 1)
    end
    
    local container = {
        frame = frame,
        texture = texture,
        fontString = fontString,
        active = false,
        instanceData = {},
        animationTimer = nil,
        currentFrame = 0,
        elapsed = 0
    }
    
    return container
end

---Create a new instance of a preset
---@param presetName string
---@param data table
function wt:CreateInstance(presetName, data)
    local preset = WeakTexturesDB.presets[presetName]
    wt:Debug("CreateInstance called for", presetName, "data:", data and "yes" or "no")
    
    if not preset then
        wt:Debug("CreateInstance: Preset not found:", presetName)
        return
    end
    
    if not preset.enabled then
        wt:Debug("CreateInstance: Preset disabled:", presetName)
        return
    end
    
    if not preset.instancePool or not preset.instancePool.enabled then
        wt:Debug("CreateInstance: Multi-instance mode not enabled for", presetName)
        wt:Debug("  preset.instancePool =", preset.instancePool and "exists" or "nil")
        if preset.instancePool then
            wt:Debug("  preset.instancePool.enabled =", preset.instancePool.enabled)
        end
        return
    end
    
    data = data or {}
    
    -- Acquire a frame from the pool
    local container = self:AcquireFrame(presetName)
    if not container then return end
    
    -- Store instance data
    container.instanceData = data
    
    -- Get texture path
    local texturePath = preset.textures and preset.textures[1] and preset.textures[1].texture
    wt:Debug("CreateInstance: texturePath =", texturePath or "nil")
    if not texturePath then
        wt:Debug("CreateInstance: No texture configured, releasing frame")
        self:ReleaseFrame(presetName, container)
        return
    end
    
    -- Apply texture settings
    local textureData = preset.textures[1]
    
    -- Apply per-instance texture override if provided
    local texturePath = data.texture or (preset.textures and preset.textures[1] and preset.textures[1].texture)
    wt:Debug("CreateInstance: texturePath =", texturePath or "nil")
    if not texturePath then
        wt:Debug("CreateInstance: No texture configured, releasing frame")
        self:ReleaseFrame(presetName, container)
        return
    end
    
    -- If texture name has no slashes, try LSM lookup
    if not texturePath:find("[/\\]") then
        local lsmTexture = wt.LSM:Fetch("background", texturePath)
        if lsmTexture then
            texturePath = lsmTexture
            wt:Debug("CreateInstance: LSM texture resolved to", texturePath)
        end
    end
    
    container.texture:SetTexture(texturePath)
    
    -- Set frame size and position
    local width = textureData.width or 512
    local height = textureData.height or 512
    container.frame:SetSize(width, height)
    wt:Debug("CreateInstance: Frame size set to", width, "x", height)
    
    -- Set anchor with per-instance offset override
    local anchor = textureData.anchor or "UIParent"
    local anchorFrame = _G[anchor] or UIParent
    if anchorFrame then
        local offsetX = data.offsetX or textureData.x or 0
        local offsetY = data.offsetY or textureData.y or 0
        container.frame:SetPoint("CENTER", anchorFrame, "CENTER", offsetX, offsetY)
        wt:Debug("CreateInstance: Anchored to", anchor, "offset:", offsetX, offsetY)
    end
    
    -- Apply scale with per-instance override
    local scale = data.scale or preset.scale or 1
    container.frame:SetScale(scale)
    wt:Debug("CreateInstance: Scale set to", scale)
    
    -- Apply alpha with per-instance override
    local alpha = data.alpha or preset.alpha or 1
    container.frame:SetAlpha(alpha)
    wt:Debug("CreateInstance: Alpha set to", alpha)
    
    -- Apply rotation
    if preset.angle and preset.angle ~= 0 then
        local radians = math.rad(preset.angle)
        container.texture:SetRotation(radians)
        wt:Debug("CreateInstance: Rotation set to", preset.angle, "degrees")
    end
    
    -- Set text if enabled
    if container.fontString and data.text then
        wt:Debug("CreateInstance: Setting text:", data.text)
        
        -- Apply per-instance font if provided
        if data.font or data.fontSize or data.fontOutline then
            local font = data.font or preset.text.font or "Fonts\\FRIZQT__.TTF"
            local size = data.fontSize or preset.text.size or 48
            local outline = data.fontOutline or preset.text.outline or "OUTLINE"
            
            -- If font is from LSM, fetch it
            if not font:match("^Interface") and not font:match("^Fonts") then
                font = wt.LSM:Fetch("font", font) or font
            end
            
            container.fontString:SetFont(font, size, outline)
        end
        
        -- Apply per-instance text color if provided
        if data.textColor then
            container.fontString:SetTextColor(
                data.textColor.r or 1,
                data.textColor.g or 1,
                data.textColor.b or 1,
                data.textColor.a or 1
            )
        end
        
        container.fontString:SetText(data.text)
        container.fontString:Show()
    elseif data.text then
        wt:Debug("CreateInstance: Text provided but fontString not created. preset.text.enabled =", preset.text and preset.text.enabled or "false")
    end
    
    -- Handle animation type
    if preset.type == "motion" then
        wt:Debug("CreateInstance: Starting stop motion animation")
        self:StartStopMotionAnimation(presetName, container)
    else
        -- Static texture
        container.texture:SetTexCoord(0, 1, 0, 1)
        wt:Debug("CreateInstance: Showing static frame at", GetTime())
        container.frame:Show()
        local x, y = container.frame:GetCenter()
        wt:Debug("CreateInstance: Static frame shown at", x, y, "Time:", GetTime())
    end
    
    -- Verify frame is actually visible
    C_Timer.After(0.1, function()
        if container.frame then
            local isShown = container.frame:IsShown()
            local alpha = container.frame:GetAlpha()
            local width, height = container.frame:GetSize()
            local x, y = container.frame:GetCenter()
            wt:Debug("CreateInstance POST-CHECK: IsShown=", isShown, "Alpha=", alpha, "Size=", width, "x", height, "Pos=", x, y)
            
            if not isShown then
                wt:Debug("CreateInstance WARNING: Frame created but not shown!")
            end
        end
    end)
    
    -- Play sound - support both soundKey (from preset.sounds) and direct sound path
    if data.soundKey then
        if preset.sounds and preset.sounds[data.soundKey] then
            wt:Debug("CreateInstance: Playing sound via soundKey:", data.soundKey)
            self:PlayPresetSound(presetName, data.soundKey)
        else
            -- Fallback: treat soundKey as direct path
            local soundPath = data.soundKey
            -- If no slashes, try LSM lookup
            if not soundPath:find("[/\\]") then
                local lsmSound = wt.LSM:Fetch("sound", soundPath)
                if lsmSound then
                    soundPath = lsmSound
                    wt:Debug("CreateInstance: LSM sound resolved to", soundPath)
                end
            end
            wt:Debug("CreateInstance: Playing sound via direct path:", soundPath)
            PlaySoundFile(soundPath, data.soundChannel or "MASTER")
        end
    elseif data.sound then
        -- Alternative: data.sound as direct path
        local soundPath = data.sound
        -- If no slashes, try LSM lookup
        if not soundPath:find("[/\\]") then
            local lsmSound = wt.LSM:Fetch("sound", soundPath)
            if lsmSound then
                soundPath = lsmSound
                wt:Debug("CreateInstance: LSM sound resolved to", soundPath)
            end
        end
        wt:Debug("CreateInstance: Playing sound via data.sound:", soundPath)
        PlaySoundFile(soundPath, data.soundChannel or "MASTER")
    end
    
    -- Auto-cleanup after duration
    local duration = preset.duration or 2.5
    wt:Debug("CreateInstance: Auto-cleanup timer set for", duration, "seconds")
    if duration and duration > 0 then
        C_Timer.After(duration, function()
            wt:Debug("CreateInstance: Cleanup timer fired after", duration, "seconds for", presetName)
            self:ReleaseFrame(presetName, container)
        end)
    end
end

---Start stop-motion animation for an instance
---@param presetName string
---@param container table
function wt:StartStopMotionAnimation(presetName, container)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or preset.type ~= "motion" then return end
    
    local columns = preset.columns or 4
    local rows = preset.rows or 6
    local totalFrames = preset.totalFrames or 24
    local fps = preset.fps or 15
    
    wt:Debug("StartStopMotionAnimation: cols=", columns, "rows=", rows, "total=", totalFrames, "fps=", fps)
    
    container.currentFrame = 0
    container.elapsed = 0
    
    -- Set initial texture coordinates for first frame
    container.texture:SetTexCoord(0, 1/columns, 0, 1/rows)
    
    -- Force parent and show
    container.frame:SetParent(UIParent)
    wt:Debug("StartStopMotionAnimation: Showing frame at", GetTime())
    container.frame:Show()
    wt:Debug("StartStopMotionAnimation: Frame shown, IsShown=", container.frame:IsShown())
    
    -- Create animation timer
    container.animationTimer = C_Timer.NewTicker(1 / fps, function()
        if not container.active then
            if container.animationTimer then
                container.animationTimer:Cancel()
                container.animationTimer = nil
            end
            return
        end
        
        container.currentFrame = container.currentFrame + 1
        
        if container.currentFrame >= totalFrames then
            container.currentFrame = totalFrames - 1
        end
        
        local col = container.currentFrame % columns
        local row = math.floor(container.currentFrame / columns)
        
        container.texture:SetTexCoord(
            col / columns,
            (col + 1) / columns,
            row / rows,
            (row + 1) / rows
        )
    end)
end

---Play a sound from a preset's sound library or a direct path
---@param presetName string
---@param soundKey string
---@param channel string
---@param directPath string|nil
function wt:PlayPresetSound(presetName, soundKey, channel, directPath)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then return end
    
    -- If direct path provided, use it
    if directPath then
        -- If no slashes, try LSM lookup
        if not directPath:find("[/\\]") then
            local lsmSound = wt.LSM:Fetch("sound", directPath)
            if lsmSound then
                directPath = lsmSound
                wt:Debug("PlayPresetSound: LSM sound resolved to", directPath)
            end
        end
        PlaySoundFile(directPath, channel or "Master")
        return
    end
    
    -- Otherwise use soundKey from preset.sounds
    if not preset.sounds or not soundKey or not preset.sounds[soundKey] then return end
    
    local soundData = preset.sounds[soundKey]
    if soundData.enabled and soundData.path then
        local fullPath = soundData.path
        -- Add prefix if not already a full path
        if not fullPath:match("^Interface") then
            fullPath = "Interface\\AddOns\\WeakTextures\\Media\\Sounds\\" .. fullPath
        end
        
        PlaySoundFile(fullPath, channel or "Master")
    end
end

---Play a random enabled sound from preset
---@param presetName string
function wt:PlayRandomPresetSound(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.sounds then return end
    
    local enabledSounds = {}
    for key, soundData in pairs(preset.sounds) do
        if soundData.enabled then
            table.insert(enabledSounds, key)
        end
    end
    
    if #enabledSounds > 0 then
        local randomKey = enabledSounds[math.random(#enabledSounds)]
        self:PlayPresetSound(presetName, randomKey)
    end
end

---Cleanup all instances for a preset
---@param presetName string
function wt:CleanupAllInstances(presetName)
    local pool = self.framePoolsByPreset[presetName]
    if not pool then return end
    
    for _, container in ipairs(pool.frames) do
        if container.active then
            self:ReleaseFrame(presetName, container)
        end
    end
end

---Cleanup all frame pools (on addon disable)
function wt:CleanupAllFramePools()
    for presetName, pool in pairs(self.framePoolsByPreset) do
        for _, container in ipairs(pool.frames) do
            if container.active then
                self:ReleaseFrame(presetName, container)
            end
            
            -- Destroy frames
            if container.frame then
                container.frame:Hide()
                container.frame = nil
            end
        end
        pool.frames = {}
        pool.activeCount = 0
    end
end

---Enable multi-instance mode for a preset (helper function)
---@param presetName string
---@param maxInstances number
function wt:EnableMultiInstance(presetName, maxInstances)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then
        print("WeakTextures: Preset '" .. presetName .. "' not found")
        return false
    end
    
    -- Migrate to v2 if needed
    if not self:IsPresetV2(preset) then
        self:MigratePresetToV2(preset)
    end
    
    -- Enable multi-instance mode
    preset.instancePool.enabled = true
    preset.instancePool.maxInstances = maxInstances or 10
    
    -- Enable text overlay with defaults
    preset.text.enabled = true
    
    print("WeakTextures: Multi-instance mode enabled for '" .. presetName .. "'")
    print("  Max instances: " .. preset.instancePool.maxInstances)
    print("  Text overlay: enabled")
    print("Use CreateInstance({text='...', sound='path'}) in trigger")
    
    return true
end
