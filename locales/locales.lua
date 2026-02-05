-- =====================================================
-- WeakTextures Localization System
-- =====================================================
local _, wt = ...

-- Localization tables for each language
wt.locales = {
    enUS = {},
    deDE = {}
}

-- Current locale (check user settings first, then game client language)
-- SavedVariables SHOULD be available immediately when addon loads
local userLocale = nil
if WeakTexturesSettings and WeakTexturesSettings.locale then
    userLocale = WeakTexturesSettings.locale
end

local gameLocale = GetLocale()

wt.currentLocale = userLocale or (gameLocale == "deDE" and "deDE" or "enUS")

-- Proxy table that dynamically returns the correct language
wt.L = setmetatable({}, {
    __index = function(t, key)
        -- Use currentLocale instead of checking WeakTexturesSettings every time
        local locale = wt.currentLocale or "enUS"
        
        -- Return string from selected locale, fallback to enUS
        return wt.locales[locale][key] or wt.locales.enUS[key] or key
    end
})

-- Available locales for settings dropdown
wt.availableLocales = {
    ["enUS"] = "English",
    ["deDE"] = "Deutsch",
}

---Get the game client locale or user setting
---@return string
function wt:GetLocale()
    -- Check if user has manually set a locale in settings
    if WeakTexturesSettings and WeakTexturesSettings.locale then
        return WeakTexturesSettings.locale
    end
    
    -- Get game client locale
    local gameLocale = GetLocale()
    
    -- Return deDE for German, otherwise fallback to enUS
    if gameLocale == "deDE" then
        return "deDE"
    end
    
    return "enUS"
end

---Set the current locale (called from settings)
---@param locale string
function wt:SetLocale(locale)
    if not wt.availableLocales[locale] then
        return
    end
    
    WeakTexturesSettings = WeakTexturesSettings or {}
    WeakTexturesSettings.locale = locale
    
    -- Reload UI to apply new locale
    C_UI.Reload()
end

