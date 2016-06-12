---------------
-- Variables --
---------------
Perl_Config_Config = {};

Perl_Config_Global_ArcaneBar_Config = {};
Perl_Config_Global_CombatDisplay_Config = {};
Perl_Config_Global_Config_Config = {};
Perl_Config_Global_Party_Config = {};
Perl_Config_Global_Player_Config = {};
Perl_Config_Global_Player_Buff_Config = {};
Perl_Config_Global_Player_Pet_Config = {};
Perl_Config_Global_Target_Config = {};
Perl_Config_Global_Target_Target_Config = {};

-- Default Saved Variables (also set in Perl_Config_GetVars)
local texture = 0;			-- no texture is set by default
local showminimapbutton = 1;		-- minimap button is on by default
local minimapbuttonpos = 270;		-- default minimap button position
local transparentbackground = 0;	-- use solid black background as default


----------------------
-- Loading Function --
----------------------
function Perl_Config_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Slash Commands
	SlashCmdList["PERL_CONFIG"] = Perl_Config_SlashHandler;
	SLASH_PERL_CONFIG1 = "/perl";

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Classic: Config loaded successfully.");
	end
end


-------------------
-- Event Handler --
-------------------
function Perl_Config_OnEvent(event)
	if (event == "ADDON_LOADED") then
		if (arg1 == "Perl_Config") then
			Perl_Config_myAddOns_Support();
		end
		return;
	elseif (event=="PLAYER_ENTERING_WORLD") then
		Perl_Config_Set_Texture();
		Perl_Config_Button_UpdatePosition();
		Perl_Config_ShowHide_MiniMap_Button();
		Perl_Config_Set_Background();
	elseif (event == "VARIABLES_LOADED") then
		Perl_Config_Initialize();
		return;
	else
		return;
	end
end


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
	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Config_Config[UnitName("player")]) == "table") then
		Perl_Config_GetVars();
	else
		Perl_Config_UpdateVars();
	end
end


---------------------------
-- Localization Function --
---------------------------
function Perl_Config_Get_Localization()
	local perl_localized_druid;
	local perl_localized_hunter;
	local perl_localized_mage;
	local perl_localized_paladin;
	local perl_localized_priest;
	local perl_localized_rogue;
	local perl_localized_shaman;
	local perl_localized_warlock;
	local perl_localized_warrior;
	local perl_localized_civilian;
	local perl_localized_creature;
	local perl_localized_notspecified;

	-- English is set no matter what in order to not break the mod for untranslated clients like in version 0.25
	--if (GetLocale() == "enUS") then
		perl_localized_druid = "Druid";
		perl_localized_hunter = "Hunter";
		perl_localized_mage = "Mage";
		perl_localized_paladin = "Paladin";
		perl_localized_priest = "Priest";
		perl_localized_rogue = "Rogue";
		perl_localized_shaman = "Shaman";
		perl_localized_warlock = "Warlock";
		perl_localized_warrior = "Warrior";

		perl_localized_civilian = "Civilian";
		perl_localized_creature = "Creature";
		perl_localized_notspecified = "Not specified";
	--end

	if (GetLocale() == "deDE") then
		perl_localized_druid = "Druide";
		perl_localized_hunter = "J\195\164ger";
		perl_localized_mage = "Magier";
		perl_localized_paladin = "Paladin";
		perl_localized_priest = "Priester";
		perl_localized_rogue = "Schurke";
		perl_localized_shaman = "Schamane";
		perl_localized_warlock = "Hexenmeister";
		perl_localized_warrior = "Krieger";

		perl_localized_civilian = "Zivilist";
		perl_localized_creature = "Kreatur";
		perl_localized_notspecified = "Nicht spezifiziert";
	end

	if (GetLocale() == "frFR") then
		perl_localized_druid = "Druide";
		perl_localized_hunter = "Chasseur";
		perl_localized_mage = "Mage";
		perl_localized_paladin = "Paladin";
		perl_localized_priest = "Pr\195\170tre";
		perl_localized_rogue = "Voleur";
		perl_localized_shaman = "Chaman";
		perl_localized_warlock = "D\195\169moniste";
		perl_localized_warrior = "Guerrier";

		perl_localized_civilian = "Civil";
		perl_localized_creature = "Cr\195\169ature";
		perl_localized_notspecified = "Non indiqu\195\169";
	end

	if (GetLocale() == "koKR") then
		perl_localized_druid = "드루이드";
		perl_localized_hunter = "사냥꾼";
		perl_localized_mage = "마법사";
		perl_localized_paladin = "성기사";
		perl_localized_priest = "사제";
		perl_localized_rogue = "도적";
		perl_localized_shaman = "주술사";
		perl_localized_warlock = "흑마법사";
		perl_localized_warrior = "전사";

		perl_localized_civilian = "민간인";
		perl_localized_creature = "동물";
		perl_localized_notspecified = "무엇인가";
	end

	if (GetLocale() == "zhCN") then
		perl_localized_druid = "德鲁伊";
		perl_localized_hunter = "猎人";
		perl_localized_mage = "法师";
		perl_localized_paladin = "圣骑士";
		perl_localized_priest = "牧师";
		perl_localized_rogue = "盗贼";
		perl_localized_shaman = "萨满祭司";
		perl_localized_warlock = "术士";
		perl_localized_warrior = "战士";

		perl_localized_civilian = "平民";
		perl_localized_creature = "生物";
		perl_localized_notspecified = "非特定的";
	end

	if (GetLocale() == "zhTW") then
		perl_localized_druid = "德魯伊";
		perl_localized_hunter = "獵人";
		perl_localized_mage = "法師";
		perl_localized_paladin = "聖騎士";
		perl_localized_priest = "牧師";
		perl_localized_rogue = "盜賊";
		perl_localized_shaman = "薩滿";
		perl_localized_warlock = "術士";
		perl_localized_warrior = "戰士";

		perl_localized_civilian = "平民";
		perl_localized_creature = "生物";
		perl_localized_notspecified = "非特定的";
	end

	local localization = {
		["druid"] = perl_localized_druid,
		["hunter"] = perl_localized_hunter,
		["mage"] = perl_localized_mage,
		["paladin"] = perl_localized_paladin,
		["priest"] = perl_localized_priest,
		["rogue"] = perl_localized_rogue,
		["shaman"] = perl_localized_shaman,
		["warlock"] = perl_localized_warlock,
		["warrior"] = perl_localized_warrior,
		["civilian"] = perl_localized_civilian,
		["creature"] = perl_localized_creature,
		["notspecified"] = perl_localized_notspecified,
	}
	return localization;
end

----------------------
-- Update Functions --
----------------------
function Perl_Config_Set_Texture(newvalue)
	if (newvalue ~= nil) then
		texture = newvalue;
		Perl_Config_UpdateVars();
	end

	local texturename;
	if (texture ~= 0) then
		texturename = "Interface\\AddOns\\Perl_Config\\Perl_StatusBar"..texture..".tga";
	else
		texturename = "Interface\\TargetingFrame\\UI-StatusBar";
	end

	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_ArcaneBarTex:SetTexture(texturename);
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_HealthBarTex:SetTexture(texturename);
		Perl_CombatDisplay_ManaBarTex:SetTexture(texturename);
		Perl_CombatDisplay_DruidBarTex:SetTexture(texturename);
		Perl_CombatDisplay_CPBarTex:SetTexture(texturename);
		Perl_CombatDisplay_Target_HealthBarTex:SetTexture(texturename);
		Perl_CombatDisplay_Target_ManaBarTex:SetTexture(texturename);
	end

	if (Perl_Party_Frame) then
		Perl_Party_MemberFrame1_StatsFrame_HealthBar_HealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame1_StatsFrame_ManaBar_ManaBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame1_StatsFrame_PetHealthBar_PetHealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame2_StatsFrame_HealthBar_HealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame2_StatsFrame_ManaBar_ManaBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame2_StatsFrame_PetHealthBar_PetHealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame3_StatsFrame_HealthBar_HealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame3_StatsFrame_ManaBar_ManaBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame3_StatsFrame_PetHealthBar_PetHealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame4_StatsFrame_HealthBar_HealthBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame4_StatsFrame_ManaBar_ManaBarTex:SetTexture(texturename);
		Perl_Party_MemberFrame4_StatsFrame_PetHealthBar_PetHealthBarTex:SetTexture(texturename);
	end

	if (Perl_Player_Frame) then
		Perl_Player_HealthBarTex:SetTexture(texturename);
		Perl_Player_ManaBarTex:SetTexture(texturename);
		Perl_Player_DruidBarTex:SetTexture(texturename);
		Perl_Player_XPBarTex:SetTexture(texturename);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_HealthBarTex:SetTexture(texturename);
		Perl_Player_Pet_ManaBarTex:SetTexture(texturename);
		Perl_Player_Pet_XPBarTex:SetTexture(texturename);
	end

	if (Perl_Target_Frame) then
		Perl_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_ManaBarTex:SetTexture(texturename);
		Perl_Target_NameFrame_CPMeterTex:SetTexture(texturename);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_Target_ManaBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_ManaBarTex:SetTexture(texturename);
	end
end

function Perl_Config_Set_Background(newvalue)
	if (newvalue ~= nil) then
		transparentbackground = newvalue;
		Perl_Config_UpdateVars();
	end

	if (transparentbackground == 1) then
		if (Perl_CombatDisplay_Frame) then
			Perl_CombatDisplay_ManaFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_CombatDisplay_Target_ManaFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_CombatDisplay_Initialize_Frame_Color();
		end

		if (Perl_Party_Frame) then
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Initialize_Frame_Color(1);
		end

		if (Perl_Player_Frame) then
			Perl_Player_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_RaidGroupNumberFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Initialize_Frame_Color();
		end

		if (Perl_Player_Pet_Frame) then
			Perl_Player_Pet_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Initialize_Frame_Color();
		end

		if (Perl_Target_Frame) then
			Perl_Target_CivilianFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_ClassNameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_CPFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_RareEliteFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Initialize_Frame_Color();
		end

		if (Perl_Target_Target_Script_Frame) then
			Perl_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_Initialize_Frame_Color();
		end
	else
		if (Perl_CombatDisplay_Frame) then
			Perl_CombatDisplay_ManaFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_CombatDisplay_Target_ManaFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_CombatDisplay_Initialize_Frame_Color();
		end

		if (Perl_Party_Frame) then
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Initialize_Frame_Color(1);
		end

		if (Perl_Player_Frame) then
			Perl_Player_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_RaidGroupNumberFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Initialize_Frame_Color();
		end

		if (Perl_Player_Pet_Frame) then
			Perl_Player_Pet_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Initialize_Frame_Color();
		end

		if (Perl_Target_Frame) then
			Perl_Target_CivilianFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_White", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_ClassNameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_CPFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_RareEliteFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Initialize_Frame_Color();
		end

		if (Perl_Target_Target_Script_Frame) then
			Perl_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Target_Target_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
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

	if (Perl_Party_Frame) then
		Perl_Party_Set_Transparency(newvalue);
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


-----------------------------------
-- Reset Frame Position Function --
-----------------------------------
function Perl_Config_Frame_Reset_Positions()
	-- Due to a terrible API, CombatDisplay resetting will not be a feature unless someone can unravel the mystery of screen resolution and scaling coordinates
--	if (Perl_CombatDisplay_Frame) then
--		Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 626, -574);
--		Perl_CombatDisplay_Target_Frame:SetPoint("BOTTOMLEFT", Perl_CombatDisplay_Frame, "TOPLEFT", 0, 5);
--	end

	if (Perl_Party_Frame) then
		Perl_Party_Frame:SetUserPlaced(1);		-- All the SetUserPlaced allows us to save the new location set by these functions even if the user has not moved the frames on their own yet.
		Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -8, -187);
	end

	if (Perl_Player_Frame) then
		Perl_Player_Frame:SetUserPlaced(1);
		Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -3, -43);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Frame:SetUserPlaced(1);
		Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 27, -112);
	end

	if (Perl_Target_Frame) then
		Perl_Target_Frame:SetUserPlaced(1);
		Perl_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 263, -43);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Frame:SetUserPlaced(1);
		Perl_Target_Target_Target_Frame:SetUserPlaced(1);
		Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 501, -43);
		Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 607, -43);
	end
end


-------------------------------------
-- Global Saved Variable Functions --
-------------------------------------
function Perl_Config_Global_Save_Settings()
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		local vartable = Perl_ArcaneBar_GetVars();
		Perl_Config_Global_ArcaneBar_Config["Global Settings"] = {
			["Enabled"] = vartable["enabled"],
			["HideOriginal"] = vartable["hideoriginal"],
			["ShowTimer"] = vartable["showtimer"],
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
			["ColorHealth"] = vartable["colorhealth"],
			["Transparency"] = vartable["transparency"],
			["ShowTarget"] = vartable["showtarget"],
			["MobHealthSupport"] = vartable["mobhealthsupport"],
			["XPositionCD"] = floor(Perl_CombatDisplay_Frame:GetLeft() + 0.5),
			["YPositionCD"] = floor(Perl_CombatDisplay_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Frame:GetScale()) + 0.5),
			["XPositionCDT"] = floor(Perl_CombatDisplay_Target_Frame:GetLeft() + 0.5),
			["YPositionCDT"] = floor(Perl_CombatDisplay_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Target_Frame:GetScale()) + 0.5),
			["ShowDruidBar"] = vartable["showdruidbar"],
		};
	end

	if (Perl_Config_Frame) then
		local vartable = Perl_Config_GetVars();
		Perl_Config_Global_Config_Config["Global Settings"] = {
			["Texture"] = vartable["texture"],
			["ShowMiniMapButton"] = vartable["showminimapbutton"],
			["MiniMapButtonPos"] = vartable["minimapbuttonpos"],
			["TransparentBackground"] = vartable["transparentbackground"],
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
			["ColorHealth"] = vartable["colorhealth"],
			["HealerMode"] = vartable["healermode"],
			["Transparency"] = vartable["transparency"],
			["BuffLocation"] = vartable["bufflocation"],
			["DebuffLocation"] = vartable["debufflocation"],
			["VerticalAlign"] = vartable["verticalalign"],
			["XPosition"] = floor(Perl_Party_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Party_Frame:GetTop() - (UIParent:GetTop() / Perl_Party_Frame:GetScale()) + 0.5),
			["CompactPercent"] = vartable["compactpercent"],
			["ShowPortrait"] = vartable["showportrait"],
			["ShowFKeys"] = vartable["showfkeys"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["BuffSize"] = vartable["buffsize"],
			["DebuffSize"] = vartable["debuffsize"],
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
			["ColorHealth"] = vartable["colorhealth"],
			["HealerMode"] = vartable["healermode"],
			["Transparency"] = vartable["transparency"],
			["XPosition"] = floor(Perl_Player_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Player_Frame:GetTop() - (UIParent:GetTop() / Perl_Player_Frame:GetScale()) + 0.5),
			["ShowPortrait"] = vartable["showportrait"],
			["CompactPercent"] = vartable["compactpercent"],
			["ThreeDPortrait"] = vartable["threedportrait"],
			["PortraitCombatText"] = vartable["portraitcombattext"],
			["ShowDruidBar"] = vartable["showdruidbar"],
		};
	end

	if (Perl_Player_Buff_Script_Frame) then
		local vartable = Perl_Player_Buff_GetVars();
		Perl_Config_Global_Player_Buff_Config["Global Settings"] = {
			["BuffAlerts"] = vartable["buffalerts"],
			["ShowBuffs"] = vartable["showbuffs"],
			["Scale"] = vartable["scale"],
		};
	end

	if (Perl_Player_Pet_Frame) then
		local vartable = Perl_Player_Pet_GetVars();
		Perl_Config_Global_Player_Pet_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["ShowXP"] = vartable["showxp"],
			["Scale"] = vartable["scale"],
			["Buffs"] = vartable["numpetbuffsshown"],
			["Debuffs"] = vartable["numpetdebuffsshown"],
			["ColorHealth"] = vartable["colorhealth"],
			["Transparency"] = vartable["transparency"],
			["BuffLocation"] = vartable["bufflocation"],
			["DebuffLocation"] = vartable["debufflocation"],
			["XPosition"] = floor(Perl_Player_Pet_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Player_Pet_Frame:GetTop() - (UIParent:GetTop() / Perl_Player_Pet_Frame:GetScale()) + 0.5),
			["BuffSize"] = vartable["buffsize"],
			["DebuffSize"] = vartable["debuffsize"],
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
			["MobHealthSupport"] = vartable["mobhealthsupport"],
			["Scale"] = vartable["scale"],
			["ColorHealth"] = vartable["colorhealth"],
			["ShowPvPRank"] = vartable["showpvprank"],
			["Transparency"] = vartable["transparency"],
			["BuffDebuffScale"] = vartable["buffdebuffscale"],
			["XPosition"] = floor(Perl_Target_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_Target_Frame:GetScale()) + 0.5),
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
		};
	end

	if (Perl_Target_Target_Script_Frame) then
		local vartable = Perl_Target_Target_GetVars();
		Perl_Config_Global_Target_Target_Config["Global Settings"] = {
			["ColorHealth"] = vartable["colorhealth"],
			["Locked"] = vartable["locked"],
			["MobHealthSupport"] = vartable["mobhealthsupport"],
			["Scale"] = vartable["scale"],
			["ToTSupport"] = vartable["totsupport"],
			["ToToTSupport"] = vartable["tototsupport"],
			["Transparency"] = vartable["transparency"],
			["XPositionToT"] = floor(Perl_Target_Target_Frame:GetLeft() + 0.5),
			["YPositionToT"] = floor(Perl_Target_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_Target_Target_Frame:GetScale()) + 0.5),
			["XPositionToToT"] = floor(Perl_Target_Target_Target_Frame:GetLeft() + 0.5),
			["YPositionToToT"] = floor(Perl_Target_Target_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_Target_Target_Target_Frame:GetScale()) + 0.5),
			["AlertSound"] = vartable["alertsound"],
			["AlertMode"] = vartable["alertmode"],
			["AlertSize"] = vartable["alertsize"],
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

		if ((Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCD"] ~= nil) and (Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCD"] ~= nil) and (Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCDT"] ~= nil) and (Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCDT"] ~= nil)) then
			Perl_CombatDisplay_Frame:SetUserPlaced(1);
			Perl_CombatDisplay_Target_Frame:SetUserPlaced(1);
			Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCD"], Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCD"]);
			Perl_CombatDisplay_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCDT"], Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCDT"]);
		end
	end

	if (Perl_Config_Frame) then
		Perl_Config_UpdateVars(Perl_Config_Global_Config_Config);
	end

	if (Perl_Party_Frame) then
		Perl_Party_UpdateVars(Perl_Config_Global_Party_Config);

		if ((Perl_Config_Global_Party_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Party_Config["Global Settings"]["YPosition"] ~= nil)) then
			Perl_Party_Frame:SetUserPlaced(1);
			Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Config["Global Settings"]["XPosition"], Perl_Config_Global_Party_Config["Global Settings"]["YPosition"]);
		end
	end

	if (Perl_Player_Frame) then
		Perl_Player_UpdateVars(Perl_Config_Global_Player_Config);

		if ((Perl_Config_Global_Player_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Player_Config["Global Settings"]["YPosition"] ~= nil)) then
			Perl_Player_Frame:SetUserPlaced(1);
			Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Player_Config["Global Settings"]["XPosition"], Perl_Config_Global_Player_Config["Global Settings"]["YPosition"]);
		end
	end

	if (Perl_Player_Buff_Script_Frame) then
		Perl_Player_Buff_UpdateVars(Perl_Config_Global_Player_Buff_Config);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_UpdateVars(Perl_Config_Global_Player_Pet_Config);

		if ((Perl_Config_Global_Player_Pet_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Player_Pet_Config["Global Settings"]["YPosition"] ~= nil)) then
			Perl_Player_Pet_Frame:SetUserPlaced(1);
			Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Player_Pet_Config["Global Settings"]["XPosition"], Perl_Config_Global_Player_Pet_Config["Global Settings"]["YPosition"]);
		end
	end

	if (Perl_Target_Frame) then
		Perl_Target_UpdateVars(Perl_Config_Global_Target_Config);

		if ((Perl_Config_Global_Target_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Target_Config["Global Settings"]["YPosition"] ~= nil)) then
			Perl_Target_Frame:SetUserPlaced(1);
			Perl_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Target_Config["Global Settings"]["XPosition"], Perl_Config_Global_Target_Config["Global Settings"]["YPosition"]);
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_UpdateVars(Perl_Config_Global_Target_Target_Config);

		if ((Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToT"] ~= nil) and (Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToT"] ~= nil) and (Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToToT"] ~= nil) and (Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToToT"] ~= nil)) then
			Perl_Target_Target_Frame:SetUserPlaced(1);
			Perl_Target_Target_Target_Frame:SetUserPlaced(1);
			Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToT"], Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToT"]);
			Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToToT"], Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToToT"]);
		end
	end
end

------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Config_GetVars()
	texture = Perl_Config_Config[UnitName("player")]["Texture"];
	showminimapbutton = Perl_Config_Config[UnitName("player")]["ShowMiniMapButton"];
	minimapbuttonpos = Perl_Config_Config[UnitName("player")]["MiniMapButtonPos"];
	transparentbackground = Perl_Config_Config[UnitName("player")]["TransparentBackground"];

	if (texture == nil) then
		texture = 0;
	end
	if (showminimapbutton == nil) then
		showminimapbutton = 1;
	end
	if (minimapbuttonpos == nil) then
		minimapbuttonpos = 270;
	end
	if (transparentbackground == nil) then
		transparentbackground = 0;
	end

	local vars = {
		["texture"] = texture,
		["showminimapbutton"] = showminimapbutton,
		["minimapbuttonpos"] = minimapbuttonpos,
		["transparentbackground"] = transparentbackground,
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
		end

		-- Set the new values if any new values were found, same defaults as above
		if (texture == nil) then
			texture = 0;
		end
		if (showminimapbutton == nil) then
			showminimapbutton = 1;
		end
		if (minimapbuttonpos == nil) then
			minimapbuttonpos = 270;
		end
		if (transparentbackground == nil) then
			transparentbackground = 0;
		end

		-- Call any code we need to activate them
		Perl_Config_Set_Texture(texture);
		Perl_Config_Set_MiniMap_Button(showminimapbutton);
		Perl_Config_Set_MiniMap_Position(minimapbuttonpos);
		Perl_Config_Set_Background();
	end

	Perl_Config_Config[UnitName("player")] = {
		["Texture"] = texture,
		["ShowMiniMapButton"] = showminimapbutton,
		["MiniMapButtonPos"] = minimapbuttonpos,
		["TransparentBackground"] = transparentbackground,
	};
end


-------------------------
-- The Toggle Function --
-------------------------
function Perl_Config_Toggle()
	if (Perl_Config_Frame:IsVisible()) then
		Perl_Config_Frame:Hide();
		Perl_Config_Hide_All();
	else
		Perl_Config_Frame:Show();
		Perl_Config_Hide_All();
	end
end

function Perl_Config_Hide_All()
	Perl_Config_All_Frame:Hide();
	Perl_Config_ArcaneBar_Frame:Hide();
	Perl_Config_CombatDisplay_Frame:Hide();
	Perl_Config_NotInstalled_Frame:Hide();
	Perl_Config_Party_Frame:Hide();
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
function Perl_Config_Button_OnClick()
	Perl_Config_Toggle();
end

function Perl_Config_Button_UpdatePosition()
	Perl_Config_ButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		55 - (75 * cos(minimapbuttonpos)),
		(75 * sin(minimapbuttonpos)) - 55
	);
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Config_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Config_myAddOns_Details = {
			name = "Perl_Config",
			version = "v0.50",
			releaseDate = "March 28, 2006",
			author = "Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS,
			optionsframe = "Perl_Config_Frame",
		};
		Perl_Config_myAddOns_Help = {};
		Perl_Config_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Config_myAddOns_Details, Perl_Config_myAddOns_Help);
	end
end