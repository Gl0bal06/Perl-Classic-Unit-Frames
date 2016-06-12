---------------
-- Variables --
---------------
Perl_CombatDisplay_Config = {};

-- Default Saved Variables (also set in Perl_CombatDisplay_GetVars)
local state = 3;
local manapersist = 0;
local healthpersist = 0;
local locked = 0;
local scale = 1;
local colorhealth = 0;		-- progressively colored health bars are off by default
local transparency = 1;		-- transparency for the frame
local showtarget = 0;
local mobhealthsupport = 1;

-- Default Local Variables
local healthfull = 0;
local InCombat = 0;
local Initialized = nil;
local IsAggroed = 0;
local manafull = 0;


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
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("VARIABLES_LOADED");

	table.insert(UnitPopupFrames,"Perl_CombatDisplay_DropDown");
	table.insert(UnitPopupFrames,"Perl_CombatDisplay_Target_DropDown");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Classic: CombatDisplay loaded successfully.");
	end
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
		if (arg1 == "target") then
			Perl_CombatDisplay_Target_Update_Health();
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
		if (arg1 == "target") then
			Perl_CombatDisplay_Target_Update_Mana();
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
		if (arg1 == "target") then
			Perl_CombatDisplay_Target_Update_Mana();
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
		if (arg1 == "target") then
			Perl_CombatDisplay_Target_Update_Mana();
		end
		return;
	elseif (event == "PLAYER_TARGET_CHANGED") then
		Perl_CombatDisplay_UpdateDisplay();
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

		-- Check if we loaded the mod already.
		if (Initialized) then
			Perl_CombatDisplay_UpdateBars();	-- what class are we? display the right color bars
			Perl_CombatDisplay_Update_Health();	-- make sure we dont display 0/0 on load
			Perl_CombatDisplay_Update_Mana();	-- make sure we dont display 0/0 on load
			Perl_CombatDisplay_UpdateDisplay();	-- what mode are we in?
			Perl_CombatDisplay_Set_Scale();		-- set the correct scale
			Perl_CombatDisplay_Set_Transparency();	-- set the transparency
		else
			Perl_CombatDisplay_Initialize();
		end
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_CombatDisplay") then
			Perl_CombatDisplay_myAddOns_Support();
		end
		return;
	else
		return;
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_CombatDisplay_Initialize()
	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_CombatDisplay_Config[UnitName("player")]) == "table") then
		Perl_CombatDisplay_GetVars();
	else
		Perl_CombatDisplay_UpdateVars();
	end

	-- Major config options.
	Perl_CombatDisplay_Initialize_Frame_Color();
	Perl_CombatDisplay_Target_Frame:Hide();

	Perl_CombatDisplay_UpdateBars();	-- Display the bars appropriate to your class
	Perl_CombatDisplay_UpdateDisplay();	-- Show or hide the window based on whats happening

	Initialized = 1;
end

function Perl_CombatDisplay_Initialize_Frame_Color()
	Perl_CombatDisplay_ManaFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_CombatDisplay_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_CombatDisplay_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_CPBarText:SetTextColor(1, 1, 1, 1);

	Perl_CombatDisplay_Target_ManaFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_CombatDisplay_Target_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_CombatDisplay_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
end


----------------------
-- Update Functions --
----------------------
function Perl_CombatDisplay_UpdateDisplay()
	if (state == 0) then
		Perl_CombatDisplay_Frame:Hide();
		Perl_CombatDisplay_Target_Frame:Hide();
		Perl_CombatDisplay_Frame:StopMovingOrSizing();
		Perl_CombatDisplay_Target_Frame:StopMovingOrSizing();
	elseif (state == 1) then
		Perl_CombatDisplay_Frame:Show();
		Perl_CombatDisplay_Target_Show();
	elseif (state == 2) then
		if (InCombat == 1) then
			Perl_CombatDisplay_Frame:Show();
			Perl_CombatDisplay_Target_Show();
		elseif (manapersist == 1 and manafull == 0) then
			Perl_CombatDisplay_Frame:Show();
			Perl_CombatDisplay_Target_Show();
		elseif (healthpersist == 1 and healthfull == 0) then
			Perl_CombatDisplay_Frame:Show();
			Perl_CombatDisplay_Target_Show();
		else
			Perl_CombatDisplay_Frame:Hide();
			Perl_CombatDisplay_Target_Frame:Hide();
			Perl_CombatDisplay_Frame:StopMovingOrSizing();
			Perl_CombatDisplay_Target_Frame:StopMovingOrSizing();
		end
	elseif (state == 3) then
		if (IsAggroed == 1) then
			Perl_CombatDisplay_Frame:Show();
			Perl_CombatDisplay_Target_Show();
		elseif (manapersist == 1 and manafull == 0) then
			Perl_CombatDisplay_Frame:Show();
			Perl_CombatDisplay_Target_Show();
		elseif (healthpersist == 1 and healthfull == 0) then
			Perl_CombatDisplay_Frame:Show();
			Perl_CombatDisplay_Target_Show();
		else
			Perl_CombatDisplay_Frame:Hide();
			Perl_CombatDisplay_Target_Frame:Hide();
			Perl_CombatDisplay_Frame:StopMovingOrSizing();
			Perl_CombatDisplay_Target_Frame:StopMovingOrSizing();
		end
	end
end

function Perl_CombatDisplay_Update_Health()
	local playerhealth = UnitHealth("player");
	local playerhealthmax = UnitHealthMax("player");

	if (UnitIsDead("player")) then				-- This prevents negative health
		playerhealth = 0;
	end

	if (colorhealth == 1) then
		local playerhealthpercent = floor(playerhealth/playerhealthmax*100+0.5);
		if ((playerhealthpercent <= 100) and (playerhealthpercent > 75)) then
			Perl_CombatDisplay_HealthBar:SetStatusBarColor(0, 0.8, 0);
			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
		elseif ((playerhealthpercent <= 75) and (playerhealthpercent > 50)) then
			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 1, 0);
			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		elseif ((playerhealthpercent <= 50) and (playerhealthpercent > 25)) then
			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 0.5, 0);
			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		else
			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 0, 0);
			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		end
	else
		Perl_CombatDisplay_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	Perl_CombatDisplay_HealthBar:SetMinMaxValues(0, playerhealthmax);
	Perl_CombatDisplay_HealthBar:SetValue(playerhealth);
	Perl_CombatDisplay_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
end

function Perl_CombatDisplay_Update_Mana()
	local playermana = UnitMana("player");
	local playermanamax = UnitManaMax("player");

	if (UnitIsDead("player")) then				-- This prevents negative mana
		playermana = 0;
	end

	Perl_CombatDisplay_ManaBar:SetMinMaxValues(0, playermanamax);
	Perl_CombatDisplay_ManaBar:SetValue(playermana);

	if (UnitPowerType("player") == 1) then
		Perl_CombatDisplay_ManaBarText:SetText(playermana);
	else
		Perl_CombatDisplay_ManaBarText:SetText(playermana.."/"..playermanamax);
	end
end

function Perl_CombatDisplay_Update_Combo_Points()
	Perl_CombatDisplay_CPBarText:SetText(GetComboPoints()..'/5');
	Perl_CombatDisplay_CPBar:SetValue(GetComboPoints());
end

function Perl_CombatDisplay_UpdateBars()
	local playerpower = UnitPowerType("player");

	-- Set power type specific events and colors.
	if (playerpower == 0) then		-- mana
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		-- Hide CP Bar
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
		Perl_CombatDisplay_CPBarText:Hide();
		Perl_CombatDisplay_ManaFrame:SetHeight(42);
		return;
	elseif (playerpower == 1) then		-- rage
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		-- Hide CP Bar
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
		Perl_CombatDisplay_CPBarText:Hide();
		Perl_CombatDisplay_ManaFrame:SetHeight(42);
		return;
	elseif (playerpower == 3) then		-- energy
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


-------------------------------
-- Update Functions (Target) --
-------------------------------
function Perl_CombatDisplay_Target_UpdateAll()
	if (UnitExists("target")) then
		Perl_CombatDisplay_Target_Update_Health();
		Perl_CombatDisplay_Target_Update_Mana();
		Perl_CombatDisplay_Target_UpdateBars();
	end
end

function Perl_CombatDisplay_Target_Update_Health()
	local targethealth = UnitHealth("target");
	local targethealthmax = UnitHealthMax("target");

	if (UnitIsDead("target")) then				-- This prevents negative health
		targethealth = 0;
	end

	if (colorhealth == 1) then
		local targethealthpercent = floor(targethealth/targethealthmax*100+0.5);
		if ((targethealthpercent <= 100) and (targethealthpercent > 75)) then
			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
		elseif ((targethealthpercent <= 75) and (targethealthpercent > 50)) then
			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 1, 0);
			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		elseif ((targethealthpercent <= 50) and (targethealthpercent > 25)) then
			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		else
			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 0, 0);
			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		end
	else
		Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	Perl_CombatDisplay_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
	Perl_CombatDisplay_Target_HealthBar:SetValue(targethealth);

	if (targethealthmax == 100) then
		-- Begin Mobhealth support
		if (mobhealthsupport == 1) then
			if (MobHealthFrame) then
				local index;
				if UnitIsPlayer("target") then
					index = UnitName("target");
				else
					index = UnitName("target")..":"..UnitLevel("target");
				end

				if ((MobHealthDB and MobHealthDB[index]) or (MobHealthPlayerDB and MobHealthPlayerDB[index])) then
					local s, e;
					local pts;
					local pct;

					if MobHealthDB[index] then
						if (type(MobHealthDB[index]) ~= "string") then
							Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."%");
						end
						s, e, pts, pct = string.find(MobHealthDB[index], "^(%d+)/(%d+)$");
					else
						if (type(MobHealthPlayerDB[index]) ~= "string") then
							Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."%");
						end
						s, e, pts, pct = string.find(MobHealthPlayerDB[index], "^(%d+)/(%d+)$");
					end

					if (pts and pct) then
						pts = pts + 0;
						pct = pct + 0;
						if (pct ~= 0) then
							pointsPerPct = pts / pct;
						else
							pointsPerPct = 0;
						end
					end

					local currentPct = UnitHealth("target");
					if (pointsPerPct > 0) then
						Perl_CombatDisplay_Target_HealthBarText:SetText(string.format("%d", (currentPct * pointsPerPct) + 0.5).."/"..string.format("%d", (100 * pointsPerPct) + 0.5).." | "..targethealth.."%");	-- Stored unit info from the DB
					end
				else
					Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."%");	-- Unit not in MobHealth DB
				end
			-- End MobHealth Support
			else
				Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."%");	-- MobHealth isn't installed
			end
		else	-- mobhealthsupport == 0
			Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."%");	-- MobHealth support is disabled
		end
	else
		Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);	-- Self/Party/Raid member
	end
end

function Perl_CombatDisplay_Target_Update_Mana()
	local targetmana = UnitMana("target");
	local targetmanamax = UnitManaMax("target");
	local targetpowertype = UnitPowerType("target");

	if (UnitIsDead("target")) then				-- This prevents negative mana
		targetmana = 0;
	end

	Perl_CombatDisplay_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
	Perl_CombatDisplay_Target_ManaBar:SetValue(targetmana);

	if (targetpowertype == 1 or targetpowertype == 2) then
		Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana);
	else
		Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
	end
end

function Perl_CombatDisplay_Target_UpdateBars()
	local targetmanamax = UnitManaMax("target");
	local targetpowertype = UnitPowerType("target");

	-- Set power type specific events and colors.
	if (targetmanamax == 0) then
		Perl_CombatDisplay_Target_ManaBar:Hide();
		Perl_CombatDisplay_Target_ManaBarBG:Hide();
		Perl_CombatDisplay_Target_ManaFrame:SetHeight(30);
	elseif (targetpowertype == 0) then	-- mana
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		Perl_CombatDisplay_Target_ManaBar:Show();
		Perl_CombatDisplay_Target_ManaBarBG:Show();
		Perl_CombatDisplay_Target_ManaFrame:SetHeight(42);
		return;
	elseif (targetpowertype == 1) then	-- rage
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		Perl_CombatDisplay_Target_ManaBar:Show();
		Perl_CombatDisplay_Target_ManaBarBG:Show();
		Perl_CombatDisplay_Target_ManaFrame:SetHeight(42);
		return;
	elseif (targetpowertype == 1) then	-- focus
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		Perl_CombatDisplay_Target_ManaBar:Show();
		Perl_CombatDisplay_Target_ManaBarBG:Show();
		Perl_CombatDisplay_Target_ManaFrame:SetHeight(42);
		return;
	elseif (targetpowertype == 3) then	-- energy
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		Perl_CombatDisplay_Target_ManaBar:Show();
		Perl_CombatDisplay_Target_ManaBarBG:Show();
		Perl_CombatDisplay_Target_ManaFrame:SetHeight(42);
		return;
	end
end

function Perl_CombatDisplay_Target_Show()
	if (showtarget == 1) then
		if (UnitExists("target")) then
			Perl_CombatDisplay_Target_Frame:Show();
			Perl_CombatDisplay_Target_UpdateAll();
		else
			Perl_CombatDisplay_Target_Frame:Hide();
		end
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_CombatDisplay_Set_State(newvalue)
	state = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_UpdateDisplay();
end

function Perl_CombatDisplay_Set_Health_Persistance(newvalue)
	healthpersist = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_UpdateDisplay();
end

function Perl_CombatDisplay_Set_Mana_Persistance(newvalue)
	manapersist = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_UpdateDisplay();
end

function Perl_CombatDisplay_Set_Progressive_Color(newvalue)
	colorhealth = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_UpdateDisplay();
end

function Perl_CombatDisplay_Set_Lock(newvalue)
	locked = newvalue;
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Target(newvalue)
	showtarget = newvalue;
	Perl_CombatDisplay_UpdateVars();
	if (showtarget == 0) then
		Perl_CombatDisplay_Target_Frame:Hide();
	end
	Perl_CombatDisplay_UpdateDisplay();
end

function Perl_CombatDisplay_Set_MobHealth(newvalue)
	mobhealthsupport = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Target_Update_Health();
end

function Perl_CombatDisplay_Set_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		scale = (number / 100);					-- convert the user input to a wow acceptable value
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_CombatDisplay_Frame:SetScale(unsavedscale);
	Perl_CombatDisplay_Target_Frame:SetScale(unsavedscale);
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);				-- convert the user input to a wow acceptable value
	end
	Perl_CombatDisplay_Frame:SetAlpha(transparency);
	Perl_CombatDisplay_Target_Frame:SetAlpha(transparency);
	Perl_CombatDisplay_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_CombatDisplay_GetVars()
	state = Perl_CombatDisplay_Config[UnitName("player")]["State"];
	locked = Perl_CombatDisplay_Config[UnitName("player")]["Locked"];
	healthpersist = Perl_CombatDisplay_Config[UnitName("player")]["HealthPersist"];
	manapersist = Perl_CombatDisplay_Config[UnitName("player")]["ManaPersist"];
	scale = Perl_CombatDisplay_Config[UnitName("player")]["Scale"];
	colorhealth = Perl_CombatDisplay_Config[UnitName("player")]["ColorHealth"];
	transparency = Perl_CombatDisplay_Config[UnitName("player")]["Transparency"];
	showtarget = Perl_CombatDisplay_Config[UnitName("player")]["ShowTarget"];
	mobhealthsupport = Perl_CombatDisplay_Config[UnitName("player")]["MobHealthSupport"];

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
	if (scale == nil) then
		scale = 1;
	end
	if (colorhealth == nil) then
		colorhealth = 0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (showtarget == nil) then
		showtarget = 0;
	end
	if (mobhealthsupport == nil) then
		mobhealthsupport = 1;
	end

	local vars = {
		["state"] = state,
		["manapersist"] = manapersist,
		["healthpersist"] = healthpersist,
		["locked"] = locked,
		["scale"] = scale,
		["colorhealth"] = colorhealth,
		["transparency"] = transparency,
		["showtarget"] = showtarget,
		["mobhealthsupport"] = mobhealthsupport,
	}
	return vars;
end

function Perl_CombatDisplay_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["State"] ~= nil) then
				state = vartable["Global Settings"]["State"];
			else
				state = nil;
			end
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["HealthPersist"] ~= nil) then
				healthpersist = vartable["Global Settings"]["HealthPersist"];
			else
				healthpersist = nil;
			end
			if (vartable["Global Settings"]["ManaPersist"] ~= nil) then
				manapersist = vartable["Global Settings"]["ManaPersist"];
			else
				manapersist = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["ColorHealth"] ~= nil) then
				colorhealth = vartable["Global Settings"]["ColorHealth"];
			else
				colorhealth = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["ShowTarget"] ~= nil) then
				showtarget = vartable["Global Settings"]["ShowTarget"];
			else
				showtarget = nil;
			end
			if (vartable["Global Settings"]["MobHealthSupport"] ~= nil) then
				mobhealthsupport = vartable["Global Settings"]["MobHealthSupport"];
			else
				mobhealthsupport = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
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
		if (scale == nil) then
			scale = 1;
		end
		if (colorhealth == nil) then
			colorhealth = 0;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (showtarget == nil) then
			showtarget = 0;
		end
		if (mobhealthsupport == nil) then
			mobhealthsupport = 1;
		end

		-- Call any code we need to activate them
		Perl_CombatDisplay_Set_Target(showtarget)
		Perl_CombatDisplay_Target_Update_Health();
		Perl_CombatDisplay_Set_Scale()
		Perl_CombatDisplay_Set_Transparency()
		Perl_CombatDisplay_UpdateDisplay();
	end

	Perl_CombatDisplay_Config[UnitName("player")] = {
		["State"] = state,
		["Locked"] = locked,
		["HealthPersist"] = healthpersist,
		["ManaPersist"] = manapersist,
		["Scale"] = scale,
		["ColorHealth"] = colorhealth,
		["Transparency"] = transparency,
		["ShowTarget"] = showtarget,
		["MobHealthSupport"] = mobhealthsupport,
	};
end


-------------------
-- Click Handler --
-------------------
function Perl_CombatDisplayDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_CombatDisplayDropDown_Initialize, "MENU");
end

function Perl_CombatDisplayDropDown_Initialize()
	UnitPopup_ShowMenu(Perl_CombatDisplay_DropDown, "SELF", "player");
end

function Perl_CombatDisplay_OnMouseDown(button)
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end

	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("player");
		elseif (CursorHasItem()) then
			DropItemOnUnit("player");
		else
			TargetUnit("player");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_CombatDisplay_DropDown, "Perl_CombatDisplay_Frame", 40, 0);
	end

	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_OnMouseUp(button)
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
end


function Perl_CombatDisplayTargetDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_CombatDisplayTargetDropDown_Initialize, "MENU");
end

function Perl_CombatDisplayTargetDropDown_Initialize()
	local menu = nil;
	if (UnitIsEnemy("target", "player")) then
		return;
	end
	if (UnitIsUnit("target", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("target", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("target")) then
		if (UnitInParty("target")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_CombatDisplay_Target_DropDown, menu, "target");
	end
end

function Perl_CombatDisplay_Target_OnMouseDown(button)
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end

	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("player");
		elseif (CursorHasItem()) then
			DropItemOnUnit("player");
		else
			TargetUnit("player");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_CombatDisplay_Target_DropDown, "Perl_CombatDisplay_Target_Frame", 40, 0);
	end

	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Target_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_Target_OnMouseUp(button)
	Perl_CombatDisplay_Target_Frame:StopMovingOrSizing();
end


----------------------
-- myAddOns Support --
----------------------
function Perl_CombatDisplay_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_CombatDisplay_myAddOns_Details = {
			name = "Perl_CombatDisplay",
			version = "v0.43",
			releaseDate = "February 16, 2006",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_CombatDisplay_myAddOns_Help = {};
		Perl_CombatDisplay_myAddOns_Help[1] = "/perlcombatdisplay\n/pcd\n";
		myAddOnsFrame_Register(Perl_CombatDisplay_myAddOns_Details, Perl_CombatDisplay_myAddOns_Help);
	end
end