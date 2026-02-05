-- ===================================================================================
-- WeakTextures Advanced conditions (user events) with Sandboxed Trigger Execution
-- ===================================================================================
local _, wt = ...
local L = wt.L

---@class UserEventFrame : Frame
---@field handlers table<string, function[]>

wt.UserEvent = CreateFrame("Frame")
wt.UserEvent.handlers = {}

-- Safe function overrides
local sandboxErrors = {}

local function getSafeFunction(name, envId)
    return function()
        local errorMsg = "Blocked function '" .. name .. "' is not allowed to be used"
        wt:Debug("SANDBOX:", errorMsg, "in preset", envId)
        
        -- Store error for UI display
        if not sandboxErrors[envId] then
            sandboxErrors[envId] = {}
        end
        table.insert(sandboxErrors[envId], errorMsg)
        
        return nil
    end
end

local function recordBlockedAccess(itemType, name, envId)
    local errorMsg = "Blocked " .. itemType .. " '" .. name .. "' is not allowed to be used"
    wt:Debug("SANDBOX:", errorMsg, "in preset", envId)
    
    -- Store error for UI display
    if not sandboxErrors[envId] then
        sandboxErrors[envId] = {}
    end
    table.insert(sandboxErrors[envId], errorMsg)
end

-- Warning counter for excessive API calls
local callCounts = {}
local MAX_CALLS_PER_EXECUTION = 100

-- Provide safe common APIs
local safeMixins = {
    -- Math
    math = math,
    string = string,
    table = table,
    -- Time
    time = time,
    date = date,
    GetTime = GetTime,
    C_Timer = C_Timer,
    -- WoW Info APIs (read-only, safe)
    UnitName = UnitName,
    UnitClass = UnitClass,
    UnitLevel = UnitLevel,
    UnitHealth = UnitHealth,
    UnitHealthMax = UnitHealthMax,
    UnitPower = UnitPower,
    UnitPowerMax = UnitPowerMax,
    UnitBuff = UnitBuff,
    UnitDebuff = UnitDebuff,
    UnitAura = UnitAura,
    GetSpellInfo = GetSpellInfo,
    GetTime = GetTime,
    IsInInstance = IsInInstance,
    IsInRaid = IsInRaid,
    IsInGroup = IsInGroup,
    GetZoneText = GetZoneText,
    GetSubZoneText = GetSubZoneText,
    -- Printing
    print = print,
    -- Basic Lua
    type = type,
    pairs = pairs,
    ipairs = ipairs,
    next = next,
    select = select,
    tostring = tostring,
    tonumber = tonumber,
    tinsert = tinsert,
    tremove = tremove,
    wipe = wipe,
    unpack = unpack,
}

---Create a sandboxed environment for trigger code execution
---@param presetName string|nil
---@return table
function wt:CreateTriggerEnv(presetName)
    local env = {}
    local envId = presetName or "unknown"
    
    -- Reset call counter and errors for this execution
    callCounts[envId] = 0
    sandboxErrors[envId] = nil
    
    -- Copy safe mixins into environment
    for k, v in pairs(safeMixins) do
        env[k] = v
    end
    
    -- Provide WeakTexturesAPI with preset context
    -- Create persistent context object that survives in closures
    local apiContext = {_currentPreset = presetName}
    local apiProxy = setmetatable(apiContext, {
        __index = WeakTexturesAPI
    })
    
    -- Make the proxy available in environment
    env.WeakTexturesAPI = apiProxy
    
    -- Add callback for playing preset sounds
    env.PlaySound = function(soundKey)
        if presetName then
            wt:PlayPresetSound(presetName, soundKey)
            return true
        end
        return false
    end
    
    -- Provide preset name for user access
    env.PRESET_NAME = presetName
    
    -- Safe wrapper for rate-limited functions
    local function wrapRateLimited(func, funcName)
        return function(...)
            callCounts[envId] = callCounts[envId] + 1
            if callCounts[envId] > MAX_CALLS_PER_EXECUTION then
                wt:Debug("SANDBOX: Rate limit exceeded for", funcName, "in preset", envId)
                return nil
            end
            return func(...)
        end
    end
    
    -- Metatable for the sandbox
    setmetatable(env, {
        __index = function(t, k)
            -- Return sandbox itself for _G access
            if k == "_G" then
                return t
            end
            
            -- Check if function is blocked
            if wt.blockedFunctions[k] then
                recordBlockedAccess("function", k, envId)
                return getSafeFunction(k, envId)
            end
            
            -- Check if table is blocked
            if wt.blockedTables[k] then
                recordBlockedAccess("table", k, envId)
                return {}
            end
            
            -- Check local environment first
            local v = rawget(t, k)
            if v ~= nil then
                return v
            end
            
            -- Allow access to safe globals
            local globalVal = _G[k]
            
            -- Wrap certain functions for rate limiting (Get* APIs)
            if type(globalVal) == "function" and k:match("^Get") and not safeMixins[k] then
                return wrapRateLimited(globalVal, k)
            end
            
            return globalVal
        end,
        
        __newindex = function(t, k, v)
            -- Warn about trying to overwrite important globals
            if _G[k] ~= nil and type(_G[k]) == "function" then
                wt:Debug("SANDBOX: Warning - Overwriting global function", k, "in preset", envId)
            end
            
            -- Prevent overwriting blocked items
            if wt.blockedFunctions[k] or wt.blockedTables[k] then
                recordBlockedAccess("override", k, envId)
                return
            end
            
            -- Store in sandbox environment only
            rawset(t, k, v)
        end,
        
        -- Prevent metatable access
        __metatable = false
    })

    return env
end

-- Test if a trigger string is valid and compile it
---@param trigger string
---@param debug boolean
---@param presetName string|nil
---@return boolean
---@return function|nil
---@return any|nil
function wt:TestTrigger(trigger, debug, presetName)
    if not trigger or trigger == "" then
        wt.frame.right.advancedPanel.errorEdit:SetText("")
        wt.frame.right.advancedPanel.errorContainer:Hide()
        wt:UpdateTriggerLineNumbers() -- Reset line numbers to normal
        return false
    end

    -- Static analysis: Check for blocked functions/tables in source code
    local envId = presetName or "unknown"
    sandboxErrors[envId] = nil
    local violations = {} -- { [name] = {type="function/table", lines={...}} }
    local allErrorLines = {}
    
    -- Split trigger into lines for analysis
    local lines = {}
    for line in trigger:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end
    for lineNum, lineText in ipairs(lines) do
        for name in pairs(wt.blockedFunctions) do
            -- Match word boundaries to avoid false positives
            if lineText:match("%f[%w_]" .. name .. "%f[^%w_]") then
                if not violations[name] then
                    violations[name] = {type = "function", lines = {}}
                end
                table.insert(violations[name].lines, lineNum)
                allErrorLines[lineNum] = true
            end
        end
        
        for name in pairs(wt.blockedTables) do
            if lineText:match("%f[%w_]" .. name .. "%f[^%w_]") then
                if not violations[name] then
                    violations[name] = {type = "table", lines = {}}
                end
                table.insert(violations[name].lines, lineNum)
                allErrorLines[lineNum] = true
            end
        end
    end
    
    -- If static analysis found violations, report them immediately
    if next(violations) then
        local errorText = ""
        
        -- Sort violations by name for consistent output
        local sortedNames = {}
        for name in pairs(violations) do
            table.insert(sortedNames, name)
        end
        table.sort(sortedNames)
        
        for _, name in ipairs(sortedNames) do
            local violation = violations[name]
            local linesList = table.concat(violation.lines, ", ")
            errorText = errorText .. violation.type .. " '" .. name .. "' is not allowed to be used on lines: " .. linesList .. "\n"
        end
        
        wt.frame.right.advancedPanel.errorEdit:SetText(errorText)
        wt.frame.right.advancedPanel.errorContainer:Show()
        
        -- Highlight all error lines
        local errorLinesList = {}
        for lineNum in pairs(allErrorLines) do
            table.insert(errorLinesList, lineNum)
        end
        if #errorLinesList > 0 then
            wt:UpdateTriggerLineNumbers(errorLinesList)
        end
        
        return false
    end

    -- Try to compile the trigger
    local func, error = loadstring("return " .. trigger)
    if error then
        if debug then wt:Debug("Trigger compilation error:", error) end
        wt.frame.right.advancedPanel.errorEdit:SetText(error)
        wt.frame.right.advancedPanel.errorContainer:Show()
        
        -- Extract line number from error message
        -- Error format: [string "return ..."]:5: syntax error near 'end'
        local errorLine = error:match("%]:(%d+):")
        if errorLine then
            wt:UpdateTriggerLineNumbers(tonumber(errorLine))
        end
        
        return false
    end

    -- Create sandboxed environment
    local env = wt:CreateTriggerEnv(presetName)
    setfenv(func, env)

    -- Execute to get the actual function (wrapped in xpcall for better error handling)
    local function errorHandler(err)
        return debug.traceback(err, 2)
    end
    
    local ok, result = xpcall(func, errorHandler)
    if not ok then
        if debug then wt:Debug("Trigger execution error:", result) end
        wt.frame.right.advancedPanel.errorEdit:SetText("Execution Error:\n" .. tostring(result))
        wt.frame.right.advancedPanel.errorContainer:Show()
        
        -- Extract line number from runtime error if present
        local errorLine = result:match("%]:(%d+):")
        if errorLine then
            wt:UpdateTriggerLineNumbers(tonumber(errorLine))
        end
        
        return false
    end

    -- Check for sandbox violations
    local envId = presetName or "unknown"
    if sandboxErrors[envId] and #sandboxErrors[envId] > 0 then
        local errorText = "Sandbox Violations:\n"
        for i, err in ipairs(sandboxErrors[envId]) do
            errorText = errorText .. i .. ". " .. err .. "\n"
        end
        wt.frame.right.advancedPanel.errorEdit:SetText(errorText)
        wt.frame.right.advancedPanel.errorContainer:Show()
        sandboxErrors[envId] = nil -- Clear after displaying
        return false
    end

    -- Clear error if trigger is valid
    wt.frame.right.advancedPanel.errorEdit:SetText("")
    wt.frame.right.advancedPanel.errorContainer:Hide()
    wt:UpdateTriggerLineNumbers() -- Reset line numbers to normal

    -- If result is a function, that's our handler
    if type(result) == "function" then
        if debug then wt:Debug("Trigger is a function") end
        return true, result, nil
    end

    -- Otherwise it's a simple return value
    if debug then wt:Debug("Trigger result:", result) end
    return true, func, result
end

-- User Event Registration
---@param eventName string
---@param func function
---@return EventHandle|nil
function wt.UserEvent:Register(eventName, func)
    if wt.blockedEvents[eventName] then
        -- Do not register protected events (eg: COMBAT_LOG_EVENT_UNFILTERED)
        wt:Debug("This event is not allowed to be registered:", eventName)
        return nil
    end
    if not self.handlers[eventName] then
        self.handlers[eventName] = {}
        local success, _ = pcall(function()
            self:RegisterEvent(eventName)
        end)
        if not success then
            return nil
        end
    end

    table.insert(self.handlers[eventName], func)

    return { event = eventName, func = func }
end

wt.UserEvent:SetScript("OnEvent", function(self, event, ...)
    local handlers = self.handlers[event]
    if not handlers then return end

    for _, handler in ipairs(handlers) do
        handler(...)
    end
end)

-- User event deregistration
---@param handle EventHandle
function wt.UserEvent:Unregister(handle)
    local handlers = self.handlers[handle.event]
    if not handlers then return end

    for i, fn in ipairs(handlers) do
        if fn == handle.func then
            table.remove(handlers, i)
            break
        end
    end

    if #handlers == 0 then
        self.handlers[handle.event] = nil
        self:UnregisterEvent(handle.event)
    end
end

-- Deregister all events for a preset
---@param presetName string
function wt:DeRegisterPresetEvents(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then return end
    if not preset.enabled then return end
    wt:Debug("Unregistered event due to no remaining handlers:", presetName)

    -- Cancel auto-hide timer if any
    if preset.autoHideTimer then
        preset.autoHideTimer:Cancel()
        preset.autoHideTimer = nil
    end

    if preset.eventHandles then
        for _, handle in ipairs(preset.eventHandles) do
            if handle then
                wt.UserEvent:Unregister(handle)
            end
        end
    end
    
    -- Force clear any remaining handlers for this preset's events
    if preset.events then
        for _, eventName in ipairs(preset.events) do
            -- Check if there are any handlers left for this event
            local handlers = wt.UserEvent.handlers[eventName]
            if handlers and #handlers == 0 then
                -- Clean up completely if empty
                wt.UserEvent.handlers[eventName] = nil
                pcall(function() wt.UserEvent:UnregisterEvent(eventName) end)
            end
        end
    end
    
    preset.eventHandles = {}
    preset.lastTriggerResult = nil
end

-- Register user event handlers for a preset
---@param presetName string
function wt:RegisterPresetEvents(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then return end
    -- Deregister old events first and ensure clean slate
    wt:DeRegisterPresetEvents(presetName)
    if not preset.enabled then return end

    
    -- Initialize eventHandles table
    preset.eventHandles = {}

    -- Check if advanced conditions are enabled
    if not preset.advancedEnabled then return end

    if not preset.events or #preset.events == 0 then return end
    if not preset.trigger or preset.trigger == "" then return end

    -- Test and compile the trigger
    local valid, func, result = wt:TestTrigger(preset.trigger, false, presetName)
    if not valid then
        wt:Debug("Invalid trigger for preset:", presetName)
        return
    end

    -- If func is a function (user wrote function(event)...), use it directly
    -- Otherwise, func is a compiled function that returns a value
    local isEventHandler = (type(func) == "function" and result == nil)
    
    -- Store initial result (only for simple triggers)
    if not isEventHandler then
        preset.lastTriggerResult = result
    end

    -- Register all events
    local success = 0
    for _, eventName in ipairs(preset.events) do
        local wrapper
        
        if isEventHandler then
            -- User defined a function(event, ...) - call it with event name
            wrapper = function(...)
                -- Check load conditions before calling trigger
                if not wt:PresetMatchesConditions(presetName) then
                    wt:Debug("Event", eventName, "for", presetName, "- load conditions failed")
                    return
                end
                
                local ok, r = pcall(func, eventName, ...)
                preset.lastTriggerResult = ok and r or false
                
                -- Update preset visibility based on trigger result
                if preset.lastTriggerResult then
                    wt:ApplyPreset(presetName)
                    
                    -- Cancel existing auto-hide timer if any
                    if preset.autoHideTimer then
                        preset.autoHideTimer:Cancel()
                        preset.autoHideTimer = nil
                    end
                    
                    -- Start auto-hide timer if duration is set
                    local duration = preset.duration
                    if duration and duration > 0 then
                        preset.autoHideTimer = C_Timer.NewTimer(duration, function()
                            wt:HideTextureFrame(presetName)
                            preset.autoHideTimer = nil
                        end)
                    end
                else
                    -- Don't auto-hide multi-instance presets
                    if not (preset.instancePool and preset.instancePool.enabled) then
                        wt:HideTextureFrame(presetName)
                    end
                end
            end
        else
            -- Simple trigger that returns a value
            wrapper = function(...)
                -- Check load conditions before calling trigger
                if not wt:PresetMatchesConditions(presetName) then
                    wt:Debug("Event", eventName, "for", presetName, "- load conditions failed")
                    return
                end
                
                local ok, r = pcall(func, ...)
                preset.lastTriggerResult = ok and r or false
                
                -- Skip auto show/hide for multi-instance presets
                if preset.instancePool and preset.instancePool.enabled then
                    return
                end
                
                -- Update preset visibility based on trigger result
                if preset.lastTriggerResult then
                    wt:ApplyPreset(presetName)
                    
                    -- Cancel existing auto-hide timer if any
                    if preset.autoHideTimer then
                        preset.autoHideTimer:Cancel()
                        preset.autoHideTimer = nil
                    end
                    
                    -- Start auto-hide timer if duration is set
                    local duration = preset.duration
                    if duration and duration > 0 then
                        preset.autoHideTimer = C_Timer.NewTimer(duration, function()
                            wt:HideTextureFrame(presetName)
                            preset.autoHideTimer = nil
                        end)
                    end
                else
                    wt:HideTextureFrame(presetName)
                end
            end
        end

        local handle = wt.UserEvent:Register(eventName, wrapper)
        if handle then
            table.insert(preset.eventHandles, handle)
            success = success + 1
        else
            wt:Debug("Failed to register event:", eventName, "(restricted or invalid)")
        end
    end

    -- Only show success message if at least one event was registered
    if success > 0 then
        wt:Debug("Registered", success, "of", #preset.events, "events for preset:", presetName, "Handler type:", isEventHandler and "function" or "simple")
    end
end

-- Register user events for all presets
function wt:RegisterAllPresetEvents()
    for presetName, preset in pairs(WeakTexturesDB.presets) do
        if preset.enabled then
            wt:RegisterPresetEvents(presetName)
        end
    end
end

-- Parse comma-separated events into a table
---@param eventString string
---@return string[]
function wt:ParseEvents(eventString)
    if not eventString or eventString == "" then
        return {}
    end

    local events = {}
    for event in string.gmatch(eventString, "[^,]+") do
        local trimmed = strtrim(event)
        if trimmed ~= "" then
            table.insert(events, trimmed)
        end
    end
    return events
end

-- Convert events table to comma-separated string
---@param events string[]
---@return string
function wt:EventsToString(events)
    if not events or #events == 0 then
        return ""
    end
    return table.concat(events, ", ")
end

--Check if advanced conditions for a preset are met
---@param presetName string
---@return boolean
function wt:CheckPresetAdvancedConditions(presetName)
    local preset = WeakTexturesDB.presets[presetName]
    if not preset then return true end

    -- If advanced conditions not enabled, pass check
    if not preset.advancedEnabled then return true end

    -- If no trigger or events, pass check
    if not preset.trigger or preset.trigger == "" then return true end
    if not preset.events or #preset.events == 0 then return true end

    -- Return the last trigger result
    return preset.lastTriggerResult == true
end
