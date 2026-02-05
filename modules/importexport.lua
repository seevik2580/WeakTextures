-- =====================================================
-- WeakTextures Import/Export
-- =====================================================
local _, wt = ...
local L = wt.L

-- Serialize a table to a Lua string representation
---@param tbl table
---@param indent number|nil
---@return string
function wt:SerializeTable(tbl, indent)
    indent = indent or 0
    local pad = string.rep(" ", indent)
    local lines = { "{" }

    for k, v in pairs(tbl) do
        local key = type(k) == "number" and "["..k.."]" or string.format("[%q]", k)
        local value

        if type(v) == "table" then
            value = self:SerializeTable(v, indent + 2)
        elseif type(v) == "string" then
            value = string.format("%q", v)
        elseif type(v) == "function" then
            -- Skip functions - they cannot be serialized properly
            value = nil
        elseif type(v) == "boolean" or type(v) == "number" then
            value = tostring(v)
        else
            -- Skip other types that cannot be serialized
            value = nil
        end

        if value then
            table.insert(lines, pad .. "  " .. key .. " = " .. value .. ",")
        end
    end

    table.insert(lines, pad .. "}")
    return table.concat(lines, "\n")
end

-- Deserialize a Lua string into a table
---@param str string
---@return table|nil deserialized
function wt:DeserializeTable(str)
    local fn = loadstring("return " .. str)
    if not fn then return nil end
    local ok, result = pcall(fn)
    if ok and type(result) == "table" then
        return result
    end
end

-- Import presets and groups from a serialized string
---@param str string
function wt:ImportFromString(str)
    local data = self:DeserializeTable(str)
    if not data then
        self:Debug("Invalid import string")
        return
    end
    
    -- Handle both new format (with groups/presets) and old format (just presets)
    local groups = data.groups or {}
    local presets = data.presets or data
    
    -- Import groups
    for name, group in pairs(groups) do
        if not WeakTexturesDB.groups[name] then
            WeakTexturesDB.groups[name] = group
        end
    end
    
    -- Import presets (create duplicates if exists)
    for name, preset in pairs(presets) do
        -- Skip if this is not a preset table (e.g., groups key)
        if type(preset) == "table" and name ~= "groups" then
            -- Migrate v1 presets to v2 if necessary
            if not wt:IsPresetV2(preset) then
                wt:MigratePresetToV2(preset)
            end
            
            local newName = name
            local i = 2
            
            while WeakTexturesDB.presets[newName] do
                newName = name .. " (" .. i .. ")"
                i = i + 1
            end

            WeakTexturesDB.presets[newName] = preset
            
            -- Get texture path from new format or old format (textures array)
            local texturePath = preset.texturePath or (preset.textures and preset.textures[1] and preset.textures[1].texture)
            
            -- Auto-register custom texture if enabled and it's not from LSM
            if WeakTexturesSettings.autoRegisterCustomTextures and texturePath then
                local isFromLSM = false
                
                -- Check if texture is already in LSM categories
                for _, category in ipairs({"background", "border", "statusbar"}) do
                    local textures = wt.LSM:List(category)
                    for _, textureName in ipairs(textures) do
                        local lsmPath = wt.LSM:Fetch(category, textureName)
                        if lsmPath == texturePath then
                            isFromLSM = true
                            break
                        end
                    end
                    if isFromLSM then break end
                end
                
                -- Register only if it's not from LSM and not already registered
                if not isFromLSM then
                    wt:RegisterCustomTexture(texturePath)
                end
            end
            
            -- Set enabled to true if not explicitly set to false
            if preset.enabled == nil then
                preset.enabled = true
            end
            
            -- Update ADDON_EVENTS table for imported preset
            if preset.enabled then
                wt:UpdateAddonEventsForPreset(newName, preset)
            end
            
            -- Regenerate event handles since functions cannot be serialized
            if preset.enabled and preset.advancedEnabled and preset.events then
                wt:RegisterPresetEvents(newName)
            end
            
            -- Enable multi-instance mode if specified
            if preset.instancePool and preset.instancePool.enabled then
                WeakTexturesAPI:EnableMultiInstance(newName)
            end
            
            -- Don't auto-show multi-instance presets or advanced presets - let events trigger them
            if not (preset.instancePool and preset.instancePool.enabled) and not preset.advancedEnabled then
                if wt:PresetMatchesConditions(newName) then
                    if preset.type and preset.type == "motion" then
                        wt:PlayStopMotion(newName, preset.textures[1].anchor, preset.textures[1].texture, 
                            preset.textures[1].width, preset.textures[1].height, preset.textures[1].x, preset.textures[1].y, 
                            preset.columns or 1, preset.rows or 1, preset.totalFrames or 1, preset.fps or 30)
                    else
                        -- Use V2 format (textures array) or V1 format (individual properties)
                        local anchor = preset.textures and preset.textures[1] and preset.textures[1].anchor or preset.anchorName
                        local texture = preset.textures and preset.textures[1] and preset.textures[1].texture or preset.texturePath
                        local width = preset.textures and preset.textures[1] and preset.textures[1].width or preset.width
                        local height = preset.textures and preset.textures[1] and preset.textures[1].height or preset.height
                        local x = preset.textures and preset.textures[1] and preset.textures[1].x or preset.x
                        local y = preset.textures and preset.textures[1] and preset.textures[1].y or preset.y
                        wt:CreateAnchoredTexture(newName, anchor, texture, width, height, x, y)
                    end
                else
                    wt:HideTextureFrame(newName)
                end
            end
        end
    end
    self:RefreshPresetList()
    --self:ApplyAllPresets()
end

-- Legacy import function for backwards compatibility
function wt:Import()
    self:ImportFromString(wt.exportBox:GetText())
    wt.exportBox:SetText("")
end

-- Export all presets and groups
function wt:Export()
    local data = {
        presets = WeakTexturesDB.presets,
        groups = WeakTexturesDB.groups,
    }
    local serialized = wt:SerializeTable(data)
    wt.exportBox:SetText(serialized)
end

-- Export a single preset to a serialized string
---@param presetName string
function wt:ExportPreset(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then return end
    
    local data = {
        presets = {
            [presetName] = preset
        },
        groups = {}
    }
    
    -- Include group if preset has one
    if preset.group and preset.group ~= "" then
        data.groups[preset.group] = true
    end
    
    local serialized = self:SerializeTable(data)
    self:ShowExportDialog(serialized, "Preset: " .. presetName)
end

-- Export a group and all its presets and subgroups
---@param groupPath string
function wt:ExportGroup(groupPath)
    local data = {
        presets = {},
        groups = {}
    }
    
    -- Add the group and all subgroups
    for path in pairs(WeakTexturesDB.groups) do
        if path == groupPath or path:match("^" .. groupPath .. "/") then
            data.groups[path] = true
        end
    end
    
    -- Add all presets in this group and subgroups
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if preset.group and (preset.group == groupPath or preset.group:match("^" .. groupPath .. "/")) then
            data.presets[presetName] = preset
        end
    end
    
    local serialized = self:SerializeTable(data)
    self:ShowExportDialog(serialized, "Group: " .. groupPath)
end

-- Show export dialog with serialized data
---@param text string
---@param title string
function wt:ShowExportDialog(text, title)
    -- Create export dialog if it doesn't exist
    if not self.exportDialog then
        self.exportDialog = CreateFrame("Frame", "WeakTexturesExportDialog", UIParent, "BackdropTemplate")
        self.exportDialog:SetSize(500, 350)
        self.exportDialog:SetPoint("CENTER")
        self.exportDialog:SetFrameStrata("DIALOG")
        self.exportDialog:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        self.exportDialog:EnableMouse(true)
        self.exportDialog:SetMovable(true)
        self.exportDialog:RegisterForDrag("LeftButton")
        self.exportDialog:SetScript("OnDragStart", function(self) self:StartMoving() end)
        self.exportDialog:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        
        self.exportDialog.title = self.exportDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.exportDialog.title:SetPoint("TOP", 0, -20)
        
        self.exportDialog.scrollFrame = CreateFrame("ScrollFrame", nil, self.exportDialog)
        self.exportDialog.scrollFrame:SetPoint("TOPLEFT", 20, -50)
        self.exportDialog.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)
        self.exportDialog.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
            local scrollBar = wt.exportDialog.scrollBar
            if scrollBar:IsVisible() then
                local currentScroll = scrollBar:GetScrollPercentage() or 0
                local step = wt.scrollSteps
                scrollBar:SetScrollPercentage(currentScroll - (delta * step))
            end
        end)
        
        self.exportDialog.scrollBar = CreateFrame("EventFrame", nil, self.exportDialog, "MinimalScrollBar")
        self.exportDialog.scrollBar:SetPoint("TOPLEFT", self.exportDialog.scrollFrame, "TOPRIGHT", 2, 0)
        self.exportDialog.scrollBar:SetPoint("BOTTOMLEFT", self.exportDialog.scrollFrame, "BOTTOMRIGHT", 2, 0)
        self.exportDialog.scrollBar:SetHideIfUnscrollable(true)
        
        self.exportDialog.editBox = CreateFrame("EditBox", nil, self.exportDialog.scrollFrame)
        self.exportDialog.editBox:SetMultiLine(true)
        self.exportDialog.editBox:SetFontObject(GameFontHighlight)
        self.exportDialog.editBox:SetWidth(self.exportDialog.scrollFrame:GetWidth())
        self.exportDialog.editBox:SetAutoFocus(false)
        self.exportDialog.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        self.exportDialog.scrollFrame:SetScrollChild(self.exportDialog.editBox)
        
        ScrollUtil.InitScrollFrameWithScrollBar(self.exportDialog.scrollFrame, self.exportDialog.scrollBar)
        
        self.exportDialog.closeButton = CreateFrame("Button", nil, self.exportDialog, "UIPanelButtonTemplate")
        self.exportDialog.closeButton:SetSize(100, 30)
        self.exportDialog.closeButton:SetPoint("BOTTOM", 0, 20)
        self.exportDialog.closeButton:SetText(L.BUTTON_CLOSE)
        self.exportDialog.closeButton:SetScript("OnClick", function()
            self.exportDialog:Hide()
        end)
    end
    
    self.exportDialog.title:SetText(title)
    self.exportDialog.editBox:SetText(text)
    self.exportDialog.editBox:HighlightText()
    self.exportDialog.editBox:SetFocus()
    self.exportDialog:Show()
end

