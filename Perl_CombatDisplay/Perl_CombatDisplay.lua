---------------
-- Variables --
---------------
Perl_CombatDisplay_Config = {};
local Perl_CombatDisplay_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_CombatDisplay_GetVars)
local state = 3;						-- hidden unless in combat by default
local manapersist = 0;					-- mana persist is off by default
local healthpersist = 0;				-- health persist is off by default
local locked = 0;						-- unlocked by default
local scale = 1.0;						-- default scale
local transparency = 1;					-- transparency for the frame
local showtarget = 0;					-- target frame is disabled by default
local showdruidbar = 0;					-- Druid Bar support is disabled by default
local showpetbars = 0;					-- Pet info is hidden by default
local rightclickmenu = 0;				-- The ability to open a menu from CombatDisplay is disabled by default
local displaypercents = 0;				-- percents are off by default
local showcp = 0;						-- combo points are hidden by default
local clickthrough = 0;					-- frames are clickable by default
local xpositioncd = 0;					-- default x position
local ypositioncd = 300;				-- default y position
local xpositioncdt = 0;					-- target default x position
local ypositioncdt = 350;				-- target default y position

-- Default Local Variables
local InCombat = 0;
local Initialized = nil;
local IsAggroed = 0;
local Perl_CombatDisplay_ManaBar_Time_Update_Rate = 0.1;		-- the update interval
local Perl_CombatDisplay_Target_ManaBar_Time_Update_Rate = 0.1;	-- the update interval
local Perl_CombatDisplay_DruidBar_Time_Update_Rate = 0.2;		-- the update interval
local healthfull = 0;
local manafull = 0;

-- Fade Bar Variables
local Perl_CombatDisplay_HealthBar_Fade_Color = 1;			-- the color fading interval
local Perl_CombatDisplay_ManaBar_Fade_Color = 1;			-- the color fading interval
--local Perl_CombatDisplay_DruidBar_Fade_Color = 1;			-- the color fading interval
--local Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_CPBar_Fade_Color = 1;				-- the color fading interval
local Perl_CombatDisplay_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_CombatDisplay_PetManaBar_Fade_Color = 1;			-- the color fading interval
local Perl_CombatDisplay_Target_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;		-- the color fading interval

-- Local variables to save memory
local playerhealth, playerhealthmax, playermana, playermanamax, playerpower, playerdruidbarmana, playerdruidbarmanamax, playerdruidbarmanapercent, pethealth, pethealthmax, petmana, petmanamax, targethealth, targethealthmax, targetmana, targetmanamax, targetpowertype, englishclass, playeronupdatemana, targetonupdatemana;


----------------------
-- Loading Function --
----------------------
function Perl_CombatDisplay_OnLoad(self)
	-- Variables
	self.lastMana = 0;

	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	--self:RegisterEvent("UNIT_COMBO_POINTS");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_HEALTH_FREQUENT");
	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_POWER_UPDATE");
	self:RegisterEvent("UNIT_POWER_FREQUENT");

	-- Scripts
	self:SetScript("OnEvent",
		function(self, event, ...)
			Perl_CombatDisplay_Events[event](self, ...);
		end
	);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetFrameLevel(Perl_CombatDisplay_ManaFrame:GetFrameLevel() + 2);
	Perl_CombatDisplay_HealthBarFadeBar:SetFrameLevel(Perl_CombatDisplay_HealthBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_ManaBarFadeBar:SetFrameLevel(Perl_CombatDisplay_ManaBar:GetFrameLevel() - 1);
	--Perl_CombatDisplay_DruidBarFadeBar:SetFrameLevel(Perl_CombatDisplay_DruidBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_CPBarFadeBar:SetFrameLevel(Perl_CombatDisplay_CPBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_PetHealthBarFadeBar:SetFrameLevel(Perl_CombatDisplay_PetHealthBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_PetManaBarFadeBar:SetFrameLevel(Perl_CombatDisplay_PetManaBar:GetFrameLevel() - 1);
end

function Perl_CombatDisplay_Target_OnLoad(self)
	-- Variables
	self.lastMana = 0;

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_CombatDisplay_Target_ManaFrame_CastClickOverlay:SetFrameLevel(Perl_CombatDisplay_Target_ManaFrame:GetFrameLevel() + 2);
	Perl_CombatDisplay_Target_HealthBarFadeBar:SetFrameLevel(Perl_CombatDisplay_Target_HealthBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_Target_ManaBarFadeBar:SetFrameLevel(Perl_CombatDisplay_Target_ManaBar:GetFrameLevel() - 1);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", "target");
end


------------
-- Events --
------------
function Perl_CombatDisplay_Events:UNIT_HEALTH(arg1)
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
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_Update_Health();
	elseif (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetHealth();
		end
	end
end
Perl_CombatDisplay_Events.UNIT_HEALTH_FREQUENT = Perl_CombatDisplay_Events.UNIT_HEALTH;
Perl_CombatDisplay_Events.UNIT_MAXHEALTH = Perl_CombatDisplay_Events.UNIT_HEALTH;

function Perl_CombatDisplay_Events:UNIT_POWER_UPDATE(arg1)
	local _;
	local powertype, _ = UnitPowerType(arg1);

	if (powertype == 0 or powertype == 2 or powertype == 3 ) then -- mana, focus, energy
		if (arg1 == "player") then
			if (UnitPower("player") == UnitPowerMax("player")) then
				manafull = 1;
				if (manapersist == 1) then
					Perl_CombatDisplay_UpdateDisplay();
				end
			else
				manafull = 0;
			end
			Perl_CombatDisplay_Update_Mana();
		elseif (arg1 == "target") then
			Perl_CombatDisplay_Target_Update_Mana();
		elseif (arg1 == "pet") then
			if (showpetbars == 1) then
				Perl_CombatDisplay_Update_PetMana();
			end
		end
	elseif (powertype == 1 or powertype == 6 or powertype == 8 or powertype == 11 or powertype == 17 or powertype == 18) then	-- rage, runic power, lunar, maelstrom, fury, pain
		if (arg1 == "player") then
			if (UnitPower("player") == 0) then
				manafull = 1;
				if (manapersist == 1) then
					Perl_CombatDisplay_UpdateDisplay();
				end
			else
				manafull = 0;
			end
			Perl_CombatDisplay_Update_Mana();
		elseif (arg1 == "target") then
			Perl_CombatDisplay_Target_Update_Mana();
		end
	-- elseif (powertype == 2 or powertype == 3) then	-- energy
	-- 	if (arg1 == "player") then
	-- 		if (UnitPower("player") == UnitPowerMax("player")) then
	-- 			manafull = 1;
	-- 			if (manapersist == 1) then
	-- 				Perl_CombatDisplay_UpdateDisplay();
	-- 			end
	-- 		else
	-- 			manafull = 0;
	-- 		end
	-- 		Perl_CombatDisplay_Update_Mana();
	-- 	elseif (arg1 == "target") then
	-- 		Perl_CombatDisplay_Target_Update_Mana();
	-- 	elseif (arg1 == "pet") then
	-- 		if (showpetbars == 1) then
	-- 			Perl_CombatDisplay_Update_PetMana();
	-- 		end
	-- 	end
	end

	if (arg1 == "player" or arg1 == "vehicle") then
		Perl_CombatDisplay_Update_Combo_Points();
	end
end
Perl_CombatDisplay_Events.UNIT_MAXPOWER = Perl_CombatDisplay_Events.UNIT_POWER_UPDATE;
Perl_CombatDisplay_Events.UNIT_POWER_FREQUENT = Perl_CombatDisplay_Events.UNIT_POWER_UPDATE;

function Perl_CombatDisplay_Events:PLAYER_TARGET_CHANGED()
	Perl_CombatDisplay_UpdateDisplay();
	Perl_CombatDisplay_Update_Combo_Points();
end

-- function Perl_CombatDisplay_Events:UNIT_COMBO_POINTS(arg1)
-- 	if (arg1 == "player" or arg1 == "vehicle") then
-- 		Perl_CombatDisplay_Update_Combo_Points();
-- 	end
-- end

function Perl_CombatDisplay_Events:PLAYER_REGEN_ENABLED()
	IsAggroed = 0;
	if (state == 3) then
		Perl_CombatDisplay_UpdateDisplay();
	end
end

function Perl_CombatDisplay_Events:PLAYER_REGEN_DISABLED()
	IsAggroed = 1;
	if (state == 3) then
		if (not InCombatLockdown()) then							-- REMOVE THIS CHECK WHEN YOU CAN
			Perl_CombatDisplay_Frame:Show();						-- Show the player frame if needed
			if (showtarget == 1) then
				RegisterUnitWatch(Perl_CombatDisplay_Target_Frame);	-- Register the target frame to show/hide on its own
			end
		end

		Perl_CombatDisplay_UpdateDisplay();
	end
end

function Perl_CombatDisplay_Events:PLAYER_SPECIALIZATION_CHANGED()
	Perl_CombatDisplay_CPBar:SetMinMaxValues(0, UnitPowerMax("player", 4));
	Perl_CombatDisplay_Update_Combo_Points();
end

function Perl_CombatDisplay_Events:UNIT_DISPLAYPOWER(arg1)
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
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_UpdateBars();
		Perl_CombatDisplay_Target_Update_Mana();
	elseif (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetManaBarColor();			-- What type of energy are we using now?
			Perl_CombatDisplay_Update_PetMana();					-- Update the energy info immediately
		end
	end
end

function Perl_CombatDisplay_Events:UNIT_AURA(arg1)
	if (arg1 == "player") then
		Perl_CombatDisplay_Buff_UpdateAll(arg1, Perl_CombatDisplay_ManaFrame);
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Buff_UpdateAll(arg1, Perl_CombatDisplay_Target_ManaFrame);
	end
end

function Perl_CombatDisplay_Events:UNIT_PET()
	Perl_CombatDisplay_CheckForPets();
end

function Perl_CombatDisplay_Events:PLAYER_LOGIN()
	local powertype = UnitPowerType("player");
	InCombat = 0;
	IsAggroed = 0;

	if (UnitHealth("player") == UnitHealthMax("player")) then
		healthfull = 1;
	else
		healthfull = 0;
	end
	if (powertype == 0 or powertype == 3) then
		if (UnitPower("player") == UnitPowerMax("player")) then
			manafull = 1;
		else
			manafull = 0;
		end
	elseif (powertype == 1) then
		if (UnitPower("player") == 0) then
			manafull = 1;
		else
			manafull = 0;
		end
	end

	Perl_CombatDisplay_Initialize();
end
Perl_CombatDisplay_Events.PLAYER_ENTERING_WORLD = Perl_CombatDisplay_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_CombatDisplay_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_CombatDisplay_UpdateBars();		-- what class are we? display the right color bars
		Perl_CombatDisplay_Update_Health();		-- make sure we dont display 0/0 on load
		Perl_CombatDisplay_Update_Mana();		-- make sure we dont display 0/0 on load
		Perl_CombatDisplay_UpdateDisplay();		-- what mode are we in?
		Perl_CombatDisplay_Set_Scale_Actual();	-- set the correct scale
		Perl_CombatDisplay_Set_Transparency();	-- set the transparency
		Perl_CombatDisplay_CheckForPets();		-- do we have a pet out?
		Perl_CombatDisplay_Update_Combo_Points();
		return;
	end

	if (PCUF_ENABLE_CLASSIC_SUPPORT == 0) then
		Perl_CombatDisplay_Frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	end

	-- Check if a previous exists, if not, enable by default.
	Perl_Config_Migrate_Vars_Old_To_New("CombatDisplay");
	if (type(Perl_CombatDisplay_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
		Perl_CombatDisplay_GetVars();
	else
		Perl_CombatDisplay_UpdateVars();
	end

	-- Major config options.
	Perl_CombatDisplay_Initialize_Frame_Color();
	Perl_CombatDisplay_Target_Frame:Hide();

	Perl_CombatDisplay_UpdateBars();			-- Display the bars appropriate to your class
	Perl_CombatDisplay_UpdateDisplay();			-- Show or hide the window based on whats happening
	Perl_CombatDisplay_CheckForPets();			-- do we have a pet out?

	Perl_CombatDisplay_Frame_Style();
	Perl_CombatDisplay_Buff_UpdateAll("player", Perl_CombatDisplay_ManaFrame);	-- call this so the energy ticker doesn't show up prematurely

	-- IFrameManager Support (Deprecated)
	Perl_CombatDisplay_Frame:SetUserPlaced(true);
	Perl_CombatDisplay_Target_Frame:SetUserPlaced(true);

	Initialized = 1;
end

function Perl_CombatDisplay_Initialize_Frame_Color()
	Perl_CombatDisplay_ManaFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_CombatDisplay_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_CombatDisplay_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_CPBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_PetHealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_PetManaBarText:SetTextColor(1, 1, 1, 1);

	Perl_CombatDisplay_Target_ManaFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_CombatDisplay_Target_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_CombatDisplay_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
end


----------------------
-- Update Functions --
----------------------
function Perl_CombatDisplay_UpdateDisplay()
	Perl_CombatDisplay_Target_HealthBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_CombatDisplay_Target_ManaBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_CombatDisplay_Target_HealthBar:SetValue(0);	-- Do this so we don't fade the bar on a fresh target switch
	Perl_CombatDisplay_Target_ManaBar:SetValue(0);		-- Do this so we don't fade the bar on a fresh target switch

	if (state == 1) then
		Perl_CombatDisplay_Target_UpdateAll();
	elseif (state == 3) then
		if (IsAggroed == 1) then
			-- Do nothing
		elseif (manapersist == 1 and manafull == 0) then
			-- Do nothing
		elseif (healthpersist == 1 and healthfull == 0) then
			-- Do nothing
		else
			if (InCombatLockdown()) then									-- remove this line when zoning issue is fixed
				Perl_Config_Queue_Add(Perl_CombatDisplay_UpdateDisplay);	-- remove this line when zoning issue is fixed
			else															-- remove this line when zoning issue is fixed
				Perl_CombatDisplay_Frame:Hide();
				UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
				Perl_CombatDisplay_Target_Frame:Hide();
			end																-- remove this line when zoning issue is fixed
			return;
		end
		Perl_CombatDisplay_Target_UpdateAll();
	end
end

function Perl_CombatDisplay_Update_Health()
	playerhealth = UnitHealth("player");
	playerhealthmax = UnitHealthMax("player");

	if (UnitIsDead("player") or UnitIsGhost("player")) then	-- This prevents negative health
		playerhealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (playerhealth < Perl_CombatDisplay_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and playerhealth > Perl_CombatDisplay_HealthBar:GetValue())) then
			Perl_CombatDisplay_HealthBarFadeBar:SetMinMaxValues(0, playerhealthmax);
			Perl_CombatDisplay_HealthBarFadeBar:SetValue(Perl_CombatDisplay_HealthBar:GetValue());
			Perl_CombatDisplay_HealthBarFadeBar:Show();
			Perl_CombatDisplay_HealthBar_Fade_Color = 1;
			Perl_CombatDisplay_HealthBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_CombatDisplay_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_HealthBar:SetMinMaxValues(0, playerhealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_HealthBar:SetValue(playerhealthmax - playerhealth);
	else
		Perl_CombatDisplay_HealthBar:SetValue(playerhealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local playerhealthpercent = floor(playerhealth/playerhealthmax*100+0.5);
--		if ((playerhealthpercent <= 100) and (playerhealthpercent > 75)) then
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((playerhealthpercent <= 75) and (playerhealthpercent > 50)) then
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((playerhealthpercent <= 50) and (playerhealthpercent > 25)) then
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = playerhealth / playerhealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_CombatDisplay_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_CombatDisplay_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (displaypercents == 0) then
		Perl_CombatDisplay_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
	else
		Perl_CombatDisplay_HealthBarText:SetText(playerhealth.."/"..playerhealthmax.." | "..floor(playerhealth/playerhealthmax*100+0.5).."%");
	end
end

function Perl_CombatDisplay_Update_Mana()
	playermana = UnitPower("player");
	playermanamax = UnitPowerMax("player");
	playerpower = UnitPowerType("player");

	if (UnitIsDead("player") or UnitIsGhost("player")) then					-- This prevents negative mana
		playermana = 0;
	end

	if (playermana ~= playermanamax) then
		Perl_CombatDisplay_ManaBar_OnUpdate_Frame:Show();
	else
		Perl_CombatDisplay_ManaBar_OnUpdate_Frame:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (playermana < Perl_CombatDisplay_Frame.lastMana or (PCUF_INVERTBARVALUES == 1 and playermana > Perl_CombatDisplay_Frame.lastMana)) then
			Perl_CombatDisplay_ManaBarFadeBar:SetMinMaxValues(0, playermanamax);
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_CombatDisplay_ManaBarFadeBar:SetValue(playermanamax - Perl_CombatDisplay_Frame.lastMana);
			else
				Perl_CombatDisplay_ManaBarFadeBar:SetValue(Perl_CombatDisplay_Frame.lastMana);
			end
			Perl_CombatDisplay_ManaBarFadeBar:Show();
			Perl_CombatDisplay_ManaBar_Fade_Color = 1;
			Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_ManaBar:SetMinMaxValues(0, playermanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_ManaBar:SetValue(playermanamax - playermana);
	else
		Perl_CombatDisplay_ManaBar:SetValue(playermana);
	end

	Perl_CombatDisplay_Frame.lastMana = playermana;

	Perl_CombatDisplay_Update_Mana_Text();

	if (showdruidbar == 1) then
		_, englishclass = UnitClass("player");
		if (englishclass == "DRUID" or englishclass == "MONK" or englishclass == "PRIEST" or englishclass == "SHAMAN") then
			if (playerpower > 0) then
				playerdruidbarmana = UnitPower("player", 0);
				playerdruidbarmanamax = UnitPowerMax("player", 0);
				playerdruidbarmanapercent = floor(playerdruidbarmana/playerdruidbarmanamax*100+0.5);

				if (playerdruidbarmanapercent == 100) then					-- This is to ensure the value isn't 1 or 2 mana under max when 100%
					playerdruidbarmana = playerdruidbarmanamax;
				end

		--		if (PCUF_FADEBARS == 1) then
		--			if (playerdruidbarmana < Perl_CombatDisplay_DruidBar:GetValue()) then
		--				Perl_CombatDisplay_DruidBarFadeBar:SetMinMaxValues(0, playerdruidbarmanamax);
		--				Perl_CombatDisplay_DruidBarFadeBar:SetValue(Perl_CombatDisplay_DruidBar:GetValue());
		--				Perl_CombatDisplay_DruidBarFadeBar:Show();
		--				Perl_CombatDisplay_DruidBar_Fade_Color = 1;
		--				Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = 0;
		--				Perl_CombatDisplay_DruidBar_Fade_OnUpdate_Frame:Show();
		--			end
		--		end

				Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, playerdruidbarmanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_CombatDisplay_DruidBar:SetValue(playerdruidbarmanamax - playerdruidbarmana);
				else
					Perl_CombatDisplay_DruidBar:SetValue(playerdruidbarmana);
				end

				-- Display the needed text
				if (displaypercents == 0) then
					Perl_CombatDisplay_DruidBarText:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
				else
					Perl_CombatDisplay_DruidBarText:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax.." | "..playerdruidbarmanapercent.."%");
				end
			else
				-- Hide it all (bars and text)
				Perl_CombatDisplay_DruidBarText:SetText();
				Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, 1);
				Perl_CombatDisplay_DruidBar:SetValue(0);
			end
		else
			-- Hide it all (bars and text)
			Perl_CombatDisplay_DruidBarText:SetText();
			Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, 1);
			Perl_CombatDisplay_DruidBar:SetValue(0);
		end
	end
end

function Perl_CombatDisplay_Update_Mana_Text()
	if (playerpower == 1 or playerpower == 6) then
		Perl_CombatDisplay_ManaBarText:SetText(playermana);
	else
		if (displaypercents == 0) then
			Perl_CombatDisplay_ManaBarText:SetText(playermana.."/"..playermanamax);
		else
			Perl_CombatDisplay_ManaBarText:SetText(playermana.."/"..playermanamax.." | "..floor(playermana/playermanamax*100+0.5).."%");
		end
	end
end

function Perl_CombatDisplay_OnUpdate_ManaBar(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if (self.TimeSinceLastUpdate > Perl_CombatDisplay_ManaBar_Time_Update_Rate) then
		self.TimeSinceLastUpdate = 0;

		--playeronupdatemana = UnitPower("player", UnitPowerType("player"));
		playeronupdatemana = UnitPower("player");

		if (PCUF_FADEBARS == 1) then
			if (playeronupdatemana < Perl_CombatDisplay_Frame.lastMana or (PCUF_INVERTBARVALUES == 1 and playeronupdatemana > Perl_CombatDisplay_Frame.lastMana)) then
				Perl_CombatDisplay_ManaBarFadeBar:SetMinMaxValues(0, playermanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_CombatDisplay_ManaBarFadeBar:SetValue(playermanamax - Perl_CombatDisplay_Frame.lastMana);
				else
					Perl_CombatDisplay_ManaBarFadeBar:SetValue(Perl_CombatDisplay_Frame.lastMana);
				end
				Perl_CombatDisplay_ManaBarFadeBar:Show();
				Perl_CombatDisplay_ManaBar_Fade_Color = 1;
				Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
				Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame:Show();
			end
		end

		if (playeronupdatemana ~= playermana) then
			playermana = playeronupdatemana;
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_CombatDisplay_ManaBar:SetValue(playermanamax - playeronupdatemana);
			else
				Perl_CombatDisplay_ManaBar:SetValue(playeronupdatemana);
			end
			Perl_CombatDisplay_Update_Mana_Text();
		end

		Perl_CombatDisplay_Frame.lastMana = playeronupdatemana;
	end
end

function Perl_CombatDisplay_Update_Combo_Points()
	if (showcp == 1) then
		local combopoints = GetComboPoints("vehicle","target");				-- How many Combo Points does the player have in their vehicle?
		local combopointsmax = 5;
		if (PCUF_ENABLE_CLASSIC_SUPPORT == 0) then
			if (combopoints == 0) then
				combopoints = UnitPower("player", 4);							-- We aren't in a vehicle, get regular combo points
				combopointsmax = UnitPowerMax("player", 4);
			end
		else
			if (combopoints == 0) then
				combopoints = GetComboPoints("player","target");
			end
		end

		if (PCUF_FADEBARS == 1) then
			if (combopoints < Perl_CombatDisplay_CPBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and combopoints > Perl_CombatDisplay_CPBar:GetValue())) then
				Perl_CombatDisplay_CPBarFadeBar:SetMinMaxValues(0, combopointsmax);
				Perl_CombatDisplay_CPBarFadeBar:SetValue(Perl_CombatDisplay_CPBar:GetValue());
				Perl_CombatDisplay_CPBarFadeBar:Show();
				Perl_CombatDisplay_CPBar_Fade_Color = 1;
				Perl_CombatDisplay_CPBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
				Perl_CombatDisplay_CPBar_Fade_OnUpdate_Frame:Show();
			end
		end

		Perl_CombatDisplay_CPBarText:SetText(combopoints..'/'..combopointsmax);
		if (PCUF_INVERTBARVALUES == 1) then
			Perl_CombatDisplay_CPBar:SetValue(5 - combopoints);
		else
			Perl_CombatDisplay_CPBar:SetValue(combopoints);
		end
	end
end

function Perl_CombatDisplay_UpdateBars()
	local _;
	playerpower, _ = UnitPowerType("player");

	-- Set power type specific events and colors.
	Perl_CombatDisplay_ManaBar:SetStatusBarColor(PERL_POWER_TYPE_COLORS[playerpower].r, PERL_POWER_TYPE_COLORS[playerpower].g, PERL_POWER_TYPE_COLORS[playerpower].b, 1);
	Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(PERL_POWER_TYPE_COLORS[playerpower].r, PERL_POWER_TYPE_COLORS[playerpower].g, PERL_POWER_TYPE_COLORS[playerpower].b, 0.25);

	if (playerpower == 3) then	-- energy
		Perl_CombatDisplay_Update_Combo_Points();	-- Setup CP Bar
	end
end

function Perl_CombatDisplay_CheckForPets()
	if (showpetbars == 1 and UnitExists("pet")) then
		Perl_CombatDisplay_Update_PetManaBarColor();
		Perl_CombatDisplay_Update_PetHealth();
		Perl_CombatDisplay_Update_PetMana();
	else
		Perl_CombatDisplay_PetHealthBar:SetMinMaxValues(0, 1);
		Perl_CombatDisplay_PetHealthBar:SetValue(0);
		Perl_CombatDisplay_PetHealthBarText:SetText();
		Perl_CombatDisplay_PetManaBar:SetMinMaxValues(0, 1);
		Perl_CombatDisplay_PetManaBar:SetValue(0);
		Perl_CombatDisplay_PetManaBarText:SetText();
	end
end

function Perl_CombatDisplay_Update_PetManaBarColor()
	local _;
	petpower, _ = UnitPowerType("pet");

	-- Set mana bar color
	Perl_CombatDisplay_PetManaBar:SetStatusBarColor(PERL_POWER_TYPE_COLORS[petpower].r, PERL_POWER_TYPE_COLORS[petpower].g, PERL_POWER_TYPE_COLORS[petpower].b, 1);
	Perl_CombatDisplay_PetManaBarBG:SetStatusBarColor(PERL_POWER_TYPE_COLORS[petpower].r, PERL_POWER_TYPE_COLORS[petpower].g, PERL_POWER_TYPE_COLORS[petpower].b, 0.25);
end

function Perl_CombatDisplay_Update_PetHealth()
	pethealth = UnitHealth("pet");
	pethealthmax = UnitHealthMax("pet");

	if (UnitIsDead("pet") or UnitIsGhost("pet")) then	-- This prevents negative health
		pethealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (pethealth < Perl_CombatDisplay_PetHealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and pethealth > Perl_CombatDisplay_PetHealthBar:GetValue())) then
			Perl_CombatDisplay_PetHealthBarFadeBar:SetMinMaxValues(0, pethealthmax);
			Perl_CombatDisplay_PetHealthBarFadeBar:SetValue(Perl_CombatDisplay_PetHealthBar:GetValue());
			Perl_CombatDisplay_PetHealthBarFadeBar:Show();
			Perl_CombatDisplay_PetHealthBar_Fade_Color = 1;
			Perl_CombatDisplay_PetHealthBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_CombatDisplay_PetHealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_PetHealthBar:SetMinMaxValues(0, pethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_PetHealthBar:SetValue(pethealthmax - pethealth);
	else
		Perl_CombatDisplay_PetHealthBar:SetValue(pethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local pethealthpercent = floor(pethealth/pethealthmax*100+0.5);
--		if ((pethealthpercent <= 100) and (pethealthpercent > 75)) then
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((pethealthpercent <= 75) and (pethealthpercent > 50)) then
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((pethealthpercent <= 50) and (pethealthpercent > 25)) then
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = pethealth / pethealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (displaypercents == 0) then
		Perl_CombatDisplay_PetHealthBarText:SetText(pethealth.."/"..pethealthmax);
	else
		Perl_CombatDisplay_PetHealthBarText:SetText(pethealth.."/"..pethealthmax.." | "..floor(pethealth/pethealthmax*100+0.5).."%");
	end
end

function Perl_CombatDisplay_Update_PetMana()
	petmana = UnitPower("pet");
	petmanamax = UnitPowerMax("pet");

	if (UnitIsDead("pet") or UnitIsGhost("pet")) then	-- This prevents negative mana
		petmana = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (petmana < Perl_CombatDisplay_PetManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and petmana > Perl_CombatDisplay_PetManaBar:GetValue())) then
			Perl_CombatDisplay_PetManaBarFadeBar:SetMinMaxValues(0, petmanamax);
			Perl_CombatDisplay_PetManaBarFadeBar:SetValue(Perl_CombatDisplay_PetManaBar:GetValue());
			Perl_CombatDisplay_PetManaBarFadeBar:Show();
			Perl_CombatDisplay_PetManaBar_Fade_Color = 1;
			Perl_CombatDisplay_PetManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_CombatDisplay_PetManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_PetManaBar:SetMinMaxValues(0, petmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_PetManaBar:SetValue(petmanamax - petmana);
	else
		Perl_CombatDisplay_PetManaBar:SetValue(petmana);
	end

	if (UnitPowerType("pet") == 2) then
		Perl_CombatDisplay_PetManaBarText:SetText(petmana);
	else
		if (displaypercents == 0) then
			Perl_CombatDisplay_PetManaBarText:SetText(petmana.."/"..petmanamax);
		else
			Perl_CombatDisplay_PetManaBarText:SetText(petmana.."/"..petmanamax.." | "..floor(petmana/petmanamax*100+0.5).."%");
		end
	end
end


-------------------------------
-- Update Functions (Target) --
-------------------------------
function Perl_CombatDisplay_Target_UpdateAll()
	if (showtarget == 1) then
		if (UnitExists("target")) then
			Perl_CombatDisplay_Target_Update_Health();
			Perl_CombatDisplay_Target_Update_Mana();
			Perl_CombatDisplay_Target_UpdateBars();
			Perl_CombatDisplay_Buff_UpdateAll("target", Perl_CombatDisplay_Target_ManaFrame);
		end
	end
end

function Perl_CombatDisplay_Target_Update_Health()
	targethealth = UnitHealth("target");
	targethealthmax = UnitHealthMax("target");

	if (UnitIsDead("target") or UnitIsGhost("target")) then	-- This prevents negative health
		targethealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (targethealth < Perl_CombatDisplay_Target_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targethealth > Perl_CombatDisplay_Target_HealthBar:GetValue())) then
			Perl_CombatDisplay_Target_HealthBarFadeBar:SetMinMaxValues(0, targethealthmax);
			Perl_CombatDisplay_Target_HealthBarFadeBar:SetValue(Perl_CombatDisplay_Target_HealthBar:GetValue());
			Perl_CombatDisplay_Target_HealthBarFadeBar:Show();
			Perl_CombatDisplay_Target_HealthBar_Fade_Color = 1;
			Perl_CombatDisplay_Target_HealthBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_CombatDisplay_Target_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_Target_HealthBar:SetValue(targethealthmax - targethealth);
	else
		Perl_CombatDisplay_Target_HealthBar:SetValue(targethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local targethealthpercent = floor(targethealth/targethealthmax*100+0.5);
--		if ((targethealthpercent <= 100) and (targethealthpercent > 75)) then
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((targethealthpercent <= 75) and (targethealthpercent > 50)) then
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((targethealthpercent <= 50) and (targethealthpercent > 25)) then
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = targethealth / targethealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (displaypercents == 0) then
		Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);
	else
		Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax.." | "..floor(targethealth/targethealthmax*100+0.5).."%");
	end
end

function Perl_CombatDisplay_Target_Update_Mana()
	targetmana = UnitPower("target");
	targetmanamax = UnitPowerMax("target");
	targetpowertype = UnitPowerType("target");

	if (targetmanamax == 0) then
		Perl_CombatDisplay_Target_ManaBarText:SetText();
		return;
	end

	if (UnitIsDead("target") or UnitIsGhost("target")) then	-- This prevents negative mana
		targetmana = 0;
	end

	if (targetmana ~= targetmanamax) then
		Perl_CombatDisplay_Target_ManaBar_OnUpdate_Frame:Show();
	else
		Perl_CombatDisplay_Target_ManaBar_OnUpdate_Frame:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (targetmana < Perl_CombatDisplay_Target_Frame.lastMana or (PCUF_INVERTBARVALUES == 1 and targetmana > Perl_CombatDisplay_Target_Frame.lastMana)) then
			Perl_CombatDisplay_Target_ManaBarFadeBar:SetMinMaxValues(0, targetmanamax);
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_CombatDisplay_Target_ManaBarFadeBar:SetValue(targetmanamax - Perl_CombatDisplay_Target_Frame.lastMana);
			else
				Perl_CombatDisplay_Target_ManaBarFadeBar:SetValue(Perl_CombatDisplay_Target_Frame.lastMana);
			end
			Perl_CombatDisplay_Target_ManaBarFadeBar:Show();
			Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;
			Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_Target_ManaBar:SetValue(targetmanamax - targetmana);
	else
		Perl_CombatDisplay_Target_ManaBar:SetValue(targetmana);
	end

	Perl_CombatDisplay_Target_Frame.lastMana = targetmana;

	Perl_CombatDisplay_Target_Update_Mana_Text();
end

function Perl_CombatDisplay_Target_Update_Mana_Text()
	if (targetpowertype == 1 or targetpowertype == 2 or targetpowertype == 6) then
		Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana);
	else
		if (displaypercents == 0) then
			Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
		else
			if (targetmanamax > 0) then
				Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax.." | "..floor(targetmana/targetmanamax*100+0.5).."%");
			else
				Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax.." | ".."0".."%");
			end
		end
	end
end

function Perl_CombatDisplay_Target_OnUpdate_ManaBar(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if (self.TimeSinceLastUpdate > Perl_CombatDisplay_Target_ManaBar_Time_Update_Rate) then
		self.TimeSinceLastUpdate = 0;

		--targetonupdatemana = UnitPower("target", UnitPowerType("target"));
		targetonupdatemana = UnitPower("target");

		if (PCUF_FADEBARS == 1) then
			if (targetonupdatemana < Perl_CombatDisplay_Target_Frame.lastMana or (PCUF_INVERTBARVALUES == 1 and targetonupdatemana > Perl_CombatDisplay_Target_Frame.lastMana)) then
				Perl_CombatDisplay_Target_ManaBarFadeBar:SetMinMaxValues(0, targetmanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_CombatDisplay_Target_ManaBarFadeBar:SetValue(targetmanamax - Perl_CombatDisplay_Target_Frame.lastMana);
				else
					Perl_CombatDisplay_Target_ManaBarFadeBar:SetValue(Perl_CombatDisplay_Target_Frame.lastMana);
				end
				Perl_CombatDisplay_Target_ManaBarFadeBar:Show();
				Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;
				Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
				Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame:Show();
			end
		end

		if (targetonupdatemana ~= targetmana) then
			targetmana = targetonupdatemana;
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_CombatDisplay_Target_ManaBar:SetValue(targetmanamax - targetonupdatemana);
			else
				Perl_CombatDisplay_Target_ManaBar:SetValue(targetonupdatemana);
			end
			Perl_CombatDisplay_Target_Update_Mana_Text();
		end

		Perl_CombatDisplay_Target_Frame.lastMana = targetonupdatemana;
	end
end

function Perl_CombatDisplay_Target_UpdateBars()
	local _;
	targetmanamax = UnitPowerMax("target");
	targetpowertype, _ = UnitPowerType("target");

	-- Set power type specific events and colors.
	if (targetmanamax == 0) then
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(0, 0, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(0, 0, 0, 0.25);
		Perl_CombatDisplay_Target_ManaBarText:SetText();
	elseif (targetpowertype) then
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(PERL_POWER_TYPE_COLORS[targetpowertype].r, PERL_POWER_TYPE_COLORS[targetpowertype].g, PERL_POWER_TYPE_COLORS[targetpowertype].b, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(PERL_POWER_TYPE_COLORS[targetpowertype].r, PERL_POWER_TYPE_COLORS[targetpowertype].g, PERL_POWER_TYPE_COLORS[targetpowertype].b, 0.25);
	else
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_CombatDisplay_HealthBar_Fade(self, elapsed)
	Perl_CombatDisplay_HealthBar_Fade_Color = Perl_CombatDisplay_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_CombatDisplay_HealthBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_HealthBar_Fade_Color, 0, Perl_CombatDisplay_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_HealthBarFadeBar:Hide();
		Perl_CombatDisplay_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_ManaBar_Fade(self, elapsed)
	Perl_CombatDisplay_ManaBar_Fade_Color = Perl_CombatDisplay_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (playerpower == 0) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color);
	elseif (playerpower == 1) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_ManaBar_Fade_Color, 0, 0, Perl_CombatDisplay_ManaBar_Fade_Color);
	elseif (playerpower == 3) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color, 0, Perl_CombatDisplay_ManaBar_Fade_Color);
	elseif (playerpower == 6) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_ManaBarFadeBar:Hide();
		Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

--function Perl_CombatDisplay_DruidBar_Fade(arg1)
--	Perl_CombatDisplay_DruidBar_Fade_Color = Perl_CombatDisplay_DruidBar_Fade_Color - arg1;
--	Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed + arg1;
--
--	Perl_CombatDisplay_DruidBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_DruidBar_Fade_Color, Perl_CombatDisplay_DruidBar_Fade_Color);
--
--	if (Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed > 1) then
--		Perl_CombatDisplay_DruidBar_Fade_Color = 1;
--		Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = 0;
--		Perl_CombatDisplay_DruidBarFadeBar:Hide();
--		Perl_CombatDisplay_DruidBar_Fade_OnUpdate_Frame:Hide();
--	end
--end

function Perl_CombatDisplay_CPBar_Fade(self, elapsed)
	Perl_CombatDisplay_CPBar_Fade_Color = Perl_CombatDisplay_CPBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_CombatDisplay_CPBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_CPBar_Fade_Color, 0, 0, Perl_CombatDisplay_CPBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_CPBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_CPBarFadeBar:Hide();
		Perl_CombatDisplay_CPBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_PetHealthBar_Fade(self, elapsed)
	Perl_CombatDisplay_PetHealthBar_Fade_Color = Perl_CombatDisplay_PetHealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_CombatDisplay_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_PetHealthBar_Fade_Color, 0, Perl_CombatDisplay_PetHealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_PetHealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_PetHealthBarFadeBar:Hide();
		Perl_CombatDisplay_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_PetManaBar_Fade(self, elapsed)
	Perl_CombatDisplay_PetManaBar_Fade_Color = Perl_CombatDisplay_PetManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("pet") == 0) then
		Perl_CombatDisplay_PetManaBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_PetManaBar_Fade_Color, Perl_CombatDisplay_PetManaBar_Fade_Color);
	elseif (UnitPowerType("pet") == 2) then
		Perl_CombatDisplay_PetManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_PetManaBar_Fade_Color, (Perl_CombatDisplay_PetManaBar_Fade_Color-0.5), 0, Perl_CombatDisplay_PetManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_PetManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_PetManaBarFadeBar:Hide();
		Perl_CombatDisplay_PetManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_Target_HealthBar_Fade(self, elapsed)
	Perl_CombatDisplay_Target_HealthBar_Fade_Color = Perl_CombatDisplay_Target_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_CombatDisplay_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_Target_HealthBar_Fade_Color, 0, Perl_CombatDisplay_Target_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_Target_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_Target_HealthBarFadeBar:Hide();
		Perl_CombatDisplay_Target_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_Target_ManaBar_Fade(self, elapsed)
	Perl_CombatDisplay_Target_ManaBar_Fade_Color = Perl_CombatDisplay_Target_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (targetpowertype == 0) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 1) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_Target_ManaBar_Fade_Color, 0, 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 2) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_Target_ManaBar_Fade_Color, (Perl_CombatDisplay_Target_ManaBar_Fade_Color-0.5), 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 3) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color, 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 6) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_CombatDisplay_Target_ManaBarFadeBar:Hide();
		Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_CombatDisplay_Frame_Style()
	local _;
	_, englishclass = UnitClass("player");

	Perl_CombatDisplay_ManaFrame:SetHeight(42);
	Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(42);

	if (state == 0) then		-- Always Hidden
		Perl_CombatDisplay_Frame:Hide();
		UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
		Perl_CombatDisplay_Target_Frame:Hide();
	elseif (state == 1) then	-- Always Shown
		Perl_CombatDisplay_Frame:Show();
		if (showtarget == 1) then
			Perl_CombatDisplay_Target_UpdateAll();
			RegisterUnitWatch(Perl_CombatDisplay_Target_Frame);
		else
			UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
			Perl_CombatDisplay_Target_Frame:Hide();
		end
	elseif (state == 3) then	-- On Agro
		UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
		Perl_CombatDisplay_Target_Frame:Hide();
	end

	if (showdruidbar == 1 and (englishclass == "DRUID" or englishclass == "MONK" or englishclass == "PRIEST" or englishclass == "SHAMAN")) then
		Perl_CombatDisplay_ManaFrame:SetHeight(Perl_CombatDisplay_ManaFrame:GetHeight() + 12);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(Perl_CombatDisplay_ManaFrame_CastClickOverlay:GetHeight() + 12);
		Perl_CombatDisplay_DruidBar:Show();
		Perl_CombatDisplay_DruidBarBG:Show();
		Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, 1);
		Perl_CombatDisplay_DruidBar:SetValue(0);
		Perl_CombatDisplay_DruidBarText:SetText();
		Perl_CombatDisplay_DruidBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_ManaBar", "BOTTOMLEFT", 0, -2);
	else
		Perl_CombatDisplay_DruidBar:Hide();
		Perl_CombatDisplay_DruidBarBG:Hide();
	end

	if (showcp == 1) then
		Perl_CombatDisplay_ManaFrame:SetHeight(Perl_CombatDisplay_ManaFrame:GetHeight() + 12);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(Perl_CombatDisplay_ManaFrame_CastClickOverlay:GetHeight() + 12);
		Perl_CombatDisplay_CPBar:Show();
		Perl_CombatDisplay_CPBarBG:Show();
		if (PCUF_ENABLE_CLASSIC_SUPPORT == 0) then
			Perl_CombatDisplay_CPBar:SetMinMaxValues(0, UnitPowerMax("player", 4));
		else
			Perl_CombatDisplay_CPBar:SetMinMaxValues(0, 5);
		end
		if (showdruidbar == 1 and (englishclass == "DRUID" or englishclass == "MONK" or englishclass == "PRIEST" or englishclass == "SHAMAN")) then
			Perl_CombatDisplay_CPBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_DruidBar", "BOTTOMLEFT", 0, -2);
		else
			Perl_CombatDisplay_CPBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_ManaBar", "BOTTOMLEFT", 0, -2);
		end
	else
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
	end

	if (showpetbars == 1) then
		Perl_CombatDisplay_ManaFrame:SetHeight(Perl_CombatDisplay_ManaFrame:GetHeight() + 24);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(Perl_CombatDisplay_ManaFrame_CastClickOverlay:GetHeight() + 24);
		Perl_CombatDisplay_PetHealthBar:Show();
		Perl_CombatDisplay_PetHealthBarBG:Show();
		Perl_CombatDisplay_PetManaBar:Show();
		Perl_CombatDisplay_PetManaBarBG:Show();
		if (showdruidbar == 1 and showcp == 0 and (englishclass == "DRUID" or englishclass == "MONK" or englishclass == "PRIEST" or englishclass == "SHAMAN")) then
			Perl_CombatDisplay_PetHealthBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_DruidBar", "BOTTOMLEFT", 0, -2);
		elseif (showdruidbar == 1 and showcp == 1 and (englishclass == "DRUID" or englishclass == "MONK" or englishclass == "PRIEST" or englishclass == "SHAMAN")) then
			Perl_CombatDisplay_PetHealthBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_CPBar", "BOTTOMLEFT", 0, -2);
		elseif (showcp == 1) then
			Perl_CombatDisplay_PetHealthBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_CPBar", "BOTTOMLEFT", 0, -2);
		end
		Perl_CombatDisplay_PetManaBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_PetHealthBar", "BOTTOMLEFT", 0, -2);
	else
		Perl_CombatDisplay_PetHealthBar:Hide();
		Perl_CombatDisplay_PetHealthBarBG:Hide();
		Perl_CombatDisplay_PetManaBar:Hide();
		Perl_CombatDisplay_PetManaBarBG:Hide();
	end

	if (clickthrough == 1) then
		Perl_CombatDisplay_Frame:EnableMouse(false);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:EnableMouse(false);
		Perl_CombatDisplay_Target_Frame:EnableMouse(false);
		Perl_CombatDisplay_Target_ManaFrame_CastClickOverlay:EnableMouse(false);
	else
		Perl_CombatDisplay_Frame:EnableMouse(true);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:EnableMouse(true);
		Perl_CombatDisplay_Target_Frame:EnableMouse(true);
		Perl_CombatDisplay_Target_ManaFrame_CastClickOverlay:EnableMouse(true);
	end

	Perl_CombatDisplay_Update_Mana();
	Perl_CombatDisplay_Update_Combo_Points();
	Perl_CombatDisplay_CheckForPets();
	Perl_CombatDisplay_UpdateDisplay();
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_CombatDisplay_Align_Horizontally()
	Perl_CombatDisplay_Frame:SetUserPlaced(true);
	Perl_CombatDisplay_Target_Frame:SetUserPlaced(true);
	Perl_CombatDisplay_Frame:ClearAllPoints();
	Perl_CombatDisplay_Target_Frame:ClearAllPoints();
	Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ((UIParent:GetWidth() / 2) / (1 - UIParent:GetEffectiveScale() + scale)) - (Perl_CombatDisplay_Frame:GetWidth() / 2), floor(Perl_CombatDisplay_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Frame:GetScale()) + 0.5))
	Perl_CombatDisplay_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ((UIParent:GetWidth() / 2) / (1 - UIParent:GetEffectiveScale() + scale)) - (Perl_CombatDisplay_Target_Frame:GetWidth() / 2), floor(Perl_CombatDisplay_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Target_Frame:GetScale()) + 0.5))
	Perl_CombatDisplay_Set_Frame_Position();
	end

function Perl_CombatDisplay_Set_State(newvalue)
	state = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Health_Persistence(newvalue)
	healthpersist = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Mana_Persistence(newvalue)
	manapersist = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Lock(newvalue)
	locked = newvalue;
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Target(newvalue)
	showtarget = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_DruidBar(newvalue)
	showdruidbar = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_PetBars(newvalue)
	showpetbars = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Right_Click(newvalue)
	rightclickmenu = newvalue;
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Display_Percents(newvalue)
	displaypercents = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Update_Health();
	Perl_CombatDisplay_Update_Mana();
	Perl_CombatDisplay_Target_UpdateAll();
end

function Perl_CombatDisplay_Set_ComboPoint_Bars(newvalue)
	showcp = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Click_Through(newvalue)
	clickthrough = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Frame_Position()
	xpositioncd = floor(Perl_CombatDisplay_Frame:GetLeft() + 0.5);
	ypositioncd = floor(Perl_CombatDisplay_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Frame:GetScale()) + 0.5);
	xpositioncdt = floor(Perl_CombatDisplay_Target_Frame:GetLeft() + 0.5);
	ypositioncdt = floor(Perl_CombatDisplay_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Target_Frame:GetScale()) + 0.5);
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);											-- convert the user input to a wow acceptable value
	end
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Set_Scale_Actual();
end

function Perl_CombatDisplay_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_CombatDisplay_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
		Perl_CombatDisplay_Frame:SetScale(unsavedscale);
		Perl_CombatDisplay_Target_Frame:SetScale(unsavedscale);
	end
end

function Perl_CombatDisplay_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);									-- convert the user input to a wow acceptable value
	end
	Perl_CombatDisplay_Frame:SetAlpha(transparency);
	Perl_CombatDisplay_Target_Frame:SetAlpha(transparency);
	Perl_CombatDisplay_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_CombatDisplay_GetVars(index, updateflag)
	if (index == nil) then
		index = GetRealmName("player").."-"..UnitName("player");
	end

	state = Perl_CombatDisplay_Config[index]["State"];
	locked = Perl_CombatDisplay_Config[index]["Locked"];
	healthpersist = Perl_CombatDisplay_Config[index]["HealthPersist"];
	manapersist = Perl_CombatDisplay_Config[index]["ManaPersist"];
	scale = Perl_CombatDisplay_Config[index]["Scale"];
	transparency = Perl_CombatDisplay_Config[index]["Transparency"];
	showtarget = Perl_CombatDisplay_Config[index]["ShowTarget"];
	showdruidbar = Perl_CombatDisplay_Config[index]["ShowDruidBar"];
	showpetbars = Perl_CombatDisplay_Config[index]["ShowPetBars"];
	rightclickmenu = Perl_CombatDisplay_Config[index]["RightClickMenu"];
	displaypercents = Perl_CombatDisplay_Config[index]["DisplayPercents"];
	showcp = Perl_CombatDisplay_Config[index]["ShowCP"];
	clickthrough = Perl_CombatDisplay_Config[index]["ClickThrough"];
	xpositioncd = Perl_CombatDisplay_Config[index]["XPositionCD"];
	ypositioncd = Perl_CombatDisplay_Config[index]["YPositionCD"];
	xpositioncdt = Perl_CombatDisplay_Config[index]["XPositionCDT"];
	ypositioncdt = Perl_CombatDisplay_Config[index]["YPositionCDT"];

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
		scale = 1.0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (showtarget == nil) then
		showtarget = 0;
	end
	if (showdruidbar == nil) then
		showdruidbar = 0;
	end
	if (showpetbars == nil) then
		showpetbars = 0;
	end
	if (rightclickmenu == nil) then
		rightclickmenu = 0;
	end
	if (displaypercents == nil) then
		displaypercents = 0;
	end
	if (showcp == nil) then
		showcp = 0;
	end
	if (clickthrough == nil) then
		clickthrough = 0;
	end
	if (xpositioncd == nil) then
		xpositioncd = 0;
	end
	if (ypositioncd == nil) then
		ypositioncd = 300;
	end
	if (xpositioncdt == nil) then
		xpositioncdt = 0;
	end
	if (ypositioncdt == nil) then
		ypositioncdt = 350;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_CombatDisplay_UpdateVars();

		-- Call any code we need to activate them
		Perl_CombatDisplay_Set_Target(showtarget);
		Perl_CombatDisplay_Target_Update_Health();
		Perl_CombatDisplay_Update_Mana();
		Perl_CombatDisplay_Set_Scale_Actual();
		Perl_CombatDisplay_Set_Transparency();
		Perl_CombatDisplay_Frame:ClearAllPoints();
		Perl_CombatDisplay_Target_Frame:ClearAllPoints();
		Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositioncd, ypositioncd);			-- Position the frame
		Perl_CombatDisplay_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositioncdt, ypositioncdt);	-- Position the frame
		Perl_CombatDisplay_UpdateDisplay();
		return;
	end

	local vars = {
		["state"] = state,
		["manapersist"] = manapersist,
		["healthpersist"] = healthpersist,
		["locked"] = locked,
		["scale"] = scale,
		["transparency"] = transparency,
		["showtarget"] = showtarget,
		["showdruidbar"] = showdruidbar,
		["showpetbars"] = showpetbars,
		["rightclickmenu"] = rightclickmenu,
		["displaypercents"] = displaypercents,
		["showcp"] = showcp,
		["clickthrough"] = clickthrough,
		["xpositioncd"] = xpositioncd,
		["ypositioncd"] = ypositioncd,
		["xpositioncdt"] = xpositioncdt,
		["ypositioncdt"] = ypositioncdt,
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
			if (vartable["Global Settings"]["ShowDruidBar"] ~= nil) then
				showdruidbar = vartable["Global Settings"]["ShowDruidBar"];
			else
				showdruidbar = nil;
			end
			if (vartable["Global Settings"]["ShowPetBars"] ~= nil) then
				showpetbars = vartable["Global Settings"]["ShowPetBars"];
			else
				showpetbars = nil;
			end
			if (vartable["Global Settings"]["RightClickMenu"] ~= nil) then
				rightclickmenu = vartable["Global Settings"]["RightClickMenu"];
			else
				rightclickmenu = nil;
			end
			if (vartable["Global Settings"]["DisplayPercents"] ~= nil) then
				displaypercents = vartable["Global Settings"]["DisplayPercents"];
			else
				displaypercents = nil;
			end
			if (vartable["Global Settings"]["ShowCP"] ~= nil) then
				showcp = vartable["Global Settings"]["ShowCP"];
			else
				showcp = nil;
			end
			if (vartable["Global Settings"]["ClickThrough"] ~= nil) then
				clickthrough = vartable["Global Settings"]["ClickThrough"];
			else
				clickthrough = nil;
			end

			if (vartable["Global Settings"]["XPositionCD"] ~= nil) then
				xpositioncd = vartable["Global Settings"]["XPositionCD"];
			else
				xpositioncd = nil;
			end
			if (vartable["Global Settings"]["YPositionCD"] ~= nil) then
				ypositioncd = vartable["Global Settings"]["YPositionCD"];
			else
				ypositioncd = nil;
			end
			if (vartable["Global Settings"]["XPositionCDT"] ~= nil) then
				xpositioncdt = vartable["Global Settings"]["XPositionCDT"];
			else
				xpositioncdt = nil;
			end
			if (vartable["Global Settings"]["YPositionCDT"] ~= nil) then
				ypositioncdt = vartable["Global Settings"]["YPositionCDT"];
			else
				ypositioncdt = nil;
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
			scale = 1.0;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (showtarget == nil) then
			showtarget = 0;
		end
		if (showdruidbar == nil) then
			showdruidbar = 0;
		end
		if (showpetbars == nil) then
			showpetbars = 0;
		end
		if (rightclickmenu == nil) then
			rightclickmenu = 0;
		end
		if (displaypercents == nil) then
			displaypercents = 0;
		end
		if (showcp == nil) then
			showcp = 0;
		end
		if (clickthrough == nil) then
			clickthrough = 0;
		end
		if (xpositioncd == nil) then
			xpositioncd = 0;
		end
		if (ypositioncd == nil) then
			ypositioncd = 300;
		end
		if (xpositioncdt == nil) then
			xpositioncdt = 0;
		end
		if (ypositioncdt == nil) then
			ypositioncdt = 350;
		end

		-- Call any code we need to activate them
		Perl_CombatDisplay_Set_Target(showtarget);
		Perl_CombatDisplay_Target_Update_Health();
		Perl_CombatDisplay_Update_Mana();
		Perl_CombatDisplay_Set_Scale_Actual();
		Perl_CombatDisplay_Set_Transparency();
		Perl_CombatDisplay_Frame:ClearAllPoints();
		Perl_CombatDisplay_Target_Frame:ClearAllPoints();
		Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositioncd, ypositioncd);			-- Position the frame
		Perl_CombatDisplay_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositioncdt, ypositioncdt);	-- Position the frame
		Perl_CombatDisplay_UpdateDisplay();
	end

	Perl_CombatDisplay_Config[GetRealmName("player").."-"..UnitName("player")] = {
		["State"] = state,
		["Locked"] = locked,
		["HealthPersist"] = healthpersist,
		["ManaPersist"] = manapersist,
		["Scale"] = scale,
		["Transparency"] = transparency,
		["ShowTarget"] = showtarget,
		["ShowDruidBar"] = showdruidbar,
		["ShowPetBars"] = showpetbars,
		["RightClickMenu"] = rightclickmenu,
		["DisplayPercents"] = displaypercents,
		["ShowCP"] = showcp,
		["ClickThrough"] = clickthrough,
		["XPositionCD"] = xpositioncd,
		["YPositionCD"] = ypositioncd,
		["XPositionCDT"] = xpositioncdt,
		["YPositionCDT"] = ypositioncdt,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_CombatDisplay_Buff_UpdateAll(unit, frame)
	local _;
	local debuffType;
	local curableDebuffFound = 0;

	for debuffnum=1,40 do											-- Start main debuff loop
		_, _, _, debuffType, _, _ = UnitDebuff(unit, debuffnum, 1);	-- Get the texture and debuff stacking information if any
		if (PCUF_COLORFRAMEDEBUFF == 1) then
			if (curableDebuffFound == 0) then
				if (UnitIsFriend("player", unit)) then
					if (debuffType) then
						if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
							local color = PerlDebuffTypeColor[debuffType];
							frame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							curableDebuffFound = 1;
							break;
						end
					end
				end
			end
		end
	end

	if (curableDebuffFound == 0) then
		frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end
end


-------------------
-- Click Handler --
-------------------
function Perl_CombatDisplay_CastClickOverlay_OnLoad(self)
	self:SetAttribute("unit", "player");
	self:SetAttribute("*type1", "target");
	self:SetAttribute("*type2", "togglemenu");
	self:SetAttribute("type2", "togglemenu");

	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_CombatDisplay_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_DragStop()
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
	Perl_CombatDisplay_Set_Frame_Position();
end

function Perl_CombatDisplay_Target_CastClickOverlay_OnLoad(self)
	self:SetAttribute("unit", "target");
	self:SetAttribute("*type1", "target");
	self:SetAttribute("*type2", "togglemenu");
	self:SetAttribute("type2", "togglemenu");

	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_CombatDisplay_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Target_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_Target_DragStop()
	Perl_CombatDisplay_Target_Frame:StopMovingOrSizing();
	Perl_CombatDisplay_Set_Frame_Position();
end
