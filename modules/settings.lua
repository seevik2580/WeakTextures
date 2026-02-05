-- =====================================================
-- WeakTextures Settings
-- =====================================================
local _, wt = ...

-- Get the RasuForge-Settings library
local RFSettings = LibStub("RasuForge-Settings")
if not RFSettings then return end

-- Function to create settings category
function wt:CreateSettingsCategory()
    local L = wt.L
    
    -- Create main settings category
    local category = RFSettings:NewCategory(wt.addonName)

    -- Addon Info Section
    category:CreateHeader(L.SETTINGS_HEADER_ABOUT, L.SETTINGS_DESC_ABOUT)

    -- Version Info Panel
    category:CreatePanel(
        "version-info",
        function(panel)
            if panel.initialized then return end
            panel.initialized = true
            
            local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOP", 0, -10)
            title:SetText(wt.addonName)
            wt:ApplyCustomFont(title, 16, "", true)
            
            local version = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            version:SetPoint("TOP", title, "BOTTOM", 0, -5)
            version:SetText(L.SETTINGS_VERSION .. wt.addonVersion)
            wt:ApplyCustomFont(version, 14)
            
            local description = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            description:SetPoint("TOP", version, "BOTTOM", 0, -10)
            description:SetWidth(400)
            description:SetText(L.SETTINGS_DESCRIPTION)
            description:SetJustifyH("CENTER")
            wt:ApplyCustomFont(description, 14)
            
            local reportBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            reportBtn:SetSize(150, 25)
            reportBtn:SetPoint("TOP", description, "BOTTOM", 0, -15)
            reportBtn:SetText(L.BUTTON_REPORT_ISSUES)
            
            local urlEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
            urlEditBox:SetSize(410, 25)
            urlEditBox:SetPoint("TOP", reportBtn, "BOTTOM", 0, -10)
            urlEditBox:SetText("https://github.com/seevik2580/WeakTextures/issues")
            urlEditBox:SetAutoFocus(false)
            urlEditBox:Hide()
            urlEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            urlEditBox:SetScript("OnEditFocusGained", function(self)
                self:HighlightText()
            end)
            urlEditBox:SetScript("OnEditFocusLost", function(self)
                self:HighlightText(0, 0)
            end)
            urlEditBox:SetScript("OnChar", function(self)
                self:SetText("https://github.com/seevik2580/WeakTextures/issues")
                self:HighlightText()
            end)
            
            reportBtn:SetScript("OnClick", function()
                if urlEditBox:IsShown() then
                    urlEditBox:Hide()
                else
                    urlEditBox:Show()
                    urlEditBox:SetFocus()
                    urlEditBox:HighlightText()
                end
            end)
        end,
        nil,
        "BackdropTemplate",
        150,
        nil,
        {"version", "about", "info"}
    )

    -- Contributors Panel (under About section)
    category:CreatePanel(
        "contributors-info",
        function(panel)
            if panel.initialized then return end
            panel.initialized = true
            
            local thankYou = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            thankYou:SetPoint("TOP", 0, -10)
            thankYou:SetWidth(400)
            thankYou:SetText(L.SETTINGS_CONTRIBUTORS_TEXT)
            thankYou:SetJustifyH("CENTER")
            wt:ApplyCustomFont(thankYou, 14)
            
            -- Author
            local authorLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            authorLabel:SetPoint("TOPLEFT", 20, -40)
            authorLabel:SetText(L.SETTINGS_CONTRIBUTORS_AUTHOR)
            wt:ApplyCustomFont(authorLabel, 14, "", true)
            
            local authorName = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            authorName:SetPoint("LEFT", authorLabel, "RIGHT", 5, 0)
            authorName:SetText("Seva-Drakthul (u/seevik)")
            wt:ApplyCustomFont(authorName, 14)
            
            -- Translation
            local translationLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            translationLabel:SetPoint("TOPLEFT", authorLabel, "BOTTOMLEFT", 0, -8)
            translationLabel:SetText(L.SETTINGS_CONTRIBUTORS_TRANSLATIONS)
            wt:ApplyCustomFont(translationLabel, 14, "", true)
            
            local translationNames = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            translationNames:SetPoint("LEFT", translationLabel, "RIGHT", 5, 0)
            translationNames:SetText("[deDE] u/Larsj_02")
            wt:ApplyCustomFont(translationNames, 14)
            
            -- Suggestions
            local suggestionsLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            suggestionsLabel:SetPoint("TOPLEFT", translationLabel, "BOTTOMLEFT", 0, -8)
            suggestionsLabel:SetText(L.SETTINGS_CONTRIBUTORS_SUGGESTIONS)
            wt:ApplyCustomFont(suggestionsLabel, 14, "", true)
            
            local suggestionsNames = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            suggestionsNames:SetPoint("LEFT", suggestionsLabel, "RIGHT", 5, 0)
            suggestionsNames:SetText("u/Larsj_02, Woxs-Drakthul")
            wt:ApplyCustomFont(suggestionsNames, 14)
            
            -- Inspired by
            local inspiredLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            inspiredLabel:SetPoint("TOPLEFT", suggestionsLabel, "BOTTOMLEFT", 0, -8)
            inspiredLabel:SetText(L.SETTINGS_CONTRIBUTORS_INSPIRED)
            wt:ApplyCustomFont(inspiredLabel, 14, "", true)
            
            local inspiredNames = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            inspiredNames:SetPoint("LEFT", inspiredLabel, "RIGHT", 5, 0)
            inspiredNames:SetWidth(300)
            inspiredNames:SetText("WeakAuras, Watchtower, RasuForge-Settings")
            inspiredNames:SetJustifyH("LEFT")
            inspiredNames:SetWordWrap(true)
            wt:ApplyCustomFont(inspiredNames, 14)
        end,
        nil,
        "BackdropTemplate",
        120,
        nil,
        {"contributors", "credits", "thanks"}
    )

    -- Language Settings Section
    category:CreateHeader(L.SETTINGS_HEADER_LANGUAGE, L.SETTINGS_DESC_LANGUAGE)
    -- Language Dropdown
    local function getLanguageOptions()
        local container = Settings.CreateControlTextContainer()
        for locale, name in pairs(wt.availableLocales) do
            container:Add(locale, name, "Set language to " .. name)
        end
        return container:GetData()
    end

    category:CreateDropdown(
        "LANGUAGE",
        "string",
        L.SETTINGS_LANGUAGE_LABEL,
        "enUS",
        function() 
            return WeakTexturesSettings.locale or wt:GetLocale()
        end,
        function(value)
            wt:SetLocale(value)
        end,
        getLanguageOptions,
        L.SETTINGS_LANGUAGE_SELECT_DESC
    )

    -- Language Info Panel
    category:CreatePanel(
        "language-info",
        function(panel)
            if panel.initialized then return end
            panel.initialized = true
            
            local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            infoText:SetPoint("TOPLEFT", 10, -10)
            infoText:SetPoint("TOPRIGHT", -10, -10)
            infoText:SetJustifyH("LEFT")
            infoText:SetWordWrap(true)
            infoText:SetText(
                wt.addonName .. L.SETTINGS_LANGUAGE_AUTO_DETECT .. "\n\n" ..
                L.SETTINGS_LANGUAGE_SUPPORTED .. "\n" ..
                L.SETTINGS_LANGUAGE_EN .. "\n" ..
                L.SETTINGS_LANGUAGE_DE .. "\n"
            )
            wt:ApplyCustomFont(infoText, 14)
        end,
        nil,
        "BackdropTemplate",
        120,
        nil,
        {"language", "locale", "translation"}
    )



    -- Profile Management Section
    category:CreateHeader(L.SETTINGS_HEADER_PROFILES, L.SETTINGS_DESC_PROFILES)

    -- Profile Dropdown
    local function getProfileOptions()
        local container = Settings.CreateControlTextContainer()
        local profiles = wt:GetAllProfiles()
        for _, name in ipairs(profiles) do
            container:Add(name, name, L.SETTINGS_PROFILE_SWITCH .. name)
        end
        return container:GetData()
    end

    category:CreateDropdown(
        "ACTIVE_PROFILE",
        "string",
        L.SETTINGS_PROFILE_ACTIVE,
        "Default",
        function() return wt:GetActiveProfile() end,
        function(value)
            wt:SaveCurrentProfile()
            wt:LoadProfile(value)
        end,
        getProfileOptions,
        L.SETTINGS_PROFILE_SELECT_DESC
    )

    -- Profile Management Panel
    category:CreatePanel(
        "profile-management",
        function(panel)
            if panel.initialized then return end
            panel.initialized = true
            
            -- New Profile Section
            local newProfileLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            newProfileLabel:SetPoint("TOPLEFT", 10, -10)
            newProfileLabel:SetText(L.SETTINGS_PROFILE_CREATE_LABEL)
            wt:ApplyCustomFont(newProfileLabel, 12)
            
            local newProfileEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
            newProfileEditBox:SetSize(200, 25)
            newProfileEditBox:SetPoint("TOPLEFT", newProfileLabel, "BOTTOMLEFT", 5, -5)
            newProfileEditBox:SetAutoFocus(false)
            
            local createBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            createBtn:SetSize(80, 25)
            createBtn:SetPoint("LEFT", newProfileEditBox, "RIGHT", 5, 0)
            createBtn:SetText(L.SETTINGS_BUTTON_CREATE)
            createBtn:SetScript("OnClick", function()
                local name = newProfileEditBox:GetText():trim()
                if wt:CreateProfile(name) then
                    newProfileEditBox:SetText("")
                end
            end)
            
            -- Copy Profile Section
            local copyProfileLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            copyProfileLabel:SetPoint("TOPLEFT", newProfileEditBox, "BOTTOMLEFT", -5, -20)
            copyProfileLabel:SetText(L.SETTINGS_PROFILE_COPY_LABEL)
            wt:ApplyCustomFont(copyProfileLabel, 12)
            
            local copyToEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
            copyToEditBox:SetSize(200, 25)
            copyToEditBox:SetPoint("TOPLEFT", copyProfileLabel, "BOTTOMLEFT", 5, -5)
            copyToEditBox:SetAutoFocus(false)
            
            local copyBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            copyBtn:SetSize(80, 25)
            copyBtn:SetPoint("LEFT", copyToEditBox, "RIGHT", 5, 0)
            copyBtn:SetText(L.SETTINGS_BUTTON_COPY)
            copyBtn:SetScript("OnClick", function()
                local toName = copyToEditBox:GetText():trim()
                local fromName = wt:GetActiveProfile()
                if wt:CopyProfile(fromName, toName) then
                    copyToEditBox:SetText("")
                end
            end)
            
            -- Rename Profile Section
            local renameProfileLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            renameProfileLabel:SetPoint("TOPLEFT", copyToEditBox, "BOTTOMLEFT", -5, -20)
            renameProfileLabel:SetText(L.SETTINGS_PROFILE_RENAME_LABEL)
            wt:ApplyCustomFont(renameProfileLabel, 12)
            
            local renameEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
            renameEditBox:SetSize(200, 25)
            renameEditBox:SetPoint("TOPLEFT", renameProfileLabel, "BOTTOMLEFT", 5, -5)
            renameEditBox:SetAutoFocus(false)
            
            local renameBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            renameBtn:SetSize(80, 25)
            renameBtn:SetPoint("LEFT", renameEditBox, "RIGHT", 5, 0)
            renameBtn:SetText(L.SETTINGS_BUTTON_RENAME)
            renameBtn:SetScript("OnClick", function()
                local newName = renameEditBox:GetText():trim()
                local oldName = wt:GetActiveProfile()
                if wt:RenameProfile(oldName, newName) then
                    renameEditBox:SetText("")
                end
            end)
            
            -- Delete Profile Button
            local deleteBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            deleteBtn:SetSize(150, 25)
            deleteBtn:SetPoint("TOPLEFT", renameEditBox, "BOTTOMLEFT", -5, -20)
            deleteBtn:SetText(L.SETTINGS_BUTTON_DELETE_PROFILE)
            deleteBtn:SetScript("OnClick", function()
                local profileName = wt:GetActiveProfile()
                StaticPopupDialogs["WEAKTEXTURES_DELETE_PROFILE"] = {
                    text = string.format(L.CONFIRM_DELETE_PROFILE, profileName),
                    button1 = L.SETTINGS_BUTTON_DELETE,
                    button2 = L.SETTINGS_BUTTON_CANCEL,
                    OnAccept = function()
                        wt:DeleteProfile(profileName)
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                    preferredIndex = 3,
                }
                StaticPopup_Show("WEAKTEXTURES_DELETE_PROFILE")
            end)
            
            -- Info text
            local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            infoText:SetPoint("TOPLEFT", deleteBtn, "BOTTOMLEFT", 0, -15)
            infoText:SetWidth(400)
            infoText:SetJustifyH("LEFT")
            infoText:SetText(L.SETTINGS_PROFILE_INFO)
            wt:ApplyCustomFont(infoText, 14)
            
            -- Export Profile Button
            local exportBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            exportBtn:SetSize(150, 25)
            exportBtn:SetPoint("TOPLEFT", infoText, "BOTTOMLEFT", 0, -15)
            exportBtn:SetText(L.SETTINGS_BUTTON_EXPORT_PROFILE)
            exportBtn:SetScript("OnClick", function()
                local profileName = wt:GetActiveProfile()
                local exportString = wt:ExportProfile(profileName)
                if exportString then
                    -- Show export dialog
                    if not wt.profileExportDialog then
                        wt.profileExportDialog = CreateFrame("Frame", "WeakTexturesProfileExportDialog", UIParent, "BasicFrameTemplateWithInset")
                        wt.profileExportDialog:SetSize(500, 400)
                        wt.profileExportDialog:SetPoint("CENTER")
                        wt.profileExportDialog:SetFrameStrata("DIALOG")
                        wt.profileExportDialog.title = wt.profileExportDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        wt.profileExportDialog.title:SetPoint("TOP", 0, -5)
                        wt:ApplyCustomFont(wt.profileExportDialog.title, 14, "", true)
                        
                        local scrollFrame = CreateFrame("ScrollFrame", nil, wt.profileExportDialog)
                        scrollFrame:SetPoint("TOPLEFT", 10, -30)
                        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 40)
                        
                        local scrollBar = CreateFrame("EventFrame", nil, wt.profileExportDialog, "MinimalScrollBar")
                        scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 5, 0)
                        scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 5, 0)
                        scrollBar:SetHideIfUnscrollable(false)
                        
                        local editBox = CreateFrame("EditBox", nil, scrollFrame)
                        editBox:SetMultiLine(true)
                        editBox:SetAutoFocus(false)
                        editBox:SetFontObject(GameFontHighlight)
                        editBox:SetWidth(scrollFrame:GetWidth() - 5)
                        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
                        scrollFrame:SetScrollChild(editBox)
                        
                        ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, scrollBar)
                        wt.profileExportDialog.editBox = editBox
                        wt.profileExportDialog.scrollFrame = scrollFrame
                        
                        local closeBtn = CreateFrame("Button", nil, wt.profileExportDialog, "UIPanelButtonTemplate")
                        closeBtn:SetSize(100, 25)
                        closeBtn:SetPoint("BOTTOM", 0, 10)
                        closeBtn:SetText(L.BUTTON_CLOSE)
                        closeBtn:SetScript("OnClick", function() wt.profileExportDialog:Hide() end)
                    end
                    
                    wt.profileExportDialog.title:SetText(L.SETTINGS_EXPORT_TITLE .. profileName)
                    wt.profileExportDialog.editBox:SetText(exportString)
                    wt.profileExportDialog.editBox:SetCursorPosition(0)
                    wt.profileExportDialog.editBox:HighlightText()
                    wt.profileExportDialog.editBox:SetFocus()
                    wt.profileExportDialog.scrollFrame:SetVerticalScroll(0)
                    wt.profileExportDialog:Show()
                end
            end)
            
            -- Import Profile Button
            local importBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            importBtn:SetSize(150, 25)
            importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 5, 0)
            importBtn:SetText("Import Profile")
            importBtn:SetScript("OnClick", function()
                -- Show import dialog
                if not wt.profileImportDialog then
                    wt.profileImportDialog = CreateFrame("Frame", "WeakTexturesProfileImportDialog", UIParent, "BasicFrameTemplateWithInset")
                    wt.profileImportDialog:SetSize(500, 450)
                    wt.profileImportDialog:SetPoint("CENTER")
                    wt.profileImportDialog:SetFrameStrata("DIALOG")
                    wt.profileImportDialog.title = wt.profileImportDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    wt.profileImportDialog.title:SetPoint("TOP", 0, -5)
                    wt:ApplyCustomFont(wt.profileImportDialog.title, 14, "", true)
                    wt.profileImportDialog.title:SetText(L.SETTINGS_IMPORT_TITLE)
                    
                    local scrollFrame = CreateFrame("ScrollFrame", nil, wt.profileImportDialog)
                    scrollFrame:SetPoint("TOPLEFT", 10, -30)
                    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 90)
                    
                    local scrollBar = CreateFrame("EventFrame", nil, wt.profileImportDialog, "MinimalScrollBar")
                    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 5, 0)
                    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 5, 0)
                    scrollBar:SetHideIfUnscrollable(false)
                    
                    local editBox = CreateFrame("EditBox", nil, scrollFrame)
                    editBox:SetMultiLine(true)
                    editBox:SetAutoFocus(false)
                    editBox:SetFontObject(GameFontHighlight)
                    editBox:SetWidth(scrollFrame:GetWidth() - 5)
                    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
                    scrollFrame:SetScrollChild(editBox)
                    
                    ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, scrollBar)
                    wt.profileImportDialog.editBox = editBox
                    wt.profileImportDialog.scrollFrame = scrollFrame
                    
                    local nameLabel = wt.profileImportDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    nameLabel:SetPoint("BOTTOMLEFT", 15, 55)
                    nameLabel:SetText(L.SETTINGS_PROFILE_NAME_LABEL)
                    wt:ApplyCustomFont(nameLabel, 12)
                    
                    local nameEditBox = CreateFrame("EditBox", nil, wt.profileImportDialog, "InputBoxTemplate")
                    nameEditBox:SetSize(300, 25)
                    nameEditBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 5, -5)
                    nameEditBox:SetAutoFocus(false)
                    wt.profileImportDialog.nameEditBox = nameEditBox
                    
                    local importAcceptBtn = wt:CreateButton(wt.profileImportDialog, 80, 25, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.BUTTON_IMPORT)
                    importAcceptBtn:SetPoint("BOTTOMRIGHT", -95, 25)
                    importAcceptBtn:SetScript("OnClick", function()
                        local importString = wt.profileImportDialog.editBox:GetText()
                        local newName = wt.profileImportDialog.nameEditBox:GetText():trim()
                        if newName == "" then newName = nil end
                        
                        if wt:ImportProfile(importString, newName) then
                            wt.profileImportDialog.editBox:SetText("")
                            wt.profileImportDialog.nameEditBox:SetText("")
                            wt.profileImportDialog:Hide()
                        end
                    end)
                    
                    local cancelBtn = wt:CreateButton(wt.profileImportDialog, 80, 25, wt.buttonNormal, wt.buttonHighlight, wt.buttonPushed, L.SETTINGS_BUTTON_CANCEL)
                    cancelBtn:SetPoint("BOTTOMRIGHT", -15, 25)
                    cancelBtn:SetScript("OnClick", function()
                        wt.profileImportDialog.editBox:SetText("")
                        wt.profileImportDialog.nameEditBox:SetText("")
                        wt.profileImportDialog.scrollFrame:SetVerticalScroll(0)
                        wt.profileImportDialog:Hide()
                    end)
                end
                
                wt.profileImportDialog.scrollFrame:SetVerticalScroll(0)
                wt.profileImportDialog:Show()
            end)
        end,
        nil,
        "BackdropTemplate",
        350,
        nil,
        {"profile", "profiles", "character", "export", "import"}
    )

    -- General Settings Section
    category:CreateHeader(L.SETTINGS_HEADER_GENERAL, L.SETTINGS_DESC_GENERAL)

    -- Debug Mode
    category:CreateCheckbox(
        "DEBUG_MODE",
        "boolean",
        L.SETTINGS_CHECKBOX_DEBUG,
        false,
        function() return WeakTexturesSettings.debugEnabled end,
        function(value)
            WeakTexturesSettings.debugEnabled = value
            wt.debugEnabled = value
        end,
        L.SETTINGS_DESC_DEBUG
    )

    -- UI Settings Section
    category:CreateHeader(L.SETTINGS_HEADER_UI, L.SETTINGS_DESC_UI)

    -- Frame Scale
    category:CreateSlider(
        "FRAME_SCALE",
        "number",
        L.SETTINGS_UI_SCALE,
        1.0,
        function() return WeakTexturesSettings.frameScale or 1.0 end,
        function(value)
            WeakTexturesSettings.frameScale = value
            if wt.frame then
                wt.frame:SetScale(value)
            end
        end,
        0.5, 2.0, 0.1,
        string.format(L.SETTINGS_DESC_UI_SCALE, wt.addonName)
    )

    -- Advanced Settings Section
    category:CreateHeader(L.SETTINGS_HEADER_ADVANCED, L.SETTINGS_DESC_ADVANCED)

    -- Rebuild Events Button
    category:CreateButton(
        L.SETTINGS_BUTTON_REBUILD_EVENTS,
        L.SETTINGS_BUTTON_REBUILD_EVENTS_SHORT,
        function()
            if wt.RebuildAddonEventsTable then
                wt:RebuildAddonEventsTable()
                print("|cffff0000[" .. wt.addonName .. "]|r ADDON_EVENTS table rebuilt successfully.")
            end
        end,
        L.SETTINGS_DESC_REBUILD_EVENTS,
        true
    )

    -- Clear All Presets Button (with warning)
    category:CreateButton(
        L.SETTINGS_BUTTON_CLEAR_DATA,
        L.SETTINGS_BUTTON_CLEAR_PRESETS,
        function()
            StaticPopupDialogs["WEAKTEXTURES_CLEAR_ALL"] = {
                text = L.SETTINGS_CONFIRM_CLEAR_ALL,
                button1 = L.SETTINGS_BUTTON_DELETE_EVERYTHING,
                button2 = L.SETTINGS_BUTTON_CANCEL,
                OnAccept = function()
                    -- Clear WeakTexturesDB (runtime cache)
                    WeakTexturesDB.presets = {}
                    WeakTexturesDB.groups = {}
                    WeakTexturesDB.ADDON_EVENTS = {}
                    wt.activeFramesByPreset = {}
                    
                    -- Clear active profile in WeakTexturesProfiles
                    local profileName = wt:GetActiveProfile()
                    if WeakTexturesProfiles and WeakTexturesProfiles[profileName] then
                        WeakTexturesProfiles[profileName].presets = {}
                        WeakTexturesProfiles[profileName].groups = {}
                        WeakTexturesProfiles[profileName].ADDON_EVENTS = {}
                    end
                    
                    -- Refresh UI
                    if wt.RefreshPresetList then
                        wt:RefreshPresetList()
                    end
                    if wt.allDefault then
                        wt:allDefault()
                    end
                    print("|cffff0000[" .. wt.addonName .. "]|r All data cleared.")
                    C_UI.Reload()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("WEAKTEXTURES_CLEAR_ALL")
        end,
        L.SETTINGS_WARNING_DELETE_ALL,
        true
    )

    -- Reload UI Button
    category:CreateButton(
        L.SETTINGS_BUTTON_RELOAD,
        L.SETTINGS_BUTTON_RELOAD_UI,
        function() C_UI.Reload() end,
        L.SETTINGS_DESC_RELOAD,
        true
    )


    -- Texture Settings Section
    category:CreateHeader(L.SETTINGS_HEADER_TEXTURES, L.SETTINGS_DESC_TEXTURES)

    -- Auto-register custom textures
    category:CreateCheckbox(
        "AUTO_REGISTER_CUSTOM_TEXTURES",
        "boolean",
        L.SETTINGS_CHECKBOX_AUTO_REGISTER,
        true,
        function()
            return WeakTexturesSettings.autoRegisterCustomTextures
        end,
        function(value)
            WeakTexturesSettings.autoRegisterCustomTextures = value
        end,
        L.SETTINGS_DESC_AUTO_REGISTER
    )

    -- Generate Example Presets Button
    category:CreateButton(
        L.SETTINGS_BUTTON_GENERATE_EXAMPLES,
        L.SETTINGS_BUTTON_CREATE_EXAMPLES,
        function()
            wt:ShowCreateExamplesDialog()
        end,
        L.SETTINGS_DESC_GENERATE_EXAMPLES .. wt.addonName,
        true
    )

    -- Font Settings Section
    category:CreateHeader(L.SETTINGS_HEADER_FONT, L.SETTINGS_DESC_FONT)

    -- Font Selection
    local function getFontOptions()
        local container = Settings.CreateControlTextContainer()
        local fonts = wt.LSM:List("font")
        for _, fontName in ipairs(fonts) do
            container:Add(fontName, fontName, "Use " .. fontName .. " font")
        end
        return container:GetData()
    end

    category:CreateDropdown(
        "FONT",
        "string",
        L.SETTINGS_FONT_LABEL,
        "PT Sans Narrow Regular",
        function()
            return WeakTexturesSettings.font or wt.customFont
        end,
        function(value)
            WeakTexturesSettings.font = value
            wt.customFont = value
            -- Apply font to existing UI if it exists
            if wt.ApplyCustomFonts then
                wt:ApplyCustomFonts()
            end
        end,
        getFontOptions,
        L.SETTINGS_DESC_FONT_SELECT
    )

    -- Bold Font Selection
    category:CreateDropdown(
        "FONT_BOLD",
        "string",
        L.SETTINGS_BOLD_FONT,
        "PT Sans Narrow Bold",
        function()
            return WeakTexturesSettings.fontBold or wt.customFontBold
        end,
        function(value)
            WeakTexturesSettings.fontBold = value
            wt.customFontBold = value
            -- Apply font to existing UI if it exists
            if wt.ApplyCustomFonts then
                wt:ApplyCustomFonts()
            end
        end,
        getFontOptions,
        L.SETTINGS_DESC_BOLD_FONT
    )

-- Store category reference for programmatic access
    wt.settingsCategory = category
end

-- Function to open settings
function wt:OpenSettings(scrollToElement)
    if InCombatLockdown() then
        print("|cffff0000[" .. wt.addonName .. "]|r " .. wt.L.MESSAGE_CANNOT_OPEN_SETTINGS_IN_COMBAT)
        return
    end
    if self.settingsCategory then
        self.settingsCategory:Open(scrollToElement)
    end
end
