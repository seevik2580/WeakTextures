-- =====================================================
-- WeakTextures Core
-- =====================================================

local _, wt = ...
WeakTexturesDB = WeakTexturesDB or { presets = {}, groups = {} }

wt.presetButtons = {}
wt.activeFramesByPreset = {}
wt.selectedPreset = nil
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
wt.selectedBackdrops = {
    bgFile = "Interface/Buttons/UI-Listbox-Highlight2",
    edgeFile = nil,
    tile = false,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

-- =====================================================
-- Auto load textures on login / reload / specialization change
-- =====================================================
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

loader:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_LOGIN" then
        wt:ApplyAllPresets()
        return
    end
end)

-- =====================================================
-- Slash command
-- =====================================================
SLASH_WT1 = "/wt"
SLASH_WT2 = "/weaktextures"

SlashCmdList.WT = function()
    wt.frame:SetShown(not wt.frame:IsShown())

    if wt.frame:IsShown() then
        wt:CollapseAllGroups()
        wt:RefreshPresetList()
    end
end