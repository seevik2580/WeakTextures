-- =====================================================
-- WeakTextures Helpers
-- =====================================================
local _, wt = ...
local L = wt.L

-- Font settings
wt.customFont = "PT Sans Narrow Regular"
wt.customFontBold = "PT Sans Narrow Bold"

---@class TextureData
---@field anchor string
---@field width number
---@field x number

---@class PresetConditions
---@field class string|nil
---@field alive boolean|nil
---@field combat boolean|nil
---@field rested boolean|nil
---@field encounter boolean|nil
---@field petBattle boolean|nil
---@field vehicle boolean|nil
---@field instance boolean|nil
---@field housing boolean|nil
---@field playerName string|nil

---@class Preset
---@field enabled boolean
---@field textures TextureData[]
---@field originalGroup string|nil
---@field advancedEnabled boolean|nil
---@field trigger string|nil
---@field rows number|nil
---@field fps number|nil
---@field strata string|nil
---@field lastTriggerResult boolean|nil
---@field autoHideTimer table|nil
---@field children table<string,
---@field presets string[]
---@field id number
---@field name string
---@field id number

---@class TreeButton : Button
---@field text any
---@field count any

---Print debug message if debugging is enabled
---@param ... any
function wt:Debug(...)
    if not wt.debugEnabled then return end
    print("|cffff0000[WeakTextures]|r", ...)
end

---Apply custom font to a FontString
---@param fontString FontString
---@param size number|nil
---@param flags string|nil
---@param useBold boolean|nil
function wt:ApplyCustomFont(fontString, size, flags, useBold)
    if not fontString or not fontString.SetFont then
        return
    end
    
    local fontName = useBold and self.customFontBold or self.customFont
    local fontPath = self.LSM:Fetch("font", fontName)
    
    if fontPath then
        fontString:SetFont(fontPath, size or 12, flags or "")
    end
end

---Apply custom font to all UI elements recursively
function wt:ApplyCustomFonts()
    if not self.frame then
        return
    end
    
    -- Helper function to apply font to all children recursively
    local function applyToRegions(frame)
        if not frame then return end
        
        for _, region in ipairs({frame:GetRegions()}) do
            if region:GetObjectType() == "FontString" then
                local _, currentSize, currentFlags = region:GetFont()
                
                -- Determine if bold should be used based on current size
                local useBold = false
                if currentSize and currentSize >= 14 then
                    useBold = true
                end
                
                wt:ApplyCustomFont(region, currentSize or 12, currentFlags, useBold)
            end
        end
        
        -- Apply to children
        for _, child in ipairs({frame:GetChildren()}) do
            applyToRegions(child)
        end
    end
    
    applyToRegions(self.frame)
    
    -- Apply to any dialog frames
    if self.exportDialog then
        applyToRegions(self.exportDialog)
    end
    if self.profileExportDialog then
        applyToRegions(self.profileExportDialog)
    end
    if self.profileImportDialog then
        applyToRegions(self.profileImportDialog)
    end
    if self.presetTooltip then
        applyToRegions(self.presetTooltip)
    end
end

---Get localized display name for system groups
---@param groupName string
---@return string
function wt:GetLocalizedGroupName(groupName)
    local L = wt.L
    if groupName == "Ungrouped" then
        return L.STATUS_UNGROUPED
    elseif groupName == "Disabled" then
        return L.STATUS_DISABLED
    else
        return groupName
    end
end

---Rebuild the ADDON_EVENTS table based on all preset conditions
function wt:RebuildAddonEventsTable()
    WeakTexturesDB.ADDON_EVENTS = {}
    
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if preset.enabled and preset.conditions then
            wt:UpdateAddonEventsForPreset(presetName, preset)
        end
    end
end

---Helper function to register events (handles both string and table)
---@param eventOrTable string|table
---@param presetName string
---@param value boolean|nil
local function RegisterEventForPreset(eventOrTable, presetName, value)
    if type(eventOrTable) == "table" then
        for _, event in ipairs(eventOrTable) do
            WeakTexturesDB.ADDON_EVENTS[event] = WeakTexturesDB.ADDON_EVENTS[event] or {}
            WeakTexturesDB.ADDON_EVENTS[event][presetName] = value
        end
    else
        WeakTexturesDB.ADDON_EVENTS[eventOrTable] = WeakTexturesDB.ADDON_EVENTS[eventOrTable] or {}
        WeakTexturesDB.ADDON_EVENTS[eventOrTable][presetName] = value
    end
end

---Update ADDON_EVENTS table entries for a specific preset
---@param presetName string
---@param preset Preset
function wt:UpdateAddonEventsForPreset(presetName, preset)
    if not preset.conditions then return end
    
    local conditions = preset.conditions
    
    -- Class and Spec conditions (both use PLAYER_SPECIALIZATION_CHANGED)
    if conditions.class then
        -- Class is specified (not "Any Class")
        local event = "PLAYER_SPECIALIZATION_CHANGED"
        WeakTexturesDB.ADDON_EVENTS[event] = WeakTexturesDB.ADDON_EVENTS[event] or {}
        WeakTexturesDB.ADDON_EVENTS[event][presetName] = true
    else
        -- "Any Class" - remove from PLAYER_SPECIALIZATION_CHANGED if exists
        local event = "PLAYER_SPECIALIZATION_CHANGED"
        if WeakTexturesDB.ADDON_EVENTS[event] then
            WeakTexturesDB.ADDON_EVENTS[event][presetName] = nil
        end
    end
    
    -- Combat conditions
    if conditions.combat then
        local eventPos = wt.conditionEventMap.combat_positive
        local eventNeg = wt.conditionEventMap.combat_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    elseif conditions.notCombat then
        local eventPos = wt.conditionEventMap.combat_negative
        local eventNeg = wt.conditionEventMap.combat_positive
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
    
    -- Encounter conditions
    if conditions.encounter then
        local eventPos = wt.conditionEventMap.encounter_positive
        local eventNeg = wt.conditionEventMap.encounter_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    elseif conditions.notEncounter then
        local eventPos = wt.conditionEventMap.encounter_negative
        local eventNeg = wt.conditionEventMap.encounter_positive
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
    
    -- Alive conditions
    if conditions.alive then
        local eventPos = wt.conditionEventMap.alive_positive
        local eventNeg = wt.conditionEventMap.alive_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
    
    -- Dead conditions
    if conditions.dead then
        local eventPos = wt.conditionEventMap.dead_positive
        local eventNeg = wt.conditionEventMap.dead_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
    
    -- Rested conditions
    if conditions.rested then
        local event = wt.conditionEventMap.rested_positive
        RegisterEventForPreset(event, presetName, true)
    elseif conditions.notRested then
        local event = wt.conditionEventMap.rested_negative
        RegisterEventForPreset(event, presetName, true)
    end
    
    -- Pet Battle conditions
    if conditions.petBattle then
        local eventPos = wt.conditionEventMap.petBattle_positive
        local eventNeg = wt.conditionEventMap.petBattle_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    elseif conditions.notPetBattle then
        local eventPos = wt.conditionEventMap.petBattle_negative
        local eventNeg = wt.conditionEventMap.petBattle_positive
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
    
    -- Vehicle conditions
    if conditions.vehicle then
        local eventPos = wt.conditionEventMap.vehicle_positive
        local eventNeg = wt.conditionEventMap.vehicle_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    elseif conditions.notVehicle then
        local eventPos = wt.conditionEventMap.vehicle_negative
        local eventNeg = wt.conditionEventMap.vehicle_positive
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
    
    -- Instance conditions
    if conditions.instance or conditions.notInstance then
        local event = wt.conditionEventMap.instance_positive
        RegisterEventForPreset(event, presetName, true)
    end
    
    -- Housing conditions
    if conditions.housing then
        local eventPos = wt.conditionEventMap.housing_positive
        local eventNeg = wt.conditionEventMap.housing_negative
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    elseif conditions.nothousing then
        local eventPos = wt.conditionEventMap.housing_negative
        local eventNeg = wt.conditionEventMap.housing_positive
        RegisterEventForPreset(eventPos, presetName, true)
        RegisterEventForPreset(eventNeg, presetName, false)
    end
end

---Remove preset from all ADDON_EVENTS entries
---@param presetName string
function wt:RemovePresetFromAddonEvents(presetName)
    for event, presets in pairs(WeakTexturesDB.ADDON_EVENTS) do
        presets[presetName] = nil
    end
end

---Check if a preset matches its load conditions
---@param presetName string
---@return boolean
function wt:PresetMatchesConditions(presetName)
    if not WeakTexturesDB.presets[presetName] then
        return false
    end
    
    ---@type Preset
    local preset = WeakTexturesDB.presets[presetName]

    -- Ultimate condition: enabled
    if preset.enabled == false then
        return false
    end

    if not preset.conditions then
        return true
    end

    local class = preset.conditions.class
    local spec  = preset.conditions.spec

    -- Class check
    if class then
        local _, playerClass = UnitClass("player")
        if playerClass ~= class then
            return false
        end
    end

    -- Spec check
    if spec then
        local currentSpec = GetSpecialization()
        if not currentSpec then return false end

        local specID = GetSpecializationInfo(currentSpec)
        if specID ~= spec then
            return false
        end
    end

    -- Alive check
    if preset.conditions.alive then
        if UnitIsDeadOrGhost("player") then
            return false
        end
    end

    -- Dead check
    if preset.conditions.dead then
        if not UnitIsDeadOrGhost("player") then
            return false
        end
    end

    -- Combat check
    if preset.conditions.combat then
        if not UnitAffectingCombat("player") then
            return false
        end
    end

    -- Not Combat check
    if preset.conditions.notCombat then
        if UnitAffectingCombat("player") then
            return false
        end
    end

    -- Rested check
    if preset.conditions.rested then
        if not IsResting() then
            return false
        end
    end

    -- Not Rested check
    if preset.conditions.notRested then
        if IsResting() then
            return false
        end
    end

    -- Encounter check
    if preset.conditions.encounter then
        if not C_InstanceEncounter.IsEncounterInProgress() then
            return false
        end
    end

    -- Not Encounter check
    if preset.conditions.notEncounter then
        if C_InstanceEncounter.IsEncounterInProgress() then
            return false
        end
    end

    -- Pet Battle check
    if preset.conditions.petBattle then
        if not C_PetBattles.IsInBattle() then
            return false
        end
    end

    -- Not Pet Battle check
    if preset.conditions.notPetBattle then
        if C_PetBattles.IsInBattle() then
            return false
        end
    end

    -- Vehicle check
    if preset.conditions.vehicle then
        if not UnitInVehicle("player") then
            return false
        end
    end

    -- Not Vehicle check
    if preset.conditions.notVehicle then
        if UnitInVehicle("player") then
            return false
        end
    end

    -- Instance check
    if preset.conditions.instance then
        local inInstance = IsInInstance()
        if not inInstance then
            return false
        end
    end

    -- Not Instance check
    if preset.conditions.notInstance then
        local inInstance = IsInInstance()
        if inInstance then
            return false
        end
    end

    -- Housing check (player housing/garrison)
    if preset.conditions.housing then
        if not C_Housing.IsInsideHouseOrPlot() then
            return false
        end
    end

    -- Not Housing check
    if preset.conditions.nothousing then
        if C_Housing.IsInsideHouseOrPlot() then
            return false
        end
    end

    -- Player Name check
    if preset.conditions.playerName and preset.conditions.playerName ~= "" then
        local playerName = UnitName("player")
        if playerName ~= preset.conditions.playerName then
            return false
        end
    end

    -- Zone check
    if preset.conditions.zone and preset.conditions.zone ~= "" then
        local currentZone = GetZoneText()
        if currentZone ~= preset.conditions.zone then
            return false
        end
    end

    return true
end

---Create an anchored texture frame for a preset
---@param presetName string
---@param anchorName string
---@param texturePath string
---@param width number
---@param height number
---@param x number
---@param y number
function wt:CreateAnchoredTexture(presetName, anchorName, texturePath, width, height, x, y)
    local anchor = _G[anchorName]
    if not anchor then return end

    width  = tonumber(width)  or 64
    height = tonumber(height) or 64
    x = tonumber(x) or 0
    y = tonumber(y) or 0

    -- Use temporary coordinates if they exist (from dragging, runtime only)
    if wt.tempCoordinates and wt.tempCoordinates[presetName] then
        x = wt.tempCoordinates[presetName].x
        y = wt.tempCoordinates[presetName].y
    end

    wt.activeFramesByPreset[presetName] = wt.activeFramesByPreset[presetName] or {}
    local container = wt.activeFramesByPreset[presetName]
    local f = container.frame

    ---@type Preset
    local preset = WeakTexturesDB.presets[presetName]
    local strata = (preset and preset.strata) or "MEDIUM"
    local frameLevel = (preset and preset.frameLevel) or 100
    local scale = (preset and preset.scale) or 1
    
    -- Apply temp overrides from CreateInstance in single-instance mode
    if preset and preset.tempOverrides then
        if preset.tempOverrides.offsetX then x = x + preset.tempOverrides.offsetX end
        if preset.tempOverrides.offsetY then y = y + preset.tempOverrides.offsetY end
        if preset.tempOverrides.scale then scale = preset.tempOverrides.scale end
    end

    -- Texture is created only once, after that its only updated
    if not f then
        f = CreateFrame("Frame", nil, anchor)
        f:SetFrameStrata(strata)
        f:SetFrameLevel(frameLevel)

        f.texture = f:CreateTexture(nil, "ARTWORK")
        f.texture:SetAllPoints(f)

        f:EnableMouse(false)
        f:EnableMouseWheel(false)
        f.texture:EnableMouse(false)

        container.frame = f
        container.isLocked = true
    else
        -- Restore parent if it was removed by HideTextureFrame
        if f:GetParent() ~= anchor then
            f:SetParent(anchor)
        end
    end

    -- Update existing texture
    local absWidth = math.abs(width)
    local absHeight = math.abs(height)
    f:SetSize(absWidth, absHeight)
    f:ClearAllPoints()
    f:SetPoint("CENTER", anchor, "CENTER", x, y)
    f:SetFrameStrata(strata)
    f:SetFrameLevel(frameLevel)
    
    -- Apply temp texture override if exists
    if preset and preset.tempOverrides and preset.tempOverrides.texture then
        texturePath = preset.tempOverrides.texture
    end
    
    f.texture:SetTexture(texturePath)
    
    -- Set color
    local r, g, b, a = 1, 1, 1, 1
    if preset and preset.color then
        r = preset.color.r or 1
        g = preset.color.g or 1
        b = preset.color.b or 1
        a = preset.color.a or 1
    end
    f.texture:SetVertexColor(r, g, b, a)
    
    -- Apply texture mirroring based on sign of width/height
    local left, right = 0, 1
    local top, bottom = 0, 1
    
    if width < 0 then
        left, right = 1, 0
    end
    
    if height < 0 then
        top, bottom = 1, 0
    end
    
    f.texture:SetTexCoord(left, right, top, bottom)
    
    -- Apply rotation
    local angle = (preset and preset.angle) or 0
    if wt.tempAngles and wt.tempAngles[presetName] then
        angle = wt.tempAngles[presetName]
    end
    local angleRadians = math.rad(angle)
    f.texture:SetRotation(angleRadians)
    
    -- Apply scale
    f:SetScale(scale)
    
    -- Apply alpha
    local alpha = (preset and preset.alpha) or 1
    if preset and preset.tempOverrides and preset.tempOverrides.alpha ~= nil then
        alpha = preset.tempOverrides.alpha
    end
    f:SetAlpha(alpha)
    
    -- Handle text overlay from tempOverrides (multi-instance mode) OR from preset.text (single-instance mode)
    if preset and preset.tempOverrides and preset.tempOverrides.text then
        if not f.fontString then
            f.fontString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        end
        
        -- Apply text offset (use override, then preset.text fallback, then default)
        local textOffsetX = preset.tempOverrides.textOffsetX or (preset.text and preset.text.offsetX) or wt.TEXT_DEFAULT_OFFSET_X
        local textOffsetY = preset.tempOverrides.textOffsetY or (preset.text and preset.text.offsetY) or wt.TEXT_DEFAULT_OFFSET_Y
        local textLeftPoint = preset.tempOverrides.textLeftPoint or "CENTER"
        local textRightPoint = preset.tempOverrides.textRightPoint or "CENTER"
        f.fontString:ClearAllPoints()
        f.fontString:SetPoint(textLeftPoint, f, textRightPoint, textOffsetX, textOffsetY)
        
        -- Always apply font settings (use override, then preset.text fallback, then default)
        local font = preset.tempOverrides.font or (preset.text and preset.text.font) or "Fonts\\FRIZQT__.TTF"
        local fontSize = preset.tempOverrides.fontSize or (preset.text and preset.text.size) or wt.TEXT_DEFAULT_SIZE
        local fontOutline = preset.tempOverrides.fontOutline or (preset.text and preset.text.outline) or wt.TEXT_DEFAULT_OUTLINE
        
        -- If font is from LSM, fetch it
        if not font:match("^Interface") and not font:match("^Fonts") then
            local lsmFont = wt.LSM:Fetch("font", font)
            if lsmFont then
                font = lsmFont
            end
        end
        
        f.fontString:SetFont(font, fontSize, fontOutline)
        
        -- Apply text color (use override, then preset.text fallback, then default)
        if preset.tempOverrides.textColor then
            f.fontString:SetTextColor(
                preset.tempOverrides.textColor.r or 1,
                preset.tempOverrides.textColor.g or 1,
                preset.tempOverrides.textColor.b or 1,
                preset.tempOverrides.textColor.a or 1
            )
        elseif preset.text and preset.text.color then
            -- Use preset default color
            f.fontString:SetTextColor(
                preset.text.color.r, preset.text.color.g,
                preset.text.color.b, preset.text.color.a)
        else
            -- Default gold color like GameFontNormal
            f.fontString:SetTextColor(wt.TEXT_DEFAULT_COLOR.r, wt.TEXT_DEFAULT_COLOR.g, wt.TEXT_DEFAULT_COLOR.b, wt.TEXT_DEFAULT_COLOR.a)
        end
        
        f.fontString:SetText(preset.tempOverrides.text)
        f.fontString:Show()
    elseif preset and preset.text and preset.text.enabled then
        -- Single-instance mode: apply text settings from preset.text (even if content is empty for dynamic text)
        if not f.fontString then
            f.fontString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        end
        
        -- Apply text offset from preset.text
        local textOffsetX = preset.text.offsetX or wt.TEXT_DEFAULT_OFFSET_X
        local textOffsetY = preset.text.offsetY or wt.TEXT_DEFAULT_OFFSET_Y
        f.fontString:ClearAllPoints()
        f.fontString:SetPoint("CENTER", f, "CENTER", textOffsetX, textOffsetY)
        
        -- Apply font settings from preset.text
        local font = preset.text.font or "Fonts\\FRIZQT__.TTF"
        local fontSize = preset.text.size or wt.TEXT_DEFAULT_SIZE
        local fontOutline = preset.text.outline or wt.TEXT_DEFAULT_OUTLINE
        
        -- If font is from LSM, fetch it
        if not font:match("^Interface") and not font:match("^Fonts") then
            local lsmFont = wt.LSM:Fetch("font", font)
            if lsmFont then
                font = lsmFont
            end
        end
        
        f.fontString:SetFont(font, fontSize, fontOutline)
        
        -- Apply text color from preset.text
        if preset.text.color then
            f.fontString:SetTextColor(
                preset.text.color.r or 1,
                preset.text.color.g or 0.82,
                preset.text.color.b or 0,
                preset.text.color.a or 1
            )
        else
            -- Default gold color like GameFontNormal
            f.fontString:SetTextColor(wt.TEXT_DEFAULT_COLOR.r, wt.TEXT_DEFAULT_COLOR.g, wt.TEXT_DEFAULT_COLOR.b, wt.TEXT_DEFAULT_COLOR.a)
        end
        
        -- Set text content if provided (can be empty for dynamic text)
        if preset.text.content and preset.text.content ~= "" then
            f.fontString:SetText(preset.text.content)
        else
            -- No content yet, but fontString is configured and ready for dynamic text
            f.fontString:SetText("")
        end
        f.fontString:Show()
    elseif f.fontString then
        f.fontString:Hide()
    end
    
    -- Handle animation type change (static vs motion)
    local animType = (preset and preset.tempOverrides and preset.tempOverrides.type) or (preset and preset.type) or "static"
    
    if animType == "motion" then
        -- Start/restart stop motion animation
        local columns = (preset and preset.tempOverrides and preset.tempOverrides.columns) or (preset and preset.columns) or 1
        local rows = (preset and preset.tempOverrides and preset.tempOverrides.rows) or (preset and preset.rows) or 1
        local totalFrames = (preset and preset.tempOverrides and preset.tempOverrides.totalFrames) or (preset and preset.totalFrames) or 1
        local fps = (preset and preset.tempOverrides and preset.tempOverrides.fps) or (preset and preset.fps) or 30
        
        -- Cancel existing animation timer if any
        if container.animationTimer then
            container.animationTimer:Cancel()
            container.animationTimer = nil
        end
        
        -- Start animation from frame 0
        container.currentFrame = 0
        container.elapsed = 0
        local frameDuration = 1 / fps
        
        container.animationTimer = C_Timer.NewTicker(frameDuration, function()
            if not f or not f:IsVisible() then
                if container.animationTimer then
                    container.animationTimer:Cancel()
                    container.animationTimer = nil
                end
                return
            end
            
            container.currentFrame = (container.currentFrame + 1) % totalFrames
            
            local col = container.currentFrame % columns
            local row = math.floor(container.currentFrame / columns) % rows
            
            local left = col / columns
            local right = (col + 1) / columns
            local top = row / rows
            local bottom = (row + 1) / rows
            
            f.texture:SetTexCoord(left, right, top, bottom)
        end)
    else
        -- Static texture - stop animation if running
        if container.animationTimer then
            container.animationTimer:Cancel()
            container.animationTimer = nil
        end
        
        -- Reset to full texture
        f.texture:SetTexCoord(0, 1, 0, 1)
    end
    
    f:Show()
    
    -- Clear temp overrides after applying
    if preset and preset.tempOverrides then
        -- Play sound if specified in overrides
        if preset.tempOverrides.sound then
            wt:PlayPresetSound(presetName, nil, preset.tempOverrides.soundChannel or "Master", preset.tempOverrides.sound)
        end
        
        preset.tempOverrides = nil
    end
end

---Play a stop-motion animation for a preset
---@param presetName string
---@param anchorName string
---@param texturePath string
---@param width number
---@param height number
---@param x number
---@param y number
---@param columns number
---@param rows number
---@param totalFrames number
---@param fps number
function wt:PlayStopMotion(presetName, anchorName, texturePath, width, height, x, y, columns, rows, totalFrames, fps)
    local anchor = _G[anchorName]
    if not anchor then return end

    width = tonumber(width) or 64
    height = tonumber(height) or 64
    x = tonumber(x) or 0
    y = tonumber(y) or 0

    -- Use temporary coordinates if they exist (from dragging, runtime only)
    if wt.tempCoordinates and wt.tempCoordinates[presetName] then
        x = wt.tempCoordinates[presetName].x
        y = wt.tempCoordinates[presetName].y
    end
    
    columns = tonumber(columns) or 1
    rows = tonumber(rows) or 1
    totalFrames = tonumber(totalFrames) or 1
    fps = tonumber(fps) or 30

    wt.activeFramesByPreset[presetName] = wt.activeFramesByPreset[presetName] or {}
    local container = wt.activeFramesByPreset[presetName]
    local f = container.frame

    ---@type Preset
    local preset = WeakTexturesDB.presets[presetName]
    local strata = (preset and preset.strata) or "MEDIUM"
    local frameLevel = (preset and preset.frameLevel) or 100
    local scale = (preset and preset.scale) or 1
    
    -- Apply temp overrides from CreateInstance in single-instance mode
    if preset and preset.tempOverrides then
        if preset.tempOverrides.offsetX then x = x + preset.tempOverrides.offsetX end
        if preset.tempOverrides.offsetY then y = y + preset.tempOverrides.offsetY end
        if preset.tempOverrides.scale then scale = preset.tempOverrides.scale end
    end

    -- Texture is created only once, after that its only updated
    if not f then
        f = CreateFrame("Frame", nil, anchor)
        f:SetFrameStrata(strata)
        f:SetFrameLevel(frameLevel)

        f.texture = f:CreateTexture(nil, "ARTWORK")
        f.texture:SetAllPoints(f)

        f:EnableMouse(false)
        f:EnableMouseWheel(false)
        f.texture:EnableMouse(false)

        -- Animation vars
        f.currentFrame = 0
        f.elapsed = 0

        container.frame = f
        container.isLocked = true
    else
        -- Restore parent if it was removed by HideTextureFrame
        if f:GetParent() ~= anchor then
            f:SetParent(anchor)
        end
    end

    -- Update existing texture
    local absWidth = math.abs(width)
    local absHeight = math.abs(height)
    f:SetSize(absWidth, absHeight)
    f:ClearAllPoints()
    f:SetPoint("CENTER", anchor, "CENTER", x, y)
    f:SetFrameStrata(strata)
    f:SetFrameLevel(frameLevel)
    f.texture:SetTexture(texturePath)
    
    -- Set vertex color (applies to entire texture, not per-frame)
    local r, g, b, a = 1, 1, 1, 1
    if preset and preset.color then
        r = preset.color.r or 1
        g = preset.color.g or 1
        b = preset.color.b or 1
        a = preset.color.a or 1
    end
    f.texture:SetVertexColor(r, g, b, a)

    -- Apply rotation
    local angle = (preset and preset.angle) or 0
    if wt.tempAngles and wt.tempAngles[presetName] then
        angle = wt.tempAngles[presetName]
    end
    local angleRadians = math.rad(angle)
    f.texture:SetRotation(angleRadians)

    -- Apply scale
    f:SetScale(scale)
    
    -- Apply alpha
    local alpha = (preset and preset.alpha) or 1
    if preset and preset.tempOverrides and preset.tempOverrides.alpha ~= nil then
        alpha = preset.tempOverrides.alpha
    end
    f:SetAlpha(alpha)
    
    -- Handle text overlay from tempOverrides (multi-instance mode) OR from preset.text (single-instance mode)
    if preset and preset.tempOverrides and preset.tempOverrides.text then
        if not f.fontString then
            f.fontString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        end
        
        -- Apply text offset
        local textOffsetX = preset.tempOverrides.textOffsetX or wt.TEXT_DEFAULT_OFFSET_X
        local textOffsetY = preset.tempOverrides.textOffsetY or wt.TEXT_DEFAULT_OFFSET_Y
        local textLeftPoint = preset.tempOverrides.textLeftPoint or "CENTER"
        local textRightPoint = preset.tempOverrides.textRightPoint or "CENTER"
        f.fontString:ClearAllPoints()
        f.fontString:SetPoint(textLeftPoint, f, textRightPoint, textOffsetX, textOffsetY)
        
        -- Apply font settings INDEPENDENTLY for PlayStopMotion (fontSize can change without font)
        if preset.tempOverrides.font or preset.tempOverrides.fontSize or preset.tempOverrides.fontOutline then
            local font = preset.tempOverrides.font
            local fontSize = preset.tempOverrides.fontSize or wt.TEXT_DEFAULT_SIZE
            local fontOutline = preset.tempOverrides.fontOutline or wt.TEXT_DEFAULT_OUTLINE
            
            -- If font is from LSM, fetch it
            if font then
                if not font:match("^Interface") and not font:match("^Fonts") then
                    font = wt.LSM:Fetch("font", font) or font
                end
            else
                -- Use current font if not specified
                local currentFont = f.fontString:GetFont()
                font = currentFont or "Fonts\\FRIZQT__.TTF"
            end
            
            f.fontString:SetFont(font, fontSize, fontOutline)
        end
        
        -- Apply text color if provided
        if preset.tempOverrides.textColor then
            f.fontString:SetTextColor(
                preset.tempOverrides.textColor.r or 1,
                preset.tempOverrides.textColor.g or 1,
                preset.tempOverrides.textColor.b or 1,
                preset.tempOverrides.textColor.a or 1
            )
        else
            -- Default gold color like GameFontNormal
            f.fontString:SetTextColor(1, 0.82, 0, 1)
        end
        
        f.fontString:SetText(preset.tempOverrides.text)
        f.fontString:Show()
    elseif preset and preset.text and preset.text.enabled then
        -- Single-instance mode: apply text settings from preset.text (even if content is empty for dynamic text)
        if not f.fontString then
            f.fontString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        end
        
        -- Apply text offset from preset.text
        local textOffsetX = preset.text.offsetX or wt.TEXT_DEFAULT_OFFSET_X
        local textOffsetY = preset.text.offsetY or wt.TEXT_DEFAULT_OFFSET_Y
        f.fontString:ClearAllPoints()
        f.fontString:SetPoint("CENTER", f, "CENTER", textOffsetX, textOffsetY)
        
        -- Apply font settings from preset.text
        local font = preset.text.font or "Fonts\\FRIZQT__.TTF"
        local fontSize = preset.text.size or wt.TEXT_DEFAULT_SIZE
        local fontOutline = preset.text.outline or wt.TEXT_DEFAULT_OUTLINE
        
        -- If font is from LSM, fetch it
        if not font:match("^Interface") and not font:match("^Fonts") then
            local lsmFont = wt.LSM:Fetch("font", font)
            if lsmFont then
                font = lsmFont
            end
        end
        
        f.fontString:SetFont(font, fontSize, fontOutline)
        
        -- Apply text color from preset.text
        if preset.text.color then
            f.fontString:SetTextColor(
                preset.text.color.r or 1,
                preset.text.color.g or 0.82,
                preset.text.color.b or 0,
                preset.text.color.a or 1
            )
        else
            -- Default gold color like GameFontNormal
            f.fontString:SetTextColor(wt.TEXT_DEFAULT_COLOR.r, wt.TEXT_DEFAULT_COLOR.g, wt.TEXT_DEFAULT_COLOR.b, wt.TEXT_DEFAULT_COLOR.a)
        end
        
        -- Set text content if provided (can be empty for dynamic text)
        if preset.text.content and preset.text.content ~= "" then
            f.fontString:SetText(preset.text.content)
        else
            -- No content yet, but fontString is configured and ready for dynamic text
            f.fontString:SetText("")
        end
        f.fontString:Show()
    elseif f.fontString then
        f.fontString:Hide()
    end
    
    -- Store sign for animation texture coord calculation
    local flipHorizontal = (width < 0)
    local flipVertical = (height < 0)

    -- Wait for texture to load before setting tex coord and starting animation
    local function checkLoaded()
        if f.texture:GetWidth() > 0 then
            -- Set initial tex coord for frame 0
            local col = 0
            local row = 0
            
            -- Apply mirroring to texture coordinates
            local left, right = col / columns, (col + 1) / columns
            local top, bottom = row / rows, (row + 1) / rows
            
            if flipHorizontal then
                left, right = right, left
            end
            if flipVertical then
                top, bottom = bottom, top
            end
            
            f.texture:SetTexCoord(left, right, top, bottom)

            -- Reset animation
            f.currentFrame = 0
            f.elapsed = 0

            f:Show()

            -- Start animation
            f:SetScript("OnUpdate", function(self, delta)
                self.elapsed = self.elapsed + delta
                if self.elapsed >= (1 / fps) then
                    self.elapsed = 0
                    self.currentFrame = (self.currentFrame + 1) % totalFrames
                end
                local col = self.currentFrame % columns
                local row = math.floor(self.currentFrame / columns)
                
                -- Apply mirroring to texture coordinates
                local left, right = col / columns, (col + 1) / columns
                local top, bottom = row / rows, (row + 1) / rows
                
                if flipHorizontal then
                    left, right = right, left
                end
                if flipVertical then
                    top, bottom = bottom, top
                end
                
                self.texture:SetTexCoord(left, right, top, bottom)
            end)
        else
            C_Timer.After(0.01, checkLoaded)
        end
    end
    checkLoaded()
    
    -- Play sound from tempOverrides after showing frame
    if preset and preset.tempOverrides and preset.tempOverrides.sound then
        wt:PlayPresetSound(presetName, nil, preset.tempOverrides.soundChannel or "Master", preset.tempOverrides.sound)
    end
    
    -- Clear temp overrides after applying
    if preset and preset.tempOverrides then
        preset.tempOverrides = nil
    end
end

---Update existing frame with new parameters without restarting animation
---@param presetName string
---@param container table
---@param overrides table
function wt:UpdateExistingFrame(presetName, container, overrides)
    if not container or not container.frame or not overrides then
        return
    end
    
    local frame = container.frame
    local preset = WeakTexturesDB.presets[presetName]
    
    -- Update size (only if explicitly provided in override)
    if overrides.width or overrides.height then
        local currentWidth, currentHeight = frame:GetSize()
        local width = overrides.width or currentWidth
        local height = overrides.height or currentHeight
        frame:SetSize(width, height)
    end
    
    -- Update layering (only if explicitly provided in override)
    if overrides.strata then
        frame:SetFrameStrata(overrides.strata)
    end
    if overrides.frameLevel then
        frame:SetFrameLevel(overrides.frameLevel)
    end
    
    -- Update texture (only if explicitly provided in override)
    if overrides.texture then
        local texturePath = overrides.texture
        
        -- If texture name has no slashes, try LSM lookup
        if not texturePath:find("[/\\]") then
            local lsmTexture = self.LSM:Fetch("background", texturePath)
            if lsmTexture then
                texturePath = lsmTexture
            end
        end
        
        if frame.texture then
            frame.texture:SetTexture(texturePath)
            
            -- For static textures, reset tex coords
            if preset.type ~= "motion" then
                frame.texture:SetTexCoord(0, 1, 0, 1)
            end
        end
    end
    
    -- Update vertex color (only if explicitly provided in override)
    if overrides.color and frame.texture then
        frame.texture:SetVertexColor(
            overrides.color.r or 1,
            overrides.color.g or 1,
            overrides.color.b or 1,
            overrides.color.a or 1
        )
    end
    
    -- Update rotation (only if explicitly provided in override)
    if overrides.angle ~= nil and frame.texture then
        local angleRadians = math.rad(overrides.angle)
        frame.texture:SetRotation(angleRadians)
    end
    
    -- Update alpha (only if explicitly provided in override)
    if overrides.alpha ~= nil then
        frame:SetAlpha(overrides.alpha)
    end
    
    -- Update scale (only if explicitly provided in override)
    if overrides.scale then
        frame:SetScale(overrides.scale)
    end
    
    -- Update position (only if explicitly provided in override)
    if overrides.anchor or overrides.x or overrides.y or overrides.offsetX or overrides.offsetY then
        local textureData = preset.textures and preset.textures[1]
        if textureData then
            -- Use override anchor or fall back to preset anchor
            local anchorName = overrides.anchor or textureData.anchor or "UIParent"
            local anchor = _G[anchorName] or UIParent
            
            -- Base position (from override or preset)
            local baseX = overrides.x or textureData.x or 0
            local baseY = overrides.y or textureData.y or 0
            
            -- Add offset if provided
            local offsetX = overrides.offsetX or 0
            local offsetY = overrides.offsetY or 0
            
            local x = baseX + offsetX
            local y = baseY + offsetY
            
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", anchor, "CENTER", x, y)
        end
    end
    
    -- Update stop motion animation parameters (only if explicitly provided in override)
    if overrides.columns or overrides.rows or overrides.totalFrames or overrides.fps then
        -- For stop motion animations, update animation parameters
        -- Note: These changes won't restart the animation, just update the frame calculation
        if preset.type == "motion" and frame.SetScript then
            local columns = overrides.columns or preset.columns or 1
            local rows = overrides.rows or preset.rows or 1
            local totalFrames = overrides.totalFrames or preset.totalFrames or 1
            local fps = overrides.fps or preset.fps or 30
            
            -- Store updated values for animation script
            preset.columns = columns
            preset.rows = rows
            preset.totalFrames = totalFrames
            preset.fps = fps
            
            -- Note: Animation script will use these new values on next frame
        end
    end
    
    -- Update or create text
    if overrides.text or overrides.font or overrides.fontSize or overrides.fontOutline or overrides.textColor then
        -- Create fontString if it doesn't exist and text is provided
        if not frame.fontString and overrides.text then
            frame.fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            
            -- Set default position if not specified
            frame.fontString:SetPoint("CENTER", frame, "CENTER", 0, 0)
        end
        
        if frame.fontString then
            -- Update text content
            if overrides.text then
                frame.fontString:SetText(overrides.text)
                frame.fontString:Show()
            end
            
            -- Always apply font settings when text is present (use instanceDefaults, then preset.text as fallback)
            local currentFont, currentSize, currentOutline = frame.fontString:GetFont()
            local font = overrides.font or (preset.instanceDefaults and preset.instanceDefaults.font) or (preset.text and preset.text.font)
            local fontSize = overrides.fontSize or (preset.instanceDefaults and preset.instanceDefaults.fontSize) or (preset.text and preset.text.size) or currentSize or wt.TEXT_DEFAULT_SIZE
            local fontOutline = overrides.fontOutline or (preset.instanceDefaults and preset.instanceDefaults.fontOutline) or (preset.text and preset.text.outline) or currentOutline or wt.TEXT_DEFAULT_OUTLINE
            
            if font then
                if not font:match("^Interface") and not font:match("^Fonts") then
                    local lsmFont = self.LSM:Fetch("font", font)
                    if lsmFont then
                        font = lsmFont
                    end
                end
            else
                font = currentFont or "Fonts\\FRIZQT__.TTF"
            end
            
            frame.fontString:SetFont(font, fontSize, fontOutline)
            
            -- Update text color (use preset.text.color as fallback before default)
            if overrides.textColor then
                frame.fontString:SetTextColor(
                    overrides.textColor.r or 1,
                    overrides.textColor.g or 1,
                    overrides.textColor.b or 1,
                    overrides.textColor.a or 1
                )
            elseif preset.instanceDefaults and preset.instanceDefaults.textColor then
                frame.fontString:SetTextColor(
                    preset.instanceDefaults.textColor.r or 1,
                    preset.instanceDefaults.textColor.g or 1,
                    preset.instanceDefaults.textColor.b or 1,
                    preset.instanceDefaults.textColor.a or 1
                )
            elseif preset.text and preset.text.color then
                frame.fontString:SetTextColor(
                    preset.text.color.r,
                    preset.text.color.g,
                    preset.text.color.b,
                    preset.text.color.a
                )
            else
                -- Default gold color like GameFontNormal
                frame.fontString:SetTextColor(wt.TEXT_DEFAULT_COLOR.r, wt.TEXT_DEFAULT_COLOR.g, wt.TEXT_DEFAULT_COLOR.b, wt.TEXT_DEFAULT_COLOR.a)
            end
            
            -- Update text position (use instanceDefaults, then preset.text as fallback)
            if overrides.textOffsetX or overrides.textOffsetY or overrides.textLeftPoint or overrides.textRightPoint then
                local currentLeftPoint, _, currentRightPoint, currentX, currentY = frame.fontString:GetPoint(1)
                local textOffsetX = overrides.textOffsetX or (preset.instanceDefaults and preset.instanceDefaults.textOffsetX) or (preset.text and preset.text.offsetX) or currentX or 0
                local textOffsetY = overrides.textOffsetY or (preset.instanceDefaults and preset.instanceDefaults.textOffsetY) or (preset.text and preset.text.offsetY) or currentY or 0
                local textLeftPoint = overrides.textLeftPoint or (preset.instanceDefaults and preset.instanceDefaults.textLeftPoint) or currentLeftPoint or "CENTER"
                local textRightPoint = overrides.textRightPoint or (preset.instanceDefaults and preset.instanceDefaults.textRightPoint) or currentRightPoint or "CENTER"
                
                frame.fontString:ClearAllPoints()
                frame.fontString:SetPoint(textLeftPoint, frame, textRightPoint, textOffsetX, textOffsetY)
            end
        end
    end
    
    -- Play sound if specified
    if overrides.sound then
        local soundPath = overrides.sound
        local soundChannel = overrides.soundChannel or (preset.sound and preset.sound.channel) or "Master"
        
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
    elseif overrides.soundKey then
        -- Support for preset sound library
        local soundChannel = overrides.soundChannel or (preset.sound and preset.sound.channel) or "Master"
        self:PlayPresetSound(presetName, overrides.soundKey, soundChannel)
    end
    
    -- Handle animation type change (static vs motion)
    if overrides.type then
        if overrides.type == "motion" then
            -- Get motion parameters (use overrides if provided, otherwise use preset/instanceDefaults)
            local columns = overrides.columns or (preset.instanceDefaults and preset.instanceDefaults.columns) or preset.columns or 1
            local rows = overrides.rows or (preset.instanceDefaults and preset.instanceDefaults.rows) or preset.rows or 1
            local totalFrames = overrides.totalFrames or (preset.instanceDefaults and preset.instanceDefaults.totalFrames) or preset.totalFrames or 1
            local fps = overrides.fps or (preset.instanceDefaults and preset.instanceDefaults.fps) or preset.fps or 30
            
            -- Cancel existing animation timer if any
            if container.animationTimer then
                container.animationTimer:Cancel()
                container.animationTimer = nil
            end
            
            -- Start animation from frame 0
            container.currentFrame = 0
            container.elapsed = 0
            local frameDuration = 1 / fps
            
            container.animationTimer = C_Timer.NewTicker(frameDuration, function()
                if not frame or not frame:IsVisible() then
                    if container.animationTimer then
                        container.animationTimer:Cancel()
                        container.animationTimer = nil
                    end
                    return
                end
                
                container.currentFrame = (container.currentFrame + 1) % totalFrames
                
                local col = container.currentFrame % columns
                local row = math.floor(container.currentFrame / columns) % rows
                
                local left = col / columns
                local right = (col + 1) / columns
                local top = row / rows
                local bottom = (row + 1) / rows
                
                frame.texture:SetTexCoord(left, right, top, bottom)
            end)
        else
            -- Static texture - stop animation if running
            if container.animationTimer then
                container.animationTimer:Cancel()
                container.animationTimer = nil
            end
            
            -- Reset to full texture
            if frame.texture then
                frame.texture:SetTexCoord(0, 1, 0, 1)
            end
        end
    end
end

---Hide and cleanup the texture frame for a preset
---@param presetName string
function wt:HideTextureFrame(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    
    -- Check if using multi-instance system
    if preset and preset.instancePool and preset.instancePool.enabled then
        -- Cleanup all instances (e.g., when conditions no longer met)
        wt:CleanupAllInstances(presetName)
        return
    end
    
    -- Legacy single-frame system
    local container = wt.activeFramesByPreset[presetName]
    if not container then 
        return 
    end

    local f = container.frame
    if f and f.Hide then
        f:Hide()
        f:SetScale(1) -- Reset scale to default before cleanup
        f:SetParent(nil)
    end

    wt.activeFramesByPreset[presetName] = nil
    
    -- Clear instance defaults when hiding preset
    if preset then
        preset.instanceDefaults = nil
    end
end

---Get all available classes
---@return ClassInfo[]
function wt:GetAllClasses()
    local classes = {}
    for classID = 1, GetNumClasses() do
        local info = C_CreatureInfo.GetClassInfo(classID)
        if info then
            table.insert(classes, {
                id = classID,
                file = info.classFile,
                name = info.className,
            })
        end
    end
    return classes
end

---Get specializations for a specific class
---@param classFile string
---@return SpecInfo[]
function wt:GetSpecsForClass(classFile)
    local specs = {}

    for classID = 1, GetNumClasses() do
        local info = C_CreatureInfo.GetClassInfo(classID)
        if info and info.classFile == classFile then
            for i = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) do
                local specID, specName = GetSpecializationInfoForClassID(classID, i)
                table.insert(specs, {
                    id = specID,
                    name = specName
                })
            end
            break
        end
    end

    return specs
end

---Reset all UI fields to default values
function wt:allDefault()
    wt.selectedPreset = nil
    wt.frame.right:Hide()
    wt.frame.right:EnableMouse(false)
    wt.frame.right.configPanelContent.anchorTypeDropDown.selectedValue = "Screen"
    wt.frame.right.configPanelContent.anchorEdit:SetText("UIParent")
    wt.frame.right.configPanelContent.anchorEdit:Hide()
    wt.frame.right.configPanelContent.selectFrameBtn:Hide()
    wt.frame.right.configPanelContent.textureDropDown.selectedValue = "Custom"
    wt.frame.right.configPanelContent.textureDropDown.selectedPath = nil
    wt.frame.right.configPanelContent.textureCustomEdit:SetText("")
    wt.frame.right.configPanelContent.textureCustomEdit:Show()
    wt.frame.right.configPanelContent.widthEdit:SetText("")
    wt.frame.right.configPanelContent.heightEdit:SetText("")
    wt.frame.right.configPanelContent.scaleEdit:SetText(1)
    wt.frame.right.configPanelContent.alphaEdit:SetText(1.0)
    wt.frame.right.configPanelContent.angleEdit:SetText(0)
    wt.frame.right.configPanelContent.xOffsetEdit:SetText(0)
    wt.frame.right.configPanelContent.yOffsetEdit:SetText(0)
    wt.frame.right.configPanelContent.groupDropDown.selectedValue = ""
    wt.frame.right.configPanelContent.groupEditBox:SetText("")
    wt.frame.right.configPanelContent.groupEditBox:Hide()
    wt.frame.right.configPanelContent.presetNameEdit:SetText("")
    wt.frame.right.configPanelContent.columnsEdit:SetText("")
    wt.frame.right.configPanelContent.rowsEdit:SetText("")
    wt.frame.right.configPanelContent.totalFramesEdit:SetText("")
    wt.frame.right.configPanelContent.fpsEdit:SetText("")
    
    -- Reset text settings to defaults
    wt.frame.right.configPanelContent.textContentEdit:SetText("")
    wt.frame.right.configPanelContent.fontDropDown.selectedValue = "Friz Quadrata TT"
    wt.frame.right.configPanelContent.fontSizeEdit:SetText(wt.TEXT_DEFAULT_SIZE or 48)
    wt.frame.right.configPanelContent.fontOutlineDropDown.selectedValue = wt.TEXT_DEFAULT_OUTLINE or "OUTLINE"
    
    local defaultTextColor = wt.TEXT_DEFAULT_COLOR or {r=1, g=0.82, b=0, a=1}
    wt.frame.right.configPanelContent.textColorPicker:SetColor(defaultTextColor.r, defaultTextColor.g, defaultTextColor.b, defaultTextColor.a)
    
    wt.frame.right.configPanelContent.textOffsetXEdit:SetText(wt.TEXT_DEFAULT_OFFSET_X or 0)
    wt.frame.right.configPanelContent.textOffsetYEdit:SetText(wt.TEXT_DEFAULT_OFFSET_Y or 125)
    
    -- Reset texture color to white
    wt.frame.right.configPanelContent.textureColorPicker:SetColor(1, 1, 1, 1)
    
    -- Reset sound settings
    wt.frame.right.configPanelContent.soundDropDown.selectedValue = "None"
    wt.frame.right.configPanelContent.soundDropDown.selectedPath = nil
    wt.frame.right.configPanelContent.soundCustomEdit:SetText("")
    wt.frame.right.configPanelContent.soundCustomEdit:Hide()
    wt.frame.right.configPanelContent.soundChannelDropDown.selectedValue = "Master"
    
    wt.frame.right.conditionsPanel.enabledCheck:SetChecked(true)
    wt.frame.right.configPanelContent.frameLevelEdit:SetText("")
    wt.frame.right.conditionsPanel.aliveCheck:SetChecked(false)
    wt.frame.right.conditionsPanel.combatCheck:SetChecked(false)
    wt.frame.right.conditionsPanel.restedCheck:SetChecked(false)
    wt:SetShownMotionFields(false)
    wt.frame.right.configPanelContent.ftypeDropDown.selectedValue = "Static"
    wt.frame.right.conditionsPanel.classDropDown.selectedValue = "Any Class"
    wt.frame.right.conditionsPanel.specDropDown.selectedValue = "Any Spec"
    wt.frame.right.configPanelContent.strataDropDown.selectedValue = "MEDIUM"
    
    -- Reset advanced conditions
    wt.frame.right.conditionsPanel.advancedCheck:SetChecked(false)
    wt:ToggleAdvancedTab(false)
    wt.frame.right.advancedPanel.eventsEdit:SetText("")
    wt.frame.right.advancedPanel.triggerEdit:SetText("")
    wt.frame.right.advancedPanel.durationEdit:SetText("")
    wt.frame.right.advancedPanel.multiInstanceCheck:SetChecked(false)
    
    -- Disable unlock button when no preset is selected
    wt.frame.right.unlockFrameBtn:Disable()
    wt.frame.right.unlockFrameBtn:SetNormalAtlas(wt.buttonDisabled)
end

---Refresh the preset list display
function wt:RefreshPresetList()
    -- Check if UI is fully initialized
    if not wt.frame.left.dataProvider then
        return
    end
    
    -- Clear old data provider
    wt.frame.left.dataProvider:Flush()
    
    local tree = wt:BuildGroupTree()

    -- Collect and sort root group names: Ungrouped first, Disabled last, others alphabetical
    local rootNames = {}
    for name in pairs(tree.children) do
        table.insert(rootNames, name)
    end
    table.sort(rootNames, function(a, b)
        if a == "Ungrouped" then
            return true
        elseif b == "Ungrouped" then
            return false
        elseif a == "Disabled" then
            return false
        elseif b == "Disabled" then
            return true
        else
            return a < b
        end
    end)

    -- Render all root groups in sorted order using data provider
    for _, name in ipairs(rootNames) do
        wt:AddGroupNodeToProvider(tree.children[name], name, 0, wt.frame.left.dataProvider)
    end
    
    -- Force ScrollBox to recalculate layout
    if wt.frame.left.scrollBox then
        wt.frame.left.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
        
        -- Adjust wheel scroll speed to be consistent regardless of content size
        -- Calculate how many pixels per scroll tick (target: ~22px = one element)
        C_Timer.After(0.1, function()
            local scrollBox = wt.frame.left.scrollBox
            local scrollBar = wt.frame.left.scrollBar
            if scrollBox and scrollBar and scrollBar:IsVisible() then
                local visibleExtent = scrollBar.visibleExtentPercentage or 1
                if visibleExtent < 1 then
                    -- wheelPanScalar is a property that determines scroll speed
                    -- We want to scroll by approximately one element (22px) per wheel tick
                    local elementHeight = 20
                    local visibleHeight = scrollBox:GetHeight() or 440
                    local targetScrollPercent = elementHeight / visibleHeight
                    local desiredScalar = targetScrollPercent / math.max(scrollBox.panExtentPercentage or 1, 0.01)
                    scrollBox.wheelPanScalar = math.max(0.5, math.min(desiredScalar, 5))
                else
                    scrollBox.wheelPanScalar = 2 -- Default value
                end
            end
        end)
    end
end

---Show or hide stop-motion animation fields
---@param flag boolean
function wt:SetShownMotionFields(flag)
    wt.frame.right.configPanelContent.columnsLabel:SetShown(flag)
    wt.frame.right.configPanelContent.columnsEdit:SetShown(flag)
    wt.frame.right.configPanelContent.rowsLabel:SetShown(flag)
    wt.frame.right.configPanelContent.rowsEdit:SetShown(flag)
    wt.frame.right.configPanelContent.totalFramesLabel:SetShown(flag)
    wt.frame.right.configPanelContent.totalFramesEdit:SetShown(flag)
    wt.frame.right.configPanelContent.fpsLabel:SetShown(flag)
    wt.frame.right.configPanelContent.fpsEdit:SetShown(flag)
end

---Handle search box text change
---@param query string
function wt:OnSearchTextChanged(query)
    wt:RefreshPresetList()
end

---Check if a name matches the search query
---@param name string
---@param query string
---@return boolean
function wt:MatchesSearchQuery(name, query)
    if not query or query == "" then
        return true
    end
    
    name = name:lower()
    query = query:lower()
    
    local initPos = 1
    local noPatternMatch = true
    return string.find(name, query, initPos, noPatternMatch) ~= nil
end

---Check if a preset matches the active filters
---@param presetName string
---@return boolean
function wt:PresetMatchesFilters(presetName)
    if not wt.activeFilters or not next(wt.activeFilters) then
        return true
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.conditions then
        return false
    end
    
    local conditions = preset.conditions
    
    -- Check class filter
    if wt.activeFilters.class then
        if not conditions.class or conditions.class ~= wt.activeFilters.class then
            return false
        end
    end
    
    -- Check spec filter
    if wt.activeFilters.spec then
        if not conditions.spec or conditions.spec ~= wt.activeFilters.spec then
            return false
        end
    end
    
    -- Check combat filter
    if wt.activeFilters.combat ~= nil then
        if wt.activeFilters.combat then
            if not conditions.combat then
                return false
            end
        else
            if not conditions.notCombat then
                return false
            end
        end
    end
    
    -- Check encounter filter
    if wt.activeFilters.encounter ~= nil then
        if wt.activeFilters.encounter then
            if not conditions.encounter then
                return false
            end
        else
            if not conditions.notEncounter then
                return false
            end
        end
    end
    
    -- Check alive filter
    if wt.activeFilters.alive ~= nil then
        if wt.activeFilters.alive then
            if not conditions.alive then
                return false
            end
        else
            if conditions.alive or conditions.dead then
                return false
            end
        end
    end
    
    -- Check rested filter
    if wt.activeFilters.rested ~= nil then
        if wt.activeFilters.rested then
            if not conditions.rested then
                return false
            end
        else
            if not conditions.notRested then
                return false
            end
        end
    end
    
    -- Check petBattle filter
    if wt.activeFilters.petBattle ~= nil then
        if wt.activeFilters.petBattle then
            if not conditions.petBattle then
                return false
            end
        else
            if not conditions.notPetBattle then
                return false
            end
        end
    end
    
    -- Check vehicle filter
    if wt.activeFilters.vehicle ~= nil then
        if wt.activeFilters.vehicle then
            if not conditions.vehicle then
                return false
            end
        else
            if not conditions.notVehicle then
                return false
            end
        end
    end
    
    -- Check instance filter
    if wt.activeFilters.instance ~= nil then
        if wt.activeFilters.instance then
            if not conditions.instance then
                return false
            end
        else
            if not conditions.notInstance then
                return false
            end
        end
    end
    
    -- Check housing filter
    if wt.activeFilters.housing ~= nil then
        if wt.activeFilters.housing then
            if not conditions.housing then
                return false
            end
        else
            if not conditions.nothousing then
                return false
            end
        end
    end
    
    -- Check advanced filter
    if wt.activeFilters.advanced then
        if not preset.advancedEnabled or not preset.trigger or preset.trigger == "" then
            return false
        end
    end
    
    return true
end

---Create a right panel tab button
---@param key string
---@param text string
---@param xOffset number
---@return any
---Get localized tab text based on tab key
---@param tabKey string
---@return string
function wt:createRightTab(key, text, xOffset)
    local index = #wt.rightTabs + 1
    local btn = CreateFrame("Button", nil, wt.frame.right, "PanelTopTabButtonTemplate")
    
    Mixin( btn, PanelTopTabButtonMixin );
    btn:OnLoad()
    
    btn:SetText(text)
    btn:SetID(index)
    btn.tabKey = key

    if index == 1 then
        btn:SetPoint("TOPLEFT", wt.frame.right, "TOPLEFT", xOffset, 30)
    else
        local prevBtn = wt.rightTabs[index - 1]
        btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", xOffset - wt.PANELTABOFFSET_Y, 30)
    end

    btn:SetScript("OnClick", function(self) wt:OnRightTabClick(self) end)

    wt.rightTabs[index] = btn
    PanelTemplates_SetTab(wt.frame.right, index)
    return btn
end

---Create a three-state checkbox (unchecked, checked, not checked)
---@param parent any
---@param name string|nil
---@param labelText string
---@param initialState number|nil
---@param usePrefix string|nil
---@return any
function wt:CreateThreeStateCheckBox(parent, name, labelText, initialState, usePrefix)
    local checkBox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkBox:SetSize(24, 24)
    
    checkBox.state = initialState or 0
    checkBox.labelText = labelText
    checkBox.usePrefix = usePrefix or ""
    
    local function UpdateVisual()
        local L = wt.L
        local localizedLabel = L[checkBox.labelText] or checkBox.labelText
        local localizedPrefix = checkBox.usePrefix ~= "" and (L[checkBox.usePrefix] or checkBox.usePrefix) or ""
        local localizedNot = L.PREFIX_NOT or "Not "
        
        if checkBox.state == 0 then
            checkBox:SetChecked(false)
            checkBox.text:SetTextColor(1, 1, 1)
            checkBox.text:SetText(localizedLabel)
        elseif checkBox.state == 1 then
            checkBox:SetChecked(true)
            checkBox.text:SetTextColor(0, 1, 0)
            if checkBox.usePrefix ~= "" then
                checkBox.text:SetText(localizedPrefix .. localizedLabel)
            else
                checkBox.text:SetText(localizedLabel)
            end
        else
            checkBox:SetChecked(true)
            checkBox.text:SetTextColor(1, 0, 0)
            if checkBox.usePrefix ~= "" then
                checkBox.text:SetText(localizedNot .. localizedPrefix .. localizedLabel)
            else
                checkBox.text:SetText(localizedNot .. localizedLabel)
            end
        end
    end
    
    checkBox.UpdateVisual = UpdateVisual
    UpdateVisual()
    
    checkBox:SetScript("OnClick", function(self)
        if self.state == 0 then
            self.state = 1
        elseif self.state == 1 then
            self.state = -1
        else
            self.state = 0
        end
        UpdateVisual()
        
        if self.onStateChange then
            self.onStateChange(self.state)
        end
    end)
    
    function checkBox:GetState()
        return self.state
    end
    
    function checkBox:SetState(newState)
        self.state = newState
        UpdateVisual()
    end
    
    return checkBox
end

---Show a specific right panel tab
---@param key string
function wt:ShowRightTab(key)
    if type(self.rightPanels) ~= "table" then
        return
    end
    for _, panel in pairs(self.rightPanels) do
        if panel and panel.Hide then
            panel:Hide()
        end
    end

    local panel = self.rightPanels[key]
    if panel and panel.Show then
        panel:Show()
    end
    
    -- Store current tab
    wt.currentRightTab = key
    
    -- Update tab visual selection
    for _, tab in ipairs(wt.rightTabs) do
        if tab.tabKey == key then
            PanelTemplates_SetTab(wt.frame.right, tab:GetID())
            break
        end
    end

    -- Hide tabs when import panel is shown
    if key == "import" then
        for _, tab in ipairs(wt.rightTabs) do
            tab:Hide()
        end
    else
        for _, tab in ipairs(wt.rightTabs) do
            -- Only show advanced tab if enabled
            if tab.tabKey == "advanced" then
                local advancedEnabled = wt.frame.right.conditionsPanel.advancedCheck:GetChecked()
                if advancedEnabled then
                    tab:Show()
                else
                    tab:Hide()
                end
            else
                tab:Show()
            end
        end
    end
end

---Toggle the visibility of the advanced tab
---@param enabled boolean
function wt:ToggleAdvancedTab(enabled)
    for _, tab in ipairs(wt.rightTabs) do
        if tab.tabKey == "advanced" then
            if enabled then
                tab:Show()
            else
                tab:Hide()
                -- If currently on advanced tab, switch to display
                if wt.frame.right.advancedPanel:IsShown() then
                    wt:ShowRightTab("display")
                end
            end
            break
        end
    end
end

---Register a custom texture with LibSharedMedia
---@param texturePath string
---@return string|nil
function wt:RegisterCustomTexture(texturePath)
    if not texturePath or texturePath == "" then return nil end
    
    -- Extract filename from path for the texture name
    local textureName = texturePath:match("([^/\\]+)$") or texturePath
    -- Remove file extension
    textureName = textureName:gsub("%.[^%.]+$", "")
    -- Add prefix to identify as WeakTextures custom texture
    textureName = "WT_" .. textureName
    
    -- Check if already registered
    if WeakTexturesCustomTextures[textureName] then
        return textureName
    end
    
    -- Try to register with LSM
    local success = pcall(function()
        wt.LSM:Register("background", textureName, texturePath)
    end)
    
    if success then
        WeakTexturesCustomTextures[textureName] = texturePath
        return textureName
    end
    
    return nil
end

---Handle the "Add Texture" button click
---Creates or updates a preset with current UI field values, validates conditions,
---registers/deregisters events, and displays the texture if conditions are met
function wt:OnAddTextureClick()
    if not wt.frame.right:IsShown() or (wt.frame.right.importPanel and wt.frame.right.importPanel:IsShown()) then
        wt:ShowRightTab("display")
    end
    
    wt.frame.right:EnableMouse(true)
    wt.frame.right:Show()
    local newPresetName = strtrim(wt.frame.right.configPanelContent.presetNameEdit:GetText())
    local anchorName = wt.frame.right.configPanelContent.anchorEdit:GetText() or "UIParent"
    
    -- Get texture path from dropdown or custom edit
    local texturePath = ""
    if wt.frame.right.configPanelContent.textureDropDown.selectedValue == "Custom" then
        texturePath = wt.frame.right.configPanelContent.textureCustomEdit:GetText() or ""
        -- Auto-register custom texture if enabled
        if WeakTexturesSettings.autoRegisterCustomTextures and texturePath ~= "" then
            wt:RegisterCustomTexture(texturePath)
        end
    else
        texturePath = wt.frame.right.configPanelContent.textureDropDown.selectedPath or ""
    end
    
    if anchorName == "" or texturePath == "" then return end
    
    -- Auto-lock frame if it's unlocked before saving
    if wt.selectedPreset then
        local container = wt.activeFramesByPreset[wt.selectedPreset]
        if container and container.isLocked == false then
            wt:OnLockOrUnlockTextureToDrag()
        end
    end

    if newPresetName ~= "" and newPresetName ~= wt.selectedPreset then
        if wt.selectedPreset then
            wt:RenamePreset(wt.selectedPreset, newPresetName)
            wt.selectedPreset = newPresetName
        else
            WeakTexturesDB.presets[newPresetName] = { textures = {}, group = nil, enabled = true, type = "static" }
            wt.selectedPreset = newPresetName
        end
    end

    if not wt.selectedPreset then return end
    if not WeakTexturesDB.presets[wt.selectedPreset] then return end
    
    ---@type Preset
    local preset = WeakTexturesDB.presets[wt.selectedPreset]

    local classText = wt.frame.right.conditionsPanel.classDropDown.selectedValue or "Any Class"
    local specText = wt.frame.right.conditionsPanel.specDropDown.selectedValue or "Any Spec"
    preset.conditions = preset.conditions or {}
    if classText == "Any Class" then
        preset.conditions.class = nil
        preset.conditions.spec = nil
    else
        for _, class in ipairs(wt:GetAllClasses()) do
            if class.name == classText then
                preset.conditions.class = class.file
                break
            end
        end
        if specText == "Any Spec" then
            preset.conditions.spec = nil
        else
            for _, spec in ipairs(wt:GetSpecsForClass(preset.conditions.class)) do
                if spec.name == specText then
                    preset.conditions.spec = spec.id
                    break
                end
            end
        end
    end

    ---Helper function to set condition states from three-state checkbox
    ---@param checkBox any
    ---@param condition string
    ---@param notCondition string
    local function setState(checkBox, condition, notCondition)
        local state = checkBox:GetState()
        if state == 1 then
            preset.conditions[condition] = true
            preset.conditions[notCondition] = false
        elseif state == -1 then
            preset.conditions[condition] = false
            preset.conditions[notCondition] = true
        else
            preset.conditions[condition] = false
            preset.conditions[notCondition] = false
        end
    end

    setState(wt.frame.right.conditionsPanel.aliveCheck, "alive", "dead")
    setState(wt.frame.right.conditionsPanel.combatCheck, "combat", "notCombat")
    setState(wt.frame.right.conditionsPanel.restedCheck, "rested", "notRested")
    setState(wt.frame.right.conditionsPanel.encounterCheck, "encounter", "notEncounter")
    setState(wt.frame.right.conditionsPanel.petBattleCheck, "petBattle", "notPetBattle")
    setState(wt.frame.right.conditionsPanel.vehicleCheck, "vehicle", "notVehicle")
    setState(wt.frame.right.conditionsPanel.instanceCheck, "instance", "notInstance")
    setState(wt.frame.right.conditionsPanel.housingCheck, "housing", "nothousing")
    preset.conditions.playerName = strtrim(wt.frame.right.conditionsPanel.playerNameEdit:GetText())
    preset.conditions.zone = strtrim(wt.frame.right.conditionsPanel.zoneEdit:GetText())

    -- Save advanced conditions
    preset.advancedEnabled = wt.frame.right.conditionsPanel.advancedCheck:GetChecked()
    preset.events = wt:ParseEvents(wt.frame.right.advancedPanel.eventsEdit:GetText())
    preset.trigger = wt.frame.right.advancedPanel.triggerEdit:GetText()
    preset.duration = tonumber(wt.frame.right.advancedPanel.durationEdit:GetText()) or 0

    local anchor = _G[anchorName]
    if not anchor then
        wt:Debug("Anchor not found:", anchorName)
        return
    end

    local width = tonumber(wt.frame.right.configPanelContent.widthEdit:GetText())
    local height = tonumber(wt.frame.right.configPanelContent.heightEdit:GetText())
    local x = tonumber(wt.frame.right.configPanelContent.xOffsetEdit:GetText())
    local y = tonumber(wt.frame.right.configPanelContent.yOffsetEdit:GetText())
    local frameLevel = tonumber(wt.frame.right.configPanelContent.frameLevelEdit:GetText()) or 100
    
    -- Only apply fallback if values are truly nil (not just 0 or negative)
    if width == nil or height == nil then
        if anchor.GetWidth and anchor.GetHeight then
            width = width or math.floor(anchor:GetWidth() < 500 and anchor:GetWidth() or 500)
            height = height or math.floor(anchor:GetHeight() < 500 and anchor:GetHeight() or 500)
        end
    end

    -- Final fallback only for nil values (allow 0 and negatives)
    if width == nil then width = 64 end
    if height == nil then height = 64 end
    if x == nil then x = 0 end
    if y == nil then y = 0 end

    preset.enabled = wt.frame.right.conditionsPanel.enabledCheck:GetChecked()
    
    -- Save scale
    local scale = tonumber(wt.frame.right.configPanelContent.scaleEdit:GetText()) or 1
    preset.scale = scale
    
    -- Save angle
    local angle = tonumber(wt.frame.right.configPanelContent.angleEdit:GetText()) or 0
    preset.angle = angle
    
    -- Save alpha
    local alpha = tonumber(wt.frame.right.configPanelContent.alphaEdit:GetText()) or 1
    preset.alpha = alpha
    
    -- Get group name from dropdown or editbox
    local groupName
    if wt.frame.right.configPanelContent.groupDropDown.selectedValue == "__CREATE_NEW__" then
        groupName = strtrim(wt.frame.right.configPanelContent.groupEditBox:GetText())
    elseif wt.frame.right.configPanelContent.groupDropDown.selectedValue == "" then
        groupName = ""
    else
        groupName = wt.frame.right.configPanelContent.groupDropDown.selectedValue
    end

    if preset.enabled then
        if groupName ~= "" then
            preset.group = groupName
            WeakTexturesDB.groups[groupName] = true
            local parent = groupName:match("(.+)/[^/]+$")
            while parent do
                WeakTexturesDB.groups[parent] = true
                parent = parent:match("(.+)/[^/]+$")
            end
        else
            preset.group = nil
        end
        preset.originalGroup = nil
    else
        preset.originalGroup = groupName
        preset.group = "Disabled"
        WeakTexturesDB.groups["Disabled"] = true
    end

    -- Store old type to detect type changes
    local oldPresetType = preset.type
    local presetType = (wt.frame.right.configPanelContent.ftypeDropDown.selectedValue == "Stop Motion") and "motion" or "static"
    preset.type = presetType
    if presetType == "motion" then
        preset.columns = tonumber(wt.frame.right.configPanelContent.columnsEdit:GetText()) or 1
        preset.rows = tonumber(wt.frame.right.configPanelContent.rowsEdit:GetText()) or 1
        preset.totalFrames = tonumber(wt.frame.right.configPanelContent.totalFramesEdit:GetText()) or 1
        preset.fps = tonumber(wt.frame.right.configPanelContent.fpsEdit:GetText()) or 30
    else
        -- Clear motion-specific properties when switching to static
        preset.columns = nil
        preset.rows = nil
        preset.totalFrames = nil
        preset.fps = nil
    end
    preset.frameLevel = frameLevel

    preset.textures = preset.textures or {}
    
    -- If temporary coordinates exist (from dragging), use them as the new permanent position
    if wt.tempCoordinates and wt.tempCoordinates[wt.selectedPreset] then
        x = wt.tempCoordinates[wt.selectedPreset].x
        y = wt.tempCoordinates[wt.selectedPreset].y
    end
    
    -- If temporary sizes exist (from resizing), use them as the new permanent size
    if wt.tempSizes and wt.tempSizes[wt.selectedPreset] then
        width = wt.tempSizes[wt.selectedPreset].width
        height = wt.tempSizes[wt.selectedPreset].height
    end
    
    preset.textures[1] = {
        anchor = anchorName,
        texture = texturePath,
        width = width,
        height = height,
        x = x,
        y = y
    }
    
    -- Text settings (stored separately in preset.text)
    preset.text = preset.text or {}
    local textContent = strtrim(wt.frame.right.configPanelContent.textContentEdit:GetText())
    
    -- Always enable text settings (even if content is empty, for dynamic text via timeline)
    preset.text.enabled = true
    preset.text.content = textContent
    preset.text.font = wt.frame.right.configPanelContent.fontDropDown.selectedValue or "Friz Quadrata TT"
    preset.text.size = tonumber(wt.frame.right.configPanelContent.fontSizeEdit:GetText()) or wt.TEXT_DEFAULT_SIZE or 48
    preset.text.outline = wt.frame.right.configPanelContent.fontOutlineDropDown.selectedValue or wt.TEXT_DEFAULT_OUTLINE or "OUTLINE"
    
    -- Get text color from color picker
    local tr, tg, tb, ta = wt.frame.right.configPanelContent.textColorPicker:GetColor()
    preset.text.color = {
        r = tr or 1,
        g = tg or 0.82,
        b = tb or 0,
        a = ta or 1
    }
    
    preset.text.offsetX = tonumber(wt.frame.right.configPanelContent.textOffsetXEdit:GetText()) or wt.TEXT_DEFAULT_OFFSET_X or 0
    preset.text.offsetY = tonumber(wt.frame.right.configPanelContent.textOffsetYEdit:GetText()) or wt.TEXT_DEFAULT_OFFSET_Y or 125
    
    -- Texture color (vertex color)
    local r, g, b, a = wt.frame.right.configPanelContent.textureColorPicker:GetColor()
    preset.color = {
        r = r or 1,
        g = g or 1,
        b = b or 1,
        a = a or 1
    }
    
    -- Sound settings
    preset.sound = preset.sound or {}
    
    -- Get sound path (either from dropdown selected path or custom edit)
    if wt.frame.right.configPanelContent.soundDropDown.selectedValue == "None" then
        -- No sound
        preset.sound.file = nil
    elseif wt.frame.right.configPanelContent.soundDropDown.selectedValue == "Custom" then
        local customSound = wt.frame.right.configPanelContent.soundCustomEdit:GetText()
        preset.sound.file = (customSound and customSound ~= "") and customSound or nil
    else
        -- LSM sound selected
        preset.sound.file = wt.frame.right.configPanelContent.soundDropDown.selectedPath or nil
    end
    
    -- Get sound channel
    preset.sound.channel = wt.frame.right.configPanelContent.soundChannelDropDown.selectedValue or "MASTER"
    
    -- Clear temporary coordinates after saving
    if wt.tempCoordinates then
        wt.tempCoordinates[wt.selectedPreset] = nil
    end
    
    -- Clear temporary sizes after saving
    if wt.tempSizes then
        wt.tempSizes[wt.selectedPreset] = nil
    end
    
    -- Clear temporary angles after saving
    if wt.tempAngles then
        wt.tempAngles[wt.selectedPreset] = nil
    end

    -- Update ADDON_EVENTS table for this preset
    wt:RemovePresetFromAddonEvents(wt.selectedPreset)
    if preset.enabled then
        wt:UpdateAddonEventsForPreset(wt.selectedPreset, preset)
    end

    -- Test trigger before registering events (after all data is saved)
    if preset.advancedEnabled and preset.trigger and preset.trigger ~= "" then
        local valid, func, result = wt:TestTrigger(preset.trigger, true, wt.selectedPreset)
        if not valid then
            wt:Debug(L.ERROR_TRIGGER_SYNTAX)
            preset.advancedEnabled = false
            wt.frame.right.conditionsPanel.advancedCheck:SetChecked(false)
            wt:DeRegisterPresetEvents(wt.selectedPreset)
            return
        end
    end
    
    -- Re-register events if advanced conditions changed AND preset is enabled
    if preset.advancedEnabled and preset.enabled then
        wt:RegisterPresetEvents(wt.selectedPreset)
    else
        wt:DeRegisterPresetEvents(wt.selectedPreset)
    end

    -- Apply multi-instance mode changes
    local multiInstanceEnabled = wt.frame.right.advancedPanel.multiInstanceCheck:GetChecked()
    if multiInstanceEnabled then
        WeakTexturesAPI:EnableMultiInstance(wt.selectedPreset)
    else
        WeakTexturesAPI:DisableMultiInstance(wt.selectedPreset)
    end

    -- If advanced conditions are enabled, wait for event to fire
    -- Don't show preset immediately - let the event system handle it
    if preset.advancedEnabled then
        wt:HideTextureFrame(wt.selectedPreset)
    -- Otherwise check regular conditions and show if met
    elseif wt:PresetMatchesConditions(wt.selectedPreset) then
        -- If type changed from motion to static, hide first to stop animation
        if oldPresetType == "motion" and presetType == "static" then
            wt:HideTextureFrame(wt.selectedPreset)
        end
        
        if preset.type and preset.type == "motion" then
            wt:PlayStopMotion(wt.selectedPreset, preset.textures[1].anchor, preset.textures[1].texture, 
                preset.textures[1].width, preset.textures[1].height, preset.textures[1].x, preset.textures[1].y, 
                preset.columns or 1, preset.rows or 1, preset.totalFrames or 1, preset.fps or 30)
        else
            wt:CreateAnchoredTexture(wt.selectedPreset, anchorName, texturePath, width, height, x, y)
        end
    else
        wt:HideTextureFrame(wt.selectedPreset)
    end

    wt:RefreshPresetList()
    
    -- Save to active profile
    if wt.SaveCurrentProfile then
        wt:SaveCurrentProfile()
    end
    
    wt.frame.right.editPresetButton.text:SetText(L.STATUS_SAVED)
    wt:LoadPresetIntoFields(wt.selectedPreset)
    C_Timer.After(1.0, function()
        if wt.frame.right.editPresetButton then
            wt.frame.right.editPresetButton.text:SetText(L.BUTTON_SAVE_CHANGES)
        end
    end)
end

---Start dragging the main frame
function wt:OnFrameDragStart()
    wt.frame:StartMoving()
end

---Stop dragging the main frame
function wt:OnFrameDragStop()
    wt.frame:StopMovingOrSizing()
end

---Toggle lock/unlock state for texture dragging
function wt:OnLockOrUnlockTextureToDrag()
    if not wt.selectedPreset then return end
    
    local container = wt.activeFramesByPreset[wt.selectedPreset]
    local btn = wt.frame.right.unlockFrameBtn
    
    -- If no frame exists, create it first
    if not container or not container.frame then
        local preset = WeakTexturesDB.presets[wt.selectedPreset]
        if not preset or not preset.textures or not preset.textures[1] then return end
        
        local data = preset.textures[1]
        if preset.type == "motion" then
            wt:PlayStopMotion(wt.selectedPreset, data.anchor, data.texture, data.width, data.height, data.x, data.y, 
                preset.columns or 1, preset.rows or 1, preset.totalFrames or 1, preset.fps or 30)
        else
            wt:CreateAnchoredTexture(wt.selectedPreset, data.anchor, data.texture, data.width, data.height, data.x, data.y)
        end
        
        container = wt.activeFramesByPreset[wt.selectedPreset]
        if not container or not container.frame then return end
    end
    
    local f = container.frame
    
    -- Apply current scale from editbox (even if not saved yet)
    local currentScale = tonumber(wt.frame.right.configPanelContent.scaleEdit:GetText()) or 1
    f:SetScale(currentScale)
    
    -- Apply current text settings from UI (even if not saved yet)
    if f.fontString or (wt.frame.right.configPanelContent.textContentEdit:GetText() ~= "") then
        -- Create fontString if it doesn't exist yet
        if not f.fontString then
            f.fontString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        end
        
        -- Apply text color from color picker
        local tr, tg, tb, ta = wt.frame.right.configPanelContent.textColorPicker:GetColor()
        f.fontString:SetTextColor(tr, tg, tb, ta)
        
        -- Apply font settings
        local fontName = wt.frame.right.configPanelContent.fontDropDown.selectedValue or "Friz Quadrata TT"
        local fontSize = tonumber(wt.frame.right.configPanelContent.fontSizeEdit:GetText()) or 48
        local fontOutline = wt.frame.right.configPanelContent.fontOutlineDropDown.selectedValue or "OUTLINE"
        
        -- Fetch font path from LSM
        local fontPath = wt.LSM:Fetch("font", fontName) or "Fonts\\FRIZQT__.TTF"
        f.fontString:SetFont(fontPath, fontSize, fontOutline)
        
        -- Apply text offset
        local textOffsetX = tonumber(wt.frame.right.configPanelContent.textOffsetXEdit:GetText()) or 0
        local textOffsetY = tonumber(wt.frame.right.configPanelContent.textOffsetYEdit:GetText()) or 125
        f.fontString:ClearAllPoints()
        f.fontString:SetPoint("CENTER", f, "CENTER", textOffsetX, textOffsetY)
        
        -- Apply text content
        local textContent = wt.frame.right.configPanelContent.textContentEdit:GetText()
        f.fontString:SetText(textContent or "")
        f.fontString:Show()
    end
    
    -- Apply current texture color (vertex color) from UI
    if f.texture then
        local r, g, b, a = wt.frame.right.configPanelContent.textureColorPicker:GetColor()
        f.texture:SetVertexColor(r, g, b, a)
    end
    
    -- Check current state
    if container.isLocked == false then
        -- Lock the frame
        container.isLocked = true
        btn.text:SetText(L.BUTTON_UNLOCK_POSITION)
        
        -- Disable dragging
        f:EnableMouse(false)
        f:SetMovable(false)
        f:RegisterForDrag()
        
        -- Hide border
        if f.border then
            f.border:Hide()
        end
        
        if f.rotatingBorder then
            f.rotatingBorder:Hide()
        end
        
        -- Hide adjustment buttons
        if f.btnUp then f.btnUp:Hide() end
        if f.btnDown then f.btnDown:Hide() end
        if f.btnLeft then f.btnLeft:Hide() end
        if f.btnRight then f.btnRight:Hide() end
        
        -- Hide overlay with both grips
        if f.overlay then
            if f.overlay.resizeGrip then f.overlay.resizeGrip:Hide() end
            if f.overlay.rotationGrip then f.overlay.rotationGrip:Hide() end
            f.overlay:Hide()
        end
        
        -- Hide size display
        if f.sizeDisplay then f.sizeDisplay:Hide() end
        
        -- Restore original visibility state
        if container.wasHiddenBeforeUnlock then
            f:Hide()
            container.wasHiddenBeforeUnlock = nil
        end
    else
        -- Unlock the frame
        container.isLocked = false
        btn.text:SetText(L.BUTTON_LOCK_POSITION)
        
        -- Track if frame was hidden before unlocking
        container.wasHiddenBeforeUnlock = not f:IsShown()
        
        -- Show the frame if it was hidden
        if container.wasHiddenBeforeUnlock then
            f:Show()
        end
        
        -- Enable dragging
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        
        -- Create invisible border for UI elements (buttons, display text)
        if not f.border then
            f.border = CreateFrame("Frame", nil, f, "BackdropTemplate")
            f.border:SetAllPoints(f)
            f.border:SetBackdrop({
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            f.border:SetBackdropBorderColor(1, 0.82, 0, 0)  -- Invisible
            f.border:SetFrameStrata(f:GetFrameStrata())
            f.border:SetFrameLevel(f:GetFrameLevel() + 1)
        end
        f.border:Show()
        
        -- Create overlay frame that rotates with texture
        if not f.overlay then
            f.overlay = CreateFrame("Frame", nil, f)
            f.overlay:SetAllPoints(f)
            f.overlay:SetFrameStrata(f:GetFrameStrata())
            f.overlay:SetFrameLevel(f:GetFrameLevel() + 2)
            
            -- Create visible rotating border texture
            f.overlay.borderTexture = f.overlay:CreateTexture(nil, "OVERLAY")
            f.overlay.borderTexture:SetAllPoints(f.overlay)
            f.overlay.borderTexture:SetColorTexture(1, 0.82, 0, 0.3)
        end
        
        -- Get current angle
        local preset = WeakTexturesDB.presets[wt.selectedPreset]
        local currentAngle = 0
        if preset then
            currentAngle = preset.angle or 0
            if wt.tempAngles and wt.tempAngles[wt.selectedPreset] then
                currentAngle = wt.tempAngles[wt.selectedPreset]
            end
        end
        
        -- Apply rotation to overlay
        local angleRad = math.rad(currentAngle)
        f.overlay.borderTexture:SetRotation(angleRad)
        f.overlay:Show()
        
        -- Helper function to adjust offset
        local function adjustOffset(xDelta, yDelta)
            local preset = WeakTexturesDB.presets[wt.selectedPreset]
            if not preset or not preset.textures or not preset.textures[1] then return end
            
            local anchorName = preset.textures[1].anchor
            local anchor = _G[anchorName]
            if not anchor then return end
            
            -- Initialize temp coordinates if not exist
            wt.tempCoordinates = wt.tempCoordinates or {}
            if not wt.tempCoordinates[wt.selectedPreset] then
                wt.tempCoordinates[wt.selectedPreset] = {
                    x = preset.textures[1].x or 0,
                    y = preset.textures[1].y or 0
                }
            end
            
            -- Adjust coordinates
            wt.tempCoordinates[wt.selectedPreset].x = wt.tempCoordinates[wt.selectedPreset].x + xDelta
            wt.tempCoordinates[wt.selectedPreset].y = wt.tempCoordinates[wt.selectedPreset].y + yDelta
            
            -- Update UI fields
            wt.frame.right.configPanelContent.xOffsetEdit:SetText(tostring(wt.tempCoordinates[wt.selectedPreset].x))
            wt.frame.right.configPanelContent.yOffsetEdit:SetText(tostring(wt.tempCoordinates[wt.selectedPreset].y))
            
            -- Reposition frame
            f:ClearAllPoints()
            f:SetPoint("CENTER", anchor, "CENTER", wt.tempCoordinates[wt.selectedPreset].x, wt.tempCoordinates[wt.selectedPreset].y)
        end
        
        -- Create Y offset buttons (right side)
        if not f.btnUp then
            f.btnUp = CreateFrame("Button", nil, f)
            f.btnUp:SetSize(24, 24)
            f.btnUp:SetPoint("LEFT", f, "RIGHT", -5, 10)
            f.btnUp:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
            f.btnUp:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
            f.btnUp:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
            f.btnUp:SetScript("OnClick", function() adjustOffset(0, 1) end)
        end
        f.btnUp:Show()
        
        if not f.btnDown then
            f.btnDown = CreateFrame("Button", nil, f)
            f.btnDown:SetSize(24, 24)
            f.btnDown:SetPoint("LEFT", f, "RIGHT", -5, -10)
            f.btnDown:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
            f.btnDown:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
            f.btnDown:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
            f.btnDown:SetScript("OnClick", function() adjustOffset(0, -1) end)
        end
        f.btnDown:Show()
        
        -- Create X offset buttons (bottom side)
        if not f.btnLeft then
            f.btnLeft = CreateFrame("Button", nil, f)
            f.btnLeft:SetSize(24, 24)
            f.btnLeft:SetPoint("TOP", f, "BOTTOM", -10, 5)
            local leftTex = f.btnLeft:CreateTexture(nil, "ARTWORK")
            leftTex:SetAllPoints()
            leftTex:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
            leftTex:SetRotation(math.rad(90))
            f.btnLeft:SetNormalTexture(leftTex)
            f.btnLeft:SetScript("OnClick", function() adjustOffset(-1, 0) end)
        end
        f.btnLeft:Show()
        
        if not f.btnRight then
            f.btnRight = CreateFrame("Button", nil, f)
            f.btnRight:SetSize(24, 24)
            f.btnRight:SetPoint("TOP", f, "BOTTOM", 10, 5)
            local rightTex = f.btnRight:CreateTexture(nil, "ARTWORK")
            rightTex:SetAllPoints()
            rightTex:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
            rightTex:SetRotation(math.rad(-90))
            f.btnRight:SetNormalTexture(rightTex)
            f.btnRight:SetScript("OnClick", function() adjustOffset(1, 0) end)
        end
        f.btnRight:Show()
        
        -- Create size display (shows W x H + X, Y)
        if not f.sizeDisplay then
            f.sizeDisplay = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            f.sizeDisplay:SetPoint("TOP", f, "TOP", 0, 15)
            f.sizeDisplay:SetTextColor(1, 0.82, 0)
        end
        local w, h = f:GetSize()
        local preset = WeakTexturesDB.presets[wt.selectedPreset]
        local currentX, currentY = 0, 0
        if preset and preset.textures and preset.textures[1] then
            if wt.tempCoordinates and wt.tempCoordinates[wt.selectedPreset] then
                currentX = wt.tempCoordinates[wt.selectedPreset].x
                currentY = wt.tempCoordinates[wt.selectedPreset].y
            else
                currentX = preset.textures[1].x or 0
                currentY = preset.textures[1].y or 0
            end
        end
        f.sizeDisplay:SetText(string.format("%d x %d | X: %d, Y: %d", math.floor(w + 0.5), math.floor(h + 0.5), math.floor(currentX + 0.5), math.floor(currentY + 0.5)))
        f.sizeDisplay:Show()
        
        -- Create resize grip on overlay (bottom right corner)
        if not f.overlay.resizeGrip then
            f.overlay.resizeGrip = CreateFrame("Button", nil, f.overlay)
            f.overlay.resizeGrip:SetSize(16, 16)
            f.overlay.resizeGrip:SetPoint("BOTTOMRIGHT", f.overlay, "BOTTOMRIGHT", 0, 0)
            
            -- Visual indicator
            local tex = f.overlay.resizeGrip:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints()
            tex:SetColorTexture(1, 1, 0, 0.8)
            
            f.overlay.resizeGrip:EnableMouse(true)
            f.overlay.resizeGrip:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" then
                    f.isResizing = true
                    f.resizeStartX, f.resizeStartY = GetCursorPosition()
                    f.resizeStartW, f.resizeStartH = f:GetSize()
                    
                    -- Check if texture is currently flipped
                    local preset = WeakTexturesDB.presets[wt.selectedPreset]
                    if preset and preset.textures and preset.textures[1] then
                        local storedW = preset.textures[1].width or f.resizeStartW
                        local storedH = preset.textures[1].height or f.resizeStartH
                        
                        -- Check temp sizes first
                        if wt.tempSizes and wt.tempSizes[wt.selectedPreset] then
                            storedW = wt.tempSizes[wt.selectedPreset].width
                            storedH = wt.tempSizes[wt.selectedPreset].height
                        end
                        
                        -- Restore sign
                        f.resizeStartW = storedW
                        f.resizeStartH = storedH
                    end
                    
                    local scale = UIParent:GetEffectiveScale()
                    f.resizeStartX = f.resizeStartX / scale
                    f.resizeStartY = f.resizeStartY / scale
                end
            end)
            
            f.overlay.resizeGrip:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" and f.isResizing then
                    f.isResizing = false
                    
                    -- Calculate final size with sign
                    local cursorX, cursorY = GetCursorPosition()
                    local scale = UIParent:GetEffectiveScale()
                    cursorX = cursorX / scale
                    cursorY = cursorY / scale
                    
                    local deltaX = cursorX - f.resizeStartX
                    local deltaY = cursorY - f.resizeStartY
                    
                    local newW = f.resizeStartW + deltaX
                    local newH = f.resizeStartH - deltaY
                    
                    -- Round to integers
                    newW = math.floor(newW + (newW >= 0 and 0.5 or -0.5))
                    newH = math.floor(newH + (newH >= 0 and 0.5 or -0.5))
                    
                    wt.frame.right.configPanelContent.widthEdit:SetText(tostring(newW))
                    wt.frame.right.configPanelContent.heightEdit:SetText(tostring(newH))
                    
                    -- Store in temp size table with sign
                    wt.tempSizes = wt.tempSizes or {}
                    wt.tempSizes[wt.selectedPreset] = { width = newW, height = newH }
                end
            end)
            
            f.overlay.resizeGrip:SetScript("OnUpdate", function(self)
                if f.isResizing then
                    local cursorX, cursorY = GetCursorPosition()
                    local scale = UIParent:GetEffectiveScale()
                    cursorX = cursorX / scale
                    cursorY = cursorY / scale
                    
                    local deltaX = cursorX - f.resizeStartX
                    local deltaY = cursorY - f.resizeStartY
                    
                    -- Allow negative values for mirroring effect
                    local newW = f.resizeStartW + deltaX
                    local newH = f.resizeStartH - deltaY
                    
                    -- Set size with absolute values
                    f:SetSize(math.abs(newW), math.abs(newH))
                    
                    -- Apply texture mirroring based on sign
                    if f.texture then
                        local left, right = 0, 1
                        local top, bottom = 0, 1
                        
                        -- Horizontal flip if width is negative
                        if newW < 0 then
                            left, right = 1, 0
                        end
                        
                        -- Vertical flip if height is negative
                        if newH < 0 then
                            top, bottom = 1, 0
                        end
                        
                        f.texture:SetTexCoord(left, right, top, bottom)
                    end
                    
                    -- Update size display (show signed values)
                    if f.sizeDisplay then
                        local preset = WeakTexturesDB.presets[wt.selectedPreset]
                        local currentX, currentY = 0, 0
                        if preset and preset.textures and preset.textures[1] then
                            if wt.tempCoordinates and wt.tempCoordinates[wt.selectedPreset] then
                                currentX = wt.tempCoordinates[wt.selectedPreset].x
                                currentY = wt.tempCoordinates[wt.selectedPreset].y
                            else
                                currentX = preset.textures[1].x or 0
                                currentY = preset.textures[1].y or 0
                            end
                        end
                        -- Round with proper sign handling
                        local displayW = math.floor(newW + (newW >= 0 and 0.5 or -0.5))
                        local displayH = math.floor(newH + (newH >= 0 and 0.5 or -0.5))
                        f.sizeDisplay:SetText(string.format("%d x %d | X: %d, Y: %d", displayW, displayH, math.floor(currentX + 0.5), math.floor(currentY + 0.5)))
                    end
                end
            end)
        end
        f.overlay.resizeGrip:Show()
        
        -- Create rotation grip on overlay (top right corner)
        if not f.overlay.rotationGrip then
            f.overlay.rotationGrip = CreateFrame("Button", nil, f.overlay)
            f.overlay.rotationGrip:SetSize(16, 16)
            
            -- Visual indicator (different color from resize)
            f.overlay.rotationGrip.texture = f.overlay.rotationGrip:CreateTexture(nil, "OVERLAY")
            f.overlay.rotationGrip.texture:SetAllPoints()
            f.overlay.rotationGrip.texture:SetColorTexture(0, 0.8, 1, 0.8)  -- Cyan color
            
            f.overlay.rotationGrip:EnableMouse(true)
            f.overlay.rotationGrip:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" then
                    f.isRotating = true
                    
                    -- Get current texture angle
                    local preset = WeakTexturesDB.presets[wt.selectedPreset]
                    local currentTextureAngle = 0
                    if preset then
                        currentTextureAngle = preset.angle or 0
                        if wt.tempAngles and wt.tempAngles[wt.selectedPreset] then
                            currentTextureAngle = wt.tempAngles[wt.selectedPreset]
                        end
                    end
                    
                    -- Get initial mouse angle relative to frame center
                    local centerX, centerY = f:GetCenter()
                    local cursorX, cursorY = GetCursorPosition()
                    local scale = UIParent:GetEffectiveScale()
                    cursorX = cursorX / scale
                    cursorY = cursorY / scale
                    
                    local mouseAngle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX))
                    
                    -- Store the offset between texture angle and mouse angle
                    f.rotateAngleOffset = currentTextureAngle - mouseAngle
                end
            end)
            
            f.overlay.rotationGrip:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" and f.isRotating then
                    f.isRotating = false
                    
                    -- Calculate final angle from mouse position
                    local centerX, centerY = f:GetCenter()
                    local cursorX, cursorY = GetCursorPosition()
                    local scale = UIParent:GetEffectiveScale()
                    cursorX = cursorX / scale
                    cursorY = cursorY / scale
                    
                    local mouseAngle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX))
                    local newAngle = mouseAngle + f.rotateAngleOffset
                    
                    -- Normalize to 0-360
                    while newAngle < 0 do newAngle = newAngle + 360 end
                    while newAngle >= 360 do newAngle = newAngle - 360 end
                    
                    -- Round to integer
                    newAngle = math.floor(newAngle + 0.5)
                    
                    wt.frame.right.configPanelContent.angleEdit:SetText(tostring(newAngle))
                    
                    -- Store in temp angle table
                    wt.tempAngles = wt.tempAngles or {}
                    wt.tempAngles[wt.selectedPreset] = newAngle
                end
            end)
            
            f.overlay.rotationGrip:SetScript("OnUpdate", function(self)
                if f.isRotating then
                    -- Get current mouse position
                    local centerX, centerY = f:GetCenter()
                    local cursorX, cursorY = GetCursorPosition()
                    local scale = UIParent:GetEffectiveScale()
                    cursorX = cursorX / scale
                    cursorY = cursorY / scale
                    
                    -- Calculate texture angle = mouse angle + offset
                    local mouseAngle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX))
                    local newAngle = mouseAngle + f.rotateAngleOffset
                    
                    -- Don't normalize yet for smooth continuous rotation
                    local displayAngle = newAngle
                    while displayAngle < 0 do displayAngle = displayAngle + 360 end
                    while displayAngle >= 360 do displayAngle = displayAngle - 360 end
                    
                    -- Apply rotation to texture (use non-normalized angle for smooth rotation)
                    local angleRadians = math.rad(newAngle)
                    f.texture:SetRotation(angleRadians)
                    
                    -- Rotate overlay border and grips
                    if f.overlay then
                        f.overlay.borderTexture:SetRotation(angleRadians)
                        if f.overlay.rotationGrip and f.overlay.rotationGrip.texture then
                            f.overlay.rotationGrip.texture:SetRotation(angleRadians)
                        end
                    end
                    
                    -- Update size display with angle
                    if f.sizeDisplay then
                        local preset = WeakTexturesDB.presets[wt.selectedPreset]
                        local currentX, currentY = 0, 0
                        local w, h = f:GetSize()
                        if preset and preset.textures and preset.textures[1] then
                            if wt.tempCoordinates and wt.tempCoordinates[wt.selectedPreset] then
                                currentX = wt.tempCoordinates[wt.selectedPreset].x
                                currentY = wt.tempCoordinates[wt.selectedPreset].y
                            else
                                currentX = preset.textures[1].x or 0
                                currentY = preset.textures[1].y or 0
                            end
                        end
                        f.sizeDisplay:SetText(string.format("%d x %d | X: %d, Y: %d | %d�", math.floor(w + 0.5), math.floor(h + 0.5), math.floor(currentX + 0.5), math.floor(currentY + 0.5), math.floor(displayAngle + 0.5)))
                    end
                end
            end)
        end
        
        -- Position rotation grip at top-right and sync overlay rotation
        f.overlay.rotationGrip:ClearAllPoints()
        f.overlay.rotationGrip:SetPoint("TOPRIGHT", f.overlay, "TOPRIGHT", 0, 0)
        f.overlay.rotationGrip.texture:SetRotation(angleRad)
        f.overlay.rotationGrip:Show()
        
        -- Setup drag scripts
        f:SetScript("OnDragStart", function(self)
            -- Store start position for custom dragging
            local preset = WeakTexturesDB.presets[wt.selectedPreset]
            if not preset or not preset.textures or not preset.textures[1] then return end
            
            local anchorName = preset.textures[1].anchor
            local anchor = _G[anchorName]
            if not anchor then return end
            
            -- Get cursor position
            local cursorX, cursorY = GetCursorPosition()
            local uiScale = UIParent:GetEffectiveScale()
            cursorX = cursorX / uiScale
            cursorY = cursorY / uiScale
            
            -- Get current offset from temp or preset
            local currentX, currentY
            if wt.tempCoordinates and wt.tempCoordinates[wt.selectedPreset] then
                currentX = wt.tempCoordinates[wt.selectedPreset].x
                currentY = wt.tempCoordinates[wt.selectedPreset].y
            else
                currentX = preset.textures[1].x or 0
                currentY = preset.textures[1].y or 0
            end
            
            -- Store drag state
            self.dragStartCursorX = cursorX
            self.dragStartCursorY = cursorY
            self.dragStartOffsetX = currentX
            self.dragStartOffsetY = currentY
            self.isDragging = true
        end)
        
        f:SetScript("OnDragStop", function(self)
            self.isDragging = false
            
            -- Calculate new offset from anchor
            local preset = WeakTexturesDB.presets[wt.selectedPreset]
            if not preset or not preset.textures or not preset.textures[1] then return end
            
            local anchorName = preset.textures[1].anchor
            local anchor = _G[anchorName]
            if not anchor then return end
            
            -- Get cursor position
            local cursorX, cursorY = GetCursorPosition()
            local uiScale = UIParent:GetEffectiveScale()
            cursorX = cursorX / uiScale
            cursorY = cursorY / uiScale
            
            -- Calculate cursor movement delta
            local deltaX = cursorX - self.dragStartCursorX
            local deltaY = cursorY - self.dragStartCursorY
            
            -- Account for frame EFFECTIVE scale - must match OnUpdate calculation
            local frameEffectiveScale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
            deltaX = deltaX / frameEffectiveScale
            deltaY = deltaY / frameEffectiveScale
            
            -- Calculate new offset
            local newOffsetX = self.dragStartOffsetX + deltaX
            local newOffsetY = self.dragStartOffsetY + deltaY
            
            -- Store temporary coordinates in runtime table (not saved to disk)
            wt.tempCoordinates = wt.tempCoordinates or {}
            wt.tempCoordinates[wt.selectedPreset] = {
                x = math.floor(newOffsetX + 0.5),
                y = math.floor(newOffsetY + 0.5)
            }
            
            -- Update UI fields with temporary values
            wt.frame.right.configPanelContent.xOffsetEdit:SetText(tostring(wt.tempCoordinates[wt.selectedPreset].x))
            wt.frame.right.configPanelContent.yOffsetEdit:SetText(tostring(wt.tempCoordinates[wt.selectedPreset].y))
            
            -- Reposition to exact offset using temporary coordinates (snap to pixel)
            self:ClearAllPoints()
            self:SetPoint("CENTER", anchor, "CENTER", wt.tempCoordinates[wt.selectedPreset].x, wt.tempCoordinates[wt.selectedPreset].y)
        end)
        
        -- OnUpdate for custom dragging
        f:SetScript("OnUpdate", function(self)
            if self.isDragging then
                local preset = WeakTexturesDB.presets[wt.selectedPreset]
                if not preset or not preset.textures or not preset.textures[1] then return end
                
                local anchorName = preset.textures[1].anchor
                local anchor = _G[anchorName]
                if not anchor then return end
                
                -- Get current cursor position
                local cursorX, cursorY = GetCursorPosition()
                local uiScale = UIParent:GetEffectiveScale()
                cursorX = cursorX / uiScale
                cursorY = cursorY / uiScale
                
                -- Calculate cursor movement delta
                local deltaX = cursorX - self.dragStartCursorX
                local deltaY = cursorY - self.dragStartCursorY
                
                -- For frame EFFECTIVE scale - frame inherits scale from anchor
                local frameEffectiveScale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
                deltaX = deltaX / frameEffectiveScale
                deltaY = deltaY / frameEffectiveScale
                
                -- Calculate new offset (add delta to start offset)
                local newOffsetX = self.dragStartOffsetX + deltaX
                local newOffsetY = self.dragStartOffsetY + deltaY
                
                -- Update size display with current position
                if self.sizeDisplay then
                    local w, h = self:GetSize()
                    self.sizeDisplay:SetText(string.format("%d x %d | X: %d, Y: %d", math.floor(w + 0.5), math.floor(h + 0.5), math.floor(newOffsetX + 0.5), math.floor(newOffsetY + 0.5)))
                end
                
                -- Apply new position
                self:ClearAllPoints()
                self:SetPoint("CENTER", anchor, "CENTER", newOffsetX, newOffsetY)
            end
        end)
    end
end

---Handle right panel show event
function wt:OnRightPanelShow()
    PanelTemplates_SetTab(wt.frame.right, wt.frame.right.selectTab or 1)
end

---Handle right tab button click
---@param btn any
function wt:OnRightTabClick(btn)
    PanelTemplates_SetTab(wt.frame.right, btn:GetID())
    wt:ShowRightTab(btn.tabKey)
end

---Handle offset edit box text change to only allow numbers
---@param editBox any
function wt:OnOffsetEditTextChanged(editBox)
    local text = editBox:GetText()
    if text ~= "" and not tonumber(text) then
        editBox:SetText(text:gsub("[^%-%d]", ""))
        editBox:SetCursorPosition(#editBox:GetText())
    end
end

---Handle import button click
function wt:OnImportButtonClick()
    wt:allDefault()
    wt.frame.right:EnableMouse(true)
    wt.frame.right:Show()
    wt:ShowRightTab("import")
end

---Handle escape key press in import edit box
---@param editBox any
function wt:OnImportEditBoxEscape(editBox)
    editBox:ClearFocus()
end

---Handle import accept button click
function wt:OnImportAcceptClick()
    wt:ImportFromString(wt.frame.right.importPanel.editBox:GetText())
    wt.frame.right.importPanel.editBox:SetText("")
    wt:RefreshPresetList()
end

---Add a group node to the tree data provider
---@param node TreeNode
---@param name string
---@param depth number
---@param parentNode any
---@param fullPath string|nil
function wt:AddGroupNodeToProvider(node, name, depth, parentNode, fullPath)
    fullPath = fullPath or name
    local expanded = wt.groupState[fullPath] ~= false
    
    -- Get search query
    local query = wt.frame.left.searchBox and wt.frame.left.searchBox:GetText() or ""
    
    -- Filter presets based on search and active filters
    local filteredPresets = {}
    for _, presetName in ipairs(node.presets) do
        local matchesSearch = (not query or query == "") or wt:MatchesSearchQuery(presetName, query)
        local matchesFilters = wt:PresetMatchesFilters(presetName)
        
        if matchesSearch and matchesFilters then
            table.insert(filteredPresets, presetName)
        end
    end
    
    ---Count all presets in a node including subgroups
    ---@param n TreeNode
    ---@param q string
    ---@return number
    local function countAllPresets(n, q)
        local total = 0
        -- Count presets in current node
        for _, presetName in ipairs(n.presets) do
            local matchesSearch = (not q or q == "") or wt:MatchesSearchQuery(presetName, q)
            local matchesFilters = wt:PresetMatchesFilters(presetName)
            
            if matchesSearch and matchesFilters then
                total = total + 1
            end
        end
        -- Recursively count presets in child groups
        for _, childNode in pairs(n.children) do
            total = total + countAllPresets(childNode, q)
        end
        return total
    end
    
    local count = countAllPresets(node, query)
    
    -- Check if any child groups have matching presets
    local hasMatchingChildren = false
    for childName, childNode in pairs(node.children) do
        if wt:GroupHasMatchingPresets(childNode, query) then
            hasMatchingChildren = true
            break
        end
    end
    
    -- Skip group if no matching presets and no matching children
    if count == 0 and not hasMatchingChildren then
        return
    end
    
    -- Add group node
    local groupData = {
        type = "group",
        name = name,
        fullPath = fullPath,
        depth = depth,
        expanded = expanded,
        count = count,
        node = node
    }
    
    local groupNode = parentNode and parentNode:Insert(groupData) or wt.frame.left.dataProvider:Insert(groupData)
    
    if expanded then
        -- Add child groups
        local childNames = {}
        for childName in pairs(node.children) do
            table.insert(childNames, childName)
        end
        table.sort(childNames)
        
        for _, childName in ipairs(childNames) do
            wt:AddGroupNodeToProvider(
                node.children[childName],
                childName,
                depth + 1,
                groupNode,
                fullPath .. "/" .. childName
            )
        end
        
        -- Add filtered presets
        table.sort(filteredPresets)
        for _, presetName in ipairs(filteredPresets) do
            local icon = wt:GetConditionIconForPreset(presetName)
            local presetData = {
                type = "preset",
                name = presetName,
                depth = depth,
                icon = icon,
                selected = (wt.selectedPreset == presetName)
            }
            groupNode:Insert(presetData)
        end
    end
end

---Check if a group node has matching presets (recursively)
---@param node TreeNode
---@param query string
---@return boolean
function wt:GroupHasMatchingPresets(node, query)
    -- Check if this group or any child group has matching presets
    for _, presetName in ipairs(node.presets) do
        local matchesSearch = (not query or query == "") or wt:MatchesSearchQuery(presetName, query)
        local matchesFilters = wt:PresetMatchesFilters(presetName)
        
        if matchesSearch and matchesFilters then
            return true
        end
    end
    
    for _, childNode in pairs(node.children) do
        if wt:GroupHasMatchingPresets(childNode, query) then
            return true
        end
    end
    
    return false
end

---Initialize a tree element (group or preset button)
---@param button TreeButton
---@param node any
function wt:InitializeTreeElement(button, node)
    local data = node:GetData()
    local indent = data.depth * 12
    
    button:SetSize(220 - indent, 22)
    
    if data.type == "group" then
        -- Group button
        button:SetNormalAtlas("Ui-Dialog-New-Button-Default")
        button:SetHighlightAtlas("Ui-Dialog-New-Button-Hover")
        button:SetPushedAtlas("Ui-Dialog-New-Button-Down")
        
        if not button.text then
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetJustifyH("LEFT")
            button.text:SetJustifyV("MIDDLE")
            wt:ApplyCustomFont(button.text, 12)
        end
        
        if not button.expandIcon then
            button.expandIcon = button:CreateTexture(nil, "OVERLAY")
            button.expandIcon:SetSize(16, 16)
        end
        
        if not button.count then
            button.count = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.count:SetJustifyH("RIGHT")
            button.count:SetJustifyV("MIDDLE")
            button.count:SetWidth(40)
            wt:ApplyCustomFont(button.count, 12)
        end
        
        -- Set expand/collapse icon
        if data.expanded then
            button.expandIcon:SetAtlas("Options_ListExpand_Right_Expanded")
        else
            button.expandIcon:SetAtlas("Options_ListExpand_Right")
        end
        button.expandIcon:ClearAllPoints()
        button.expandIcon:SetPoint("LEFT", button, "LEFT", 5, 0)
        button.expandIcon:Show()
        
        button.text:SetText(wt:GetLocalizedGroupName(data.name))
        button.text:ClearAllPoints()
        button.text:SetPoint("LEFT", button.expandIcon, "RIGHT", 5, 0)
        button.text:SetPoint("RIGHT", button.count, "LEFT", -5, 0)
        
        button.count:SetText("(" .. data.count .. ")")
        button.count:ClearAllPoints()
        button.count:SetPoint("RIGHT", button, "RIGHT", -5, 0)
        button.count:Show()
        
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        
        button:SetScript("OnMouseDown", function(self, mouseButton)
            if mouseButton == "LeftButton" then
                self.clickStartTime = GetTime()
            end
        end)
        
        button:SetScript("OnMouseUp", function(self, mouseButton)
            if mouseButton == "LeftButton" then
                -- Check if a preset is being dragged
                if wt.draggedPreset then
                    wt:DropPresetOnGroup(data.fullPath)
                    return
                end
                
                -- Normal click - check if it was a quick click (not a drag)
                local clickTime = self.clickStartTime or 0
                if GetTime() - clickTime < 0.3 then
                    wt.groupState[data.fullPath] = not data.expanded
                    wt:RefreshPresetList()
                end
            end
        end)
        
        button:SetScript("OnClick", function(self, mouseButton)
            if mouseButton == "RightButton" then
                wt:ShowContextMenu(self, data.name, data.fullPath)
            end
        end)
        
        -- Enable drop for groups
        button:SetScript("OnEnter", function(self)
            if wt.draggedPreset then
                -- Show red highlight for Disabled group
                local isInvalid = (data.fullPath == "Disabled")
                wt:HighlightDropTarget(self, data.fullPath, isInvalid)
            end
        end)
        button:SetScript("OnLeave", function(self)
            if wt.draggedPreset then
                wt:UnhighlightDropTarget(self)
            end
        end)
        
        -- Hide eye button if exists (only used for presets)
        if button.eye then
            button.eye:Hide()
        end
        
        -- Hide enable button if exists (only used for presets)
        if button.enableButton then
            button.enableButton:Hide()
        end
        
        -- Hide selected highlight if exists (only used for presets)
        if button.selectedHighlight then
            button.selectedHighlight:Hide()
        end
        
        -- Hide drop highlight if exists (clear from previous use)
        if button.dropHighlight then
            button.dropHighlight:Hide()
        end
        
        -- Disable drag for group buttons (in case button was recycled from preset)
        button:SetMovable(false)
        button:RegisterForDrag()
        button:SetScript("OnDragStart", nil)
        button:SetScript("OnDragStop", nil)
        
        -- Hide drop highlight if exists (clear from previous use)
        if button.dropHighlight then
            button.dropHighlight:Hide()
        end
        
    elseif data.type == "preset" then
        -- Preset button
        if data.selected then
            button:SetNormalAtlas("UI-QuestTracker-Primary-Objective-Header")
        else
            button:SetNormalAtlas("UI-QuestTracker-Secondary-Objective-Header")
        end
        button:SetHighlightAtlas("UI-QuestTracker-Secondary-Objective-Header")
        button:SetPushedAtlas("UI-QuestTracker-Secondary-Objective-Header")
        
        -- Create enable/disable toggle button
        if not button.enableButton then
            button.enableButton = CreateFrame("Button", nil, button)
            button.enableButton:SetSize(16, 16)
            
            button.enableButton.icon = button.enableButton:CreateTexture(nil, "ARTWORK")
            button.enableButton.icon:SetAllPoints()
            
            button.enableButton:SetScript("OnClick", function(self)
                -- Read preset name from button (set during refresh)
                local presetName = self.presetName
                
                if not presetName then 
                    return 
                end
                
                local preset = WeakTexturesDB.presets[presetName]
                if preset then
                    preset.enabled = not preset.enabled
                    
                    -- Move preset to/from Disabled group
                    if not preset.enabled then
                        -- Disabling: save current group and move to Disabled
                        preset.previousGroup = preset.group
                        preset.group = "Disabled"
                        wt:HideTextureFrame(presetName)
                        
                        -- Deregister events when disabling
                        wt:DeRegisterPresetEvents(presetName)
                    else
                        -- Enabling: restore previous group
                        preset.group = preset.previousGroup
                        preset.previousGroup = preset.group
                        wt:ApplyPreset(presetName)
                        
                        -- Re-register events when enabling (if advanced conditions are active)
                        if preset.advancedEnabled then
                            wt:RegisterPresetEvents(presetName)
                        end
                    end
                    
                    -- Refresh will update icon automatically
                    wt:RefreshPresetList()
                end
            end)
            
            button.enableButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local presetName = self.presetName
                if not presetName then return end
                
                local preset = WeakTexturesDB.presets[presetName]
                if preset and preset.enabled then
                    GameTooltip:SetText("Click to disable preset", nil, nil, nil, nil, true)
                else
                    GameTooltip:SetText("Click to enable preset", nil, nil, nil, nil, true)
                end
                GameTooltip:Show()
            end)
            
            button.enableButton:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        
        -- Store current preset name in button (for OnClick handler)
        button.enableButton.presetName = data.name
        
        -- Check if this is an example preset
        local preset = WeakTexturesDB.presets[data.name]
        if preset and preset.example then
            -- Hide enable button for example presets
            button.enableButton:Hide()
        else
            -- Update enable button icon for regular presets
            if preset and preset.enabled then
                button.enableButton.icon:SetAtlas("PlayerFriend")
            else
                button.enableButton.icon:SetAtlas("PlayerEnemy")
            end
            
            button.enableButton:ClearAllPoints()
            button.enableButton:SetPoint("LEFT", button, "LEFT", -5, 0)
            button.enableButton:Show()
        end
        
        if not button.text then
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetJustifyH("LEFT")
            wt:ApplyCustomFont(button.text, 12)
        end
        
        if data.icon then
            button.text:SetText("|T" .. data.icon .. ":14:14:0:-1|t " .. data.name)
        else
            button.text:SetText(data.name)
        end
        button.text:ClearAllPoints()
        if preset and preset.example then
            button.text:SetPoint("LEFT", button, "LEFT", 5, 0)
        else
            button.text:SetPoint("LEFT", button.enableButton, "RIGHT", 0, 0)
        end
        
        -- Hide count and expandIcon if exists (for when button is reused from group)
        if button.count then
            button.count:Hide()
        end
        if button.expandIcon then
            button.expandIcon:Hide()
        end
        
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        
        button:SetScript("OnMouseDown", function(self, mouseButton)
            if mouseButton == "LeftButton" then
                self.clickStartTime = GetTime()
            end
        end)
        
        button:SetScript("OnMouseUp", function(self, mouseButton)
            if mouseButton == "LeftButton" then
                -- Check if this was a drag operation
                if wt.draggedPreset == data.name then
                    -- Don't select preset after drag
                    return
                end
                
                -- Normal click
                local clickTime = self.clickStartTime or 0
                if GetTime() - clickTime < 0.3 then
                    wt:allDefault()
                    wt.selectedPreset = data.name
                    wt.frame.right:EnableMouse(true)
                    wt.frame.right:Show()
                    wt:LoadPresetIntoFields(data.name)
                    wt:RefreshPresetList()
                    
                    -- Determine which tab to show
                    local targetTab = "display"
                    if wt.currentRightTab then
                        targetTab = wt.currentRightTab
                    end
                    
                    local preset = WeakTexturesDB.presets[data.name]
                    
                    -- Don't stay on advanced if advanced conditions aren't enabled
                    if targetTab == "advanced" then
                        if not preset.conditions or not preset.conditions.advanced then
                            targetTab = "display"
                        end
                    end
                    
                    -- Don't stay on import tab
                    if targetTab == "import" then
                        targetTab = "display"
                    end
                    
                    wt:ShowRightTab(targetTab)
                    
                    wt:Debug("Selected preset:", wt.selectedPreset)
                end
            end
        end)
        
        button:SetScript("OnClick", function(self, mouseButton)
            if mouseButton == "RightButton" then
                wt:ShowContextMenu(self, data.name)
            end
        end)
        
        -- Enable drag and drop for presets
        button:SetMovable(true)
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnDragStart", function(self)
            wt:StartPresetDrag(self, data.name)
        end)
        button:SetScript("OnDragStop", function(self)
            wt:StopPresetDrag()
        end)
        
        -- Prevent dropping on presets
        button:SetScript("OnEnter", function(self)
            if wt.draggedPreset then
                -- Show red highlight on presets (invalid drop target)
                wt:HighlightDropTarget(self, "PRESET", true)
            end
        end)
        button:SetScript("OnLeave", function(self)
            if wt.draggedPreset then
                wt:UnhighlightDropTarget(self)
            end
        end)
        
        -- Hide drop highlight if exists (clear from previous use)
        if button.dropHighlight then
            button.dropHighlight:Hide()
        end
        
        -- Create and show/hide selected highlight
        if not button.selectedHighlight then
            button.selectedHighlight = button:CreateTexture(nil, "OVERLAY")
            button.selectedHighlight:SetAllPoints()
            button.selectedHighlight:SetColorTexture(0, 0.6, 0, 0.15)  -- Dark green overlay
        end
        
        if data.selected then
            button.selectedHighlight:Show()
        else
            button.selectedHighlight:Hide()
        end
        
        -- Create eye button
        if not button.eye then
            button.eye = CreateFrame("Button", nil, button)
            button.eye:SetSize(16, 16)
            button.eye:SetNormalAtlas("worldquest-icon-nzoth")
            button.eye:SetHighlightAtlas("worldquest-icon-nzoth")
            button.eye:SetPushedAtlas("worldquest-icon-nzoth")
        end
        button.eye:Show()
        button.eye:ClearAllPoints()
        button.eye:SetPoint("RIGHT", button, "RIGHT", -5, 0)
        button.eye:SetScript("OnEnter", function(self)
            wt:ShowPresetTooltip(self, data.name)
        end)
        button.eye:SetScript("OnLeave", function()
            wt:HidePresetTooltip()
        end)
    end
end

---Update line numbers in trigger editor, optionally highlighting error lines
---@param errorLines number|number[]|nil
function wt:UpdateTriggerLineNumbers(errorLines)
    -- Check if UI is loaded
    if not wt.frame or not wt.frame.right or not wt.frame.right.advancedPanel then
        return
    end
    
    local editbox = wt.frame.right.advancedPanel.triggerEdit
    local linebox = wt.frame.right.advancedPanel.lineNumEditBox
    local linetest = wt.frame.right.advancedPanel.lineTestText
    
    -- Convert single number to table for uniform handling
    if type(errorLines) == "number" then
        errorLines = {errorLines}
    end
    
    -- Create lookup table for error lines
    local errorLineMap = {}
    if errorLines then
        for _, lineNum in ipairs(errorLines) do
            errorLineMap[lineNum] = true
        end
    end
    
    local width = editbox:GetWidth()
    local text = editbox:GetText()
    
    local linetext = ""
    local count = 1
    for line in text:gmatch("([^\n]*\n?)") do
        if #line > 0 then
            -- Highlight error lines in red
            if errorLineMap[count] then
                linetext = linetext .. "|cffff0000" .. count .. "|r\n"
            else
                linetext = linetext .. count .. "\n"
            end
            count = count + 1
        end
    end
    
    if text:sub(-1, -1) == "\n" then
        if errorLineMap[count] then
            linetext = linetext .. "|cffff0000" .. count .. "|r\n"
        else
            linetext = linetext .. count .. "\n"
        end
    end
    
    linebox:SetText(linetext)
end

---Highlight the error line in the trigger editor with bright overlay color
function wt:HighlightTriggerErrorLine()
    local editbox = wt.frame.right.advancedPanel.triggerEdit
    local text = editbox:GetText()
    
    if not wt.triggerErrorLine then
        -- No error, let IndentationLib handle coloring
        if editbox.cachedText then
            editbox:SetText(editbox.cachedText)
            editbox.cachedText = nil
        end
        return
    end
    
    -- Cache original text before modification
    if not editbox.cachedText then
        editbox.cachedText = text
    end
    
    -- Split text into lines
    local lines = {}
    for line in text:gmatch("([^\n]*\n?)") do
        table.insert(lines, line)
    end
    
    -- Apply bright yellow/orange overlay to error line
    if lines[wt.triggerErrorLine] then
        local errorLineText = lines[wt.triggerErrorLine]
        -- Bright yellow overlay color that will be visible over other syntax colors
        lines[wt.triggerErrorLine] = "|cFFFFDD00" .. errorLineText:gsub("|r", "") .. "|r"
    end
    
    -- Reconstruct text
    local newText = table.concat(lines, "")
    editbox:SetText(newText)
end

---Get list of all profile names
---@return string[]
function wt:GetAllProfiles()
    local profiles = {}
    for name in pairs(WeakTexturesProfiles) do
        table.insert(profiles, name)
    end
    table.sort(profiles)
    return profiles
end

---Get active profile name
---@return string
function wt:GetActiveProfile()
    return WeakTexturesCharacter.activeProfile or "Default"
end

---Start dragging a preset
---@param button Frame
---@param presetName string
function wt:StartPresetDrag(button, presetName)
    -- Don't allow dragging disabled presets
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or preset.enabled == false then
        wt:Debug("Cannot drag disabled preset:", presetName)
        return
    end
    
    -- Clear any existing highlights
    if wt.highlightedTarget then
        wt:UnhighlightDropTarget(wt.highlightedTarget)
    end
    
    wt.draggedPreset = presetName
    wt.draggedButton = button
    
    -- Create visual drag frame
    if not wt.dragFrame then
        wt.dragFrame = CreateFrame("Frame", nil, UIParent)
        wt.dragFrame:SetFrameStrata("TOOLTIP")
        wt.dragFrame:SetSize(200, 20)
        
        wt.dragFrame.bg = wt.dragFrame:CreateTexture(nil, "BACKGROUND")
        wt.dragFrame.bg:SetAllPoints()
        wt.dragFrame.bg:SetColorTexture(0, 0, 0, 0.8)
        
        wt.dragFrame.text = wt.dragFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        wt.dragFrame.text:SetPoint("CENTER")
    end
    
    wt.dragFrame.text:SetText(presetName)
    wt.dragFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", GetCursorPosition())
    wt.dragFrame:Show()
    
    -- Update drag frame position
    wt.dragFrame:SetScript("OnUpdate", function(self)
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    end)
end

---Stop dragging a preset
function wt:StopPresetDrag()
    -- Save values before clearing
    local presetName = wt.draggedPreset
    local targetGroup = wt.highlightedGroupPath
    
    -- Clear state immediately to prevent recursion
    wt.draggedPreset = nil
    wt.draggedButton = nil
    wt.highlightedGroupPath = nil
    
    if wt.dragFrame then
        wt.dragFrame:Hide()
        wt.dragFrame:SetScript("OnUpdate", nil)
    end
    
    -- Clear any remaining highlights
    if wt.highlightedTarget then
        wt:UnhighlightDropTarget(wt.highlightedTarget)
    end
    
    -- Now perform the drop (after clearing state)
    if presetName and targetGroup then
        wt:DropPresetOnGroup(targetGroup, presetName)
    end
end

---Highlight a drop target
---@param button Frame
---@param groupPath string
---@param isInvalid boolean|nil
function wt:HighlightDropTarget(button, groupPath, isInvalid)
    if not wt.draggedPreset then return end
    
    -- Clear previous highlight if different button
    if wt.highlightedTarget and wt.highlightedTarget ~= button then
        wt:UnhighlightDropTarget(wt.highlightedTarget)
    end
    
    wt.highlightedTarget = button
    
    -- Only set highlightedGroupPath if it's a valid drop target
    if not isInvalid then
        wt.highlightedGroupPath = groupPath
    else
        wt.highlightedGroupPath = nil
    end
    
    -- Create highlight overlay
    if not button.dropHighlight then
        button.dropHighlight = button:CreateTexture(nil, "OVERLAY")
        button.dropHighlight:SetAllPoints()
    end
    
    -- Green for valid, red for invalid
    if isInvalid then
        button.dropHighlight:SetColorTexture(1, 0, 0, 0.3)  -- Red
    else
        button.dropHighlight:SetColorTexture(0, 1, 0, 0.3)  -- Green
    end
    
    button.dropHighlight:Show()
end

---Unhighlight a drop target
---@param button Frame
function wt:UnhighlightDropTarget(button)
    if button and button.dropHighlight then
        button.dropHighlight:Hide()
    end
    
    wt.highlightedTarget = nil
    wt.highlightedGroupPath = nil
end

---Drop a preset on a group
---@param groupPath string
---@param presetName string|nil
function wt:DropPresetOnGroup(groupPath, presetName)
    presetName = presetName or wt.draggedPreset
    
    if not presetName then 
        return 
    end
    
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then
        return
    end
    
    -- Determine the new group value
    local newGroup
    if groupPath == "Ungrouped" then
        newGroup = ""
    elseif groupPath == "Disabled" then
        -- Can't move to Disabled - that's controlled by enabled flag
        return
    else
        newGroup = groupPath
    end
    
    -- Update preset's group
    preset.group = newGroup
    
    -- Refresh UI
    wt:RefreshPresetList()
end

---Toggle filter panel visibility
function wt:ToggleFilterPanel()
    local filterPanel = wt.frame.left.filterPanel
    local filterButton = wt.frame.left.filterButton
    local L = wt.L
    
    if filterPanel:IsShown() then
        -- Hide filter panel
        filterPanel:Hide()
        wt.frame.left.filterScrollFrame:EnableMouse(false)
        filterButton.text:SetText(L.BUTTON_FILTER)
    else
        -- Show filter panel
        filterPanel:Show()
        wt.frame.left.filterScrollFrame:EnableMouse(true)
        filterButton.text:SetText(L.BUTTON_CLOSE)
        
        -- Initialize filter panel if not already done
        if not filterPanel.initialized then
            wt:InitializeFilterPanel()
        end
    end
end

---Initialize filter panel with all filter controls
function wt:InitializeFilterPanel()
    local panel = wt.frame.left.filterPanel
    local content = wt.frame.left.filterContent
    local L = wt.L
    local yOffset = -10
    
    -- Initialize active filters table
    wt.activeFilters = wt.activeFilters or {}
    
    -- Header
    local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOP", content, "TOP", 0, yOffset)
    header:SetText(L.HEADER_FILTERS)
    header:SetTextColor(0.5, 1, 0.5)
    wt:ApplyCustomFont(header, 12, "", true)
    yOffset = yOffset - 25
    
    -- Class dropdown
    local classLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    classLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    classLabel:SetText(L.LABEL_CLASS .. ":")
    wt:ApplyCustomFont(classLabel, 10)
    yOffset = yOffset - 18
    
    local classDropdown = wt:CreateDropdown(content, "WT_FilterClassDropdown", 200, L.DROPDOWN_ANY_CLASS, "")
    classDropdown:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    yOffset = yOffset - 30
    
    -- Spec dropdown (initially hidden)
    local specLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    specLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    specLabel:SetText(L.LABEL_SPEC .. ":")
    wt:ApplyCustomFont(specLabel, 10)
    specLabel:Hide()
    yOffset = yOffset - 18
    
    local specDropdown = wt:CreateDropdown(content, "WT_FilterSpecDropdown", 200, L.DROPDOWN_ANY_SPEC, "")
    specDropdown:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    specDropdown:Hide()
    yOffset = yOffset - 30
    
    -- Setup class dropdown menu
    classDropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(L.DROPDOWN_ANY_CLASS, function() return dropdown.selectedValue == "" end, function()
            dropdown.selectedValue = ""
            wt.activeFilters.class = nil
            wt.activeFilters.spec = nil
            specLabel:Hide()
            specDropdown:Hide()
            wt:RefreshPresetList()
        end)
        
        for _, class in ipairs(wt:GetAllClasses()) do
            rootDescription:CreateRadio(class.name, function() return dropdown.selectedValue == class.file end, function()
                dropdown.selectedValue = class.file
                wt.activeFilters.class = class.file
                wt.activeFilters.spec = nil
                
                -- Show spec dropdown and update its options
                specLabel:Show()
                specDropdown:Show()
                specDropdown.selectedValue = ""
                
                -- Rebuild spec dropdown menu
                specDropdown:SetupMenu(function(specDD, specRoot)
                    specRoot:CreateRadio(L.DROPDOWN_ANY_SPEC, function() return specDD.selectedValue == "" end, function()
                        specDD.selectedValue = ""
                        wt.activeFilters.spec = nil
                        wt:RefreshPresetList()
                    end)
                    
                    for _, spec in ipairs(wt:GetSpecsForClass(class.file)) do
                        specRoot:CreateRadio(spec.name, function() return specDD.selectedValue == spec.id end, function()
                            specDD.selectedValue = spec.id
                            wt.activeFilters.spec = spec.id
                            wt:RefreshPresetList()
                        end)
                    end
                end)
                
                wt:RefreshPresetList()
            end)
        end
    end)
    
    -- Combat checkbox
    local combatCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_COMBAT, 0, L.PREFIX_IN)
    combatCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    combatCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.combat = nil
        elseif state == 1 then
            wt.activeFilters.combat = true
        else
            wt.activeFilters.combat = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(combatCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Encounter checkbox
    local encounterCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_ENCOUNTER, 0, L.PREFIX_IN)
    encounterCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    encounterCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.encounter = nil
        elseif state == 1 then
            wt.activeFilters.encounter = true
        else
            wt.activeFilters.encounter = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(encounterCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Alive checkbox
    local aliveCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_ALIVE, 0, "")
    aliveCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    aliveCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.alive = nil
        elseif state == 1 then
            wt.activeFilters.alive = true
        else
            wt.activeFilters.alive = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(aliveCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Rested checkbox
    local restedCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_RESTED, 0, "")
    restedCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    restedCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.rested = nil
        elseif state == 1 then
            wt.activeFilters.rested = true
        else
            wt.activeFilters.rested = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(restedCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Pet Battle checkbox
    local petBattleCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_PET_BATTLE, 0, L.PREFIX_IN)
    petBattleCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    petBattleCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.petBattle = nil
        elseif state == 1 then
            wt.activeFilters.petBattle = true
        else
            wt.activeFilters.petBattle = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(petBattleCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Vehicle checkbox
    local vehicleCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_VEHICLE, 0, L.PREFIX_IN)
    vehicleCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    vehicleCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.vehicle = nil
        elseif state == 1 then
            wt.activeFilters.vehicle = true
        else
            wt.activeFilters.vehicle = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(vehicleCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Instance checkbox
    local instanceCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_INSTANCE, 0, L.PREFIX_IN)
    instanceCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    instanceCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.instance = nil
        elseif state == 1 then
            wt.activeFilters.instance = true
        else
            wt.activeFilters.instance = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(instanceCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Housing checkbox
    local housingCheck = wt:CreateThreeStateCheckBox(content, nil, L.CHECKBOX_HOME, 0, L.PREFIX_AT)
    housingCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    housingCheck.onStateChange = function(state)
        if state == 0 then
            wt.activeFilters.housing = nil
        elseif state == 1 then
            wt.activeFilters.housing = true
        else
            wt.activeFilters.housing = false
        end
        wt:RefreshPresetList()
    end
    wt:ApplyCustomFont(housingCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Advanced checkbox (simple checkbox, not three-state)
    local advancedCheck = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    advancedCheck:SetSize(24, 24)
    advancedCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    advancedCheck.text:SetText(L.HEADER_ADVANCED_CONDITIONS)
    advancedCheck.text:SetTextColor(1, 1, 1)
    advancedCheck:SetScript("OnClick", function(self)
        if self:GetChecked() then
            wt.activeFilters.advanced = true
        else
            wt.activeFilters.advanced = nil
        end
        wt:RefreshPresetList()
    end)
    wt:ApplyCustomFont(advancedCheck.text, 10)
    yOffset = yOffset - 28
    
    -- Set content height for scrolling
    content:SetHeight(math.abs(yOffset) + 20)
    
    panel.initialized = true
end