---------------
-- Variables --
---------------
Perl_CombatDisplay_Config = {};

-- Defaults
local State = 1;
local ManaPersist = 1;
local HealthPersist = 0;
local IsAggroed = 0;
local InCombat = 0;
local ManaFull = 0;
local HealthFull = 0;
local Debug = 0;
local Locked = 0;
local Initialized = nil;
local VariablesLoaded = nil;


-------------------------
-- Debug Info Function --
-------------------------
function Perl_CombatDisplay_DebugPrint(message)
	if (Debug == 1) then
		DEFAULT_CHAT_FRAME:AddMessage(message);
	end
end


-----------------------
-- Obligatory OnLoad --
-----------------------
function Perl_CombatDisplay_OnLoad()
	-- Events
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_ENTER_COMBAT");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_LEVEL_UP");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

	-- Slash Commands
	SlashCmdList["COMBATDISPLAY"] = Perl_CombatDisplay_SlashHandler;
	SLASH_COMBATDISPLAY1 = "/perlcombatdisplay";
	SLASH_COMBATDISPLAY2 = "/pcd";

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display by Perl loaded successfully.");
	end
	UIErrorsFrame:AddMessage("|cffffff00Combat Display by Perl loaded successfully.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);

	Perl_CombatDisplay_DebugPrint("OnLoad function run.");
end


-------------------
-- Event Handler --
-------------------
function Perl_CombatDisplay_OnEvent(event)
	if (event == "UNIT_NAME_UPDATE") or (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD")then
		if (UnitName("player") == "Unknown Entity") then
			return
		else 
			Perl_CombatDisplay_UpdateBars();
			Perl_CombatDisplay_VarInit();
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "UNIT_MANA") then
		if (UnitPowerType("player") == 0) then
			if (UnitMana("player") == UnitManaMax("player")) then
				ManaFull = 1;
			else
				ManaFull = 0;
			end
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "UNIT_HEALTH") then
		if (UnitHealth("player") == UnitHealthMax("player")) then
			HealthFull = 1;
		else
			HealthFull = 0;
		end
		Perl_CombatDisplay_UpdateDisplay();
	elseif (event == "UNIT_RAGE") then
		if (UnitPowerType("player") == 1) then
			if (UnitMana("player") == 0) then
				ManaFull = 1;
			else
				ManaFull = 0;
			end
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "UNIT_ENERGY") then
		if (UnitPowerType("player") == 3) then
			if (UnitMana("player") == UnitManaMax("player")) then
				ManaFull = 1;
			else
				ManaFull = 0;
			end
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "PLAYER_COMBO_POINTS") then
		if (UnitPowerType("player") == 3) then
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then  -- Player no longer in combat.
		IsAggroed = 0;
		Perl_CombatDisplay_DebugPrint("IsAggroed set to 0");
		if (State == 3) then
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "PLAYER_REGEN_DISABLED") then  -- Player in combat.
		IsAggroed = 1;
		Perl_CombatDisplay_DebugPrint("IsAggroed set to 1");
		if (State == 3) then
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "PLAYER_ENTER_COMBAT") then  -- Player attacking.
		InCombat = 1;
		Perl_CombatDisplay_DebugPrint("InCombat set to 1");
		if (State == 2) then
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "PLAYER_LEAVE_COMBAT") then  -- Player not attacking.
		InCombat = 0;
		Perl_CombatDisplay_DebugPrint("InCombat set to 0");
		if (State == 2) then
			Perl_CombatDisplay_UpdateDisplay();
		end
	elseif (event == "PLAYER_LEVEL_UP") then
		Perl_CombatDisplay_ManaBar:SetMinMaxValues(0, UnitManaMax("player"));		
	elseif (event == "UNIT_DISPLAYPOWER") then
		Perl_CombatDisplay_UpdateBars();
	--elseif (event == "VARIABLES_LOADED") then
		--VariablesLoaded = 1;
	elseif (event == "ADDON_LOADED" and arg1 == "Perl_CombatDisplay") then
		Perl_CombatDisplay_myAddOns_Support();
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_CombatDisplay_SlashHandler (msg)
	Perl_CombatDisplay_Options_Toggle();
	--[[
	msg = string.lower(msg);
	if (string.find(msg, "show")) then
		Perl_CombatDisplay_SetShow();
	elseif (string.find(msg, "hide")) then
		Perl_CombatDisplay_SetHide();
	elseif (string.find(msg, "combat")) then
		Perl_CombatDisplay_SetCombat();
	elseif (string.find(msg, "aggro")) then
		Perl_CombatDisplay_SetAggro();
	elseif (string.find(msg, "persist mana")) then
		Perl_CombatDisplay_TogglePersist("mana");
	elseif (string.find(msg, "persist health")) then
		Perl_CombatDisplay_TogglePersist("health");
	elseif (string.find(msg, "debug")) then
		Perl_CombatDisplay_ToggleDebug();
	elseif (string.find(msg, "unlock")) then
		Perl_CombatDisplay_Unlock();
	elseif (string.find(msg, "lock")) then
		Perl_CombatDisplay_Lock();
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00<Perl_CombatDisplay>");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffhide - hide it.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffshow - show it.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffaggro - show/hide on gain/lose aggro.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffcombat - show/hide on enter/leave combat.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffpersist health - toggle CD to ManaPersist till health is full.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffpersist mana - toggle CD to ManaPersist till mana is full.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cfffffffflock - lock CD in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00> |cffffffffunlock - allow CD to be dragged.");
		
	end ]]--
end


-------------------
-- Click Handler --
-------------------
function Perl_CombatDisplay_OnMouseDown (button)
	if (button == "LeftButton" and Locked == 0) then
		Perl_CombatDisplay_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_OnMouseUp (button)
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
end


---------------------
-- Update Function --
---------------------
function Perl_CombatDisplay_UpdateDisplay ()

	-- set common variables
	local playermana = UnitMana("player");
	local playermanamax = UnitManaMax("player");
	--local playermanapercent = floor(UnitMana("player")/UnitManaMax("player")*100+0.5);
	local playerhealth = UnitHealth("player");
	local playerhealthmax = UnitHealthMax("player");
	--local playerhealthpercent = floor(UnitHealth("player")/UnitHealthMax("player")*100+0.5);
	--local playerxp = UnitXP("player");
	--local playerxpmax = UnitXPMax("player");
	--local playerxprest = GetXPExhaustion();
	--local playerlevel = UnitLevel("player");
	--local playerpower = UnitPowerType("player");
	
	Perl_CombatDisplay_HealthBar:SetMinMaxValues(0, playerhealthmax);
	Perl_CombatDisplay_ManaBar:SetMinMaxValues(0, playermanamax);
	
	Perl_CombatDisplay_HealthBar:SetValue(playerhealth);
	Perl_CombatDisplay_HealthBarText:SetText(playerhealth..'/'..playerhealthmax);
	Perl_CombatDisplay_ManaBar:SetValue(playermana);
	Perl_CombatDisplay_ManaBarText:SetText(playermana..'/'..playermanamax);
	
	Perl_CombatDisplay_CPBarText:SetText(GetComboPoints()..'/5');
	Perl_CombatDisplay_CPBar:SetValue(GetComboPoints());
	
	--if (getglobal('PERL_COMMON')) then
		--Perl_CombatDisplay_SetSmoothBarColor(Perl_CombatDisplay_HealthBar);
		--Perl_CombatDisplay_SetSmoothBarColor(Perl_CombatDisplay_HealthBarBG, Perl_CombatDisplay_HealthBar, 0.25);
	--end
			
	if (State == 0) then
		Perl_CombatDisplay_Frame:Hide();
		Perl_CombatDisplay_Frame:StopMovingOrSizing();
	elseif (State == 1) then
		Perl_CombatDisplay_Frame:Show();
	elseif (State == 2) then
		if (InCombat == 1) then
			Perl_CombatDisplay_Frame:Show();
		elseif (ManaPersist == 1 and ManaFull == 0) then
			Perl_CombatDisplay_Frame:Show();
		elseif (HealthPersist == 1 and HealthFull == 0) then
			Perl_CombatDisplay_Frame:Show();
		else
			Perl_CombatDisplay_Frame:Hide();
			Perl_CombatDisplay_Frame:StopMovingOrSizing();
		end
	elseif (State == 3) then
		if (IsAggroed == 1) then
			Perl_CombatDisplay_Frame:Show();
		elseif (ManaPersist == 1 and ManaFull == 0) then
			Perl_CombatDisplay_Frame:Show();
		elseif (HealthPersist == 1 and HealthFull == 0) then
			Perl_CombatDisplay_Frame:Show();
		else
			Perl_CombatDisplay_Frame:Hide();
			Perl_CombatDisplay_Frame:StopMovingOrSizing();
		end
	end
end


----------------------
-- Settings Setters --
----------------------
function Perl_CombatDisplay_SetHide ()
	State = 0;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame:Hide();
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display is now |cffffffffHidden|cffffff00.");
end

function Perl_CombatDisplay_SetShow ()
	State = 1;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame:Show();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display is now |cffffffffShown|cffffff00.");
end

function Perl_CombatDisplay_SetCombat()
	State = 2;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame:Hide();
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display will now show on |cffffffffAuto-Attack|cffffff00.");
end

function Perl_CombatDisplay_SetAggro()
	State = 3;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame:Hide();
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display will now show on |cffffffffAggro|cffffff00.");
end


function Perl_CombatDisplay_TogglePersist (persisttype)
	if (persisttype == "mana") then
		if (ManaPersist == 0) then
			ManaPersist = 1;
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display Mana-Persistance is now |cffffffffOn|cffffff00.");
		else
			ManaPersist = 0;
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display Mana-Persistance is now |cffffffffOff|cffffff00.");
		end
	elseif (persisttype == "health") then
		if (HealthPersist == 0) then
			HealthPersist = 1;
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display Health-Persistance is now |cffffffffOn|cffffff00.");
		else
			HealthPersist = 0;
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display Health-Persistance is now |cffffffffOff|cffffff00.");
		end
	end
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Lock ()
	Locked = 1;
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display is now |cffffffffLocked|cffffff00.");
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Unlock ()
	Locked = 0;
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display is now |cffffffffUnlocked|cffffff00.");
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_ToggleDebug ()
	if (Debug == 0) then
		Debug = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Debug mode is now |cffffffffOn|cffffff00.");
	else
		Debug = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Debug mode is now |cffffffffOff|cffffff00.");
	end
end

function Perl_CombatDisplay_UpdateVars()
	Perl_CombatDisplay_Config[UnitName("player")] = {
		["state"] = State,
		["manapersist"] = ManaPersist,
		["healthpersist"] = HealthPersist,
		["locked"] = Locked,
	}
end

function Perl_CombatDisplay_UpdateBars()
	-- Set power type specific events and colors.
	
	if (UnitPowerType("player") == 0) then
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		-- Hide CP Bar
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
		Perl_CombatDisplay_CPBarText:Hide();
		Perl_CombatDisplay_ManaFrame:SetHeight(42);
		
		return "Power = |cffffffffMana|cffffff00.  ";
	
	elseif (UnitPowerType("player") == 3) then
		this:RegisterEvent("PLAYER_COMBO_POINTS");
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);		
		-- Setup CP Bar
		Perl_CombatDisplay_CPBar:Show();
		Perl_CombatDisplay_CPBarBG:Show();
		Perl_CombatDisplay_CPBarText:Show();
		Perl_CombatDisplay_CPBarText:SetText('0/5');
		Perl_CombatDisplay_ManaFrame:SetHeight(54);
		Perl_CombatDisplay_CPBar:SetMinMaxValues(0,5);
		Perl_CombatDisplay_CPBar:SetValue(GetComboPoints());
	
		return "Power = |cffffffffEnergy|cffffff00.  ";
	
	elseif (UnitPowerType("player") == 1) then
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		-- Hide CP Bar
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
		Perl_CombatDisplay_CPBarText:Hide();
		Perl_CombatDisplay_ManaFrame:SetHeight(42);
		
		return "Power = |cffffffffRage|cffffff00.  ";
	end
end

-------------------
-- Init Function --
-------------------
function Perl_CombatDisplay_VarInit () 

	if (Initialized) then
		return;
	end

	local strstate;
	local strpersist;
	local strpower;
	local strlocked;
	
	-- Major config options.

	Perl_CombatDisplay_ManaFrame:SetBackdropColor(0, 0, 0, 0.5);
	Perl_CombatDisplay_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
	
	Perl_CombatDisplay_HealthBarText:SetTextColor(1,1,1,1);
	Perl_CombatDisplay_ManaBarText:SetTextColor(1,1,1,1);
	Perl_CombatDisplay_CPBarText:SetTextColor(1,1,1,1);

	-- Load Variables
	
	
	if (Perl_CombatDisplay_Config[UnitName("player")] == nil) then
		Perl_CombatDisplay_Config = {
			[UnitName("player")] = {
				["state"] = 1,
			}
		}
		State = 1;
	else
		State = Perl_CombatDisplay_Config[UnitName("player")]["state"];  -- Move value to internal variable.
	end
	
	if (Perl_CombatDisplay_Config[UnitName("player")]["healthpersist"] == nil) then
		Perl_CombatDisplay_Config[UnitName("player")]["healthpersist"] = 0;
		HealthPersist = 0;
	else
		HealthPersist = Perl_CombatDisplay_Config[UnitName("player")]["healthpersist"];
	end

	if (Perl_CombatDisplay_Config[UnitName("player")]["manapersist"] == nil) then
		Perl_CombatDisplay_Config[UnitName("player")]["manapersist"] = 0;
		ManaPersist = 0;
	else
		ManaPersist = Perl_CombatDisplay_Config[UnitName("player")]["manapersist"];
	end
		
	if (Perl_CombatDisplay_Config[UnitName("player")]["locked"] == nil) then
		Perl_CombatDisplay_Config[UnitName("player")]["locked"] = 0;
		Locked = 0;
	else
		Locked = Perl_CombatDisplay_Config[UnitName("player")]["locked"];
	end
	
	-- Setup strings for startup message.
	
	if (State == 1) then
		strstate = "State = |cffffffffShown|cffffff00.  ";
	elseif (State == 2) then
		strstate = "State = |cffffffffCombat|cffffff00.  ";
	elseif (State == 3) then
		strstate = "State = |cffffffffAggro|cffffff00.  ";
	else
		strstate = "State = |cffffffffHidden|cffffff00.  ";
	end
	
	if (Locked == 1) then
		strlocked = "Lock =|cffffffff On|cffffff00.  ";
	else
		strlocked = "Lock =|cffffffff Off|cffffff00.  ";
	end
	
	if (ManaPersist == 1 and HealthPersist == 1) then
		strpersist = "Persist = |cffffffffHealth, Mana|cffffff00.  ";
	elseif (ManaPersist == 1) then
		strpersist = "Persist = |cffffffffMana|cffffff00.  ";
	elseif (HealthPersist == 1) then
		strpersist = "Persist = |cffffffffHealth|cffffff00.  ";
	else
		strpersist = "Persist = |cffffffffOff|cffffff00.  ";
	end
	
	
	-- Set power type specific events and colors.
	
	strpower = Perl_CombatDisplay_UpdateBars();
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display: "..strpower..strstate..strpersist..strlocked);
	
	-- Settings for Perl_Common
	
	--if (getglobal('PERL_COMMON')) then
		--Perl_CombatDisplay_HealthBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
		--Perl_CombatDisplay_ManaBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
		--Perl_CombatDisplay_CPBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
	--end
	
	--Perl_CombatDisplay_UpdateBars();
	Perl_CombatDisplay_UpdateDisplay();
	
	Initialized = 1;
end


------------------------------
-- Common Related Functions --
------------------------------
function Perl_CombatDisplay_GetVars ()
	local vars = {
		["state"] = State,
		["manapersist"] = ManaPersist,
		["healthpersist"] = HealthPersist,
		["locked"] = Locked,
	}
	
	return vars;
end

function Perl_CombatDisplay_SetVars (vartable)
	if (vartable["state"]) then
		State = vartable["state"];
	end
	if (vartable["healthpersist"]) then
		HealthPersist = vartable["healthpersist"];
	end
	if (vartable["manapersist"]) then
		ManaPersist = vartable["manapersist"];
	end
	if (vartable["locked"]) then
		Locked = vartable["locked"];
	end
	Perl_CombatDisplay_UpdateDisplay();
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_SetSmoothBarColor (bar, refbar, alpha)
	
	if (not refbar) then
		refbar = bar;
	end
	
	if (not alpha) then
		alpha = 1;
	end
	
	if (bar) then
		local barmin, barmax = refbar:GetMinMaxValues();
		
		if (barmin == barmax) then
			return false;
		end
		
		local percentage = refbar:GetValue()/(barmax-barmin);
		
		local red;
		local green;
		
		if (percentage < 0.5) then
			red = 1;
			green = 2*percentage;
		else
			green = 1;
			red = 2*(1 - percentage);
		end
		
		bar:SetStatusBarColor(red, green, 0, alpha);
			
	else
		return false;
	end
	
	
end


----------------------
-- myAddOns Support --
----------------------
function Perl_CombatDisplay_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_CombatDisplay_myAddOns_Details = {
			name = "Perl_CombatDisplay",
			version = "v0.06",
			releaseDate = "October 16, 2005",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS,
			optionsframe = "Perl_CombatDisplay_Options_Frame"
		};
		Perl_CombatDisplay_myAddOns_Help = {};
		Perl_CombatDisplay_myAddOns_Help[1] = "/perlcombatdisplay\n/pcd\n";
		myAddOnsFrame_Register(Perl_CombatDisplay_myAddOns_Details, Perl_CombatDisplay_myAddOns_Help);
	end	
end