-- =====================================================
-- Frame Chooser (adapted from WeakAuras)
-- =====================================================

local _, wt = ...

local frameChooserFrame
local frameChooserBox
local oldFocus
local oldFocusName

local function recurseGetName(frame)
    if not frame then return nil end

    if frame.GetName then
        local name = frame:GetName()
        if name then
            return name
        end
    end

    local parent = frame.GetParent and frame:GetParent()
    if parent then
        for key, child in pairs(parent) do
            if child == frame then
                local parentName = recurseGetName(parent)
                if parentName then
                    return parentName .. "." .. key
                end
            end
        end
    end
end

function wt:StartFrameChooser()
    if not frameChooserFrame then
        frameChooserFrame = CreateFrame("Frame")
        frameChooserBox = CreateFrame("Frame", nil, frameChooserFrame, "BackdropTemplate")

        frameChooserBox:SetFrameStrata("TOOLTIP")
        frameChooserBox:SetFrameLevel(100)
        frameChooserBox:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        frameChooserBox:SetBackdropBorderColor(0, 1, 0)
        frameChooserBox:Hide()
    end

    oldFocus = nil
    oldFocusName = nil

    frameChooserFrame:SetScript("OnUpdate", function()
        -- Cancel with right click
        if IsMouseButtonDown("RightButton") then
            wt:StopFrameChooser()
            return
        end

        -- Confirm with left click
        if IsMouseButtonDown("LeftButton") and oldFocusName then
            wt.anchorEdit:SetText(oldFocusName)
            wt:StopFrameChooser()
            return
        end

        SetCursor("CAST_CURSOR")

        local focus
        if GetMouseFocus then
            focus = GetMouseFocus()
        elseif GetMouseFoci then
            local foci = GetMouseFoci()
            focus = foci and foci[1]
        end

        local focusName

        if focus then
            focusName = recurseGetName(focus)

            if not focusName then
                frameChooserBox:Hide()
            else
                frameChooserBox:ClearAllPoints()
                frameChooserBox:SetPoint("BOTTOMLEFT", focus, "BOTTOMLEFT", -4, -4)
                frameChooserBox:SetPoint("TOPRIGHT", focus, "TOPRIGHT", 4, 4)
                frameChooserBox:Show()
            end

            if focusName == "WorldFrame"
            or focusName == "UIParent"
            or not focusName then
                focusName = nil
            end

            if focus ~= oldFocus then
                if focusName then
                    frameChooserBox:ClearAllPoints()
                    frameChooserBox:SetPoint("BOTTOMLEFT", focus, "BOTTOMLEFT", -4, -4)
                    frameChooserBox:SetPoint("TOPRIGHT", focus, "TOPRIGHT", 4, 4)
                    frameChooserBox:Show()
                else
                    frameChooserBox:Hide()
                end

                oldFocus = focus
                oldFocusName = focusName
            end
        else
            frameChooserBox:Hide()
        end
    end)
end

function wt:StopFrameChooser()
    if frameChooserFrame then
        frameChooserFrame:SetScript("OnUpdate", nil)
        frameChooserBox:Hide()
    end
    ResetCursor()
end