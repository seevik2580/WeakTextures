-- =====================================================
-- WeakTextures Presets
-- =====================================================
local _, wt = ...

function wt:ApplyPreset(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.textures then return end

    if not self:PresetMatchesConditions(presetName) then
        self:HideTextureFrame(presetName)
        return
    end

    local data = preset.textures[1]
    if not data then return end

    if preset.type == "motion" then
        self:PlayStopMotion(presetName, data.anchor, data.texture, data.width, data.height, data.x, data.y, preset.columns or 1, preset.rows or 1, preset.totalFrames or 1, preset.fps or 30)
    else
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
end

function wt:ApplyAllPresets()
    for presetName in pairs(WeakTexturesDB.presets) do
        self:ApplyPreset(presetName)
    end
end

function wt:LoadPresetIntoFields(presetName)
    local preset = WeakTexturesDB.presets[presetName]

    -- NO PRESET / EMPTY PRESET
    if not preset or not preset.textures then
        wt:allDefault()
        wt.presetNameEdit:SetText(presetName or "")
        wt.groupEditBox:SetText(preset and preset.group or "")
        wt.enabledCheck:SetChecked(preset and preset.enabled ~= false or true)
        return
    end

    -- RESET DROPDOWNS FIRST
    UIDropDownMenu_SetText(wt.classDropDown, "Any Class")
    UIDropDownMenu_SetText(wt.specDropDown, "Any Spec")

    -- CONDITIONS
    if preset.conditions then
        -- Class
        if preset.conditions.class then
            for _, class in ipairs(self:GetAllClasses()) do
                if class.file == preset.conditions.class then
                    UIDropDownMenu_SetText(wt.classDropDown, class.name)
                    break
                end
            end
        end

        -- Spec (only if class exists)
        if preset.conditions.class and preset.conditions.spec then
            for _, spec in ipairs(self:GetSpecsForClass(preset.conditions.class)) do
                if spec.id == preset.conditions.spec then
                    UIDropDownMenu_SetText(wt.specDropDown, spec.name)
                    break
                end
            end
        end
    end

    -- STRATA
    local strata = preset.strata or "MEDIUM"
    UIDropDownMenu_SetSelectedValue(wt.strataDropDown, strata)
    UIDropDownMenu_SetText(wt.strataDropDown, strata)

    -- FRAME LEVEL
    wt.frameLevelEdit:SetText(preset.frameLevel and tostring(preset.frameLevel) or "100")

    -- TEXTURE DATA (SINGLE)
    local data = preset.textures[1]
    if data then
        wt.anchorEdit:SetText(data.anchor or "")
        wt.textureEdit:SetText(data.texture or "")
        wt.widthEdit:SetText(data.width and tostring(data.width) or "")
        wt.heightEdit:SetText(data.height and tostring(data.height) or "")
        wt.xOffsetEdit:SetText(data.x and tostring(data.x) or "")
        wt.yOffsetEdit:SetText(data.y and tostring(data.y) or "")
    end
    -- PRESET NAME + GROUP
    wt.presetNameEdit:SetText(presetName)

    local displayGroup = preset.group
    if preset.group == "Disabled" and preset.originalGroup then
        displayGroup = preset.originalGroup
    end
    wt.groupEditBox:SetText(displayGroup or "")

    -- TYPE
    local presetType = preset.type or "static"
    UIDropDownMenu_SetText(wt.typeDropDown, presetType == "motion" and "Stop Motion" or "Static")
    if presetType == "motion" then
        wt:ShowMotionFields()
        wt.columnsEdit:SetText(preset.columns and tostring(preset.columns) or "")
        wt.rowsEdit:SetText(preset.rows and tostring(preset.rows) or "")
        wt.totalFramesEdit:SetText(preset.totalFrames and tostring(preset.totalFrames) or "")
        wt.fpsEdit:SetText(preset.fps and tostring(preset.fps) or "")
    else
        wt:HideMotionFields()
    end

    wt.enabledCheck:SetChecked(preset.enabled ~= false)
end

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

    return newName
end