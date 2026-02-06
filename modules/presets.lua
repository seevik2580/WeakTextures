-- =====================================================
-- WeakTextures Presets
-- =====================================================
local _, wt = ...
local L = wt.L

-- Apply a single preset (show its texture)
---@param presetName string
function wt:ApplyPreset(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.textures or not preset.textures[1] then 
        wt:Debug("ApplyPreset: No preset or textures for", presetName)
        return 
    end
    
    -- Skip ApplyPreset logic for multi-instance presets
    -- They manage their own lifecycle via CreateInstance + duration timers
    if preset.instancePool and preset.instancePool.enabled then
        return
    end
    
    if preset.enabled == false then
        wt:Debug("ApplyPreset: Preset disabled:", presetName)
        self:HideTextureFrame(presetName)
        return
    end

    wt:Debug("ApplyPreset: Processing", presetName, "type:", preset.type)

    -- Check advanced conditions
    if not wt:CheckPresetAdvancedConditions(presetName) then
        wt:Debug("ApplyPreset: Advanced conditions failed for", presetName)
        self:HideTextureFrame(presetName)
        return
    end

    local isMatching = self:PresetMatchesConditions(presetName)
    wt:Debug("ApplyPreset: isMatching =", isMatching, "for", presetName)
    
    if wt.isApplyingFromEvent then
        local wasMatching = wt.lastPresetState[presetName]
        wt:Debug("ApplyPreset: wasMatching =", wasMatching, "isApplyingFromEvent = true")
        wt.lastPresetState[presetName] = isMatching
        
        if not isMatching then
            wt:Debug("ApplyPreset: Hiding because not matching")
            -- Kontrola zda už není skrytý
            local container = wt.activeFramesByPreset[presetName]
            local isCurrentlyShown = container and container.frame and container.frame:IsShown()
            if isCurrentlyShown then
                self:HideTextureFrame(presetName)
            end
            return
        end

        -- Check if frame actually exists and is shown - if yes, skip recreation
        local container = wt.activeFramesByPreset[presetName]
        local frameExists = container and container.frame
        local isCurrentlyShown = frameExists and container.frame:IsShown()
        if wasMatching and isCurrentlyShown then
            wt:Debug("ApplyPreset: Skipping because wasMatching = true and frame is shown")
            return
        end
    elseif not isMatching then
        -- Not applying from event but conditions don't match
        wt:Debug("ApplyPreset: Hiding because not matching (not from event)")
        self:HideTextureFrame(presetName)
        return
    end

    -- Check if preset uses v2 multi-instance system
    if preset.instancePool and preset.instancePool.enabled then
        wt:Debug("ApplyPreset: Using multi-instance mode for", presetName)
        -- Multi-instance mode doesn't auto-show, it waits for CreateInstance() calls
        return
    end

    local data = preset.textures[1]
    wt:Debug("ApplyPreset: Creating texture for", presetName, "anchor:", data.anchor, "texture:", data.texture)

    if preset.type == "motion" then
        wt:Debug("ApplyPreset: Playing stop motion")
        self:PlayStopMotion(presetName, data.anchor, data.texture, data.width, data.height, data.x, data.y, preset.columns or 1, preset.rows or 1, preset.totalFrames or 1, preset.fps or 30)
    else
        wt:Debug("ApplyPreset: Creating static texture")
        self:CreateAnchoredTexture(
            presetName,
            data.anchor,
            data.texture,
            data.width,
            data.height,
            data.x,
            data.y
        )
    end
    
    -- Play default sound if defined (only for single-frame presets, not instance pool)
    if preset.sound and preset.sound.file then
        local soundPath = preset.sound.file
        local soundChannel = preset.sound.channel or "Master"
        
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
end

-- Apply all presets that match their conditions
function wt:ApplyAllPresets()
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if preset.enabled then
            self:ApplyPreset(presetName)
        end
    end
end

-- Apply only presets registered for a specific event
---@param event string
function wt:ApplyPresetsForEvent(event)
    local presets = WeakTexturesDB.ADDON_EVENTS[event]
    if not presets then return end
    
    for presetName, shouldShow in pairs(presets) do
        local preset = WeakTexturesDB.presets[presetName]
        if preset and preset.enabled then
            if shouldShow then
                -- true = zkontroluj conditions a zobraz pokud splňuje
                self:ApplyPreset(presetName)
            else
                -- false = rovnou schovej
                local container = wt.activeFramesByPreset[presetName]
                local isCurrentlyShown = container and container.frame and container.frame:IsShown()
                if isCurrentlyShown then
                    self:HideTextureFrame(presetName)
                end
            end
        end
    end
end

-- Load a preset's data into the UI fields
---@param presetName string
function wt:LoadPresetIntoFields(presetName)
    local preset = WeakTexturesDB.presets[presetName]

    -- NO PRESET / EMPTY PRESET
    if not preset or not preset.textures then
        wt:allDefault()
        wt.frame.right.configPanelContent.presetNameEdit:SetText(presetName or "")
        
        -- Set group dropdown
        local groupName = preset and preset.group or ""
        if groupName and groupName ~= "" and WeakTexturesDB.groups[groupName] then
            wt.frame.right.configPanelContent.groupDropDown.selectedValue = groupName
            wt.frame.right.configPanelContent.groupEditBox:Hide()
        else
            wt.frame.right.configPanelContent.groupDropDown.selectedValue = ""
            wt.frame.right.configPanelContent.groupEditBox:Hide()
        end
        
        wt.frame.right.conditionsPanel.enabledCheck:SetChecked(preset and preset.enabled ~= false or true)
        return
    end
    
    -- PRESET NAME + GROUP
    wt.frame.right.configPanelContent.presetNameEdit:SetText(presetName)

    local displayGroup = preset.group
    if preset.group == "Disabled" and preset.originalGroup then
        displayGroup = preset.originalGroup
    end
    
    -- Set group dropdown
    if displayGroup and displayGroup ~= "" and displayGroup ~= "Disabled" and WeakTexturesDB.groups[displayGroup] then
        wt.frame.right.configPanelContent.groupDropDown.selectedValue = displayGroup
        wt.frame.right.configPanelContent.groupEditBox:Hide()
    else
        wt.frame.right.configPanelContent.groupDropDown.selectedValue = ""
        wt.frame.right.configPanelContent.groupEditBox:Hide()
    end

    -- TEXTURE DATA
    local data = preset.textures[1]
    if data then
        local anchorValue = data.anchor or "UIParent"
        wt.frame.right.configPanelContent.anchorEdit:SetText(anchorValue)
        
        -- Set anchor type dropdown based on anchor value
        if anchorValue == "UIParent" or anchorValue == "" then
            wt.frame.right.configPanelContent.anchorTypeDropDown.selectedValue = "Screen"
            wt.frame.right.configPanelContent.anchorEdit:Hide()
            wt.frame.right.configPanelContent.selectFrameBtn:Hide()
        else
            wt.frame.right.configPanelContent.anchorTypeDropDown.selectedValue = "Custom"
            wt.frame.right.configPanelContent.anchorEdit:Show()
            wt.frame.right.configPanelContent.selectFrameBtn:Show()
        end
        
        -- Check if texture is from LSM or WeakTexturesCustomTextures
        local texturePath = data.texture or ""
        local foundTexture = false
        
        -- First check WeakTexturesCustomTextures
        if WeakTexturesCustomTextures then
            for textureName, customPath in pairs(WeakTexturesCustomTextures) do
                if customPath == texturePath then
                    local displayName = textureName:gsub("^WT_", "")  -- Remove WT_ prefix for display
                    wt.frame.right.configPanelContent.textureDropDown.selectedValue = displayName
                    wt.frame.right.configPanelContent.textureDropDown.selectedPath = customPath
                    wt.frame.right.configPanelContent.textureCustomEdit:Hide()
                    foundTexture = true
                    break
                end
            end
        end
        
        -- If not found in custom textures, check all LSM categories
        if not foundTexture then
            for _, category in ipairs({"background", "border", "statusbar"}) do
                local textures = wt.LSM:List(category)
                for _, textureName in ipairs(textures) do
                    local lsmPath = wt.LSM:Fetch(category, textureName)
                    if lsmPath == texturePath then
                        wt.frame.right.configPanelContent.textureDropDown.selectedValue = textureName
                        wt.frame.right.configPanelContent.textureDropDown.selectedPath = lsmPath
                        wt.frame.right.configPanelContent.textureCustomEdit:Hide()
                        foundTexture = true
                        break
                    end
                end
                if foundTexture then break end
            end
        end
        
        -- If not found anywhere, use Custom
        if not foundTexture then
            wt.frame.right.configPanelContent.textureDropDown.selectedValue = "Custom"
            wt.frame.right.configPanelContent.textureDropDown.selectedPath = nil
            wt.frame.right.configPanelContent.textureCustomEdit:SetText(texturePath)
            wt.frame.right.configPanelContent.textureCustomEdit:Show()
        end
        
        wt.frame.right.configPanelContent.widthEdit:SetText(data.width and tostring(data.width) or "")
        wt.frame.right.configPanelContent.heightEdit:SetText(data.height and tostring(data.height) or "")
        wt.frame.right.configPanelContent.xOffsetEdit:SetText(data.x and tostring(data.x) or "")
        wt.frame.right.configPanelContent.yOffsetEdit:SetText(data.y and tostring(data.y) or "")
    end
    
    -- TEXT SETTINGS (from preset.text)
    if preset.text then
        wt.frame.right.configPanelContent.textContentEdit:SetText(preset.text.content or "")
        wt.frame.right.configPanelContent.fontDropDown.selectedValue = preset.text.font or "Friz Quadrata TT"
        wt.frame.right.configPanelContent.fontSizeEdit:SetText(preset.text.size and tostring(preset.text.size) or tostring(wt.TEXT_DEFAULT_SIZE or 48))
        wt.frame.right.configPanelContent.fontOutlineDropDown.selectedValue = preset.text.outline or wt.TEXT_DEFAULT_OUTLINE or "OUTLINE"
        
        if preset.text.color then
            wt.frame.right.configPanelContent.textColorPicker:SetColor(
                preset.text.color.r or 1,
                preset.text.color.g or 0.82,
                preset.text.color.b or 0,
                preset.text.color.a or 1
            )
        else
            -- Use defaults from db.lua
            local defaultColor = wt.TEXT_DEFAULT_COLOR or {r=1, g=0.82, b=0, a=1}
            wt.frame.right.configPanelContent.textColorPicker:SetColor(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
        end
        
        wt.frame.right.configPanelContent.textOffsetXEdit:SetText(preset.text.offsetX and tostring(preset.text.offsetX) or tostring(wt.TEXT_DEFAULT_OFFSET_X or 0))
        wt.frame.right.configPanelContent.textOffsetYEdit:SetText(preset.text.offsetY and tostring(preset.text.offsetY) or tostring(wt.TEXT_DEFAULT_OFFSET_Y or 125))
    else
        -- No text settings - use defaults
        wt.frame.right.configPanelContent.textContentEdit:SetText("")
        wt.frame.right.configPanelContent.fontDropDown.selectedValue = "Friz Quadrata TT"
        wt.frame.right.configPanelContent.fontSizeEdit:SetText(tostring(wt.TEXT_DEFAULT_SIZE or 48))
        wt.frame.right.configPanelContent.fontOutlineDropDown.selectedValue = wt.TEXT_DEFAULT_OUTLINE or "OUTLINE"
        local defaultColor = wt.TEXT_DEFAULT_COLOR or {r=1, g=0.82, b=0, a=1}
        wt.frame.right.configPanelContent.textColorPicker:SetColor(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
        wt.frame.right.configPanelContent.textOffsetXEdit:SetText(tostring(wt.TEXT_DEFAULT_OFFSET_X or 0))
        wt.frame.right.configPanelContent.textOffsetYEdit:SetText(tostring(wt.TEXT_DEFAULT_OFFSET_Y or 125))
    end
    
    -- Texture color
    if preset.color then
        wt.frame.right.configPanelContent.textureColorPicker:SetColor(
            preset.color.r or 1,
            preset.color.g or 1,
            preset.color.b or 1,
            preset.color.a or 1
        )
    else
        -- Default white
        wt.frame.right.configPanelContent.textureColorPicker:SetColor(1, 1, 1, 1)
    end
    
    -- SOUND SETTINGS
    if preset.sound then
        -- Check if sound is from LSM or custom
        local soundPath = preset.sound.file
        local foundSound = false
        
        if not soundPath or soundPath == "" then
            -- No sound - set to None
            wt.frame.right.configPanelContent.soundDropDown.selectedValue = "None"
            wt.frame.right.configPanelContent.soundDropDown.selectedPath = nil
            wt.frame.right.configPanelContent.soundCustomEdit:SetText("")
            wt.frame.right.configPanelContent.soundCustomEdit:Hide()
            foundSound = true
        elseif type(soundPath) == "number" then
            -- FileID - use Custom
            wt.frame.right.configPanelContent.soundDropDown.selectedValue = "Custom"
            wt.frame.right.configPanelContent.soundDropDown.selectedPath = nil
            wt.frame.right.configPanelContent.soundCustomEdit:SetText(tostring(soundPath))
            wt.frame.right.configPanelContent.soundCustomEdit:Show()
            foundSound = true
        elseif type(soundPath) == "string" and soundPath ~= "" then
            -- Check LSM sounds
            local sounds = wt.LSM:List("sound")
            for _, soundName in ipairs(sounds) do
                local lsmPath = wt.LSM:Fetch("sound", soundName)
                if lsmPath == soundPath then
                    wt.frame.right.configPanelContent.soundDropDown.selectedValue = soundName
                    wt.frame.right.configPanelContent.soundDropDown.selectedPath = lsmPath
                    wt.frame.right.configPanelContent.soundCustomEdit:Hide()
                    foundSound = true
                    break
                end
            end
            
            -- If not found in LSM, use Custom
            if not foundSound then
                wt.frame.right.configPanelContent.soundDropDown.selectedValue = "Custom"
                wt.frame.right.configPanelContent.soundDropDown.selectedPath = nil
                wt.frame.right.configPanelContent.soundCustomEdit:SetText(soundPath)
                wt.frame.right.configPanelContent.soundCustomEdit:Show()
            end
        end
        
        -- Sound channel
        wt.frame.right.configPanelContent.soundChannelDropDown.selectedValue = preset.sound.channel or "Master"
    else
        -- No sound settings - use defaults (None)
        wt.frame.right.configPanelContent.soundDropDown.selectedValue = "None"
        wt.frame.right.configPanelContent.soundDropDown.selectedPath = nil
        wt.frame.right.configPanelContent.soundCustomEdit:SetText("")
        wt.frame.right.configPanelContent.soundCustomEdit:Hide()
        wt.frame.right.configPanelContent.soundChannelDropDown.selectedValue = "MASTER"
    end
    
    -- Apply enable/disable state for sound controls based on selectedValue
    
    -- TYPE
    local presetType = preset.type or "static"
    local typeText = presetType == "motion" and "Stop Motion" or "Static"
    wt.frame.right.configPanelContent.ftypeDropDown.selectedValue = typeText
    if presetType == "motion" then
        wt:SetShownMotionFields(true)
        wt.frame.right.configPanelContent.columnsEdit:SetText(preset.columns and tostring(preset.columns) or "")
        wt.frame.right.configPanelContent.rowsEdit:SetText(preset.rows and tostring(preset.rows) or "")
        wt.frame.right.configPanelContent.totalFramesEdit:SetText(preset.totalFrames and tostring(preset.totalFrames) or "")
        wt.frame.right.configPanelContent.fpsEdit:SetText(preset.fps and tostring(preset.fps) or "")
    else
        wt:SetShownMotionFields(false)
    end
    -- SCALE
    wt.frame.right.configPanelContent.scaleEdit:SetText(preset.scale and tostring(preset.scale) or "1.0")
    
    -- ALPHA
    wt.frame.right.configPanelContent.alphaEdit:SetText(preset.alpha and tostring(preset.alpha) or "1.0")
    
    -- ANGLE
    wt.frame.right.configPanelContent.angleEdit:SetText(preset.angle and tostring(preset.angle) or "0")

    -- STRATA
    local strata = preset.strata or "MEDIUM"
    wt.frame.right.configPanelContent.strataDropDown.selectedValue = strata

    -- FRAME LEVEL
    wt.frame.right.configPanelContent.frameLevelEdit:SetText(preset.frameLevel and tostring(preset.frameLevel) or "100")

    -- Enable unlock button for existing preset
    wt.frame.right.unlockFrameBtn:Enable()
    wt.frame.right.unlockFrameBtn:SetNormalAtlas(wt.buttonNormal)
    
    -- RESET DROPDOWNS FIRST
    wt.frame.right.conditionsPanel.classDropDown.selectedValue = "Any Class"
    wt.frame.right.conditionsPanel.specDropDown.selectedValue = "Any Spec"

    -- Reset checkboxes
    wt.frame.right.conditionsPanel.aliveCheck:SetState(0)
    wt.frame.right.conditionsPanel.combatCheck:SetState(0)
    wt.frame.right.conditionsPanel.restedCheck:SetState(0)
    wt.frame.right.conditionsPanel.encounterCheck:SetState(0)
    wt.frame.right.conditionsPanel.petBattleCheck:SetState(0)
    wt.frame.right.conditionsPanel.vehicleCheck:SetState(0)
    wt.frame.right.conditionsPanel.instanceCheck:SetState(0)
    wt.frame.right.conditionsPanel.housingCheck:SetState(0)
    wt.frame.right.conditionsPanel.playerNameEdit:SetText("")
    wt.frame.right.conditionsPanel.zoneEdit:SetText("")

    -- CONDITIONS
    if preset.conditions then
        -- Class
        if preset.conditions.class then
            for _, class in ipairs(self:GetAllClasses()) do
                if class.file == preset.conditions.class then
                    wt.frame.right.conditionsPanel.classDropDown.selectedValue = class.name
                    break
                end
            end
        end

        -- Spec (only if class exists)
        if preset.conditions.class and preset.conditions.spec then
            for _, spec in ipairs(self:GetSpecsForClass(preset.conditions.class)) do
                if spec.id == preset.conditions.spec then
                    wt.frame.right.conditionsPanel.specDropDown.selectedValue = spec.name
                    break
                end
            end
        end

        -- Checkboxes
        if preset.conditions.alive and not preset.conditions.dead then
            wt.frame.right.conditionsPanel.aliveCheck:SetState(1)
        elseif not preset.conditions.alive and preset.conditions.dead then
            wt.frame.right.conditionsPanel.aliveCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.aliveCheck:SetState(0)
        end
        if preset.conditions.combat and not preset.conditions.notCombat then
            wt.frame.right.conditionsPanel.combatCheck:SetState(1)
        elseif not preset.conditions.combat and preset.conditions.notCombat then
            wt.frame.right.conditionsPanel.combatCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.combatCheck:SetState(0)
        end
        if preset.conditions.rested and not preset.conditions.notRested then
            wt.frame.right.conditionsPanel.restedCheck:SetState(1)
        elseif not preset.conditions.rested and preset.conditions.notRested then
            wt.frame.right.conditionsPanel.restedCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.restedCheck:SetState(0)
        end
        if preset.conditions.encounter and not preset.conditions.notEncounter then
            wt.frame.right.conditionsPanel.encounterCheck:SetState(1)
        elseif not preset.conditions.encounter and preset.conditions.notEncounter then
            wt.frame.right.conditionsPanel.encounterCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.encounterCheck:SetState(0)
        end
        if preset.conditions.petBattle and not preset.conditions.notPetBattle then
            wt.frame.right.conditionsPanel.petBattleCheck:SetState(1)
        elseif not preset.conditions.petBattle and preset.conditions.notPetBattle then
            wt.frame.right.conditionsPanel.petBattleCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.petBattleCheck:SetState(0)
        end
        if preset.conditions.vehicle and not preset.conditions.notVehicle then
            wt.frame.right.conditionsPanel.vehicleCheck:SetState(1)
        elseif not preset.conditions.vehicle and preset.conditions.notVehicle then
            wt.frame.right.conditionsPanel.vehicleCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.vehicleCheck:SetState(0)
        end
        if preset.conditions.instance and not preset.conditions.notInstance then
            wt.frame.right.conditionsPanel.instanceCheck:SetState(1)
        elseif not preset.conditions.instance and preset.conditions.notInstance then
            wt.frame.right.conditionsPanel.instanceCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.instanceCheck:SetState(0)
        end
        if preset.conditions.housing and not preset.conditions.nothousing then
            wt.frame.right.conditionsPanel.housingCheck:SetState(1)
        elseif not preset.conditions.housing and preset.conditions.nothousing then
            wt.frame.right.conditionsPanel.housingCheck:SetState(-1)
        else
            wt.frame.right.conditionsPanel.housingCheck:SetState(0)
        end
        wt.frame.right.conditionsPanel.playerNameEdit:SetText(preset.conditions.playerName or "")
        wt.frame.right.conditionsPanel.zoneEdit:SetText(preset.conditions.zone or "")
    end

    -- ADVANCED CONDITIONS
    local advancedEnabled = preset.advancedEnabled or false
    wt.frame.right.conditionsPanel.advancedCheck:SetChecked(advancedEnabled)
    wt:ToggleAdvancedTab(advancedEnabled)
    
    wt.frame.right.advancedPanel.eventsEdit:SetText(wt:EventsToString(preset.events or {}))
    wt.frame.right.advancedPanel.durationEdit:SetText(tostring(preset.duration or ""))
    wt.frame.right.advancedPanel.triggerEdit:SetText(preset.trigger or "")

    -- Multi-Instance checkbox state
    local multiInstanceEnabled = preset.instancePool and preset.instancePool.enabled or false
    wt.frame.right.advancedPanel.multiInstanceCheck:SetChecked(multiInstanceEnabled)

    wt.frame.right.conditionsPanel.enabledCheck:SetChecked(preset.enabled ~= false)
end

-- Rename a preset
---@param oldName string
---@param newName string
---@return string
function wt:RenamePreset(oldName, newName)
    if oldName == newName then return oldName end
    if WeakTexturesDB.presets[newName] then
        wt:Debug("Preset already exists:", newName)
        return oldName
    end

    -- Move DB entry
    WeakTexturesDB.presets[newName] = WeakTexturesDB.presets[oldName]
    WeakTexturesDB.presets[oldName] = nil

    -- Move active frame
    if wt.activeFramesByPreset[oldName] then
        wt.activeFramesByPreset[newName] = wt.activeFramesByPreset[oldName]
        wt.activeFramesByPreset[oldName] = nil
    end

    -- Update ADDON_EVENTS table
    for event, presets in pairs(WeakTexturesDB.ADDON_EVENTS) do
        if presets[oldName] then
            presets[newName] = presets[oldName]
            presets[oldName] = nil
        end
    end

    return newName
end