-- =====================================================
-- WeakTextures UI
-- =====================================================
local _, wt = ...

wt.frame = CreateFrame("Frame", "MTP_MainFrame", UIParent, "DefaultPanelTemplate")
wt.frame:SetSize(800, 600)
wt.frame:SetPoint("CENTER")
wt.frame:SetMovable(true)
wt.frame:EnableMouse(true)
wt.frame:RegisterForDrag("LeftButton")
wt.frame:SetScript("OnDragStart", wt.frame.StartMoving)
wt.frame:SetScript("OnDragStop", wt.frame.StopMovingOrSizing)
wt.frame:Hide()

if wt.frame.TitleContainer and wt.frame.TitleContainer.TitleText then
    wt.frame.TitleContainer.TitleText:SetText("WeakTextures")
end

--wt.frame.title:SetFrameStrata("HIGH")

wt.closeButton = CreateFrame("Button", nil, wt.frame, "UIPanelCloseButton")
wt.closeButton:SetPoint("TOPRIGHT", -5, -5)

-- =====================================================
-- LEFT PANEL (Presets)
-- =====================================================
wt.left = CreateFrame("Frame", nil, wt.frame, "BackdropTemplate")
wt.left:SetSize(250, 550)
wt.left:SetPoint("TOPLEFT", 10, -30)
wt.left:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
wt.left:SetBackdropColor(0,0,0,0.4)

wt.leftTitle = wt.left:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
wt.leftTitle:SetPoint("TOPLEFT", 10, -5)
wt.leftTitle:SetText("Presets")

wt.scroll = CreateFrame("ScrollFrame", nil, wt.left, "UIPanelScrollFrameTemplate")
wt.scroll:SetPoint("TOPLEFT", 5, -45)
wt.scroll:SetPoint("BOTTOMRIGHT", -28, 40)

wt.content = CreateFrame("Frame", nil, wt.scroll)
wt.content:SetSize(1,1)
wt.scroll:SetScrollChild(wt.content)

-- =====================================================
-- RIGHT PANEL (Texture creation)
-- =====================================================
wt.right = CreateFrame("Frame", nil, wt.frame, "BackdropTemplate")
wt.right:SetSize(520, 450)
wt.right:SetPoint("TOPLEFT", 270, -30)
wt.right:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
wt.right:SetBackdropColor(0,0,0,0.4)

wt.rightTitle = wt.right:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
wt.rightTitle:SetPoint("TOPLEFT", 15, -5)
wt.rightTitle:SetText("Configuration")

-- Subpanels
wt.configPanel = CreateFrame("Frame", nil, wt.right, "BackdropTemplate")
wt.configPanel:SetSize(280, 410)
wt.configPanel:SetPoint("TOPLEFT", 10, -25)
wt.configPanel:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
wt.configPanel:SetBackdropColor(0,0,0,0.2)

wt.presetNameLabel = wt.configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.presetNameLabel:SetPoint("TOPLEFT", 5, -2)
wt.presetNameLabel:SetText("Preset Name")

wt.presetNameEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.presetNameEdit:SetSize(125, 20)
wt.presetNameEdit:SetPoint("TOPLEFT", wt.presetNameLabel, "BOTTOMLEFT", 5, -5)
wt.presetNameEdit:SetAutoFocus(false)

wt.conditionsPanel = CreateFrame("Frame", nil, wt.right, "BackdropTemplate")
wt.conditionsPanel:SetSize(220, 410)
wt.conditionsPanel:SetPoint("TOPLEFT", 300, -25)
wt.conditionsPanel:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
wt.conditionsPanel:SetBackdropColor(0,0,0,0.2)

wt.conditionsTitle = wt.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.conditionsTitle:SetPoint("TOPLEFT", 5, -5)
wt.conditionsTitle:SetText("Load Conditions")

wt.groupEditLabel = wt.configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.groupEditLabel:SetPoint("TOPLEFT", wt.presetNameEdit, "TOPRIGHT", 10, 15)
wt.groupEditLabel:SetText("Preset Group")

wt.groupEditBox = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.groupEditBox:SetSize(125, 20)
wt.groupEditBox:SetPoint("TOPLEFT", wt.groupEditLabel, "TOPLEFT", 2, -15)
wt.groupEditBox:SetAutoFocus(false)

wt.enabledCheck = CreateFrame("CheckButton", nil, wt.conditionsPanel, "UICheckButtonTemplate")
wt.enabledCheck:SetPoint("TOPLEFT", 5, -20)
wt.enabledCheck:SetChecked(true)
wt.enabledCheck.text:SetText("Can load?")

wt.typeLabel = wt.configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.typeLabel:SetPoint("TOPLEFT", wt.presetNameEdit, "BOTTOMLEFT", -4, -10)
wt.typeLabel:SetText("Preset Type")

wt.typeDropDown = CreateFrame("Frame", "WT_TypeDropdown", wt.configPanel, "UIDropDownMenuTemplate")
wt.typeDropDown:SetPoint("TOPLEFT", wt.typeLabel, "BOTTOMLEFT", -20, -5)
UIDropDownMenu_SetWidth(wt.typeDropDown, 115)
UIDropDownMenu_SetText(wt.typeDropDown, "Static")
UIDropDownMenu_Initialize(wt.typeDropDown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Static"
    info.func = function()
        UIDropDownMenu_SetText(wt.typeDropDown, "Static")
        wt:HideMotionFields()
    end
    UIDropDownMenu_AddButton(info)
    info.text = "Stop Motion"
    info.func = function()
        UIDropDownMenu_SetText(wt.typeDropDown, "Stop Motion")
        wt:ShowMotionFields()
    end
    UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedValue(wt.typeDropDown, "Static")

wt.anchorLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.anchorLabel:SetPoint("TOPLEFT", wt.typeDropDown, "BOTTOMLEFT", 20, -10)
wt.anchorLabel:SetText("Anchor Frame")

wt.anchorEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.anchorEdit:SetSize(190, 20)
wt.anchorEdit:SetPoint("TOPLEFT", wt.anchorLabel, "BOTTOMLEFT", 3, -5)
wt.anchorEdit:SetAutoFocus(false)

wt.selectFrameBtn = CreateFrame("Button", nil, wt.configPanel, "UIPanelButtonTemplate")
wt.selectFrameBtn:SetSize(90, 20)
wt.selectFrameBtn:SetPoint("RIGHT", wt.anchorEdit, "RIGHT", 0, 20)
wt.selectFrameBtn:SetText("Select Frame")

wt.selectFrameBtn:SetScript("OnClick", function()
    wt:StartFrameChooser()
end)

-- ======================
-- Class dropdown
-- ======================
wt.classLabel = wt.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.classLabel:SetPoint("TOPLEFT", 5, -50)
wt.classLabel:SetText("Class")

wt.classDropDown = CreateFrame("Frame", "MTP_ClassDropdown", wt.conditionsPanel, "UIDropDownMenuTemplate")
wt.classDropDown:SetPoint("TOPLEFT", wt.classLabel, "BOTTOMLEFT", -15, -5)
UIDropDownMenu_SetWidth(wt.classDropDown, 180)
UIDropDownMenu_SetText(wt.classDropDown, "Any Class")
UIDropDownMenu_Initialize(wt.classDropDown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()

    -- Any class
    info.text = "Any Class"
    info.func = function()
        UIDropDownMenu_SetText(wt.classDropDown, "Any Class")
        UIDropDownMenu_SetText(wt.specDropDown, "Any Spec")
    end
    UIDropDownMenu_AddButton(info)

    -- Class list
    for _, class in ipairs(wt:GetAllClasses()) do
        info = UIDropDownMenu_CreateInfo()
        info.text = class.name
        info.func = function()
            UIDropDownMenu_SetText(wt.classDropDown, class.name)
            UIDropDownMenu_SetText(wt.specDropDown, "Any Spec")
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- ======================
-- Spec dropdown
-- ======================
wt.specLabel = wt.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.specLabel:SetPoint("TOPLEFT", wt.classDropDown, "BOTTOMLEFT", 15, 0)
wt.specLabel:SetText("Spec")

wt.specDropDown = CreateFrame("Frame", "MTP_SpecDropdown", wt.conditionsPanel, "UIDropDownMenuTemplate")
wt.specDropDown:SetPoint("TOPLEFT", wt.specLabel, "BOTTOMLEFT", -15, -5)
UIDropDownMenu_SetWidth(wt.specDropDown, 180)
UIDropDownMenu_SetText(wt.specDropDown, "Any Spec")
UIDropDownMenu_Initialize(wt.specDropDown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()

    -- Any spec
    info.text = "Any Spec"
    info.func = function()
        UIDropDownMenu_SetText(wt.specDropDown, "Any Spec")
    end
    UIDropDownMenu_AddButton(info)

    local classText = UIDropDownMenu_GetText(wt.classDropDown)
    if classText == "Any Class" then return end

    local classFile
    for _, class in ipairs(wt:GetAllClasses()) do
        if class.name == classText then
            classFile = class.file
            break
        end
    end
    if not classFile then return end

    for _, spec in ipairs(wt:GetSpecsForClass(classFile)) do
        info = UIDropDownMenu_CreateInfo()
        info.text = spec.name
        info.func = function()
            UIDropDownMenu_SetText(wt.specDropDown, spec.name)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

wt.textureLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.textureLabel:SetPoint("TOPLEFT", wt.anchorEdit, "BOTTOMLEFT", 0, -15)
wt.textureLabel:SetText("Texture Path")

wt.textureEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.textureEdit:SetSize(264, 20)
wt.textureEdit:SetPoint("TOPLEFT", wt.textureLabel, "BOTTOMLEFT", 0, -5)
wt.textureEdit:SetAutoFocus(false)

wt.widthLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.widthLabel:SetPoint("TOPLEFT", wt.textureEdit, "BOTTOMLEFT", 0, -20)
wt.widthLabel:SetText("Width")

wt.widthEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.widthEdit:SetSize(60, 20)
wt.widthEdit:SetPoint("TOPLEFT", wt.widthLabel, "BOTTOMLEFT", 0, -5)
wt.widthEdit:SetAutoFocus(false)
wt.widthEdit:SetNumeric(true)

wt.heightLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.heightLabel:SetPoint("TOPLEFT", wt.textureEdit, "BOTTOMLEFT", 68, -20)
wt.heightLabel:SetText("Height")

wt.heightEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.heightEdit:SetSize(60, 20)
wt.heightEdit:SetPoint("TOPLEFT", wt.heightLabel, "BOTTOMLEFT", 0, -5)
wt.heightEdit:SetAutoFocus(false)
wt.heightEdit:SetNumeric(true)

wt.xOffsetLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.xOffsetLabel:SetPoint("TOPLEFT", wt.textureEdit, "BOTTOMLEFT", 136, -20)
wt.xOffsetLabel:SetText("X Offset")

wt.xOffsetEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.xOffsetEdit:SetSize(60, 20)
wt.xOffsetEdit:SetPoint("TOPLEFT", wt.xOffsetLabel, "BOTTOMLEFT", 0, -5)
wt.xOffsetEdit:SetAutoFocus(false)

wt.yOffsetLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.yOffsetLabel:SetPoint("TOPLEFT", wt.textureEdit, "BOTTOMLEFT", 204, -20)
wt.yOffsetLabel:SetText("Y Offset")

wt.yOffsetEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.yOffsetEdit:SetSize(60, 20)
wt.yOffsetEdit:SetPoint("TOPLEFT", wt.yOffsetLabel, "BOTTOMLEFT", 0, -5)
wt.yOffsetEdit:SetAutoFocus(false)

wt.xOffsetEdit:SetScript("OnTextChanged", function(self)
    local text = self:GetText()
    if text ~= "" and not tonumber(text) then
        self:SetText(text:gsub("[^%-%d]", ""))
        self:SetCursorPosition(#self:GetText())
    end
end)

wt.yOffsetEdit:SetScript("OnTextChanged", function(self)
    local text = self:GetText()
    if text ~= "" and not tonumber(text) then
        self:SetText(text:gsub("[^%-%d]", ""))
        self:SetCursorPosition(#self:GetText())
    end
end)

-- Motion fields
wt.columnsLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.columnsLabel:SetPoint("TOPLEFT", wt.widthEdit, "BOTTOMLEFT", 0, -20)
wt.columnsLabel:SetText("Columns")
wt.columnsLabel:Hide()

wt.columnsEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.columnsEdit:SetSize(60, 20)
wt.columnsEdit:SetPoint("TOPLEFT", wt.columnsLabel, "BOTTOMLEFT", 0, -5)
wt.columnsEdit:SetAutoFocus(false)
wt.columnsEdit:SetNumeric(true)
wt.columnsEdit:Hide()

wt.rowsLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.rowsLabel:SetPoint("TOPLEFT", wt.widthEdit, "BOTTOMLEFT", 68, -20)
wt.rowsLabel:SetText("Rows")
wt.rowsLabel:Hide()

wt.rowsEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.rowsEdit:SetSize(60, 20)
wt.rowsEdit:SetPoint("TOPLEFT", wt.rowsLabel, "BOTTOMLEFT", 0, -5)
wt.rowsEdit:SetAutoFocus(false)
wt.rowsEdit:SetNumeric(true)
wt.rowsEdit:Hide()

wt.totalFramesLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.totalFramesLabel:SetPoint("TOPLEFT", wt.widthEdit, "BOTTOMLEFT", 136, -20)
wt.totalFramesLabel:SetText("Frames")
wt.totalFramesLabel:Hide()

wt.totalFramesEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.totalFramesEdit:SetSize(60, 20)
wt.totalFramesEdit:SetPoint("TOPLEFT", wt.totalFramesLabel, "BOTTOMLEFT", 0, -5)
wt.totalFramesEdit:SetAutoFocus(false)
wt.totalFramesEdit:SetNumeric(true)
wt.totalFramesEdit:Hide()

wt.fpsLabel = wt.configPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
wt.fpsLabel:SetPoint("TOPLEFT", wt.widthEdit, "BOTTOMLEFT", 204, -20)
wt.fpsLabel:SetText("FPS")
wt.fpsLabel:Hide()

wt.fpsEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.fpsEdit:SetSize(60, 20)
wt.fpsEdit:SetPoint("TOPLEFT", wt.fpsLabel, "BOTTOMLEFT", 0, -5)
wt.fpsEdit:SetAutoFocus(false)
wt.fpsEdit:SetNumeric(true)
wt.fpsEdit:Hide()



-- ======================
-- Strata dropdown
-- ======================
wt.strataLabel = wt.configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.strataLabel:SetPoint("TOPLEFT", wt.typeLabel, "TOPRIGHT", 70, 0)
wt.strataLabel:SetText("Frame Strata")

wt.strataDropDown = CreateFrame("Frame", "MTP_StrataDropdown", wt.configPanel, "UIDropDownMenuTemplate")
wt.strataDropDown:SetPoint("TOPLEFT", wt.strataLabel, "BOTTOMLEFT", -22, -5)
UIDropDownMenu_SetWidth(wt.strataDropDown, 115)
UIDropDownMenu_SetText(wt.strataDropDown, "MEDIUM")
UIDropDownMenu_Initialize(wt.strataDropDown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()

    for _, strata in ipairs(wt.frameStrataList) do
        info.text = strata
        info.func = function()
            UIDropDownMenu_SetText(wt.strataDropDown, strata)

            if wt.selectedPreset then
                local preset = WeakTexturesDB.presets[wt.selectedPreset]
                preset.strata = strata
            end
        end
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetSelectedValue(wt.strataDropDown, "MEDIUM")

wt.frameLevelLabel = wt.configPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
wt.frameLevelLabel:SetPoint("TOPLEFT", wt.selectFrameBtn, "TOPRIGHT", 9, -3)
wt.frameLevelLabel:SetText("Frame Level")

wt.frameLevelEdit = CreateFrame("EditBox", nil, wt.configPanel, "InputBoxTemplate")
wt.frameLevelEdit:SetSize(60, 20)
wt.frameLevelEdit:SetPoint("TOPLEFT", wt.frameLevelLabel, "BOTTOMLEFT", 5, -5)
wt.frameLevelEdit:SetAutoFocus(false)
wt.frameLevelEdit:SetNumeric(true)

wt.clearForm = CreateFrame("Button", nil, wt.configPanel, "UIPanelButtonTemplate")
wt.clearForm:SetSize(280, 30)
wt.clearForm:SetPoint("BOTTOMLEFT", wt.configPanel, "BOTTOMLEFT", 0, 40)
wt.clearForm:SetText("Clear")
wt.clearForm:SetScript("OnClick", function()
    wt:allDefault()
end)

wt.addTexture = CreateFrame("Button", nil, wt.configPanel, "UIPanelButtonTemplate")
wt.addTexture:SetSize(280, 40)
wt.addTexture:SetPoint("BOTTOMLEFT", wt.configPanel, "BOTTOMLEFT", 0, 0)
wt.addTexture:SetText("Create/Edit")

wt.addTexture:SetScript("OnClick", function()
    local newPresetName = strtrim(wt.presetNameEdit:GetText())
    local anchorName = wt.anchorEdit:GetText()
    local texturePath = wt.textureEdit:GetText()
    if anchorName == "" or texturePath == "" then return end

    -- Handle preset creation/renaming
    if newPresetName ~= "" and newPresetName ~= wt.selectedPreset then
        if wt.selectedPreset then
            -- Rename existing preset
            wt:RenamePreset(wt.selectedPreset, newPresetName)
            wt.selectedPreset = newPresetName
        else
            -- Create new preset
            WeakTexturesDB.presets[newPresetName] = {
                textures = {},
                group = nil
            }
            wt.selectedPreset = newPresetName
        end
        --wt.presetNameEdit:SetText("")
    end

    if not wt.selectedPreset then return end
    if not WeakTexturesDB.presets[wt.selectedPreset] then return end
    local preset = WeakTexturesDB.presets[wt.selectedPreset]

    -- Set conditions from dropdowns
    local classText = UIDropDownMenu_GetText(wt.classDropDown)
    local specText = UIDropDownMenu_GetText(wt.specDropDown)
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

    local anchor = _G[anchorName]
    if not anchor then
        wt:Debug("Anchor not found:", anchorName)
        return
    end

    
    -- Read fields
    local width  = tonumber(wt.widthEdit:GetText())
    local height = tonumber(wt.heightEdit:GetText())
    local x = tonumber(wt.xOffsetEdit:GetText())
    local y = tonumber(wt.yOffsetEdit:GetText())
    local frameLevel = tonumber(wt.frameLevelEdit:GetText()) or 100

    -- 🔥 AUTO-FILL FROM ANCHOR
    if not width or not height then
        if anchor.GetWidth and anchor.GetHeight then
            width  = width  or math.floor(anchor:GetWidth())
            height = height or math.floor(anchor:GetHeight())
        end
    end

    width  = width  or 64
    height = height or 64
    x = x or 0
    y = y or 0

    -- Update UI fields
    wt.widthEdit:SetText(width)
    wt.heightEdit:SetText(height)
    wt.xOffsetEdit:SetText(x)
    wt.yOffsetEdit:SetText(y)

    if not wt.selectedPreset then return end

    -- Save (🔥 SINGLE TEXTURE PER PRESET)
    local preset = WeakTexturesDB.presets[wt.selectedPreset]
    local groupName = strtrim(wt.groupEditBox:GetText())

    preset.enabled = wt.enabledCheck:GetChecked()

    local groupName = strtrim(wt.groupEditBox:GetText())

    if preset.enabled then
        if groupName ~= "" then
            preset.group = groupName
            WeakTexturesDB.groups[groupName] = true

            -- auto-create parents
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

    local presetType = UIDropDownMenu_GetText(wt.typeDropDown) == "Stop Motion" and "motion" or "static"
    preset.type = presetType
    if presetType == "motion" then
        preset.columns = tonumber(wt.columnsEdit:GetText()) or 1
        preset.rows = tonumber(wt.rowsEdit:GetText()) or 1
        preset.totalFrames = tonumber(wt.totalFramesEdit:GetText()) or 1
        preset.fps = tonumber(wt.fpsEdit:GetText()) or 30
    end
    preset.frameLevel = frameLevel

    preset.textures = preset.textures or {}
    preset.textures[1] = {
        anchor  = anchorName,
        texture = texturePath,
        width   = width,
        height  = height,
        x       = x,
        y       = y
    }

    -- Apply or hide
    if wt:PresetMatchesConditions(wt.selectedPreset) then
        if preset.type and preset.type == "motion" then
            wt:PlayStopMotion(wt.selectedPreset, preset.textures[1].anchor, preset.textures[1].texture, preset.textures[1].width, preset.textures[1].height, preset.textures[1].x, preset.textures[1].y, preset.columns or 1, preset.rows or 1, preset.totalFrames or 1, preset.fps or 30)
        else
            wt:CreateAnchoredTexture(
                wt.selectedPreset,
                anchorName,
                texturePath,
                width,
                height,
                x,
                y
            )
        end
    else
        wt:HideTextureFrame(wt.selectedPreset)
    end


    wt:RefreshPresetList()
end)

function wt:RefreshPresetList()
    for _, b in ipairs(wt.presetButtons) do b:Hide() end
    wipe(wt.presetButtons)

    self._renderY = 0

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

    -- Render all root groups in sorted order
    for _, name in ipairs(rootNames) do
        wt:RenderGroupNode(tree.children[name], name, 0)
    end
end

function wt:ShowMotionFields()
    wt.columnsLabel:Show()
    wt.columnsEdit:Show()
    wt.rowsLabel:Show()
    wt.rowsEdit:Show()
    wt.totalFramesLabel:Show()
    wt.totalFramesEdit:Show()
    wt.fpsLabel:Show()
    wt.fpsEdit:Show()
end

function wt:HideMotionFields()
    wt.columnsLabel:Hide()
    wt.columnsEdit:Hide()
    wt.rowsLabel:Hide()
    wt.rowsEdit:Hide()
    wt.totalFramesLabel:Hide()
    wt.totalFramesEdit:Hide()
    wt.fpsLabel:Hide()
    wt.fpsEdit:Hide()
end

-- =====================================================
-- BOTTOM PANEL
-- =====================================================

local backdrop = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
    edgeSize = 16,
	insets = { left = 4, right = 3, top = 4, bottom = 3 }
}

-- Bottom UI panel
wt.bottom = CreateFrame("Frame", nil, wt.frame, "BackdropTemplate")
wt.bottom:SetSize(780, 120)
wt.bottom:SetPoint("BOTTOMLEFT", wt.right, "BOTTOMLEFT",-10, -120)
wt.bottom:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
wt.bottom:SetBackdropColor(0,0,0,0)

-- Backdrop frame
wt.exportBoxFrame = CreateFrame("Frame", nil, wt.bottom, "BackdropTemplate")
wt.exportBoxFrame:SetSize(420, 100)
wt.exportBoxFrame:SetPoint("BOTTOMLEFT", 10, 20)
wt.exportBoxFrame:SetBackdrop(backdrop)
wt.exportBoxFrame:SetBackdropColor(0, 0, 0, 0.9)

-- Scroll frame
wt.exportScroll = CreateFrame("ScrollFrame", nil, wt.exportBoxFrame, "UIPanelScrollFrameTemplate")
wt.exportScroll:SetPoint("TOPLEFT", 4, -4)
wt.exportScroll:SetPoint("BOTTOMRIGHT", -26, 4)

-- EditBox
wt.exportBox = CreateFrame("EditBox", nil, wt.exportScroll)
wt.exportBox:SetMultiLine(true)
wt.exportBox:SetMaxLetters(0)
wt.exportBox:SetFontObject(ChatFontNormal)
wt.exportBox:SetWidth(560)
wt.exportBox:SetHeight(60)
wt.exportBox:SetAutoFocus(false)
wt.exportBox:SetJustifyH("LEFT")
wt.exportBox:SetJustifyV("TOP")

wt.exportScroll:SetScrollChild(wt.exportBox)

-- Mouse wheel scrolling
wt.exportScroll:EnableMouseWheel(true)
wt.exportScroll:SetScript("OnMouseWheel", function(self, delta)
    local cur = self:GetVerticalScroll()
    local max = self:GetVerticalScrollRange()
    if delta < 0 then
        self:SetVerticalScroll(math.min(cur + 20, max))
    else
        self:SetVerticalScroll(math.max(cur - 20, 0))
    end
end)

wt.exportBtn = CreateFrame("Button", nil, wt.bottom, "UIPanelButtonTemplate")
wt.exportBtn:SetSize(100, 22)
wt.exportBtn:SetPoint("TOPLEFT", wt.bottom, "TOPLEFT", 430, 0)
wt.exportBtn:SetText("Export All")

wt.exportBtn:SetScript("OnClick", function()
    wt:Export()
end)

wt.importBtn = CreateFrame("Button", nil, wt.bottom, "UIPanelButtonTemplate")
wt.importBtn:SetSize(100, 22)
wt.importBtn:SetPoint("TOPLEFT", wt.exportBtn, "BOTTOMLEFT", 0, -5)
wt.importBtn:SetText("Import All")

wt.importBtn:SetScript("OnClick", function()
    wt:Import()
end)