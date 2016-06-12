--if (GetLocale() == "enUS") then	-- Bypassing this allows us to at least give other languages English since they aren't fully translated
	-- Generic Globals that do NOT need localizing
	PERL_LOCALIZED_VERSION_NUMBER = "0.80";
	PERL_LOCALIZED_DATE = "September 22, 2006";
	PERL_LOCALIZED_BUFF_NONE = "none";

	-- Title and Version
	PERL_LOCALIZED_NAME = "Perl Classic Unit Frames";
	PERL_LOCALIZED_VERSION = "Version "..PERL_LOCALIZED_VERSION_NUMBER;

	-- Class Names
	PERL_LOCALIZED_DRUID = "Druid";
	PERL_LOCALIZED_HUNTER = "Hunter";
	PERL_LOCALIZED_MAGE = "Mage";
	PERL_LOCALIZED_PALADIN = "Paladin";
	PERL_LOCALIZED_PRIEST = "Priest";
	PERL_LOCALIZED_ROGUE = "Rogue";
	PERL_LOCALIZED_SHAMAN = "Shaman";
	PERL_LOCALIZED_WARLOCK = "Warlock";
	PERL_LOCALIZED_WARRIOR = "Warrior";

	-- Creature Types
	PERL_LOCALIZED_CIVILIAN = "Civilian";
	PERL_LOCALIZED_CREATURE = "Creature";
	PERL_LOCALIZED_NOTSPECIFIED = "Not specified";

	-- Debuff Types
	PERL_LOCALIZED_BUFF_CURSE = "Curse";
	PERL_LOCALIZED_BUFF_DISEASE = "Disease";
	PERL_LOCALIZED_BUFF_MAGIC = "Magic";
	PERL_LOCALIZED_BUFF_POISON = "Poison";

	-- Status Types
	PERL_LOCALIZED_STATUS_DEAD = "Dead";
	PERL_LOCALIZED_STATUS_FEIGNDEATH = "Feign Death";
	PERL_LOCALIZED_STATUS_OFFLINE = "Offline";
	PERL_LOCALIZED_STATUS_RESURRECTED = "Resurrected";
	PERL_LOCALIZED_STATUS_SS_AVAILABLE = "SS Available";

	-- Perl ArcaneBar Strings
	PERL_LOCALIZED_ARCANEBAR_CHANNELING = "Channeling";

	-- Perl Player Strings
	PERL_LOCALIZED_PLAYER_GROUP = "Group ";
	PERL_LOCALIZED_PLAYER_LEVEL_SEVENTY = "Level 70";
	PERL_LOCALIZED_PLAYER_NOMORE_EXPERIENCE = "You can't gain anymore experience!";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_ONE = "Hated";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_TWO = "Hostile";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_THREE = "Unfriendly";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_FOUR = "Neutral";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_FIVE = "Friendly";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_SIX = "Honored";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_SEVEN = "Revered";
	PERL_LOCALIZED_PLAYER_REACTIONNAME_EIGHT = "Exalted";
	PERL_LOCALIZED_PLAYER_NO_REPUTATION = "There is no reputation being tracked.";
	PERL_LOCALIZED_PLAYER_SELECT_REPUTATION = "Select a Reputation";
	PERL_LOCALIZED_PLAYER_UNRANKED = "You are Unranked.";

	-- Perl Target Strings
	PERL_LOCALIZED_TARGET_BOSS = "Boss";
	PERL_LOCALIZED_TARGET_ELITE = "Elite";
	PERL_LOCALIZED_TARGET_RARE = "Rare";
	PERL_LOCALIZED_TARGET_RAREELITE = "Rare+";
	PERL_LOCALIZED_TARGET_FIRE_VULNERABILITY = "Fire Vulnerability";
	PERL_LOCALIZED_TARGET_SHADOW_VULNERABILITY = "Shadow Vulnerability";
	PERL_LOCALIZED_TARGET_SUNDER_ARMOR = "Sunder Armor";

	-- Perl Target Target Strings
	PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU = " has changed targets to you!";

	-- Buttons and Titles
	PERL_LOCALIZED_CONFIG_ALL = "All";
	PERL_LOCALIZED_CONFIG_ARCANEBAR = "ArcaneBar";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY = "CombatDisplay";
	PERL_LOCALIZED_CONFIG_PARTY = "Party";
	PERL_LOCALIZED_CONFIG_PARTYPET = "Party Pet";
	PERL_LOCALIZED_CONFIG_PARTYTARGET = "Party Target";
	PERL_LOCALIZED_CONFIG_PLAYER = "Player";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF = "Player Buff";
	PERL_LOCALIZED_CONFIG_PLAYERPET = "Player Pet";
	PERL_LOCALIZED_CONFIG_RAID = "Raid";
	PERL_LOCALIZED_CONFIG_TARGET = "Target";
	PERL_LOCALIZED_CONFIG_TARGETTARGET = "Target Target";

	-- Perl Config Key Binging Strings
	BINDING_HEADER_PERLCONFIG = PERL_LOCALIZED_NAME;
	BINDING_NAME_TOGGLEOPTIONS = "Toggle Options Menu";

	-- Perl Raid Key Binging Strings
	BINDING_HEADER_PERLRAID = "Perl "..PERL_LOCALIZED_CONFIG_RAID;
	BINDING_NAME_SHOWHIDE = "Show/Hide Raid Frames";
	BINDING_NAME_TOGGLECLASS = "Toggle Group/Class Sorting";

	-- Perl Config Shared Strings
	PERL_LOCALIZED_CONFIG_TRANSPARENCY = "Transparency";
	PERL_LOCALIZED_CONFIG_SCALING = "Scaling";
	PERL_LOCALIZED_CONFIG_SCALING_SET_CURRENT = "Set To Current UI Scale";
	PERL_LOCALIZED_CONFIG_MISC = "Misc";
	PERL_LOCALIZED_CONFIG_DISPLAY_MODE = "Display Mode";
	PERL_LOCALIZED_CONFIG_DRUIDBAR = "Druid Bar Support";
	PERL_LOCALIZED_CONFIG_MOBHEALTH = "MobHealth Support";
	PERL_LOCALIZED_CONFIG_FIVESEC = "FiveSec Support";
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
	PERL_LOCALIZED_CONFIG_CLASS_BUFFDEBUFF = "Class Buffs/Debuffs";
	PERL_LOCALIZED_CONFIG_CLASS_COLORED_NAMES = "Class Colored Names";
	PERL_LOCALIZED_CONFIG_PVP_RANK_ICON = "PvP Rank Icon";
	PERL_LOCALIZED_CONFIG_SMALL = "Small";
	PERL_LOCALIZED_CONFIG_BIG = "Big";
	PERL_LOCALIZED_CONFIG_HIDE_POWER_BARS = "Hide Power Bars";
	PERL_LOCALIZED_CONFIG_DISPLAY_MANA_DEFICIT = "Display Mana Deficit"
	PERL_LOCALIZED_CONFIG_PVP_STATUS_ICON = "PvP Status Icon";
	PERL_LOCALIZED_CONFIG_SHOW_BAR_VALUES = "Show Bar Values";
	PERL_LOCALIZED_CONFIG_INVERT_BAR_VALUES = "Invert Bar Values";

	-- Perl Config Generic
	PERL_LOCALIZED_CONFIG_HEADER = "Perl Config";
	PERL_LOCALIZED_CONFIG_CLOSE = "Close";
	PERL_LOCALIZED_CONFIG_NOTINSTALLED = "Not Installed";
	PERL_LOCALIZED_CONFIG_NOTINSTALLED_EXPLANATION = "The requested mod is not installed or enabled.";
	PERL_LOCALIZED_CONFIG_MINIMAP_LOCK = "Right clicking will LOCK all frames";
	PERL_LOCALIZED_CONFIG_MINIMAP_UNLOCK = "Right clicking will UNLOCK all frames";
	PERL_LOCALIZED_CONFIG_THIRDPARTY = "Third Party";

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
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_HEALTH_PERSIST = "Health Persistance";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_MANA_PERSIST = "Mana Persistance";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_MENU = "Menu on Right Click";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_COMBATDISPLAY.." Frames";
	PERL_LOCALIZED_CONFIG_COMBATDISPLAY_ENABLE_TARGET = "Enable Target Frame";

	-- Perl Config Party
	PERL_LOCALIZED_CONFIG_PARTY_SPACING = "Spacing (80 is default)";
	PERL_LOCALIZED_CONFIG_PARTY_FKEYS = "Display F Keys";
	PERL_LOCALIZED_CONFIG_PARTY_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PARTY.." Frame";

	-- Perl Config Party Pet
	PERL_LOCALIZED_CONFIG_PARTYPET_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_PARTYPET.." Frames";
	PERL_LOCALIZED_CONFIG_PARTYPET_RESET_FRAMES_OUTPUT = "|cffffff00"..PERL_LOCALIZED_NAME..": "..PERL_LOCALIZED_CONFIG_PARTYPET.." Frame Positions have been reset.";
	PERL_LOCALIZED_CONFIG_PARTYPET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PARTYPET.." Frames";

	-- Perl Config Party Target
	PERL_LOCALIZED_CONFIG_PARTYTARGET_ENABLE = "Enable "..PERL_LOCALIZED_CONFIG_PARTYTARGET.." Frames";
	PERL_LOCALIZED_CONFIG_PARTYTARGET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PARTYTARGET.." Frames";

	-- Perl Config Player
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_MODE = "Experience Bar Mode";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_EXPERIENCE = "Experience";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_PVPRANK = "PvP Rank";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_REPUTATION = "Reputation";
	PERL_LOCALIZED_CONFIG_PLAYER_XPBAR_HIDDEN = "Hidden";
	PERL_LOCALIZED_CONFIG_PLAYER_RAID_GROUP = "Show Raid Group Number";
	PERL_LOCALIZED_CONFIG_PLAYER_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PLAYER.." Frame";

	-- Perl Config Player Buff
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_ENABLE = "Enable Player Frame Buffs";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_WARNING = "Enable 30 Second Spell Warning Messages";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_HIDESECONDS = "Hide Seconds";
	PERL_LOCALIZED_CONFIG_PLAYERBUFF_HORIZONTAL_SPACING = "Horizontal Spacing (10 is default)";

	-- Perl Config Player Pet
	PERL_LOCALIZED_CONFIG_PLAYERPET_EXPERIENCE = "Enable Experience Bar";
	PERL_LOCALIZED_CONFIG_PLAYERPET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_PLAYERPET.." Frame";

	-- Perl Config Raid
	PERL_LOCALIZED_CONFIG_RAID_GROUP_SETTINGS = "Group Settings";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_ONE = "Show Group 1 (Warrior)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_TWO = "Show Group 2 (Mage)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_THREE = "Show Group 3 (Priest)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_FOUR = "Show Group 4 (Warlock)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_FIVE = "Show Group 5 (Druid)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_SIX = "Show Group 6 (Rogue)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_SEVEN = "Show Group 7 (Hunter)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_EIGHT = "Show Group 8 (Paladin)";
	PERL_LOCALIZED_CONFIG_RAID_GROUP_NINE = "Show Group 9 (Shaman)";
	PERL_LOCALIZED_CONFIG_RAID_SORT_BY_CLASS = "Sort By Class";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_GROUP_HEADERS = "Show Group Headers";
	PERL_LOCALIZED_CONFIG_RAID_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_RAID.." Frames";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_ALL = "Show All Groups";
	PERL_LOCALIZED_CONFIG_RAID_HIDE_ALL = "Hide All Groups";
	PERL_LOCALIZED_CONFIG_RAID_CONNECT_FRAMES = "Connect Frames";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_HEALTH_PERCENTAGES = "Show Health Percentages";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_MANA_PERCENTAGES = "Show Mana Percentages";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_MISSING_HEALTH = "Show Missing Health";
	PERL_LOCALIZED_CONFIG_RAID_INVERT_FRAMES = "Invert Frames";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_BUFFS = "Show Buffs";
	PERL_LOCALIZED_CONFIG_RAID_SHOW_DEBUFFS = "Show Debuffs";
	PERL_LOCALIZED_CONFIG_RAID_COLOR_DEBUFF_NAMES = "Color Debuff Names";
	PERL_LOCALIZED_CONFIG_RAID_ALTERNATE_FRAME_STYLE = "Alternate Frame Style";
	PERL_LOCALIZED_CONFIG_RAID_HIDE_BORDER = "Hide Border";
	PERL_LOCALIZED_CONFIG_RAID_REMOVE_SPACE = "Remove Space";
	PERL_LOCALIZED_CONFIG_RAID_TOOLTIP = "CTRA Style Tooltip";
	PERL_LOCALIZED_CONFIG_RAID_HIDE_EMPTY_HEADERS = "Hide Empty Group Headers";

	-- Perl Config Target
	PERL_LOCALIZED_CONFIG_TARGET_BUFFDEBUFF_SCALING = "Buff/Debuff Scaling (100 is default)";
	PERL_LOCALIZED_CONFIG_TARGET_COMBO_LOCATION = "Combo Location";
	PERL_LOCALIZED_CONFIG_TARGET_CLASS_ICON = "Class Icon";
	PERL_LOCALIZED_CONFIG_TARGET_CLASS_CIVILIAN_FRAMES = "Class/Civilian Frames";
	PERL_LOCALIZED_CONFIG_TARGET_RARE_ELITE_FRAME = "Rare/Elite Frame";
	PERL_LOCALIZED_CONFIG_TARGET_HIDE_BUFFDEBUFF_BACKGROUND = "Hide Buff/Debuff Background";
	PERL_LOCALIZED_CONFIG_TARGET_SOUND_ON_TARGET_CHANGE = "Sound on Target Change";
	PERL_LOCALIZED_CONFIG_TARGET_LOCK = "Lock "..PERL_LOCALIZED_CONFIG_TARGET.." Frame";
	PERL_LOCALIZED_CONFIG_TARGET_COMBO_POINT_FRAME = "Combo Point Frame";
	PERL_LOCALIZED_CONFIG_TARGET_DISPLAY_IN_NAME_FRAME = "Display in Name Frame";
	PERL_LOCALIZED_CONFIG_TARGET_DEBUFF_STACKS_IN_COMBO_FRAME = "Debuff Stacks in Combo Frame";
	PERL_LOCALIZED_CONFIG_TARGET_ALTERNATE_FRAME_STYLE = "Alternate Frame Style";
	PERL_LOCALIZED_CONFIG_TARGET_INVERT_BUFFS_DEBUFFS = "Invert Buffs/Debuffs";

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