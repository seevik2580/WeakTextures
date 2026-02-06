-- =====================================================
-- WeakTextures UI
-- =====================================================

local _, wt = ...

-- Initialize UI constants
function wt:InitializeUIConstants()
    local L = wt.L
    wt.frameWidth = 705
    wt.frameHeight = 504
    wt.inset = 30
    wt.PANELOFFSET_Y = -20
    wt.PANELTABOFFSET_Y = 5
    wt.smallEditBoxWidth = 58.5
    wt.conditionCheckboxSpacing = 90
    
    wt.multiLineEditBoxBackdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }

    wt.buttonNormal = "128-RedButton-UP"
    wt.buttonHighlight = "128-RedButton-VisibilityOn-Highlight"
    wt.buttonPushed = "128-RedButton-Pressed"
    wt.buttonDisabled = "128-RedButton-Disable"
end

function wt:CreateHeader(parent, text)
        local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        header:SetText(text)
        header:SetTextColor(0.5, 1, 0.5)
        return header
    end

function wt:CreateButton(parent, width, height, normalAtlas, highlightAtlas, pushedAtlas, text)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)
    btn:SetNormalAtlas(normalAtlas)
    btn:SetHighlightAtlas(highlightAtlas)
    btn:SetPushedAtlas(pushedAtlas)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)

    self:ApplyCustomFont(btn.text, 11)

    return btn
end

function wt:CreateEditBox(parent, width, height, instructionsText)
    local editBox = CreateFrame("EditBox", nil, parent, "SearchBoxTemplate")
    editBox:SetSize(width, height or 20)
    
    if editBox.Left then
        editBox.Left:SetHeight((height or 20) + 5)
    end
    if editBox.Right then
        editBox.Right:SetHeight((height or 20) + 5)
    end
    if editBox.Middle then
        editBox.Middle:SetHeight((height or 20) + 5)
    end
    
    editBox:SetAutoFocus(false)
    editBox.Instructions:SetText(instructionsText or "")
    editBox.Instructions:SetPoint("TOPLEFT", 1, 0)
    wt:ApplyCustomFont(editBox.Instructions, 11)
    editBox.searchIcon:Hide()
    editBox:SetTextInsets(1, 0, 0, 0)
    
    return editBox
end

function wt:CreateDropdown(parent, name, width, defaultText, defaultValue)
    local dropdown = CreateFrame("DropdownButton", name, parent, "WowStyle1DropdownTemplate")
    dropdown:SetWidth(width or 160)
    if defaultText then
        dropdown:SetDefaultText(defaultText)
    end
    dropdown.selectedValue = defaultValue or ""
    return dropdown
end

function wt:CreateColorPicker(parent, labelText, r, g, b, a)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(120, 20)
    
    -- Color swatch button
    local swatch = CreateFrame("Button", nil, container)
    swatch:SetSize(20, 20)
    swatch:SetPoint("LEFT")
    
    -- Background (border)
    local bg = swatch:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 1)
    bg:SetAllPoints()
    
    -- Color display
    local color = swatch:CreateTexture(nil, "ARTWORK")
    color:SetColorTexture(r or 1, g or 1, b or 1, a or 1)
    color:SetPoint("TOPLEFT", 2, -2)
    color:SetPoint("BOTTOMRIGHT", -2, 2)
    
    -- Store current color
    swatch.r = r or 1
    swatch.g = g or 1
    swatch.b = b or 1
    swatch.a = a or 1
    
    -- Label
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    label:SetText(labelText or "Color")
    
    -- Click to open color picker
    swatch:SetScript("OnClick", function(self)
        local function OnColorChanged()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            local newA = ColorPickerFrame:GetColorAlpha()
            color:SetColorTexture(newR, newG, newB, newA)
            self.r = newR
            self.g = newG
            self.b = newB
            self.a = newA
        end
        
        local function OnCancel()
            local oldR, oldG, oldB, oldA = ColorPickerFrame:GetPreviousValues()
            color:SetColorTexture(oldR, oldG, oldB, oldA)
            self.r = oldR
            self.g = oldG
            self.b = oldB
            self.a = oldA
        end
        
        local options = {
            swatchFunc = OnColorChanged,
            opacityFunc = OnColorChanged,
            cancelFunc = OnCancel,
            hasOpacity = true,
            opacity = self.a,
            r = self.r,
            g = self.g,
            b = self.b,
        }
        
        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)
    
    -- Method to get current color
    function container:GetColor()
        return swatch.r, swatch.g, swatch.b, swatch.a
    end
    
    -- Method to set color programmatically
    function container:SetColor(r, g, b, a)
        swatch.r = r or 1
        swatch.g = g or 1
        swatch.b = b or 1
        swatch.a = a or 1
        color:SetColorTexture(swatch.r, swatch.g, swatch.b, swatch.a)
    end
    
    container.swatch = swatch
    container.label = label
    
    return container
end

function wt:CreateUI()
    local L = wt.L
    self:InitializeUIConstants()

    wt.rightTabs = {}
    wt.rightPanels = wt.rightPanels or {}

    wt.frame = CreateFrame("Frame", "WeakTextures_MainFrame", UIParent, "BackdropTemplate")
    wt.frame:SetSize(wt.frameWidth, wt.frameHeight)
    wt.frame:SetPoint("CENTER")
    wt.frame:SetMovable(true)
    wt.frame:SetFrameStrata("HIGH")
    wt.frame:Hide()

    wt.frame.left = CreateFrame("Frame", nil, wt.frame, nil)
    wt.frame.left:SetPoint("TOPLEFT", wt.frame, 12, -50)
    wt.frame.left:SetPoint("BOTTOMLEFT", wt.frame, 6, 9)
    wt.frame.left:SetWidth(250)
    wt.frame.left.Background = wt.frame.left:CreateTexture(nil, "BACKGROUND")
    wt.frame.left.Background:SetAllPoints()
    NineSliceUtil.ApplyLayoutByName(wt.frame.left, "InsetFrameTemplate")

    wt.frame.left:EnableMouse(true)
    wt.frame.left:RegisterForDrag("LeftButton")
    wt.frame.left:SetScript("OnDragStart", function(self) wt:OnFrameDragStart() end)
    wt.frame.left:SetScript("OnDragStop", function(self) wt:OnFrameDragStop() end)

    wt.frame.left.settingsBtn = wt:CreateButton(wt.frame.left, 120, 29, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_SETTINGS)
    wt.frame.left.settingsBtn:SetPoint("TOPRIGHT", wt.frame.left, "TOPRIGHT", -5, -22)
    wt.frame.left.settingsBtn:SetScript("OnClick", function() wt:OpenSettings() end)

    wt.frame.left.profilesDropDown = wt:CreateDropdown(wt.frame.left.settingsBtn, "MTP_ProfilesDropdown", 114, wt:GetActiveProfile(), wt:GetActiveProfile())
    wt.frame.left.profilesDropDown:SetPoint("LEFT", wt.frame.left.settingsBtn, "LEFT", -116, 0)
    wt.frame.left.profilesDropDown:SetupMenu(function(dropdown, rootDescription)
        for _, profile in pairs(wt:GetAllProfiles()) do
            rootDescription:CreateRadio(profile, function() return dropdown.selectedValue == profile end, function()
                dropdown.selectedValue = profile
                wt:LoadProfile(profile)
            end)
        end 

    end)

    -- Main preset scrollbox
    wt.frame.left.scrollBox = CreateFrame("Frame", nil, wt.frame.left, "WowScrollBoxList")
    wt.frame.left.scrollBox:SetPoint("TOPLEFT", 5, -50)
    wt.frame.left.scrollBox:SetPoint("BOTTOMRIGHT", -19, 70)

    wt.frame.left.scrollBar = CreateFrame("EventFrame", nil, wt.frame.left, "MinimalScrollBar")
    wt.frame.left.scrollBar:SetPoint("TOPLEFT", wt.frame.left.scrollBox, "TOPRIGHT", 3, 0)
    wt.frame.left.scrollBar:SetPoint("BOTTOMLEFT", wt.frame.left.scrollBox, "BOTTOMRIGHT", 0, 0)
    wt.frame.left.scrollBar:SetScale(0.65)
    wt.frame.left.scrollBar:SetHideIfUnscrollable(true)

    wt.frame.left.dataProvider = CreateTreeDataProvider()
    wt.frame.left.scrollView = CreateScrollBoxListTreeListView()

    wt.frame.left.scrollView:SetElementInitializer("Button", function(button, node)
        wt:InitializeTreeElement(button, node)
    end)
    wt.frame.left.scrollView:SetElementExtent(22)
    wt.frame.left.scrollView:SetDataProvider(wt.frame.left.dataProvider)
    ScrollUtil.InitScrollBoxListWithScrollBar(wt.frame.left.scrollBox, wt.frame.left.scrollBar, wt.frame.left.scrollView)

    wt.frame.left.scroll = {}
    wt.frame.left.scroll.content = wt.frame.left.scrollBox

    -- Filter panel (overlay over preset list, hidden by default)
    wt.frame.left.filterPanel = CreateFrame("Frame", nil, wt.frame.left, "BackdropTemplate")
    wt.frame.left.filterPanel:SetPoint("TOPLEFT", wt.frame.left.scrollBox, "TOPLEFT", 0, 0)
    wt.frame.left.filterPanel:SetPoint("BOTTOMRIGHT", wt.frame.left.scrollBox, "BOTTOMRIGHT", 14, 0)
    wt.frame.left.filterPanel:SetFrameLevel(wt.frame.left.scrollBox:GetFrameLevel() + 10)
    wt.frame.left.filterPanel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    wt.frame.left.filterPanel:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    wt.frame.left.filterPanel:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    wt.frame.left.filterPanel:Hide()

    -- Filter content frame (simple scrollable frame)
    wt.frame.left.filterScrollFrame = CreateFrame("ScrollFrame", nil, wt.frame.left.filterPanel)
    wt.frame.left.filterScrollFrame:SetPoint("TOPLEFT", 8, -8)
    wt.frame.left.filterScrollFrame:SetPoint("BOTTOMRIGHT", -18, 8)
    wt.frame.left.filterScrollFrame:EnableMouse(false)

    wt.frame.left.filterScrollBar = CreateFrame("Slider", nil, wt.frame.left.filterPanel, "MinimalScrollBar")
    wt.frame.left.filterScrollBar:SetPoint("TOPLEFT", wt.frame.left.filterScrollFrame, "TOPRIGHT", 0, 0)
    wt.frame.left.filterScrollBar:SetPoint("BOTTOMLEFT", wt.frame.left.filterScrollFrame, "BOTTOMRIGHT", 0, 0)
    wt.frame.left.filterScrollBar:SetScale(0.75)

    wt.frame.left.filterContent = CreateFrame("Frame", nil, wt.frame.left.filterScrollFrame)
    wt.frame.left.filterContent:SetSize(210, 1)
    wt.frame.left.filterScrollFrame:SetScrollChild(wt.frame.left.filterContent)

    -- Setup scroll bar
    wt.frame.left.filterScrollBar:SetMinMaxValues(0, 1)
    wt.frame.left.filterScrollBar:SetValue(0)
    wt.frame.left.filterScrollBar:SetValueStep(0.1)
    wt.frame.left.filterScrollBar:SetObeyStepOnDrag(true)
    wt.frame.left.filterScrollBar:SetScript("OnValueChanged", function(self, value)
        local scrollFrame = wt.frame.left.filterScrollFrame
        local range = scrollFrame:GetVerticalScrollRange()
        scrollFrame:SetVerticalScroll(value * range)
    end)

    -- Mouse wheel scrolling
    wt.frame.left.filterScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local scrollBar = wt.frame.left.filterScrollBar
        local current = scrollBar:GetValue()
        local min, max = scrollBar:GetMinMaxValues()
        local step = scrollBar:GetValueStep()
        
        if delta < 0 and current < max then
            scrollBar:SetValue(math.min(current + step, max))
        elseif delta > 0 and current > min then
            scrollBar:SetValue(math.max(current - step, min))
        end
    end)

    wt.frame.left.topTitleBar = wt.frame.left:CreateTexture(nil, "ARTWORK")
    wt.frame.left.topTitleBar:SetSize(260, 60)
    wt.frame.left.topTitleBar:SetPoint("TOPLEFT", wt.frame.left, "TOPLEFT", -3, 28)
    wt.frame.left.topTitleBar:SetAtlas("ui-frame-midnight-ribbon")
    wt.frame.left.topTitleBarText = wt.frame.left:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wt.frame.left.topTitleBarText:SetPoint("CENTER", wt.frame.left.topTitleBar, "CENTER", 0, 0)
    wt.frame.left.topTitleBarText:SetText(L.ADDON_NAME)
    wt:ApplyCustomFont(wt.frame.left.topTitleBarText, 16, "", true)

    wt.frame.left.topTitleBartopTexture = wt.frame.left:CreateTexture(nil, "ARTWORK")
    wt.frame.left.topTitleBartopTexture:SetSize(260, 71)
    wt.frame.left.topTitleBartopTexture:SetPoint("TOPLEFT", wt.frame.left.topTitleBar, "TOPLEFT", 0, 28)
    wt.frame.left.topTitleBartopTexture:SetAtlas("jailerstower-score-topper")
    wt.frame.left.topTitleBartopTexture:SetDrawLayer("ARTWORK", 1)

    wt.frame.left.closeButton = wt:CreateButton(wt.frame.left, 20, 20, '128-RedButton-Exit', '128-redbutton-exit-highlight', '128-RedButton-Exit-Pressed', nil)
    wt.frame.left.closeButton:SetPoint("TOPRIGHT", wt.frame.left, "TOPRIGHT", -35, 7)
    wt.frame.left.closeButton:SetScript("OnClick", function() wt:ToggleUI() end)

    wt.frame.left.bottomTexture = wt.frame.left:CreateTexture(nil, "ARTWORK")
    wt.frame.left.bottomTexture:SetSize(260, 71)
    wt.frame.left.bottomTexture:SetPoint("BOTTOMLEFT", wt.frame.left, "BOTTOMLEFT", 0, -35)
    wt.frame.left.bottomTexture:SetAtlas("jailerstower-score-footer")

    -- Filter button
    wt.frame.left.filterButton = wt:CreateButton(wt.frame.left, 60, 22, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_FILTER)
    wt.frame.left.filterButton:SetPoint("BOTTOMLEFT", wt.frame.left, "BOTTOMLEFT", 7, 38)
    wt.frame.left.filterButton:SetScript("OnClick", function() wt:ToggleFilterPanel() end)

    -- Search box
    wt.frame.left.searchBox = CreateFrame("EditBox", nil, wt.frame.left, "SearchBoxTemplate")
    wt.frame.left.searchBox:SetPoint("LEFT", wt.frame.left.filterButton, "RIGHT", 8, 0)
    wt.frame.left.searchBox:SetPoint("BOTTOMRIGHT", wt.frame.left, "BOTTOMRIGHT", -8, 38)
    wt.frame.left.searchBox:SetHeight(24)
    wt.frame.left.searchBox:SetAutoFocus(false)
    wt.frame.left.searchBox.Instructions:SetText(L.PLACEHOLDER_SEARCH)
    wt:ApplyCustomFont(wt.frame.left.searchBox.Instructions, 11)
    wt.frame.left.searchBox:HookScript("OnTextChanged", function(self)
        wt:OnSearchTextChanged(self:GetText())
    end)

    wt.frame.left.addTexture = wt:CreateButton(wt.frame.left, 120, 30, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_CREATE_NEW)
    wt.frame.left.addTexture:SetPoint("BOTTOMLEFT", wt.frame.left, "BOTTOM", 0, 5)
    wt.frame.left.addTexture:SetScript("OnClick", function()
        wt:allDefault()
        wt.frame.right:EnableMouse(true)
        wt.frame.right:Show()
        wt:ShowRightTab("display")
    end)

    wt.frame.left.importButton = wt:CreateButton(wt.frame.left, 120, 30, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_IMPORT)
    wt.frame.left.importButton:SetPoint("BOTTOMRIGHT", wt.frame.left, "BOTTOM", 0, 5)
    wt.frame.left.importButton:SetScript("OnClick", function() wt:OnImportButtonClick() end)

    wt.frame.right = CreateFrame("Frame", nil, wt.frame, nil)
    wt.frame.right:SetPoint("TOPLEFT", wt.frame.left, "TOPRIGHT", 4, 0)
    wt.frame.right:SetPoint("BOTTOMRIGHT", wt.frame, -6, 9)
    wt.frame.right.Background = wt.frame.right:CreateTexture(nil, "BACKGROUND")
    wt.frame.right.Background:SetAtlas("GarrMissionLocation-Maw-bg-02")
    wt.frame.right.Background:SetDrawLayer("BACKGROUND", 0)
    wt.frame.right.Background:SetAllPoints()
    NineSliceUtil.ApplyLayoutByName(wt.frame.right, "InsetFrameTemplate")

    wt.frame.right:EnableMouse(true)
    wt.frame.right:RegisterForDrag("LeftButton")
    wt.frame.right:SetScript("OnShow", function(self) wt:OnRightPanelShow(self) end)
    wt.frame.right:SetScript("OnDragStart", function(self) wt:OnFrameDragStart() end)
    wt.frame.right:SetScript("OnDragStop", function(self) wt:OnFrameDragStop() end)

    wt.frame.right.resetButton = wt:CreateButton(wt.frame.right, 120, 30, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_CLOSE)
    wt.frame.right.resetButton:SetPoint("BOTTOMLEFT", wt.frame.right, "BOTTOMLEFT", 5, 5)
    wt.frame.right.resetButton:SetScript("OnClick", function() wt:allDefault() end)

    wt.frame.right.unlockFrameBtn = wt:CreateButton(wt.frame.right, 120, 30, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_UNLOCK_POSITION)
    wt.frame.right.unlockFrameBtn:SetPoint("BOTTOM", wt.frame.right, "BOTTOM", 0, 5)
    wt.frame.right.unlockFrameBtn:SetScript("OnClick", function() wt:OnLockOrUnlockTextureToDrag() end)

    wt.frame.right.editPresetButton = wt:CreateButton(wt.frame.right, 120, 30, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_SAVE_CHANGES)
    wt.frame.right.editPresetButton:SetPoint("BOTTOMRIGHT", wt.frame.right, "BOTTOMRIGHT", -5, 5)
    wt.frame.right.editPresetButton:SetScript("OnClick", function() wt:OnAddTextureClick() end)

    PanelTemplates_SetNumTabs(wt.frame.right, 0)
    wt.frame.right.selectedTab = 1

        wt:createRightTab("display", L.TAB_DISPLAY, 15)
        wt:createRightTab("loadcondition", L.TAB_LOAD_CONDITIONS, 125)
        wt:createRightTab("advanced", L.TAB_ADVANCED, -15, "TOPRIGHT")

    PanelTemplates_SetNumTabs(wt.frame.right, #wt.rightTabs)

    -- Hide advanced tab initially
    for _, tab in ipairs(wt.rightTabs) do
        if tab.tabKey == "advanced" then
            tab:Hide()
            break
        end
    end

    -- Config Panel with Scrolling
    wt.frame.right.configPanel = CreateFrame("Frame", nil, wt.frame.right, nil)
    wt.frame.right.configPanel:SetSize(420, 380)
    wt.frame.right.configPanel:SetPoint("TOPLEFT", 10, wt.PANELOFFSET_Y)

    -- Scroll Frame for config panel
    wt.frame.right.configPanelScrollFrame = CreateFrame("ScrollFrame", nil, wt.frame.right.configPanel)
    wt.frame.right.configPanelScrollFrame:SetPoint("TOPLEFT", 0, 0)
    wt.frame.right.configPanelScrollFrame:SetPoint("BOTTOMRIGHT", -12, 0)
    wt.frame.right.configPanelScrollFrame:EnableMouse(false)
    wt.frame.right.configPanelScrollFrame:EnableMouseWheel(true)

    -- Scroll Bar for config panel
    wt.frame.right.configPanelScrollBar = CreateFrame("EventFrame", nil, wt.frame.right.configPanel, "MinimalScrollBar")
    wt.frame.right.configPanelScrollBar:SetPoint("TOPLEFT", wt.frame.right.configPanelScrollFrame, "TOPRIGHT", 2, 0)
    wt.frame.right.configPanelScrollBar:SetPoint("BOTTOMLEFT", wt.frame.right.configPanelScrollFrame, "BOTTOMRIGHT", 2, 0)
    wt.frame.right.configPanelScrollBar:SetScale(0.65)
    wt.frame.right.configPanelScrollBar:SetHideIfUnscrollable(true)

    -- Scroll Content (child) - large height for all UI elements
    wt.frame.right.configPanelContent = CreateFrame("Frame", nil, wt.frame.right.configPanelScrollFrame)
    wt.frame.right.configPanelContent:SetSize(390, 650)
    wt.frame.right.configPanelScrollFrame:SetScrollChild(wt.frame.right.configPanelContent)

    ScrollUtil.InitScrollFrameWithScrollBar(wt.frame.right.configPanelScrollFrame, wt.frame.right.configPanelScrollBar)
    
    wt.frame.right.configPanelScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local scrollBar = wt.frame.right.configPanelScrollBar
        if scrollBar:IsVisible() then
            local currentScroll = scrollBar:GetScrollPercentage() or 0
            local step = wt.scrollSteps
            scrollBar:SetScrollPercentage(currentScroll - (delta * step))
        end
    end)

    -- Use configPanelContent for all child UI elements
    local content = wt.frame.right.configPanelContent

    -- === BASIC INFORMATION ===
    content.basicHeader = wt:CreateHeader(content, L.HEADER_BASIC_INFO)
    content.basicHeader:SetPoint("TOPLEFT", 5, 0)

    -- Basic Info
    content.presetNameEdit = wt:CreateEditBox(content, 220, nil, L.PLACEHOLDER_PRESET_NAME)
    content.presetNameEdit:SetPoint("TOPLEFT", content.basicHeader, "BOTTOMLEFT", 5, -24)
    --content.presetNameEdit.Instructions:SetPoint("TOPLEFT", 1, 0)

    content.presetNameLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.presetNameLabel:SetPoint("BOTTOMLEFT", content.presetNameEdit, "TOPLEFT", -5, 3)
    content.presetNameLabel:SetText(L.LABEL_PRESET_NAME)

    content.groupDropDown = wt:CreateDropdown(content, "WT_GroupDropdown", 160, L.DROPDOWN_NO_GROUP, "")
    content.groupDropDown:SetPoint("LEFT", content.presetNameEdit, "RIGHT", 10, 0)
    content.groupDropDown:SetupMenu(function(dropdown, rootDescription)
        -- Ungrouped option
        rootDescription:CreateRadio(L.STATUS_UNGROUPED, function() return dropdown.selectedValue == "" end, function()
            dropdown.selectedValue = ""
            content.groupEditBox:Hide()
        end)
        
        -- option: Create new group
        rootDescription:CreateRadio(L.DROPDOWN_CREATE_NEW_GROUP, function() return dropdown.selectedValue == "__CREATE_NEW__" end, function()
            dropdown.selectedValue = "__CREATE_NEW__"
            content.groupEditBox:Show()
            content.groupEditBox:SetFocus()
        end)
        

        -- List all existing groups
        local groups = {}
        for groupPath in pairs(WeakTexturesDB.groups) do
            if groupPath ~= "Disabled" then
                table.insert(groups, groupPath)
            end
        end
        table.sort(groups)
        
        for _, groupPath in ipairs(groups) do
            rootDescription:CreateRadio(groupPath, function() return dropdown.selectedValue == groupPath end, function()
                dropdown.selectedValue = groupPath
                content.groupEditBox:Hide()
            end)
        end
    end)

    content.groupEditLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.groupEditLabel:SetPoint("BOTTOMLEFT", content.groupDropDown, "TOPLEFT", 0, 3)
    content.groupEditLabel:SetText(L.LABEL_GROUP)

    -- EditBox for creating new group (hidden by default)
    content.groupEditBox = wt:CreateEditBox(content, 155, nil, L.PLACEHOLDER_GROUP_NAME)
    content.groupEditBox:SetPoint("TOP", content.groupDropDown, "BOTTOM", 3, -5)
    content.groupEditBox:Hide()

    -- === TEXTURE AND FRAME SETTINGS ===
    content.frameHeader = wt:CreateHeader(content, L.HEADER_TEXTURE_FRAME)
    content.frameHeader:SetPoint("TOPLEFT", content.presetNameEdit, "BOTTOMLEFT", -5, -12)

    -- Texture Dropdown
    content.textureDropDown = wt:CreateDropdown(content, "WT_TextureDropdown", 394.5, "Custom", "Custom")
    content.textureDropDown:SetPoint("TOPLEFT", content.frameHeader, "BOTTOMLEFT", 0, -24)
    content.textureDropDown.selectedPath = nil
    content.textureDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetScrollMode(450)  -- Enable scrolling with max height
        
        -- Custom option
        rootDescription:CreateRadio("Custom", function() return dropdown.selectedValue == "Custom" end, function()
            dropdown.selectedValue = "Custom"
            dropdown.selectedPath = nil
            
            -- If editing existing preset, populate with current texture path
            if wt.selectedPreset then
                local preset = WeakTexturesDB.presets[wt.selectedPreset]
                if preset and preset.texture then
                    content.textureCustomEdit:SetText(preset.texture)
                else
                    content.textureCustomEdit:SetText("")
                end
            else
                -- New preset - leave empty
                content.textureCustomEdit:SetText("")
            end
            
            content.textureCustomEdit:Show()
        end)
        
        -- Show registered custom textures
        if WeakTexturesCustomTextures and next(WeakTexturesCustomTextures) then
            rootDescription:CreateDivider()
            local customHeader = rootDescription:CreateButton("=== MY CUSTOM TEXTURES ===")
            customHeader:SetEnabled(false)
            
            -- Sort custom textures by name
            local customNames = {}
            for name in pairs(WeakTexturesCustomTextures) do
                table.insert(customNames, name)
            end
            table.sort(customNames)
            
            for _, textureName in ipairs(customNames) do
                local texturePath = WeakTexturesCustomTextures[textureName]
                local displayName = textureName:gsub("^WT_", "")  -- Remove WT_ prefix for display
                local radio = rootDescription:CreateRadio(displayName, function() return dropdown.selectedValue == displayName end, function()
                    dropdown.selectedValue = displayName
                    dropdown.selectedPath = texturePath
                    content.textureCustomEdit:Hide()
                end)
                radio:SetTooltip(function(tooltip)
                    tooltip:SetText(displayName)
                    tooltip:AddLine(" ")
                    if not tooltip.texturePreview then
                        -- Create backdrop frame
                        tooltip.texturePreviewFrame = CreateFrame("Frame", nil, tooltip, "BackdropTemplate")
                        tooltip.texturePreviewFrame:SetSize(136, 136)
                        tooltip.texturePreviewFrame:SetPoint("TOP", tooltip, "BOTTOM", 0, -5)
                        tooltip.texturePreviewFrame:SetBackdrop({
                            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                            tile = true,
                            tileSize = 16,
                            edgeSize = 16,
                            insets = { left = 4, right = 4, top = 4, bottom = 4 }
                        })
                        tooltip.texturePreviewFrame:SetBackdropColor(0, 0, 0, 0.9)
                        tooltip.texturePreviewFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
                        
                        tooltip.texturePreview = tooltip.texturePreviewFrame:CreateTexture(nil, "ARTWORK")
                        tooltip.texturePreview:SetSize(128, 128)
                        tooltip.texturePreview:SetPoint("CENTER")
                        
                        tooltip:HookScript("OnHide", function(self)
                            if self.texturePreviewFrame then
                                self.texturePreviewFrame:Hide()
                            end
                        end)
                    end
                    tooltip.texturePreview:SetTexture(texturePath)
                    tooltip.texturePreviewFrame:Show()
                    tooltip:Show()
                end)
            end
        end
        
        rootDescription:CreateDivider()
        
        -- Background textures
        local backgrounds = wt.LSM:List("background")
        if #backgrounds > 0 then
            local bgButton = rootDescription:CreateButton("=== BACKGROUNDS ===")
            bgButton:SetEnabled(false)
            
            for _, textureName in ipairs(backgrounds) do
                if textureName ~= "None" and not string.find(textureName, "^WT_") then
                    local texturePath = wt.LSM:Fetch("background", textureName)
                    local radio = rootDescription:CreateRadio(textureName, function() return dropdown.selectedValue == textureName end, function()
                        dropdown.selectedValue = textureName
                        dropdown.selectedPath = texturePath
                        content.textureCustomEdit:Hide()
                    end)
                radio:SetTooltip(function(tooltip)
                    tooltip:SetText(textureName)
                    tooltip:AddLine(" ")
                    -- Add texture preview
                    if not tooltip.texturePreview then
                        -- Create backdrop frame
                        tooltip.texturePreviewFrame = CreateFrame("Frame", nil, tooltip, "BackdropTemplate")
                        tooltip.texturePreviewFrame:SetSize(136, 136)
                        tooltip.texturePreviewFrame:SetPoint("TOP", tooltip, "BOTTOM", 0, -5)
                        tooltip.texturePreviewFrame:SetBackdrop({
                            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                            tile = true,
                            tileSize = 16,
                            edgeSize = 16,
                            insets = { left = 4, right = 4, top = 4, bottom = 4 }
                        })
                        tooltip.texturePreviewFrame:SetBackdropColor(0, 0, 0, 0.9)
                        tooltip.texturePreviewFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
                        
                        tooltip.texturePreview = tooltip.texturePreviewFrame:CreateTexture(nil, "ARTWORK")
                        tooltip.texturePreview:SetSize(128, 128)
                        tooltip.texturePreview:SetPoint("CENTER")
                        
                        tooltip:HookScript("OnHide", function(self)
                            if self.texturePreviewFrame then
                                self.texturePreviewFrame:Hide()
                            end
                        end)
                    end
                    tooltip.texturePreview:SetTexture(texturePath)
                    tooltip.texturePreviewFrame:Show()
                    tooltip:Show()
                end)
                end
            end
        end
        
        -- Border textures
        local borders = wt.LSM:List("border")
        if #borders > 0 then
            rootDescription:CreateDivider()
            local borderButton = rootDescription:CreateButton("=== BORDERS ===")
            borderButton:SetEnabled(false)
            
            for _, textureName in ipairs(borders) do
                if textureName ~= "None" then
                    local texturePath = wt.LSM:Fetch("border", textureName)
                    local radio = rootDescription:CreateRadio(textureName, function() return dropdown.selectedValue == textureName end, function()
                        dropdown.selectedValue = textureName
                        dropdown.selectedPath = texturePath
                        content.textureCustomEdit:Hide()
                    end)
                radio:SetTooltip(function(tooltip)
                    tooltip:SetText(textureName)
                    tooltip:AddLine(" ")
                    if not tooltip.texturePreview then
                        -- Create backdrop frame
                        tooltip.texturePreviewFrame = CreateFrame("Frame", nil, tooltip, "BackdropTemplate")
                        tooltip.texturePreviewFrame:SetSize(136, 136)
                        tooltip.texturePreviewFrame:SetPoint("TOP", tooltip, "BOTTOM", 0, -5)
                        tooltip.texturePreviewFrame:SetBackdrop({
                            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                            tile = true,
                            tileSize = 16,
                            edgeSize = 16,
                            insets = { left = 4, right = 4, top = 4, bottom = 4 }
                        })
                        tooltip.texturePreviewFrame:SetBackdropColor(0, 0, 0, 0.9)
                        tooltip.texturePreviewFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
                        
                        tooltip.texturePreview = tooltip.texturePreviewFrame:CreateTexture(nil, "ARTWORK")
                        tooltip.texturePreview:SetSize(128, 128)
                        tooltip.texturePreview:SetPoint("CENTER")
                        
                        tooltip:HookScript("OnHide", function(self)
                            if self.texturePreviewFrame then
                                self.texturePreviewFrame:Hide()
                            end
                        end)
                    end
                    tooltip.texturePreview:SetTexture(texturePath)
                    tooltip.texturePreviewFrame:Show()
                    tooltip:Show()
                end)
                end
            end
        end
        
        -- Statusbar textures
        local statusbars = wt.LSM:List("statusbar")
        if #statusbars > 0 then
            rootDescription:CreateDivider()
            local sbButton = rootDescription:CreateButton("=== STATUSBARS ===")
            sbButton:SetEnabled(false)
            
            for _, textureName in ipairs(statusbars) do
                if textureName ~= "None" then
                    local texturePath = wt.LSM:Fetch("statusbar", textureName)
                    local radio = rootDescription:CreateRadio(textureName, function() return dropdown.selectedValue == textureName end, function()
                        dropdown.selectedValue = textureName
                        dropdown.selectedPath = texturePath
                        content.textureCustomEdit:Hide()
                    end)
                radio:SetTooltip(function(tooltip)
                    tooltip:SetText(textureName)
                    tooltip:AddLine(" ")
                    if not tooltip.texturePreview then
                        -- Create backdrop frame
                        tooltip.texturePreviewFrame = CreateFrame("Frame", nil, tooltip, "BackdropTemplate")
                        tooltip.texturePreviewFrame:SetSize(136, 136)
                        tooltip.texturePreviewFrame:SetPoint("TOP", tooltip, "BOTTOM", 0, -5)
                        tooltip.texturePreviewFrame:SetBackdrop({
                            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                            tile = true,
                            tileSize = 16,
                            edgeSize = 16,
                            insets = { left = 4, right = 4, top = 4, bottom = 4 }
                        })
                        tooltip.texturePreviewFrame:SetBackdropColor(0, 0, 0, 0.9)
                        tooltip.texturePreviewFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
                        
                        tooltip.texturePreview = tooltip.texturePreviewFrame:CreateTexture(nil, "ARTWORK")
                        tooltip.texturePreview:SetSize(128, 128)
                        tooltip.texturePreview:SetPoint("CENTER")
                        
                        tooltip:HookScript("OnHide", function(self)
                            if self.texturePreviewFrame then
                                self.texturePreviewFrame:Hide()
                            end
                        end)
                    end
                    tooltip.texturePreview:SetTexture(texturePath)
                    tooltip.texturePreviewFrame:Show()
                    tooltip:Show()
                end)
                end
            end
        end
    end)

    content.textureLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.textureLabel:SetPoint("BOTTOMLEFT", content.textureDropDown, "TOPLEFT", 0, 3)
    content.textureLabel:SetText(L.LABEL_TEXTURE_PATH)

    -- Custom texture path EditBox (shown when "Custom" is selected)
    content.textureCustomEdit = wt:CreateEditBox(content, 390, nil, L.PLACEHOLDER_TEXTURE_PATH .. "e.g. Interface\\AddOns\\MyAddon\\Textures\\MyTexture.tga")
    content.textureCustomEdit:SetPoint("TOPLEFT", content.textureDropDown, "BOTTOMLEFT", 5, -5)

    -- Frame Type & Strata
    content.ftypeDropDown = wt:CreateDropdown(content, "WT_TypeDropdown", 155, L.TYPE_STATIC, "Static")
    content.ftypeDropDown:SetPoint("TOPLEFT", content.textureCustomEdit, "BOTTOMLEFT", -5, -24)
    content.ftypeDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(L.TYPE_STATIC, function() return dropdown.selectedValue == "Static" end, function()
            dropdown.selectedValue = "Static"
            wt:SetShownMotionFields(false)
        end)
        rootDescription:CreateRadio(L.TYPE_STOP_MOTION, function() return dropdown.selectedValue == "Stop Motion" end, function()
            dropdown.selectedValue = "Stop Motion"
            wt:SetShownMotionFields(true)
        end)
    end)

    content.frametypeLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.frametypeLabel:SetPoint("BOTTOMLEFT", content.ftypeDropDown, "TOPLEFT", 0, 3)
    content.frametypeLabel:SetText(L.LABEL_TYPE)

    content.strataDropDown = wt:CreateDropdown(content, "MTP_StrataDropdown", 169, "MEDIUM", "MEDIUM")
    content.strataDropDown:SetPoint("LEFT", content.ftypeDropDown, "RIGHT", 8, 0)
    content.strataDropDown:SetupMenu(function(dropdown, rootDescription)
        for _, strata in ipairs(wt.frameStrataList) do
            rootDescription:CreateRadio(strata, function() return dropdown.selectedValue == strata end, function()
                dropdown.selectedValue = strata
                if wt.selectedPreset then
                    local preset = WeakTexturesDB.presets[wt.selectedPreset]
                    preset.strata = strata
                end
            end)
        end
    end)

    content.strataLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.strataLabel:SetPoint("BOTTOMLEFT", content.strataDropDown, "TOPLEFT", 0, 3)
    content.strataLabel:SetText(L.LABEL_STRATA)

    content.frameLevelEdit = wt:CreateEditBox(content, 55, nil, 100)
    content.frameLevelEdit:SetPoint("LEFT", content.strataDropDown, "RIGHT", 8, 1)
    content.frameLevelEdit:SetNumeric(true)

    content.frameLevelLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.frameLevelLabel:SetPoint("BOTTOMLEFT", content.frameLevelEdit, "TOPLEFT", -4, 3)
    content.frameLevelLabel:SetText(L.LABEL_LEVEL)

    -- Anchor Type Dropdown
    content.anchorTypeDropDown = wt:CreateDropdown(content, "WT_AnchorTypeDropdown", 100, L.ANCHOR_SCREEN, "Screen")
    content.anchorTypeDropDown:SetPoint("TOPLEFT", content.ftypeDropDown, "BOTTOMLEFT", 0, -24)
    content.anchorTypeDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(L.ANCHOR_SCREEN, function() return dropdown.selectedValue == "Screen" end, function()
            dropdown.selectedValue = "Screen"
            content.anchorEdit:SetText("UIParent")
            content.anchorEdit:Hide()
            content.selectFrameBtn:Hide()
        end)
        
        rootDescription:CreateRadio(L.ANCHOR_CUSTOM_FRAME, function() return dropdown.selectedValue == "Custom" end, function()
            dropdown.selectedValue = "Custom"
            -- Clear UIParent if it's there, otherwise keep current value
            local currentValue = content.anchorEdit:GetText()
            if currentValue == "UIParent" then
                content.anchorEdit:SetText("")
            end
            content.anchorEdit:Show()
            content.selectFrameBtn:Show()
        end)
    end)

    content.anchorTypeLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.anchorTypeLabel:SetPoint("BOTTOMLEFT", content.anchorTypeDropDown, "TOPLEFT", 0, 3)
    content.anchorTypeLabel:SetText(L.LABEL_ANCHOR_FRAME)

    -- Anchor Edit (hidden by default when Screen is selected)
    content.anchorEdit = wt:CreateEditBox(content, 151, nil, "e.g. Minimap")
    content.anchorEdit:SetPoint("LEFT", content.anchorTypeDropDown, "RIGHT", 10, 0)
    content.anchorEdit:Hide()  -- Hidden by default

    content.selectFrameBtn = wt:CreateButton(content, 55, 22, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_SELECT)
    content.selectFrameBtn:SetPoint("LEFT", content.anchorEdit, "RIGHT", 5, 0)
    content.selectFrameBtn:SetScript("OnClick", function() wt:StartFrameChooser() end)
    content.selectFrameBtn:Hide()  -- Hidden by default

    -- === TEXT SETTINGS ===
    content.textHeader = wt:CreateHeader(content, L.HEADER_TEXT_SETTINGS)
    content.textHeader:SetPoint("TOPLEFT", content.anchorTypeDropDown, "BOTTOMLEFT", 1, -12)

    -- Text content
    content.textContentEdit = wt:CreateEditBox(content, 390, nil, L.PLACEHOLDER_TEXT_CONTENT)
    content.textContentEdit:SetPoint("TOPLEFT", content.textHeader, "BOTTOMLEFT", 5, -24)

    content.textContentLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.textContentLabel:SetPoint("BOTTOMLEFT", content.textContentEdit, "TOPLEFT", -5, 3)
    content.textContentLabel:SetText(L.LABEL_TEXT_CONTENT)

    -- Font dropdown (LSM fonts)
    content.fontDropDown = wt:CreateDropdown(content, "WT_FontDropdown", 190, "Friz Quadrata TT", "Friz Quadrata TT")
    content.fontDropDown:SetPoint("TOPLEFT", content.textContentEdit, "BOTTOMLEFT", -5, -24)
    content.fontDropDown:SetupMenu(function(dropdown, rootDescription)
        local fonts = wt.LSM:List("font")
        table.sort(fonts)
        for _, fontName in ipairs(fonts) do
            rootDescription:CreateRadio(fontName, function() return dropdown.selectedValue == fontName end, function()
                dropdown.selectedValue = fontName
            end)
        end
    end)

    content.fontLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.fontLabel:SetPoint("BOTTOMLEFT", content.fontDropDown, "TOPLEFT", 0, 3)
    content.fontLabel:SetText(L.LABEL_FONT)

    -- Font size
    content.fontSizeEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 48)
    content.fontSizeEdit:SetPoint("LEFT", content.fontDropDown, "RIGHT", 8, 0)
    content.fontSizeEdit:SetNumeric(true)

    content.fontSizeLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.fontSizeLabel:SetPoint("BOTTOM", content.fontSizeEdit, "TOP", 0, 3)
    content.fontSizeLabel:SetText(L.LABEL_FONT_SIZE)

    -- Font outline
    content.fontOutlineDropDown = wt:CreateDropdown(content, "WT_FontOutlineDropdown", 130, L.OUTLINE_NORMAL, "OUTLINE")
    content.fontOutlineDropDown:SetPoint("LEFT", content.fontSizeEdit, "RIGHT", 8, 0)
    content.fontOutlineDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(L.OUTLINE_NONE, function() return dropdown.selectedValue == "" end, function()
            dropdown.selectedValue = ""
        end)
        rootDescription:CreateRadio(L.OUTLINE_NORMAL, function() return dropdown.selectedValue == "OUTLINE" end, function()
            dropdown.selectedValue = "OUTLINE"
        end)
        rootDescription:CreateRadio(L.OUTLINE_THICK, function() return dropdown.selectedValue == "THICKOUTLINE" end, function()
            dropdown.selectedValue = "THICKOUTLINE"
        end)
        rootDescription:CreateRadio(L.OUTLINE_MONOCHROME, function() return dropdown.selectedValue == "MONOCHROME" end, function()
            dropdown.selectedValue = "MONOCHROME"
        end)
    end)

    content.fontOutlineLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.fontOutlineLabel:SetPoint("BOTTOM", content.fontOutlineDropDown, "TOP", 0, 3)
    content.fontOutlineLabel:SetText(L.LABEL_FONT_OUTLINE)

    -- Text color picker
    content.textColorPicker = wt:CreateColorPicker(content, L.LABEL_TEXT_COLOR, 1, 0.82, 0, 1)
    content.textColorPicker:SetPoint("TOPLEFT", content.fontDropDown, "BOTTOMLEFT", 0, -24)

    -- Text offset X/Y
    content.textOffsetXEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 0)
    content.textOffsetXEdit:SetPoint("LEFT", content.textColorPicker, "RIGHT", 12, 0)

    content.textOffsetXLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.textOffsetXLabel:SetPoint("BOTTOM", content.textOffsetXEdit, "TOP", 0, 3)
    content.textOffsetXLabel:SetText(L.LABEL_TEXT_OFFSET_X)

    content.textOffsetYEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 125)
    content.textOffsetYEdit:SetPoint("LEFT", content.textOffsetXEdit, "RIGHT", 8, 0)

    content.textOffsetYLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.textOffsetYLabel:SetPoint("BOTTOM", content.textOffsetYEdit, "TOP", 0, 3)
    content.textOffsetYLabel:SetText(L.LABEL_TEXT_OFFSET_Y)

    -- === SIZE & OFFSET ===
    content.sizeHeader = wt:CreateHeader(content, L.HEADER_VISUAL)
    content.sizeHeader:SetPoint("TOPLEFT", content.textColorPicker, "BOTTOMLEFT", -3, -12)

    -- Texture color picker
    content.textureColorPicker = wt:CreateColorPicker(content, L.LABEL_TEXTURE_COLOR, 1, 1, 1, 1)
    content.textureColorPicker:SetPoint("TOPLEFT", content.sizeHeader, "BOTTOMLEFT", 3, -24)

    content.widthEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 100)
    content.widthEdit:SetPoint("LEFT", content.textureColorPicker, "RIGHT", 12, -36)

    content.widthLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.widthLabel:SetPoint("BOTTOM", content.widthEdit, "TOP", 0, 3)
    content.widthLabel:SetText(L.LABEL_WIDTH)

    content.heightEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 100)
    content.heightEdit:SetPoint("LEFT", content.widthEdit, "RIGHT", 8, 0)

    content.heightLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.heightLabel:SetPoint("BOTTOM", content.heightEdit, "TOP", 0, 3)
    content.heightLabel:SetText(L.LABEL_HEIGHT)

    content.xOffsetEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 0)
    content.xOffsetEdit:SetPoint("LEFT", content.textureColorPicker, "RIGHT", 12, 0)

    content.xOffsetLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.xOffsetLabel:SetPoint("BOTTOM", content.xOffsetEdit, "TOP", 0, 3)
    content.xOffsetLabel:SetText(L.LABEL_X)

    content.yOffsetEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 0)
    content.yOffsetEdit:SetPoint("LEFT", content.xOffsetEdit, "RIGHT", 8, 0)

    content.yOffsetLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.yOffsetLabel:SetPoint("BOTTOM", content.yOffsetEdit, "TOP", 0, 3)
    content.yOffsetLabel:SetText(L.LABEL_Y)

    content.scaleEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, "1.0")
    content.scaleEdit:SetPoint("LEFT", content.yOffsetEdit, "RIGHT", 12, 0)
    content.scaleEdit:SetText("1.0")

    content.scaleLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.scaleLabel:SetPoint("BOTTOM", content.scaleEdit, "TOP", 0, 3)
    content.scaleLabel:SetText(L.LABEL_SCALE)

    content.angleEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 0)
    content.angleEdit:SetPoint("TOPLEFT", content.scaleEdit, "BOTTOMLEFT", 0, -16)
    content.angleEdit:SetText("0")

    content.angleLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.angleLabel:SetPoint("BOTTOM", content.angleEdit, "TOP", 0, 3)
    content.angleLabel:SetText(L.LABEL_ANGLE)

    content.alphaEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, "1.0")
    content.alphaEdit:SetPoint("LEFT", content.angleEdit, "RIGHT", 8, 0)
    content.alphaEdit:SetText("1.0")

    content.alphaLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.alphaLabel:SetPoint("BOTTOM", content.alphaEdit, "TOP", 0, 3)
    content.alphaLabel:SetText(L.LABEL_ALPHA)

    content.columnsEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 4)
    content.columnsEdit:SetPoint("TOPLEFT", content.widthEdit, "BOTTOMLEFT", 0, -16)
    content.columnsEdit:SetNumeric(true)
    content.columnsEdit:Hide()

    content.columnsLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.columnsLabel:SetPoint("BOTTOM", content.columnsEdit, "TOP", 0, 3)
    content.columnsLabel:SetText(L.LABEL_COL)
    content.columnsLabel:Hide()

    content.rowsEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 4)
    content.rowsEdit:SetPoint("LEFT", content.columnsEdit, "RIGHT", 8, 0)
    content.rowsEdit:SetNumeric(true)
    content.rowsEdit:Hide()

    content.rowsLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.rowsLabel:SetPoint("BOTTOM", content.rowsEdit, "TOP", 0, 3)
    content.rowsLabel:SetText(L.LABEL_ROW)
    content.rowsLabel:Hide()

    content.totalFramesEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 16)
    content.totalFramesEdit:SetPoint("LEFT", content.rowsEdit, "RIGHT", 12, 0)
    content.totalFramesEdit:SetNumeric(true)
    content.totalFramesEdit:Hide()

    content.totalFramesLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.totalFramesLabel:SetPoint("BOTTOM", content.totalFramesEdit, "TOP", 0, 3)
    content.totalFramesLabel:SetText(L.LABEL_FRAMES)
    content.totalFramesLabel:Hide()

    content.fpsEdit = wt:CreateEditBox(content, wt.smallEditBoxWidth, nil, 10)
    content.fpsEdit:SetPoint("LEFT", content.totalFramesEdit, "RIGHT", 8, 0)
    content.fpsEdit:SetNumeric(true)
    content.fpsEdit:Hide()

    content.fpsLabel = content:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    content.fpsLabel:SetPoint("BOTTOM", content.fpsEdit, "TOP", 0, 3)
    content.fpsLabel:SetText(L.LABEL_FPS)
    content.fpsLabel:Hide()

    -- === SOUND SETTINGS ===
    content.soundHeader = wt:CreateHeader(content, L.HEADER_SOUND_SETTINGS)
    content.soundHeader:SetPoint("TOPLEFT", content.sizeHeader, "BOTTOMLEFT", 0, -100)

    -- Sound Dropdown
    content.soundDropDown = wt:CreateDropdown(content, "WT_SoundDropdown", 250, L.SOUND_NONE, "None")
    content.soundDropDown:SetPoint("TOPLEFT", content.soundHeader, "BOTTOMLEFT", 5, -24)
    content.soundDropDown.selectedPath = nil
    content.soundDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetScrollMode(450)
        
        -- Helper function to add preview button to menu item
        local function AddPreviewButton(radio, soundPath, soundName)
            radio:AddInitializer(function(button, description, menu)
                local previewBtn = button:AttachTexture()
                previewBtn:SetSize(16, 16)
                previewBtn:SetPoint("RIGHT", -4, 0)
                previewBtn:SetAtlas("voicechat-icon-speaker")
                
                -- Create clickable region
                if not button.soundPreviewRegion then
                    button.soundPreviewRegion = CreateFrame("Button", nil, button)
                    button.soundPreviewRegion:SetSize(20, 20)
                    button.soundPreviewRegion:SetPoint("RIGHT", -2, 0)
                    
                    -- Highlight on hover
                    local highlight = button.soundPreviewRegion:CreateTexture(nil, "HIGHLIGHT")
                    highlight:SetAllPoints()
                    highlight:SetColorTexture(1, 1, 1, 0.3)
                    
                    button.soundPreviewRegion:SetScript("OnClick", function(self, btn)
                        if btn == "LeftButton" then
                            local soundChannel = content.soundChannelDropDown.selectedValue or "Master"
                            if soundPath then
                                if type(soundPath) == "number" then
                                    PlaySoundFile(soundPath, soundChannel)
                                elseif type(soundPath) == "string" then
                                    if not soundPath:find("[/\\\\]") then
                                        local lsmSound = wt.LSM:Fetch("sound", soundPath)
                                        if lsmSound then
                                            soundPath = lsmSound
                                        end
                                    end
                                    PlaySoundFile(soundPath, soundChannel)
                                end
                            end
                            -- Prevent menu from closing
                            self:GetParent():GetParent():SetPropagateMouseClicks(false)
                        end
                    end)
                    
                    button.soundPreviewRegion:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(L.BUTTON_PREVIEW_SOUND)
                        GameTooltip:Show()
                    end)
                    
                    button.soundPreviewRegion:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)
                end
            end)
        end
        
        -- None option (no preview button)
        rootDescription:CreateRadio(L.SOUND_NONE, function() return dropdown.selectedValue == "None" end, function()
            dropdown.selectedValue = "None"
            dropdown.selectedPath = nil
            content.soundCustomEdit:Hide()
        end)
        
        -- Custom option (no preview button, as path is unknown until entered)
        rootDescription:CreateRadio(L.SOUND_CUSTOM, function() return dropdown.selectedValue == "Custom" end, function()
            dropdown.selectedValue = "Custom"
            dropdown.selectedPath = nil
            content.soundCustomEdit:Show()
        end)
        
        -- LSM sounds
        local sounds = wt.LSM:List("sound")
        if #sounds > 0 then
            rootDescription:CreateDivider()
            local soundsHeader = rootDescription:CreateButton("=== SOUNDS ===")
            soundsHeader:SetEnabled(false)
            
            for _, soundName in ipairs(sounds) do
                -- Skip "None" from LSM list if it exists
                if soundName:lower() ~= "none" then
                    local soundPath = wt.LSM:Fetch("sound", soundName)
                    local radio = rootDescription:CreateRadio(soundName, function() return dropdown.selectedValue == soundName end, function()
                        dropdown.selectedValue = soundName
                        dropdown.selectedPath = soundPath
                        content.soundCustomEdit:Hide()
                    end)
                    
                    -- Add preview button to this item
                    AddPreviewButton(radio, soundPath, soundName)
                end
            end
        end
    end)

    content.soundLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.soundLabel:SetPoint("BOTTOMLEFT", content.soundDropDown, "TOPLEFT", 0, 3)
    content.soundLabel:SetText(L.LABEL_SOUND)
    
    -- Sound Custom Path Edit
    content.soundCustomEdit = wt:CreateEditBox(content, 245, nil, L.PLACEHOLDER_SOUND)
    content.soundCustomEdit:SetPoint("TOPLEFT", content.soundDropDown, "BOTTOMLEFT", 5, -8)
    content.soundCustomEdit:Hide()

    -- Sound Channel Dropdown
    content.soundChannelDropDown = wt:CreateDropdown(content, "WT_SoundChannelDropdown", 130, L.SOUND_CHANNEL_MASTER, "Master")
    content.soundChannelDropDown:SetPoint("LEFT", content.soundDropDown, "RIGHT", 12, 0)
    content.soundChannelDropDown:SetupMenu(function(dropdown, rootDescription)
        local channels = {
            {name = L.SOUND_CHANNEL_MASTER, value = "Master"},
            {name = L.SOUND_CHANNEL_SFX, value = "SFX"},
            {name = L.SOUND_CHANNEL_MUSIC, value = "Music"},
            {name = L.SOUND_CHANNEL_AMBIENCE, value = "Ambience"},
            {name = L.SOUND_CHANNEL_DIALOG, value = "Dialog"}
        }
        
        for _, channel in ipairs(channels) do
            rootDescription:CreateRadio(channel.name, function() return dropdown.selectedValue == channel.value end, function()
                dropdown.selectedValue = channel.value
            end)
        end
    end)

    content.soundChannelLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    content.soundChannelLabel:SetPoint("BOTTOMLEFT", content.soundChannelDropDown, "TOPLEFT", 0, 3)
    content.soundChannelLabel:SetText(L.LABEL_SOUND_CHANNEL)

    wt.frame.right.conditionsPanel = CreateFrame("Frame", nil, wt.frame.right, nil)
    wt.frame.right.conditionsPanel:SetSize(500, 370)
    wt.frame.right.conditionsPanel:SetPoint("TOPLEFT", 10, wt.PANELOFFSET_Y)

    wt.frame.right.conditionsPanel.loadingHeader = wt:CreateHeader(wt.frame.right.conditionsPanel, L.HEADER_LOADING)
    wt.frame.right.conditionsPanel.loadingHeader:SetPoint("TOPLEFT", 5, -3)

    wt.frame.right.conditionsPanel.enabledCheck = CreateFrame("CheckButton", nil, wt.frame.right.conditionsPanel, "UICheckButtonTemplate")
    wt.frame.right.conditionsPanel.enabledCheck:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.loadingHeader, "BOTTOMLEFT", 5, -10)
    wt.frame.right.conditionsPanel.enabledCheck:SetChecked(true)
    wt.frame.right.conditionsPanel.enabledCheck.text:SetText(L.CHECKBOX_CAN_LOAD)

    wt.frame.right.conditionsPanel.advancedCheck = CreateFrame("CheckButton", nil, wt.frame.right.conditionsPanel, "UICheckButtonTemplate")
    wt.frame.right.conditionsPanel.advancedCheck:SetPoint("LEFT", wt.frame.right.conditionsPanel.enabledCheck, "RIGHT", 100, 0)
    wt.frame.right.conditionsPanel.advancedCheck:SetChecked(false)
    wt.frame.right.conditionsPanel.advancedCheck.text:SetText(L.HEADER_ADVANCED_CONDITIONS)
    wt.frame.right.conditionsPanel.advancedCheck:SetScript("OnClick", function(self)
        wt:ToggleAdvancedTab(self:GetChecked())
    end)

    wt.frame.right.conditionsPanel.characterHeader = wt:CreateHeader(wt.frame.right.conditionsPanel, L.HEADER_CHARACTER_CONDITIONS)
    wt.frame.right.conditionsPanel.characterHeader:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.enabledCheck, "BOTTOMLEFT", -5, -12)

    wt.frame.right.conditionsPanel.classDropDown = wt:CreateDropdown(wt.frame.right.conditionsPanel, "MTP_ClassDropdown", 120, L.DROPDOWN_ANY_CLASS, "Any Class")
    wt.frame.right.conditionsPanel.classDropDown:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.characterHeader, "BOTTOMLEFT", 5, -24)
    wt.frame.right.conditionsPanel.classDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(L.DROPDOWN_ANY_CLASS, function() return dropdown.selectedValue == "Any Class" end, function()
            dropdown.selectedValue = "Any Class"
            wt.frame.right.conditionsPanel.specDropDown.selectedValue = "Any Spec"
        end)
        
        for _, class in ipairs(wt:GetAllClasses()) do
            rootDescription:CreateRadio(class.name, function() return dropdown.selectedValue == class.name end, function()
                dropdown.selectedValue = class.name
                wt.frame.right.conditionsPanel.specDropDown.selectedValue = "Any Spec"
            end)
        end
    end)

    wt.frame.right.conditionsPanel.classLabel = wt.frame.right.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    wt.frame.right.conditionsPanel.classLabel:SetPoint("BOTTOMLEFT", wt.frame.right.conditionsPanel.classDropDown, "TOPLEFT", 0, 3)
    wt.frame.right.conditionsPanel.classLabel:SetText(L.LABEL_CLASS)

    wt.frame.right.conditionsPanel.specDropDown = wt:CreateDropdown(wt.frame.right.conditionsPanel, "MTP_SpecDropdown", 120, L.DROPDOWN_ANY_SPEC, "Any Spec")
    wt.frame.right.conditionsPanel.specDropDown:SetPoint("LEFT", wt.frame.right.conditionsPanel.classDropDown, "RIGHT", 10, 0)
    wt.frame.right.conditionsPanel.specDropDown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateRadio(L.DROPDOWN_ANY_SPEC, function() return dropdown.selectedValue == "Any Spec" end, function()
            dropdown.selectedValue = "Any Spec"
        end)
        
        local classDropdown = wt.frame.right.conditionsPanel.classDropDown
        local classText = classDropdown.selectedValue
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
            rootDescription:CreateRadio(spec.name, function() return dropdown.selectedValue == spec.name end, function()
                dropdown.selectedValue = spec.name
            end)
        end
    end)

    wt.frame.right.conditionsPanel.specLabel = wt.frame.right.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    wt.frame.right.conditionsPanel.specLabel:SetPoint("BOTTOMLEFT", wt.frame.right.conditionsPanel.specDropDown, "TOPLEFT", 0, 3)
    wt.frame.right.conditionsPanel.specLabel:SetText(L.LABEL_SPEC)

    wt.frame.right.conditionsPanel.playerNameEdit = wt:CreateEditBox(wt.frame.right.conditionsPanel, 125, nil, L.LABEL_PLAYER_NAME)
    wt.frame.right.conditionsPanel.playerNameEdit:SetPoint("LEFT", wt.frame.right.conditionsPanel.specDropDown, "RIGHT", 10, 1)

    wt.frame.right.conditionsPanel.playerNameLabel = wt.frame.right.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    wt.frame.right.conditionsPanel.playerNameLabel:SetPoint("BOTTOMLEFT", wt.frame.right.conditionsPanel.playerNameEdit, "TOPLEFT", 0, 4)
    wt.frame.right.conditionsPanel.playerNameLabel:SetText(L.LABEL_PLAYER_NAME)

    wt.frame.right.conditionsPanel.stateHeader = wt:CreateHeader(wt.frame.right.conditionsPanel, L.HEADER_STATE_CONDITIONS)
    wt.frame.right.conditionsPanel.stateHeader:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.classDropDown, "BOTTOMLEFT", -5, -12)

    wt.frame.right.conditionsPanel.aliveCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_ALIVE, 0, "")
    wt.frame.right.conditionsPanel.aliveCheck:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.stateHeader, "BOTTOMLEFT", 5, -10)

    wt.frame.right.conditionsPanel.combatCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_COMBAT, 0, L.PREFIX_IN)
    wt.frame.right.conditionsPanel.combatCheck:SetPoint("LEFT", wt.frame.right.conditionsPanel.aliveCheck, "RIGHT", wt.conditionCheckboxSpacing, 0)

    wt.frame.right.conditionsPanel.restedCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_RESTED, 0, "")
    wt.frame.right.conditionsPanel.restedCheck:SetPoint("LEFT", wt.frame.right.conditionsPanel.combatCheck, "RIGHT", wt.conditionCheckboxSpacing, 0)

    wt.frame.right.conditionsPanel.environmentHeader = wt:CreateHeader(wt.frame.right.conditionsPanel, L.HEADER_ENVIRONMENT)
    wt.frame.right.conditionsPanel.environmentHeader:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.aliveCheck, "BOTTOMLEFT", -5, -12)

    wt.frame.right.conditionsPanel.instanceCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_INSTANCE, 0, L.PREFIX_IN)
    wt.frame.right.conditionsPanel.instanceCheck:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.environmentHeader, "BOTTOMLEFT", 5, -10)

    wt.frame.right.conditionsPanel.encounterCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_ENCOUNTER, 0, L.PREFIX_IN)
    wt.frame.right.conditionsPanel.encounterCheck:SetPoint("LEFT", wt.frame.right.conditionsPanel.instanceCheck, "RIGHT", wt.conditionCheckboxSpacing, 0)

    wt.frame.right.conditionsPanel.petBattleCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_PET_BATTLE, 0, L.PREFIX_IN)
    wt.frame.right.conditionsPanel.petBattleCheck:SetPoint("LEFT", wt.frame.right.conditionsPanel.encounterCheck, "RIGHT", wt.conditionCheckboxSpacing, 0)

    wt.frame.right.conditionsPanel.vehicleCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_VEHICLE, 0, L.PREFIX_IN)
    wt.frame.right.conditionsPanel.vehicleCheck:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.instanceCheck, "BOTTOMLEFT", 0, -5)

    wt.frame.right.conditionsPanel.housingCheck = wt:CreateThreeStateCheckBox(wt.frame.right.conditionsPanel, nil, L.CHECKBOX_HOME, 0, L.PREFIX_AT)
    wt.frame.right.conditionsPanel.housingCheck:SetPoint("LEFT", wt.frame.right.conditionsPanel.vehicleCheck, "RIGHT", wt.conditionCheckboxSpacing, 0)

    wt.frame.right.conditionsPanel.zoneEdit = wt:CreateEditBox(wt.frame.right.conditionsPanel, 380, nil, L.PLACEHOLDER_ZONE)
    wt.frame.right.conditionsPanel.zoneEdit:SetPoint("TOPLEFT", wt.frame.right.conditionsPanel.vehicleCheck, "BOTTOMLEFT", 5, -19)

    wt.frame.right.conditionsPanel.zoneLabel = wt.frame.right.conditionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    wt.frame.right.conditionsPanel.zoneLabel:SetPoint("BOTTOMLEFT", wt.frame.right.conditionsPanel.zoneEdit, "TOPLEFT", 0, 3)
    wt.frame.right.conditionsPanel.zoneLabel:SetText(L.LABEL_ZONE)

    wt.frame.right.advancedPanel = CreateFrame("Frame", nil, wt.frame.right, nil)
    wt.frame.right.advancedPanel:SetSize(500, 370)
    wt.frame.right.advancedPanel:SetPoint("TOPLEFT", 10, wt.PANELOFFSET_Y)

    wt.frame.right.advancedPanel.title = wt.frame.right.advancedPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wt.frame.right.advancedPanel.title:SetPoint("TOP", -50, -5)
    wt.frame.right.advancedPanel.title:SetText(L.HEADER_ADVANCED_CONDITIONS)

    wt.frame.right.advancedPanel.eventsLabel = wt.frame.right.advancedPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wt.frame.right.advancedPanel.eventsLabel:SetPoint("TOPLEFT", 10, -35)
    wt.frame.right.advancedPanel.eventsLabel:SetText(L.LABEL_EVENTS)
    wt.frame.right.advancedPanel.eventsLabel:SetJustifyH("LEFT")

    wt.frame.right.advancedPanel.eventsEdit = wt:CreateEditBox(wt.frame.right.advancedPanel, 315, nil, L.PLACEHOLDER_EVENTS)
    wt.frame.right.advancedPanel.eventsEdit:SetPoint("TOPLEFT", wt.frame.right.advancedPanel.eventsLabel, "BOTTOMLEFT", 5, -5)

    wt.frame.right.advancedPanel.eventsEdit:HookScript("OnTextChanged", function(self)
        local text = self:GetText()
        if not text or text == "" then
            return
        end
        
        local events = {}
        for event in string.gmatch(text, "[^,]+") do
            event = string.trim(event)
            table.insert(events, event)
        end
        
        for _, event in ipairs(events) do
            for blacklisted, _ in pairs(wt.blockedEvents) do
                if event:upper() == blacklisted:upper() then
                    wt.frame.right.advancedPanel.errorEdit:SetText(string.format(L.ERROR_EVENT_NOT_ALLOWED, event))
                    wt.frame.right.advancedPanel.errorContainer:Show()
                    return
                end
            end
        end
    end)

    -- Multi-Instance checkbox
    wt.frame.right.advancedPanel.multiInstanceCheck = CreateFrame("CheckButton", "WeakTexturesMultiInstanceCheck", wt.frame.right.advancedPanel, "UICheckButtonTemplate")
    wt.frame.right.advancedPanel.multiInstanceCheck:SetPoint("BOTTOMRIGHT", wt.frame.right.advancedPanel.eventsEdit, "BOTTOMRIGHT", 5, -32)
    wt.frame.right.advancedPanel.multiInstanceCheck.text:SetText("Multi-Instance")
    wt.frame.right.advancedPanel.multiInstanceCheck.text:SetFontObject(GameFontNormal)

    wt.frame.right.advancedPanel.durationLabel = wt.frame.right.advancedPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wt.frame.right.advancedPanel.durationLabel:SetPoint("LEFT", wt.frame.right.advancedPanel.eventsEdit, "RIGHT", 20, 21)
    wt.frame.right.advancedPanel.durationLabel:SetText(L.LABEL_DURATION)

    wt.frame.right.advancedPanel.durationEdit = wt:CreateEditBox(wt.frame.right.advancedPanel, 60, nil, L.PLACEHOLDER_SECONDS)
    wt.frame.right.advancedPanel.durationEdit:SetPoint("TOP", wt.frame.right.advancedPanel.durationLabel, "BOTTOM", 0, -5)

    wt.frame.right.advancedPanel.triggerLabel = wt.frame.right.advancedPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    wt.frame.right.advancedPanel.triggerLabel:SetPoint("TOPLEFT", wt.frame.right.advancedPanel.eventsEdit, "BOTTOMLEFT", -5, -10)
    wt.frame.right.advancedPanel.triggerLabel:SetText(L.LABEL_TRIGGER_FUNCTION)

    wt.frame.right.advancedPanel.triggerContainer = CreateFrame("Frame", nil, wt.frame.right.advancedPanel, "BackdropTemplate")
    wt.frame.right.advancedPanel.triggerContainer:SetPoint("TOPLEFT", wt.frame.right.advancedPanel.triggerLabel, "BOTTOMLEFT", 0, -5)
    wt.frame.right.advancedPanel.triggerContainer:SetSize(395, 230)
    wt.frame.right.advancedPanel.triggerContainer:SetBackdrop(wt.multiLineEditBoxBackdrop)
    wt.frame.right.advancedPanel.triggerContainer:SetBackdropColor(0, 0, 0, 0.8)
    wt.frame.right.advancedPanel.triggerContainer:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    wt.frame.right.advancedPanel.lineNumScrollFrame = CreateFrame("ScrollFrame", nil, wt.frame.right.advancedPanel.triggerContainer)
    wt.frame.right.advancedPanel.lineNumScrollFrame:SetPoint("TOPLEFT", 8, -8)
    wt.frame.right.advancedPanel.lineNumScrollFrame:SetSize(30, 214)

    wt.frame.right.advancedPanel.lineNumEditBox = CreateFrame("EditBox", nil, wt.frame.right.advancedPanel.lineNumScrollFrame)
    wt.frame.right.advancedPanel.lineNumEditBox:SetMultiLine(true)
    wt.frame.right.advancedPanel.lineNumEditBox:SetWidth(30)
    wt.frame.right.advancedPanel.lineNumEditBox:SetFontObject(GameFontHighlight)
    wt.frame.right.advancedPanel.lineNumEditBox:SetAutoFocus(false)
    wt.frame.right.advancedPanel.lineNumEditBox:EnableMouse(false)
    wt.frame.right.advancedPanel.lineNumEditBox:SetTextColor(0.6, 0.6, 0.6, 1)
    wt:ApplyCustomFont(wt.frame.right.advancedPanel.lineNumEditBox, 10)
    wt.frame.right.advancedPanel.lineNumScrollFrame:SetScrollChild(wt.frame.right.advancedPanel.lineNumEditBox)

    wt.frame.right.advancedPanel.lineTestFrame = CreateFrame("Frame", nil, wt.frame.right.advancedPanel)
    wt.frame.right.advancedPanel.lineTestFrame:Hide()
    wt.frame.right.advancedPanel.lineTestText = wt.frame.right.advancedPanel.lineTestFrame:CreateFontString(nil, "OVERLAY")
    wt.frame.right.advancedPanel.lineTestText:SetFontObject(GameFontHighlight)

    wt.frame.right.advancedPanel.triggerScrollFrame = CreateFrame("ScrollFrame", nil, wt.frame.right.advancedPanel.triggerContainer)
    wt.frame.right.advancedPanel.triggerScrollFrame:SetPoint("TOPLEFT", 43, -8)
    wt.frame.right.advancedPanel.triggerScrollFrame:SetPoint("BOTTOMRIGHT", -18, 8)
    wt.frame.right.advancedPanel.triggerScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local scrollBar = wt.frame.right.advancedPanel.triggerScrollBar
        if scrollBar:IsVisible() then
            local currentScroll = scrollBar:GetScrollPercentage() or 0
            local step = wt.scrollSteps
            scrollBar:SetScrollPercentage(currentScroll - (delta * step))
        end
    end)

    wt.frame.right.advancedPanel.triggerScrollBar = CreateFrame("EventFrame", nil, wt.frame.right.advancedPanel.triggerContainer, "MinimalScrollBar")
    wt.frame.right.advancedPanel.triggerScrollBar:SetPoint("TOPLEFT", wt.frame.right.advancedPanel.triggerScrollFrame, "TOPRIGHT", 2, 0)
    wt.frame.right.advancedPanel.triggerScrollBar:SetPoint("BOTTOMLEFT", wt.frame.right.advancedPanel.triggerScrollFrame, "BOTTOMRIGHT", 2, 0)
    wt.frame.right.advancedPanel.triggerScrollBar:SetScale(0.65)
    wt.frame.right.advancedPanel.triggerScrollBar:SetHideIfUnscrollable(true)

    wt.frame.right.advancedPanel.triggerEdit = CreateFrame("EditBox", nil, wt.frame.right.advancedPanel.triggerScrollFrame)
    wt.frame.right.advancedPanel.triggerEdit:SetMultiLine(true)
    wt.frame.right.advancedPanel.triggerEdit:SetWidth(wt.frame.right.advancedPanel.triggerScrollFrame:GetWidth())
    wt.frame.right.advancedPanel.triggerEdit:SetMaxLetters(0)
    wt.frame.right.advancedPanel.triggerEdit:SetFontObject(GameFontHighlight)
    wt.frame.right.advancedPanel.triggerEdit:SetAutoFocus(false)
    wt:ApplyCustomFont(wt.frame.right.advancedPanel.triggerEdit, 10)

    wt.frame.right.advancedPanel.triggerEdit.Instructions = wt.frame.right.advancedPanel.triggerScrollFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    wt.frame.right.advancedPanel.triggerEdit.Instructions:SetPoint("TOPLEFT", wt.frame.right.advancedPanel.triggerEdit, "TOPLEFT", 2, -2)
    wt.frame.right.advancedPanel.triggerEdit.Instructions:SetPoint("BOTTOMRIGHT", wt.frame.right.advancedPanel.triggerEdit, "BOTTOMRIGHT", -2, 2)
    wt.frame.right.advancedPanel.triggerEdit.Instructions:SetJustifyH("LEFT")
    wt.frame.right.advancedPanel.triggerEdit.Instructions:SetJustifyV("TOP")
    wt.frame.right.advancedPanel.triggerEdit.Instructions:SetText(L.PLACEHOLDER_TRIGGER_CODE)
    wt:ApplyCustomFont(wt.frame.right.advancedPanel.triggerEdit.Instructions, 10)

    wt.frame.right.advancedPanel.triggerScrollFrame:SetScrollChild(wt.frame.right.advancedPanel.triggerEdit)

    ScrollUtil.InitScrollFrameWithScrollBar(wt.frame.right.advancedPanel.triggerScrollFrame, wt.frame.right.advancedPanel.triggerScrollBar)

    wt.frame.right.advancedPanel.triggerScrollFrame:SetScript("OnMouseDown", function()
        wt.frame.right.advancedPanel.triggerEdit:SetFocus()
    end)

    wt.frame.right.advancedPanel.triggerScrollFrame:HookScript("OnVerticalScroll", function(self, offset)
        wt.frame.right.advancedPanel.lineNumScrollFrame:SetVerticalScroll(offset)
    end)

    wt.frame.right.advancedPanel.triggerEdit:HookScript("OnTextChanged", function(self)
        wt:UpdateTriggerLineNumbers()
        local text = self:GetText()
        wt:TestTrigger(text, false)
        
        local isEmpty = not text or text == "" or text:match("^%s*$")
        if self.Instructions then
            self.Instructions:SetShown(isEmpty)
        end
    end)

    wt.frame.right.advancedPanel.triggerEdit:HookScript("OnEditFocusGained", function(self)
        if self.Instructions then
            self.Instructions:Hide()
        end
    end)

    wt.frame.right.advancedPanel.triggerEdit:HookScript("OnEditFocusLost", function(self)
        local text = self:GetText()
        local isEmpty = not text or text == "" or text:match("^%s*$")
        if self.Instructions and isEmpty then
            self.Instructions:Show()
        end
    end)

    wt:UpdateTriggerLineNumbers()

    wt.frame.right.advancedPanel.errorContainer = CreateFrame("Frame", nil, wt.frame.right.advancedPanel, "BackdropTemplate")
    wt.frame.right.advancedPanel.errorContainer:SetPoint("TOPLEFT", wt.frame.right.advancedPanel.triggerContainer, "BOTTOMLEFT", 0, -5)
    wt.frame.right.advancedPanel.errorContainer:SetSize(395, 40)
    wt.frame.right.advancedPanel.errorContainer:SetBackdrop(wt.multiLineEditBoxBackdrop)
    wt.frame.right.advancedPanel.errorContainer:SetBackdropColor(0.2, 0, 0, 0.8)
    wt.frame.right.advancedPanel.errorContainer:SetBackdropBorderColor(0.8, 0, 0, 1)

    wt.frame.right.advancedPanel.errorEdit = CreateFrame("EditBox", nil, wt.frame.right.advancedPanel.errorContainer)
    wt.frame.right.advancedPanel.errorEdit:SetMultiLine(true)
    wt.frame.right.advancedPanel.errorEdit:SetPoint("TOPLEFT", 8, -8)
    wt.frame.right.advancedPanel.errorEdit:SetPoint("BOTTOMRIGHT", -8, 8)
    wt.frame.right.advancedPanel.errorEdit:SetFontObject(GameFontNormal)
    wt.frame.right.advancedPanel.errorEdit:SetAutoFocus(false)
    wt.frame.right.advancedPanel.errorEdit:EnableMouse(true)
    wt.frame.right.advancedPanel.errorEdit:SetTextColor(1, 0.2, 0.2, 1)
    wt.frame.right.advancedPanel.errorEdit:SetMaxLetters(0)
    wt.frame.right.advancedPanel.errorEdit:SetText("")

    wt.frame.right.importPanel = CreateFrame("Frame", nil, wt.frame.right)
    wt.frame.right.importPanel:SetAllPoints()
    wt.frame.right.importPanel:Hide()

    wt.frame.right.importPanel.title = wt.frame.right.importPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wt.frame.right.importPanel.title:SetPoint("TOP", 0, -20)
    wt.frame.right.importPanel.title:SetText(L.HEADER_IMPORT)

    wt.frame.right.importPanel.editBoxContainer = CreateFrame("Frame", nil, wt.frame.right.importPanel, "BackdropTemplate")
    wt.frame.right.importPanel.editBoxContainer:SetPoint("TOPLEFT", 15, -50)
    wt.frame.right.importPanel.editBoxContainer:SetPoint("BOTTOMRIGHT", -15, 60)
    wt.frame.right.importPanel.editBoxContainer:SetBackdrop(wt.multiLineEditBoxBackdrop)
    wt.frame.right.importPanel.editBoxContainer:SetBackdropColor(0, 0, 0, 0.8)
    wt.frame.right.importPanel.editBoxContainer:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    wt.frame.right.importPanel.scrollFrame = CreateFrame("ScrollFrame", nil, wt.frame.right.importPanel.editBoxContainer)
    wt.frame.right.importPanel.scrollFrame:SetPoint("TOPLEFT", 8, -8)
    wt.frame.right.importPanel.scrollFrame:SetPoint("BOTTOMRIGHT", -18, 8)
    wt.frame.right.importPanel.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local scrollBar = wt.frame.right.importPanel.scrollBar
        if scrollBar:IsVisible() then
            local currentScroll = scrollBar:GetScrollPercentage() or 0
            local step = wt.scrollSteps
            scrollBar:SetScrollPercentage(currentScroll - (delta * step))
        end
    end)

    wt.frame.right.importPanel.scrollBar = CreateFrame("EventFrame", nil, wt.frame.right.importPanel.editBoxContainer, "MinimalScrollBar")
    wt.frame.right.importPanel.scrollBar:SetPoint("TOPLEFT", wt.frame.right.importPanel.scrollFrame, "TOPRIGHT", 2, 0)
    wt.frame.right.importPanel.scrollBar:SetPoint("BOTTOMLEFT", wt.frame.right.importPanel.scrollFrame, "BOTTOMRIGHT", 2, 0)
    wt.frame.right.importPanel.scrollBar:SetHideIfUnscrollable(true)

    wt.frame.right.importPanel.editBox = CreateFrame("EditBox", nil, wt.frame.right.importPanel.scrollFrame)
    wt.frame.right.importPanel.editBox:SetMultiLine(true)
    wt.frame.right.importPanel.editBox:SetWidth(wt.frame.right.importPanel.scrollFrame:GetWidth())
    wt.frame.right.importPanel.editBox:SetMaxLetters(0)
    wt.frame.right.importPanel.editBox:SetFontObject(GameFontHighlight)
    wt.frame.right.importPanel.editBox:SetAutoFocus(false)

    wt.frame.right.importPanel.scrollFrame:SetScrollChild(wt.frame.right.importPanel.editBox)

    ScrollUtil.InitScrollFrameWithScrollBar(wt.frame.right.importPanel.scrollFrame, wt.frame.right.importPanel.scrollBar)

    wt.frame.right.importPanel.scrollFrame:SetScript("OnMouseDown", function()
        wt.frame.right.importPanel.editBox:SetFocus()
    end)

    wt.frame.right.importPanel.acceptButton = wt:CreateButton(wt.frame.right.importPanel, 120, 30, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_ACCEPT_IMPORT)
    wt.frame.right.importPanel.acceptButton:SetPoint("BOTTOMRIGHT", -5, 5)
    wt.frame.right.importPanel.acceptButton:SetScript("OnClick", function() wt:OnImportAcceptClick() end)

    wt.frame.right.importPanel.editBox:SetScript("OnEscapePressed", function(self) wt:OnImportEditBoxEscape(self) end)

    wt.rightPanels.display = wt.frame.right.configPanel
    wt.rightPanels.loadcondition = wt.frame.right.conditionsPanel
    wt.rightPanels.advanced = wt.frame.right.advancedPanel
    wt.rightPanels.import = wt.frame.right.importPanel

    PanelTemplates_SetTab(wt.frame.right, 1)
    wt:ShowRightTab("display")
    wt.frame.right:Hide()
    wt.frame.right:EnableMouse(false)

    local wtColorTable = {}
    wtColorTable[IndentationLib.tokens.TOKEN_SPECIAL] = "|c00ff99ff"
    wtColorTable[IndentationLib.tokens.TOKEN_KEYWORD] = "|c006666ff"
    wtColorTable[IndentationLib.tokens.TOKEN_COMMENT_SHORT] = "|c00999999"
    wtColorTable[IndentationLib.tokens.TOKEN_COMMENT_LONG] = "|c00999999"

    local stringColor = "|c00ffff77"
    wtColorTable[IndentationLib.tokens.TOKEN_STRING] = stringColor
    wtColorTable[".."] = stringColor

    local tableColor = "|c00ff9900"
    wtColorTable["..."] = tableColor
    wtColorTable["{"] = tableColor
    wtColorTable["}"] = tableColor
    wtColorTable["["] = tableColor
    wtColorTable["]"] = tableColor

    local arithmeticColor = "|c0033ff55"
    wtColorTable[IndentationLib.tokens.TOKEN_NUMBER] = arithmeticColor
    wtColorTable["+"] = arithmeticColor
    wtColorTable["-"] = arithmeticColor
    wtColorTable["/"] = arithmeticColor
    wtColorTable["*"] = arithmeticColor

    local logicColor1 = "|c0055ff88"
    wtColorTable["=="] = logicColor1
    wtColorTable["<"] = logicColor1
    wtColorTable["<="] = logicColor1
    wtColorTable[">"] = logicColor1
    wtColorTable[">="] = logicColor1
    wtColorTable["~="] = logicColor1

    local logicColor2 = "|c00ff0000"
    wtColorTable["local"] = logicColor2
    wtColorTable["for"] = logicColor2
    wtColorTable["in"] = logicColor2
    wtColorTable["and"] = logicColor2
    wtColorTable["or"] = logicColor2
    wtColorTable["not"] = logicColor2
    wtColorTable["while"] = logicColor2
    wtColorTable["do"] = logicColor2
    wtColorTable["function"] = logicColor2
    wtColorTable["if"] = logicColor2
    wtColorTable["then"] = logicColor2
    wtColorTable["return"] = logicColor2
    wtColorTable["end"] = logicColor2
    wtColorTable["else"] = logicColor2
    wtColorTable["elseif"] = logicColor2
    wtColorTable["repeat"] = logicColor2
    wtColorTable["until"] = logicColor2
    wtColorTable["nil"] = logicColor2
    wtColorTable["true"] = logicColor2
    wtColorTable["false"] = logicColor2

    IndentationLib.enable(wt.frame.right.advancedPanel.triggerEdit, wtColorTable, 2)
    IndentationLib.enable(wt.frame.right.importPanel.editBox, wtColorTable, 2)

end

function wt:ToggleUI()
    if not wt.frame.right then
        -- UI not fully initialized yet
        return
    end

    wt.frame:SetShown(not wt.frame:IsShown())
    if wt.frame:IsShown() then
        wt.frame:SetScale(WeakTexturesSettings.frameScale or 1)
        local leftAtlasBackgrounds = wt.leftAtlasBackgrounds
        wt.frame.left.Background:SetAtlas(leftAtlasBackgrounds[math.random(1, #leftAtlasBackgrounds)])
        wt.frame.right:EnableMouse(false)
        wt:CollapseAllGroups()
        if wt.frame.left.searchBox then
            wt.frame.left.searchBox:SetText("")
        end
        wt:RefreshPresetList()
    end
end
