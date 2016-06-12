--if (GetLocale() == "enUS") then	-- Bypassing this allows us to at least give other languages English since they aren't fully translated
	-- Generic Globals that do NOT need localizing
	PERL_LOCALIZED_VERSION_NUMBER = "5.08";
	PERL_LOCALIZED_DATE = "February 23, 2014";
	PERL_LOCALIZED_BUFF_NONE = "none";

	-- Title and Version
	PERL_LOCALIZED_NAME = "Perl Classic Unit Frames";
	PERL_LOCALIZED_VERSION = "Version "..PERL_LOCALIZED_VERSION_NUMBER;

	-- Creature Types
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

	-- Perl Config Strings
	PERL_LOCALIZED_CONFIG_MINIMAP_LOCK = "Right clicking will LOCK all frames";
	PERL_LOCALIZED_CONFIG_MINIMAP_UNLOCK = "Right clicking will UNLOCK all frames";
	PERL_LOCALIZED_CONFIG_OPTIONS_UNAVAILABLE = PERL_LOCALIZED_NAME..": Options cannot be changed in combat.";
	PERL_LOCALIZED_CONFIG_BLIZZARD_BUTTON = "Open Options"

	-- Perl Player Strings
	PERL_LOCALIZED_PLAYER_GROUP = "Group ";
	PERL_LOCALIZED_PLAYER_LEVEL_NINETY = "Level 90";
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
	PERL_LOCALIZED_PLAYER_STEALTH = "Stealth";
	PERL_LOCALIZED_PLAYER_PROWL = "Prowl";

	-- Perl Target Strings
	PERL_LOCALIZED_TARGET_BOSS = "Boss";
	PERL_LOCALIZED_TARGET_ELITE = "Elite";
	PERL_LOCALIZED_TARGET_RARE = "Rare";
	PERL_LOCALIZED_TARGET_RAREELITE = "Rare+";
	PERL_LOCALIZED_TARGET_FIRE_VULNERABILITY = "Fire Vulnerability";
	PERL_LOCALIZED_TARGET_SHADOW_VULNERABILITY = "Shadow Vulnerability";
	PERL_LOCALIZED_TARGET_SUNDER_ARMOR = "Sunder Armor";
	PERL_LOCALIZED_TARGET_HOLY_VENGEANCE = "Holy Vengeance";
	PERL_LOCALIZED_TARGET_NA = "N/A";
	PERL_LOCALIZED_TARGET_UNGUILDED = "Unguilded";
	PERL_LOCALIZED_TARGET_TRIVIAL = "Trivial"

	-- Perl Target Target Strings
	PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU = " has changed targets to you!";

	-- Perl Config Key Binging Strings
	BINDING_HEADER_PERLCONFIG = PERL_LOCALIZED_NAME;
	BINDING_NAME_TOGGLEOPTIONS = "Toggle Options Menu";
--end
