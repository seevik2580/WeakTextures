local _, wt = ...

-- Example preset data structures
local EXAMPLE_PRESETS = {
  ["presets"] = {
    ["Example - Advanced - pull timer"] = {
      ["color"] = {
        ["a"] = 1,
        ["r"] = 1,
        ["g"] = 1,
        ["b"] = 1,
      },
      ["eventHandles"] = {
      },
      ["sounds"] = {
      },
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["sound"] = {
        ["channel"] = "Master",
      },
      ["enabled"] = false,
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "function(e, ...)\
  local _, duration = ...\
  local prefix = \"Interface\\\\AddOns\\\\WeakTextures\\\\Media\\\\\"\
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
  -- Build timeline for countdown\
  local timeline = {}\
  \
  -- Countdown events: 3, 2, 1\
  for i = 3, 1, -1 do\
    table.insert(timeline, {\
        delay = duration - i,\
        update = {\
          alpha = 1,  -- Fade in when countdown starts\
          texture = media.textures[i],\
          text = tostring(i),\
          sound = media.sounds[i],\
        }\
    })\
  end\
  \
  -- \"GO!\" event when countdown expires\
  table.insert(timeline, {\
      delay = duration,\
      update = {\
        texture = media.textures[0],\
        text = \"GO!\",\
        fontSize = 50,\
        textOffsetX = 100,\
        textColor = {r=0, g=1, b=0, a=1},\
      }\
  })\
  \
  -- Hide 1 second after countdown ends\
  table.insert(timeline, {\
      delay = duration + 1,\
      destroy = true\
  })\
  \
  -- Create instance with timeline - START INVISIBLE\
  WeakTexturesAPI:CreateInstance({\
      timeline = timeline\
  })\
  \
  WeakTexturesAPI:RefreshPreset(true)\
end",
      ["text"] = {
        ["enabled"] = true,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 60,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 1,
          ["g"] = 0,
          ["b"] = 0.039215687662363,
        },
        ["offsetY"] = 0,
        ["content"] = "",
        ["size"] = 30,
      },
      ["alpha"] = 0,
      ["duration"] = 0,
      ["example"] = true,
      ["group"] = "Examples/Advanced",
      ["events"] = {
        [1] = "START_PLAYER_COUNTDOWN",
      },
      ["scale"] = 1,
      ["version"] = 2,
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
        ["instance"] = true,
        ["notPetBattle"] = false,
        ["notEncounter"] = false,
        ["notCombat"] = false,
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["playerName"] = "",
      },
      ["originalGroup"] = "Examples/Advanced",
      ["textures"] = {
        [1] = {
          ["y"] = 43,
          ["x"] = -369,
          ["anchor"] = "UIParent",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\semaphor-green.png",
          ["height"] = 179,
          ["width"] = 72,
        },
      },
    },
    ["Example - Static Texture"] = {
      ["strata"] = "HIGH",
      ["scale"] = 1,
      ["duration"] = 0,
      ["sounds"] = {
      },
      ["advancedEnabled"] = false,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["sound"] = {
        ["channel"] = "MASTER",
      },
      ["enabled"] = false,
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "",
      ["text"] = {
        ["enabled"] = true,
        ["font"] = "PT Sans Narrow Bold",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 0.090196080505848,
          ["g"] = 0.678431391716,
          ["b"] = 0.50196081399918,
        },
        ["offsetY"] = 50,
        ["content"] = "Hello World",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["group"] = "Examples/Simple",
      ["example"] = true,
      ["events"] = {
      },
      ["version"] = 2,
      ["textures"] = {
        [1] = {
          ["y"] = 0,
          ["x"] = 0,
          ["anchor"] = "UIParent",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\emoji.tga",
          ["height"] = 81,
          ["width"] = 81,
        },
      },
      ["color"] = {
        ["a"] = 1,
        ["r"] = 0.10588236153126,
        ["g"] = 1,
        ["b"] = 0,
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
      ["originalGroup"] = "Examples/Simple",
      ["eventHandles"] = {
      },
    },
    ["Example - Stop Motion"] = {
      ["strata"] = "DIALOG",
      ["totalFrames"] = 23,
      ["group"] = "Examples/Simple",
      ["example"] = true,
      ["sounds"] = {
      },
      ["duration"] = 0,
      ["advancedEnabled"] = false,
      ["instancePool"] = {
        ["enabled"] = false,
        ["maxInstances"] = 10,
      },
      ["angle"] = 360,
      ["sound"] = {
        ["channel"] = "MASTER",
      },
      ["columns"] = 4,
      ["textures"] = {
        [1] = {
          ["y"] = 4,
          ["x"] = -135,
          ["anchor"] = "UIParent",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\fastercat.tga",
          ["height"] = 246,
          ["width"] = 240,
        },
      },
      ["type"] = "motion",
      ["frameLevel"] = 100,
      ["eventHandles"] = {
      },
      ["trigger"] = "",
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
      ["fps"] = 15,
      ["version"] = 2,
      ["enabled"] = false,
      ["events"] = {
      },
      ["rows"] = 6,
      ["scale"] = 1,
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
      ["originalGroup"] = "Examples/Simple",
      ["color"] = {
        ["a"] = 1,
        ["r"] = 1,
        ["g"] = 0.23529413342476,
        ["b"] = 0,
      },
    },
    ["Example - Advanced - death alert"] = {
      ["totalFrames"] = 158,
      ["color"] = {
        ["a"] = 1,
        ["r"] = 1,
        ["g"] = 1,
        ["b"] = 1,
      },
      ["duration"] = 3,
      ["sounds"] = {
      },
      ["example"] = true,
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = true,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["sound"] = {
        ["channel"] = "MASTER",
      },
      ["group"] = "Examples/Advanced",
      ["textures"] = {
        [1] = {
          ["y"] = 318,
          ["x"] = 0,
          ["anchor"] = "UIParent",
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\default.tga",
          ["height"] = 502,
          ["width"] = 513,
        },
      },
      ["type"] = "motion",
      ["columns"] = 14,
      ["rows"] = 12,
      ["trigger"] = "function(event, ...)\
  if not event == \"UNIT_DIED\" then return false end\
  local prefix = \"Interface\\\\AddOns\\\\WeakTextures\\\\Media\\\\Sounds\\\\\"\
  local sounds = { \"turtlemoan1.ogg\", \"turtlemoan2.ogg\", \"turtlemoan3.ogg\", \"turtlemoan4.ogg\", \"turtlemoan5.ogg\", \"turtlemoan6.ogg\" }\
  \
  WeakTexturesAPI:CreateInstance({\
      sound = prefix .. sounds[math.random(1, 6)],\
      textColor = {r=math.random(0,100)/100, g=math.random(0,100)/100, b=math.random(0,100)/100, a=1},\
      offsetX = math.random(-200, 200),\
      offsetY = math.random(-100, 100),\
  })\
end\
\
\
\
\
",
      ["text"] = {
        ["enabled"] = true,
        ["font"] = "PT Sans Narrow Bold",
        ["offsetX"] = 1,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["r"] = 0,
          ["g"] = 0.65490198135376,
          ["b"] = 1,
        },
        ["offsetY"] = 100,
        ["content"] = "UNIT DEAD!",
        ["size"] = 50,
      },
      ["alpha"] = 1,
      ["fps"] = 60,
      ["frameLevel"] = 100,
      ["version"] = 2,
      ["events"] = {
        [1] = "UNIT_DIED",
      },
      ["enabled"] = false,
      ["eventHandles"] = {
      },
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
      ["originalGroup"] = "Examples/Advanced",
      ["scale"] = 1,
    },
    ["Example - Advanced - new whisper"] = {
      ["scale"] = 1,
      ["duration"] = 3,
      ["color"] = {
        ["a"] = 1,
        ["b"] = 1,
        ["g"] = 1,
        ["r"] = 1,
      },
      ["sounds"] = {
      },
      ["example"] = true,
      ["advancedEnabled"] = true,
      ["instancePool"] = {
        ["enabled"] = true,
        ["maxInstances"] = 10,
      },
      ["angle"] = 0,
      ["sound"] = {
        ["channel"] = "MASTER",
      },
      ["enabled"] = false,
      ["type"] = "static",
      ["frameLevel"] = 100,
      ["trigger"] = "function(e, ...)\
  if e == \"CHAT_MSG_WHISPER\" then\
    WeakTexturesAPI:CreateInstance({\
        text = \"New whisper\",\
        timeline = {\
          {delay = 2, update = {text = \"hahaha\", sound = \"BigWigs: Alarm\"}},\
        }\
    })\
  end\
  WeakTexturesAPI:RefreshPreset(true)\
end",
      ["text"] = {
        ["enabled"] = true,
        ["font"] = "Fonts\\FRIZQT__.TTF",
        ["offsetX"] = 0,
        ["outline"] = "OUTLINE",
        ["color"] = {
          ["a"] = 1,
          ["b"] = 1,
          ["g"] = 0.66666668653488,
          ["r"] = 0,
        },
        ["offsetY"] = 100,
        ["content"] = "",
        ["size"] = 48,
      },
      ["alpha"] = 1,
      ["eventHandles"] = {
      },
      ["textures"] = {
        [1] = {
          ["y"] = 116,
          ["x"] = -1,
          ["anchor"] = "UIParent",
          ["height"] = 64,
          ["width"] = 64,
          ["texture"] = "Interface\\AddOns\\WeakTextures\\Media\\Textures\\emoji.tga",
        },
      },
      ["events"] = {
        [1] = "CHAT_MSG_WHISPER",
        [2] = "CHAT_MSG_BN_WHISPER",
      },
      ["version"] = 2,
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
        ["notEncounter"] = true,
        ["notRested"] = false,
        ["petBattle"] = false,
        ["notInstance"] = false,
        ["rested"] = false,
        ["playerName"] = "",
      },
      ["originalGroup"] = "Examples/Advanced",
      ["group"] = "Examples/Advanced",
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