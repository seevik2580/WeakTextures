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
            -- Preventively cancel any lingering timers before reusing container
            if container.timelineTimers then
                for _, timer in ipairs(container.timelineTimers) do
                    if timer then timer:Cancel() end
                end
                container.timelineTimers = nil
            end
            
            if container.autoCleanupTimer then
                container.autoCleanupTimer:Cancel()
                container.autoCleanupTimer = nil
            end
            
            if container.animationTimer then
                container.animationTimer:Cancel()
                container.animationTimer = nil
            end
            
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
    
    container.active = false
    container.frame:Hide()
    
    -- Clear instance data
    if container.instanceData then
        wipe(container.instanceData)
    end
    
    -- Stop animation if running
    if container.animationTimer then
        container.animationTimer:Cancel()
        container.animationTimer = nil
    end
    
    -- Cancel timeline timers
    if container.timelineTimers then
        for _, timer in ipairs(container.timelineTimers) do
            if timer then timer:Cancel() end
        end
        container.timelineTimers = nil
    end
    
    -- Cancel auto-cleanup timer
    if container.autoCleanupTimer then
        container.autoCleanupTimer:Cancel()
        container.autoCleanupTimer = nil
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
    
    -- Create texture
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(frame)
    
    -- Create optional font string for text
    local fontString = nil
    if preset.text and preset.text.enabled then
        fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fontString:SetPoint("CENTER", frame, "CENTER", 
            preset.text.offsetX or wt.TEXT_DEFAULT_OFFSET_X, 
            preset.text.offsetY or wt.TEXT_DEFAULT_OFFSET_Y)
        
        -- Set font
        local font = preset.text.font or "Fonts\\FRIZQT__.TTF"
        local size = preset.text.size or wt.TEXT_DEFAULT_SIZE
        local outline = preset.text.outline or wt.TEXT_DEFAULT_OUTLINE
        
        -- If font is from LSM, fetch it
        if not font:match("^Interface") and not font:match("^Fonts") then
            local lsmFont = wt.LSM:Fetch("font", font)
            if lsmFont then
                font = lsmFont
            end
        end
        
        fontString:SetFont(font, size, outline)
        
        -- Set color
        if preset.text.color then
            fontString:SetTextColor(
                preset.text.color.r or 1,
                preset.text.color.g or 1,
                preset.text.color.b or 1,
                preset.text.color.a or 1
            )
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
    
    if not preset then
        return
    end
    
    if not preset.enabled then
        return
    end
    
    if not preset.instancePool or not preset.instancePool.enabled then
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
    if not texturePath then
        self:ReleaseFrame(presetName, container)
        return
    end
    
    -- Apply texture settings
    local textureData = preset.textures[1]
    
    -- Apply per-instance texture override if provided
    local texturePath = data.texture or (preset.textures and preset.textures[1] and preset.textures[1].texture)
    if not texturePath then
        self:ReleaseFrame(presetName, container)
        return
    end
    
    -- If texture name has no slashes, try LSM lookup
    if not texturePath:find("[/\\]") then
        local lsmTexture = wt.LSM:Fetch("background", texturePath)
        if lsmTexture then
            texturePath = lsmTexture
        end
    end
    
    container.texture:SetTexture(texturePath)
    
    -- Set frame size and position
    local width = textureData.width or 512
    local height = textureData.height or 512
    container.frame:SetSize(width, height)
    
    -- Set anchor with per-instance offset override
    local anchor = textureData.anchor or "UIParent"
    local anchorFrame = _G[anchor] or UIParent
    if anchorFrame then
        local offsetX = data.offsetX or textureData.x or 0
        local offsetY = data.offsetY or textureData.y or 0
        container.frame:SetPoint("CENTER", anchorFrame, "CENTER", offsetX, offsetY)
    end
    
    -- Apply scale with per-instance override
    local scale = data.scale or preset.scale or 1
    container.frame:SetScale(scale)
    
    -- Apply alpha with per-instance override
    local alpha = data.alpha or preset.alpha or 1
    container.frame:SetAlpha(alpha)
    
    -- Apply rotation
    if preset.angle and preset.angle ~= 0 then
        local radians = math.rad(preset.angle)
        container.texture:SetRotation(radians)
    end
    
    -- Set text if enabled
    if container.fontString then
        -- Get text content (use override or fallback to preset default)
        local textContent = data.text or (preset.text and preset.text.content)
        
        -- Always apply font settings (use overrides if provided, otherwise use preset defaults)
        local font = data.font or (preset.text and preset.text.font) or "Fonts\\FRIZQT__.TTF"
        local size = data.fontSize or (preset.text and preset.text.size) or wt.TEXT_DEFAULT_SIZE
        local outline = data.fontOutline or (preset.text and preset.text.outline) or wt.TEXT_DEFAULT_OUTLINE
        
        -- If font is from LSM, fetch it
        if not font:match("^Interface") and not font:match("^Fonts") then
            local lsmFont = wt.LSM:Fetch("font", font)
            if lsmFont then
                font = lsmFont
            end
        end
        
        container.fontString:SetFont(font, size, outline)
        
        -- Apply per-instance text color if provided
        if data.textColor then
            container.fontString:SetTextColor(
                data.textColor.r or 1,
                data.textColor.g or 1,
                data.textColor.b or 1,
                data.textColor.a or 1
            )
        elseif preset.text and preset.text.color then
            -- Use preset default color
            container.fontString:SetTextColor(
                preset.text.color.r, preset.text.color.g,
                preset.text.color.b, preset.text.color.a)
        else
            -- Default gold color like GameFontNormal
            container.fontString:SetTextColor(wt.TEXT_DEFAULT_COLOR.r, wt.TEXT_DEFAULT_COLOR.g, wt.TEXT_DEFAULT_COLOR.b, wt.TEXT_DEFAULT_COLOR.a)
        end
        
        -- Always apply text offset (use overrides if provided, otherwise use preset defaults)
        local offsetX = data.textOffsetX or (preset.text and preset.text.offsetX) or wt.TEXT_DEFAULT_OFFSET_X or 0
        local offsetY = data.textOffsetY or (preset.text and preset.text.offsetY) or wt.TEXT_DEFAULT_OFFSET_Y or 0
        container.fontString:ClearAllPoints()
        container.fontString:SetPoint("CENTER", container.frame, "CENTER", offsetX, offsetY)
        
        -- Set text content (can be empty string if no default text is defined)
        container.fontString:SetText(textContent or "")
        container.fontString:Show()
    end
    
    -- Handle animation type (use override if provided, otherwise use preset default)
    local animType = data.type or preset.type or "static"
    
    if animType == "motion" then
        -- Get motion parameters (use overrides if provided, otherwise use preset defaults)
        local columns = data.columns or preset.columns or 1
        local rows = data.rows or preset.rows or 1
        local totalFrames = data.totalFrames or preset.totalFrames or 1
        local fps = data.fps or preset.fps or 30
        
        -- Update preset values for animation
        container.columns = columns
        container.rows = rows
        container.totalFrames = totalFrames
        container.fps = fps
        
        self:StartStopMotionAnimation(presetName, container)
    else
        -- Static texture - stop animation if running
        if container.animationTimer then
            container.animationTimer:Cancel()
            container.animationTimer = nil
        end
        
        -- Reset to full texture
        container.texture:SetTexCoord(0, 1, 0, 1)
        container.frame:Show()
    end
    
    -- Play sound - support both soundKey (from preset.sounds) and direct sound path
    if data.soundKey then
        if preset.sounds and preset.sounds[data.soundKey] then
            self:PlayPresetSound(presetName, data.soundKey)
        else
            -- Fallback: treat soundKey as direct path
            local soundPath = data.soundKey
            -- If no slashes, try LSM lookup
            if not soundPath:find("[/\\]") then
                local lsmSound = wt.LSM:Fetch("sound", soundPath)
                if lsmSound then
                    soundPath = lsmSound
                end
            end
            local soundChannel = data.soundChannel or (preset.sound and preset.sound.channel) or "Master"
            PlaySoundFile(soundPath, soundChannel)
        end
    elseif data.sound then
        -- Alternative: data.sound as direct path
        local soundPath = data.sound
        -- If no slashes, try LSM lookup
        if not soundPath:find("[/\\]") then
            local lsmSound = wt.LSM:Fetch("sound", soundPath)
            if lsmSound then
                soundPath = lsmSound
            end
        end
        local soundChannel = data.soundChannel or (preset.sound and preset.sound.channel) or "Master"
        PlaySoundFile(soundPath, soundChannel)
    elseif preset.sound and preset.sound.file then
        -- Use default sound from preset settings (if no data.sound provided)
        local soundPath = preset.sound.file
        local soundChannel = data.soundChannel or preset.sound.channel or "Master"
        
        if type(soundPath) == "number" then
            -- FileID, use directly
            PlaySoundFile(soundPath, soundChannel)
        elseif type(soundPath) == "string" then
            -- String path or LSM name
            if not soundPath:find("[/\\]") then
                local lsmSound = wt.LSM:Fetch("sound", soundPath)
                if lsmSound then
                    soundPath = lsmSound
                end
            end
            PlaySoundFile(soundPath, soundChannel)
        end
    end
    
    -- Process timeline if provided
    if data.timeline then
        container.timelineTimers = {}
        local duration = preset.duration or 2.5
        
        -- Check if timeline has destroy event
        local hasDestroyEvent = false
        for _, evt in ipairs(data.timeline) do
            if evt.destroy then
                hasDestroyEvent = true
                break
            end
        end
        
        for i, event in ipairs(data.timeline) do
            local delay = event.delay or 0
            
            -- Validate delay against duration
            if not hasDestroyEvent and delay > duration then
                print(string.format("[WeakTextures] WARNING: Timeline event #%d has delay %.2fs which exceeds preset duration %.2fs", i, delay, duration))
            end
            
            local timer = C_Timer.NewTimer(delay, function()
                if not container.active then return end
                
                -- Update parameters
                if event.update then
                    self:UpdateContainerParameters(presetName, container, event.update, preset)
                end
                
                -- Destroy instance
                if event.destroy then
                    -- Cancel remaining timeline timers
                    if container.timelineTimers then
                        for _, t in ipairs(container.timelineTimers) do
                            if t then t:Cancel() end
                        end
                        container.timelineTimers = nil
                    end
                    
                    -- Cancel auto-cleanup timer if it exists
                    if container.autoCleanupTimer then
                        container.autoCleanupTimer:Cancel()
                        container.autoCleanupTimer = nil
                    end
                    
                    self:ReleaseFrame(presetName, container)
                end
            end)
            
            table.insert(container.timelineTimers, timer)
        end
        
        -- Auto-cleanup after duration (but NOT if timeline has destroy event)
        local duration = preset.duration or 2.5
        if duration and duration > 0 and not hasDestroyEvent then
            container.autoCleanupTimer = C_Timer.NewTimer(duration, function()
                if not container.active then return end
                
                -- Cancel timeline timers
                if container.timelineTimers then
                    for _, timer in ipairs(container.timelineTimers) do
                        if timer then timer:Cancel() end
                    end
                    container.timelineTimers = nil
                end
                
                self:ReleaseFrame(presetName, container)
            end)
        end
    else
        -- No timeline, use standard auto-cleanup
        local duration = preset.duration or 2.5
        if duration and duration > 0 then
            container.autoCleanupTimer = C_Timer.NewTimer(duration, function()
                if not container.active then return end
                
                self:ReleaseFrame(presetName, container)
            end)
        end
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
    
    container.currentFrame = 0
    container.elapsed = 0
    
    -- Set initial texture coordinates for first frame
    container.texture:SetTexCoord(0, 1/columns, 0, 1/rows)
    
    -- Force parent and show
    container.frame:SetParent(UIParent)
    container.frame:Show()
    
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

---Update container parameters without restarting animation
---@param presetName string
---@param container table
---@param updates table
---@param preset table
function wt:UpdateContainerParameters(presetName, container, updates, preset)
    if not container or not container.frame or not container.active or not updates then
        return
    end
    
    local frame = container.frame
    
    -- Update alpha
    if updates.alpha ~= nil then
        frame:SetAlpha(updates.alpha)
    end
    
    -- Update scale
    if updates.scale then
        frame:SetScale(updates.scale)
    end
    
    -- Update texture
    if updates.texture then
        local texturePath = updates.texture
        if not texturePath:find("[/\\]") then
            local lsmTexture = self.LSM:Fetch("background", texturePath)
            if lsmTexture then
                texturePath = lsmTexture
            end
        end
        
        if container.texture then
            container.texture:SetTexture(texturePath)
            if preset.type ~= "motion" then
                container.texture:SetTexCoord(0, 1, 0, 1)
            end
        end
    end
    
    -- Update position
    if updates.offsetX or updates.offsetY then
        local textureData = preset.textures and preset.textures[1]
        if textureData then
            local anchor = _G[textureData.anchor] or UIParent
            local baseX = container.instanceData.offsetX or textureData.x or 0
            local baseY = container.instanceData.offsetY or textureData.y or 0
            local x = baseX + (updates.offsetX or 0)
            local y = baseY + (updates.offsetY or 0)
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", anchor, "CENTER", x, y)
        end
    end
    
    -- Update text
    if container.fontString then
        if updates.text then
            container.fontString:SetText(updates.text)
            container.fontString:Show()
        end
        
        if updates.font or updates.fontSize or updates.fontOutline then
            local currentFont, currentSize, currentOutline = container.fontString:GetFont()
            local font = updates.font
            local fontSize = updates.fontSize or currentSize or wt.TEXT_DEFAULT_SIZE
            local fontOutline = updates.fontOutline or currentOutline or wt.TEXT_DEFAULT_OUTLINE
            
            if font then
                if not font:match("^Interface") and not font:match("^Fonts") then
                    font = self.LSM:Fetch("font", font) or font
                end
            else
                font = currentFont or "Fonts\\FRIZQT__.TTF"
            end
            
            container.fontString:SetFont(font, fontSize, fontOutline)
            
            -- Restore color after SetFont if no explicit textColor provided
            if not updates.textColor then
                if preset.text and preset.text.color then
                    -- Use preset default color
                    container.fontString:SetTextColor(
                        preset.text.color.r, preset.text.color.g,
                        preset.text.color.b, preset.text.color.a)
                else
                    -- Fall back to gold default color
                    container.fontString:SetTextColor(wt.TEXT_DEFAULT_COLOR.r, wt.TEXT_DEFAULT_COLOR.g, wt.TEXT_DEFAULT_COLOR.b, wt.TEXT_DEFAULT_COLOR.a)
                end
            end
        end
        
        if updates.textColor then
            container.fontString:SetTextColor(
                updates.textColor.r or 1,
                updates.textColor.g or 1,
                updates.textColor.b or 1,
                updates.textColor.a or 1
            )
        end
        
        if updates.textOffsetX or updates.textOffsetY or updates.textLeftPoint or updates.textRightPoint then
            local currentLeftPoint, _, currentRightPoint, currentX, currentY = container.fontString:GetPoint(1)
            local textOffsetX = updates.textOffsetX or currentX or 0
            local textOffsetY = updates.textOffsetY or currentY or 0
            local textLeftPoint = updates.textLeftPoint or currentLeftPoint or "CENTER"
            local textRightPoint = updates.textRightPoint or currentRightPoint or "CENTER"
            
            container.fontString:ClearAllPoints()
            container.fontString:SetPoint(textLeftPoint, frame, textRightPoint, textOffsetX, textOffsetY)
        end
    end
    
    -- Play sound
    if updates.sound then
        local soundPath = updates.sound
        local soundChannel = updates.soundChannel or (preset.sound and preset.sound.channel) or "Master"
        
        if type(soundPath) == "number" then
            -- FileID, use directly
            PlaySoundFile(soundPath, soundChannel)
        elseif type(soundPath) == "string" then
            -- String path or LSM name
            if not soundPath:find("[/\\]") then
                local lsmSound = self.LSM:Fetch("sound", soundPath)
                if lsmSound then
                    soundPath = lsmSound
                end
            end
            PlaySoundFile(soundPath, soundChannel)
        end
    elseif updates.soundKey then
        local soundChannel = updates.soundChannel or (preset.sound and preset.sound.channel) or "Master"
        self:PlayPresetSound(presetName, updates.soundKey, soundChannel)
    end
    
    -- Handle animation type change (static vs motion)
    if updates.type then
        if updates.type == "motion" then
            -- Get motion parameters (use updates if provided, otherwise container/preset defaults)
            local columns = updates.columns or container.columns or preset.columns or 1
            local rows = updates.rows or container.rows or preset.rows or 1
            local totalFrames = updates.totalFrames or container.totalFrames or preset.totalFrames or 1
            local fps = updates.fps or container.fps or preset.fps or 30
            
            -- Update container values
            container.columns = columns
            container.rows = rows
            container.totalFrames = totalFrames
            container.fps = fps
            
            -- Start/restart stop motion animation
            self:StartStopMotionAnimation(presetName, container)
        else
            -- Static texture - stop animation if running
            if container.animationTimer then
                container.animationTimer:Cancel()
                container.animationTimer = nil
            end
            
            -- Reset to full texture
            if container.texture then
                container.texture:SetTexCoord(0, 1, 0, 1)
            end
        end
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
    
    -- Clear instance defaults when cleaning up all instances
    local preset = WeakTexturesDB.presets[presetName]
    if preset then
        preset.instanceDefaults = nil
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
