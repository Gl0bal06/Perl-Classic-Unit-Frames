---------------
-- Variables --
---------------
Perl_CombatDisplay_Config = {};

-- Defaults (also set in Perl_CombatDisplay_GetVars)
local state = 3;
local locked = 0;
local manapersist = 0;
local healthpersist = 0;

local IsAggroed = 0;
local InCombat = 0;
local healthfull = 0;
local manafull = 0;
local Initialized = nil;


----------------------
-- Loading Function --
----------------------
function Perl_CombatDisplay_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTER_COMBAT");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LEAVE_COMBAT");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Slash Commands
	SlashCmdList["COMBATDISPLAY"] = Perl_CombatDisplay_SlashHandler;
	SLASH_COMBATDISPLAY1 = "/perlcombatdisplay";
	SLASH_COMBATDISPLAY2 = "/pcd";

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Combat Display by Perl loaded successfully.");
	end
	UIErrorsFrame:AddMessage("|cffffff00Combat Display by Perl loaded successfully.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
end


-------------------
-- Event Handler --
-------------------
function Perl_CombatDisplay_OnEvent(event)
	if (event == "UNIT_HEALTH") then
		if (arg1 == "player") then
			if (UnitHealth("player") == UnitHealthMax("player")) then
				healthfull = 1;
				if (healthpersist == 1) then
					Perl_CombatDisplay_UpdateDisplay();
				end
			else
				healthfull = 0;
			end
			Perl_CombatDisplay_Update_Health();
		end
		return;
	elseif (event == "UNIT_ENERGY") then
		if (arg1 == "player") then
			if (UnitMana("player") == UnitManaMax("player")) then
				manafull = 1;
				if (manapersist == 1) then
					Perl_CombatDisplay_UpdateDisplay();
				end
			else
				manafull = 0;
			end
			Perl_CombatDisplay_Update_Mana();
		end
		return;
	elseif (event == "UNIT_MANA") then
		if (arg1 == "player") then
			if (UnitMana("player") == UnitManaMax("player")) then
				manafull = 1;
				if (manapersist == 1) then
					Perl_CombatDisplay_UpdateDisplay();
				end
			else
				manafull = 0;
			end
			Perl_CombatDisplay_Update_Mana();
		end
		return;
	elseif (event == "UNIT_RAGE") then
		if (arg1 == "player") then
			if (UnitMana("player") == 0) then
				manafull = 1;
				if (manapersist == 1) then
					Perl_CombatDisplay_UpdateDisplay();
				end
			else
				manafull = 0;
			end
			Perl_CombatDisplay_Update_Mana();
		end
		return;
	elseif (event == "PLAYER_COMBO_POINTS") then
		Perl_CombatDisplay_Update_Combo_Points();
		return;
	elseif (event == "PLAYER_REGEN_ENABLED") then	-- Player no longer in combat (something has agro on you)
		IsAggroed = 0;
		if (state == 3) then
			Perl_CombatDisplay_UpdateDisplay();
		end
		return;
	elseif (event == "PLAYER_REGEN_DISABLED") then	-- Player in combat (something has agro on you)
		IsAggroed = 1;
		if (state == 3) then
			Perl_CombatDisplay_UpdateDisplay();
		end
		return;
	elseif (event == "PLAYER_ENTER_COMBAT") then	-- Player attacking (auto attack)
		InCombat = 1;
		if (state == 2) then
			Perl_CombatDisplay_UpdateDisplay();
		end
		return;
	elseif (event == "PLAYER_LEAVE_COMBAT") then	-- Player not attacking (auto attack)
		InCombat = 0;
		if (state == 2) then
			Perl_CombatDisplay_UpdateDisplay();
		end
		return;
	elseif (event == "UNIT_DISPLAYPOWER") then
		if (arg1 == "player") then
			Perl_CombatDisplay_UpdateBars();
			Perl_CombatDisplay_Update_Mana();
			if (InCombat == 0 and IsAggroed == 0) then
				if (state == 1) then
					Perl_CombatDisplay_Frame:Show();
				else
					Perl_CombatDisplay_Frame:Hide();
				end
			end
		end
		return;
	elseif ((event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD")) then
		local powertype = UnitPowerType("player");
		InCombat = 0;
		IsAggroed = 0;

		if (UnitHealth("player") == UnitHealthMax("player")) then
			healthfull = 1;
		else
			healthfull = 0;
		end
		if (powertype == 0 or powertype == 3) then
			if (UnitMana("player") == UnitManaMax("player")) then
				manafull = 1;
			else
				manafull = 0;
			end
		elseif (powertype == 1) then
			if (UnitMana("player") == 0) then
				manafull = 1;
			else
				manafull = 0;
			end
		end
		
		if (Initialized) then
			Perl_CombatDisplay_UpdateBars();
			Perl_CombatDisplay_UpdateDisplay();
			return;
		end
		Perl_CombatDisplay_Initialize();
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_CombatDisplay") then
			Perl_CombatDisplay_myAddOns_Support();
		end
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_CombatDisplay_SlashHandler(msg)
	Perl_CombatDisplay_Options_Toggle();
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_CombatDisplay_Initialize()
	-- Check if we loaded the mod already.
	if (Initialized) then
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_CombatDisplay_Config[UnitName("player")]) == "table") then
		Perl_CombatDisplay_GetVars();
	else
		Perl_CombatDisplay_UpdateVars();
	end

	-- Major config options.
	Perl_CombatDisplay_ManaFrame:SetBackdropColor(0, 0, 0, 0.5);
	Perl_CombatDisplay_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5);
	Perl_CombatDisplay_HealthBarText:SetTextColor(1,1,1,1);
	Perl_CombatDisplay_ManaBarText:SetTextColor(1,1,1,1);
	Perl_CombatDisplay_CPBarText:SetTextColor(1,1,1,1);

	Perl_CombatDisplay_UpdateBars();	-- Display the bars appropriate to your class
	Perl_CombatDisplay_Update_Health();	-- Get hp info
	Perl_CombatDisplay_Update_Mana();	-- Get power info
	Perl_CombatDisplay_UpdateDisplay();	-- Show or hide the window based on whats happening

	Initialized = 1;
end


----------------------
-- Update Functions --
----------------------
function Perl_CombatDisplay_UpdateDisplay()
	if (state == 0) then
		Perl_CombatDisplay_Frame:Hide();
		Perl_CombatDisplay_Frame:StopMovingOrSizing();
	elseif (state == 1) then
		Perl_CombatDisplay_Frame:Show();
	elseif (state == 2) then
		if (InCombat == 1) then
			Perl_CombatDisplay_Frame:Show();
		elseif (manapersist == 1 and manafull == 0) then
			Perl_CombatDisplay_Frame:Show();
		elseif (healthpersist == 1 and healthfull == 0) then
			Perl_CombatDisplay_Frame:Show();
		else
			Perl_CombatDisplay_Frame:Hide();
			Perl_CombatDisplay_Frame:StopMovingOrSizing();
		end
	elseif (state == 3) then
		if (IsAggroed == 1) then
			Perl_CombatDisplay_Frame:Show();
		elseif (manapersist == 1 and manafull == 0) then
			Perl_CombatDisplay_Frame:Show();
		elseif (healthpersist == 1 and healthfull == 0) then
			Perl_CombatDisplay_Frame:Show();
		else
			Perl_CombatDisplay_Frame:Hide();
			Perl_CombatDisplay_Frame:StopMovingOrSizing();
		end
	end
end

function Perl_CombatDisplay_Update_Health()
	local playerhealth = UnitHealth("player");
	local playerhealthmax = UnitHealthMax("player");

	Perl_CombatDisplay_HealthBar:SetMinMaxValues(0, playerhealthmax);
	Perl_CombatDisplay_HealthBar:SetValue(playerhealth);
	Perl_CombatDisplay_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
end

function Perl_CombatDisplay_Update_Mana()
	local playermana = UnitMana("player");
	local playermanamax = UnitManaMax("player");

	Perl_CombatDisplay_ManaBar:SetMinMaxValues(0, playermanamax);
	Perl_CombatDisplay_ManaBar:SetValue(playermana);
	Perl_CombatDisplay_ManaBarText:SetText(playermana.."/"..playermanamax);
end

function Perl_CombatDisplay_Update_Combo_Points()
	Perl_CombatDisplay_CPBarText:SetText(GetComboPoints()..'/5');
	Perl_CombatDisplay_CPBar:SetValue(GetComboPoints());
end

function Perl_CombatDisplay_UpdateBars()
	-- Set power type specific events and colors.
	if (UnitPowerType("player") == 0) then		-- mana
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		-- Hide CP Bar
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
		Perl_CombatDisplay_CPBarText:Hide();
		Perl_CombatDisplay_ManaFrame:SetHeight(42);
		return;
	elseif (UnitPowerType("player") == 1) then	-- rage
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		-- Hide CP Bar
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
		Perl_CombatDisplay_CPBarText:Hide();
		Perl_CombatDisplay_ManaFrame:SetHeight(42);
		return;
	elseif (UnitPowerType("player") == 3) then	-- energy
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
		return;
	end
end


----------------------
-- Config functions --
----------------------
function Perl_CombatDisplay_GetVars()
	state = Perl_CombatDisplay_Config[UnitName("player")]["State"];
	locked = Perl_CombatDisplay_Config[UnitName("player")]["Locked"];
	healthpersist = Perl_CombatDisplay_Config[UnitName("player")]["HealthPersist"];
	manapersist = Perl_CombatDisplay_Config[UnitName("player")]["ManaPersist"];

	if (state == nil) then
		state = 3;
	end
	if (locked == nil) then
		locked = 0;
	end
	if (healthpersist == nil) then
		healthpersist = 0;
	end
	if (manapersist == nil) then
		manapersist = 0;
	end

	local vars = {
		["state"] = state,
		["manapersist"] = manapersist,
		["healthpersist"] = healthpersist,
		["locked"] = locked,
	}
	return vars;
end

function Perl_CombatDisplay_UpdateVars()
	Perl_CombatDisplay_Config[UnitName("player")] = {
							["State"] = state,
							["Locked"] = locked,
							["HealthPersist"] = healthpersist,
							["ManaPersist"] = manapersist,
	};
end


------------------------------
-- Common Related Functions --
------------------------------
function Perl_CombatDisplay_SetVars (vartable)
	if (vartable["state"]) then
		state = vartable["state"];
	end
	if (vartable["healthpersist"]) then
		healthpersist = vartable["healthpersist"];
	end
	if (vartable["manapersist"]) then
		manapersist = vartable["manapersist"];
	end
	if (vartable["locked"]) then
		locked = vartable["locked"];
	end
	Perl_CombatDisplay_UpdateDisplay();
	Perl_CombatDisplay_UpdateVars();
end


-------------------
-- Click Handler --
-------------------
function Perl_CombatDisplay_OnMouseDown(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_OnMouseUp(button)
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
end


----------------------
-- myAddOns Support --
----------------------
function Perl_CombatDisplay_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_CombatDisplay_myAddOns_Details = {
			name = "Perl_CombatDisplay",
			version = "v0.14",
			releaseDate = "October 30, 2005",
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