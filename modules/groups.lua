-- =====================================================
-- WeakTextures Groups
-- =====================================================
local _, wt = ...
local L = wt.L

-- Build a tree structure of all groups and presets
---@return TreeNode
function wt:BuildGroupTree()
    local tree = { children = {}, presets = {} }

    local function getNode(path)
        local node = tree
        if not path or path == "" then return node end

        for part in string.gmatch(path, "[^/]+") do
            node.children[part] = node.children[part] or { children = {}, presets = {} }
            node = node.children[part]
        end
        return node
    end

    tree.children["Ungrouped"] = tree.children["Ungrouped"] or { children = {}, presets = {} }
    tree.children["Disabled"] = tree.children["Disabled"] or { children = {}, presets = {} }

    for groupPath in pairs(WeakTexturesDB.groups or {}) do
        getNode(groupPath)
    end

    for presetName, preset in pairs(WeakTexturesDB.presets) do
        local path = preset.group
        -- Empty string or nil means Ungrouped
        if not path or path == "" then
            path = "Ungrouped"
        end
        local node = getNode(path)
        table.insert(node.presets, presetName)
    end

    return tree
end

-- Show a context menu for a group or preset
---@param owner Frame
---@param name string
---@param fullPath string|nil
function wt:ShowContextMenu(owner, name, fullPath)
    local isPreset = WeakTexturesDB.presets[name] ~= nil
    local isDisabledGroup = (name == "Disabled")
    local isUngroupedGroup = (name == "Ungrouped")
    
    local function GenerateMenu(_, rootDescription)
        rootDescription:CreateTitle(name)
        
        -- For Disabled group, only show Export and Delete options
        if isDisabledGroup then
            rootDescription:CreateButton("Export", function()
                wt:ExportGroup(fullPath)
            end)
            rootDescription:CreateButton("Delete", function()
                StaticPopup_Show("WEAKTEXTURES_DELETE_DISABLED_PRESETS")
            end)
            return
        end
        
        -- For Ungrouped group, only show Export and Delete options
        if isUngroupedGroup then
            rootDescription:CreateButton("Export", function()
                wt:ExportGroup(fullPath)
            end)
            rootDescription:CreateButton("Delete", function()
                StaticPopup_Show("WEAKTEXTURES_DELETE_UNGROUPED_PRESETS")
            end)
            return
        end
        
        -- Copy option
        rootDescription:CreateButton("Copy", function()
            if isPreset then
                local base = name
                local newName = base
                local i = 2

                while WeakTexturesDB.presets[newName] do
                    newName = base .. " (" .. i .. ")"
                    i = i + 1
                end

                local function DeepCopy(tbl)
                    local c = {}
                    for k, v in pairs(tbl) do
                        c[k] = type(v) == "table" and DeepCopy(v) or v
                    end
                    return c
                end

                -- Deep copy the preset
                local copiedPreset = DeepCopy(WeakTexturesDB.presets[name])
                WeakTexturesDB.presets[newName] = copiedPreset

                -- Update ADDON_EVENTS table for the new preset
                if copiedPreset.enabled then
                    wt:UpdateAddonEventsForPreset(newName, copiedPreset)
                end

                -- Regenerate event handles since they need to be registered for the new preset
                if copiedPreset.enabled and copiedPreset.advancedEnabled and copiedPreset.events then
                    wt:RegisterPresetEvents(newName)
                end

                -- Ensure instancePool structure exists if source preset had it
                if copiedPreset.instancePool then
                    -- Initialize frame pool for the new preset if multi-instance is enabled
                    if copiedPreset.instancePool.enabled then
                        wt:InitializeFramePool(newName)
                    end
                end

                wt.selectedPreset = newName
                wt.frame.right:EnableMouse(true)
                wt.frame.right:Show()
                wt:LoadPresetIntoFields(newName)
                wt:RefreshPresetList()
            else
                local newPath = wt:CloneGroupPath(fullPath)
                wt.groupState[newPath] = true
                wt:RefreshPresetList()
            end
        end)
        
        -- Export option
        rootDescription:CreateButton("Export", function()
            if isPreset then
                wt:ExportPreset(name)
            else
                wt:ExportGroup(fullPath)
            end
        end)
        
        -- Delete option
        rootDescription:CreateButton("Delete", function()
            if isPreset then
                StaticPopup_Show("WEAKTEXTURES_DELETE_PRESET", name, nil, name)
            else
                StaticPopup_Show("WEAKTEXTURES_DELETE_GROUP", fullPath, nil, fullPath)
            end
        end)
    end
    
    MenuUtil.CreateContextMenu(owner, GenerateMenu)
end

-- Check if a preset is in a group path or its subgroups
---@param preset Preset
---@param groupPath string
---@return boolean
function wt:IsPresetInGroupPath(preset, groupPath)
    if not preset.group then return false end
    local escapedPath = groupPath:gsub("([%%%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
    return preset.group == groupPath
        or preset.group:match("^" .. escapedPath .. "/")
end

-- Delete a group and all its presets and subgroups
---@param groupPath string
function wt:DeleteGroupPath(groupPath)
    -- Remove presets in this group subtree
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if self:IsPresetInGroupPath(preset, groupPath) then
            self:HideTextureFrame(presetName)
            WeakTexturesDB.presets[presetName] = nil
        end
    end

    -- Remove group entries
    local escapedPath = groupPath:gsub("([%%%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
    for path in pairs(WeakTexturesDB.groups) do
        if path == groupPath or path:match("^" .. escapedPath .. "/") then
            WeakTexturesDB.groups[path] = nil
        end
    end

    -- Cleanup UI state
    wt.groupState[groupPath] = nil
end

-- Clone a group path with all its presets and subgroups
---@param sourcePath string
---@return string
function wt:CloneGroupPath(sourcePath)
    local base = sourcePath .. " (Copy)"
    local targetPath = base
    local i = 2

    while WeakTexturesDB.groups[targetPath] do
        targetPath = base .. " " .. i
        i = i + 1
    end

    -- Clone group entries
    for path in pairs(WeakTexturesDB.groups) do
        if path == sourcePath or path:match("^" .. sourcePath .. "/") then
            local suffix = path:sub(#sourcePath + 1)
            WeakTexturesDB.groups[targetPath .. suffix] = true
        end
    end

    -- Clone presets
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if preset.group and (
            preset.group == sourcePath or
            preset.group:match("^" .. sourcePath .. "/")
        ) then
            -- Generate new preset name
            local newName = presetName
            local n = 2
            while WeakTexturesDB.presets[newName] do
                newName = presetName .. " (" .. n .. ")"
                n = n + 1
            end

            -- Deep copy preset
            local function DeepCopy(tbl)
                local c = {}
                for k, v in pairs(tbl) do
                    c[k] = type(v) == "table" and DeepCopy(v) or v
                end
                return c
            end

            local copy = DeepCopy(preset)

            -- Rewrite group path
            copy.group = preset.group:gsub(
                "^" .. sourcePath,
                targetPath
            )

            WeakTexturesDB.presets[newName] = copy
        end
    end

    return targetPath
end

-- Count the number of presets in a group (including subgroups)
---@param groupPath string
---@return number
function wt:CountPresetsInGroup(groupPath)
    local count = 0

    for _, preset in pairs(WeakTexturesDB.presets) do
        -- UNGROUPED
        if groupPath == "Ungrouped" then
            if not preset.group or preset.group == "" then
                count = count + 1
            end
        elseif groupPath == "Disabled" then
            if preset.enabled == false then
                count = count + 1
            end
        else
            -- NORMAL GROUPS + SUBGROUPS
            if preset.group then
                if preset.group == groupPath
                   or preset.group:match("^" .. groupPath .. "/") then
                    count = count + 1
                end
            end
        end

    end

    return count
end

-- Collapse all groups in the tree
function wt:CollapseAllGroups()
    wipe(wt.groupState)

    for path in pairs(WeakTexturesDB.groups or {}) do
        wt.groupState[path] = false
    end

    wt.groupState["Ungrouped"] = false
end

-- Get the icon path for a class
---@param classFile string|nil
---@return string|nil iconPath
function wt:GetClassIcon(classFile)
    if not classFile then return nil end
    return "Interface\\ICONS\\ClassIcon_" .. classFile
end

-- Get the condition icon for a preset (spec, class, or advanced)
---@param presetName string
---@return string|nil iconPath
function wt:GetConditionIconForPreset(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.conditions then
        return nil
    end

    if preset.advancedEnabled then
        -- Use a gear icon for advanced/scripted conditions
        return "Interface\\Icons\\Trade_Engineering"
    end

    -- Spec has priority
    if preset.conditions.spec then
        local _, _, _, icon = GetSpecializationInfoByID(preset.conditions.spec)
        return icon
    end

    -- Fallback to class
    if preset.conditions.class then
        return self:GetClassIcon(preset.conditions.class)
    end

    

    return nil
end