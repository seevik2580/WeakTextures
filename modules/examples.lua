local _, wt = ...

-- Example preset data structures
local EXAMPLE_PRESETS = {
["presets"] = {
    ["Example - Advanced - pull timer"] = {
      ["totalFrames"] = 23,
      ["scale"] = 1,
      ["example"] = true,
      ["sounds"] = {
      },
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["textures"] = {
        [1] = {
          ["y"] = 33,
          ["x"] = -320,
          ["anchor"] = "UIParent",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\semaphor-green.png",
          ["height"] = 122,
          ["width"] = 48,
        },
      },
      ["type"] = "static",
      ["columns"] = 4,
      ["duration"] = 0,
      ["trigger"] = "function(e, ...)\
  local _, duration = ...\
  if duration == nil then\
    duration = 10\
  end\
  \
  local prefix = \"Interface\\\\AddOns\\\\WeakTextures\\\\Media\\\\\"\
  \
  -- Default for all CreateInstance\
  local defaultConfig = {\
    textOffsetX = 50,\
    font = \"Friz Quadrata TT\",\
    fontSize = 20,\
    fontOutline = \"THICKOUTLINE\",\
    textColor = {r=1, g=1, b=1, a=1},\
    soundChannel = \"MASTER\"\
  }\
  \
  local media = {\
    textures = {\
      [3] = prefix .. \"Textures\\\\semaphor-red.png\",\
      [2] = prefix .. \"Textures\\\\semaphor-yellow.png\",\
      [1] = prefix .. \"Textures\\\\semaphor-yellow.png\",\
      [0] = prefix .. \"Textures\\\\semaphor-green.png\",\
    },\
    sounds = {\
      [3] = prefix .. \"Sounds\\\\3.ogg\",\
      [2] = prefix .. \"Sounds\\\\2.ogg\",\
      [1] = prefix .. \"Sounds\\\\1.ogg\"\
    }\
  }\
  \
  local function config(overrides)\
    local result = {}\
    -- Copy default\
    for k, v in pairs(defaultConfig) do\
      result[k] = v\
    end\
    -- Rewrite values\
    if overrides then\
      for k, v in pairs(overrides) do\
        result[k] = v\
      end\
    end\
    return result\
  end\
  \
  -- Countdown 3, 2, 1\
  for i = 3, 1, -1 do\
    C_Timer.After(duration - i, function()\
        WeakTexturesAPI:CreateInstance(config({\
              texture = media.textures[i],\
              text = tostring(i),\
              sound = media.sounds[i]\
        }))\
        WeakTexturesAPI:RefreshPreset(true)\
    end)\
  end\
  \
  -- When countdown expires\
  C_Timer.After(duration, function()\
      WeakTexturesAPI:CreateInstance(config({\
            texture = media.textures[0],\
            text = \"GO!\",\
            fontSize = 50,  -- Override\
            textOffsetX=100, -- Override\
            textColor = {r=0, g=1, b=0, a=1}  -- Override\
      }))\
      WeakTexturesAPI:RefreshPreset(true)\
  end)\
  \
  -- Hide preset\
  C_Timer.After(duration + 1, function()\
      WeakTexturesAPI:RefreshPreset(false)\
  end)  \
end",
      ["text"] = {
        ["outline"] = "OUTLINE",
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["enabled"] = false,
        ["color"] = {
          ["a"] = 1,
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1,
        },
        ["offsetY"] = 125,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["fps"] = 15,
      ["eventHandles"] = {
        [1] = {
          ["event"] = "START_PLAYER_COUNTDOWN",
        },
      },
      ["rows"] = 6,
      ["version"] = 2,
      ["frameLevel"] = 100,
      ["events"] = {
        [1] = "START_PLAYER_COUNTDOWN",
      },
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notCombat"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["playerName"] = "",
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["notRested"] = false,
      },
      ["enabled"] = false,
      ["group"] = "Examples/Advanced",
    },
    ["Example - Static Texture"] = {
      ["strata"] = "LOW",
      ["group"] = "Examples/Simple",
      ["example"] = true,
      ["sounds"] = {
      },
      ["advancedEnabled"] = false,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["textures"] = {
        [1] = {
          ["y"] = 100,
          ["x"] = 0,
          ["anchor"] = "UIParent",
          ["height"] = 64,
          ["width"] = 64,
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\emoji.tga",
        },
      },
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "",
      ["text"] = {
        ["enabled"] = false,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1,
        },
        ["offsetY"] = 125,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["eventHandles"] = {
      },
      ["events"] = {
      },
      ["version"] = 2,
      ["scale"] = 1,
      ["duration"] = 0,
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notCombat"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["notRested"] = false,
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["playerName"] = "",
      },
      ["enabled"] = false,
    },
    ["Example - Stop Motion"] = {
      ["strata"] = "LOW",
      ["totalFrames"] = 23,
      ["group"] = "Examples/Simple",
      ["example"] = true,
      ["sounds"] = {
      },
      ["advancedEnabled"] = false,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 146,
      ["textures"] = {
        [1] = {
          ["y"] = 73,
          ["x"] = 377,
          ["anchor"] = "UIParent",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\fastercat.tga",
          ["height"] = 209,
          ["width"] = 270,
        },
      },
      ["type"] = "motion",
      ["frameLevel"] = 100,
      ["duration"] = 0,
      ["trigger"] = "",
      ["text"] = {
        ["enabled"] = false,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1,
        },
        ["offsetY"] = 125,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["fps"] = 15,
      ["rows"] = 6,
      ["scale"] = 1,
      ["version"] = 2,
      ["enabled"] = false,
      ["events"] = {
      },
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notCombat"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["notRested"] = false,
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["playerName"] = "",
      },
      ["columns"] = 4,
      ["eventHandles"] = {
      },
    },
    ["Example - Advanced - target type"] = {
      ["example"] = true,
      ["strata"] = "HIGH",
      ["scale"] = 1,
      ["eventHandles"] = {
        [1] = {
          ["event"] = "PLAYER_TARGET_CHANGED",
        },
      },
      ["advancedEnabled"] = true,
      ["angle"] = 0,
      ["enabled"] = false,
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "function(e)\
  if not UnitExists(\"target\") then\
    return false\
  end\
  \
  local texPrefix = \"Interface\\\\AddOns\\\\UFArtSharedMedia\\\\Media\\\\\"\
  local targetType = {\
    [\"elite\"] = texPrefix .. \"Elite\\\\FrameSize80_256x64.png\",\
    [\"worldboss\"] = texPrefix .. \"Elite\\\\FrameSize80_256x64.png\",\
    [\"normal\"] = texPrefix .. \"Normal\\\\NoPowerBarSize70_256x64.png\",\
  }\
  \
  local classification = UnitClassification(\"target\")\
  local texturePath = targetType[classification] or targetType[\"normal\"]\
  \
  WeakTexturesAPI:CreateInstance({\
      texture = texturePath,\
      text = classification,\
      textOffsetY = 50,\
      fontSize = 20,\
  })\
  \
  return true\
end",
      ["alpha"] = 1,
      ["events"] = {
        [1] = "PLAYER_TARGET_CHANGED",
      },
      ["duration"] = 0,
      ["group"] = "Examples/Advanced",
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notCombat"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["playerName"] = "",
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["notRested"] = false,
      },
      ["textures"] = {
        [1] = {
          ["y"] = 0,
          ["x"] = 0,
          ["anchor"] = "UUF_Target",
          ["height"] = 50,
          ["width"] = 275,
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\emoji.tga",
        },
      },
    },
    ["Example - Advanced - trade"] = {
      ["group"] = "Examples/Advanced",
      ["example"] = true,
      ["sounds"] = {
      },
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["enabled"] = false,
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "function(e)\
        if e == \"TRADE_SHOW\" then\
            return true\
        else\
            return false\
        end\
    end\
            ",
      ["text"] = {
        ["enabled"] = false,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1,
        },
        ["offsetY"] = 125,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["duration"] = 0,
      ["events"] = {
        [1] = "TRADE_SHOW",
        [2] = "TRADE_CLOSED",
      },
      ["eventHandles"] = {
        [1] = {
          ["event"] = "TRADE_SHOW",
        },
        [2] = {
          ["event"] = "TRADE_CLOSED",
        },
      },
      ["textures"] = {
        [1] = {
          ["y"] = -4,
          ["x"] = 282,
          ["anchor"] = "TradeFrame",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\emoji.tga",
          ["height"] = 198,
          ["width"] = 197,
        },
      },
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notCombat"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["playerName"] = "",
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["notRested"] = false,
      },
      ["version"] = 2,
      ["scale"] = 1,
    },
    ["Example - Advanced - death alert"] = {
      ["totalFrames"] = 158,
      ["scale"] = 1,
      ["example"] = true,
      ["tempOverrides"] = {
        ["fontSize"] = 80,
        ["scale"] = 1.17,
        ["text"] = "DEAD!",
        ["alpha"] = 0.9,
        ["font"] = "Friz Quadrata TT",
        ["offsetX"] = 78,
        ["fontOutline"] = "THICKOUTLINE",
        ["soundChannel"] = "MASTER",
        ["offsetY"] = 38,
        ["sound"] = "Interface\\AddOns\\WeakTextures\\Media\\Sounds\\turtlemoan6.ogg",
        ["textColor"] = {
          ["a"] = 1,
          ["b"] = 0.62,
          ["g"] = 0.63,
          ["r"] = 0.38,
        },
      },
      ["sounds"] = {
      },
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = true,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["eventHandles"] = {
        [1] = {
          ["event"] = "UNIT_DIED",
        },
      },
      ["textures"] = {
        [1] = {
          ["y"] = 219,
          ["x"] = -8,
          ["anchor"] = "UIParent",
          ["height"] = 548,
          ["width"] = 650,
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\among\\default.tga",
        },
      },
      ["type"] = "motion",
      ["frameLevel"] = 100,
      ["duration"] = 3,
      ["trigger"] = "function(event, ...)\
  local prefix = \"Interface\\\\AddOns\\\\WeakTextures\\\\Media\\\\Sounds\\\\\"\
  local sounds = { \"turtlemoan1.ogg\", \"turtlemoan2.ogg\", \"turtlemoan3.ogg\", \"turtlemoan4.ogg\", \"turtlemoan5.ogg\", \"turtlemoan6.ogg\" }\
  \
  WeakTexturesAPI:CreateInstance({\
      text = \"DEAD!\",\
      offsetX = math.random(-200, 200),\
      offsetY = math.random(-100, 100),\
      scale = math.random(80, 150) / 100,\
      alpha = 0.9,\
      font = \"Friz Quadrata TT\",\
      fontSize = 80,\
      fontOutline = \"THICKOUTLINE\",\
      textColor = {r=math.random(0,100)/100, g=math.random(0,100)/100, b=math.random(0,100)/100, a=1},\
      sound = prefix .. sounds[math.random(1, 6)],\
      soundChannel = \"MASTER\"\
  })\
  return false\
end\
\
\
\
\
",
      ["text"] = {
        ["enabled"] = true,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1,
        },
        ["offsetY"] = 125,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["fps"] = 60,
      ["rows"] = 12,
      ["events"] = {
        [1] = "UNIT_DIED",
      },
      ["version"] = 2,
      ["enabled"] = false,
      ["columns"] = 14,
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notRested"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = true,
        ["playerName"] = "",
        ["petBattle"] = false,
        ["notInstance"] = true,
        ["rested"] = false,
        ["notCombat"] = false,
      },
      ["group"] = "Examples/Advanced",
    },
    ["Example - Advanced - new whisper"] = {
      ["example"] = true,
      ["scale"] = 1,
      ["eventHandles"] = {
        [1] = {
          ["event"] = "CHAT_MSG_WHISPER",
        },
      },
      ["sounds"] = {
      },
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = true,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["enabled"] = false,
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "function(e, ...)\
  if e == \"CHAT_MSG_WHISPER\" then\
    local message, sender = ...\
    -- Show notification when receiving whisper\
    if string.find(message, \"pi me\") then\
      WeakTexturesAPI:CreateInstance({\
          text = \"Requested PI from\\n\" .. sender,\
          texture = \"Interface\\\\ICONS\\\\spell_holy_powerinfusion\",\
          offsetY = 200,\
          textColor = {1, 0.5, 1, 1},\
      })\
    end\
  end\
end",
      ["text"] = {
        ["enabled"] = true,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1,
        },
        ["offsetY"] = 125,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["version"] = 2,
      ["textures"] = {
        [1] = {
          ["y"] = 0,
          ["x"] = 0,
          ["anchor"] = "UIParent",
          ["width"] = 64,
          ["height"] = 64,
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\emoji.tga",
        },
      },
      ["group"] = "Examples/Advanced",
      ["conditions"] = {
        ["combat"] = false,
        ["zone"] = "",
        ["encounter"] = false,
        ["nothousing"] = false,
        ["notVehicle"] = false,
        ["notCombat"] = false,
        ["alive"] = false,
        ["vehicle"] = false,
        ["dead"] = false,
        ["housing"] = false,
        ["instance"] = false,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["notRested"] = false,
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["playerName"] = "",
      },
      ["events"] = {
        [1] = "CHAT_MSG_WHISPER",
      },
      ["duration"] = 3,
    },
  },
  ["groups"] = {
    ["Examples/Advanced"] = true,
    ["Examples/Simple"] = true,
    ["Examples"] = true,
  },
}

---Create example presets using import system
function wt:CreateExamplePresets()
    local L = wt.L
    local existingCount = 0
    local createdCount = 0
    
    -- Check which presets already exist
    for presetName, _ in pairs(EXAMPLE_PRESETS.presets) do
        if WeakTexturesDB.presets[presetName] then
            existingCount = existingCount + 1
        end
    end
    
    -- If all examples already exist, don't import
    if existingCount == 2 then
        print("|cffff9900["..wt.addonName.."]|r " .. L.MESSAGE_EXAMPLES_EXISTS)
        return
    end
    
    -- Create data structure with only non-existing presets
    local dataToImport = {
        ["groups"] = EXAMPLE_PRESETS.groups,
        ["presets"] = {}
    }
    
    for presetName, presetData in pairs(EXAMPLE_PRESETS.presets) do
        if not WeakTexturesDB.presets[presetName] then
            dataToImport.presets[presetName] = presetData
            createdCount = createdCount + 1
        end
    end
    
    -- Serialize and import
    if createdCount > 0 then
        local serialized = self:SerializeTable(dataToImport)
        if serialized then
            self:ImportFromString(serialized)
            
            -- Apply all presets immediately after import
            if self.ApplyAllPresets then
                self:ApplyAllPresets()
            end
            
            print("|cffff9900["..wt.addonName.."]|r " .. L.MESSAGE_EXAMPLES_CREATED)
        else
            print("|cffff0000["..wt.addonName.."]|r " .. L.MESSAGE_EXAMPLES_FAILED)
        end
    end
end

---Show confirmation dialog for creating example presets
function wt:ShowCreateExamplesDialog()
    local L = wt.L
    local count = 0
    for _ in pairs(EXAMPLE_PRESETS.presets) do
        count = count + 1
    end
    StaticPopupDialogs["WEAKTEXTURES_CREATE_EXAMPLES"] = {
        text = string.format(L.DIALOG_CREATE_EXAMPLES, count),
        button1 = L.BUTTON_YES,
        button2 = L.BUTTON_NO,
        OnAccept = function()
            wt:CreateExamplePresets()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("WEAKTEXTURES_CREATE_EXAMPLES")
end