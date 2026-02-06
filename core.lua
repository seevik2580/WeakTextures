-- =====================================================
-- WeakTextures Core
-- =====================================================
local _, wt = ...

---@diagnostic disable: undefined-field, undefined-doc-name

---@class Button
---@class Frame

---@class EventHandle
---@field event string
---@field func function

---@class FrameContainer
---@field frame Frame
---@field isLocked boolean|nil
---@field wasHiddenBeforeUnlock boolean|nil

---@class WeakTexturesDB
---@field presets table<string, Preset>
---@field groups table<string, boolean>
---@field ADDON_EVENTS table<string, table<string, boolean>>

---@class WeakTextures
---@field debugEnabled boolean
---@field presetButtons Button[]
---@field activeFramesByPreset table<string, FrameContainer>
---@field selectedPreset string|nil
---@field lastPresetState table<string, boolean>
---@field isApplyingFromEvent boolean
---@field frameStrataList string[]
---@field groupState table<string, boolean>
---@field presetState table<string, any>
---@field conditionEventMap table<string, string|table>
---@field events table<string, boolean>
---@field blockedEvents table<string, boolean>
---@field blockedFunctions table<string, boolean>
---@field blockedTables table<string, boolean>
---@field leftAtlasBackgrounds string[]
---@field scrollSteps number
---@field frame Frame
---@field frameWidth number
---@field frameHeight number
---@field inset number
---@field PANELOFFSET_Y number
---@field PANELTABOFFSET_Y number
---@field multiLineEditBoxBackdrop table
---@field buttonNormal string
---@field buttonHighlight string
---@field buttonPushed string
---@field buttonDisabled string
---@field rightTabs Button[]
---@field rightPanels table<string, Frame>
---@field UserEvent UserEventFrame
---@field exportDialog Frame|nil
---@field presetTooltip Frame|nil

---@class wt : WeakTextures
wt = wt or {}
wt.LDB = LibStub("LibDataBroker-1.1")
wt.LDBIcon = LibStub("LibDBIcon-1.0")
wt.LSM = LibStub("LibSharedMedia-3.0")
wt.addonName = C_AddOns.GetAddOnMetadata("WeakTextures", "Title") or "WeakTextures"
wt.addonVersion = C_AddOns.GetAddOnMetadata("WeakTextures", "Version") or "Unknown"
            

wt.presetButtons = {}
wt.activeFramesByPreset = {}
wt.selectedPreset = nil
wt.lastPresetState = {}
wt.isApplyingFromEvent = false
wt.customFont = "PT Sans Narrow Regular"
wt.customFontBold = "PT Sans Narrow Bold"
wt.frameStrataList = {
    "BACKGROUND",
    "LOW",
    "MEDIUM",
    "HIGH",
    "DIALOG",
    "FULLSCREEN",
    "FULLSCREEN_DIALOG",
    "TOOLTIP",
}
wt.groupState = {}
wt.presetState = {}

-- Event list for static load conditions (like login, specialization change, combat state, death, alive, zone change)
wt.events = {
    ADDON_LOADED = true,
    PLAYER_LOGIN = true,
    PLAYER_ENTERING_WORLD = true,
    PLAYER_SPECIALIZATION_CHANGED = true,
    PLAYER_REGEN_DISABLED = true,
    PLAYER_REGEN_ENABLED = true,
    PLAYER_DEAD = true,
    PLAYER_UNGHOST = true,
    PLAYER_ALIVE = true,
    PLAYER_UPDATE_RESTING = true,
    ZONE_CHANGED_NEW_AREA = true,
    ENCOUNTER_START = true,
    ENCOUNTER_END = true,
    PET_BATTLE_OPENING_START = true,
    PET_BATTLE_CLOSE = true,
    UNIT_ENTERED_VEHICLE = true,
    UNIT_EXITED_VEHICLE = true,
    HOUSE_PLOT_ENTERED = true,
    HOUSE_PLOT_EXITED = true,
}
-- Mapping of condition states to their corresponding events
wt.conditionEventMap = {
    -- Combat conditions
    combat_positive = "PLAYER_REGEN_DISABLED",
    combat_negative = "PLAYER_REGEN_ENABLED",
    -- Encounter conditions
    encounter_positive = {"ENCOUNTER_START", "PLAYER_REGEN_DISABLED"},
    encounter_negative = {"ENCOUNTER_END", "PLAYER_REGEN_ENABLED"},
    -- Death/Alive conditions
    alive_positive = "PLAYER_ALIVE",
    alive_negative = "PLAYER_DEAD",
    dead_positive = "PLAYER_DEAD",
    dead_negative = "PLAYER_ALIVE",
    -- Rested conditions
    rested_positive = "PLAYER_UPDATE_RESTING",
    rested_negative = "PLAYER_UPDATE_RESTING",
    -- Pet battle conditions
    petBattle_positive = "PET_BATTLE_OPENING_START",
    petBattle_negative = "PET_BATTLE_CLOSE",
    -- Vehicle conditions
    vehicle_positive = "UNIT_ENTERED_VEHICLE",
    vehicle_negative = "UNIT_EXITED_VEHICLE",
    -- Instance conditions
    instance_positive = "PLAYER_ENTERING_WORLD",
    instance_negative = "PLAYER_ENTERING_WORLD",
    -- Housing conditions
    housing_positive = "HOUSE_PLOT_ENTERED",
    housing_negative = "HOUSE_PLOT_EXITED",
}
-- Blocked events that should not be registered by presets
wt.blockedEvents = {
    COMBAT_LOG_EVENT_UNFILTERED = true,
}
-- Blocked dangerous functions
wt.blockedFunctions = {
  getfenv = true,
  setfenv = true,
  loadstring = true,
  pcall = true,
  xpcall = true,
  SendMail = true,
  SetTradeMoney = true,
  AddTradeMoney = true,
  PickupTradeMoney = true,
  PickupPlayerMoney = true,
  TradeFrame = true,
  MailFrame = true,
  EnumerateFrames = true,
  RunScript = true,
  AcceptTrade = true,
  SetSendMailMoney = true,
  EditMacro = true,
  DevTools_DumpCommand = true,
  hash_SlashCmdList = true,
  RegisterNewSlashCommand = true,
  CreateMacro = true,
  SetBindingMacro = true,
  GuildDisband = true,
  GuildUninvite = true,
  securecall = true,
  DeleteCursorItem = true,
  ChatEdit_SendText = true,
  ChatEdit_ActivateChat = true,
  ChatEdit_ParseText = true,
  ChatEdit_OnEnterPressed = true,
  GetButtonMetatable = true,
  GetEditBoxMetatable = true,
  GetFontStringMetatable = true,
  GetFrameMetatable = true,
}
-- Blocked tables
wt.blockedTables = {
    UIParent = true,
    WorldFrame = true,
}

wt.leftAtlasBackgrounds = {
    "AlliedRace-UnlockingFrame-ModelBackground-DarkIronDwarf",
    "AlliedRace-UnlockingFrame-ModelBackground-Highmountain",
    "AlliedRace-UnlockingFrame-ModelBackground-Nightborne",
    "AlliedRace-UnlockingFrame-ModelBackground-Voidelf",
    "AlliedRace-UnlockingFrame-ModelBackground-Magharorc",
    "AlliedRace-UnlockingFrame-ModelBackground-Earthen",
    "AlliedRace-UnlockingFrame-ModelBackground-Haranir",
    "AlliedRace-UnlockingFrame-ModelBackground-Kultiran",
    "AlliedRace-UnlockingFrame-ModelBackground-Zandalari",
    "AlliedRace-UnlockingFrame-ModelBackground-Lightforge",
    "AlliedRace-UnlockingFrame-ModelBackground-Vulpera",
    "AlliedRace-UnlockingFrame-ModelBackground-Mechagnome",
}
wt.scrollSteps = 0.05

-- StaticPopup Dialogs
StaticPopupDialogs["WEAKTEXTURES_DELETE_PRESET"] = {
    text = "Delete preset '%s'?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self, presetName)
        wt:HideTextureFrame(presetName)
        wt:RemovePresetFromAddonEvents(presetName)
        WeakTexturesDB.presets[presetName] = nil
        if wt.selectedPreset == presetName then
            wt:allDefault()
        end
        wt:RefreshPresetList()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["WEAKTEXTURES_DELETE_GROUP"] = {
    text = "Delete group '%s' and all included presets?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self, groupPath)
        wt:DeleteGroupPath(groupPath)
        wt:allDefault()
        wt:RefreshPresetList()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["WEAKTEXTURES_DELETE_DISABLED_PRESETS"] = {
    text = "Delete all presets in Disabled group?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self)
        -- Delete all presets in Disabled group
        for presetName, preset in pairs(WeakTexturesDB.presets) do
            if preset.group == "Disabled" then
                wt:HideTextureFrame(presetName)
                wt:RemovePresetFromAddonEvents(presetName)
                WeakTexturesDB.presets[presetName] = nil
            end
        end
        wt:allDefault()
        wt:RefreshPresetList()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["WEAKTEXTURES_DELETE_UNGROUPED_PRESETS"] = {
    text = "Delete all presets in Ungrouped group?",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self)
        -- Delete all presets that are ungrouped
        for presetName, preset in pairs(WeakTexturesDB.presets) do
            if not preset.group or preset.group == "" then
                wt:HideTextureFrame(presetName)
                wt:RemovePresetFromAddonEvents(presetName)
                WeakTexturesDB.presets[presetName] = nil
            end
        end
        wt:allDefault()
        wt:RefreshPresetList()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Function to initialize minimap icon
function wt:InitializeMinimapIcon()
    local L = wt.L
    
    local Broker_WeakTextures = wt.LDB:NewDataObject(wt.addonName, {
        type = "launcher",
        text = wt.addonName,
        icon = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\textLogo-small.png",
        OnClick = function(self, button)
            if button == 'LeftButton' then
                wt:ToggleUI()
            else
                wt:OpenSettings()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(wt.addonName)
            tooltip:AddLine(L.SETTINGS_VERSION .. (wt.addonVersion or "Unknown"), 0.5, 0.5, 0.5)
            tooltip:AddLine(" ")
            tooltip:AddLine(L.MINIMAP_LEFTCLICK .. wt.addonName)
            tooltip:AddLine(L.MINIMAP_RIGHTCLICK)
        end,
    })
    
    wt.LDBIcon:Register(wt.addonName, Broker_WeakTextures, WeakTexturesDB.minimap)
end

-- Auto load textures on login / reload / specialization change / combat state change / death / alive
local loader = CreateFrame("Frame")
for event in pairs(wt.events) do
    loader:RegisterEvent(event)
end

loader:SetScript("OnEvent", function(_, event, ...)
    if wt.events[event] then

        if event == "ADDON_LOADED" then
            local addonName = ...
            if addonName ~= "WeakTextures" then
                return
            end
            
            -- Update currentLocale based on user settings (if they manually selected a language)
            if WeakTexturesSettings and WeakTexturesSettings.locale then
                wt.currentLocale = WeakTexturesSettings.locale
            end
            
            -- Load debug setting from saved variables
            wt.debugEnabled = WeakTexturesSettings.debugEnabled or false
            
            -- Create settings category after locale is properly set
            if wt.CreateSettingsCategory then
                wt:CreateSettingsCategory()
            end
            
            -- Initialize minimap icon after locale is set
            if wt.InitializeMinimapIcon then
                wt:InitializeMinimapIcon()
            end
            
            -- NOW create the UI after locale is set correctly
            if not wt.frame then
                wt:CreateUI()
            end
            
            -- Register fonts with LibSharedMedia
            wt.LSM:Register("font", "PT Sans Narrow Regular", "Interface\\AddOns\\" .. wt.addonName .. "\\Media\\Fonts\\PTSansNarrow-Regular.ttf")
            wt.LSM:Register("font", "PT Sans Narrow Bold", "Interface\\AddOns\\" .. wt.addonName .. "\\Media\\Fonts\\PTSansNarrow-Bold.ttf")
            
            -- Register all saved custom textures with LibSharedMedia
            if WeakTexturesCustomTextures then
                for textureName, texturePath in pairs(WeakTexturesCustomTextures) do
                    pcall(function()
                        wt.LSM:Register("background", textureName, texturePath)
                    end)
                end
            end
            
            -- Load saved font settings
            if WeakTexturesSettings.font then
                wt.customFont = WeakTexturesSettings.font
            end
            if WeakTexturesSettings.fontBold then
                wt.customFontBold = WeakTexturesSettings.fontBold
            end
        end

        -- Initialize event handles for all presets on login
        if event == "PLAYER_LOGIN" then
            -- Apply custom fonts to all UI
            if wt.ApplyCustomFonts then
                wt:ApplyCustomFonts()
            end
            
            -- Initialize profile system
            wt:InitializeProfiles()
            
            -- Show example presets dialog on first run
            if WeakTexturesSettings.firstRun then
                C_Timer.After(2, function()
                    wt:ShowCreateExamplesDialog()
                end)
                WeakTexturesSettings.firstRun = false
            end
            
            for _, preset in pairs(WeakTexturesDB.presets) do
                if not preset.eventHandles then
                    preset.eventHandles = {}
                end
            end
            -- Initialize ADDON_EVENTS table
            WeakTexturesDB.ADDON_EVENTS = WeakTexturesDB.ADDON_EVENTS or {}
            wt:RebuildAddonEventsTable()
            -- Register all preset custom events BEFORE applying presets (only if load conditions are met)
            wt:RegisterAllPresetEvents()
        end
        
        wt.isApplyingFromEvent = true
        
        -- Only process events that have registered presets in ADDON_EVENTS
        if WeakTexturesDB.ADDON_EVENTS[event] then
            wt:ApplyPresetsForEvent(event)
        end
        -- If event is not in ADDON_EVENTS, do nothing (optimization)
        
        wt.isApplyingFromEvent = false
        
        return
    end
end)

-- Slash command
SLASH_WEAKTEXTURES1 = "/weaktextures"
SlashCmdList.WEAKTEXTURES = function(msg)
    if InCombatLockdown() then return end
    local command = msg:lower():trim()
    
    if command == "settings" or command == "config" or command == "options" then
        -- Open settings panel
        if wt.OpenSettings then
            wt:OpenSettings()
        else
            print("|cffff0000[" .. wt.addonName .. "]|r Settings not loaded yet. Please try again.")
        end
    else
        -- Toggle main UI
        wt:ToggleUI()
    end
end
