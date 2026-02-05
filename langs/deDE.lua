-- =====================================================
-- WeakTextures German (DE) Localization
-- =====================================================
-- This file populates German translations

local _, wt = ...
local L = wt.locales.deDE

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

-- Stop Motion Settings
L.LABEL_COL = "Spalte"
L.LABEL_ROW = "Zeile"
L.LABEL_FRAMES = "Bilder"
L.LABEL_FPS = "FPS"

-- Load Conditions
L.HEADER_LOADING = "Laden"
L.CHECKBOX_CAN_LOAD = "Kann laden?"
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
L.CHECKBOX_ADVANCED = "Erweitert"

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

-- Filter Panel
L.FILTER_ALL = "Alle"

-- Minimap Icon Tooltip
L.MINIMAP_VERSION = "Version: "
L.MINIMAP_LEFTCLICK = "Linksklick: Öffne "
L.MINIMAP_RIGHTCLICK = "Rechtsklick: Öffne Einstellungen"

-- Dynamic/Template Texts
L.ERROR_EVENT_NOT_ALLOWED = "Event '%s' darf nicht verwendet werden."
L.MESSAGE_MIGRATED_TO_PROFILE = "Vorhandene Daten wurden zum 'Standard'-Profil migriert."
L.CONFIRM_DELETE_PROFILE = "Profil '%s' löschen? Dies kann nicht rückgängig gemacht werden!"
L.SETTINGS_DESC_UI_SCALE = "Passe die Größe des %s-Hauptfensters an"

-- Multi-Instance System (v2)
L.HEADER_TEXT_OVERLAY = "Text-Overlay"
L.TEXT_ENABLED = "Text-Overlay aktivieren"
L.TEXT_CONTENT = "Textinhalt"
L.TEXT_FONT = "Schriftart"
L.TEXT_SIZE = "Schriftgröße"
L.TEXT_COLOR = "Textfarbe"
L.TEXT_OFFSET_X = "X-Versatz"
L.TEXT_OFFSET_Y = "Y-Versatz"
L.TEXT_OUTLINE = "Textumriss"
L.TEXT_OUTLINE_NONE = "Keine"
L.TEXT_OUTLINE_THIN = "Dünn"
L.TEXT_OUTLINE_THICK = "Dick"

L.HEADER_SOUNDS = "Sounds"
L.SOUND_ADD = "Sound hinzufügen"
L.SOUND_REMOVE = "Entfernen"
L.SOUND_KEY = "Sound-Schlüssel"
L.SOUND_PATH = "Dateipfad"
L.SOUND_ENABLED = "Aktiviert"
L.SOUND_TEST = "Testen"
L.SOUND_RANDOM = "Zufällig abspielen"

L.HEADER_INSTANCES = "Multi-Instanz-Einstellungen"
L.INSTANCE_ENABLED = "Multi-Instanz-Modus aktivieren"
L.INSTANCE_MAX = "Max. Instanzen"
L.INSTANCE_DESC = "Der Multi-Instanz-Modus ermöglicht das gleichzeitige Spawnen mehrerer Kopien dieser Vorlage. Verwende CreateInstance(data) in Triggern, um Instanzen zu spawnen."
L.INSTANCE_WARNING = "Hinweis: Der Multi-Instanz-Modus erfordert Trigger-Code zum Aufruf von CreateInstance(). Vorlagen werden nicht automatisch angezeigt, wenn Bedingungen erfüllt sind."
