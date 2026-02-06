-- =====================================================
-- WeakTextures German (DE) Localization
-- =====================================================
-- This file populates German translations

local _, wt = ...
local L = wt.locales.deDE

-- Minimap
L.MINIMAP_LEFTCLICK = "Linksklick zum Öffnen "
L.MINIMAP_RIGHTCLICK = "Rechtsklick zum Öffnen der Einstellungen"

-- Dialogs
L.DIALOG_CREATE_EXAMPLES = "WeakTextures\n\nMöchtest du Beispielvorlagen erstellen?\nDies fügt %s Beispielvorlagen hinzu, um dir den Einstieg zu erleichtern."
L.MESSAGE_EXAMPLES_CREATED = "Beispielvorlagen erstellt. Schau dir die Gruppe 'Beispiele' an!"
L.MESSAGE_EXAMPLES_FAILED = "Fehler beim Erstellen der Beispielvorlagen."
L.BUTTON_YES = "Ja"
L.BUTTON_NO = "Nein"

-- Messages
L.MESSAGE_EXAMPLES_EXISTS = "Beispielvorlagen existieren bereits."

-- Main UI
L.ADDON_NAME = "WeakTextures"
L.BUTTON_SETTINGS = "Einstellungen"
L.BUTTON_FILTER = "Filter"
L.HEADER_FILTERS = "Filter"
L.PLACEHOLDER_SEARCH = "Suche"
L.BUTTON_CREATE_NEW = "Neu erstellen"
L.BUTTON_IMPORT = "Importieren"
L.BUTTON_CLOSE = "Schließen"
L.BUTTON_SAVE_CHANGES = "Änderungen speichern"
L.STATUS_SAVED = "Gespeichert"

-- Tabs
L.TAB_DISPLAY = "Anzeigeeinstellungen"
L.TAB_LOAD_CONDITIONS = "Ladebedingungen"
L.TAB_ADVANCED = "Fortgeschritten"

-- Basic Information
L.HEADER_BASIC_INFO = "Grundinformationen"
L.LABEL_PRESET_NAME = "Vorlagenname"
L.PLACEHOLDER_PRESET_NAME = "Gib einen Namen für diese Vorlage ein."
L.LABEL_GROUP = "Gruppe"
L.DROPDOWN_NO_GROUP = "Keine Gruppe"
L.STATUS_UNGROUPED = "Ohne Gruppe"
L.DROPDOWN_CREATE_NEW_GROUP = "Neue Gruppe erstellen"
L.PLACEHOLDER_GROUP_NAME = "Gruppenname/Untergruppe1"
L.STATUS_DISABLED = "Deaktiviert"

-- Texture and Frame Settings
L.HEADER_TEXTURE_FRAME = "Textur- und Fenstereinstellungen"
L.LABEL_TEXTURE_PATH = "Texturpfad"
L.PLACEHOLDER_TEXTURE_PATH = "Gib den vollständigen Pfad ein. "
L.LABEL_TYPE = "Typ"
L.TYPE_STATIC = "Statisch"
L.TYPE_STOP_MOTION = "Stop-Motion"
L.LABEL_STRATA = "Schicht"
L.LABEL_LEVEL = "Ebene"
L.LABEL_ANCHOR_FRAME = "Anker-Fenster"
L.ANCHOR_SCREEN = "Bildschirm"
L.ANCHOR_CUSTOM_FRAME = "Benutzerdefiniertes Fenster"
L.CHECKBOX_HIDE_WITH_PARENT = "Mit Elternelement verstecken"
L.BUTTON_SELECT = "Auswählen"

-- Visual Settings
L.HEADER_VISUAL = "Visuelle Einstellungen"
L.LABEL_WIDTH = "Breite"
L.LABEL_HEIGHT = "Höhe"
L.LABEL_X = "X"
L.LABEL_Y = "Y"
L.LABEL_SCALE = "Skalierung"
L.LABEL_ANGLE = "Winkel"
L.LABEL_ALPHA = "Transparenz"
L.BUTTON_UNLOCK_POSITION = "Position entsperren"
L.BUTTON_LOCK_POSITION = "Position sperren"
-- Sound Settings
L.HEADER_SOUND_SETTINGS = "Sound-Einstellungen"
L.LABEL_SOUND = "Sound"
L.PLACEHOLDER_SOUND = "Soundpfad eingeben"
L.LABEL_SOUND_CHANNEL = "Sound-Kanal"
L.SOUND_CHANNEL_MASTER = "Master"
L.SOUND_CHANNEL_SFX = "SFX"
L.SOUND_CHANNEL_MUSIC = "Musik"
L.SOUND_CHANNEL_AMBIENCE = "Ambiente"
L.SOUND_CHANNEL_DIALOG = "Dialog"
L.SOUND_NONE = "Keine"
L.SOUND_CUSTOM = "Benutzerdefiniert"
L.BUTTON_PREVIEW_SOUND = "Sound-Vorschau"
-- Stop Motion Settings
L.LABEL_COL = "Spalte"
L.LABEL_ROW = "Zeile"
L.LABEL_FRAMES = "Bilder"
L.LABEL_FPS = "FPS"

-- Text Settings
L.HEADER_TEXT_SETTINGS = "Texteinstellungen"
L.LABEL_TEXT_CONTENT = "Text"
L.PLACEHOLDER_TEXT_CONTENT = "Text zum Anzeigen eingeben"
L.LABEL_FONT = "Schriftart"
L.LABEL_FONT_SIZE = "Schriftgröße"
L.LABEL_FONT_OUTLINE = "Umriss"
L.LABEL_TEXT_COLOR = "Textfarbe"
L.LABEL_TEXT_OFFSET_X = "Text X"
L.LABEL_TEXT_OFFSET_Y = "Text Y"
L.LABEL_TEXTURE_COLOR = "Texturfarbe"
L.OUTLINE_NONE = "Keine"
L.OUTLINE_NORMAL = "Normal"
L.OUTLINE_THICK = "Dick"
L.OUTLINE_MONOCHROME = "Monochrom"

-- Load Conditions
L.HEADER_LOADING = "Laden"
L.CHECKBOX_CAN_LOAD = "Aktiviert"
L.HEADER_ADVANCED_CONDITIONS = "Fortgeschrittene Bedingungen"

-- Character Conditions
L.HEADER_CHARACTER_CONDITIONS = "Charakterbedingungen"
L.LABEL_CLASS = "Klasse"
L.DROPDOWN_ANY_CLASS = "Alle Klassen"
L.LABEL_SPEC = "Spezialisierung"
L.DROPDOWN_ANY_SPEC = "Alle Spezialisierungen"
L.LABEL_PLAYER_NAME = "Spielername"

-- State Conditions
L.HEADER_STATE_CONDITIONS = "Zustandsbedingungen"
L.PREFIX_IN = "in "
L.PREFIX_NOT = "Nicht "
L.PREFIX_AT = "Bei "
L.CHECKBOX_ALIVE = "Lebendig"
L.CHECKBOX_COMBAT = "Kampf"
L.CHECKBOX_RESTED = "Ausgeruht"
L.CHECKBOX_INSTANCE = "Instanz"
L.CHECKBOX_ENCOUNTER = "Bosskampf"
L.CHECKBOX_PET_BATTLE = "Haustierkampf"
L.CHECKBOX_VEHICLE = "Fahrzeug"
L.CHECKBOX_HOME = "Zuhause"

-- Environment
L.HEADER_ENVIRONMENT = "Umgebung"
L.LABEL_ZONE = "Zone"
L.PLACEHOLDER_ZONE = "Zonenname"

-- Advanced Tab
L.LABEL_EVENTS = "Events (durch Komma getrennt):\nCLEU ist blockiert!"
L.PLACEHOLDER_EVENTS = "z.B. PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED"
L.LABEL_DURATION = "Dauer:"
L.PLACEHOLDER_SECONDS = "Sekunden"
L.LABEL_TRIGGER_FUNCTION = "Trigger-Funktion (return true/false):"
L.ERROR_TRIGGER_SYNTAX = "Trigger hat Fehler und kann nicht verwendet werden. Überprüfe die Syntax."

-- Import/Export
L.HEADER_IMPORT = "Vorlagen und Gruppen importieren"
L.BUTTON_ACCEPT_IMPORT = "Importieren"

-- Settings Panel - About
L.SETTINGS_HEADER_ABOUT = "Über"
L.SETTINGS_DESC_ABOUT = "Addon-Informationen"
L.SETTINGS_VERSION = "Version: "
L.SETTINGS_DESCRIPTION = "Zeige benutzerdefinierte Texturen mit bedingungsbasierten Sichtbarkeitskontrollen an."
L.BUTTON_REPORT_ISSUES = "Probleme melden"
-- Settings Panel - Contributors
L.SETTINGS_HEADER_CONTRIBUTORS = "Mitwirkende"
L.SETTINGS_DESC_CONTRIBUTORS = "Personen, die bei diesem Addon geholfen haben"
L.SETTINGS_CONTRIBUTORS_TEXT = "Vielen Dank an alle, die zu diesem Projekt beigetragen haben:"
L.SETTINGS_CONTRIBUTORS_AUTHOR = "Autor: "
L.SETTINGS_CONTRIBUTORS_TRANSLATIONS = "Übersetzungen: "
L.SETTINGS_CONTRIBUTORS_SUGGESTIONS = "Vorschläge: "
L.SETTINGS_CONTRIBUTORS_INSPIRED = "Inspiriert von: "
-- Settings Panel - Profile Management
L.SETTINGS_HEADER_PROFILES = "Profilverwaltung"
L.SETTINGS_DESC_PROFILES = "Addon-Profile verwalten"
L.SETTINGS_PROFILE_SWITCH = "Wechsle zu Profil: "
L.SETTINGS_PROFILE_ACTIVE = "Aktives Profil"
L.SETTINGS_PROFILE_SELECT_DESC = "Wähle aus, welches Profil für diesen Charakter verwendet werden soll"
L.SETTINGS_PROFILE_CREATE_LABEL = "Neues Profil erstellen:"
L.SETTINGS_BUTTON_CREATE = "Erstellen"
L.SETTINGS_PROFILE_COPY_LABEL = "Aktuelles Profil kopieren:"
L.SETTINGS_BUTTON_COPY = "Kopieren"
L.SETTINGS_PROFILE_RENAME_LABEL = "Aktuelles Profil umbenennen:"
L.SETTINGS_BUTTON_RENAME = "Umbenennen"
L.SETTINGS_BUTTON_DELETE_PROFILE = "Aktuelles Profil löschen"
L.SETTINGS_BUTTON_DELETE = "Löschen"
L.SETTINGS_BUTTON_CANCEL = "Abbrechen"
L.SETTINGS_PROFILE_INFO = "Profile ermöglichen es dir, unterschiedliche Vorlagen-Konfigurationen pro Charakter zu haben. Alle Profile sind auf allen Charakteren sichtbar, aber jeder Charakter merkt sich, welches Profil er verwendet."
L.SETTINGS_BUTTON_EXPORT_PROFILE = "Aktuelles Profil exportieren"
L.SETTINGS_EXPORT_TITLE = "Profil exportieren: "
L.SETTINGS_IMPORT_TITLE = "Profil importieren"
L.SETTINGS_PROFILE_NAME_LABEL = "Profilname (optional):"
L.MESSAGE_OLD_DB_CLEARED = "Alte WeakTexturesDB-Daten werden gelöscht. Alle Daten werden jetzt in Profilen gespeichert."
L.MESSAGE_PROFILE_LOADED = "Profil erfolgreich geladen!"
L.MESSAGE_PROFILE_CREATED = "Profil erfolgreich erstellt!"
L.MESSAGE_PROFILE_COPIED = "Profil erfolgreich kopiert!"
L.MESSAGE_PROFILE_DELETED = "Profil erfolgreich gelöscht!"

-- Settings Panel - General
L.SETTINGS_HEADER_GENERAL = "Allgemeine Einstellungen"
L.SETTINGS_DESC_GENERAL = "Grundlegende Addon-Konfiguration"
L.SETTINGS_CHECKBOX_DEBUG = "Debug-Modus aktivieren"
L.SETTINGS_DESC_DEBUG = "Zeigt Debug-Nachrichten im Chat zur Fehlerbehebung an"

-- Settings Panel - UI
L.SETTINGS_HEADER_UI = "Benutzeroberfläche"
L.SETTINGS_DESC_UI = "Addon-Oberfläche anpassen"
L.SETTINGS_UI_SCALE = "AddOn UI-Skalierung"

-- Settings Panel - Advanced
L.SETTINGS_HEADER_ADVANCED = "Fortgeschritten"
L.SETTINGS_DESC_ADVANCED = "Fortgeschrittene Addon-Funktionen"
L.SETTINGS_BUTTON_REBUILD_EVENTS = "Addon Event-Tabelle neu aufbauen"
L.SETTINGS_BUTTON_REBUILD_EVENTS_SHORT = "ADDON_EVENTS neu aufbauen"
L.SETTINGS_DESC_REBUILD_EVENTS = "ADDON_EVENTS-Optimierungstabelle manuell neu aufbauen"
L.SETTINGS_BUTTON_CLEAR_DATA = "Alle Daten löschen"
L.SETTINGS_BUTTON_CLEAR_PRESETS = "Alle Vorlagen löschen"
L.SETTINGS_CONFIRM_CLEAR_ALL = "Dadurch werden ALLE Vorlagen und Gruppen gelöscht. Diese Aktion kann nicht rückgängig gemacht werden! Bist du sicher, dass du fortfahren möchtest?"
L.SETTINGS_BUTTON_DELETE_EVERYTHING = "Alles löschen"
L.SETTINGS_WARNING_DELETE_ALL = "WARNUNG: Löscht alle Vorlagen und Gruppen dauerhaft"
L.SETTINGS_BUTTON_RELOAD = "Interface neu laden"
L.SETTINGS_BUTTON_RELOAD_UI = "UI neu laden"
L.SETTINGS_DESC_RELOAD = "Lade die Benutzeroberfläche neu, um Änderungen anzuwenden"

-- Settings Panel - Language
L.SETTINGS_HEADER_LANGUAGE = "Sprache"
L.SETTINGS_DESC_LANGUAGE = "Sprach- und Lokalisierungseinstellungen"
L.SETTINGS_LANGUAGE_LABEL = "Sprache"
L.SETTINGS_LANGUAGE_SELECT_DESC = "Wähle deine bevorzugte Sprache. Erfordert ein UI-Neuladen, um wirksam zu werden."
L.SETTINGS_LANGUAGE_AUTO_DETECT = " erkennt automatisch die Sprache deines Spielclients."
L.SETTINGS_LANGUAGE_SUPPORTED = "Derzeit unterstützte Sprachen:"
L.SETTINGS_LANGUAGE_EN = "• Englisch (enUS)"
L.SETTINGS_LANGUAGE_DE = "• Deutsch (deDE)"

-- Settings Panel - Textures
L.SETTINGS_HEADER_TEXTURES = "Texturen"
L.SETTINGS_DESC_TEXTURES = "Texturverwaltungseinstellungen"
L.SETTINGS_CHECKBOX_AUTO_REGISTER = "Benutzerdefinierte Texturen automatisch registrieren"
L.SETTINGS_DESC_AUTO_REGISTER = "Registriere automatisch benutzerdefinierte Texturpfade bei LibSharedMedia, damit sie von anderen Addons verwendet werden können"
L.SETTINGS_BUTTON_GENERATE_EXAMPLES = "Beispielvorlagen generieren"
L.SETTINGS_BUTTON_CREATE_EXAMPLES = "Beispiele erstellen"
L.SETTINGS_DESC_GENERATE_EXAMPLES = "Erstelle Beispielvorlagen, um dir den Einstieg zu erleichtern."

-- Settings Panel - Font
L.SETTINGS_HEADER_FONT = "Schriftart"
L.SETTINGS_DESC_FONT = "Schriftart- und Erscheinungsbildeinstellungen"
L.SETTINGS_FONT_LABEL = "Schriftart"
L.SETTINGS_DESC_FONT_SELECT = "Wähle die Schriftart aus, die in der gesamten Addon-Oberfläche verwendet werden soll."
L.SETTINGS_BOLD_FONT = "Fettschrift"
L.SETTINGS_DESC_BOLD_FONT = "Wähle die fette Schriftvariante für Überschriften und großen Text aus."

-- Dynamic/Template Texts
L.ERROR_EVENT_NOT_ALLOWED = "Event '%s' darf nicht verwendet werden."
L.PLACEHOLDER_TRIGGER_CODE = "--e.g.  function(e) if InCombatLockdown() then return true end end"
L.MESSAGE_MIGRATED_TO_PROFILE = "Vorhandene Daten wurden zum 'Standard'-Profil migriert."
L.CONFIRM_DELETE_PROFILE = "Profil '%s' löschen? Dies kann nicht rückgängig gemacht werden!"
L.SETTINGS_DESC_UI_SCALE = "Passe die Größe des %s-Hauptfensters an"
