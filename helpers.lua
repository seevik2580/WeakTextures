-- =====================================================
-- WeakTextures Helpers
-- =====================================================
local _, wt = ...

function wt:Debug(...)
    print("|cffff0000[WeakTextures]|r", ...)
end

function wt:MakeTextureKey(anchorName, texturePath)
    return anchorName .. "|" .. texturePath
end

function wt:PresetMatchesConditions(preset)
    if not WeakTexturesDB.presets[preset] then
        return false
    end
    preset = WeakTexturesDB.presets[preset]

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

    return true
end

function wt:CreateAnchoredTexture(presetName, anchorName, texturePath, width, height, x, y)
    local anchor = _G[anchorName]
    if not anchor then return end

    width  = tonumber(width)  or 64
    height = tonumber(height) or 64
    x = tonumber(x) or 0
    y = tonumber(y) or 0

    wt.activeFramesByPreset[presetName] = wt.activeFramesByPreset[presetName] or {}
    local container = wt.activeFramesByPreset[presetName]
    local f = container.frame

    local preset = WeakTexturesDB.presets[presetName]
    local strata = (preset and preset.strata) or "MEDIUM"
    local frameLevel = (preset and preset.frameLevel) or 100

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
    end

    -- Update existing texture
    f:SetSize(width, height)
    f:ClearAllPoints()
    f:SetPoint("CENTER", anchor, "CENTER", x, y)
    f:SetFrameStrata(strata)
    f:SetFrameLevel(frameLevel)
    f.texture:SetTexture(texturePath)


end

function wt:PlayStopMotion(presetName, anchorName, texturePath, width, height, x, y, columns, rows, totalFrames, fps)
    local anchor = _G[anchorName]
    if not anchor then return end

    width = tonumber(width) or 64
    height = tonumber(height) or 64
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    columns = tonumber(columns) or 1
    rows = tonumber(rows) or 1
    totalFrames = tonumber(totalFrames) or 1
    fps = tonumber(fps) or 30

    wt.activeFramesByPreset[presetName] = wt.activeFramesByPreset[presetName] or {}
    local container = wt.activeFramesByPreset[presetName]
    local f = container.frame

    local preset = WeakTexturesDB.presets[presetName]
    local strata = (preset and preset.strata) or "MEDIUM"
    local frameLevel = (preset and preset.frameLevel) or 100

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
    end

    -- Update existing texture
    f:SetSize(width, height)
    f:ClearAllPoints()
    f:SetPoint("CENTER", anchor, "CENTER", x, y)
    f:SetFrameStrata(strata)
    f:SetFrameLevel(frameLevel)
    f.texture:SetTexture(texturePath)

    -- Wait for texture to load before setting tex coord and starting animation
    local function checkLoaded()
        if f.texture:GetWidth() > 0 then
            -- Set initial tex coord for frame 0
            local col = 0
            local row = 0
            f.texture:SetTexCoord(
                col / columns,
                (col + 1) / columns,
                row / rows,
                (row + 1) / rows
            )

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
                self.texture:SetTexCoord(
                    col / columns,
                    (col + 1) / columns,
                    row / rows,
                    (row + 1) / rows
                )
            end)
        else
            C_Timer.After(0.01, checkLoaded)
        end
    end
    checkLoaded()
end

function wt:HideTextureFrame(presetName)
    local frames = wt.activeFramesByPreset[presetName]
    if not frames then return end

    for _, frame in pairs(frames) do
        frame:Hide()
        frame:SetParent(nil)
    end

    wt.activeFramesByPreset[presetName] = nil
end

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

function wt:GetSpecsForClass(classFile)
    local specs = {}

    for classID = 1, GetNumClasses() do
        local info = C_CreatureInfo.GetClassInfo(classID)
        if info and info.classFile == classFile then
            for i = 1, GetNumSpecializationsForClassID(classID) do
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

function wt:allDefault()
    wt.selectedPreset = nil
    wt.selectedGroup = nil
    wt.anchorEdit:SetText("")
    wt.textureEdit:SetText("")
    wt.widthEdit:SetText("")
    wt.heightEdit:SetText("")
    wt.xOffsetEdit:SetText("")
    wt.yOffsetEdit:SetText("")
    wt.groupEditBox:SetText("")
    wt.presetNameEdit:SetText("")
    wt.enabledCheck:SetChecked(true)
    UIDropDownMenu_SetText(wt.typeDropDown, "Static")
    wt:HideMotionFields()
    wt.columnsEdit:SetText("")
    wt.rowsEdit:SetText("")
    wt.totalFramesEdit:SetText("")
    wt.fpsEdit:SetText("")
    UIDropDownMenu_SetSelectedValue(wt.classDropDown, "Any Class")
    UIDropDownMenu_SetSelectedValue(wt.specDropDown, "Any Spec")
    UIDropDownMenu_SetSelectedValue(wt.strataDropDown, "MEDIUM")
    wt.frameLevelEdit:SetText("100")
end