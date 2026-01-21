-- =====================================================
-- WeakTextures Groups
-- =====================================================
local _, wt = ...

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

    for groupPath in pairs(WeakTexturesDB.groups or {}) do
        getNode(groupPath)
    end

    for presetName, preset in pairs(WeakTexturesDB.presets) do
        local path = preset.group or "Ungrouped"
        local node = getNode(path)
        table.insert(node.presets, presetName)
    end

    return tree
end

function wt:RenderGroupNode(node, name, depth, fullPath)
    depth = depth or 0
    fullPath = fullPath or name

    self._renderY = self._renderY or 0

    -- Add delimiter line for Ungrouped and Disabled
    --[[
    if name == "Disabled" then
        local line = wt.content:CreateTexture(nil, "ARTWORK")
        line:SetSize(220, 3)
        line:SetPoint("TOPLEFT", 0, -self._renderY)
        line:SetColorTexture(0.5, 0.5, 0.5, 1) -- Gray line
        table.insert(wt.presetButtons, line)
        self._renderY = self._renderY + 3
    end
    --]]

    local indent = depth * 12
    local expanded = wt.groupState[fullPath] ~= false

    -- GROUP BUTTON
    local count = wt:CountPresetsInGroup(fullPath)

    local header = CreateFrame("Button", nil, wt.content, "UIPanelButtonTemplate")
    header:SetSize(170 - indent, 22)
    header:SetPoint("TOPLEFT", indent, -self._renderY)
    header:SetText(
        (expanded and "- " or "+ ")
        .. name
        .. " (" .. count .. ")"
    )

    local fs = header:GetFontString()
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("MIDDLE")
    fs:ClearAllPoints()
    fs:SetPoint("LEFT", header, "LEFT", 10, 0)

    header:SetScript("OnClick", function()
        wt.groupState[fullPath] = not expanded
        wt:RefreshPresetList()
    end)


    table.insert(wt.presetButtons, header)

    -- CLONE GROUP BUTTON
    local cloneGroup = CreateFrame("Button", nil, wt.content, "UIPanelButtonTemplate")
    cloneGroup:SetSize(20, 20)
    cloneGroup:SetPoint("LEFT", header, "RIGHT", 2, 0)
    cloneGroup:SetText("C")
    cloneGroup:GetFontString():SetFontObject("GameFontNormalSmall")

    cloneGroup:SetScript("OnClick", function()
        local newPath = wt:CloneGroupPath(fullPath)
        wt.groupState[newPath] = true
        wt:RefreshPresetList()
    end)

    table.insert(wt.presetButtons, cloneGroup)

    if name == "Disabled" or name == "Ungrouped" then
        cloneGroup:Hide()
    end

    -- DELETE GROUP BUTTON
    local delGroup = CreateFrame("Button", nil, wt.content, "UIPanelButtonTemplate")
    delGroup:SetSize(20, 20)
    delGroup:SetPoint("LEFT", cloneGroup, "RIGHT", 2, 0)
    delGroup:SetText("X")

    delGroup:GetFontString():SetFontObject("GameFontNormalSmall")
    delGroup:GetFontString():SetTextColor(1, 0.2, 0.2)

    delGroup:SetScript("OnClick", function()
        wt:DeleteGroupPath(fullPath)
        wt:allDefault()
        wt:RefreshPresetList()
    end)

    table.insert(wt.presetButtons, delGroup)

    if name == "Disabled" or name == "Ungrouped" then
        delGroup:Hide()
    end

    self._renderY = self._renderY + 24
    if not expanded then return end

    -- CHILD GROUPS
    for childName, childNode in pairs(node.children) do
        wt:RenderGroupNode(
            childNode,
            childName,
            depth + 1,
            fullPath .. "/" .. childName
        )
    end

    -- PRESETS
    table.sort(node.presets)
    for _, presetName in ipairs(node.presets) do
        -- PRESET BUTTON TO SELECT PRESET
        local b = CreateFrame("Button", nil, wt.content, "BackdropTemplate, UIPanelButtonTemplate")
        b:SetSize(150 - indent, 20)
        b:SetPoint("TOPLEFT", indent + 20, -self._renderY)
        local icon = wt:GetConditionIconForPreset(presetName)

        if icon then
            b:SetText("|T" .. icon .. ":14:14:0:-1|t " .. presetName)
        else
            b:SetText(presetName)
        end

        local bfs = b:GetFontString()
        bfs:SetJustifyH("LEFT")
        bfs:SetPoint("LEFT", b, "LEFT", 10, 0)

        if wt.selectedPreset == presetName then
            b:SetBackdrop(wt.selectedBackdrops)
            b:SetBackdropColor(0, 1, 0, 0.35)
        end

        b:SetScript("OnClick", function()
            wt.selectedPreset = presetName
            wt:LoadPresetIntoFields(presetName)
            wt:RefreshPresetList()
            wt:Debug("Selected preset:", wt.selectedPreset)
        end)

        table.insert(wt.presetButtons, b)

        -- CLONE PRESET
        local cloneBtn = CreateFrame("Button", nil, wt.content, "UIPanelButtonTemplate")
        cloneBtn:SetSize(20, 20)
        cloneBtn:SetPoint("LEFT", b, "RIGHT", 2, 0)
        cloneBtn:SetText("C")
        cloneBtn:GetFontString():SetFontObject("GameFontNormalSmall")

        cloneBtn:SetScript("OnClick", function()
            local base = presetName
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

            WeakTexturesDB.presets[newName] =
                DeepCopy(WeakTexturesDB.presets[presetName])

            wt.selectedPreset = newName
            wt:RefreshPresetList()
        end)

        table.insert(wt.presetButtons, cloneBtn)

        -- DELETE PRESET
        local delBtn = CreateFrame("Button", nil, wt.content, "UIPanelButtonTemplate")
        delBtn:SetSize(20, 20)
        delBtn:SetPoint("LEFT", cloneBtn, "RIGHT", 2, 0)
        delBtn:SetText("X")
        delBtn:GetFontString():SetFontObject("GameFontNormalSmall")
        delBtn:GetFontString():SetTextColor(1, 0.2, 0.2)

        delBtn:SetScript("OnClick", function()
            wt:HideTextureFrame(presetName)
            WeakTexturesDB.presets[presetName] = nil
            if wt.selectedPreset == presetName then
                wt:allDefault()
            end
            wt:RefreshPresetList()
        end)

        table.insert(wt.presetButtons, delBtn)

        self._renderY = self._renderY + 22
    end
end

function wt:IsPresetInGroupPath(preset, groupPath)
    if not preset.group then return false end
    return preset.group == groupPath
        or preset.group:match("^" .. groupPath .. "/")
end

function wt:DeleteGroupPath(groupPath)
    -- Remove presets in this group subtree
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if self:IsPresetInGroupPath(preset, groupPath) then
            self:HideTextureFrame(presetName)
            WeakTexturesDB.presets[presetName] = nil
        end
    end

    -- Remove group entries
    for path in pairs(WeakTexturesDB.groups) do
        if path == groupPath or path:match("^" .. groupPath .. "/") then
            WeakTexturesDB.groups[path] = nil
        end
    end

    -- Cleanup UI state
    wt.groupState[groupPath] = nil
    if wt.selectedGroup == groupPath then
        wt.selectedGroup = nil
        wt.selectedPreset = nil
        wt:allDefault()
    end
end

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

function wt:CountPresetsInGroup(groupPath)
    local count = 0

    for _, preset in pairs(WeakTexturesDB.presets) do
        -- UNGROUPED
        if groupPath == "Ungrouped" then
            if not preset.group or preset.group == "" then
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

function wt:CollapseAllGroups()
    wipe(wt.groupState)

    for path in pairs(WeakTexturesDB.groups or {}) do
        wt.groupState[path] = false
    end

    wt.groupState["Ungrouped"] = false
end

function wt:GetClassIcon(classFile)
    if not classFile then return nil end
    return "Interface\\ICONS\\ClassIcon_" .. classFile
end

function wt:GetConditionIconForPreset(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.conditions then
        return nil
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