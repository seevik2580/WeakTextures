-- =====================================================
-- WeakTextures Import/Export
-- =====================================================
local _, wt = ...

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
        else
            value = tostring(v)
        end

        table.insert(lines, pad .. "  " .. key .. " = " .. value .. ",")
    end

    table.insert(lines, pad .. "}")
    return table.concat(lines, "\n")
end

function wt:DeserializeTable(str)
    local fn = loadstring("return " .. str)
    if not fn then return nil end
    local ok, result = pcall(fn)
    if ok and type(result) == "table" then
        return result
    end
end

function wt:Import()
    local data = wt:DeserializeTable(wt.exportBox:GetText())
    if not data then
        wt:Debug("Invalid import string")
        return
    end
    for name, group in pairs(data.groups) do
        WeakTexturesDB.groups[name] = group
    end
    for name, preset in pairs(data.presets) do
        local newName = name
        local i = 1
        while WeakTexturesDB.presets[newName] do
            i = i + 1
            newName = name .. " (" .. i .. ")"
        end

        WeakTexturesDB.presets[newName] = preset
        wt:ApplyPreset(newName)
    end
    wt.exportBox:SetText("")
    wt:RefreshPresetList()
end

function wt:Export()
    local data = {
        presets = WeakTexturesDB.presets,
        groups = WeakTexturesDB.groups,
    }
    local serialized = wt:SerializeTable(data)
    wt.exportBox:SetText(serialized)
end

