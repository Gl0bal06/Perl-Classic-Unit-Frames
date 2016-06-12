---------------
-- Variables --
---------------
PCUF_SHOW_DEBUG_EVENTS = 0;	-- event hijack and forbidden action monitor
Perl_Config_Config = {};
Perl_Config_Profiles = {};
local Perl_Config_Events = {};	-- event manager
local Perl_Config_Queue = {};	-- queue manager

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
local texture = 0;			-- no texture is set by default
local showminimapbutton = 1;		-- minimap button is on by default
local minimapbuttonpos = 270;		-- default minimap button position
local minimapbuttonrad = 80;		-- default minimap button radius
local transparentbackground = 0;	-- use solid black background as default
local texturedbarbackground = 0;	-- bar backgrounds are plain by default
PCUF_CASTPARTYSUPPORT = 0;		-- CastParty support is disabled by default
PCUF_COLORHEALTH = 0;			-- progressively colored health bars are off by default
PCUF_FADEBARS = 0;			-- fading status bars is off by default
PCUF_NAMEFRAMECLICKCAST = 0;		-- name frames will be the one safe spot for menus by default
PCUF_INVERTBARVALUES = 0;		-- bars deplete when low
PCUF_COLORFRAMEDEBUFF = 1;		-- frame debuff coloring is on by default
local positioningmode = 0;

-- Default Local Variables
local Initialized = nil;		-- waiting to be initialized
local currentprofilenumber = 0;		-- easy way to make our profile system work
local eventqueuetotal = 0;		-- variable to check how many queued events we have

-- Variables for position of the class icon texture.
PCUF_CLASSPOSRIGHT = {
	["DRUID"] = 0.75,
	["HUNTER"] = 0,
	["MAGE"] = 0.25,
	["PALADIN"] = 0,
	["PRIEST"] = 0.5,
	["ROGUE"] = 0.5,
	["SHAMAN"] = 0.25,
	["WARLOCK"] = 0.75,
	["WARRIOR"] = 0,
};
PCUF_CLASSPOSLEFT = {
	["DRUID"] = 1,
	["HUNTER"] = 0.25,
	["MAGE"] = 0.5,
	["PALADIN"] = 0.25,
	["PRIEST"] = 0.75,
	["ROGUE"] = 0.75,
	["SHAMAN"] = 0.5,
	["WARLOCK"] = 1,
	["WARRIOR"] = 0.25,
};
PCUF_CLASSPOSTOP = {
	["DRUID"] = 0,
	["HUNTER"] = 0.25,
	["MAGE"] = 0,
	["PALADIN"] = 0.5,
	["PRIEST"] = 0.25,
	["ROGUE"] = 0,
	["SHAMAN"] = 0.25,
	["WARLOCK"] = 0.25,
	["WARRIOR"] = 0,
};
PCUF_CLASSPOSBOTTOM = {
	["DRUID"] = 0.25,
	["HUNTER"] = 0.5,
	["MAGE"] = 0.25,
	["PALADIN"] = 0.75,
	["PRIEST"] = 0.5,
	["ROGUE"] = 0.25,
	["SHAMAN"] = 0.5,
	["WARLOCK"] = 0.5,
	["WARRIOR"] = 0.25,
};


----------------------
-- Loading Function --
----------------------
function Perl_Config_OnLoad()
	-- Events
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");

	-- Scripts
	this:SetScript("OnEvent", Perl_Config_OnEvent);

	-- Slash Commands
	SlashCmdList["PERL_CONFIG"] = Perl_Config_SlashHandler;
	SLASH_PERL_CONFIG1 = "/perl";
end

function Perl_BlizzardOptions_OnLoad(panel)
	panel.name = PERL_LOCALIZED_NAME;
	InterfaceOptions_AddCategory(panel);
end


-------------------
-- Event Handler --
-------------------
function Perl_Config_OnEvent()
	local func = Perl_Config_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Config: Report the following event error to the author: "..event);
		end
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
	if (type(Perl_Config_Config[UnitName("player")]) == "table") then
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

	-- MyAddOns Support
	Perl_Config_myAddOns_Support();

	-- Set the initialization flag
	Initialized = 1;

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00"..PERL_LOCALIZED_NAME..": "..PERL_LOCALIZED_VERSION.." loaded.");
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


---------------------
-- Queue Functions --
---------------------
function Perl_Config_Queue_Add(incomingFunction)
	if (incomingFunction ~= nil) then
		table.insert(Perl_Config_Queue, incomingFunction);	-- Add our function to the queue
		eventqueuetotal = eventqueuetotal + 1;			-- Increment our variable by one
	end
end

function Perl_Config_Queue_Process()
	for i=1, table.getn(Perl_Config_Queue), 1 do			-- Loop through the queue and call all the functions we need to update
		local func = Perl_Config_Queue[i];
		if (func) then
			func();
		end
	end
	Perl_Config_Queue = {};						-- Empty the queue
	eventqueuetotal = 0;						-- Reset our variable
end


-----------------------
-- Profile Functions --
-----------------------
function Perl_Config_Profile_Work()
	local name = UnitName("player");
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
	UIDropDownMenu_SetWidth(100, Perl_Config_All_Frame_DropDown1);
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

function Perl_Config_Profile_OnClick()
	currentprofilenumber = this:GetID();
	UIDropDownMenu_SetSelectedID(Perl_Config_All_Frame_DropDown1, this:GetID());
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
	local name = Perl_Config_Profiles[currentprofilenumber];
	local indexfound = nil;
	for i = 1, getn(Perl_Config_Profiles), 1 do
		if (name == Perl_Config_Profiles[i]) then
			indexfound = i;
			break;
		end
	end

	if (indexfound ~= nil) then
		DEFAULT_CHAT_FRAME:AddMessage(PERL_LOCALIZED_CONFIG_ALL_DELETE_PROFILE_OUTPUT..Perl_Config_Profiles[indexfound]);
		Perl_Config_Profiles[indexfound] = table.remove(Perl_Config_Profiles);
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
		Perl_ArcaneBar_playerTex:SetTexture(texturename);
		Perl_ArcaneBar_targetTex:SetTexture(texturename);
		Perl_ArcaneBar_focusTex:SetTexture(texturename);
		Perl_ArcaneBar_party1Tex:SetTexture(texturename);
		Perl_ArcaneBar_party2Tex:SetTexture(texturename);
		Perl_ArcaneBar_party3Tex:SetTexture(texturename);
		Perl_ArcaneBar_party4Tex:SetTexture(texturename);
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_HealthBarTex:SetTexture(texturename);
		Perl_CombatDisplay_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_ManaBarTex:SetTexture(texturename);
		Perl_CombatDisplay_ManaBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_DruidBarTex:SetTexture(texturename);
		--Perl_CombatDisplay_DruidBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_CPBarTex:SetTexture(texturename);
		Perl_CombatDisplay_CPBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_PetHealthBarTex:SetTexture(texturename);
		Perl_CombatDisplay_PetHealthBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_PetManaBarTex:SetTexture(texturename);
		Perl_CombatDisplay_PetManaBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_Target_HealthBarTex:SetTexture(texturename);
		Perl_CombatDisplay_Target_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_CombatDisplay_Target_ManaBarTex:SetTexture(texturename);
		Perl_CombatDisplay_Target_ManaBarFadeBarTex:SetTexture(texturename);
		if (texturedbarbackground == 1) then
			Perl_CombatDisplay_HealthBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_ManaBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_DruidBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_CPBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_PetHealthBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_PetManaBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_Target_HealthBarBGTex:SetTexture(texturename);
			Perl_CombatDisplay_Target_ManaBarBGTex:SetTexture(texturename);
		else
			Perl_CombatDisplay_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_DruidBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_CPBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_PetHealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_PetManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_Target_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_CombatDisplay_Target_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_HealthBarTex:SetTexture(texturename);
		Perl_Focus_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Focus_ManaBarTex:SetTexture(texturename);
		Perl_Focus_ManaBarFadeBarTex:SetTexture(texturename);
		Perl_Focus_NameFrame_CPMeterTex:SetTexture(texturename);
		if (texturedbarbackground == 1) then
			Perl_Focus_HealthBarBGTex:SetTexture(texturename);
			Perl_Focus_ManaBarBGTex:SetTexture(texturename);
		else
			Perl_Focus_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Focus_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Party_Frame) then
		for num=1,4 do
			getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_HealthBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar_HealthBarFadeBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_ManaBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar_ManaBarFadeBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_PetHealthBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar_PetHealthBarFadeBarTex"):SetTexture(texturename);
			if (texturedbarbackground == 1) then
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"):SetTexture(texturename);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"):SetTexture(texturename);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG_PetHealthBarBGTex"):SetTexture(texturename);
			else
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG_PetHealthBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			end
		end
	end

	if (Perl_Party_Pet_Script_Frame) then
		for num=1,4 do
			getglobal("Perl_Party_Pet"..num.."_StatsFrame_HealthBar_HealthBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_Pet"..num.."_StatsFrame_HealthBarFadeBar_HealthBarFadeBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_Pet"..num.."_StatsFrame_ManaBar_ManaBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_Pet"..num.."_StatsFrame_ManaBarFadeBar_ManaBarFadeBarTex"):SetTexture(texturename);
			if (texturedbarbackground == 1) then
				getglobal("Perl_Party_Pet"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"):SetTexture(texturename);
				getglobal("Perl_Party_Pet"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"):SetTexture(texturename);
			else
				getglobal("Perl_Party_Pet"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				getglobal("Perl_Party_Pet"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			end
		end
	end

	if (Perl_Party_Target_Script_Frame) then
		for num=1,5 do
			getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar_HealthBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBarFadeBar_HealthBarFadeBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar_ManaBarTex"):SetTexture(texturename);
			getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBarFadeBar_ManaBarFadeBarTex"):SetTexture(texturename);
			if (texturedbarbackground == 1) then
				getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"):SetTexture(texturename);
				getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"):SetTexture(texturename);
			else
				getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBarBG_HealthBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
				getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBarBG_ManaBarBGTex"):SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			end
		end
	end

	if (Perl_Player_Frame) then
		Perl_Player_HealthBarTex:SetTexture(texturename);
		Perl_Player_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Player_ManaBarTex:SetTexture(texturename);
		Perl_Player_ManaBarFadeBarTex:SetTexture(texturename);
		Perl_Player_DruidBarTex:SetTexture(texturename);
		--Perl_Player_DruidBarFadeBarTex:SetTexture(texturename);
		Perl_Player_XPBarTex:SetTexture(texturename);
		if (texturedbarbackground == 1) then
			Perl_Player_HealthBarBGTex:SetTexture(texturename);
			Perl_Player_ManaBarBGTex:SetTexture(texturename);
			Perl_Player_DruidBarBGTex:SetTexture(texturename);
			Perl_Player_XPBarBGTex:SetTexture(texturename);
		else
			Perl_Player_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_DruidBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_XPBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_HealthBarTex:SetTexture(texturename);
		Perl_Player_Pet_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Player_Pet_ManaBarTex:SetTexture(texturename);
		Perl_Player_Pet_ManaBarFadeBarTex:SetTexture(texturename);
		Perl_Player_Pet_XPBarTex:SetTexture(texturename);
		Perl_Player_Pet_Target_HealthBarTex:SetTexture(texturename);
		Perl_Player_Pet_Target_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Player_Pet_Target_ManaBarTex:SetTexture(texturename);
		Perl_Player_Pet_Target_ManaBarFadeBarTex:SetTexture(texturename);
		if (texturedbarbackground == 1) then
			Perl_Player_Pet_HealthBarBGTex:SetTexture(texturename);
			Perl_Player_Pet_ManaBarBGTex:SetTexture(texturename);
			Perl_Player_Pet_XPBarBGTex:SetTexture(texturename);
			Perl_Player_Pet_Target_HealthBarBGTex:SetTexture(texturename);
			Perl_Player_Pet_Target_ManaBarBGTex:SetTexture(texturename);
		else
			Perl_Player_Pet_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_Pet_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_Pet_XPBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_Pet_Target_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Player_Pet_Target_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Target_Frame) then
		Perl_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Target_ManaBarTex:SetTexture(texturename);
		Perl_Target_ManaBarFadeBarTex:SetTexture(texturename);
		Perl_Target_NameFrame_CPMeterTex:SetTexture(texturename);
		if (texturedbarbackground == 1) then
			Perl_Target_HealthBarBGTex:SetTexture(texturename);
			Perl_Target_ManaBarBGTex:SetTexture(texturename);
		else
			Perl_Target_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Target_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_Target_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Target_Target_ManaBarTex:SetTexture(texturename);
		Perl_Target_Target_ManaBarFadeBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_HealthBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_HealthBarFadeBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_ManaBarTex:SetTexture(texturename);
		Perl_Target_Target_Target_ManaBarFadeBarTex:SetTexture(texturename);
		if (texturedbarbackground == 1) then
			Perl_Target_Target_HealthBarBGTex:SetTexture(texturename);
			Perl_Target_Target_ManaBarBGTex:SetTexture(texturename);
			Perl_Target_Target_Target_HealthBarBGTex:SetTexture(texturename);
			Perl_Target_Target_Target_ManaBarBGTex:SetTexture(texturename);
		else
			Perl_Target_Target_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Target_Target_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Target_Target_Target_HealthBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
			Perl_Target_Target_Target_ManaBarBGTex:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
		end
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

		if (Perl_Focus_Frame) then
			Perl_Focus_CivilianFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_ClassNameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_LevelFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_RareEliteFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_Initialize_Frame_Color();
		end

		if (Perl_Party_Frame) then
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Initialize_Frame_Color();
		end

		if (Perl_Party_Pet_Script_Frame) then
			for partynum=1,4 do
				getglobal("Perl_Party_Pet"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_Pet"..partynum.."_PortraitFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_Pet"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Pet_Initialize_Frame_Color();
		end

		if (Perl_Party_Target_Script_Frame) then
			for partynum=1,5 do
				getglobal("Perl_Party_Target"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Target_Initialize_Frame_Color();
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
			Perl_Player_Pet_PortraitFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Target_NameFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Initialize_Frame_Color();
		end

		if (Perl_Target_Frame) then
			Perl_Target_GuildFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
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

		if (Perl_Focus_Frame) then
			Perl_Focus_CivilianFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_White", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_ClassNameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_LevelFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_RareEliteFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Focus_Initialize_Frame_Color();
		end

		if (Perl_Party_Frame) then
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Initialize_Frame_Color();
		end

		if (Perl_Party_Pet_Script_Frame) then
			for partynum=1,4 do
				getglobal("Perl_Party_Pet"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_Pet"..partynum.."_PortraitFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_Pet"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Pet_Initialize_Frame_Color();
		end

		if (Perl_Party_Target_Script_Frame) then
			for partynum=1,5 do
				getglobal("Perl_Party_Target"..partynum.."_NameFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			end
			Perl_Party_Target_Initialize_Frame_Color();
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
			Perl_Player_Pet_PortraitFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Target_NameFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Target_StatsFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
			Perl_Player_Pet_Initialize_Frame_Color();
		end

		if (Perl_Target_Frame) then
			Perl_Target_GuildFrame:SetBackdrop({bgFile = "Interface\\AddOns\\Perl_Config\\Perl_Black", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
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
		Perl_CombatDisplay_Frame:SetUserPlaced(1);		-- All the SetUserPlaced allows us to save the new location set by these functions even if the user has not moved the frames on their own yet.
		Perl_CombatDisplay_Target_Frame:SetUserPlaced(1);
		Perl_CombatDisplay_Frame:ClearAllPoints();
		Perl_CombatDisplay_Target_Frame:ClearAllPoints();
		Perl_CombatDisplay_Frame:SetPoint("BOTTOM", 0, 300);
		Perl_CombatDisplay_Target_Frame:SetPoint("BOTTOMLEFT", Perl_CombatDisplay_Frame, "TOPLEFT", 0, 5);
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_Frame:SetUserPlaced(1);
		Perl_Focus_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -650);
	end

	if (Perl_Party_Frame) then
		local vartable = Perl_Party_GetVars();
		Perl_Party_Frame:SetUserPlaced(1);
		if (vartable["showportrait"] == 0) then
			Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -7, -187);
		else
			Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 55, -187);
		end
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_Allign();
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_Allign();
	end

	if (Perl_Player_Frame) then
		local vartable = Perl_Player_GetVars();
		Perl_Player_Frame:SetUserPlaced(1);
		if (vartable["showportrait"] == 0) then
			Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2, -43);
		else
			Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 60, -43);
		end
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Frame:SetUserPlaced(1);
		Perl_Player_Pet_Target_Frame:SetUserPlaced(1);
		if (Perl_Player_Frame) then
			local vartableone = Perl_Player_GetVars();
			local vartabletwo = Perl_Player_Pet_GetVars();
			Perl_Player_Pet_Frame:ClearAllPoints();
			if (vartableone["showportrait"] == 0 and vartabletwo["showportrait"] == 1) then
				Perl_Player_Pet_Frame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "BOTTOMLEFT", 54, 2);
			else
				Perl_Player_Pet_Frame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "BOTTOMLEFT", 0, 2);
			end
		else
			Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 27, -112);
		end
		Perl_Player_Pet_Target_Frame:ClearAllPoints();
		Perl_Player_Pet_Target_Frame:SetPoint("TOPLEFT", Perl_Player_Pet_Frame, "TOPRIGHT", -2, 0);
	end

	if (Perl_Target_Frame) then
		Perl_Target_Frame:SetUserPlaced(1);
		if (Perl_Player_Frame) then
			Perl_Target_Frame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "TOPRIGHT", -2, 22);
		else
			Perl_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 283, -43);
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Frame:SetUserPlaced(1);
		Perl_Target_Target_Target_Frame:SetUserPlaced(1);
		if (Perl_Target_Frame) then
			Perl_Target_Target_Frame:ClearAllPoints();
			Perl_Target_Target_Target_Frame:ClearAllPoints();
			local vartable = Perl_Target_GetVars();
			if (vartable["showcp"] == 1) then
				if (vartable["showportrait"] == 1) then
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_CPFrame, "TOPRIGHT", -2, 34);
				else
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_CPFrame, "TOPRIGHT", -2, 22);
				end
			else
				if (vartable["showportrait"] == 1) then
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_PortraitFrame, "TOPRIGHT", -2, 0);
				else
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_LevelFrame, "TOPRIGHT", -2, 0);
				end
			end
			Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", -2, 0);
		else
			Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 525, -43);
			Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 633, -43);
		end
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
			["MobHealthSupport"] = vartable["mobhealthsupport"],
			["XPositionCD"] = floor(Perl_CombatDisplay_Frame:GetLeft() + 0.5),
			["YPositionCD"] = floor(Perl_CombatDisplay_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Frame:GetScale()) + 0.5),
			["XPositionCDT"] = floor(Perl_CombatDisplay_Target_Frame:GetLeft() + 0.5),
			["YPositionCDT"] = floor(Perl_CombatDisplay_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Target_Frame:GetScale()) + 0.5),
			["ShowDruidBar"] = vartable["showdruidbar"],
			["ShowPetBars"] = vartable["showpetbars"],
			["RightClickMenu"] = vartable["rightclickmenu"],
			["DisplayPercents"] = vartable["displaypercents"],
			["ShowCP"] = vartable["showcp"],
			["ClickThrough"] = vartable["clickthrough"],
			["ShowEnergyTicker"] = vartable["showenergyticker"],
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
			["MobHealthSupport"] = vartable["mobhealthsupport"],
			["Scale"] = vartable["scale"],
			["Transparency"] = vartable["transparency"],
			["BuffDebuffScale"] = vartable["buffdebuffscale"],
			["XPosition"] = floor(Perl_Focus_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Focus_Frame:GetTop() - (UIParent:GetTop() / Perl_Focus_Frame:GetScale()) + 0.5),
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
			["XPosition"] = floor(Perl_Party_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Party_Frame:GetTop() - (UIParent:GetTop() / Perl_Party_Frame:GetScale()) + 0.5),
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
			["XPosition1"] = floor(Perl_Party_Pet1:GetLeft() + 0.5),
			["YPosition1"] = floor(Perl_Party_Pet1:GetTop() - (UIParent:GetTop() / Perl_Party_Pet1:GetScale()) + 0.5),
			["XPosition2"] = floor(Perl_Party_Pet2:GetLeft() + 0.5),
			["YPosition2"] = floor(Perl_Party_Pet2:GetTop() - (UIParent:GetTop() / Perl_Party_Pet2:GetScale()) + 0.5),
			["XPosition3"] = floor(Perl_Party_Pet3:GetLeft() + 0.5),
			["YPosition3"] = floor(Perl_Party_Pet3:GetTop() - (UIParent:GetTop() / Perl_Party_Pet3:GetScale()) + 0.5),
			["XPosition4"] = floor(Perl_Party_Pet4:GetLeft() + 0.5),
			["YPosition4"] = floor(Perl_Party_Pet4:GetTop() - (UIParent:GetTop() / Perl_Party_Pet4:GetScale()) + 0.5),
			["Enabled"] = vartable["enabled"],
		};
	end

	if (Perl_Party_Target_Script_Frame) then
		local vartable = Perl_Party_Target_GetVars();
		Perl_Config_Global_Party_Target_Config["Global Settings"] = {
			["Locked"] = vartable["locked"],
			["Scale"] = vartable["scale"],
			["FocusScale"] = vartable["focusscale"],
			["Transparency"] = vartable["transparency"],
			["MobHealthSupport"] = vartable["mobhealthsupport"],
			["HidePowerBars"] = vartable["hidepowerbars"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["XPosition1"] = floor(Perl_Party_Target1:GetLeft() + 0.5),
			["YPosition1"] = floor(Perl_Party_Target1:GetTop() - (UIParent:GetTop() / Perl_Party_Target1:GetScale()) + 0.5),
			["XPosition2"] = floor(Perl_Party_Target2:GetLeft() + 0.5),
			["YPosition2"] = floor(Perl_Party_Target2:GetTop() - (UIParent:GetTop() / Perl_Party_Target2:GetScale()) + 0.5),
			["XPosition3"] = floor(Perl_Party_Target3:GetLeft() + 0.5),
			["YPosition3"] = floor(Perl_Party_Target3:GetTop() - (UIParent:GetTop() / Perl_Party_Target3:GetScale()) + 0.5),
			["XPosition4"] = floor(Perl_Party_Target4:GetLeft() + 0.5),
			["YPosition4"] = floor(Perl_Party_Target4:GetTop() - (UIParent:GetTop() / Perl_Party_Target4:GetScale()) + 0.5),
			["XPosition5"] = floor(Perl_Party_Target5:GetLeft() + 0.5),
			["YPosition5"] = floor(Perl_Party_Target5:GetTop() - (UIParent:GetTop() / Perl_Party_Target5:GetScale()) + 0.5),
			["Enabled"] = vartable["enabled"],
			["PartyHiddenInRaid"] = vartable["partyhiddeninraid"],
			["EnabledFocus"] = vartable["enabledfocus"],
			["FocusHiddenInRaid"] = vartable["focushiddeninraid"],
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
			["XPosition"] = floor(Perl_Player_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Player_Frame:GetTop() - (UIParent:GetTop() / Perl_Player_Frame:GetScale()) + 0.5),
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
			["ShowEnergyTicker"] = vartable["showenergyticker"],
			["FiveSecondRule"] = vartable["fivesecondrule"],
			["TotemTimers"] = vartable["totemtimers"],
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
			["XPosition"] = floor(Perl_Player_Pet_Frame:GetLeft() + 0.5),
			["YPosition"] = floor(Perl_Player_Pet_Frame:GetTop() - (UIParent:GetTop() / Perl_Player_Pet_Frame:GetScale()) + 0.5),
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
			["MobHealthSupport"] = vartable["mobhealthsupport"],
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
		};
	end

	if (Perl_Target_Target_Script_Frame) then
		local vartable = Perl_Target_Target_GetVars();
		Perl_Config_Global_Target_Target_Config["Global Settings"] = {
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
			["ShowToTBuffs"] = vartable["showtotbuffs"],
			["ShowToToTBuffs"] = vartable["showtototbuffs"],
			["HidePowerBars"] = vartable["hidepowerbars"],
			["ShowToTDebuffs"] = vartable["showtotdebuffs"],
			["ShowToToTDebuffs"] = vartable["showtototdebuffs"],
			["DisplayCastableBuffs"] = vartable["displaycastablebuffs"],
			["ClassColoredNames"] = vartable["classcolorednames"],
			["ShowFriendlyHealth"] = vartable["showfriendlyhealth"],
			["DisplayCurableDebuff"] = vartable["displaycurabledebuff"],
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

		if (Perl_Config_Global_CombatDisplay_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCD"] ~= nil) and (Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCD"] ~= nil) and (Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCDT"] ~= nil) and (Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCDT"] ~= nil)) then
				Perl_CombatDisplay_Frame:SetUserPlaced(1);
				Perl_CombatDisplay_Target_Frame:SetUserPlaced(1);
				Perl_CombatDisplay_Frame:ClearAllPoints();
				Perl_CombatDisplay_Target_Frame:ClearAllPoints();
				Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCD"], Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCD"]);
				Perl_CombatDisplay_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_CombatDisplay_Config["Global Settings"]["XPositionCDT"], Perl_Config_Global_CombatDisplay_Config["Global Settings"]["YPositionCDT"]);
			end
		end
	end

	if (Perl_Config_Script_Frame) then
		Perl_Config_UpdateVars(Perl_Config_Global_Config_Config);
	end

	if (Perl_Focus_Frame) then
		Perl_Focus_UpdateVars(Perl_Config_Global_Focus_Config);

		if (Perl_Config_Global_Focus_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Focus_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Focus_Config["Global Settings"]["YPosition"] ~= nil)) then
				Perl_Focus_Frame:SetUserPlaced(1);
				Perl_Focus_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Focus_Config["Global Settings"]["XPosition"], Perl_Config_Global_Focus_Config["Global Settings"]["YPosition"]);
			end
		end
	end

	if (Perl_Party_Frame) then
		Perl_Party_UpdateVars(Perl_Config_Global_Party_Config);

		if (Perl_Config_Global_Party_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Party_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Party_Config["Global Settings"]["YPosition"] ~= nil)) then
				Perl_Party_Frame:SetUserPlaced(1);
				Perl_Party_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Config["Global Settings"]["XPosition"], Perl_Config_Global_Party_Config["Global Settings"]["YPosition"]);
			end
		end
	end

	if (Perl_Party_Pet_Script_Frame) then
		Perl_Party_Pet_UpdateVars(Perl_Config_Global_Party_Pet_Config);

		if (Perl_Config_Global_Party_Pet_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Party_Pet_Config["Global Settings"]["XPosition1"] ~= nil) and (Perl_Config_Global_Party_Pet_Config["Global Settings"]["YPosition1"] ~= nil)) then
				Perl_Party_Pet1:SetUserPlaced(1);
				Perl_Party_Pet2:SetUserPlaced(1);
				Perl_Party_Pet3:SetUserPlaced(1);
				Perl_Party_Pet4:SetUserPlaced(1);
				Perl_Party_Pet1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Pet_Config["Global Settings"]["XPosition1"], Perl_Config_Global_Party_Pet_Config["Global Settings"]["YPosition1"]);
				Perl_Party_Pet2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Pet_Config["Global Settings"]["XPosition2"], Perl_Config_Global_Party_Pet_Config["Global Settings"]["YPosition2"]);
				Perl_Party_Pet3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Pet_Config["Global Settings"]["XPosition3"], Perl_Config_Global_Party_Pet_Config["Global Settings"]["YPosition3"]);
				Perl_Party_Pet4:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Pet_Config["Global Settings"]["XPosition4"], Perl_Config_Global_Party_Pet_Config["Global Settings"]["YPosition4"]);
			end
		end
	end

	if (Perl_Party_Target_Script_Frame) then
		Perl_Party_Target_UpdateVars(Perl_Config_Global_Party_Target_Config);

		if (Perl_Config_Global_Party_Target_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Party_Target_Config["Global Settings"]["XPosition1"] ~= nil) and (Perl_Config_Global_Party_Target_Config["Global Settings"]["YPosition1"] ~= nil)) then
				Perl_Party_Target1:SetUserPlaced(1);
				Perl_Party_Target2:SetUserPlaced(1);
				Perl_Party_Target3:SetUserPlaced(1);
				Perl_Party_Target4:SetUserPlaced(1);
				Perl_Party_Target5:SetUserPlaced(1);
				Perl_Party_Target1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Target_Config["Global Settings"]["XPosition1"], Perl_Config_Global_Party_Target_Config["Global Settings"]["YPosition1"]);
				Perl_Party_Target2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Target_Config["Global Settings"]["XPosition2"], Perl_Config_Global_Party_Target_Config["Global Settings"]["YPosition2"]);
				Perl_Party_Target3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Target_Config["Global Settings"]["XPosition3"], Perl_Config_Global_Party_Target_Config["Global Settings"]["YPosition3"]);
				Perl_Party_Target4:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Target_Config["Global Settings"]["XPosition4"], Perl_Config_Global_Party_Target_Config["Global Settings"]["YPosition4"]);
				Perl_Party_Target5:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Party_Target_Config["Global Settings"]["XPosition5"], Perl_Config_Global_Party_Target_Config["Global Settings"]["YPosition5"]);
			end
		end
	end

	if (Perl_Player_Frame) then
		Perl_Player_UpdateVars(Perl_Config_Global_Player_Config);

		if (Perl_Config_Global_Player_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Player_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Player_Config["Global Settings"]["YPosition"] ~= nil)) then
				Perl_Player_Frame:SetUserPlaced(1);
				Perl_Player_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Player_Config["Global Settings"]["XPosition"], Perl_Config_Global_Player_Config["Global Settings"]["YPosition"]);
			end
		end
	end

	if (Perl_Player_Buff_Script_Frame) then
		Perl_Player_Buff_UpdateVars(Perl_Config_Global_Player_Buff_Config);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_UpdateVars(Perl_Config_Global_Player_Pet_Config);

		if (Perl_Config_Global_Player_Pet_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Player_Pet_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Player_Pet_Config["Global Settings"]["YPosition"] ~= nil)) then
				Perl_Player_Pet_Frame:SetUserPlaced(1);
				Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Player_Pet_Config["Global Settings"]["XPosition"], Perl_Config_Global_Player_Pet_Config["Global Settings"]["YPosition"]);
			end
		end
	end

	if (Perl_Target_Frame) then
		Perl_Target_UpdateVars(Perl_Config_Global_Target_Config);

		if (Perl_Config_Global_Target_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Target_Config["Global Settings"]["XPosition"] ~= nil) and (Perl_Config_Global_Target_Config["Global Settings"]["YPosition"] ~= nil)) then
				Perl_Target_Frame:SetUserPlaced(1);
				Perl_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Target_Config["Global Settings"]["XPosition"], Perl_Config_Global_Target_Config["Global Settings"]["YPosition"]);
			end
		end
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_UpdateVars(Perl_Config_Global_Target_Target_Config);

		if (Perl_Config_Global_Target_Target_Config["Global Settings"] ~= nil) then
			if ((Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToT"] ~= nil) and (Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToT"] ~= nil) and (Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToToT"] ~= nil) and (Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToToT"] ~= nil)) then
				Perl_Target_Target_Frame:SetUserPlaced(1);
				Perl_Target_Target_Target_Frame:SetUserPlaced(1);
				Perl_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToT"], Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToT"]);
				Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", Perl_Config_Global_Target_Target_Config["Global Settings"]["XPositionToToT"], Perl_Config_Global_Target_Target_Config["Global Settings"]["YPositionToToT"]);
			end
		end
	end
end

------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Config_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	texture = Perl_Config_Config[name]["Texture"];
	showminimapbutton = Perl_Config_Config[name]["ShowMiniMapButton"];
	minimapbuttonpos = Perl_Config_Config[name]["MiniMapButtonPos"];
	transparentbackground = Perl_Config_Config[name]["TransparentBackground"];
	PCUF_CASTPARTYSUPPORT = Perl_Config_Config[name]["PCUF_CastPartySupport"];
	PCUF_COLORHEALTH = Perl_Config_Config[name]["PCUF_ColorHealth"];
	texturedbarbackground = Perl_Config_Config[name]["TexturedBarBackround"];
	PCUF_FADEBARS = Perl_Config_Config[name]["PCUF_FadeBars"];
	PCUF_NAMEFRAMECLICKCAST = Perl_Config_Config[name]["PCUF_NameFrameClickCast"];
	PCUF_INVERTBARVALUES = Perl_Config_Config[name]["PCUF_InvertBarValues"];
	minimapbuttonrad = Perl_Config_Config[name]["MiniMapButtonRad"];
	PCUF_COLORFRAMEDEBUFF = Perl_Config_Config[name]["PCUF_ColorFrameDebuff"];
	positioningmode = Perl_Config_Config[name]["PositioningMode"];

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
		["PCUF_CastPartySupport"] = PCUF_CASTPARTYSUPPORT,
		["PCUF_ColorHealth"] = PCUF_COLORHEALTH,
		["TexturedBarBackround"] = texturedbarbackground,
		["PCUF_FadeBars"] = PCUF_FADEBARS,
		["PCUF_NameFrameClickCast"] = PCUF_NAMEFRAMECLICKCAST,
		["PCUF_InvertBarValues"] = PCUF_INVERTBARVALUES,
		["MiniMapButtonRad"] = minimapbuttonrad,
		["PCUF_ColorFrameDebuff"] = PCUF_COLORFRAMEDEBUFF,
		["PositioningMode"] = positioningmode,
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
function Perl_Config_Button_OnClick(button)
	if (button == "LeftButton") then
		Perl_Config_Toggle();
	elseif (button == "RightButton") then
		local unlockedflag = 0;

		if (Perl_CombatDisplay_Frame) then
			if (Perl_CombatDisplay_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Focus_Frame) then
			if (Perl_Focus_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Party_Frame) then
			if (Perl_Party_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Party_Pet_Script_Frame) then
			if (Perl_Party_Pet_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Party_Target_Script_Frame) then
			if (Perl_Party_Target_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Player_Frame) then
			if (Perl_Player_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Player_Pet_Frame) then
			if (Perl_Player_Pet_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Target_Frame) then
			if (Perl_Target_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (Perl_Target_Target_Script_Frame) then
			if (Perl_Target_Target_Config[UnitName("player")]["Locked"] == 0) then
				unlockedflag = 1;
			end
		end

		if (unlockedflag == 1) then
			Perl_Config_Lock_Unlock(1);
		else
			Perl_Config_Lock_Unlock(0);
		end

		GameTooltip:Hide();
		Perl_Config_Button_Tooltip();
	end
end

function Perl_Config_Button_Tooltip()
	local unlockedflag = 0;

	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:SetText("Perl Classic Options");

	if (Perl_CombatDisplay_Frame) then
		if (type(Perl_CombatDisplay_Config[UnitName("player")]) == "table") then
			if (Perl_CombatDisplay_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Focus_Config[UnitName("player")]) == "table") then
			if (Perl_Focus_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Party_Config[UnitName("player")]) == "table") then
			if (Perl_Party_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Party_Pet_Config[UnitName("player")]) == "table") then
			if (Perl_Party_Pet_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Party_Target_Config[UnitName("player")]) == "table") then
			if (Perl_Party_Target_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Player_Config[UnitName("player")]) == "table") then
			if (Perl_Player_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Player_Pet_Config[UnitName("player")]) == "table") then
			if (Perl_Player_Pet_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Target_Config[UnitName("player")]) == "table") then
			if (Perl_Target_Config[UnitName("player")]["Locked"] == 0) then
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
		if (type(Perl_Target_Target_Config[UnitName("player")]) == "table") then
			if (Perl_Target_Target_Config[UnitName("player")]["Locked"] == 0) then
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


----------------------
-- myAddOns Support --
----------------------
function Perl_Config_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Config_myAddOns_Details = {
			name = "Perl_Config",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
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
