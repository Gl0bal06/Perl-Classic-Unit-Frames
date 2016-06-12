---------------
-- Variables --
---------------
Perl_Config_Config = {};

-- Default Saved Variables (also set in Perl_Player_GetVars)
local texture = 0;		-- no texture is set by default
local showminimapbutton = 1;
local minimapbuttonpos = 270;


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
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Config by Global loaded successfully.");
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
		Perl_CombatDisplay_CPBarTex:SetTexture(texturename);
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
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_Target_ManaBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_ManaBarTex:SetTexture(texturename);
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


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Config_GetVars()
	texture = Perl_Config_Config[UnitName("player")]["Texture"];
	showminimapbutton = Perl_Config_Config[UnitName("player")]["ShowMiniMapButton"];
	minimapbuttonpos = Perl_Config_Config[UnitName("player")]["MiniMapButtonPos"];

	if (texture == nil) then
		texture = 0;
	end
	if (showminimapbutton == nil) then
		showminimapbutton = 1;
	end
	if (minimapbuttonpos == nil) then
		minimapbuttonpos = 270;
	end

	local vars = {
		["texture"] = texture,
		["showminimapbutton"] = showminimapbutton,
		["minimapbuttonpos"] = minimapbuttonpos,
	}
	return vars;
end

function Perl_Config_UpdateVars()
	Perl_Config_Config[UnitName("player")] = {
						["Texture"] = texture,
						["ShowMiniMapButton"] = showminimapbutton,
						["MiniMapButtonPos"] = minimapbuttonpos,
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
			version = "v0.32",
			releaseDate = "January 21, 2006",
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