-- =====================================================
-- WeakTextures English (US) Localization
-- =====================================================
-- This file populates English strings as fallback

local _, wt = ...
local L = wt.locales.enUS

-- Minimap
L.MINIMAP_LEFTCLICK = "Left-Click to open "
L.MINIMAP_RIGHTCLICK = "Right-Click to open Settings"

-- Dialogs
L.DIALOG_CREATE_EXAMPLES = "WeakTextures\n\nDo you want to create example presets?\nThis will add %s example presets to help you get started."
L.MESSAGE_EXAMPLES_CREATED = "Created example presets. Check 'Examples' group to see them!"
L.MESSAGE_EXAMPLES_FAILED = "Failed to create example presets."
L.BUTTON_YES = "Yes"
L.BUTTON_NO = "No"

-- Messages
L.MESSAGE_EXAMPLES_EXISTS = "Example presets already exist."
L.MESSAGE_OLD_DB_CLEARED = "Old WeakTexturesDB data will be cleared. All data is now stored in profiles."
L.MESSAGE_PROFILE_LOADED = "Profile loaded successfully!"
L.MESSAGE_PROFILE_CREATED = "Profile created successfully!"
L.MESSAGE_PROFILE_COPIED = "Profile copied successfully!"
L.MESSAGE_PROFILE_DELETED = "Profile deleted successfully!"

-- Main UI
L.ADDON_NAME = "WeakTextures"
L.BUTTON_SETTINGS = "Settings"
L.BUTTON_FILTER = "Filter"
L.HEADER_FILTERS = "Filters"
L.PLACEHOLDER_SEARCH = "Search"
L.BUTTON_CREATE_NEW = "Create new"
L.BUTTON_IMPORT = "Import"
L.BUTTON_CLOSE = "Close"
L.BUTTON_SAVE_CHANGES = "Save changes"
L.STATUS_SAVED = "Saved"

-- Tabs
L.TAB_DISPLAY = "Display settings"
L.TAB_LOAD_CONDITIONS = "Load Conditions"
L.TAB_ADVANCED = "Advanced"

-- Basic Information
L.HEADER_BASIC_INFO = "Basic Information"
L.LABEL_PRESET_NAME = "Preset Name"
L.PLACEHOLDER_PRESET_NAME = "Enter the name for this preset."
L.LABEL_GROUP = "Group"
L.DROPDOWN_NO_GROUP = "No Group"
L.STATUS_UNGROUPED = "Ungrouped"
L.DROPDOWN_CREATE_NEW_GROUP = "Create new group"
L.PLACEHOLDER_GROUP_NAME = "Group Name/Subgroup1"
L.STATUS_DISABLED = "Disabled"

-- Texture and Frame Settings
L.HEADER_TEXTURE_FRAME = "Texture and Frame Settings"
L.LABEL_TEXTURE_PATH = "Texture Path"
L.PLACEHOLDER_TEXTURE_PATH = "Enter the full path. "
L.LABEL_TYPE = "Type"
L.TYPE_STATIC = "Static"
L.TYPE_STOP_MOTION = "Stop Motion"
L.LABEL_STRATA = "Strata"
L.LABEL_LEVEL = "Level"
L.LABEL_ANCHOR_FRAME = "Anchor Frame"
L.ANCHOR_SCREEN = "Screen"
L.ANCHOR_CUSTOM_FRAME = "Custom frame"
L.BUTTON_SELECT = "Select"

-- Visual Settings
L.HEADER_VISUAL = "Visual Settings"
L.LABEL_WIDTH = "Width"
L.LABEL_HEIGHT = "Height"
L.LABEL_X = "X"
L.LABEL_Y = "Y"
L.LABEL_SCALE = "Scale"
L.LABEL_ANGLE = "Angle"
L.LABEL_ALPHA = "Alpha"
L.BUTTON_UNLOCK_POSITION = "Unlock position"
L.BUTTON_LOCK_POSITION = "Lock position"

-- Stop Motion Settings
L.LABEL_COL = "Col"
L.LABEL_ROW = "Row"
L.LABEL_FRAMES = "Frames"
L.LABEL_FPS = "FPS"

-- Load Conditions
L.HEADER_LOADING = "Loading"
L.CHECKBOX_CAN_LOAD = "Enabled"
L.HEADER_ADVANCED_CONDITIONS = "Advanced Conditions"

-- Character Conditions
L.HEADER_CHARACTER_CONDITIONS = "Character Conditions"
L.LABEL_CLASS = "Class"
L.DROPDOWN_ANY_CLASS = "Any Class"
L.LABEL_SPEC = "Spec"
L.DROPDOWN_ANY_SPEC = "Any Spec"
L.LABEL_PLAYER_NAME = "Player Name"

-- State Conditions
L.HEADER_STATE_CONDITIONS = "State Conditions"
L.PREFIX_IN = "In "
L.PREFIX_NOT = "Not "
L.PREFIX_AT = "At "
L.CHECKBOX_ALIVE = "Alive"
L.CHECKBOX_COMBAT = "Combat"
L.CHECKBOX_RESTED = "Rested"
L.CHECKBOX_INSTANCE = "Instance"
L.CHECKBOX_ENCOUNTER = "Encounter"
L.CHECKBOX_PET_BATTLE = "Pet Battle"
L.CHECKBOX_VEHICLE = "Vehicle"
L.CHECKBOX_HOME = "Home"

-- Environment
L.HEADER_ENVIRONMENT = "Environment"
L.LABEL_ZONE = "Zone"
L.PLACEHOLDER_ZONE = "Zone name"

-- Advanced Tab
L.LABEL_EVENTS = "Events (comma-separated):\nCLEU is blacklisted!"
L.PLACEHOLDER_EVENTS = "e.g. PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED"
L.LABEL_DURATION = "Duration:"
L.PLACEHOLDER_SECONDS = "Seconds"
L.LABEL_TRIGGER_FUNCTION = "Trigger Function (return true/false):"
L.ERROR_TRIGGER_SYNTAX = "Trigger has errors and cannot be used. Check your syntax."

-- Import/Export
L.HEADER_IMPORT = "Import Presets and Groups"
L.BUTTON_ACCEPT_IMPORT = "Accept import"

-- Settings Panel - About
L.SETTINGS_HEADER_ABOUT = "About"
L.SETTINGS_DESC_ABOUT = "Addon information"
L.SETTINGS_VERSION = "Version: "
L.SETTINGS_DESCRIPTION = "Display custom textures with advanced condition-based visibility controls."
L.BUTTON_REPORT_ISSUES = "Report Issues"

-- Settings Panel - Contributors
L.SETTINGS_HEADER_CONTRIBUTORS = "Contributors"
L.SETTINGS_DESC_CONTRIBUTORS = "People who helped with this addon"
L.SETTINGS_CONTRIBUTORS_TEXT = "Thank you to everyone who contributed to this project:"
L.SETTINGS_CONTRIBUTORS_AUTHOR = "Author: "
L.SETTINGS_CONTRIBUTORS_TRANSLATIONS = "Translations: "
L.SETTINGS_CONTRIBUTORS_SUGGESTIONS = "Suggestions: "
L.SETTINGS_CONTRIBUTORS_INSPIRED = "Inspired by: "

-- Settings Panel - Profile Management
L.SETTINGS_HEADER_PROFILES = "Profile Management"
L.SETTINGS_DESC_PROFILES = "Manage addon profiles"
L.SETTINGS_PROFILE_SWITCH = "Switch to profile: "
L.SETTINGS_PROFILE_ACTIVE = "Active Profile"
L.SETTINGS_PROFILE_SELECT_DESC = "Select which profile to use on this character"
L.SETTINGS_PROFILE_CREATE_LABEL = "Create New Profile:"
L.SETTINGS_BUTTON_CREATE = "Create"
L.SETTINGS_PROFILE_COPY_LABEL = "Copy Current Profile:"
L.SETTINGS_BUTTON_COPY = "Copy"
L.SETTINGS_PROFILE_RENAME_LABEL = "Rename Current Profile:"
L.SETTINGS_BUTTON_RENAME = "Rename"
L.SETTINGS_BUTTON_DELETE_PROFILE = "Delete Current Profile"
L.SETTINGS_BUTTON_DELETE = "Delete"
L.SETTINGS_BUTTON_CANCEL = "Cancel"
L.SETTINGS_PROFILE_INFO = "Profiles allow you to have different preset configurations per character. All profiles are visible on all characters, but each character remembers which profile it uses."
L.SETTINGS_BUTTON_EXPORT_PROFILE = "Export Current Profile"
L.SETTINGS_EXPORT_TITLE = "Export Profile: "
L.SETTINGS_IMPORT_TITLE = "Import Profile"
L.SETTINGS_PROFILE_NAME_LABEL = "Profile Name (optional):"

-- Settings Panel - General
L.SETTINGS_HEADER_GENERAL = "General Settings"
L.SETTINGS_DESC_GENERAL = "Basic addon configuration"
L.SETTINGS_CHECKBOX_DEBUG = "Enable Debug Mode"
L.SETTINGS_DESC_DEBUG = "Shows debug messages in chat for troubleshooting"

-- Settings Panel - UI
L.SETTINGS_HEADER_UI = "User Interface"
L.SETTINGS_DESC_UI = "Customize the addon interface"
L.SETTINGS_UI_SCALE = "AddOn UI Scale"

-- Settings Panel - Advanced
L.SETTINGS_HEADER_ADVANCED = "Advanced"
L.SETTINGS_DESC_ADVANCED = "Advanced addon features"
L.SETTINGS_BUTTON_REBUILD_EVENTS = "Rebuild Event Table"
L.SETTINGS_BUTTON_REBUILD_EVENTS_SHORT = "Rebuild ADDON_EVENTS"
L.SETTINGS_DESC_REBUILD_EVENTS = "Manually rebuild the ADDON_EVENTS optimization table"
L.SETTINGS_BUTTON_CLEAR_DATA = "Clear All Data"
L.SETTINGS_BUTTON_CLEAR_PRESETS = "Clear All Presets"
L.SETTINGS_CONFIRM_CLEAR_ALL = "This will delete ALL presets and groups. This action cannot be undone! Are you sure you want to continue?"
L.SETTINGS_BUTTON_DELETE_EVERYTHING = "Delete Everything"
L.SETTINGS_WARNING_DELETE_ALL = "WARNING: Deletes all presets and groups permanently"
L.SETTINGS_BUTTON_RELOAD = "Reload Interface"
L.SETTINGS_BUTTON_RELOAD_UI = "Reload UI"
L.SETTINGS_DESC_RELOAD = "Reload the user interface to apply changes"

-- Settings Panel - Language
L.SETTINGS_HEADER_LANGUAGE = "Language"
L.SETTINGS_DESC_LANGUAGE = "Language and localization settings"
L.SETTINGS_LANGUAGE_LABEL = "Language"
L.SETTINGS_LANGUAGE_SELECT_DESC = "Select your preferred language. Requires UI reload to take effect."
L.SETTINGS_LANGUAGE_AUTO_DETECT = " automatically detects your game client language. You can override it here."
L.SETTINGS_LANGUAGE_SUPPORTED = "Currently supported languages:"
L.SETTINGS_LANGUAGE_EN = "• English (enUS)"
L.SETTINGS_LANGUAGE_DE = "• Deutsch (deDE)"

-- Settings Panel - Textures
L.SETTINGS_HEADER_TEXTURES = "Textures"
L.SETTINGS_DESC_TEXTURES = "Texture management settings"
L.SETTINGS_CHECKBOX_AUTO_REGISTER = "Auto-register custom textures"
L.SETTINGS_DESC_AUTO_REGISTER = "Automatically register custom texture paths with LibSharedMedia so they can be used by other addons"
L.SETTINGS_BUTTON_GENERATE_EXAMPLES = "Generate Example Presets"
L.SETTINGS_BUTTON_CREATE_EXAMPLES = "Create Examples"
L.SETTINGS_DESC_GENERATE_EXAMPLES = "Create example presets to help you get started with "

-- Settings Panel - Font
L.SETTINGS_HEADER_FONT = "Font"
L.SETTINGS_DESC_FONT = "Font and appearance settings"
L.SETTINGS_FONT_LABEL = "Font"
L.SETTINGS_DESC_FONT_SELECT = "Select the font to use throughout the addon interface."
L.SETTINGS_BOLD_FONT = "Bold Font"
L.SETTINGS_DESC_BOLD_FONT = "Select the bold font variant to use for headers and large text."

-- Dynamic/Template Texts
L.ERROR_EVENT_NOT_ALLOWED = "event '%s' is not allowed to be used."
L.PLACEHOLDER_TRIGGER_CODE = "--e.g.  function(e) if InCombatLockdown() then return true end end"
L.MESSAGE_MIGRATED_TO_PROFILE = "Migrated existing data to 'Default' profile."
L.CONFIRM_DELETE_PROFILE = "Delete profile '%s'? This cannot be undone!"
L.SETTINGS_DESC_UI_SCALE = "Adjust the size of the %s main window"
