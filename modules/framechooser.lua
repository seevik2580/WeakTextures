-- =====================================================
-- Frame Chooser (adapted from WeakAuras)
-- =====================================================

local _, wt = ...

---@type Frame|nil
local frameChooserFrame
---@type Frame|nil
local frameChooserBox
---@type Frame|nil
local oldFocus
---@type string|nil
local oldFocusName

---Recursively get the name of a frame
---@param frame Frame|table
---@return string|nil frameName
local function recurseGetName(frame)
  local name = frame.GetName and frame:GetName() or nil
  if name then
     return name
  end
  local parent = frame.GetParent and frame:GetParent()
  if parent then
     for key, child in pairs(parent) do
        if child == frame then
           return (recurseGetName(parent) or "") .. "." .. key
        end
     end
  end
end

---Start the interactive frame chooser
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
            wt.frame.right.configPanelContent.anchorEdit:SetText(oldFocusName)
            wt:StopFrameChooser()
            return
        end

        SetCursor("CAST_CURSOR")

        local focus
        local focusName
        
        -- Try GetMouseFoci first (returns all frames under cursor)
        if GetMouseFoci then
            local foci = GetMouseFoci()
            if foci then
                -- Iterate through all frames and find the best match
                for i, frame in ipairs(foci) do
                    local name = recurseGetName(frame)
                    
                    -- Try to get direct name if recursion failed
                    if not name and frame.GetName then
                        name = frame:GetName()
                    end
                    
                    -- Try parent name if still no name
                    if not name and frame.GetParent then
                        local parent = frame:GetParent()
                        if parent then
                            name = recurseGetName(parent)
                            if not name and parent.GetName then
                                name = parent:GetName()
                            end
                        end
                    end
                    
                    -- Skip WeakTextures frames, UIParent, and WorldFrame
                    if name and not name:match("^WeakTextures") 
                       and name ~= "UIParent" 
                       and name ~= "WorldFrame" then
                        focus = frame
                        focusName = name
                        break  -- Use first valid frame (highest in z-order)
                    end
                end
            end
        end
        
        -- Fallback to GetMouseFocus
        if not focus and GetMouseFocus then
            focus = GetMouseFocus()
            if focus then
                focusName = recurseGetName(focus)
                if not focusName and focus.GetName then
                    focusName = focus:GetName()
                end
                
                -- Filter out own addon frames
                if focusName and (focusName:match("^WeakTextures") 
                   or focusName == "UIParent" 
                   or focusName == "WorldFrame") then
                    focusName = nil
                    focus = nil
                end
            end
        end

        if focus and focusName then
            if focus ~= oldFocus then
                frameChooserBox:ClearAllPoints()
                frameChooserBox:SetPoint("BOTTOMLEFT", focus, "BOTTOMLEFT", -4, -4)
                frameChooserBox:SetPoint("TOPRIGHT", focus, "TOPRIGHT", 4, 4)
                frameChooserBox:Show()
                
                oldFocus = focus
                oldFocusName = focusName
            end
        else
            frameChooserBox:Hide()
            oldFocus = nil
            oldFocusName = nil
        end
    end)
end

---Stop the interactive frame chooser
function wt:StopFrameChooser()
    if frameChooserFrame then
        frameChooserFrame:SetScript("OnUpdate", nil)
        frameChooserBox:Hide()
    end
    ResetCursor()
end