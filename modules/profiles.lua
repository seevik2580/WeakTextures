-- =====================================================
-- WeakTextures Profiles System
-- =====================================================
local _, wt = ...
local L = wt.L

---Initialize the profile system
function wt:InitializeProfiles()
    -- Migrate old data from WeakTexturesDB if it exists (for users upgrading from old version)
    -- WeakTexturesDB is no longer a SavedVariable, but might exist from previous addon version
    if WeakTexturesDB and (WeakTexturesDB.presets or WeakTexturesDB.groups or WeakTexturesDB.ADDON_EVENTS) then
        local hasOldData = false
        
        -- Check if there's actual data to migrate
        if WeakTexturesDB.presets then
            for _ in pairs(WeakTexturesDB.presets) do
                hasOldData = true
                break
            end
        end
        
        if not hasOldData and WeakTexturesDB.groups then
            for _ in pairs(WeakTexturesDB.groups) do
                hasOldData = true
                break
            end
        end
        
        -- If we have old data, migrate it to Default profile
        if hasOldData and not next(WeakTexturesProfiles) then
            WeakTexturesProfiles["Default"] = {
                presets = self:DeepCopy(WeakTexturesDB.presets or {}),
                groups = self:DeepCopy(WeakTexturesDB.groups or {}),
                ADDON_EVENTS = self:DeepCopy(WeakTexturesDB.ADDON_EVENTS or {})
            }
            
            print("|cffff0000[WeakTextures]|r " .. L.MESSAGE_MIGRATED_TO_PROFILE)
            print("|cffff0000[WeakTextures]|r " .. L.MESSAGE_OLD_DB_CLEARED)
        end
    end
    
    -- Create default profile if it doesn't exist
    if not WeakTexturesProfiles["Default"] then
        WeakTexturesProfiles["Default"] = {
            presets = {},
            groups = {},
            ADDON_EVENTS = {}
        }
    end
    
    -- Initialize WeakTexturesDB as runtime cache (not saved to disk)
    WeakTexturesDB = {
        presets = {},
        groups = {},
        ADDON_EVENTS = {}
    }
    
    -- Load active profile
    self:LoadProfile(WeakTexturesCharacter.activeProfile)
end

---Load a profile
---@param profileName string
function wt:LoadProfile(profileName)
    if not WeakTexturesProfiles[profileName] then
        print("|cffff0000[WeakTextures]|r Profile '" .. profileName .. "' not found. Loading Default.")
        profileName = "Default"
    end
    
    -- Save current active profile name
    WeakTexturesCharacter.activeProfile = profileName
    
    -- Load profile data into WeakTexturesDB
    local profile = WeakTexturesProfiles[profileName]
    WeakTexturesDB.presets = profile.presets or {}
    WeakTexturesDB.groups = profile.groups or {}
    WeakTexturesDB.ADDON_EVENTS = profile.ADDON_EVENTS or {}
    
    -- Hide all existing frames
    for presetName in pairs(wt.activeFramesByPreset) do
        wt:HideTextureFrame(presetName)
    end
    wt.activeFramesByPreset = {}
    
    -- Rebuild ADDON_EVENTS table
    wt:RebuildAddonEventsTable()
    
    -- Apply all presets from new profile
    wt:ApplyAllPresets()
    
    -- Refresh UI if it's open
    if wt.frame and wt.frame:IsShown() then
        wt:allDefault()
        wt:RefreshPresetList()
    end
    
    print("|cffff0000[WeakTextures]|r " .. L.MESSAGE_PROFILE_LOADED .. " (" .. profileName .. ")")
end

---Save current data to active profile
function wt:SaveCurrentProfile()
    local profileName = WeakTexturesCharacter.activeProfile
    if not WeakTexturesProfiles[profileName] then
        WeakTexturesProfiles[profileName] = {}
    end
    
    WeakTexturesProfiles[profileName].presets = WeakTexturesDB.presets
    WeakTexturesProfiles[profileName].groups = WeakTexturesDB.groups
    WeakTexturesProfiles[profileName].ADDON_EVENTS = WeakTexturesDB.ADDON_EVENTS
end

---Create a new profile
---@param profileName string
---@param copyFrom string|nil
---@return boolean
function wt:CreateProfile(profileName)
    if not profileName or profileName == "" then
        print("|cffff0000[WeakTextures]|r Profile name cannot be empty.")
        return false
    end
    
    if WeakTexturesProfiles[profileName] then
        print("|cffff0000[WeakTextures]|r Profile '" .. profileName .. "' already exists.")
        return false
    end
    
    -- Create new empty profile
    WeakTexturesProfiles[profileName] = {
        presets = {},
        groups = {},
        ADDON_EVENTS = {}
    }
    
    print("|cffff0000[WeakTextures]|r " .. L.MESSAGE_PROFILE_CREATED .. " (" .. profileName .. ")")
    return true
end

---Copy a profile
---@param fromProfile string
---@param toProfile string
---@return boolean
function wt:CopyProfile(fromProfile, toProfile)
    if not WeakTexturesProfiles[fromProfile] then
        print("|cffff0000[WeakTextures]|r Source profile '" .. fromProfile .. "' not found.")
        return false
    end
    
    if not toProfile or toProfile == "" then
        print("|cffff0000[WeakTextures]|r Profile name cannot be empty.")
        return false
    end
    
    if WeakTexturesProfiles[toProfile] then
        print("|cffff0000[WeakTextures]|r Profile '" .. toProfile .. "' already exists.")
        return false
    end
    
    -- Deep copy profile data
    local source = WeakTexturesProfiles[fromProfile]
    WeakTexturesProfiles[toProfile] = {
        presets = wt:DeepCopy(source.presets),
        groups = wt:DeepCopy(source.groups),
        ADDON_EVENTS = wt:DeepCopy(source.ADDON_EVENTS)
    }
    
    print("|cffff0000[WeakTextures]|r " .. L.MESSAGE_PROFILE_COPIED .. " (" .. fromProfile .. " → " .. toProfile .. ")")
    return true
end

---Delete a profile
---@param profileName string
---@return boolean
function wt:DeleteProfile(profileName)
    if profileName == "Default" then
        print("|cffff0000[WeakTextures]|r Cannot delete the Default profile.")
        return false
    end
    
    if not WeakTexturesProfiles[profileName] then
        print("|cffff0000[WeakTextures]|r Profile '" .. profileName .. "' not found.")
        return false
    end
    
    -- If this is the active profile, switch to Default
    if WeakTexturesCharacter.activeProfile == profileName then
        wt:LoadProfile("Default")
    end
    
    WeakTexturesProfiles[profileName] = nil
    print("|cffff0000[WeakTextures]|r " .. L.MESSAGE_PROFILE_DELETED .. " (" .. profileName .. ")")
    return true
end

---Rename a profile
---@param oldName string
---@param newName string
---@return boolean
function wt:RenameProfile(oldName, newName)
    if oldName == "Default" then
        print("|cffff0000[WeakTextures]|r Cannot rename the Default profile.")
        return false
    end
    
    if not WeakTexturesProfiles[oldName] then
        print("|cffff0000[WeakTextures]|r Profile '" .. oldName .. "' not found.")
        return false
    end
    
    if not newName or newName == "" then
        print("|cffff0000[WeakTextures]|r Profile name cannot be empty.")
        return false
    end
    
    if WeakTexturesProfiles[newName] then
        print("|cffff0000[WeakTextures]|r Profile '" .. newName .. "' already exists.")
        return false
    end
    
    -- Copy to new name
    WeakTexturesProfiles[newName] = WeakTexturesProfiles[oldName]
    WeakTexturesProfiles[oldName] = nil
    
    -- Update active profile name if needed
    if WeakTexturesCharacter.activeProfile == oldName then
        WeakTexturesCharacter.activeProfile = newName
    end
    
    print("|cffff0000[WeakTextures]|r Renamed profile '" .. oldName .. "' to '" .. newName .. "'.")
    return true
end

---Deep copy a table
---@param orig table
---@return table
function wt:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[wt:DeepCopy(orig_key)] = wt:DeepCopy(orig_value)
        end
        setmetatable(copy, wt:DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

---Export a profile to string
---@param profileName string
---@return string|nil exportString
function wt:ExportProfile(profileName)
    if not WeakTexturesProfiles[profileName] then
        print("|cffff0000[WeakTextures]|r Profile '" .. profileName .. "' not found.")
        return nil
    end
    
    local profile = WeakTexturesProfiles[profileName]
    local exportData = {
        profileName = profileName,
        presets = profile.presets,
        groups = profile.groups,
        ADDON_EVENTS = profile.ADDON_EVENTS
    }
    
    return wt:SerializeTable(exportData)
end

---Import a profile from string
---@param str string
---@param newProfileName string|nil
---@return boolean
function wt:ImportProfile(str, newProfileName)
    local data = wt:DeserializeTable(str)
    if not data then
        print("|cffff0000[WeakTextures]|r Invalid import string.")
        return false
    end
    
    -- Validate data structure
    if not data.profileName or not data.presets then
        print("|cffff0000[WeakTextures]|r Invalid profile data.")
        return false
    end
    
    -- Use provided name or original name
    local targetName = newProfileName or data.profileName
    
    -- If profile exists, add a number suffix
    if WeakTexturesProfiles[targetName] then
        local i = 2
        while WeakTexturesProfiles[targetName .. " (" .. i .. ")"] do
            i = i + 1
        end
        targetName = targetName .. " (" .. i .. ")"
    end
    
    -- Create new profile
    WeakTexturesProfiles[targetName] = {
        presets = data.presets or {},
        groups = data.groups or {},
        ADDON_EVENTS = data.ADDON_EVENTS or {}
    }
    
    print("|cffff0000[WeakTextures]|r Imported profile: " .. targetName)
    return true
end
