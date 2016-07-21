---------------
-- Variables --
---------------
PCUF_SHOW_DEBUG_EVENTS = 0;			-- event hijack and forbidden action monitor
Perl_Config_Config = {};
Perl_Config_Profiles = {};
local Perl_Config_Events = {};		-- event manager
local Perl_Config_Queue = {};		-- queue manager
local _;
Perl_Config_Global_ArcaneBar_Config = {};
Perl_Config_Global_CombatDisplay_Config = {};
Perl_Config_Global_Config_Config = {};
Perl_Config_Global_Focus_Config = {};
Perl_Config_Global_Party_Config = {};
Perl_Config_Global_Party_Pet_Config = {};
Perl_Config_Global_Party_Target_Config = {};
Perl_Config_Global_Player_Config = {};
Perl_Config_Global_Player_Buff_Config = {};
Perl_Config_Global_Player_Pet_Config = {};
Perl_Config_Global_Target_Config = {};
Perl_Config_Global_Target_Target_Config = {};

-- Default Saved Variables (also set in Perl_Config_GetVars)
local texture = 0;					-- no texture is set by default
local showminimapbutton = 1;		-- minimap button is on by default
local minimapbuttonpos = 300;		-- default minimap button position
local minimapbuttonrad = 80;		-- default minimap button radius
local transparentbackground = 0;	-- use solid black background as default
local texturedbarbackground = 0;	-- bar backgrounds are plain by default
PCUF_CASTPARTYSUPPORT = 0;			-- CastParty support is disabled by default
PCUF_COLORHEALTH = 0;				-- progressively colored health bars are off by default
PCUF_FADEBARS = 0;					-- fading status bars is off by default
PCUF_NAMEFRAMECLICKCAST = 0;		-- name frames will be the one safe spot for menus by default
PCUF_INVERTBARVALUES = 0;			-- bars deplete when low
PCUF_COLORFRAMEDEBUFF = 1;			-- frame debuff coloring is on by default
local positioningmode = 0;			-- positioning mode is off by default
PCUF_THREATICON = 0;				-- threat icon is off by default

-- Default Local Variables
local Initialized = nil;			-- waiting to be initialized
local currentprofilenumber = 0;		-- easy way to make our profile system work
local eventqueuetotal = 0;			-- variable to check how many queued events we have
local inpetbattle = 0;				-- variable to keep track of pet battle status		MAY NOT NEED THIS

-- Local variables to save memory
local playerClass;


----------------------
-- Loading Function --
----------------------
function Perl_Config_OnLoad(self)
	-- Events
	--self:RegisterEvent("PET_BATTLE_CLOSE");
	--self:RegisterEvent("PET_BATTLE_OPENING_START");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");

	-- Scripts
	self:SetScript("OnEvent",
		function(self, event, ...)
			Perl_Config_Events[event](self, ...);
		end
	);

	-- Slash Commands
	SlashCmdList["PERL_CONFIG"] = Perl_Config_SlashHandler;
	SLASH_PERL_CONFIG1 = "/perl";
end

function Perl_BlizzardOptions_OnLoad(panel)
	panel.name = PERL_LOCALIZED_NAME;
	InterfaceOptions_AddCategory(panel);
end


------------
-- Events --
------------
function Perl_Config_Events:PET_BATTLE_CLOSE()
	positioningmode = 0;								-- This may not work for PvP detection, will have to test on live servers
	Perl_Config_PositioningMode_Disable();
end

function Perl_Config_Events:PET_BATTLE_OPENING_START()
	positioningmode = 1;								-- This may not work for PvP detection, will have to test on live servers

	if (Perl_CombatDisplay_Frame) then
		SmartHide(Perl_CombatDisplay_Frame);
		SmartHide(Perl_CombatDisplay_Target_Frame);
		FRAMELOCK_STATES.PETBATTLES.Perl_CombatDisplay_Frame = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_CombatDisplay_Target_Frame = "hidden";
	end

	if (Perl_Focus_Frame) then
		SmartHide(Perl_Focus_Frame);
		FRAMELOCK_STATES.PETBATTLES.Perl_Focus_Frame = "hidden";
	end

	if (Perl_Party_Frame) then
		SmartHide(Perl_Party_MemberFrame1);
		SmartHide(Perl_Party_MemberFrame2);
		SmartHide(Perl_Party_MemberFrame3);
		SmartHide(Perl_Party_MemberFrame4);
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_MemberFrame1 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_MemberFrame2 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_MemberFrame3 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_MemberFrame4 = "hidden";
	end

	if (Perl_Party_Pet_Script_Frame) then
		SmartHide(Perl_Party_Pet1);
		SmartHide(Perl_Party_Pet2);
		SmartHide(Perl_Party_Pet3);
		SmartHide(Perl_Party_Pet4);
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Pet1 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Pet2 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Pet3 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Pet4 = "hidden";
	end

	if (Perl_Party_Target_Script_Frame) then
		SmartHide(Perl_Party_Target1);
		SmartHide(Perl_Party_Target2);
		SmartHide(Perl_Party_Target3);
		SmartHide(Perl_Party_Target4);
		SmartHide(Perl_Party_Target5);
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Target1 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Target2 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Target3 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Target4 = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Party_Target5 = "hidden";
	end

	if (Perl_Player_Frame) then
		SmartHide(Perl_Player_Frame);
		FRAMELOCK_STATES.PETBATTLES.Perl_Player_Frame = "hidden";
	end

	if (Perl_Player_Pet_Frame) then
		SmartHide(Perl_Player_Pet_Frame);
		SmartHide(Perl_Player_Pet_Target_Frame);
		FRAMELOCK_STATES.PETBATTLES.Perl_Player_Pet_Frame = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Player_Pet_Target_Frame = "hidden";
	end

	if (Perl_Target_Frame) then
		SmartHide(Perl_Target_Frame);
		FRAMELOCK_STATES.PETBATTLES.Perl_Target_Frame = "hidden";
	end

	if (Perl_Target_Target_Script_Frame) then
		SmartHide(Perl_Target_Target_Frame);
		SmartHide(Perl_Target_Target_Target_Frame);
		FRAMELOCK_STATES.PETBATTLES.Perl_Target_Target_Frame = "hidden";
		FRAMELOCK_STATES.PETBATTLES.Perl_Target_Target_Target_Frame = "hidden";
	end
end

function Perl_Config_Events:PLAYER_REGEN_DISABLED()
	if (Perl_Config_Frame) then
		if (Perl_Config_Frame:IsVisible()) then
			Perl_Config_Frame:Hide();
			Perl_Config_Hide_All();
			DEFAULT_CHAT_FRAME:AddMessage(PERL_LOCALIZED_CONFIG_OPTIONS_UNAVAILABLE);
		end
	end
	if (positioningmode == 1) then
		positioningmode = 0;
		Perl_Config_PositioningMode_Disable();
	end
end

function Perl_Config_Events:PLAYER_REGEN_ENABLED()
	if (eventqueuetotal ~= 0) then
		Perl_Config_Queue_Process();
	end
end

function Perl_Config_Events:PLAYER_LOGIN()
	Perl_Config_Initialize();
end
Perl_Config_Events.PLAYER_ENTERING_WORLD = Perl_Config_Events.PLAYER_LOGIN;

function Perl_Config_Events:ADDON_ACTION_BLOCKED()
	if (PCUF_SHOW_DEBUG_EVENTS == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("Perl Classic: Violation in : "..arg1.."    Function Name : "..arg2);
	end
end
Perl_Config_Events.ADDON_ACTION_FORBIDDEN = Perl_Config_Events.ADDON_ACTION_BLOCKED;


-------------------
-- Slash Handler --
-------------------
function Perl_Config_SlashHandler(msg)
	Perl_Config_Toggle();
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Config_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Config_Set_Texture();
		Perl_Config_Button_UpdatePosition();
		Perl_Config_ShowHide_MiniMap_Button();
		Perl_Config_Set_Background();
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	Perl_Config_Migrate_Vars_Old_To_New("Config");
	if (type(Perl_Config_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
		Perl_Config_GetVars();
	else
		Perl_Config_UpdateVars();
	end

	-- Debug Stuff
	if (PCUF_SHOW_DEBUG_EVENTS == 1) then
		Perl_Config_Script_Frame:RegisterEvent("ADDON_ACTION_BLOCKED");
		Perl_Config_Script_Frame:RegisterEvent("ADDON_ACTION_FORBIDDEN");
	end

	-- Profile Support
	Perl_Config_Profile_Work();

	-- Debuff Coloring Support for 3.0+
	local _;
	_, playerClass = UnitClass("player");

	-- Set the initialization flag
	Initialized = 1;

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": "..PERL_LOCALIZED_VERSION.." loaded.");
end


-------------------------------
-- Migrate Settings Function --
-------------------------------
function Perl_Config_Migrate_Vars_Old_To_New(addon)		-- Do not add new variable support to this function
	local name = UnitName("player");
	local realm = GetRealmName("player");

	if (addon == "ArcaneBar") then
		if (type(Perl_ArcaneBar_Config[name]) == "table" and type(Perl_ArcaneBar_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_ArcaneBar_Config[realm.."-"..name] = {
				["PlayerEnabled"] = Perl_ArcaneBar_Config[name]["PlayerEnabled"],
				["TargetEnabled"] = Perl_ArcaneBar_Config[name]["TargetEnabled"],
				["FocusEnabled"] = Perl_ArcaneBar_Config[name]["FocusEnabled"],
				["PartyEnabled"] = Perl_ArcaneBar_Config[name]["PartyEnabled"],
				["PlayerShowTimer"] = Perl_ArcaneBar_Config[name]["PlayerShowTimer"],
				["TargetShowTimer"] = Perl_ArcaneBar_Config[name]["TargetShowTimer"],
				["FocusShowTimer"] = Perl_ArcaneBar_Config[name]["FocusShowTimer"],
				["PartyShowTimer"] = Perl_ArcaneBar_Config[name]["PartyShowTimer"],
				["PlayerLeftTimer"] = Perl_ArcaneBar_Config[name]["PlayerLeftTimer"],
				["TargetLeftTimer"] = Perl_ArcaneBar_Config[name]["TargetLeftTimer"],
				["FocusLeftTimer"] = Perl_ArcaneBar_Config[name]["FocusLeftTimer"],
				["PartyLeftTimer"] = Perl_ArcaneBar_Config[name]["PartyLeftTimer"],
				["PlayerNameReplace"] = Perl_ArcaneBar_Config[name]["PlayerNameReplace"],
				["TargetNameReplace"] = Perl_ArcaneBar_Config[name]["TargetNameReplace"],
				["FocusNameReplace"] = Perl_ArcaneBar_Config[name]["FocusNameReplace"],
				["PartyNameReplace"] = Perl_ArcaneBar_Config[name]["PartyNameReplace"],
				["HideOriginal"] = Perl_ArcaneBar_Config[name]["HideOriginal"],
				["Transparency"] = Perl_ArcaneBar_Config[name]["Transparency"],
			};
		end
	end

	if (addon == "CombatDisplay") then
		if (type(Perl_CombatDisplay_Config[name]) == "table" and type(Perl_CombatDisplay_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_CombatDisplay_Config[realm.."-"..name] = {
				["State"] = Perl_CombatDisplay_Config[name]["State"],
				["Locked"] = Perl_CombatDisplay_Config[name]["Locked"],
				["HealthPersist"] = Perl_CombatDisplay_Config[name]["HealthPersist"],
				["ManaPersist"] = Perl_CombatDisplay_Config[name]["ManaPersist"],
				["Scale"] = Perl_CombatDisplay_Config[name]["Scale"],
				["Transparency"] = Perl_CombatDisplay_Config[name]["Transparency"],
				["ShowTarget"] = Perl_CombatDisplay_Config[name]["ShowTarget"],
				["ShowDruidBar"] = Perl_CombatDisplay_Config[name]["ShowDruidBar"],
				["ShowPetBars"] = Perl_CombatDisplay_Config[name]["ShowPetBars"],
				["RightClickMenu"] = Perl_CombatDisplay_Config[name]["RightClickMenu"],
				["DisplayPercents"] = Perl_CombatDisplay_Config[name]["DisplayPercents"],
				["ShowCP"] = Perl_CombatDisplay_Config[name]["ShowCP"],
				["ClickThrough"] = Perl_CombatDisplay_Config[name]["ClickThrough"],
			};
		end
	end

	if (addon == "Config") then
		if (type(Perl_Config_Config[name]) == "table" and type(Perl_Config_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Config_Config[realm.."-"..name] = {
				["Texture"] = Perl_Config_Config[name]["Texture"],
				["ShowMiniMapButton"] = Perl_Config_Config[name]["ShowMiniMapButton"],
				["MiniMapButtonPos"] = Perl_Config_Config[name]["MiniMapButtonPos"],
				["TransparentBackground"] = Perl_Config_Config[name]["TransparentBackground"],
				["PCUF_CastPartySupport"] = Perl_Config_Config[name]["PCUF_CastPartySupport"],
				["PCUF_ColorHealth"] = Perl_Config_Config[name]["PCUF_ColorHealth"],
				["TexturedBarBackround"] = Perl_Config_Config[name]["TexturedBarBackround"],
				["PCUF_FadeBars"] = Perl_Config_Config[name]["PCUF_FadeBars"],
				["PCUF_NameFrameClickCast"] = Perl_Config_Config[name]["PCUF_NameFrameClickCast"],
				["PCUF_InvertBarValues"] = Perl_Config_Config[name]["PCUF_InvertBarValues"],
				["MiniMapButtonRad"] = Perl_Config_Config[name]["MiniMapButtonRad"],
				["PCUF_ColorFrameDebuff"] = Perl_Config_Config[name]["PCUF_ColorFrameDebuff"],
				["PositioningMode"] = Perl_Config_Config[name]["PositioningMode"],
				["PCUF_ThreatIcon"] = Perl_Config_Config[name]["PCUF_ThreatIcon"],
			};
		end
	end

	if (addon == "Focus") then
		if (type(Perl_Focus_Config[name]) == "table" and type(Perl_Focus_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Focus_Config[realm.."-"..name] = {
				["Locked"] = Perl_Focus_Config[name]["Locked"],
				["ClassIcon"] = Perl_Focus_Config[name]["ClassIcon"],
				["ClassFrame"] = Perl_Focus_Config[name]["ClassFrame"],
				["PvPIcon"] = Perl_Focus_Config[name]["PvPIcon"],
				["Buffs"] = Perl_Focus_Config[name]["Buffs"],
				["Debuffs"] = Perl_Focus_Config[name]["Debuffs"],
				["Scale"] = Perl_Focus_Config[name]["Scale"],
				["Transparency"] = Perl_Focus_Config[name]["Transparency"],
				["BuffDebuffScale"] = Perl_Focus_Config[name]["BuffDebuffScale"],
				["ShowPortrait"] = Perl_Focus_Config[name]["ShowPortrait"],
				["ThreeDPortrait"] = Perl_Focus_Config[name]["ThreeDPortrait"],
				["PortraitCombatText"] = Perl_Focus_Config[name]["PortraitCombatText"],
				["ShowRareEliteFrame"] = Perl_Focus_Config[name]["ShowRareEliteFrame"],
				["NameFrameComboPoints"] = Perl_Focus_Config[name]["NameFrameComboPoints"],
				["ComboFrameDebuffs"] = Perl_Focus_Config[name]["ComboFrameDebuffs"],
				["FrameStyle"] = Perl_Focus_Config[name]["FrameStyle"],
				["CompactMode"] = Perl_Focus_Config[name]["CompactMode"],
				["CompactPercent"] = Perl_Focus_Config[name]["CompactPercent"],
				["HideBuffBackground"] = Perl_Focus_Config[name]["HideBuffBackground"],
				["ShortBars"] = Perl_Focus_Config[name]["ShortBars"],
				["HealerMode"] = Perl_Focus_Config[name]["HealerMode"],
				["DisplayCastableBuffs"] = Perl_Focus_Config[name]["DisplayCastableBuffs"],
				["ClassColoredNames"] = Perl_Focus_Config[name]["ClassColoredNames"],
				["ShowManaDeficit"] = Perl_Focus_Config[name]["ShowManaDeficit"],
				["InvertBuffs"] = Perl_Focus_Config[name]["InvertBuffs"],
				["DisplayCurableDebuff"] = Perl_Focus_Config[name]["DisplayCurableDebuff"],
				["DisplayBuffTimers"] = Perl_Focus_Config[name]["DisplayBuffTimers"],
				["DisplayOnlyMyDebuffs"] = Perl_Focus_Config[name]["DisplayOnlyMyDebuffs"],
			};
		end
	end

	if (addon == "Party") then
		if (type(Perl_Party_Config[name]) == "table" and type(Perl_Party_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Party_Config[realm.."-"..name] = {
				["Locked"] = Perl_Party_Config[name]["Locked"],
				["CompactMode"] = Perl_Party_Config[name]["CompactMode"],
				["PartyHidden"] = Perl_Party_Config[name]["PartyHidden"],
				["PartySpacing"] = Perl_Party_Config[name]["PartySpacing"],
				["Scale"] = Perl_Party_Config[name]["Scale"],
				["ShowPets"] = Perl_Party_Config[name]["ShowPets"],
				["HealerMode"] = Perl_Party_Config[name]["HealerMode"],
				["Transparency"] = Perl_Party_Config[name]["Transparency"],
				["BuffLocation"] = Perl_Party_Config[name]["BuffLocation"],
				["DebuffLocation"] = Perl_Party_Config[name]["DebuffLocation"],
				["VerticalAlign"] = Perl_Party_Config[name]["VerticalAlign"],
				["CompactPercent"] = Perl_Party_Config[name]["CompactPercent"],
				["ShowPortrait"] = Perl_Party_Config[name]["ShowPortrait"],
				["ShowFKeys"] = Perl_Party_Config[name]["ShowFKeys"],
				["DisplayCastableBuffs"] = Perl_Party_Config[name]["DisplayCastableBuffs"],
				["ThreeDPortrait"] = Perl_Party_Config[name]["ThreeDPortrait"],
				["BuffSize"] = Perl_Party_Config[name]["BuffSize"],
				["DebuffSize"] = Perl_Party_Config[name]["DebuffSize"],
				["Buffs"] = Perl_Party_Config[name]["Buffs"],
				["Debuffs"] = Perl_Party_Config[name]["Debuffs"],
				["ClassColoredNames"] = Perl_Party_Config[name]["ClassColoredNames"],
				["ShortBars"] = Perl_Party_Config[name]["ShortBars"],
				["HideClassLevelFrame"] = Perl_Party_Config[name]["HideClassLevelFrame"],
				["ShowManaDeficit"] = Perl_Party_Config[name]["ShowManaDeficit"],
				["ShowPvPIcon"] = Perl_Party_Config[name]["ShowPvPIcon"],
				["ShowBarValues"] = Perl_Party_Config[name]["ShowBarValues"],
				["DisplayCurableDebuff"] = Perl_Party_Config[name]["DisplayCurableDebuff"],
				["PortraitBuffs"] = Perl_Party_Config[name]["PortraitBuffs"],
				["DisplayBuffTimers"] = Perl_Party_Config[name]["DisplayBuffTimers"],
			};
		end
	end

	if (addon == "Party_Pet") then
		if (type(Perl_Party_Pet_Config[name]) == "table" and type(Perl_Party_Pet_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Party_Pet_Config[realm.."-"..name] = {
				["Locked"] = Perl_Party_Pet_Config[name]["Locked"],
				["ShowPortrait"] = Perl_Party_Pet_Config[name]["ShowPortrait"],
				["ThreeDPortrait"] = Perl_Party_Pet_Config[name]["ThreeDPortrait"],
				["Scale"] = Perl_Party_Pet_Config[name]["Scale"],
				["Transparency"] = Perl_Party_Pet_Config[name]["Transparency"],
				["Buffs"] = Perl_Party_Pet_Config[name]["Buffs"],
				["Debuffs"] = Perl_Party_Pet_Config[name]["Debuffs"],
				["BuffSize"] = Perl_Party_Pet_Config[name]["BuffSize"],
				["DebuffSize"] = Perl_Party_Pet_Config[name]["DebuffSize"],
				["BuffLocation"] = Perl_Party_Pet_Config[name]["BuffLocation"],
				["DebuffLocation"] = Perl_Party_Pet_Config[name]["DebuffLocation"],
				["HiddenInRaids"] = Perl_Party_Pet_Config[name]["HiddenInRaids"],
				["Enabled"] = Perl_Party_Pet_Config[name]["Enabled"],
				["DisplayCastableBuffs"] = Perl_Party_Pet_Config[name]["DisplayCastableBuffs"],
				["DisplayCurableDebuff"] = Perl_Party_Pet_Config[name]["DisplayCurableDebuff"],
			};
		end
	end

	if (addon == "Party_Target") then
		if (type(Perl_Party_Target_Config[name]) == "table" and type(Perl_Party_Target_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Party_Target_Config[realm.."-"..name] = {
				["Locked"] = Perl_Party_Target_Config[name]["Locked"],
				["Scale"] = Perl_Party_Target_Config[name]["Scale"],
				["FocusScale"] = Perl_Party_Target_Config[name]["FocusScale"],
				["Transparency"] = Perl_Party_Target_Config[name]["Transparency"],
				["HidePowerBars"] = Perl_Party_Target_Config[name]["HidePowerBars"],
				["ClassColoredNames"] = Perl_Party_Target_Config[name]["ClassColoredNames"],
				["Enabled"] = Perl_Party_Target_Config[name]["Enabled"],
				["PartyHiddenInRaid"] = Perl_Party_Target_Config[name]["PartyHiddenInRaid"],
				["EnabledFocus"] = Perl_Party_Target_Config[name]["EnabledFocus"],
				["FocusHiddenInRaid"] = Perl_Party_Target_Config[name]["FocusHiddenInRaid"],
			};
		end
	end

	if (addon == "Player") then
		if (type(Perl_Player_Config[name]) == "table" and type(Perl_Player_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Player_Config[realm.."-"..name] = {
				["Locked"] = Perl_Player_Config[name]["Locked"],
				["XPBarState"] = Perl_Player_Config[name]["XPBarState"],
				["CompactMode"] = Perl_Player_Config[name]["CompactMode"],
				["ShowRaidGroup"] = Perl_Player_Config[name]["ShowRaidGroup"],
				["Scale"] = Perl_Player_Config[name]["Scale"],
				["HealerMode"] = Perl_Player_Config[name]["HealerMode"],
				["Transparency"] = Perl_Player_Config[name]["Transparency"],
				["ShowPortrait"] = Perl_Player_Config[name]["ShowPortrait"],
				["CompactPercent"] = Perl_Player_Config[name]["CompactPercent"],
				["ThreeDPortrait"] = Perl_Player_Config[name]["ThreeDPortrait"],
				["PortraitCombatText"] = Perl_Player_Config[name]["PortraitCombatText"],
				["ShowDruidBar"] = Perl_Player_Config[name]["ShowDruidBar"],
				["ShortBars"] = Perl_Player_Config[name]["ShortBars"],
				["ClassColoredNames"] = Perl_Player_Config[name]["ClassColoredNames"],
				["HideClassLevelFrame"] = Perl_Player_Config[name]["HideClassLevelFrame"],
				["ShowManaDeficit"] = Perl_Player_Config[name]["ShowManaDeficit"],
				["HiddenInRaid"] = Perl_Player_Config[name]["HiddenInRaid"],
				["ShowPvPIcon"] = Perl_Player_Config[name]["ShowPvPIcon"],
				["ShowBarValues"] = Perl_Player_Config[name]["ShowBarValues"],
				["ShowRaidGroupInName"] = Perl_Player_Config[name]["ShowRaidGroupInName"],
				["FiveSecondRule"] = Perl_Player_Config[name]["FiveSecondRule"],
				["TotemTimers"] = Perl_Player_Config[name]["TotemTimers"],
				["RuneFrame"] = Perl_Player_Config[name]["RuneFrame"],
				["PvPTimer"] = Perl_Player_Config[name]["PvPTimer"],
				["PaladinPowerBar"] = Perl_Player_Config[name]["PaladinPowerBar"],
				["ShardBarFrame"] = Perl_Player_Config[name]["ShardBarFrame"],
				["EclipseBarFrame"] = Perl_Player_Config[name]["EclipseBarFrame"],
				["HarmonyBarFrame"] = Perl_Player_Config[name]["HarmonyBarFrame"],
				["PriestBarFrame"] = Perl_Player_Config[name]["PriestBarFrame"],
			};
		end
	end

	if (addon == "Player_Buff") then
		if (type(Perl_Player_Buff_Config[name]) == "table" and type(Perl_Player_Buff_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Player_Buff_Config[realm.."-"..name] = {
				["BuffAlerts"] = Perl_Player_Buff_Config[name]["BuffAlerts"],
				["ShowBuffs"] = Perl_Player_Buff_Config[name]["ShowBuffs"],
				["Scale"] = Perl_Player_Buff_Config[name]["Scale"],
				["HideSeconds"] = Perl_Player_Buff_Config[name]["HideSeconds"],
				["HorizontalSpacing"] = Perl_Player_Buff_Config[name]["HorizontalSpacing"],
			};
		end
	end

	if (addon == "Player_Pet") then
		if (type(Perl_Player_Pet_Config[name]) == "table" and type(Perl_Player_Pet_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Player_Pet_Config[realm.."-"..name] = {
				["Locked"] = Perl_Player_Pet_Config[name]["Locked"],
				["ShowXP"] = Perl_Player_Pet_Config[name]["ShowXP"],
				["Scale"] = Perl_Player_Pet_Config[name]["Scale"],
				["TargetScale"] = Perl_Player_Pet_Config[name]["TargetScale"],
				["Buffs"] = Perl_Player_Pet_Config[name]["Buffs"],
				["Debuffs"] = Perl_Player_Pet_Config[name]["Debuffs"],
				["Transparency"] = Perl_Player_Pet_Config[name]["Transparency"],
				["BuffLocation"] = Perl_Player_Pet_Config[name]["BuffLocation"],
				["DebuffLocation"] = Perl_Player_Pet_Config[name]["DebuffLocation"],
				["BuffSize"] = Perl_Player_Pet_Config[name]["BuffSize"],
				["DebuffSize"] = Perl_Player_Pet_Config[name]["DebuffSize"],
				["ShowPortrait"] = Perl_Player_Pet_Config[name]["ShowPortrait"],
				["ThreeDPortrait"] = Perl_Player_Pet_Config[name]["ThreeDPortrait"],
				["PortraitCombatText"] = Perl_Player_Pet_Config[name]["PortraitCombatText"],
				["CompactMode"] = Perl_Player_Pet_Config[name]["CompactMode"],
				["HideName"] = Perl_Player_Pet_Config[name]["HideName"],
				["DisplayPetTarget"] = Perl_Player_Pet_Config[name]["DisplayPetTarget"],
				["ClassColoredNames"] = Perl_Player_Pet_Config[name]["ClassColoredNames"],
				["ShowFriendlyHealth"] = Perl_Player_Pet_Config[name]["ShowFriendlyHealth"],
				["DisplayCastableBuffs"] = Perl_Player_Pet_Config[name]["DisplayCastableBuffs"],
				["DisplayCurableDebuff"] = Perl_Player_Pet_Config[name]["DisplayCurableDebuff"],
			};
		end
	end

	if (addon == "Target") then
		if (type(Perl_Target_Config[name]) == "table" and type(Perl_Target_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Target_Config[realm.."-"..name] = {
				["Locked"] = Perl_Target_Config[name]["Locked"],
				["ComboPoints"] = Perl_Target_Config[name]["ComboPoints"],
				["ClassIcon"] = Perl_Target_Config[name]["ClassIcon"],
				["ClassFrame"] = Perl_Target_Config[name]["ClassFrame"],
				["PvPIcon"] = Perl_Target_Config[name]["PvPIcon"],
				["Buffs"] = Perl_Target_Config[name]["Buffs"],
				["Debuffs"] = Perl_Target_Config[name]["Debuffs"],
				["Scale"] = Perl_Target_Config[name]["Scale"],
				["Transparency"] = Perl_Target_Config[name]["Transparency"],
				["BuffDebuffScale"] = Perl_Target_Config[name]["BuffDebuffScale"],
				["ShowPortrait"] = Perl_Target_Config[name]["ShowPortrait"],
				["ThreeDPortrait"] = Perl_Target_Config[name]["ThreeDPortrait"],
				["PortraitCombatText"] = Perl_Target_Config[name]["PortraitCombatText"],
				["ShowRareEliteFrame"] = Perl_Target_Config[name]["ShowRareEliteFrame"],
				["NameFrameComboPoints"] = Perl_Target_Config[name]["NameFrameComboPoints"],
				["ComboFrameDebuffs"] = Perl_Target_Config[name]["ComboFrameDebuffs"],
				["FrameStyle"] = Perl_Target_Config[name]["FrameStyle"],
				["CompactMode"] = Perl_Target_Config[name]["CompactMode"],
				["CompactPercent"] = Perl_Target_Config[name]["CompactPercent"],
				["HideBuffBackground"] = Perl_Target_Config[name]["HideBuffBackground"],
				["ShortBars"] = Perl_Target_Config[name]["ShortBars"],
				["HealerMode"] = Perl_Target_Config[name]["HealerMode"],
				["SoundTargetChange"] = Perl_Target_Config[name]["SoundTargetChange"],
				["DisplayCastableBuffs"] = Perl_Target_Config[name]["DisplayCastableBuffs"],
				["ClassColoredNames"] = Perl_Target_Config[name]["ClassColoredNames"],
				["ShowManaDeficit"] = Perl_Target_Config[name]["ShowManaDeficit"],
				["InvertBuffs"] = Perl_Target_Config[name]["InvertBuffs"],
				["ShowGuildName"] = Perl_Target_Config[name]["ShowGuildName"],
				["EliteRareGraphic"] = Perl_Target_Config[name]["EliteRareGraphic"],
				["DisplayCurableDebuff"] = Perl_Target_Config[name]["DisplayCurableDebuff"],
				["DisplayBuffTimers"] = Perl_Target_Config[name]["DisplayBuffTimers"],
				["DisplayNumbericThreat"] = Perl_Target_Config[name]["DisplayNumbericThreat"],
				["DisplayOnlyMyDebuffs"] = Perl_Target_Config[name]["DisplayOnlyMyDebuffs"],
			};
		end
	end

	if (addon == "Target_Target") then
		if (type(Perl_Target_Target_Config[name]) == "table" and type(Perl_Target_Target_Config[realm.."-"..name]) ~= "table") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": Migrating settings for Perl_"..addon);

			Perl_Target_Target_Config[realm.."-"..name] = {
				["Locked"] = Perl_Target_Target_Config[name]["Locked"],
				["Scale"] = Perl_Target_Target_Config[name]["Scale"],
				["ToTSupport"] = Perl_Target_Target_Config[name]["ToTSupport"],
				["ToToTSupport"] = Perl_Target_Target_Config[name]["ToToTSupport"],
				["Transparency"] = Perl_Target_Target_Config[name]["Transparency"],
				["AlertSound"] = Perl_Target_Target_Config[name]["AlertSound"],
				["AlertMode"] = Perl_Target_Target_Config[name]["AlertMode"],
				["AlertSize"] = Perl_Target_Target_Config[name]["AlertSize"],
				["ShowToTBuffs"] = Perl_Target_Target_Config[name]["ShowToTBuffs"],
				["ShowToToTBuffs"] = Perl_Target_Target_Config[name]["ShowToToTBuffs"],
				["HidePowerBars"] = Perl_Target_Target_Config[name]["HidePowerBars"],
				["ShowToTDebuffs"] = Perl_Target_Target_Config[name]["ShowToTDebuffs"],
				["ShowToToTDebuffs"] = Perl_Target_Target_Config[name]["ShowToToTDebuffs"],
				["DisplayCastableBuffs"] = Perl_Target_Target_Config[name]["DisplayCastableBuffs"],
				["ClassColoredNames"] = Perl_Target_Target_Config[name]["ClassColoredNames"],
				["ShowFriendlyHealth"] = Perl_Target_Target_Config[name]["ShowFriendlyHealth"],
				["DisplayCurableDebuff"] = Perl_Target_Target_Config[name]["DisplayCurableDebuff"],
				["DisplayOnlyMyDebuffs"] = Perl_Target_Target_Config[name]["DisplayOnlyMyDebuffs"],
			};
		end
	end
end


---------------------------
-- Config Mode Functions --
---------------------------
function Perl_Config_PositioningMode_Disable()
	if (Perl_Focus_Frame) then
		Perl_Focus_Frame:SetAttribute("unit", "focus");
		if (UnitExists("focus")) then
			Perl_Focus_Update_Once();
		end
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Target_Frame:SetAttribute("unit", "target");
		Perl_CombatDisplay_Frame:Hide();
		Perl_CombatDisplay_Target_Frame:Hide();
		Perl_CombatDisplay_Frame_Style();
		Perl_CombatDisplay_Initialize();
	end

	if (Perl_Party_Frame) then
		Perl_Party_MemberFrame1:SetAttribute("unit", "party1");
		Perl_Party_MemberFrame2:SetAttribute("unit", "party2");
		Perl_Party_MemberFrame3:SetAttribute("unit", "party3");
		Perl_Party_MemberFrame4:SetAttribute("unit", "party4");
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame1);
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame2);
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame3);
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame4);
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet1:SetAttribute("unit", "partypet1");
		Perl_Party_Pet2:SetAttribute("unit", "partypet2");
		Perl_Party_Pet3:SetAttribute("unit", "partypet3");
		Perl_Party_Pet4:SetAttribute("unit", "partypet4");
		Perl_Party_Pet_Update();
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_Script_Frame:SetScript("OnUpdate", Perl_Party_Target_OnUpdate);
		Perl_Party_Target1:SetAttribute("unit", "party1target");
		Perl_Party_Target2:SetAttribute("unit", "party2target");
		Perl_Party_Target3:SetAttribute("unit", "party3target");
		Perl_Party_Target4:SetAttribute("unit", "party4target");
		Perl_Party_Target5:SetAttribute("unit", "focustarget");
	end

	if (Perl_Player_Frame) then
		Perl_Player_Update_Once();
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Target_Frame:SetScript("OnUpdate", Perl_Player_Pet_Target_OnUpdate);
		Perl_Player_Pet_Frame:SetAttribute("unit", "pet");
		Perl_Player_Pet_Target_Frame:SetAttribute("unit", "pettarget");
		Perl_Player_Pet_Update_Once();

	end

	if (Perl_Target_Frame) then
		Perl_Target_Frame:SetAttribute("unit", "target");
		if (UnitExists("target")) then
			Perl_Target_Update_Once();
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Script_Frame:SetScript("OnUpdate", Perl_Target_Target_OnUpdate);
		Perl_Target_Target_Frame:SetAttribute("unit", "targettarget");
		Perl_Target_Target_Target_Frame:SetAttribute("unit", "targettargettarget");
	end
end

function Perl_Config_PositioningMode_Enable()
	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Target_Frame:SetAttribute("unit", "player");
		Perl_CombatDisplay_HealthBarText:SetText("CombatDisplay Player");
		Perl_CombatDisplay_Target_HealthBarText:SetText("CombatDisplay Target");
		Perl_CombatDisplay_Frame:Show();
		Perl_CombatDisplay_Target_Frame:Show();
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Frame:SetAttribute("unit", "player");
		Perl_Focus_Update_Once();
		Perl_Focus_Reset_Buffs();
		Perl_Focus_BuffFrame:Hide();
		Perl_Focus_DebuffFrame:Hide();
		Perl_Focus_NameBarText:SetText("Focus");
	end

	if (Perl_Party_Frame) then
		Perl_Party_MemberFrame1:SetAttribute("unit", "player");
		Perl_Party_MemberFrame2:SetAttribute("unit", "player");
		Perl_Party_MemberFrame3:SetAttribute("unit", "player");
		Perl_Party_MemberFrame4:SetAttribute("unit", "player");
		Perl_Party_MemberFrame1_Name_NameBarText:SetText("Party 1");
		Perl_Party_MemberFrame2_Name_NameBarText:SetText("Party 2");
		Perl_Party_MemberFrame3_Name_NameBarText:SetText("Party 3");
		Perl_Party_MemberFrame4_Name_NameBarText:SetText("Party 4");
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet1:SetAttribute("unit", "player");
		Perl_Party_Pet2:SetAttribute("unit", "player");
		Perl_Party_Pet3:SetAttribute("unit", "player");
		Perl_Party_Pet4:SetAttribute("unit", "player");
		Perl_Party_Pet1_NameFrame_NameBarText:SetText("Party Pet 1");
		Perl_Party_Pet2_NameFrame_NameBarText:SetText("Party Pet 2");
		Perl_Party_Pet3_NameFrame_NameBarText:SetText("Party Pet 3");
		Perl_Party_Pet4_NameFrame_NameBarText:SetText("Party Pet 4");
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_Script_Frame:SetScript("OnUpdate", nil);
		Perl_Party_Target1:SetAttribute("unit", "player");
		Perl_Party_Target2:SetAttribute("unit", "player");
		Perl_Party_Target3:SetAttribute("unit", "player");
		Perl_Party_Target4:SetAttribute("unit", "player");
		Perl_Party_Target5:SetAttribute("unit", "player");
		Perl_Party_Target1_NameFrame_NameBarText:SetText("Party Target 1");
		Perl_Party_Target2_NameFrame_NameBarText:SetText("Party Target 2");
		Perl_Party_Target3_NameFrame_NameBarText:SetText("Party Target 3");
		Perl_Party_Target4_NameFrame_NameBarText:SetText("Party Target 4");
		Perl_Party_Target5_NameFrame_NameBarText:SetText("Focus Target");
	end

	if (Perl_Player_Frame) then
		Perl_Player_NameBarText:SetText("Player");
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Target_Frame:SetScript("OnUpdate", nil);
		Perl_Player_Pet_Frame:SetAttribute("unit", "player");
		Perl_Player_Pet_Target_Frame:SetAttribute("unit", "player");
		Perl_Player_Pet_ShowXP();
		Perl_Player_Pet_NameBarText:SetText("Pet");
		Perl_Player_Pet_Target_NameBarText:SetText("Pet Target");
	end

	if (Perl_Target_Frame) then
		Perl_Target_Frame:SetAttribute("unit", "player");
		Perl_Target_Update_Once();
		Perl_Target_Reset_Buffs();
		Perl_Target_BuffFrame:Hide();
		Perl_Target_DebuffFrame:Hide();
		Perl_Target_NameBarText:SetText("Target");
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Script_Frame:SetScript("OnUpdate", nil);
		Perl_Target_Target_Frame:SetAttribute("unit", "player");
		Perl_Target_Target_Target_Frame:SetAttribute("unit", "player");
		Perl_Target_Target_NameBarText:SetText("ToT");
		Perl_Target_Target_Target_NameBarText:SetText("ToToT");
	end
end


----------------------
-- Debuff Functions --
----------------------
function Perl_Config_Set_Curable_Debuffs(debuffType)
	if (playerClass == "DRUID") then
		if (debuffType == PERL_LOCALIZED_BUFF_CURSE or debuffType == PERL_LOCALIZED_BUFF_POISON) then
			return 1;
		end
	elseif (playerClass == "MAGE") then
		if (debuffType == PERL_LOCALIZED_BUFF_CURSE) then
			return 1;
		end
	elseif (playerClass == "PALADIN") then
		if (debuffType == PERL_LOCALIZED_BUFF_DISEASE or debuffType == PERL_LOCALIZED_BUFF_MAGIC or debuffType == PERL_LOCALIZED_BUFF_POISON) then
			return 1;
		end
	elseif (playerClass == "PRIEST") then
		if (debuffType == PERL_LOCALIZED_BUFF_DISEASE or debuffType == PERL_LOCALIZED_BUFF_MAGIC) then
			return 1;
		end
	elseif (playerClass == "SHAMAN") then
		if (debuffType == PERL_LOCALIZED_BUFF_CURSE) then
			return 1;
		end
	elseif (playerClass == "WARLOCK") then
		if (debuffType == PERL_LOCALIZED_BUFF_MAGIC) then
			return 1;
		end
	end
	return 0;
end


---------------------
-- Queue Functions --
---------------------
function Perl_Config_Queue_Add(incomingFunction)
	if (incomingFunction ~= nil) then
		table.insert(Perl_Config_Queue, incomingFunction);	-- Add our function to the queue
		eventqueuetotal = eventqueuetotal + 1;				-- Increment our variable by one
	end
end

function Perl_Config_Queue_Process()
	for i=1, table.getn(Perl_Config_Queue), 1 do			-- Loop through the queue and call all the functions we need to update
		local func = Perl_Config_Queue[i];
		if (func) then
			func();
		end
	end
	Perl_Config_Queue = {};									-- Empty the queue
	eventqueuetotal = 0;									-- Reset our variable
end


-----------------------
-- Profile Functions --
-----------------------
function Perl_Config_Profile_Work()
	local name = GetRealmName("player").."-"..UnitName("player");
	local found = 0;

	for i=1,table.getn(Perl_Config_Profiles),1 do
		if (Perl_Config_Profiles[i] == name) then
			found = 1;
			break;
		end
	end

	if (found == 0) then
		table.insert(Perl_Config_Profiles, name);
	end
end

function Perl_Config_Profile_OnShow()
	UIDropDownMenu_Initialize(Perl_Config_All_Frame_DropDown1, Perl_Config_Profile_Initialize);
	UIDropDownMenu_SetSelectedID(Perl_Config_All_Frame_DropDown1, 0);
	UIDropDownMenu_SetWidth(Perl_Config_All_Frame_DropDown1, 100);
end

function Perl_Config_Profile_Initialize()
	local info;
	for i = 1, getn(Perl_Config_Profiles), 1 do
		info = {
			text = Perl_Config_Profiles[i];
			func = Perl_Config_Profile_OnClick;
		};
		UIDropDownMenu_AddButton(info);
	end
end

function Perl_Config_Profile_OnClick(self)
	currentprofilenumber = self:GetID();
	UIDropDownMenu_SetSelectedID(Perl_Config_All_Frame_DropDown1, self:GetID());
end

function Perl_Config_Profile_Load()
	local name = Perl_Config_Profiles[currentprofilenumber];

	if (name ~= nil) then
		Perl_Config_GetVars(name, 1);

		if (Perl_ArcaneBar_Frame_Loaded_Frame) then
			Perl_ArcaneBar_GetVars(name, 1);
		end

		if (Perl_CombatDisplay_Frame) then
			Perl_CombatDisplay_GetVars(name, 1);
		end

		if (Perl_Focus_Frame) then
			Perl_Focus_GetVars(name, 1);
		end

		if (Perl_Party_Frame) then
			Perl_Party_GetVars(name, 1);
		end

		if (Perl_Party_Pet_Script_Frame) then
			Perl_Party_Pet_GetVars(name, 1);
		end

		if (Perl_Party_Target_Script_Frame) then
			Perl_Party_Target_GetVars(name, 1);
		end

		if (Perl_Player_Frame) then
			Perl_Player_GetVars(name, 1);
		end

		if (Perl_Player_Pet_Frame) then
			Perl_Player_Pet_GetVars(name, 1);
		end

		if (Perl_Target_Frame) then
			Perl_Target_GetVars(name, 1);
		end

		if (Perl_Target_Target_Script_Frame) then
			Perl_Target_Target_GetVars(name, 1);
		end

		DEFAULT_CHAT_FRAME:AddMessage(PERL_LOCALIZED_CONFIG_ALL_LOAD_PROFILE_OUTPUT..name);
	else
		DEFAULT_CHAT_FRAME:AddMessage(PERL_LOCALIZED_CONFIG_ALL_NO_PROFILE_SELECTED_OUTPUT);
	end
end

function Perl_Config_Profile_Delete()
	if (getn(Perl_Config_Profiles) > 0 and currentprofilenumber ~= 0) then
		table.remove(Perl_Config_Profiles, currentprofilenumber);
		UIDropDownMenu_SetSelectedID(Perl_Config_All_Frame_DropDown1, 0);
		currentprofilenumber = 0;
	end
end


--------------------------
-- Update/GUI Functions --
--------------------------
function Perl_Config_Set_Texture(newvalue)
	if (newvalue ~= nil) then
		texture = newvalue;
		Perl_Config_UpdateVars();
	end

	local texturename;
	if (texture == 0) then
		texturename = "Interface\\TargetingFrame\\UI-StatusBar";
	else
		texturename = "Interface\\AddOns\\Perl_Config\\Perl_StatusBar"..texture..".tga";
	end

	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_playerTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_targetTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_focusTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_party1Tex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_party2Tex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_party3Tex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_ArcaneBar_party4Tex, texturename);
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_ManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_DruidBarTex, texturename);
		--Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_DruidBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_CPBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_CPBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetHealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetHealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_ManaBarFadeBarTex, texturename);
		if (texturedbarbackground == 1) then
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_ManaBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_DruidBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_CPBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetHealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetManaBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_ManaBarBGTex, texturename);
		else
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_DruidBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_CPBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetHealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_PetManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_CombatDisplay_Target_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Focus_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_Focus_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Focus_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Focus_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Focus_ManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Focus_NameFrame_CPMeterTex, texturename);
		if (texturedbarbackground == 1) then
			Perl_Config_Set_Texture_Properties(Perl_Focus_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Focus_ManaBarBGTex, texturename);
		else
			Perl_Config_Set_Texture_Properties(Perl_Focus_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Focus_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Party_Frame) then
		for num=1,4 do
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_HealthBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar_HealthBarFadeBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_ManaBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar_ManaBarFadeBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_PetHealthBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar_PetHealthBarFadeBarTex"], texturename);
			if (texturedbarbackground == 1) then
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"], texturename);
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"], texturename);
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG_PetHealthBarBGTex"], texturename);
			else
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG_PetHealthBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			end
		end
	end

	if (Perl_Party_Pet_Script_Frame) then
		for num=1,4 do
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_HealthBar_HealthBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_HealthBarFadeBar_HealthBarFadeBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_ManaBar_ManaBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_ManaBarFadeBar_ManaBarFadeBarTex"], texturename);
			if (texturedbarbackground == 1) then
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"], texturename);
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"], texturename);
			else
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Pet"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			end
		end
	end

	if (Perl_Party_Target_Script_Frame) then
		for num=1,5 do
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_HealthBar_HealthBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_HealthBarFadeBar_HealthBarFadeBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_ManaBar_ManaBarTex"], texturename);
			Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_ManaBarFadeBar_ManaBarFadeBarTex"], texturename);
			if (texturedbarbackground == 1) then
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"], texturename);
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"], texturename);
			else
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				Perl_Config_Set_Texture_Properties(_G["Perl_Party_Target"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"], "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			end
		end
	end

	if (Perl_Player_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_Player_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_ManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_DruidBarTex, texturename);
		--Perl_Config_Set_Texture_Properties(Perl_Player_DruidBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_XPBarTex, texturename);
		if (texturedbarbackground == 1) then
			Perl_Config_Set_Texture_Properties(Perl_Player_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_ManaBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_DruidBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_XPBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_XPRestBarTex, texturename);
		else
			Perl_Config_Set_Texture_Properties(Perl_Player_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_DruidBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_XPBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_XPRestBarTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_ManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_XPBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_ManaBarFadeBarTex, texturename);
		if (texturedbarbackground == 1) then
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_ManaBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_XPBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_ManaBarBGTex, texturename);
		else
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_XPBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Player_Pet_Target_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Target_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_Target_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_ManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_NameFrame_CPMeterTex, texturename);
		if (texturedbarbackground == 1) then
			Perl_Config_Set_Texture_Properties(Perl_Target_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Target_ManaBarBGTex, texturename);
		else
			Perl_Config_Set_Texture_Properties(Perl_Target_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Target_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_ManaBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_HealthBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_HealthBarFadeBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_ManaBarTex, texturename);
		Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_ManaBarFadeBarTex, texturename);
		if (texturedbarbackground == 1) then
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_ManaBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_HealthBarBGTex, texturename);
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_ManaBarBGTex, texturename);
		else
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_HealthBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Config_Set_Texture_Properties(Perl_Target_Target_Target_ManaBarBGTex, "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end
end

function Perl_Config_Set_Texture_Properties(texture, texturename)
	texture:SetTexture(texturename);
	texture:SetHorizTile(false);
	texture:SetVertTile(false);
end

function Perl_Config_Set_Background(newvalue)
	if (newvalue ~= nil) then
		transparentbackground = newvalue;
		Perl_Config_UpdateVars();
	end

	if (transparentbackground == 1) then
		if (Perl_CombatDisplay_Frame) then
			Perl_CombatDisplay_ManaFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_CombatDisplay_Target_ManaFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_CombatDisplay_Initialize_Frame_Color();
		end

		if (Perl_Focus_Frame) then
			Perl_Focus_CivilianFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_ClassNameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_RareEliteFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_Initialize_Frame_Color();
		end

		if (Perl_Party_Frame) then
			for partynum=1,4 do
				_G["Perl_Party_MemberFrame"..partynum.."_NameFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_MemberFrame"..partynum.."_LevelFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_MemberFrame"..partynum.."_PortraitFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_MemberFrame"..partynum.."_StatsFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			end
			Perl_Party_Initialize_Frame_Color();
		end

		if (Perl_Party_Pet_Script_Frame) then
			for partynum=1,4 do
				_G["Perl_Party_Pet"..partynum.."_NameFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_Pet"..partynum.."_PortraitFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_Pet"..partynum.."_StatsFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			end
			Perl_Party_Pet_Initialize_Frame_Color();
		end

		if (Perl_Party_Target_Script_Frame) then
			for partynum=1,5 do
				_G["Perl_Party_Target"..partynum.."_NameFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_Target"..partynum.."_StatsFrame"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			end
			Perl_Party_Target_Initialize_Frame_Color();
		end

		if (Perl_Player_Frame) then
			Perl_Player_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_RaidGroupNumberFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Initialize_Frame_Color();
		end

		if (Perl_Player_Pet_Frame) then
			Perl_Player_Pet_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_Initialize_Frame_Color();
		end

		if (Perl_Target_Frame) then
			Perl_Target_GuildFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_ClassNameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_CPFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_RareEliteFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Initialize_Frame_Color();
		end

		if (Perl_Target_Target_Script_Frame) then
			Perl_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_Initialize_Frame_Color();
		end
	else
		if (Perl_CombatDisplay_Frame) then
			Perl_CombatDisplay_ManaFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_CombatDisplay_Target_ManaFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_CombatDisplay_Initialize_Frame_Color();
		end

		if (Perl_Focus_Frame) then
			Perl_Focus_CivilianFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_ClassNameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_RareEliteFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Focus_Initialize_Frame_Color();
		end

		if (Perl_Party_Frame) then
			for partynum=1,4 do
				_G["Perl_Party_MemberFrame"..partynum.."_NameFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_MemberFrame"..partynum.."_LevelFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_MemberFrame"..partynum.."_PortraitFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_MemberFrame"..partynum.."_StatsFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			end
			Perl_Party_Initialize_Frame_Color();
		end

		if (Perl_Party_Pet_Script_Frame) then
			for partynum=1,4 do
				_G["Perl_Party_Pet"..partynum.."_NameFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_Pet"..partynum.."_PortraitFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_Pet"..partynum.."_StatsFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			end
			Perl_Party_Pet_Initialize_Frame_Color();
		end

		if (Perl_Party_Target_Script_Frame) then
			for partynum=1,5 do
				_G["Perl_Party_Target"..partynum.."_NameFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
				_G["Perl_Party_Target"..partynum.."_StatsFrame"]:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			end
			Perl_Party_Target_Initialize_Frame_Color();
		end

		if (Perl_Player_Frame) then
			Perl_Player_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_RaidGroupNumberFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Initialize_Frame_Color();
		end

		if (Perl_Player_Pet_Frame) then
			Perl_Player_Pet_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Player_Pet_Initialize_Frame_Color();
		end

		if (Perl_Target_Frame) then
			Perl_Target_GuildFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_ClassNameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_CPFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_RareEliteFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Initialize_Frame_Color();
		end

		if (Perl_Target_Target_Script_Frame) then
			Perl_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }});
			Perl_Target_Target_Initialize_Frame_Color();
		end
	end
end

function Perl_Config_Set_Transparency(newvalue)
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_ArcaneBar_Set_Transparency(newvalue);
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Set_Transparency(newvalue);
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Set_Transparency(newvalue);
	end

	if (Perl_Party_Frame) then
		Perl_Party_Set_Transparency(newvalue);
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_Set_Transparency(newvalue);
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_Set_Transparency(newvalue);
	end

	if (Perl_Player_Frame) then
		Perl_Player_Set_Transparency(newvalue);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Set_Transparency(newvalue);
	end

	if (Perl_Target_Frame) then
		Perl_Target_Set_Transparency(newvalue);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Set_Transparency(newvalue);
	end
end

function Perl_Config_Set_MiniMap_Button(newvalue)
	showminimapbutton = newvalue;
	Perl_Config_UpdateVars();
	Perl_Config_ShowHide_MiniMap_Button();
end

function Perl_Config_Set_MiniMap_Position(newvalue)
	minimapbuttonpos = newvalue;
	Perl_Config_UpdateVars();
	Perl_Config_Button_UpdatePosition();
end

function Perl_Config_Set_MiniMap_Radius(newvalue)
	minimapbuttonrad = newvalue;
	Perl_Config_UpdateVars();
	Perl_Config_Button_UpdatePosition();
end

function Perl_Config_Set_CastParty_Support(newvalue)
	PCUF_CASTPARTYSUPPORT = newvalue;
	Perl_Config_UpdateVars();
end

function Perl_Config_Set_Color_Health(newvalue)
	PCUF_COLORHEALTH = newvalue;
	Perl_Config_UpdateVars();
end

function Perl_Config_Set_Textured_Bar_Background(newvalue)
	texturedbarbackground = newvalue;
	Perl_Config_UpdateVars();
	Perl_Config_Set_Texture();
end

function Perl_Config_Set_Fade_Bars(newvalue)
	PCUF_FADEBARS = newvalue;
	Perl_Config_UpdateVars();
end

function Perl_Config_Set_Name_Frame_Click_Cast(newvalue)
	PCUF_NAMEFRAMECLICKCAST = newvalue;
	Perl_Config_UpdateVars();
end

function Perl_Config_Set_Positioning_Mode(newvalue)
	positioningmode = newvalue;
	Perl_Config_UpdateVars();
	if (positioningmode == 1) then
		Perl_Config_PositioningMode_Enable();
	else
		Perl_Config_PositioningMode_Disable();
	end
end

function Perl_Config_Set_Invert_Bar_Values(newvalue)
	PCUF_INVERTBARVALUES = newvalue;
	Perl_Config_UpdateVars();

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Update_Health();
		Perl_CombatDisplay_Update_Mana();
		Perl_CombatDisplay_Update_Combo_Points();
		if (UnitExists("pet")) then
			Perl_CombatDisplay_Update_PetHealth();
			Perl_CombatDisplay_Update_PetMana();
		end
		if (UnitExists("target")) then
			Perl_CombatDisplay_Target_Update_Health();
			Perl_CombatDisplay_Target_Update_Mana();
		end
	end

	if (Perl_Focus_Frame) then
		if (UnitExists("focus")) then
			Perl_Focus_Update_Once();
		end
	end

	if (Perl_Party_Frame) then
		Perl_Party_Update_Health_Mana();
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_Update();
	end

	if (Perl_Player_Frame) then
		Perl_Player_Update_Health();
		Perl_Player_Update_Mana();
	end

	if (Perl_Player_Pet_Frame) then
		if (UnitExists("pet")) then
			Perl_Player_Pet_Update_Health();
			Perl_Player_Pet_Update_Mana();
		end
	end

	if (Perl_Target_Frame) then
		if (UnitExists("target")) then
			Perl_Target_Update_Once();
		end
	end
end

function Perl_Config_Set_Color_Frame_Debuff(newvalue)
	PCUF_COLORFRAMEDEBUFF = newvalue;
	Perl_Config_UpdateVars();

	-- Update the frame color on toggle if needed
	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Buff_UpdateAll("player", Perl_CombatDisplay_ManaFrame);
		Perl_CombatDisplay_Buff_UpdateAll("target", Perl_CombatDisplay_Target_ManaFrame);
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Buff_UpdateAll();
	end

	if (Perl_Party_Frame) then
		Perl_Party_Update_Buffs();
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_Buff_UpdateAll("partypet1");
		Perl_Party_Pet_Buff_UpdateAll("partypet2");
		Perl_Party_Pet_Buff_UpdateAll("partypet3");
		Perl_Party_Pet_Buff_UpdateAll("partypet4");
	end

	if (Perl_Player_Frame) then
		Perl_Player_BuffUpdateAll();
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Buff_UpdateAll();
	end

	if (Perl_Target_Frame) then
		Perl_Target_Buff_UpdateAll();
	end
end

function Perl_Config_Set_Threat_Icon(newvalue)
	PCUF_THREATICON = newvalue;
	Perl_Config_UpdateVars();

	if (Perl_Focus_Frame) then
		if (UnitExists("focus")) then
			Perl_Focus_Update_Threat();
		end
	end

	if (Perl_Party_Frame) then
		for id=1,4 do
			if (UnitExists(_G["Perl_Party_MemberFrame"..id])) then
				Perl_Party_Update_Threat(_G["Perl_Party_MemberFrame"..id]);
			end
		end
	end

	if (Perl_Player_Frame) then
		Perl_Player_Update_Threat();
	end

	if (Perl_Target_Frame) then
		if (UnitExists("target")) then
			Perl_Target_Update_Threat();
		end
	end
end

function Perl_Config_Lock_Unlock(value)
	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Set_Lock(value);
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Set_Lock(value);
	end

	if (Perl_Party_Frame) then
		Perl_Party_Set_Lock(value);
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_Set_Lock(value);
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_Set_Lock(value);
	end

	if (Perl_Player_Frame) then
		Perl_Player_Set_Lock(value);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Set_Lock(value);
	end

	if (Perl_Target_Frame) then
		Perl_Target_Set_Lock(value);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Set_Lock(value);
	end
end


-----------------------------------
-- Reset Frame Position Function --
-----------------------------------
function Perl_Config_Frame_Reset_Positions()
	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Frame:SetUserPlaced(true);
		Perl_CombatDisplay_Target_Frame:SetUserPlaced(true);
		Perl_CombatDisplay_Frame:ClearAllPoints();
		Perl_CombatDisplay_Target_Frame:ClearAllPoints();
		Perl_CombatDisplay_Frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 300);
		Perl_CombatDisplay_Target_Frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 350);
		Perl_CombatDisplay_Set_Frame_Position();
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Frame:SetUserPlaced(true);
		Perl_Focus_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -650);
		Perl_Focus_Set_Frame_Position();
	end

	if (Perl_Party_Frame) then
		local vartable = Perl_Party_GetVars();
		Perl_Party_Frame:SetUserPlaced(true);
		if (vartable["showportrait"] == 0) then
			Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -7, -187);
		else
			Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 55, -187);
		end
		Perl_Party_Set_Frame_Position();
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_Allign();
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_Allign();
	end

	if (Perl_Player_Frame) then
		local vartable = Perl_Player_GetVars();
		Perl_Player_Frame:SetUserPlaced(true);
		if (vartable["showportrait"] == 0) then
			Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2, -43);
		else
			Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 60, -43);
		end
		Perl_Player_Set_Frame_Position();
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Frame:SetUserPlaced(true);
		Perl_Player_Pet_Target_Frame:SetUserPlaced(true);
		if (Perl_Player_Frame) then
			local vartableone = Perl_Player_GetVars();
			local vartabletwo = Perl_Player_Pet_GetVars();
			if (vartableone["showportrait"] == 0 and vartabletwo["showportrait"] == 1) then
				Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 52, -117);
			else
				Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -117);
			end
		else
			Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -117);
		end
		Perl_Player_Pet_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Player_Pet_Frame:GetRight() - 2), -117);
		Perl_Player_Pet_Set_Frame_Position();
	end

	if (Perl_Target_Frame) then
		Perl_Target_Frame:SetUserPlaced(true);
		if (Perl_Player_Frame) then
			Perl_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Player_StatsFrame:GetRight() - 2), -43);
		else
			Perl_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 298, -43);
		end
		Perl_Target_Set_Frame_Position();
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Frame:SetUserPlaced(true);
		Perl_Target_Target_Target_Frame:SetUserPlaced(true);
		if (Perl_Target_Frame) then
			local vartable = Perl_Target_GetVars();
			if (vartable["showcp"] == 1) then
				if (vartable["showportrait"] == 1) then
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Target_PortraitFrame:GetRight() + 21), -43);
				else
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Target_LevelFrame:GetRight() + 21), -43);
				end
			else
				if (vartable["showportrait"] == 1) then
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Target_PortraitFrame:GetRight() - 2), -43);
				else
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Target_LevelFrame:GetRight() - 2), -43);
				end
			end
			Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (Perl_Target_Target_Frame:GetRight() - 2), -43);
		else
			Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 517, -43);
			Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 625, -43);
		end
		Perl_Target_Target_Set_Frame_Position();
	end
end


-------------------------------------
-- Global Saved Variable Functions --
-------------------------------------
function Perl_Config_Global_Save_Settings()
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		local vartable = Perl_ArcaneBar_GetVars();
		Perl_Config_Global_ArcaneBar_Config["Global Settings"] = {
			["PlayerEnabled"] = vartable["playerenabled"],
			["TargetEnabled"] = vartable["targetenabled"],
			["FocusEnabled"] = vartable["focusenabled"],
			["PartyEnabled"] = vartable["partyenabled"],
			["PlayerShowTimer"] = vartable["playershowtimer"],
			["TargetShowTimer"] = vartable["targetshowtimer"],
			["FocusShowTimer"] = vartable["focusshowtimer"],
			["PartyShowTimer"] = vartable["partyshowtimer"],
			["PlayerLeftTimer"] = vartable["playerlefttimer"],
			["TargetLeftTimer"] = vartable["targetlefttimer"],
			["FocusLeftTimer"] = vartable["focuslefttimer"],
			["PartyLeftTimer"] = vartable["partylefttimer"],
			["PlayerNameReplace"] = vartable["playernamereplace"],
			["TargetNameReplace"] = vartable["targetnamereplace"],
			["FocusNameReplace"] = vartable["focusnamereplace"],
			["PartyNameReplace"] = vartable["partynamereplace"],
			["HideOriginal"] = vartable["hideoriginal"],
			["Transparency"] = vartable["transparency"],
		};
	end

	if (Perl_CombatDisplay_Frame) then
		local vartable = Perl_CombatDisplay_GetVars();
		Perl_Config_Global_CombatDisplay_Config["Global Settings"] = {
			["State"] = vartable["state"],
			["Locked"] = vartable["locked"],
			["HealthPersist"] = vartable["healthpersist"],
			["ManaPersist"] = vartable["manapersist"],
			["Scale"] = vartable["scale"],
			["Transparency"] = vartable["transparency"],
			["ShowTarget"] = vartable["showtarget"],
			["ShowDruidBar"] = vartable["showdruidbar"],
			["ShowPetBars"] = vartable["showpetbars"],
			["RightClickMenu"] = vartable["rightclickmenu"],
			["DisplayPercents"] = vartable["displaypercents"],
			["ShowCP"] = vartable["showcp"],
			["ClickThrough"] = vartable["clickthrough"],
			["XPositionCD"] = vartable["xpositioncd"],
			["YPositionCD"] = vartable["ypositioncd"],
			["XPositionCDT"] = vartable["xpositioncdt"],
			["YPositionCDT"] = vartable["ypositioncdt"],
		};
	end

	if (Perl_Config_Script_Frame) then
		local vartable = Perl_Config_GetVars();
		Perl_Config_Global_Config_Config["Global Settings"] = {
			["Texture"] = vartable["texture"],
			["ShowMiniMapButton"] = vartable["showminimapbutton"],
			["MiniMapButtonPos"] = vartable["minimapbuttonpos"],
			["TransparentBackground"] = vartable["transparentbackground"],
			["PCUF_CastPartySupport"] = vartable["PCUF_CastPartySupport"],
			["PCUF_ColorHealth"] = vartable["PCUF_ColorHealth"],
			["TexturedBarBackround"] = vartable["texturedbarbackground"],
			["PCUF_FadeBars"] = vartable["PCUF_FadeBars"],
			["PCUF_InvertBarValues"] = vartable["PCUF_InvertBarValues"],
			["MiniMapButtonRad"] = vartable["minimapbuttonrad"],
			["PCUF_ColorFrameDebuff"] = vartable["PCUF_ColorFrameDebuff"],
			["PositioningMode"] = vartable["positioningmode"],
			["PCUF_ThreatIcon"] = vartable["PCUF_ThreatIcon"],
		};
	end

	if (Perl_Focus_Frame) then
		local vartable = Perl_Focus_GetVars();
		Perl_Config_Global_Focus_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["ClassIcon"] = vartable["showclassicon"],
			["ClassFrame"] = vartable["showclassframe"],
			["PvPIcon"] = vartable["showpvpicon"],
			["Buffs"] = vartable["numbuffsshown"],
			["Debuffs"] = vartable["numdebuffsshown"],
			["Scale"] = vartable["scale"],
			["Transparency"] = vartable["transparency"],
			["BuffDebuffScale"] = vartable["buffdebuffscale"],
			["ShowPortrait"] = vartable["showportrait"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["PortraitCombatText"] = vartable["portraitcombattext"],
			["ShowRareEliteFrame"] = vartable["showrareeliteframe"],
			["NameFrameComboPoints"] = vartable["nameframecombopoints"],
			["ComboFrameDebuffs"] = vartable["comboframedebuffs"],
			["FrameStyle"] = vartable["framestyle"],
			["CompactMode"] = vartable["compactmode"],
			["CompactPercent"] = vartable["compactpercent"],
			["HideBuffBackground"] = vartable["hidebuffbackground"],
			["ShortBars"] = vartable["shortbars"],
			["HealerMode"] = vartable["healermode"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["ShowManaDeficit"] = vartable["showmanadeficit"],
			["InvertBuffs"] = vartable["invertbuffs"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
			["DisplayBuffTimers"] = vartable["displaybufftimers"],
			["DisplayOnlyMyDebuffs"] = vartable["displayonlymydebuffs"],
			["XPosition"] = vartable["xposition"],
			["YPosition"] = vartable["yposition"],
		};
	end

	if (Perl_Party_Frame) then
		local vartable = Perl_Party_GetVars();
		Perl_Config_Global_Party_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["CompactMode"] = vartable["compactmode"],
			["PartyHidden"] = vartable["partyhidden"],
			["PartySpacing"] = vartable["partyspacing"],
			["Scale"] = vartable["scale"],
			["ShowPets"] = vartable["showpets"],
			["HealerMode"] = vartable["healermode"],
			["Transparency"] = vartable["transparency"],
			["BuffLocation"] = vartable["bufflocation"],
			["DebuffLocation"] = vartable["debufflocation"],
			["VerticalAlign"] = vartable["verticalalign"],
			["CompactPercent"] = vartable["compactpercent"],
			["ShowPortrait"] = vartable["showportrait"],
			["ShowFKeys"] = vartable["showfkeys"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["BuffSize"] = vartable["buffsize"],
			["DebuffSize"] = vartable["debuffsize"],
			["Buffs"] = vartable["numbuffsshown"],
			["Debuffs"] = vartable["numdebuffsshown"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["ShortBars"] = vartable["shortbars"],
			["HideClassLevelFrame"] = vartable["hideclasslevelframe"],
			["ShowManaDeficit"] = vartable["showmanadeficit"],
			["ShowPvPIcon"] = vartable["showpvpicon"],
			["ShowBarValues"] = vartable["showbarvalues"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
			["PortraitBuffs"] = vartable["portraitbuffs"],
			["DisplayBuffTimers"] = vartable["displaybufftimers"],
			["XPosition"] = vartable["xposition"],
			["YPosition"] = vartable["yposition"],
		};
	end

	if (Perl_Party_Pet_Script_Frame) then
		local vartable = Perl_Party_Pet_GetVars();
		Perl_Config_Global_Party_Pet_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["ShowPortrait"] = vartable["showportrait"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["Scale"] = vartable["scale"],
			["Transparency"] = vartable["transparency"],
			["Buffs"] = vartable["numpetbuffsshown"],
			["Debuffs"] = vartable["numpetdebuffsshown"],
			["BuffSize"] = vartable["buffsize"],
			["DebuffSize"] = vartable["debuffsize"],
			["BuffLocation"] = vartable["bufflocation"],
			["DebuffLocation"] = vartable["debufflocation"],
			["HiddenInRaids"] = vartable["hiddeninraids"],
			["Enabled"] = vartable["enabled"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
			["XPosition1"] = vartable["xposition1"],
			["YPosition1"] = vartable["yposition1"],
			["XPosition2"] = vartable["xposition2"],
			["YPosition2"] = vartable["yposition2"],
			["XPosition3"] = vartable["xposition3"],
			["YPosition3"] = vartable["yposition3"],
			["XPosition4"] = vartable["xposition4"],
			["YPosition4"] = vartable["yposition4"],
		};
	end

	if (Perl_Party_Target_Script_Frame) then
		local vartable = Perl_Party_Target_GetVars();
		Perl_Config_Global_Party_Target_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["Scale"] = vartable["scale"],
			["FocusScale"] = vartable["focusscale"],
			["Transparency"] = vartable["transparency"],
			["HidePowerBars"] = vartable["hidepowerbars"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["Enabled"] = vartable["enabled"],
			["PartyHiddenInRaid"] = vartable["partyhiddeninraid"],
			["EnabledFocus"] = vartable["enabledfocus"],
			["FocusHiddenInRaid"] = vartable["focushiddeninraid"],
			["XPosition1"] = vartable["xposition1"],
			["YPosition1"] = vartable["yposition1"],
			["XPosition2"] = vartable["xposition2"],
			["YPosition2"] = vartable["yposition2"],
			["XPosition3"] = vartable["xposition3"],
			["YPosition3"] = vartable["yposition3"],
			["XPosition4"] = vartable["xposition4"],
			["YPosition4"] = vartable["yposition4"],
			["XPosition5"] = vartable["xposition5"],
			["YPosition5"] = vartable["yposition5"],
		};
	end

	if (Perl_Player_Frame) then
		local vartable = Perl_Player_GetVars();
		Perl_Config_Global_Player_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["XPBarState"] = vartable["xpbarstate"],
			["CompactMode"] = vartable["compactmode"],
			["ShowRaidGroup"] = vartable["showraidgroup"],
			["Scale"] = vartable["scale"],
			["HealerMode"] = vartable["healermode"],
			["Transparency"] = vartable["transparency"],
			["ShowPortrait"] = vartable["showportrait"],
			["CompactPercent"] = vartable["compactpercent"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["PortraitCombatText"] = vartable["portraitcombattext"],
			["ShowDruidBar"] = vartable["showdruidbar"],
			["ShortBars"] = vartable["shortbars"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["HideClassLevelFrame"] = vartable["hideclasslevelframe"],
			["ShowManaDeficit"] = vartable["showmanadeficit"],
			["HiddenInRaid"] = vartable["hiddeninraid"],
			["ShowPvPIcon"] = vartable["showpvpicon"],
			["ShowBarValues"] = vartable["showbarvalues"],
			["ShowRaidGroupInName"] = vartable["showraidgroupinname"],
			["FiveSecondRule"] = vartable["fivesecondrule"],
			["TotemTimers"] = vartable["totemtimers"],
			["RuneFrame"] = vartable["runeframe"],
			["PvPTimer"] = vartable["pvptimer"],
			["PaladinPowerBar"] = vartable["paladinpowerbar"],
			["ShardBarFrame"] = vartable["shardbarframe"],
			["EclipseBarFrame"] = vartable["eclipsebarframe"],
			["HarmonyBarFrame"] = vartable["harmonybarframe"],
			["PriestBarFrame"] = vartable["priestbarframe"],
			["XPosition"] = vartable["xposition"],
			["YPosition"] = vartable["yposition"],
		};
	end

	if (Perl_Player_Buff_Script_Frame) then
		local vartable = Perl_Player_Buff_GetVars();
		Perl_Config_Global_Player_Buff_Config["Global Settings"] = {
			["BuffAlerts"] = vartable["buffalerts"],
			["ShowBuffs"] = vartable["showbuffs"],
			["Scale"] = vartable["scale"],
			["HideSeconds"] = vartable["hideseconds"],
			["HorizontalSpacing"] = vartable["horizontalspacing"],
		};
	end

	if (Perl_Player_Pet_Frame) then
		local vartable = Perl_Player_Pet_GetVars();
		Perl_Config_Global_Player_Pet_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["ShowXP"] = vartable["showxp"],
			["Scale"] = vartable["scale"],
			["TargetScale"] = vartable["targetscale"],
			["Buffs"] = vartable["numpetbuffsshown"],
			["Debuffs"] = vartable["numpetdebuffsshown"],
			["Transparency"] = vartable["transparency"],
			["BuffLocation"] = vartable["bufflocation"],
			["DebuffLocation"] = vartable["debufflocation"],
			["BuffSize"] = vartable["buffsize"],
			["DebuffSize"] = vartable["debuffsize"],
			["ShowPortrait"] = vartable["showportrait"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["PortraitCombatText"] = vartable["portraitcombattext"],
			["CompactMode"] = vartable["compactmode"],
			["HideName"] = vartable["hidename"],
			["DisplayPetTarget"] = vartable["displaypettarget"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["ShowFriendlyHealth"] = vartable["showfriendlyhealth"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
			["XPosition"] = vartable["xposition"],
			["YPosition"] = vartable["yposition"],
			["XPositionT"] = vartable["xpositiont"],
			["YPositionT"] = vartable["ypositiont"],
		};
	end

	if (Perl_Target_Frame) then
		local vartable = Perl_Target_GetVars();
		Perl_Config_Global_Target_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["ComboPoints"] = vartable["showcp"],
			["ClassIcon"] = vartable["showclassicon"],
			["ClassFrame"] = vartable["showclassframe"],
			["PvPIcon"] = vartable["showpvpicon"],
			["Buffs"] = vartable["numbuffsshown"],
			["Debuffs"] = vartable["numdebuffsshown"],
			["Scale"] = vartable["scale"],
			["Transparency"] = vartable["transparency"],
			["BuffDebuffScale"] = vartable["buffdebuffscale"],
			["ShowPortrait"] = vartable["showportrait"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["PortraitCombatText"] = vartable["portraitcombattext"],
			["ShowRareEliteFrame"] = vartable["showrareeliteframe"],
			["NameFrameComboPoints"] = vartable["nameframecombopoints"],
			["ComboFrameDebuffs"] = vartable["comboframedebuffs"],
			["FrameStyle"] = vartable["framestyle"],
			["CompactMode"] = vartable["compactmode"],
			["CompactPercent"] = vartable["compactpercent"],
			["HideBuffBackground"] = vartable["hidebuffbackground"],
			["ShortBars"] = vartable["shortbars"],
			["HealerMode"] = vartable["healermode"],
			["SoundTargetChange"] = vartable["soundtargetchange"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["ShowManaDeficit"] = vartable["showmanadeficit"],
			["InvertBuffs"] = vartable["invertbuffs"],
			["ShowGuildName"] = vartable["showguildname"],
			["EliteRareGraphic"] = vartable["eliteraregraphic"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
			["DisplayBuffTimers"] = vartable["displaybufftimers"],
			["DisplayNumbericThreat"] = vartable["displaynumbericthreat"],
			["DisplayOnlyMyDebuffs"] = vartable["displayonlymydebuffs"],
			["XPosition"] = vartable["xposition"],
			["YPosition"] = vartable["yposition"],
		};
	end

	if (Perl_Target_Target_Script_Frame) then
		local vartable = Perl_Target_Target_GetVars();
		Perl_Config_Global_Target_Target_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["Scale"] = vartable["scale"],
			["ToTSupport"] = vartable["totsupport"],
			["ToToTSupport"] = vartable["tototsupport"],
			["Transparency"] = vartable["transparency"],
			["AlertSound"] = vartable["alertsound"],
			["AlertMode"] = vartable["alertmode"],
			["AlertSize"] = vartable["alertsize"],
			["ShowToTBuffs"] = vartable["showtotbuffs"],
			["ShowToToTBuffs"] = vartable["showtototbuffs"],
			["HidePowerBars"] = vartable["hidepowerbars"],
			["ShowToTDebuffs"] = vartable["showtotdebuffs"],
			["ShowToToTDebuffs"] = vartable["showtototdebuffs"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["ShowFriendlyHealth"] = vartable["showfriendlyhealth"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
			["DisplayOnlyMyDebuffs"] = vartable["displayonlymydebuffs"],
			["XPositionToT"] = vartable["xpositiontot"],
			["YPositionToT"] = vartable["ypositiontot"],
			["XPositionToToT"] = vartable["xpositiontotot"],
			["YPositionToToT"] = vartable["ypositiontotot"],
		};
	end
end

function Perl_Config_Global_Load_Settings()
	-- Load all global settings from last save and then do window positions in this mod since we aren't saving the positions in each individual mod (and to keep all position changes in one file instead of six).
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_ArcaneBar_UpdateVars(Perl_Config_Global_ArcaneBar_Config);
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_UpdateVars(Perl_Config_Global_CombatDisplay_Config);
	end

	if (Perl_Config_Script_Frame) then
		Perl_Config_UpdateVars(Perl_Config_Global_Config_Config);
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_UpdateVars(Perl_Config_Global_Focus_Config);
	end

	if (Perl_Party_Frame) then
		Perl_Party_UpdateVars(Perl_Config_Global_Party_Config);
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_UpdateVars(Perl_Config_Global_Party_Pet_Config);
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_UpdateVars(Perl_Config_Global_Party_Target_Config);
	end

	if (Perl_Player_Frame) then
		Perl_Player_UpdateVars(Perl_Config_Global_Player_Config);
	end

	if (Perl_Player_Buff_Script_Frame) then
		Perl_Player_Buff_UpdateVars(Perl_Config_Global_Player_Buff_Config);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_UpdateVars(Perl_Config_Global_Player_Pet_Config);
	end

	if (Perl_Target_Frame) then
		Perl_Target_UpdateVars(Perl_Config_Global_Target_Config);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_UpdateVars(Perl_Config_Global_Target_Target_Config);
	end
end

------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Config_GetVars(index, updateflag)
	if (index == nil) then
		index = GetRealmName("player").."-"..UnitName("player");
	end

	texture = Perl_Config_Config[index]["Texture"];
	showminimapbutton = Perl_Config_Config[index]["ShowMiniMapButton"];
	minimapbuttonpos = Perl_Config_Config[index]["MiniMapButtonPos"];
	transparentbackground = Perl_Config_Config[index]["TransparentBackground"];
	PCUF_CASTPARTYSUPPORT = Perl_Config_Config[index]["PCUF_CastPartySupport"];
	PCUF_COLORHEALTH = Perl_Config_Config[index]["PCUF_ColorHealth"];
	texturedbarbackground = Perl_Config_Config[index]["TexturedBarBackround"];
	PCUF_FADEBARS = Perl_Config_Config[index]["PCUF_FadeBars"];
	PCUF_NAMEFRAMECLICKCAST = Perl_Config_Config[index]["PCUF_NameFrameClickCast"];
	PCUF_INVERTBARVALUES = Perl_Config_Config[index]["PCUF_InvertBarValues"];
	minimapbuttonrad = Perl_Config_Config[index]["MiniMapButtonRad"];
	PCUF_COLORFRAMEDEBUFF = Perl_Config_Config[index]["PCUF_ColorFrameDebuff"];
	positioningmode = Perl_Config_Config[index]["PositioningMode"];
	PCUF_THREATICON = Perl_Config_Config[index]["PCUF_ThreatIcon"];

	if (texture == nil) then
		texture = 0;
	end
	if (showminimapbutton == nil) then
		showminimapbutton = 1;
	end
	if (minimapbuttonpos == nil) then
		minimapbuttonpos = 300;
	end
	if (transparentbackground == nil) then
		transparentbackground = 0;
	end
	if (PCUF_CASTPARTYSUPPORT == nil) then
		PCUF_CASTPARTYSUPPORT = 0;
	end
	if (PCUF_COLORHEALTH == nil) then
		PCUF_COLORHEALTH = 0;
	end
	if (texturedbarbackground == nil) then
		texturedbarbackground = 0;
	end
	if (PCUF_FADEBARS == nil) then
		PCUF_FADEBARS = 0;
	end
	if (PCUF_NAMEFRAMECLICKCAST == nil) then
		PCUF_NAMEFRAMECLICKCAST = 0;
	end
	if (PCUF_INVERTBARVALUES == nil) then
		PCUF_INVERTBARVALUES = 0;
	end
	if (minimapbuttonrad == nil) then
		minimapbuttonrad = 80;
	end
	if (PCUF_COLORFRAMEDEBUFF == nil) then
		PCUF_COLORFRAMEDEBUFF = 1;
	end
	if (positioningmode == nil) then
		positioningmode = 0;
	end
	if (PCUF_THREATICON == nil) then
		PCUF_THREATICON = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Config_UpdateVars();

		-- Call any code we need to activate them
		Perl_Config_Set_Texture(texture);
		Perl_Config_Set_MiniMap_Button(showminimapbutton);
		Perl_Config_Set_MiniMap_Position(minimapbuttonpos);
		Perl_Config_Set_Background();
		return;
	end

	local vars = {
		["texture"] = texture,
		["showminimapbutton"] = showminimapbutton,
		["minimapbuttonpos"] = minimapbuttonpos,
		["transparentbackground"] = transparentbackground,
		["PCUF_CastPartySupport"] = PCUF_CASTPARTYSUPPORT,
		["PCUF_ColorHealth"] = PCUF_COLORHEALTH,
		["texturedbarbackground"] = texturedbarbackground,
		["PCUF_FadeBars"] = PCUF_FADEBARS,
		["PCUF_NameFrameClickCast"] = PCUF_NAMEFRAMECLICKCAST,
		["PCUF_InvertBarValues"] = PCUF_INVERTBARVALUES,
		["minimapbuttonrad"] = minimapbuttonrad,
		["PCUF_ColorFrameDebuff"] = PCUF_COLORFRAMEDEBUFF,
		["positioningmode"] = positioningmode,
		["PCUF_ThreatIcon"] = PCUF_THREATICON,
	}
	return vars;
end

function Perl_Config_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Texture"] ~= nil) then
				texture = vartable["Global Settings"]["Texture"];
			else
				texture = nil;
			end
			if (vartable["Global Settings"]["ShowMiniMapButton"] ~= nil) then
				showminimapbutton = vartable["Global Settings"]["ShowMiniMapButton"];
			else
				showminimapbutton = nil;
			end
			if (vartable["Global Settings"]["MiniMapButtonPos"] ~= nil) then
				minimapbuttonpos = vartable["Global Settings"]["MiniMapButtonPos"];
			else
				minimapbuttonpos = nil;
			end
			if (vartable["Global Settings"]["TransparentBackground"] ~= nil) then
				transparentbackground = vartable["Global Settings"]["TransparentBackground"];
			else
				transparentbackground = nil;
			end
			if (vartable["Global Settings"]["PCUF_CastPartySupport"] ~= nil) then
				PCUF_CASTPARTYSUPPORT = vartable["Global Settings"]["PCUF_CastPartySupport"];
			else
				PCUF_CASTPARTYSUPPORT = nil;
			end
			if (vartable["Global Settings"]["PCUF_ColorHealth"] ~= nil) then
				PCUF_COLORHEALTH = vartable["Global Settings"]["PCUF_ColorHealth"];
			else
				PCUF_COLORHEALTH = nil;
			end
			if (vartable["Global Settings"]["TexturedBarBackround"] ~= nil) then
				texturedbarbackground = vartable["Global Settings"]["TexturedBarBackround"];
			else
				texturedbarbackground = nil;
			end
			if (vartable["Global Settings"]["PCUF_FadeBars"] ~= nil) then
				PCUF_FADEBARS = vartable["Global Settings"]["PCUF_FadeBars"];
			else
				PCUF_FADEBARS = nil;
			end
			if (vartable["Global Settings"]["PCUF_NameFrameClickCast"] ~= nil) then
				PCUF_NAMEFRAMECLICKCAST = vartable["Global Settings"]["PCUF_NameFrameClickCast"];
			else
				PCUF_NAMEFRAMECLICKCAST = nil;
			end
			if (vartable["Global Settings"]["PCUF_InvertBarValues"] ~= nil) then
				PCUF_INVERTBARVALUES = vartable["Global Settings"]["PCUF_InvertBarValues"];
			else
				PCUF_INVERTBARVALUES = nil;
			end
			if (vartable["Global Settings"]["MiniMapButtonRad"] ~= nil) then
				minimapbuttonrad = vartable["Global Settings"]["MiniMapButtonRad"];
			else
				minimapbuttonrad = nil;
			end
			if (vartable["Global Settings"]["PCUF_ColorFrameDebuff"] ~= nil) then
				PCUF_COLORFRAMEDEBUFF = vartable["Global Settings"]["PCUF_ColorFrameDebuff"];
			else
				PCUF_COLORFRAMEDEBUFF = nil;
			end
			if (vartable["Global Settings"]["PositioningMode"] ~= nil) then
				positioningmode = vartable["Global Settings"]["PositioningMode"];
			else
				positioningmode = nil;
			end
			if (vartable["Global Settings"]["PCUF_ThreatIcon"] ~= nil) then
				PCUF_THREATICON = vartable["Global Settings"]["PCUF_ThreatIcon"];
			else
				PCUF_THREATICON = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (texture == nil) then
			texture = 0;
		end
		if (showminimapbutton == nil) then
			showminimapbutton = 1;
		end
		if (minimapbuttonpos == nil) then
			minimapbuttonpos = 300;
		end
		if (transparentbackground == nil) then
			transparentbackground = 0;
		end
		if (PCUF_CASTPARTYSUPPORT == nil) then
			PCUF_CASTPARTYSUPPORT = 0;
		end
		if (PCUF_COLORHEALTH == nil) then
			PCUF_COLORHEALTH = 0;
		end
		if (texturedbarbackground == nil) then
			texturedbarbackground = 0;
		end
		if (PCUF_FADEBARS == nil) then
			PCUF_FADEBARS = 0;
		end
		if (PCUF_NAMEFRAMECLICKCAST == nil) then
			PCUF_NAMEFRAMECLICKCAST = 0;
		end
		if (PCUF_INVERTBARVALUES == nil) then
			PCUF_INVERTBARVALUES = 0;
		end
		if (minimapbuttonrad == nil) then
			minimapbuttonrad = 80;
		end
		if (PCUF_COLORFRAMEDEBUFF == nil) then
			PCUF_COLORFRAMEDEBUFF = 1;
		end
		if (positioningmode == nil) then
			positioningmode = 0;
		end
		if (PCUF_THREATICON == nil) then
			PCUF_THREATICON = 0;
		end

		-- Call any code we need to activate them
		Perl_Config_Set_Texture(texture);
		Perl_Config_Set_MiniMap_Button(showminimapbutton);
		Perl_Config_Set_MiniMap_Position(minimapbuttonpos);
		Perl_Config_Set_Background();
	end

	Perl_Config_Config[GetRealmName("player").."-"..UnitName("player")] = {
		["Texture"] = texture,
		["ShowMiniMapButton"] = showminimapbutton,
		["MiniMapButtonPos"] = minimapbuttonpos,
		["TransparentBackground"] = transparentbackground,
		["PCUF_CastPartySupport"] = PCUF_CASTPARTYSUPPORT,
		["PCUF_ColorHealth"] = PCUF_COLORHEALTH,
		["TexturedBarBackround"] = texturedbarbackground,
		["PCUF_FadeBars"] = PCUF_FADEBARS,
		["PCUF_NameFrameClickCast"] = PCUF_NAMEFRAMECLICKCAST,
		["PCUF_InvertBarValues"] = PCUF_INVERTBARVALUES,
		["MiniMapButtonRad"] = minimapbuttonrad,
		["PCUF_ColorFrameDebuff"] = PCUF_COLORFRAMEDEBUFF,
		["PositioningMode"] = positioningmode,
		["PCUF_ThreatIcon"] = PCUF_THREATICON,
	};
end


-------------------------
-- The Toggle Function --
-------------------------
function Perl_Config_Toggle()
	if (InCombatLockdown()) then
		DEFAULT_CHAT_FRAME:AddMessage(PERL_LOCALIZED_CONFIG_OPTIONS_UNAVAILABLE);
	else
		local loaded, reason = LoadAddOn("Perl_Config_Options");

		if (loaded) then
			if (Perl_Config_Frame:IsVisible()) then
				Perl_Config_Frame:Hide();
				Perl_Config_Hide_All();
			else
				Perl_Config_Frame:ClearAllPoints();
				Perl_Config_Frame:SetPoint("CENTER", 0, 0);
				Perl_Config_Frame:Show();
				Perl_Config_Hide_All();
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Config: The options menu failed to load because: "..reason);
		end
	end
end

function Perl_Config_Hide_All()
	Perl_Config_All_Frame:Hide();
	Perl_Config_ArcaneBar_Frame:Hide();
	Perl_Config_CombatDisplay_Frame:Hide();
	Perl_Config_Focus_Frame:Hide();
	Perl_Config_NotInstalled_Frame:Hide();
	Perl_Config_Party_Frame:Hide();
	Perl_Config_Party_Pet_Frame:Hide();
	Perl_Config_Party_Target_Frame:Hide();
	Perl_Config_Player_Frame:Hide();
	Perl_Config_Player_Buff_Frame:Hide();
	Perl_Config_Player_Pet_Frame:Hide();
	Perl_Config_Target_Frame:Hide();
	Perl_Config_Target_Target_Frame:Hide();
end

function Perl_Config_ShowHide_MiniMap_Button()
	if (showminimapbutton == 0) then
		Perl_Config_ButtonFrame:Hide();
	else
		Perl_Config_ButtonFrame:Show();
	end
end


---------------------------
-- The Minimap Functions --
---------------------------
function Perl_Config_Button_OnClick(self, button)
	if (button == "LeftButton") then
		Perl_Config_Toggle();
	elseif (button == "RightButton") then
		local unlockedflag = 0;

		if (Perl_CombatDisplay_Frame) then
			if (Perl_CombatDisplay_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Focus_Frame) then
			if (Perl_Focus_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Party_Frame) then
			if (Perl_Party_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Party_Pet_Script_Frame) then
			if (Perl_Party_Pet_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Party_Target_Script_Frame) then
			if (Perl_Party_Target_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Player_Frame) then
			if (Perl_Player_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Player_Pet_Frame) then
			if (Perl_Player_Pet_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Target_Frame) then
			if (Perl_Target_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Target_Target_Script_Frame) then
			if (Perl_Target_Target_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (unlockedflag == 1) then
			Perl_Config_Lock_Unlock(1);
		else
			Perl_Config_Lock_Unlock(0);
		end

		GameTooltip:Hide();
		Perl_Config_Button_Tooltip(self);
	end
end

function Perl_Config_Button_Tooltip(self)
	local unlockedflag = 0;

	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetText("Perl Classic Options");

	if (Perl_CombatDisplay_Frame) then
		if (type(Perl_CombatDisplay_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_CombatDisplay_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_CombatDisplay is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_CombatDisplay is locked");
			end
		else
			Perl_CombatDisplay_UpdateVars();
			GameTooltip:AddLine("Perl_CombatDisplay could not verify its status.");
		end
	end

	if (Perl_Focus_Frame) then
		if (type(Perl_Focus_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Focus_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Focus is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Focus is locked");
			end
		else
			Perl_Focus_UpdateVars();
			GameTooltip:AddLine("Perl_Focus could not verify its status.");
		end
	end

	if (Perl_Party_Frame) then
		if (type(Perl_Party_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Party_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Party is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Party is locked");
			end
		else
			Perl_Party_UpdateVars();
			GameTooltip:AddLine("Perl_Party could not verify its status.");
		end
	end

	if (Perl_Party_Pet_Script_Frame) then
		if (type(Perl_Party_Pet_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Party_Pet_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Party_Pet is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Party_Pet is locked");
			end
		else
			Perl_Party_Pet_UpdateVars();
			GameTooltip:AddLine("Perl_Party_Pet could not verify its status.");
		end
	end

	if (Perl_Party_Target_Script_Frame) then
		if (type(Perl_Party_Target_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Party_Target_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Party_Target is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Party_Target is locked");
			end
		else
			Perl_Party_Target_UpdateVars();
			GameTooltip:AddLine("Perl_Party_Target could not verify its status.");
		end
	end

	if (Perl_Player_Frame) then
		if (type(Perl_Player_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Player_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Player is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Player is locked");
			end
		else
			Perl_Player_UpdateVars();
			GameTooltip:AddLine("Perl_Player could not verify its status.");
		end
	end

	if (Perl_Player_Pet_Frame) then
		if (type(Perl_Player_Pet_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Player_Pet_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Player_Pet is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Player_Pet is locked");
			end
		else
			Perl_Player_Pet_UpdateVars();
			GameTooltip:AddLine("Perl_Player_Pet could not verify its status.");
		end
	end

	if (Perl_Target_Frame) then
		if (type(Perl_Target_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Target_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Target is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Target is locked");
			end
		else
			Perl_Target_UpdateVars();
			GameTooltip:AddLine("Perl_Target could not verify its status.");
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		if (type(Perl_Target_Target_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
			if (Perl_Target_Target_Config[GetRealmName("player").."-"..UnitName("player")]["Locked"] == 0) then
				GameTooltip:AddLine("Perl_Target_Target is unlocked");
				unlockedflag = 1;
			else
				GameTooltip:AddLine("Perl_Target_Target is locked");
			end
		else
			Perl_Target_Target_UpdateVars();
			GameTooltip:AddLine("Perl_Target_Target could not verify its status.");
		end
	end

	GameTooltip:AddLine(" ");

	if (unlockedflag == 1) then
		GameTooltip:AddLine(PERL_LOCALIZED_CONFIG_MINIMAP_LOCK);
	else
		GameTooltip:AddLine(PERL_LOCALIZED_CONFIG_MINIMAP_UNLOCK);
	end

	GameTooltip:Show();
end

function Perl_Config_Button_UpdatePosition()
	Perl_Config_ButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		52 - (minimapbuttonrad * cos(minimapbuttonpos)),
		(minimapbuttonrad * sin(minimapbuttonpos)) - 52
	);
end


---------------------------
-- Combat Text Functions --
---------------------------
PERL_COMBATFEEDBACK_FADEINTIME = 0.2;
PERL_COMBATFEEDBACK_HOLDTIME = 0.7;
PERL_COMBATFEEDBACK_FADEOUTTIME = 0.3;

PERL_SCHOOL_MASK_NONE		= 0x00;
PERL_SCHOOL_MASK_PHYSICAL	= 0x01;
PERL_SCHOOL_MASK_HOLY		= 0x02;
PERL_SCHOOL_MASK_FIRE		= 0x04;
PERL_SCHOOL_MASK_NATURE		= 0x08;
PERL_SCHOOL_MASK_FROST		= 0x10;
PERL_SCHOOL_MASK_SHADOW		= 0x20;
PERL_SCHOOL_MASK_ARCANE		= 0x40;

Perl_CombatFeedbackText = { };
Perl_CombatFeedbackText["INTERRUPT"]	= INTERRUPT;
Perl_CombatFeedbackText["MISS"]			= MISS;
Perl_CombatFeedbackText["RESIST"]		= RESIST;
Perl_CombatFeedbackText["DODGE"]		= DODGE;
Perl_CombatFeedbackText["PARRY"]		= PARRY;
Perl_CombatFeedbackText["BLOCK"]		= BLOCK;
Perl_CombatFeedbackText["EVADE"]		= EVADE;
Perl_CombatFeedbackText["IMMUNE"]		= IMMUNE;
Perl_CombatFeedbackText["DEFLECT"]		= DEFLECT;
Perl_CombatFeedbackText["ABSORB"]		= ABSORB;
Perl_CombatFeedbackText["REFLECT"]		= REFLECT;

function Perl_CombatFeedback_Initialize(self, feedbackText, fontHeight)
	self.feedbackText = feedbackText;
	self.feedbackFontHeight = fontHeight;
end

function Perl_CombatFeedback_OnCombatEvent(self, event, flags, amount, type)
	local feedbackText = self.feedbackText;
	local fontHeight = self.feedbackFontHeight;
	local text = "";
	local r = 1.0;
	local g = 1.0;
	local b = 1.0;

	if( event == "IMMUNE" ) then
		fontHeight = fontHeight * 0.5;
		text = Perl_CombatFeedbackText[event];
	elseif ( event == "WOUND" ) then
		if ( amount ~= 0 ) then
			if ( flags == "CRITICAL" or flags == "CRUSHING" ) then
				fontHeight = fontHeight * 1.5;
			elseif ( flags == "GLANCING" ) then
				fontHeight = fontHeight * 0.75;
			end
			if ( type ~= PERL_SCHOOL_MASK_PHYSICAL ) then
				r = 1.0;
				g = 1.0;
				b = 0.0;
			end
			text = Perl_BreakUpLargeNumbers(amount);
		elseif ( flags == "ABSORB" ) then
			fontHeight = fontHeight * 0.75;
			text = Perl_CombatFeedbackText["ABSORB"];
		elseif ( flags == "BLOCK" ) then
			fontHeight = fontHeight * 0.75;
			text = Perl_CombatFeedbackText["BLOCK"];
		elseif ( flags == "RESIST" ) then
			fontHeight = fontHeight * 0.75;
			text = Perl_CombatFeedbackText["RESIST"];
		else
			text = Perl_CombatFeedbackText["MISS"];
		end
	elseif ( event == "BLOCK" ) then
		fontHeight = fontHeight * 0.75;
		text = Perl_CombatFeedbackText[event];
	elseif ( event == "HEAL" ) then
		text = Perl_BreakUpLargeNumbers(amount);
		r = 0.0;
		g = 1.0;
		b = 0.0;
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.5;
		end
	elseif ( event == "ENERGIZE" ) then
		text = Perl_BreakUpLargeNumbers(amount);
		r = 0.41;
		g = 0.8;
		b = 0.94;
		if ( flags == "CRITICAL" ) then
			fontHeight = fontHeight * 1.5;
		end
	else
		text = Perl_CombatFeedbackText[event];
	end

	self.feedbackStartTime = GetTime();

	feedbackText:SetTextHeight(fontHeight);
	feedbackText:SetText(text);
	feedbackText:SetTextColor(r, g, b);
	feedbackText:SetAlpha(0.0);
	feedbackText:Show();
end

function Perl_CombatFeedback_OnUpdate(self, elapsed)
	local feedbackText = self.feedbackText;
	if ( feedbackText:IsVisible() ) then
		local elapsedTime = GetTime() - self.feedbackStartTime;
		local fadeInTime = PERL_COMBATFEEDBACK_FADEINTIME;
		if ( elapsedTime < fadeInTime ) then
			local alpha = (elapsedTime / fadeInTime);
			feedbackText:SetAlpha(alpha);
			return;
		end
		local holdTime = PERL_COMBATFEEDBACK_HOLDTIME;
		if ( elapsedTime < (fadeInTime + holdTime) ) then
			feedbackText:SetAlpha(1.0);
			return;
		end
		local fadeOutTime = PERL_COMBATFEEDBACK_FADEOUTTIME;
		if ( elapsedTime < (fadeInTime + holdTime + fadeOutTime) ) then
			local alpha = 1.0 - ((elapsedTime - holdTime - fadeInTime) / fadeOutTime);
			feedbackText:SetAlpha(alpha);
			return;
		end
		feedbackText:Hide();
	end
end

function Perl_BreakUpLargeNumbers(value)
	local retString = "";
	if ( value < 1000 ) then
		if ( (value - math.floor(value)) == 0) then
			return value;
		end
		local decimal = (math.floor(value*100));
		retString = string.sub(decimal, 1, -3);
		retString = retString..".";
		retString = retString..string.sub(decimal, -2);
		return retString;
	end

	value = math.floor(value);
	local strLen = strlen(value);
	if ( GetCVarBool("breakUpLargeNumbers") ) then
		if ( strLen > 6 ) then
			retString = string.sub(value, 1, -7)..",";
		end
		if ( strLen > 3 ) then
			retString = retString..string.sub(value, -6, -4)..",";
		end
		retString = retString..string.sub(value, -3, -1);
	else
		retString = value;
	end
	return retString;
end


-------------------------------------
-- Localizing some Blizzard Arrays --
-------------------------------------
PERL_CLASS_ICON_TCOORDS = {
	["WARRIOR"]		= {0, 0.25, 0, 0.25},
	["MAGE"]		= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]		= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]		= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]		= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	 	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]		= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]		= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]		= {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, .5, 0.5, .75},
	["MONK"]		= {0.5, 0.73828125, 0.5, .75},
	["DEMONHUNTER"]	= {0.7421875, 0.98828125, 0.5, 0.75},
};

PERL_FACTION_BAR_COLORS = {
	[1] = {r = 0.8, g = 0.3, b = 0.22},
	[2] = {r = 0.8, g = 0.3, b = 0.22},
	[3] = {r = 0.75, g = 0.27, b = 0},
	[4] = {r = 0.9, g = 0.7, b = 0},
	[5] = {r = 0, g = 0.6, b = 0.1},
	[6] = {r = 0, g = 0.6, b = 0.1},
	[7] = {r = 0, g = 0.6, b = 0.1},
	[8] = {r = 0, g = 0.6, b = 0.1},
};

PERL_RAID_CLASS_COLORS = {
	["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["WARLOCK"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
	["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["MAGE"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
	["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23, colorStr = "ffc41f3b" },
	["MONK"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "ff00ff96" },
	["DEMONHUNTER"] = { r = 0.64, g = 0.19, b = 0.79, colorStr = "ffa330c9" },
};

PERL_POWER_TYPE_COLORS = {
	["MANA"] = { r = 0.00, g = 0.00, b = 1.00 },
	["RAGE"] = { r = 1.00, g = 0.00, b = 0.00 },
	["FOCUS"] = { r = 1.00, g = 0.50, b = 0.25 },
	["ENERGY"] = { r = 1.00, g = 1.00, b = 0.00 },
	["COMBO_POINTS"] = { r = 1.00, g = 0.96, b = 0.41 },
	["RUNES"] = { r = 0.50, g = 0.50, b = 0.50 },
	["RUNIC_POWER"] = { r = 0.00, g = 0.82, b = 1.00 },
	["SOUL_SHARDS"] = { r = 0.50, g = 0.32, b = 0.55 },
	["LUNAR_POWER"] = { r = 0.30, g = 0.52, b = 0.90 },
	["HOLY_POWER"] = { r = 0.95, g = 0.90, b = 0.60 },
	["MAELSTROM"] = { r = 0.00, g = 0.50, b = 1.00 },
	["INSANITY"] = { r = 0.40, g = 0, b = 0.80 },
	["CHI"] = { r = 0.71, g = 1.0, b = 0.92 },
	["ARCANE_CHARGES"] = { r = 0.1, g = 0.1, b = 0.98 },
	["FURY"] = { r = 0.788, g = 0.259, b = 0.992 },
	["PAIN"] = { r = 1, g = 0, b = 0 },
}

PERL_POWER_TYPE_COLORS[0] = PERL_POWER_TYPE_COLORS["MANA"];
PERL_POWER_TYPE_COLORS[1] = PERL_POWER_TYPE_COLORS["RAGE"];
PERL_POWER_TYPE_COLORS[2] = PERL_POWER_TYPE_COLORS["FOCUS"];
PERL_POWER_TYPE_COLORS[3] = PERL_POWER_TYPE_COLORS["ENERGY"];
PERL_POWER_TYPE_COLORS[4] = PERL_POWER_TYPE_COLORS["CHI"];
PERL_POWER_TYPE_COLORS[5] = PERL_POWER_TYPE_COLORS["RUNES"];
PERL_POWER_TYPE_COLORS[6] = PERL_POWER_TYPE_COLORS["RUNIC_POWER"];
PERL_POWER_TYPE_COLORS[7] = PERL_POWER_TYPE_COLORS["SOUL_SHARDS"];
PERL_POWER_TYPE_COLORS[8] = PERL_POWER_TYPE_COLORS["LUNAR_POWER"];
PERL_POWER_TYPE_COLORS[9] = PERL_POWER_TYPE_COLORS["HOLY_POWER"];
PERL_POWER_TYPE_COLORS[11] = PERL_POWER_TYPE_COLORS["MAELSTROM"];
PERL_POWER_TYPE_COLORS[13] = PERL_POWER_TYPE_COLORS["INSANITY"];
PERL_POWER_TYPE_COLORS[17] = PERL_POWER_TYPE_COLORS["FURY"];
PERL_POWER_TYPE_COLORS[18] = PERL_POWER_TYPE_COLORS["PAIN"];

PerlDebuffTypeColor = { };
PerlDebuffTypeColor["none"]	= { r = 0.80, g = 0, b = 0 };
PerlDebuffTypeColor["Magic"]	= { r = 0.20, g = 0.60, b = 1.00 };
PerlDebuffTypeColor["Curse"]	= { r = 0.60, g = 0.00, b = 1.00 };
PerlDebuffTypeColor["Disease"]	= { r = 0.60, g = 0.40, b = 0 };
PerlDebuffTypeColor["Poison"]	= { r = 0.00, g = 0.60, b = 0 };
PerlDebuffTypeColor[""]	= PerlDebuffTypeColor["none"];


----------------------------------------
-- Localizing some Blizzard Functions --
----------------------------------------
function PerlSetRaidTargetIconTexture(texture, raidTargetIconIndex)
	local PERL_RAID_TARGET_ICON_DIMENSION = 64;
	local PERL_RAID_TARGET_TEXTURE_DIMENSION = 256;
	local PERL_RAID_TARGET_TEXTURE_COLUMNS = 4;
	local PERL_RAID_TARGET_TEXTURE_ROWS = 4;

	raidTargetIconIndex = raidTargetIconIndex - 1;
	local left, right, top, bottom;
	local coordIncrement = PERL_RAID_TARGET_ICON_DIMENSION / PERL_RAID_TARGET_TEXTURE_DIMENSION;
	left = mod(raidTargetIconIndex , PERL_RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
	right = left + coordIncrement;
	top = floor(raidTargetIconIndex / PERL_RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
	bottom = top + coordIncrement;
	texture:SetTexCoord(left, right, top, bottom);
end

function Perl_CooldownFrame_SetTimer(self, start, duration, enable, charges, maxCharges)
	if(enable and enable ~= 0) then
		self:SetCooldown(start, duration, charges, maxCharges);
	else
		self:SetCooldown(0, 0, charges, maxCharges);
	end
end


--------------------------------------
-- Disable Blizzard Frame Functions --
--------------------------------------
function Perl_clearBlizzardFrameDisable(frameObject)
	frameObject:UnregisterAllEvents();
	frameObject:SetScript("OnEvent", nil);
	frameObject:SetScript("OnShow", nil);
	frameObject:SetScript("OnUpdate", nil);
	if (not InCombatLockdown()) then
		frameObject:ClearAllPoints();
		frameObject:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 1000, -1000);
		frameObject:Hide();
	end
end

function Perl_clearBlizzardFocusFrameDisable()
	Perl_clearBlizzardFrameDisable(FocusFrame);
end
