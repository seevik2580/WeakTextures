-- =====================================================
-- WeakTextures Tooltip
-- =====================================================
local _, wt = ...
local L = wt.L

-- Show a tooltip preview of a preset's texture
---@param parent Frame
---@param presetName string
function wt:ShowPresetTooltip(parent, presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset or not preset.textures or not preset.textures[1] then return end
    local data = preset.textures[1]
    local width = tonumber(data.width) or 64
    local height = tonumber(data.height) or 64
    -- Create tooltip frame if it doesn't exist
    if not wt.presetTooltip then
        wt.presetTooltip = CreateFrame("Frame", "WeakTexturesPresetTooltip", UIParent, "BackdropTemplate")
        wt.presetTooltip:SetFrameStrata("TOOLTIP")
        wt.presetTooltip:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        wt.presetTooltip:SetBackdropColor(0, 0, 0, 0.9)
        wt.presetTooltip:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        wt.presetTooltip.texture = wt.presetTooltip:CreateTexture(nil, "ARTWORK")
        wt.presetTooltip.texture:SetPoint("CENTER")
    end

    local tooltip = wt.presetTooltip
    tooltip:SetSize(width + 12, height + 12)
    tooltip.texture:SetSize(width, height)
    tooltip.texture:SetTexture(data.texture)

    -- Position tooltip next to cursor
    tooltip:SetPoint("BOTTOMLEFT", parent, "TOPRIGHT", 40, 0)

    if preset.type == "motion" then
        local columns = preset.columns or 1
        local rows = preset.rows or 1
        local totalFrames = preset.totalFrames or 1
        local fps = preset.fps or 30

        -- Wait for texture to load before starting animation
        local function checkLoaded()
            if tooltip.texture:GetWidth() > 0 then
                tooltip.currentFrame = 0
                tooltip.elapsed = 0
                tooltip:SetScript("OnUpdate", function(self, delta)
                    self.elapsed = self.elapsed + delta
                    if self.elapsed >= (1 / fps) then
                        self.elapsed = 0
                        self.currentFrame = (self.currentFrame + 1) % totalFrames
                    end
                    local col = self.currentFrame % columns
                    local row = math.floor(self.currentFrame / columns)
                    self.texture:SetTexCoord(
                        col / columns,
                        (col + 1) / columns,
                        row / rows,
                        (row + 1) / rows
                    )
                end)
            else
                C_Timer.After(0.01, checkLoaded)
            end
        end
        checkLoaded()
    else
        -- Static texture
        tooltip.texture:SetTexCoord(0, 1, 0, 1)
        tooltip:SetScript("OnUpdate", nil)
    end

    tooltip:Show()
end

-- Hide the preset tooltip
function wt:HidePresetTooltip()
    if wt.presetTooltip then
        wt.presetTooltip:Hide()
        wt.presetTooltip:SetScript("OnUpdate", nil)
    end
end
