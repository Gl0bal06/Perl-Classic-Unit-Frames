--if (GetLocale() == "enUS") then	-- Bypassing this allows us to at least give other languages English since they aren't fully translated
	-- Buttons and Titles
	PERL_LOCALIZED_CONFIG_ALL = "All";
	PERL_LOCALIZED_CONFIG_ARCANEBAR = "ArcaneBar";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY = "CombatDisplay";
	PERL_LOCALIZED_CONFIG_FOCUS = "Focus";
	PERL_LOCALIZED_CONFIG_FOCUSTARGET = "Focus Target";
	PERL_LOCALIZED_CONFIG_FOCUSPARTYTARGET = "Focus/Party Target";
	PERL_LOCALIZED_CONFIG_PARTY = "Party";
	PERL_LOCALIZED_CONFIG_PARTYPET = "Party Pet";
	PERL_LOCALIZED_CONFIG_PARTYTARGET = "Party Target";
	PERL_LOCALIZED_CONFIG_PLAYER = "Player";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF = "Player Buff";
	PERL_LOCALIZED_CONFIG_PLAYERPET = "Player Pet";
	PERL_LOCALIZED_CONFIG_TARGET = "Target";
	PERL_LOCALIZED_CONFIG_TARGETTARGET = "Target Target";

	-- Perl Config Shared Strings
	PERL_LOCALIZED_CONFIG_TRANSPARENCY = "Transparency";
	PERL_LOCALIZED_CONFIG_SCALING = "Scaling";
	PERL_LOCALIZED_CONFIG_SCALING_SET_CURRENT = "Set To Current UI Scale";
	PERL_LOCALIZED_CONFIG_MISC = "Misc";
	PERL_LOCALIZED_CONFIG_DISPLAY_MODE = "Display Mode";
	PERL_LOCALIZED_CONFIG_DRUIDBAR = "Druid Bar Support";
	PERL_LOCALIZED_CONFIG_RESET_FRAMES = "Reset Frame Positions";
	PERL_LOCALIZED_CONFIG_PORTRAITS = "Display Portrait Frames";
	PERL_LOCALIZED_CONFIG_THREED_PORTRAITS = "3D Portrait Frames";
	PERL_LOCALIZED_CONFIG_ALWAYS_SHOWN = "Always Shown";
	PERL_LOCALIZED_CONFIG_HIDDEN_IN_RAID = "Hidden In Raids";
	PERL_LOCALIZED_CONFIG_ALWAYS_HIDDEN = "Always Hidden";
	PERL_LOCALIZED_CONFIG_BUFF_LOCATION = "Buff Location";
	PERL_LOCALIZED_CONFIG_DEBUFF_LOCATION = "Debuff Location";
	PERL_LOCALIZED_CONFIG_BUFF_SIZE_SMALL = "Buff Size (12 is default)";
	PERL_LOCALIZED_CONFIG_DEBUFF_SIZE_SMALL = "Debuff Size (12 is default)";
	PERL_LOCALIZED_CONFIG_BUFF_SIZE_LARGE = "Buff Size (16 is default)";
	PERL_LOCALIZED_CONFIG_DEBUFF_SIZE_LARGE = "Debuff Size (16 is default)";
	PERL_LOCALIZED_CONFIG_BUFF_NUMBER = "# of Buffs";
	PERL_LOCALIZED_CONFIG_DEBUFF_NUMBER = "# of Debuffs";
	PERL_LOCALIZED_CONFIG_COMBAT_TEXT = "Combat Text";
	PERL_LOCALIZED_CONFIG_COMPACT = "Compact Mode";
	PERL_LOCALIZED_CONFIG_DISPLAY_PERCENTS = "Display Percents";
	PERL_LOCALIZED_CONFIG_SHORT_BARS = "Short Bars";
	PERL_LOCALIZED_CONFIG_VERTICAL_FRAMES = "Vertical Frames";
	PERL_LOCALIZED_CONFIG_HIDE_CLASSICON_FRAME = "Hide Class Icon Frame";
	PERL_LOCALIZED_CONFIG_HEALER_MODE = "Healer Mode";
	PERL_LOCALIZED_CONFIG_PET_SUPPORT = "Display Pet Bars";
	PERL_LOCALIZED_CONFIG_CLASS_COLORED_NAMES = "Class Colored Names";
	PERL_LOCALIZED_CONFIG_SMALL = "Small";
	PERL_LOCALIZED_CONFIG_BIG = "Big";
	PERL_LOCALIZED_CONFIG_HIDE_POWER_BARS = "Hide Power Bars";
	PERL_LOCALIZED_CONFIG_DISPLAY_MANA_DEFICIT = "Display Mana Deficit"
	PERL_LOCALIZED_CONFIG_PVP_STATUS_ICON = "PvP Status Icon";
	PERL_LOCALIZED_CONFIG_SHOW_BAR_VALUES = "Show Bar Values";
	PERL_LOCALIZED_CONFIG_INVERT_BAR_VALUES = "Invert Bar Values";
	PERL_LOCALIZED_CONFIG_COLOR_FRAME_DEBUFF = "Color Frame By Debuff";
	PERL_LOCALIZED_CONFIG_CLASS_BUFF = "Class Buffs Only";
	PERL_LOCALIZED_CONFIG_CLASS_DEBUFF = "Curable Debuffs Only";
	PERL_LOCALIZED_CONFIG_ALIGN_HORIZONTALLY = "Align Horizontally";
	PERL_LOCALIZED_CONFIG_THREAT_ICONS = "Threat Icons";
	PERL_LOCALIZED_CONFIG_MY_DEBUFFS = "Only My Debuffs"

	-- Perl Config Generic
	PERL_LOCALIZED_CONFIG_HEADER = "Perl Config";
	PERL_LOCALIZED_CONFIG_CLOSE = "Close";
	PERL_LOCALIZED_CONFIG_NOTINSTALLED = "Not Installed";
	PERL_LOCALIZED_CONFIG_NOTINSTALLED_EXPLANATION = "The requested mod is not installed or enabled.";

	-- Perl Config All
	PERL_LOCALIZED_CONFIG_ALL_TEXTURED_BARS = "Textured Bars";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_ONE = "Texture #1";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_TWO = "Texture #2";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_THREE = "Texture #3";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_FOUR = "Texture #4";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_FIVE = "Texture #5";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_SIX = "Texture #6";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURE_NONE = "No Texture";
	PERL_LOCALIZED_CONFIG_ALL_MINIMAP_POSITION = "MiniMap Button Position";
	PERL_LOCALIZED_CONFIG_ALL_SHOW_MINIMAP = "Show MiniMap Button";
	PERL_LOCALIZED_CONFIG_ALL_FRAMES = "Frames";
	PERL_LOCALIZED_CONFIG_ALL_TRANSPARENT_BACKGROUND = "Transparent Frame Background";
	PERL_LOCALIZED_CONFIG_ALL_LOCK_ALL = "Lock All Frames";
	PERL_LOCALIZED_CONFIG_ALL_UNLOCK_ALL = "Unlock All Frames";
	PERL_LOCALIZED_CONFIG_ALL_LOAD = "Load Global Settings";
	PERL_LOCALIZED_CONFIG_ALL_SAVE = "Save Global Settings";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": Global Settings Loaded.";
	PERL_LOCALIZED_CONFIG_ALL_SAVE_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": Global Settings Saved.";
	PERL_LOCALIZED_CONFIG_ALL_RESET_FRAMES_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": Frame Positions have been reset.";
	PERL_LOCALIZED_CONFIG_ALL_CLICKHEALING = "CastParty/Genesis/AceHeal/ClickHeal Support";
	PERL_LOCALIZED_CONFIG_ALL_PROGRESSIVE = "Progressively Colored Health Bars";
	PERL_LOCALIZED_CONFIG_ALL_NO_PROFILE_SELECTED_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": No profile was selected.";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": Profile Settings Loaded: ";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_HEADER = "Profile To Load";
	PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_BUTTON = "Load";
	PERL_LOCALIZED_CONFIG_ALL_DELETE_PROFILE_BUTTON = "Delete";
	PERL_LOCALIZED_CONFIG_ALL_DELETE_PROFILE_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": The following profile has been removed from the list: ";
	PERL_LOCALIZED_CONFIG_ALL_TEXTURED_BACKGROUND = "Textured Background Bar";
	PERL_LOCALIZED_CONFIG_ALL_FADE_BARS = "Fade Status Bars";
	PERL_LOCALIZED_CONFIG_ALL_CLICKCASTABLE_NAME_FRAMES = "Make Name Frames Click Castable";
	PERL_LOCALIZED_CONFIG_ALL_MINIMAP_RADIUS = "MiniMap Button Radius";
	PERL_LOCALIZED_CONFIG_ALL_POSITIONING_MODE = "Positioning Mode";
	PERL_LOCALIZED_CONFIG_ALL_POSITIONING_MODE_TOOLTIP = "This option is for *positioning frames only*!\nText 'errors' are normal and do not need to be reported.\nThis option works best if you have no target so the titles of the frames don't change.";

	-- Perl Config ArcaneBar
	PERL_LOCALIZED_CONFIG_ARCANEBAR_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_ARCANEBAR;
	PERL_LOCALIZED_CONFIG_ARCANEBAR_DISPLAY_TIMER = "Display Cast Timer";
	PERL_LOCALIZED_CONFIG_ARCANEBAR_HIDE_BLIZZARD = "Hide the Blizzard Casting Bar";
	PERL_LOCALIZED_CONFIG_ARCANEBAR_REPLACE_NAME = "Replace Player Name With Spell Name";
	PERL_LOCALIZED_CONFIG_ARCANEBAR_LEFT_TIMER = "Left Align Cast Timer";

	-- Perl Config CombatDisplay
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_PERSIST_MODES = "Persist Modes";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_TARGET_SETTINGS = "Target Settings";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_AUTOATTACK = "w/ Auto Attack";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_ONAGRO = "On Agro";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_HEALTH_PERSIST = "Health Persistence";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_MANA_PERSIST = "Mana Persistence";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_MENU = "Menu on Right Click";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_COMBATDISPLAY.." Frames";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_ENABLE_TARGET = "Enable Target Frame";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_DISPLAY_COMBOPOINT_BAR = "Display Combo Point Bar";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_CLICK_THROUGH = "Click Through Frames";

	-- Perl Config Party
	PERL_LOCALIZED_CONFIG_PARTY_SPACING = "Spacing (95 is default)";
	PERL_LOCALIZED_CONFIG_PARTY_FKEYS = "Display F Keys";
	PERL_LOCALIZED_CONFIG_PARTY_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PARTY.." Frame";
	PERL_LOCALIZED_CONFIG_PARTY_PORTRAITBUFFS = "Align Buffs To Portraits";

	-- Perl Config Party Pet
	PERL_LOCALIZED_CONFIG_PARTYPET_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_PARTYPET.." Frames";
	PERL_LOCALIZED_CONFIG_PARTYPET_RESET_FRAMES_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": "..PERL_LOCALIZED_CONFIG_PARTYPET.." Frame Positions have been reset.";
	PERL_LOCALIZED_CONFIG_PARTYPET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PARTYPET.." Frames";

	-- Perl Config Party Target
	PERL_LOCALIZED_CONFIG_PARTYTARGET_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_PARTYTARGET.." Frames";
	PERL_LOCALIZED_CONFIG_FOCUSTARGET_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_FOCUSTARGET.." Frame";
	PERL_LOCALIZED_CONFIG_PARTYTARGET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_FOCUSPARTYTARGET.." Frames";
	PERL_LOCALIZED_CONFIG_PARTYTARGET_PARTY_HIDDEN_IN_RAID = PERL_LOCALIZED_CONFIG_PARTYTARGET.." "..PERL_LOCALIZED_CONFIG_HIDDEN_IN_RAID;
	PERL_LOCALIZED_CONFIG_PARTYTARGET_FOCUS_HIDDEN_IN_RAID = PERL_LOCALIZED_CONFIG_FOCUSTARGET.." "..PERL_LOCALIZED_CONFIG_HIDDEN_IN_RAID;
	PERL_LOCALIZED_CONFIG_PARTYTARGET_SCALE = PERL_LOCALIZED_CONFIG_PARTY.." "..PERL_LOCALIZED_CONFIG_TARGET.." "..PERL_LOCALIZED_CONFIG_SCALING;
	PERL_LOCALIZED_CONFIG_FOCUSTARGET_SCALE = PERL_LOCALIZED_CONFIG_FOCUS.." "..PERL_LOCALIZED_CONFIG_TARGET.." "..PERL_LOCALIZED_CONFIG_SCALING;

	-- Perl Config Player
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_MODE = "Experience Bar Mode";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_EXPERIENCE = "Experience";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_PVPRANK = "PvP Rank";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_REPUTATION = "Reputation";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_HIDDEN = "Hidden";
	PERL_LOCALIZED_CONFIG_PLAYER_RAID_GROUP = "Show Raid Group Number";
	PERL_LOCALIZED_CONFIG_PLAYER_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PLAYER.." Frame";
	PERL_LOCALIZED_CONFIG_PLAYER_RAID_GROUP_IN_NAME = "Show Raid Group Number In Name Frame";
	PERL_LOCALIZED_CONFIG_PLAYER_FIVE_SECOND_RULE = "Five Second Rule";
	PERL_LOCALIZED_CONFIG_PLAYER_PVP_TIMER = "PvP Timer";
	PERL_LOCALIZED_CONFIG_PLAYER_CLASS_RESOURCE_FRAME = "Class Resource Frame";

	-- Perl Config Player Buff
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_ENABLE = "Enable Player Frame Buffs";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_WARNING = "Enable 30 Second Spell Warning Messages";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_HIDESECONDS = "Hide Seconds";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_HORIZONTAL_SPACING = "Horizontal Spacing (10 is default)";

	-- Perl Config Player Pet
	PERL_LOCALIZED_CONFIG_PLAYERPET_EXPERIENCE = "Enable Experience Bar";
	PERL_LOCALIZED_CONFIG_PLAYERPET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PLAYERPET.." Frame";
	PERL_LOCALIZED_CONFIG_PLAYERPET_HIDENAME = "Hide Name";
	PERL_LOCALIZED_CONFIG_PLAYERPET_TARGET = "Pet Target";
	PERL_LOCALIZED_CONFIG_PLAYERPET_TARGET_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_PLAYERPET_TARGET;
	PERL_LOCALIZED_CONFIG_PLAYERPET_SCALE = PERL_LOCALIZED_CONFIG_PLAYERPET.." "..PERL_LOCALIZED_CONFIG_SCALING;
	PERL_LOCALIZED_CONFIG_PLAYERPET_TARGET_SCALE = PERL_LOCALIZED_CONFIG_PLAYERPET.." "..PERL_LOCALIZED_CONFIG_TARGET.." "..PERL_LOCALIZED_CONFIG_SCALING;

	-- Perl Config Target
	PERL_LOCALIZED_CONFIG_TARGET_BUFFDEBUFF_SCALING = "Buff/Debuff Scaling (100 is default)";
	PERL_LOCALIZED_CONFIG_TARGET_COMBO_LOCATION = "Combo Location";
	PERL_LOCALIZED_CONFIG_TARGET_CLASS_ICON = "Class Icon";
	PERL_LOCALIZED_CONFIG_TARGET_CLASS_FRAME = "Class Frame";
	PERL_LOCALIZED_CONFIG_TARGET_RARE_ELITE_FRAME = "Rare/Elite Frame";
	PERL_LOCALIZED_CONFIG_TARGET_HIDE_BUFFDEBUFF_BACKGROUND = "Hide Buff/Debuff Background";
	PERL_LOCALIZED_CONFIG_TARGET_SOUND_ON_TARGET_CHANGE = "Sound on Target Change";
	PERL_LOCALIZED_CONFIG_TARGET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_TARGET.." Frame";
	PERL_LOCALIZED_CONFIG_TARGET_COMBO_POINT_FRAME = "Combo Point Frame";
	PERL_LOCALIZED_CONFIG_TARGET_DISPLAY_IN_NAME_FRAME = "Display in Name Frame";
	PERL_LOCALIZED_CONFIG_TARGET_DEBUFF_STACKS_IN_COMBO_FRAME = "Debuff Stacks in Combo Frame";
	PERL_LOCALIZED_CONFIG_TARGET_ALTERNATE_FRAME_STYLE = "Alternate Frame Style";
	PERL_LOCALIZED_CONFIG_TARGET_INVERT_BUFFS_DEBUFFS = "Invert Buffs/Debuffs";
	PERL_LOCALIZED_CONFIG_TARGET_GUILD_FRAME = "Guild Name Frame";
	PERL_LOCALIZED_CONFIG_TARGET_ELITE_RARE_GRAPHIC = "Rare/Elite Graphic";
	PERL_LOCALIZED_CONFIG_TARGET_BUFF_DEBUFF_TIMERS = "Buff/Debuff Timers";
	PERL_LOCALIZED_CONFIG_TARGET_DISPLAY_NUMERIC_THREAT = "Display Numeric Threat";
	PERL_LOCALIZED_CONFIG_TARGET_DISPLAY_NUMERIC_THREAT_TOOLTIP = "If this option is enabled, the '"..PERL_LOCALIZED_CONFIG_TARGET_RARE_ELITE_FRAME.."' option will not function.";

	-- Perl Config Target Target
	PERL_LOCALIZED_CONFIG_TARGETTARGET_MAIN = "Main";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ALERT_MODE = "Alert Mode";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ALERT_SIZE = "Alert Size";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ENABLE_TOT = "Enable Target of Target";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_ENABLE_TOTOT = "Enable Target of Target of Target";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_AUDIO_ALERT_ON_AGRO = "Audio Alert on Agro";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_TARGETTARGET.." Frames";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOT_BUFFS = "Show ToT Buffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOT_DEBUFFS = "Show ToT Debuffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOTOT_BUFFS = "Show ToToT Buffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_TOTOT_DEBUFFS = "Show ToToT Debuffs";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_DPS_MODE = "DPS Mode";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_TANK_MODE = "Tank Mode";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_HEALER_MODE = "Healer Mode";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SMALL_TEXT = "Small Text";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_LARGE_TEXT = "Large Text";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_NO_TEXT = "No Text";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_RIGHT_OF_TARGET_FRAME = "Right of Target Frame";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_TOP_OF_TARGET_FRAME = "Top of Target Frame";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_RIGHT_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": Target of Target frames have been 'Right Aligned'.";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_TOP_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": Target of Target frames have been 'Top Aligned'.";
	PERL_LOCALIZED_CONFIG_TARGETTARGET_SHOW_FRIENDLY_HEALTH = "Show Friendly Health Values";
--end
