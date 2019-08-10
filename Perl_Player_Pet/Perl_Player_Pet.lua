---------------
-- Variables --
---------------
Perl_Player_Pet_Config = {};
local Perl_Player_Pet_Events = {};	-- event manager
local _;
-- Default Saved Variables (also set in Perl_Player_Pet_GetVars)
local locked = 0;					-- unlocked by default
local showxp = 0;					-- xp bar is hidden by default
local scale = 1.0;					-- default scale for pet frame
local targetscale = 1.0;			-- default scale for pet target frame
local numpetbuffsshown = 16;		-- buff row is 16 long
local numpetdebuffsshown = 16;		-- debuff row is 16 long
local transparency = 1;				-- transparency for frames
local bufflocation = 4;				-- default buff location
local debufflocation = 5;			-- default debuff location
local buffsize = 12;				-- default buff size is 12
local debuffsize = 12;				-- default debuff size is 12
local showportrait = 0;				-- portrait is hidden by default
local threedportrait = 0;			-- 3d portraits are off by default
local portraitcombattext = 0;		-- Combat text is disabled by default on the portrait frame
local compactmode = 0;				-- compact mode is disabled by default
local hidename = 0;					-- name and level frame is enabled by default
local displaypettarget = 0;			-- pet's target is off by default
local classcolorednames = 0;		-- names are colored based on pvp status by default
local showfriendlyhealth = 0;		-- show numerical friendly health is disbaled by default
local displaycastablebuffs = 0;		-- display all buffs by default
local displaycurabledebuff = 0;		-- display all debuffs by default
local xposition = 30;				-- default x position
local yposition = -117;				-- default y position
local xpositiont = 198;				-- target default x position
local ypositiont = -117;			-- target default y position

-- Default Local Variables
local Initialized = nil;			-- waiting to be initialized
--local Perl_Player_Pet_Target_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Player_Pet_Target_Time_Update_Rate = 0.2;	-- the update interval
local mouseoverpettargethealthflag = 0;					-- are we showing detailed health info?
local mouseoverpettargetmanaflag = 0;					-- are we showing detailed mana info?

-- Fade Bar Variables
local Perl_Player_Pet_HealthBar_Fade_Color = 1;			-- the color fading interval
local Perl_Player_Pet_ManaBar_Fade_Color = 1;			-- the color fading interval
local Perl_Player_Pet_Target_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Player_Pet_Target_ManaBar_Fade_Color = 1;	-- the color fading interval

-- Local variables to save memory
local pethealth, pethealthmax, petmana, petmanamax, happiness, playerpetxp, playerpetxpmax, xptext, r, g, b, reaction, pettargethealth, pettargethealthmax, pettargethealthpercent, pettargetmana, pettargetmanamax, pettargetpower, raidpettargetindex, englishclass, bufffilter, debufffilter;


----------------------
-- Loading Functions --
----------------------
function Perl_Player_Pet_OnLoad(self)
	-- Combat Text
	CombatFeedback_Initialize(self, Perl_Player_Pet_HitIndicator, 30);

	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	--self:RegisterEvent("PLAYER_PET_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_COMBAT");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_HEALTH_FREQUENT");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_PET_EXPERIENCE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UNIT_POWER_UPDATE");
	--self:RegisterEvent("UNIT_SPELLMISS");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");

	-- Scripts
	self:SetScript("OnEvent",
		function(self, event, ...)
			Perl_Player_Pet_Events[event](self, ...);
		end
	);
	self:SetScript("OnUpdate", CombatFeedback_OnUpdate);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_Player_Pet_NameFrame_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_NameFrame:GetFrameLevel() + 1);
	Perl_Player_Pet_LevelFrame_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_LevelFrame:GetFrameLevel() + 2);
	Perl_Player_Pet_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_Pet_PortraitFrame_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_PortraitFrame:GetFrameLevel() + 2);
	Perl_Player_Pet_PortraitTextFrame:SetFrameLevel(Perl_Player_Pet_PortraitFrame:GetFrameLevel() + 1);
	Perl_Player_Pet_HealthBarFadeBar:SetFrameLevel(Perl_Player_Pet_HealthBar:GetFrameLevel() - 1);
	Perl_Player_Pet_ManaBarFadeBar:SetFrameLevel(Perl_Player_Pet_ManaBar:GetFrameLevel() - 1);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", "pet");

	-- Misc
	self.unit = "pet";
end

function Perl_Player_Pet_Target_OnLoad(self)
	-- Variables
	self.TimeSinceLastUpdate = 0;

	-- Scripts
	self:SetScript("OnUpdate", Perl_Player_Pet_Target_OnUpdate);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_Player_Pet_Target_NameFrame_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_Target_NameFrame:GetFrameLevel() + 1);
	Perl_Player_Pet_Target_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_Target_StatsFrame:GetFrameLevel() + 1);
	Perl_Player_Pet_Target_HealthBar_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_Target_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_Pet_Target_ManaBar_CastClickOverlay:SetFrameLevel(Perl_Player_Pet_Target_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_Pet_Target_HealthBarFadeBar:SetFrameLevel(Perl_Player_Pet_Target_HealthBar:GetFrameLevel() - 1);
	Perl_Player_Pet_Target_ManaBarFadeBar:SetFrameLevel(Perl_Player_Pet_Target_ManaBar:GetFrameLevel() - 1);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", "pettarget");

	-- Misc
	self.unit = "pettarget";
end


------------
-- Events --
------------
function Perl_Player_Pet_Events:UNIT_HEALTH(arg1)
	if (arg1 == "pet") then
		Perl_Player_Pet_Update_Health();						-- Update health values
	end
end
Perl_Player_Pet_Events.UNIT_HEALTH_FREQUENT = Perl_Player_Pet_Events.UNIT_HEALTH;
Perl_Player_Pet_Events.UNIT_MAXHEALTH = Perl_Player_Pet_Events.UNIT_HEALTH;

function Perl_Player_Pet_Events:UNIT_POWER_UPDATE(arg1, arg2)
	if (arg1 == "pet") then
		if (arg2 ~= "HAPPINESS") then
			Perl_Player_Pet_Update_Mana();						-- Update energy/mana/rage values
		else
			Perl_Player_PetFrame_SetHappiness();				-- Update pet happiness icon
		end

	end
end
Perl_Player_Pet_Events.UNIT_MAXPOWER = Perl_Player_Pet_Events.UNIT_POWER_UPDATE;

function Perl_Player_Pet_Events:UNIT_COMBAT(arg1)
	if (arg1 == "pet") then
		CombatFeedback_OnCombatEvent(Perl_Player_Pet_Frame, arg2, arg3, arg4, arg5);
	end
end

-- function Perl_Player_Pet_Events:UNIT_SPELLMISS(arg1)
-- 	if (arg1 == "pet") then
-- 		CombatFeedback_OnSpellMissEvent(arg2);
-- 	end
-- end

function Perl_Player_Pet_Events:UNIT_NAME_UPDATE(arg1)
	if (arg1 == "pet") then
		Perl_Player_Pet_NameBarText:SetText(UnitName("pet"));	-- Set name
	end
end

function Perl_Player_Pet_Events:UNIT_AURA(arg1)
	if (arg1 == "pet") then
		Perl_Player_Pet_Buff_UpdateAll();						-- Update the buff/debuff list
	end
end

function Perl_Player_Pet_Events:UNIT_PET_EXPERIENCE()
	if (showxp == 1) then
		Perl_Player_Pet_Update_Experience();					-- Set the experience bar info
	end
end

function Perl_Player_Pet_Events:UNIT_LEVEL(arg1)
	if (arg1 == "pet") then
		Perl_Player_Pet_LevelBarText:SetText(UnitLevel("pet"));	-- Set Level
	elseif (arg1 == "player") then
		Perl_Player_Pet_ShowXP();
	end
end

function Perl_Player_Pet_Events:UNIT_DISPLAYPOWER(arg1)
	if (arg1 == "pet") then
		Perl_Player_Pet_Update_Mana_Bar();						-- What type of energy are we using now?
		Perl_Player_Pet_Update_Mana();							-- Update the energy info immediately
	end
end

-- function Perl_Player_Pet_Events:PLAYER_PET_CHANGED()
-- 	Perl_Player_Pet_Update_Once();
-- end

function Perl_Player_Pet_Events:UNIT_PET(arg1)
	if (arg1 == "player") then
		Perl_Player_Pet_Update_Once();
	end
end

function Perl_Player_Pet_Events:UNIT_PORTRAIT_UPDATE(arg1)
	if (arg1 == "pet") then
		--Perl_Player_Pet_Update_Portrait();					-- Uncomment this line if the line below is ever removed
		Perl_Player_Pet_Update_Once();							-- As of 1.10 the stable is partially broken, this event however is always called after a pet is swapped, so we will just update the whole mod here too to ensure a clean switch.
	end
end
Perl_Player_Pet_Events.UNIT_MODEL_CHANGED = Perl_Player_Pet_Events.UNIT_PORTRAIT_UPDATE;

function Perl_Player_Pet_Events:UNIT_THREAT_SITUATION_UPDATE(arg1)
	if (arg1 == "pet") then
		Perl_Player_Pet_Update_Threat();
	end
end

function Perl_Player_Pet_Events:PLAYER_LOGIN()
	Perl_Player_Pet_Initialize();
end
Perl_Player_Pet_Events.PLAYER_ENTERING_WORLD = Perl_Player_Pet_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Player_Pet_Initialize()
	-- Check if we loaded the mod already.
	if (Initialized) then
		Perl_Player_Pet_Update_Once();
		Perl_Player_Pet_Set_Scale_Actual();	-- Set the scale
		Perl_Player_Pet_Set_Transparency();	-- Set transparency
		Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition, yposition);			-- Position the frame
		Perl_Player_Pet_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositiont, ypositiont);	-- Position the frame
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	Perl_Config_Migrate_Vars_Old_To_New("Player_Pet");
	if (type(Perl_Player_Pet_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
		Perl_Player_Pet_GetVars();
	else
		Perl_Player_Pet_UpdateVars();
	end

	-- Major config options.
	Perl_Player_Pet_Initialize_Frame_Color();
	Perl_Player_Pet_Reset_Buffs();			-- Set correct buff sizes
	Perl_Player_Pet_Set_Window_Layout();	-- Warlocks don't need the happiness frame

	-- Unregister and Hide the Blizzard frames
	Perl_clearBlizzardFrameDisable(PetFrame);

	-- IFrameManager Support (Deprecated)
	Perl_Player_Pet_Frame:SetUserPlaced(true);
	Perl_Player_Pet_Target_Frame:SetUserPlaced(true);

	-- WoW 2.0 Secure API Stuff
	RegisterUnitWatch(Perl_Player_Pet_Frame);

	Initialized = 1;
end

function Perl_Player_Pet_Initialize_Frame_Color()
	Perl_Player_Pet_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_LevelFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_BuffFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_DebuffFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_DebuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_PortraitFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	Perl_Player_Pet_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Player_Pet_ManaBarText:SetTextColor(1, 1, 1, 1);


	Perl_Player_Pet_Target_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_Target_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_Pet_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	Perl_Player_Pet_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Player_Pet_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
end


-------------------------
-- The Update Function --
-------------------------
function Perl_Player_Pet_Update_Once()
	if (UnitExists(Perl_Player_Pet_Frame:GetAttribute("unit"))) then	-- Show the frame if applicable
		Perl_Player_Pet_NameBarText:SetText(UnitName("pet"));			-- Set name
		Perl_Player_Pet_LevelBarText:SetText(UnitLevel("pet"));			-- Set Level
		Perl_Player_Pet_Update_Portrait();								-- Set the pet's portrait
		Perl_Player_Pet_Update_Health();								-- Set health
		Perl_Player_Pet_Update_Mana();									-- Set mana values
		Perl_Player_Pet_Update_Mana_Bar();								-- Set the type of mana
		Perl_Player_PetFrame_SetHappiness();							-- Set Happiness
		Perl_Player_Pet_Buff_Position_Update();							-- Set the buff positions
		Perl_Player_Pet_Buff_UpdateAll();								-- Set buff frame
		Perl_Player_Pet_Portrait_Combat_Text();							-- Set the combat text frame
		Perl_Player_Pet_ShowXP();										-- Are we showing the xp bar?
		Perl_Player_Pet_Update_Threat();								-- Update the threat icon if needed
	end
end

function Perl_Player_Pet_Update_Health()
	pethealth = UnitHealth("pet");
	pethealthmax = UnitHealthMax("pet");

	if (UnitIsDead("pet") or UnitIsGhost("pet")) then					-- This prevents negative health
		pethealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (pethealth < Perl_Player_Pet_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and pethealth > Perl_Player_Pet_HealthBar:GetValue())) then
			Perl_Player_Pet_HealthBarFadeBar:SetMinMaxValues(0, pethealthmax);
			Perl_Player_Pet_HealthBarFadeBar:SetValue(Perl_Player_Pet_HealthBar:GetValue());
			Perl_Player_Pet_HealthBarFadeBar:Show();
			Perl_Player_Pet_HealthBar_Fade_Color = 1;
			Perl_Player_Pet_HealthBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_Player_Pet_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Player_Pet_HealthBar:SetMinMaxValues(0, pethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Player_Pet_HealthBar:SetValue(pethealthmax - pethealth);
	else
		Perl_Player_Pet_HealthBar:SetValue(pethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local playerpethealthpercent = floor(pethealth/pethealthmax*100+0.5);
--		if ((playerpethealthpercent <= 100) and (playerpethealthpercent > 75)) then
--			Perl_Player_Pet_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((playerpethealthpercent <= 75) and (playerpethealthpercent > 50)) then
--			Perl_Player_Pet_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((playerpethealthpercent <= 50) and (playerpethealthpercent > 25)) then
--			Perl_Player_Pet_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_Player_Pet_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
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

		Perl_Player_Pet_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_Player_Pet_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_Player_Pet_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_Player_Pet_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (pethealthmax == 100) then
		Perl_Player_Pet_HealthBarText:SetText(pethealth.."%");
	else
		Perl_Player_Pet_HealthBarText:SetText(pethealth.."/"..pethealthmax);
	end
end

function Perl_Player_Pet_Update_Mana()
	petmana = UnitPower("pet");
	petmanamax = UnitPowerMax("pet");

	if (UnitIsDead("pet") or UnitIsGhost("pet")) then	-- This prevents negative mana
		petmana = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (petmana < Perl_Player_Pet_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and petmana > Perl_Player_Pet_ManaBar:GetValue())) then
			Perl_Player_Pet_ManaBarFadeBar:SetMinMaxValues(0, petmanamax);
			Perl_Player_Pet_ManaBarFadeBar:SetValue(Perl_Player_Pet_ManaBar:GetValue());
			Perl_Player_Pet_ManaBarFadeBar:Show();
			Perl_Player_Pet_ManaBar_Fade_Color = 1;
			Perl_Player_Pet_ManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_Player_Pet_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Player_Pet_ManaBar:SetMinMaxValues(0, petmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Player_Pet_ManaBar:SetValue(petmanamax - petmana);
	else
		Perl_Player_Pet_ManaBar:SetValue(petmana);
	end

	local _;
	_, englishclass = UnitClass("player");
	if (englishclass == "HUNTER") then
		Perl_Player_Pet_ManaBarText:SetText(petmana);
	else
		Perl_Player_Pet_ManaBarText:SetText(petmana.."/"..petmanamax);
	end
end

function Perl_Player_Pet_Update_Mana_Bar()
	local _;
	petpower, _ = UnitPowerType("pet");

	-- Set mana bar color
	if (UnitPowerType("pet") == 0) then
		Perl_Player_Pet_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Player_Pet_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	elseif (petpower) then
		Perl_Player_Pet_ManaBar:SetStatusBarColor(PERL_POWER_TYPE_COLORS[petpower].r, PERL_POWER_TYPE_COLORS[petpower].g, PERL_POWER_TYPE_COLORS[petpower].b, 1);
		Perl_Player_Pet_ManaBarBG:SetStatusBarColor(PERL_POWER_TYPE_COLORS[petpower].r, PERL_POWER_TYPE_COLORS[petpower].g, PERL_POWER_TYPE_COLORS[petpower].b, 0.25);
	end
end

function Perl_Player_PetFrame_SetHappiness()
	-- happiness = GetPetHappiness();

	-- if (happiness == 1) then
		-- Perl_Player_PetHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	-- elseif (happiness == 2) then
		-- Perl_Player_PetHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	-- elseif (happiness == 3) then
		 Perl_Player_PetHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
	-- end
end

function Perl_Player_Pet_ShowXP()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Player_Pet_ShowXP);
	else
		if (showxp == 0) then
			Perl_Player_Pet_XPBar:Hide();
			Perl_Player_Pet_XPBarBG:Hide();
			Perl_Player_Pet_XPBarText:SetText();
			Perl_Player_Pet_StatsFrame:SetHeight(34);
			Perl_Player_Pet_StatsFrame_CastClickOverlay:SetHeight(34);
		else
			local _;
			_, englishclass = UnitClass("player");
			if (englishclass == "HUNTER") then
				if (UnitLevel("pet") == UnitLevel("player")) then
					Perl_Player_Pet_XPBar:Hide();
					Perl_Player_Pet_XPBarBG:Hide();
					Perl_Player_Pet_XPBarText:SetText();
					Perl_Player_Pet_StatsFrame:SetHeight(34);
					Perl_Player_Pet_StatsFrame_CastClickOverlay:SetHeight(34);
				else
					Perl_Player_Pet_XPBar:Show();
					Perl_Player_Pet_XPBarBG:Show();
					Perl_Player_Pet_StatsFrame:SetHeight(45);
					Perl_Player_Pet_StatsFrame_CastClickOverlay:SetHeight(45);
					Perl_Player_Pet_Update_Experience();
				end
			else
				Perl_Player_Pet_XPBar:Hide();
				Perl_Player_Pet_XPBarBG:Hide();
				Perl_Player_Pet_XPBarText:SetText();
				Perl_Player_Pet_StatsFrame:SetHeight(34);
				Perl_Player_Pet_StatsFrame_CastClickOverlay:SetHeight(34);
			end
		end
	end
end

function Perl_Player_Pet_Update_Experience()
	-- XP Bar stuff
	playerpetxp, playerpetxpmax = GetPetExperience();

	Perl_Player_Pet_XPBar:SetMinMaxValues(0, playerpetxpmax);
	Perl_Player_Pet_XPBar:SetValue(playerpetxp);

	-- Set xp text
	xptext = playerpetxp.."/"..playerpetxpmax;

	Perl_Player_Pet_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);
	Perl_Player_Pet_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);
	Perl_Player_Pet_XPBarText:SetText(xptext);

	if (UnitLevel("pet") == UnitLevel("player")) then
		Perl_Player_Pet_ShowXP();
	end
end

function Perl_Player_Pet_Update_Portrait()
	if (showportrait == 1) then
		if (threedportrait == 0) then
			SetPortraitTexture(Perl_Player_Pet_Portrait, "pet");		-- Load the correct 2d graphic
		else
			if UnitIsVisible("pet") then
				Perl_Player_Pet_PortraitFrame_PetModel:SetUnit("pet");	-- Load the correct 3d graphic
				Perl_Player_Pet_Portrait:Hide();						-- Hide the 2d graphic
				Perl_Player_Pet_PortraitFrame_PetModel:Show();			-- Show the 3d graphic
				Perl_Player_Pet_PortraitFrame_PetModel:SetPortraitZoom(1);
			else
				SetPortraitTexture(Perl_Player_Pet_Portrait, "pet");	-- Load the correct 2d graphic
				Perl_Player_Pet_PortraitFrame_PetModel:Hide();			-- Hide the 3d graphic
				Perl_Player_Pet_Portrait:Show();						-- Show the 2d graphic
			end
		end
	end
end

function Perl_Player_Pet_Portrait_Combat_Text()
	if (portraitcombattext == 1) then
		Perl_Player_Pet_PortraitTextFrame:Show();
	else
		Perl_Player_Pet_PortraitTextFrame:Hide();
	end
end

function Perl_Player_Pet_Update_Threat()
	local status = UnitThreatSituation("pet");

	if (status == nil) then
		Perl_Player_Pet_ThreatIndicator:Hide();
		return;
	end

	if (status > 0 and PCUF_THREATICON == 1) then
		Perl_Player_Pet_ThreatIndicator:SetVertexColor(GetThreatStatusColor(status));
		Perl_Player_Pet_ThreatIndicator:Show();
	else
		Perl_Player_Pet_ThreatIndicator:Hide();
	end
end

function Perl_Player_Pet_Set_Window_Layout()
	Perl_Player_Pet_StatsFrame:ClearAllPoints();
	Perl_Player_Pet_LevelFrame:ClearAllPoints();
	local _;
	_, englishclass = UnitClass("player");
	if (englishclass == "HUNTER") then
		if (hidename == 1) then
			Perl_Player_Pet_LevelFrame:SetPoint("TOPLEFT", "Perl_Player_Pet_Frame", "TOPLEFT", 0, 0);
			Perl_Player_Pet_StatsFrame:SetPoint("TOPLEFT", "Perl_Player_Pet_Frame", "TOPLEFT", 28, 0);
		else
			Perl_Player_Pet_LevelFrame:SetPoint("TOPLEFT", "Perl_Player_Pet_Frame", "BOTTOMLEFT", 0, 2);
			Perl_Player_Pet_StatsFrame:SetPoint("TOPLEFT", "Perl_Player_Pet_NameFrame", "BOTTOMLEFT", 28, 2);
		end
		if (compactmode == 0) then
			Perl_Player_Pet_LevelFrame:Show();
			Perl_Player_Pet_Frame:SetWidth(170);
			Perl_Player_Pet_NameFrame:SetWidth(170);
			Perl_Player_Pet_NameFrame_CastClickOverlay:SetWidth(170);
			Perl_Player_Pet_StatsFrame:SetWidth(142);
			Perl_Player_Pet_StatsFrame_CastClickOverlay:SetWidth(142);
			Perl_Player_Pet_HealthBar:SetWidth(133);
			Perl_Player_Pet_HealthBarFadeBar:SetWidth(133);
			Perl_Player_Pet_HealthBarBG:SetWidth(133);
			Perl_Player_Pet_ManaBar:SetWidth(133);
			Perl_Player_Pet_ManaBarFadeBar:SetWidth(133);
			Perl_Player_Pet_ManaBarBG:SetWidth(133);
			Perl_Player_Pet_XPBar:SetWidth(133);
			Perl_Player_Pet_XPBarBG:SetWidth(133);
		else
			Perl_Player_Pet_LevelFrame:Show();
			Perl_Player_Pet_Frame:SetWidth(135);
			Perl_Player_Pet_NameFrame:SetWidth(135);
			Perl_Player_Pet_NameFrame_CastClickOverlay:SetWidth(135);
			Perl_Player_Pet_StatsFrame:SetWidth(107);
			Perl_Player_Pet_StatsFrame_CastClickOverlay:SetWidth(107);
			Perl_Player_Pet_HealthBar:SetWidth(98);
			Perl_Player_Pet_HealthBarFadeBar:SetWidth(98);
			Perl_Player_Pet_HealthBarBG:SetWidth(98);
			Perl_Player_Pet_ManaBar:SetWidth(98);
			Perl_Player_Pet_ManaBarFadeBar:SetWidth(98);
			Perl_Player_Pet_ManaBarBG:SetWidth(98);
			Perl_Player_Pet_XPBar:SetWidth(98);
			Perl_Player_Pet_XPBarBG:SetWidth(98);
		end
	else
		if (hidename == 1) then
			Perl_Player_Pet_StatsFrame:SetPoint("TOPLEFT", "Perl_Player_Pet_Frame", "TOPLEFT", 0, 0);
		else
			Perl_Player_Pet_StatsFrame:SetPoint("TOPLEFT", "Perl_Player_Pet_NameFrame", "BOTTOMLEFT", 0, 2);
		end

		if (compactmode == 0) then
			Perl_Player_Pet_LevelFrame:Hide();
			Perl_Player_Pet_Frame:SetWidth(170);
			Perl_Player_Pet_NameFrame:SetWidth(170);
			Perl_Player_Pet_NameFrame_CastClickOverlay:SetWidth(170);
			Perl_Player_Pet_StatsFrame:SetWidth(170);
			Perl_Player_Pet_StatsFrame_CastClickOverlay:SetWidth(170);
			Perl_Player_Pet_HealthBar:SetWidth(158);
			Perl_Player_Pet_HealthBarFadeBar:SetWidth(158);
			Perl_Player_Pet_HealthBarBG:SetWidth(158);
			Perl_Player_Pet_ManaBar:SetWidth(158);
			Perl_Player_Pet_ManaBarFadeBar:SetWidth(158);
			Perl_Player_Pet_ManaBarBG:SetWidth(158);
			Perl_Player_Pet_XPBar:SetWidth(158);
			Perl_Player_Pet_XPBarBG:SetWidth(158);
		else
			Perl_Player_Pet_LevelFrame:Hide();
			Perl_Player_Pet_Frame:SetWidth(135);
			Perl_Player_Pet_NameFrame:SetWidth(135);
			Perl_Player_Pet_NameFrame_CastClickOverlay:SetWidth(135);
			Perl_Player_Pet_StatsFrame:SetWidth(135);
			Perl_Player_Pet_StatsFrame_CastClickOverlay:SetWidth(135);
			Perl_Player_Pet_HealthBar:SetWidth(123);
			Perl_Player_Pet_HealthBarFadeBar:SetWidth(123);
			Perl_Player_Pet_HealthBarBG:SetWidth(123);
			Perl_Player_Pet_ManaBar:SetWidth(123);
			Perl_Player_Pet_ManaBarFadeBar:SetWidth(123);
			Perl_Player_Pet_ManaBarBG:SetWidth(123);
			Perl_Player_Pet_XPBar:SetWidth(123);
			Perl_Player_Pet_XPBarBG:SetWidth(123);
		end
	end

	if (hidename == 1) then
		Perl_Player_Pet_NameFrame:Hide();
	else
		Perl_Player_Pet_NameFrame:Show();
	end

	if (showportrait == 1) then
		Perl_Player_Pet_PortraitFrame:Show();
		if (threedportrait == 0) then
			Perl_Player_Pet_PortraitFrame_PetModel:Hide();	-- Hide the 3d graphic
			Perl_Player_Pet_Portrait:Show();				-- Show the 2d graphic
		end
	else
		Perl_Player_Pet_PortraitFrame:Hide();
	end

	if (displaypettarget == 1) then
		RegisterUnitWatch(Perl_Player_Pet_Target_Frame);
	else
		Perl_Player_Pet_Target_Frame:Hide();
		UnregisterUnitWatch(Perl_Player_Pet_Target_Frame);
	end

	Perl_Player_Pet_NameBarText:SetWidth(Perl_Player_Pet_NameFrame:GetWidth() - 30);
	Perl_Player_Pet_NameBarText:SetHeight(Perl_Player_Pet_NameFrame:GetHeight() - 10);
	Perl_Player_Pet_NameBarText:SetNonSpaceWrap(false);

	Perl_Player_Pet_Target_NameBarText:SetWidth(Perl_Player_Pet_Target_NameFrame:GetWidth() - 10);
	Perl_Player_Pet_Target_NameBarText:SetHeight(Perl_Player_Pet_Target_NameFrame:GetHeight() - 10);
	Perl_Player_Pet_Target_NameBarText:SetNonSpaceWrap(false);
end


--------------------------
-- Pet Target Functions --
--------------------------
function Perl_Player_Pet_Target_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	--Perl_Player_Pet_Target_Time_Elapsed = Perl_Player_Pet_Target_Time_Elapsed + arg1;
	if (self.TimeSinceLastUpdate > Perl_Player_Pet_Target_Time_Update_Rate) then
		self.TimeSinceLastUpdate = 0;

		if (UnitExists(Perl_Player_Pet_Target_Frame:GetAttribute("unit"))) then
			-- Begin: Set the name
			Perl_Player_Pet_Target_NameBarText:SetText(UnitName("pettarget"));
			-- End: Set the name

			-- Begin: Set the name text color
			if (UnitPlayerControlled("pettarget")) then					-- is it a player
				if (UnitCanAttack("pettarget", "player")) then			-- are we in an enemy controlled zone
					-- Hostile players are red
					if (not UnitCanAttack("player", "pettarget")) then	-- enemy is not pvp enabled
						r = 0.5;
						g = 0.5;
						b = 1.0;
					else												-- enemy is pvp enabled
						r = 1.0;
						g = 0.0;
						b = 0.0;
					end
				elseif (UnitCanAttack("player", "pettarget")) then		-- enemy in a zone controlled by friendlies or when we're a ghost
					-- Players we can attack but which are not hostile are yellow
					r = 1.0;
					g = 1.0;
					b = 0.0;
				elseif (UnitIsPVP("pettarget") and not UnitIsPVPSanctuary("pettarget") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
					-- Players we can assist but are PvP flagged are green
					r = 0.0;
					g = 1.0;
					b = 0.0;
				else													-- friendly non pvp enabled character
					-- All other players are blue (the usual state on the "blue" server)
					r = 0.5;
					g = 0.5;
					b = 1.0;
				end
				Perl_Player_Pet_Target_NameBarText:SetTextColor(r, g, b);
			elseif (not UnitPlayerControlled("pettarget") and UnitIsTapDenied("pettarget")) then
				Perl_Player_Pet_Target_NameBarText:SetTextColor(0.5,0.5,0.5);	-- not our tap
			else
				if (UnitIsVisible("pettarget")) then
					reaction = UnitReaction("pettarget", "player");
					if (reaction) then
						r = PERL_FACTION_BAR_COLORS[reaction].r;
						g = PERL_FACTION_BAR_COLORS[reaction].g;
						b = PERL_FACTION_BAR_COLORS[reaction].b;
						Perl_Player_Pet_Target_NameBarText:SetTextColor(r, g, b);
					else
						Perl_Player_Pet_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
					end
				else
					if (UnitCanAttack("pettarget", "player")) then		-- are we in an enemy controlled zone
						-- Hostile players are red
						if (not UnitCanAttack("player", "pettarget")) then	-- enemy is not pvp enabled
							r = 0.5;
							g = 0.5;
							b = 1.0;
						else											-- enemy is pvp enabled
							r = 1.0;
							g = 0.0;
							b = 0.0;
						end
					elseif (UnitCanAttack("player", "pettarget")) then	-- enemy in a zone controlled by friendlies or when we're a ghost
						-- Players we can attack but which are not hostile are yellow
						r = 1.0;
						g = 1.0;
						b = 0.0;
					elseif (UnitIsPVP("pettarget") and not UnitIsPVPSanctuary("pettarget") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
						-- Players we can assist but are PvP flagged are green
						r = 0.0;
						g = 1.0;
						b = 0.0;
					else												-- friendly non pvp enabled character
						-- All other players are blue (the usual state on the "blue" server)
						r = 0.5;
						g = 0.5;
						b = 1.0;
					end
					Perl_Player_Pet_Target_NameBarText:SetTextColor(r, g, b);
				end
			end

			if (classcolorednames == 1) then
				if (UnitIsPlayer("pettarget")) then
					local _;
					_, englishclass = UnitClass("pettarget");
					Perl_Player_Pet_Target_NameBarText:SetTextColor(PERL_RAID_CLASS_COLORS[englishclass].r,PERL_RAID_CLASS_COLORS[englishclass].g,PERL_RAID_CLASS_COLORS[englishclass].b);
				end
			end
			-- End: Set the name text color

			-- Begin: Update the health bar
			pettargethealth = UnitHealth("pettarget");
			pettargethealthmax = UnitHealthMax("pettarget");
			pettargethealthpercent = floor(pettargethealth/pettargethealthmax*100+0.5);

			if (UnitIsDead("pettarget") or UnitIsGhost("pettarget")) then	-- This prevents negative health
				pettargethealth = 0;
				pettargethealthpercent = 0;
			end

			Perl_Player_Pet_Target_HealthBar_Fade_Check();

			Perl_Player_Pet_Target_HealthBar:SetMinMaxValues(0, pettargethealthmax);
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_Player_Pet_Target_HealthBar:SetValue(pettargethealthmax - pettargethealth);
			else
				Perl_Player_Pet_Target_HealthBar:SetValue(pettargethealth);
			end

			if (PCUF_COLORHEALTH == 1) then
--				if ((pettargethealthpercent <= 100) and (pettargethealthpercent > 75)) then
--					Perl_Player_Pet_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
--					Perl_Player_Pet_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--				elseif ((pettargethealthpercent <= 75) and (pettargethealthpercent > 50)) then
--					Perl_Player_Pet_Target_HealthBar:SetStatusBarColor(1, 1, 0);
--					Perl_Player_Pet_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--				elseif ((pettargethealthpercent <= 50) and (pettargethealthpercent > 25)) then
--					Perl_Player_Pet_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
--					Perl_Player_Pet_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--				else
--					Perl_Player_Pet_Target_HealthBar:SetStatusBarColor(1, 0, 0);
--					Perl_Player_Pet_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--				end

				local rawpercent = pettargethealth / pettargethealthmax;
				local red, green;

				if(rawpercent > 0.5) then
					red = (1.0 - rawpercent) * 2;
					green = 1.0;
				else
					red = 1.0;
					green = rawpercent * 2;
				end

				Perl_Player_Pet_Target_HealthBar:SetStatusBarColor(red, green, 0, 1);
				Perl_Player_Pet_Target_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
			else
				Perl_Player_Pet_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
				Perl_Player_Pet_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
			end

			if (mouseoverpettargethealthflag == 1) then
				Perl_Player_Pet_Target_HealthShow();
			else
				if (showfriendlyhealth == 1) then
					if (pettargethealthmax == 100) then
						Perl_Player_Pet_Target_HealthBarText:SetText(pettargethealthpercent.."%");
					else
						Perl_Player_Pet_Target_HealthBarText:SetText(pettargethealth.."/"..pettargethealthmax);
					end
				else
					Perl_Player_Pet_Target_HealthBarText:SetText(pettargethealthpercent.."%");
				end
			end
			-- End: Update the health bar

			-- Begin: Update the mana bar
			pettargetmana = UnitPower("pettarget");
			pettargetmanamax = UnitPowerMax("pettarget");

			if (UnitIsDead("pettarget") or UnitIsGhost("pettarget")) then	-- This prevents negative mana
				pettargetmana = 0;
			end

			Perl_Player_Pet_Target_ManaBar_Fade_Check();

			Perl_Player_Pet_Target_ManaBar:SetMinMaxValues(0, pettargetmanamax);
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_Player_Pet_Target_ManaBar:SetValue(pettargetmanamax - pettargetmana);
			else
				Perl_Player_Pet_Target_ManaBar:SetValue(pettargetmana);
			end

			if (mouseoverpettargetmanaflag == 1) then
				if (UnitPowerType("pettarget") == 1 or UnitPowerType("pettarget") == 2 or UnitPowerType("pettarget") == 6) then
					Perl_Player_Pet_Target_ManaBarText:SetText(pettargetmana);
				else
					Perl_Player_Pet_Target_ManaBarText:SetText(pettargetmana.."/"..pettargetmanamax);
				end
			else
				Perl_Player_Pet_Target_ManaBarText:Hide();
			end
			-- End: Update the mana bar

			-- Begin: Update the mana bar color
			pettargetpower = UnitPowerType("pettarget");

			if (UnitPowerMax("pettarget") == 0) then
				Perl_Player_Pet_Target_ManaBar:SetStatusBarColor(0, 0, 0, 1);
				Perl_Player_Pet_Target_ManaBarBG:SetStatusBarColor(0, 0, 0, 0.25);
			elseif (pettargetpower) then
				Perl_Player_Pet_Target_ManaBar:SetStatusBarColor(PERL_POWER_TYPE_COLORS[pettargetpower].r, PERL_POWER_TYPE_COLORS[pettargetpower].g, PERL_POWER_TYPE_COLORS[pettargetpower].b, 1);
				Perl_Player_Pet_Target_ManaBarBG:SetStatusBarColor(PERL_POWER_TYPE_COLORS[pettargetpower].r, PERL_POWER_TYPE_COLORS[pettargetpower].g, PERL_POWER_TYPE_COLORS[pettargetpower].b, 0.25);
			else
				Perl_Player_Pet_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
				Perl_Player_Pet_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
			end
			-- End: Update the mana bar color

			-- Begin: Raid Icon
			raidpettargetindex = GetRaidTargetIndex("pettarget");
			if (raidpettargetindex) then
				PerlSetRaidTargetIconTexture(Perl_Player_Pet_Target_RaidTargetIcon, raidpettargetindex);
				Perl_Player_Pet_Target_RaidTargetIcon:Show();
			else
				Perl_Player_Pet_Target_RaidTargetIcon:Hide();
			end
			-- End: Raid Icon

			-- Begin: Debuff Frame Coloring
			local curableDebuffFound = 0;
			if (PCUF_COLORFRAMEDEBUFF == 1) then
				local debuffType;
				local _;
				_, _, _, debuffType = UnitDebuff("pettarget", 1, 1);
				if (debuffType) then
					local color = PerlDebuffTypeColor[debuffType];
					Perl_Player_Pet_Target_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
					Perl_Player_Pet_Target_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
					curableDebuffFound = 1;
				end
			end
			if (curableDebuffFound == 0) then
				Perl_Player_Pet_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
				Perl_Player_Pet_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			end
			-- End: Debuff Frame Coloring
		end
	end
end

function Perl_Player_Pet_Target_HealthBar_Fade_Check()
	if (PCUF_FADEBARS == 1) then
		if (pettargethealth < Perl_Player_Pet_Target_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and pettargethealth > Perl_Player_Pet_Target_HealthBar:GetValue())) then
			Perl_Player_Pet_Target_HealthBarFadeBar:SetMinMaxValues(0, pettargethealthmax);
			Perl_Player_Pet_Target_HealthBarFadeBar:SetValue(Perl_Player_Pet_Target_HealthBar:GetValue());
			Perl_Player_Pet_Target_HealthBarFadeBar:Show();
			Perl_Player_Pet_Target_HealthBar_Fade_Color = 1;
			Perl_Player_Pet_Target_HealthBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			Perl_Player_Pet_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Player_Pet_Target_HealthBar_Fade_Color, 0, Perl_Player_Pet_Target_HealthBar_Fade_Color);
			Perl_Player_Pet_Target_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end
end

function Perl_Player_Pet_Target_ManaBar_Fade_Check()
	if (PCUF_FADEBARS == 1) then
		if (pettargetmana < Perl_Player_Pet_Target_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and pettargetmana > Perl_Player_Pet_Target_ManaBar:GetValue())) then
			Perl_Player_Pet_Target_ManaBarFadeBar:SetMinMaxValues(0, pettargetmanamax);
			Perl_Player_Pet_Target_ManaBarFadeBar:SetValue(Perl_Player_Pet_Target_ManaBar:GetValue());
			Perl_Player_Pet_Target_ManaBarFadeBar:Show();
			Perl_Player_Pet_Target_ManaBar_Fade_Color = 1;
			Perl_Player_Pet_Target_ManaBar_Fade_OnUpdate_Frame.TimeSinceLastUpdate = 0;
			if (pettargetpower == 0) then	-- Forcing an initial value will prevent the fade from starting incorrectly
				Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color);
			elseif (pettargetpower == 1) then
				Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_Target_ManaBar_Fade_Color, 0, 0, Perl_Player_Pet_Target_ManaBar_Fade_Color);
			elseif (pettargetpower == 2) then
				Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_Target_ManaBar_Fade_Color, (Perl_Player_Pet_Target_ManaBar_Fade_Color-0.5), 0, Perl_Player_Pet_Target_ManaBar_Fade_Color);
			elseif (pettargetpower == 3) then
				Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color, 0, Perl_Player_Pet_Target_ManaBar_Fade_Color);
			elseif (pettargetpower == 6) then
				Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color);
			end
			Perl_Player_Pet_Target_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end
end

function Perl_Player_Pet_Target_HealthShow()
	pettargethealth = UnitHealth("pettarget");
	pettargethealthmax = UnitHealthMax("pettarget");

	if (UnitIsDead("pettarget") or UnitIsGhost("pettarget")) then	-- This prevents negative health
		pettargethealth = 0;
		pettargethealthpercent = 0;
	end

	Perl_Player_Pet_Target_HealthBarText:SetText(pettargethealth.."/"..pettargethealthmax);	-- Self/Party/Raid member

	mouseoverpettargethealthflag = 1;
end

function Perl_Player_Pet_Target_HealthHide()
	if (UnitHealthMax("pettarget") > 0) then
		pettargethealthpercent = floor(UnitHealth("pettarget")/UnitHealthMax("pettarget")*100+0.5);
	else
		pettargethealthpercent = 0;
	end

	if (UnitIsDead("pettarget") or UnitIsGhost("pettarget")) then	-- This prevents negative health
		pettargethealthpercent = 0;
	end

	Perl_Player_Pet_Target_HealthBarText:SetText(pettargethealthpercent.."%");
	mouseoverpettargethealthflag = 0;
end

function Perl_Player_Pet_Target_ManaShow()
	pettargetmana = UnitPower("pettarget");
	pettargetmanamax = UnitPowerMax("pettarget");

	if (UnitIsDead("pettarget") or UnitIsGhost("pettarget")) then	-- This prevents negative mana
		pettargetmana = 0;
	end

	if (UnitPowerType("pettarget") == 1 or UnitPowerType("pettarget") == 2 or UnitPowerType("pettarget") == 6) then
		Perl_Player_Pet_Target_ManaBarText:SetText(pettargetmana);
	else
		Perl_Player_Pet_Target_ManaBarText:SetText(pettargetmana.."/"..pettargetmanamax);
	end
	Perl_Player_Pet_Target_ManaBarText:Show();
	mouseoverpettargetmanaflag = 1;
end

function Perl_Player_Pet_Target_ManaHide()
	Perl_Player_Pet_Target_ManaBarText:Hide();
	mouseoverpettargetmanaflag = 0;
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Player_Pet_HealthBar_Fade(self, elapsed)
	Perl_Player_Pet_HealthBar_Fade_Color = Perl_Player_Pet_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Player_Pet_HealthBarFadeBar:SetStatusBarColor(0, Perl_Player_Pet_HealthBar_Fade_Color, 0, Perl_Player_Pet_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Player_Pet_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Player_Pet_HealthBarFadeBar:Hide();
		Perl_Player_Pet_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Player_Pet_ManaBar_Fade(self, elapsed)
	Perl_Player_Pet_ManaBar_Fade_Color = Perl_Player_Pet_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("pet") == 0) then
		Perl_Player_Pet_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Player_Pet_ManaBar_Fade_Color, Perl_Player_Pet_ManaBar_Fade_Color);
	elseif (UnitPowerType("pet") == 2) then
		Perl_Player_Pet_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_ManaBar_Fade_Color, (Perl_Player_Pet_ManaBar_Fade_Color-0.5), 0, Perl_Player_Pet_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Player_Pet_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Player_Pet_ManaBarFadeBar:Hide();
		Perl_Player_Pet_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Player_Pet_Target_HealthBar_Fade(self, elapsed)
	Perl_Player_Pet_Target_HealthBar_Fade_Color = Perl_Player_Pet_Target_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Player_Pet_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Player_Pet_Target_HealthBar_Fade_Color, 0, Perl_Player_Pet_Target_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Player_Pet_Target_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Player_Pet_Target_HealthBarFadeBar:Hide();
		Perl_Player_Pet_Target_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Player_Pet_Target_ManaBar_Fade(self, elapsed)
	Perl_Player_Pet_Target_ManaBar_Fade_Color = Perl_Player_Pet_Target_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (pettargetpower == 0) then
		Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color);
	elseif (pettargetpower == 1) then
		Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_Target_ManaBar_Fade_Color, 0, 0, Perl_Player_Pet_Target_ManaBar_Fade_Color);
	elseif (pettargetpower == 2) then
		Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_Target_ManaBar_Fade_Color, (Perl_Player_Pet_Target_ManaBar_Fade_Color-0.5), 0, Perl_Player_Pet_Target_ManaBar_Fade_Color);
	elseif (pettargetpower == 3) then
		Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color, 0, Perl_Player_Pet_Target_ManaBar_Fade_Color);
	elseif (pettargetpower == 6) then
		Perl_Player_Pet_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color, Perl_Player_Pet_Target_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Player_Pet_Target_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Player_Pet_Target_ManaBarFadeBar:Hide();
		Perl_Player_Pet_Target_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Player_Pet_Allign()
	Perl_Player_Pet_Frame:SetUserPlaced(true);
	Perl_Player_Pet_Target_Frame:SetUserPlaced(true);

	if (Perl_Player_Frame) then
		local vartable = Perl_Player_GetVars();
		Perl_Player_Pet_Frame:ClearAllPoints();
		if (vartable["showportrait"] == 0 and showportrait == 1) then
			Perl_Player_Pet_Frame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "BOTTOMLEFT", 54, 2);
		else
			Perl_Player_Pet_Frame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "BOTTOMLEFT", 0, 2);
		end
	end
	Perl_Player_Pet_Target_Frame:ClearAllPoints();
	Perl_Player_Pet_Target_Frame:SetPoint("TOPLEFT", Perl_Player_Pet_Frame, "TOPRIGHT", -2, 0);
	Perl_Player_Pet_Set_Frame_Position();
end

function Perl_Player_Pet_Set_Buffs(newbuffnumber)
	if (newbuffnumber == nil) then
		newbuffnumber = 16;
	end
	numpetbuffsshown = newbuffnumber;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Debuffs(newdebuffnumber)
	if (newdebuffnumber == nil) then
		newdebuffnumber = 16;
	end
	numpetdebuffsshown = newdebuffnumber;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Buff_Location(newvalue)
	if (newvalue ~= nil) then
		bufflocation = newvalue;
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Buff_Position_Update();	-- Set the buff positions
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Debuff_Location(newvalue)
	if (newvalue ~= nil) then
		debufflocation = newvalue;
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Buff_Position_Update();	-- Set the buff positions
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Buff_Size(newvalue)
	if (newvalue ~= nil) then
		buffsize = newvalue;
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Buff_Position_Update();	-- Set the buff positions
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Debuff_Size(newvalue)
	if (newvalue ~= nil) then
		debuffsize = newvalue;
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Buff_Position_Update();	-- Set the buff positions
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Class_Buffs(newvalue)
	if (newvalue ~= nil) then
		displaycastablebuffs = newvalue;
	end
	Perl_Player_Pet_UpdateVars();			-- Save the new setting
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Curable_Debuffs(newvalue)
	if (newvalue ~= nil) then
		displaycurabledebuff = newvalue;
	end
	Perl_Player_Pet_UpdateVars();			-- Save the new setting
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Compact_Mode(newvalue)
	compactmode = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Buff_Position_Update();	-- Set the buff positions
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
	Perl_Player_Pet_Set_Window_Layout();
end

function Perl_Player_Pet_Set_Hide_Name(newvalue)
	hidename = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Buff_Position_Update();	-- Set the buff positions
	Perl_Player_Pet_Reset_Buffs();			-- Reset the buff icons and set the size
	Perl_Player_Pet_Buff_UpdateAll();		-- Repopulate the buff icons
	Perl_Player_Pet_Set_Window_Layout();
end

function Perl_Player_Pet_Set_ShowXP(newvalue)
	showxp = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_ShowXP();
end

function Perl_Player_Pet_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_Set_Portrait(newvalue)
	showportrait = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Set_Window_Layout();
	Perl_Player_Pet_Update_Portrait();
end

function Perl_Player_Pet_Set_3D_Portrait(newvalue)
	threedportrait = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Set_Window_Layout();
	Perl_Player_Pet_Update_Portrait();
end

function Perl_Player_Pet_Set_Portrait_Combat_Text(newvalue)
	portraitcombattext = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Portrait_Combat_Text();
end

function Perl_Player_Pet_Set_Pet_Target(newvalue)
	displaypettarget = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Set_Window_Layout();
end

function Perl_Player_Pet_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_Set_Friendly_Health(newvalue)
	showfriendlyhealth = newvalue;
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_Set_Frame_Position()
	xposition = floor(Perl_Player_Pet_Frame:GetLeft() + 0.5);
	yposition = floor(Perl_Player_Pet_Frame:GetTop() - (UIParent:GetTop() / Perl_Player_Pet_Frame:GetScale()) + 0.5);
	xpositiont = floor(Perl_Player_Pet_Target_Frame:GetLeft() + 0.5);
	ypositiont = floor(Perl_Player_Pet_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_Player_Pet_Target_Frame:GetScale()) + 0.5);
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);				-- convert the user input to a wow acceptable value
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Set_Scale_Actual();
end

function Perl_Player_Pet_Target_Set_Scale(number)
	if (number ~= nil) then
		targetscale = (number / 100);		-- convert the user input to a wow acceptable value
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Set_Scale_Actual();
end

function Perl_Player_Pet_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Player_Pet_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;			-- run it through the scaling formula introduced in 1.9
		local unsavedscaletwo = 1 - UIParent:GetEffectiveScale() + targetscale;	-- run it through the scaling formula introduced in 1.9
		Perl_Player_Pet_Frame:SetScale(unsavedscale);
		Perl_Player_Pet_Target_Frame:SetScale(unsavedscaletwo);
	end
end

function Perl_Player_Pet_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);		-- convert the user input to a wow acceptable value
	end
	Perl_Player_Pet_Frame:SetAlpha(transparency);
	Perl_Player_Pet_Target_Frame:SetAlpha(transparency);
	Perl_Player_Pet_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Player_Pet_GetVars(index, updateflag)
	if (index == nil) then
		index = GetRealmName("player").."-"..UnitName("player");
	end

	locked = Perl_Player_Pet_Config[index]["Locked"];
	showxp = Perl_Player_Pet_Config[index]["ShowXP"];
	scale = Perl_Player_Pet_Config[index]["Scale"];
	targetscale = Perl_Player_Pet_Config[index]["TargetScale"];
	numpetbuffsshown = Perl_Player_Pet_Config[index]["Buffs"];
	numpetdebuffsshown = Perl_Player_Pet_Config[index]["Debuffs"];
	transparency = Perl_Player_Pet_Config[index]["Transparency"];
	bufflocation = Perl_Player_Pet_Config[index]["BuffLocation"];
	debufflocation = Perl_Player_Pet_Config[index]["DebuffLocation"];
	buffsize = Perl_Player_Pet_Config[index]["BuffSize"];
	debuffsize = Perl_Player_Pet_Config[index]["DebuffSize"];
	showportrait = Perl_Player_Pet_Config[index]["ShowPortrait"];
	threedportrait = Perl_Player_Pet_Config[index]["ThreeDPortrait"];
	portraitcombattext = Perl_Player_Pet_Config[index]["PortraitCombatText"];
	compactmode = Perl_Player_Pet_Config[index]["CompactMode"];
	hidename = Perl_Player_Pet_Config[index]["HideName"];
	displaypettarget = Perl_Player_Pet_Config[index]["DisplayPetTarget"];
	classcolorednames = Perl_Player_Pet_Config[index]["ClassColoredNames"];
	showfriendlyhealth = Perl_Player_Pet_Config[index]["ShowFriendlyHealth"];
	displaycastablebuffs = Perl_Player_Pet_Config[index]["DisplayCastableBuffs"];
	displaycurabledebuff = Perl_Player_Pet_Config[index]["DisplayCurableDebuff"];
	xposition = Perl_Player_Pet_Config[index]["XPosition"];
	yposition = Perl_Player_Pet_Config[index]["YPosition"];
	xpositiont = Perl_Player_Pet_Config[index]["XPositionT"];
	ypositiont = Perl_Player_Pet_Config[index]["YPositionT"];

	if (locked == nil) then
		locked = 0;
	end
	if (showxp == nil) then
		showxp = 0;
	end
	if (scale == nil) then
		scale = 1.0;
	end
	if (targetscale == nil) then
		targetscale = 1.0;
	end
	if (numpetbuffsshown == nil) then
		numpetbuffsshown = 16;
	end
	if (numpetdebuffsshown == nil) then
		numpetdebuffsshown = 16;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (bufflocation == nil) then
		bufflocation = 4;
	end
	if (debufflocation == nil) then
		debufflocation = 5;
	end
	if (buffsize == nil) then
		buffsize = 12;
	end
	if (debuffsize == nil) then
		debuffsize = 12;
	end
	if (showportrait == nil) then
		showportrait = 0;
	end
	if (threedportrait == nil) then
		threedportrait = 0;
	end
	if (portraitcombattext == nil) then
		portraitcombattext = 0;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
	if (hidename == nil) then
		hidename = 0;
	end
	if (displaypettarget == nil) then
		displaypettarget = 0;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (showfriendlyhealth == nil) then
		showfriendlyhealth = 0;
	end
	if (displaycastablebuffs == nil) then
		displaycastablebuffs = 0;
	end
	if (displaycurabledebuff == nil) then
		displaycurabledebuff = 0;
	end
	if (xposition == nil) then
		xposition = 30;
	end
	if (yposition == nil) then
		yposition = -117;
	end
	if (xpositiont == nil) then
		xpositiont = 198;
	end
	if (ypositiont == nil) then
		ypositiont = -117;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Player_Pet_UpdateVars();

		-- Call any code we need to activate them
		Perl_Player_Pet_Reset_Buffs();		-- Reset the buff icons
		Perl_Player_Pet_Buff_UpdateAll();	-- Repopulate the buff icons
		Perl_Player_Pet_Update_Health();	-- Update the health in case progrssive health color was set
		Perl_Player_Pet_Update_Portrait();
		Perl_Player_Pet_Portrait_Combat_Text();
		Perl_Player_Pet_Set_Window_Layout();
		Perl_Player_Pet_Set_Scale_Actual();	-- Set the scale
		Perl_Player_Pet_Set_Transparency();	-- Set the transparency
		Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition, yposition);			-- Position the frame
		Perl_Player_Pet_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositiont, ypositiont);	-- Position the frame
		return;
	end

	local vars = {
		["locked"] = locked,
		["showxp"] = showxp,
		["scale"] = scale,
		["targetscale"] = targetscale,
		["numpetbuffsshown"] = numpetbuffsshown,
		["numpetdebuffsshown"] = numpetdebuffsshown,
		["transparency"] = transparency,
		["bufflocation"] = bufflocation,
		["debufflocation"] = debufflocation,
		["buffsize"] = buffsize,
		["debuffsize"] = debuffsize,
		["showportrait"] = showportrait,
		["threedportrait"] = threedportrait,
		["portraitcombattext"] = portraitcombattext,
		["compactmode"] = compactmode,
		["hidename"] = hidename,
		["displaypettarget"] = displaypettarget,
		["classcolorednames"] = classcolorednames,
		["showfriendlyhealth"] = showfriendlyhealth,
		["displaycastablebuffs"] = displaycastablebuffs,
		["displaycurabledebuff"] = displaycurabledebuff,
		["xposition"] = xposition,
		["yposition"] = yposition,
		["xpositiont"] = xpositiont,
		["ypositiont"] = ypositiont,
	}
	return vars;
end

function Perl_Player_Pet_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["ShowXP"] ~= nil) then
				showxp = vartable["Global Settings"]["ShowXP"];
			else
				showxp = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["TargetScale"] ~= nil) then
				targetscale = vartable["Global Settings"]["TargetScale"];
			else
				targetscale = nil;
			end
			if (vartable["Global Settings"]["Buffs"] ~= nil) then
				numpetbuffsshown = vartable["Global Settings"]["Buffs"];
			else
				numpetbuffsshown = nil;
			end
			if (vartable["Global Settings"]["Debuffs"] ~= nil) then
				numpetdebuffsshown = vartable["Global Settings"]["Debuffs"];
			else
				numpetdebuffsshown = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["BuffLocation"] ~= nil) then
				bufflocation = vartable["Global Settings"]["BuffLocation"];
			else
				bufflocation = nil;
			end
			if (vartable["Global Settings"]["DebuffLocation"] ~= nil) then
				debufflocation = vartable["Global Settings"]["DebuffLocation"];
			else
				debufflocation = nil;
			end
			if (vartable["Global Settings"]["BuffSize"] ~= nil) then
				buffsize = vartable["Global Settings"]["BuffSize"];
			else
				buffsize = nil;
			end
			if (vartable["Global Settings"]["DebuffSize"] ~= nil) then
				debuffsize = vartable["Global Settings"]["DebuffSize"];
			else
				debuffsize = nil;
			end
			if (vartable["Global Settings"]["ShowPortrait"] ~= nil) then
				showportrait = vartable["Global Settings"]["ShowPortrait"];
			else
				showportrait = nil;
			end
			if (vartable["Global Settings"]["ThreeDPortrait"] ~= nil) then
				threedportrait = vartable["Global Settings"]["ThreeDPortrait"];
			else
				threedportrait = nil;
			end
			if (vartable["Global Settings"]["PortraitCombatText"] ~= nil) then
				portraitcombattext = vartable["Global Settings"]["PortraitCombatText"];
			else
				portraitcombattext = nil;
			end
			if (vartable["Global Settings"]["CompactMode"] ~= nil) then
				compactmode = vartable["Global Settings"]["CompactMode"];
			else
				compactmode = nil;
			end
			if (vartable["Global Settings"]["HideName"] ~= nil) then
				hidename = vartable["Global Settings"]["HideName"];
			else
				hidename = nil;
			end
			if (vartable["Global Settings"]["DisplayPetTarget"] ~= nil) then
				displaypettarget = vartable["Global Settings"]["DisplayPetTarget"];
			else
				displaypettarget = nil;
			end
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["ShowFriendlyHealth"] ~= nil) then
				showfriendlyhealth = vartable["Global Settings"]["ShowFriendlyHealth"];
			else
				showfriendlyhealth = nil;
			end
			if (vartable["Global Settings"]["DisplayCastableBuffs"] ~= nil) then
				displaycastablebuffs = vartable["Global Settings"]["DisplayCastableBuffs"];
			else
				displaycastablebuffs = nil;
			end
			if (vartable["Global Settings"]["DisplayCurableDebuff"] ~= nil) then
				displaycurabledebuff = vartable["Global Settings"]["DisplayCurableDebuff"];
			else
				displaycurabledebuff = nil;
			end
			if (vartable["Global Settings"]["XPosition"] ~= nil) then
				xposition = vartable["Global Settings"]["XPosition"];
			else
				xposition = nil;
			end
			if (vartable["Global Settings"]["YPosition"] ~= nil) then
				yposition = vartable["Global Settings"]["YPosition"];
			else
				yposition = nil;
			end
			if (vartable["Global Settings"]["XPositionT"] ~= nil) then
				xpositiont = vartable["Global Settings"]["XPositionT"];
			else
				xpositiont = nil;
			end
			if (vartable["Global Settings"]["YPositionT"] ~= nil) then
				ypositiont = vartable["Global Settings"]["YPositionT"];
			else
				ypositiont = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (showxp == nil) then
			showxp = 0;
		end
		if (scale == nil) then
			scale = 1.0;
		end
		if (targetscale == nil) then
			targetscale = 1.0;
		end
		if (numpetbuffsshown == nil) then
			numpetbuffsshown = 16;
		end
		if (numpetdebuffsshown == nil) then
			numpetdebuffsshown = 16;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (bufflocation == nil) then
			bufflocation = 4;
		end
		if (debufflocation == nil) then
			debufflocation = 5;
		end
		if (buffsize == nil) then
			buffsize = 12;
		end
		if (debuffsize == nil) then
			debuffsize = 12;
		end
		if (showportrait == nil) then
			showportrait = 0;
		end
		if (threedportrait == nil) then
			threedportrait = 0;
		end
		if (portraitcombattext == nil) then
			portraitcombattext = 0;
		end
		if (compactmode == nil) then
			compactmode = 0;
		end
		if (hidename == nil) then
			hidename = 0;
		end
		if (displaypettarget == nil) then
			displaypettarget = 0;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (showfriendlyhealth == nil) then
			showfriendlyhealth = 0;
		end
		if (displaycastablebuffs == nil) then
			displaycastablebuffs = 0;
		end
		if (displaycurabledebuff == nil) then
			displaycurabledebuff = 0;
		end
		if (xposition == nil) then
			xposition = 30;
		end
		if (yposition == nil) then
			yposition = -117;
		end
		if (xpositiont == nil) then
			xpositiont = 198;
		end
		if (ypositiont == nil) then
			ypositiont = -117;
		end

		-- Call any code we need to activate them
		Perl_Player_Pet_Reset_Buffs();		-- Reset the buff icons
		Perl_Player_Pet_Buff_UpdateAll();	-- Repopulate the buff icons
		Perl_Player_Pet_Update_Health();	-- Update the health in case progrssive health color was set
		Perl_Player_Pet_Update_Portrait();
		Perl_Player_Pet_Portrait_Combat_Text();
		Perl_Player_Pet_Set_Window_Layout();
		Perl_Player_Pet_Set_Scale_Actual();	-- Set the scale
		Perl_Player_Pet_Set_Transparency();	-- Set the transparency
		Perl_Player_Pet_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition, yposition);			-- Position the frame
		Perl_Player_Pet_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpositiont, ypositiont);	-- Position the frame
	end

	Perl_Player_Pet_Config[GetRealmName("player").."-"..UnitName("player")] = {
		["Locked"] = locked,
		["ShowXP"] = showxp,
		["Scale"] = scale,
		["TargetScale"] = targetscale,
		["Buffs"] = numpetbuffsshown,
		["Debuffs"] = numpetdebuffsshown,
		["Transparency"] = transparency,
		["BuffLocation"] = bufflocation,
		["DebuffLocation"] = debufflocation,
		["BuffSize"] = buffsize,
		["DebuffSize"] = debuffsize,
		["ShowPortrait"] = showportrait,
		["ThreeDPortrait"] = threedportrait,
		["PortraitCombatText"] = portraitcombattext,
		["CompactMode"] = compactmode,
		["HideName"] = hidename,
		["DisplayPetTarget"] = displaypettarget,
		["ClassColoredNames"] = classcolorednames,
		["ShowFriendlyHealth"] = showfriendlyhealth,
		["DisplayCastableBuffs"] = displaycastablebuffs,
		["DisplayCurableDebuff"] = displaycurabledebuff,
		["XPosition"] = xposition,
		["YPosition"] = yposition,
		["XPositionT"] = xpositiont,
		["YPositionT"] = ypositiont,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Player_Pet_Buff_UpdateAll()
	if (UnitName("pet")) then
		local button, buffCount, buffTexture, buffApplications, color, debuffType;	-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)
		local curableDebuffFound = 0;
		local _;

		for buffnum=1,numpetbuffsshown do											-- Start main buff loop
			if (displaycastablebuffs == 0) then										-- Which buff filter mode are we in?
				bufffilter = "HELPFUL";
			else
				bufffilter = "HELPFUL RAID";
			end
			_, buffTexture, buffApplications = UnitAura("pet", buffnum, bufffilter);	-- Get the texture and buff stacking information if any
			button = _G["Perl_Player_Pet_Buff"..buffnum];							-- Create the main icon for the buff
			if (buffTexture) then													-- If there is a valid texture, proceed with buff icon creation
				_G[button:GetName().."Icon"]:SetTexture(buffTexture);				-- Set the texture
				_G[button:GetName().."DebuffBorder"]:Hide();						-- Hide the debuff border
				buffCount = _G[button:GetName().."Count"];							-- Declare the buff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);							-- Set the text to the number of applications if greater than 0
					buffCount:Show();												-- Show the text
				else
					buffCount:Hide();												-- Hide the text if equal to 0
				end
				button:Show();														-- Show the final buff icon
			else
				button:Hide();														-- Hide the icon since there isn't a buff in this position
			end
		end																			-- End main buff loop

		for debuffnum=1,numpetdebuffsshown do
			if (displaycurabledebuff == 1) then										-- Are we targeting a friend or enemy and which filter do we need to apply?
				debufffilter = "HARMFUL RAID";
			else
				debufffilter = "HARMFUL";
			end
			_, buffTexture, buffApplications, debuffType = UnitAura("pet", debuffnum, debufffilter);	-- Get the texture and debuff stacking information if any
			button = _G["Perl_Player_Pet_Debuff"..debuffnum];						-- Create the main icon for the debuff
			if (buffTexture) then													-- If there is a valid texture, proceed with debuff icon creation
				_G[button:GetName().."Icon"]:SetTexture(buffTexture);				-- Set the texture
				if (debuffType) then
					color = PerlDebuffTypeColor[debuffType];
					if (PCUF_COLORFRAMEDEBUFF == 1) then
						if (curableDebuffFound == 0) then
							if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
								Perl_Player_Pet_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
								Perl_Player_Pet_PortraitFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
								Perl_Player_Pet_LevelFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
								Perl_Player_Pet_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
								curableDebuffFound = 1;
							end
						end
					end
				else
					color = PerlDebuffTypeColor[PERL_LOCALIZED_BUFF_NONE];
				end
				_G[button:GetName().."DebuffBorder"]:SetVertexColor(color.r, color.g, color.b);	-- Set the debuff border color
				_G[button:GetName().."DebuffBorder"]:Show();						-- Show the debuff border
				buffCount = _G[button:GetName().."Count"];							-- Declare the debuff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);							-- Set the text to the number of applications if greater than 0
					buffCount:Show();												-- Show the text
				else
					buffCount:Hide();												-- Hide the text if equal to 0
				end
				button:Show();														-- Show the final debuff icon
			else
				button:Hide();														-- Hide the icon since there isn't a debuff in this position
			end
		end																			-- End main debuff loop

		if (curableDebuffFound == 0) then
			Perl_Player_Pet_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Player_Pet_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Player_Pet_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Player_Pet_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		end
	end
end

function Perl_Player_Pet_Buff_Position_Update()
	Perl_Player_Pet_Buff1:ClearAllPoints();
	local _;
	if (bufflocation == 1) then
		if (hidename == 0) then
			Perl_Player_Pet_Buff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_NameFrame", "TOPLEFT", 5, 15);
		else
			_, englishclass = UnitClass("player");
			if (englishclass == "HUNTER") then
				Perl_Player_Pet_Buff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_LevelFrame", "TOPLEFT", 5, 15);
			else
				Perl_Player_Pet_Buff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_StatsFrame", "TOPLEFT", 5, 15);
			end
		end
	elseif (bufflocation == 2) then
		if (hidename == 0) then
			Perl_Player_Pet_Buff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_NameFrame", "TOPLEFT", 5, 0);
		else
			_, englishclass = UnitClass("player");
			if (englishclass == "HUNTER") then
				Perl_Player_Pet_Buff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_LevelFrame", "TOPLEFT", 5, 0);
			else
				Perl_Player_Pet_Buff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_StatsFrame", "TOPLEFT", 5, 0);
			end
		end
	elseif (bufflocation == 3) then
		Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_NameFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 4) then
		Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -5);
	elseif (bufflocation == 5) then
		Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -20);
	elseif (bufflocation == 6) then
		_, englishclass = UnitClass("player");
		if (englishclass == "HUNTER") then
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, 0);
		else
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "BOTTOMLEFT", 5, 0);
		end
	elseif (bufflocation == 7) then
		_, englishclass = UnitClass("player");
		if (englishclass == "HUNTER") then
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, -15);
		else
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "BOTTOMLEFT", 5, -15);
		end
	end

	Perl_Player_Pet_Debuff1:ClearAllPoints();
	if (debufflocation == 1) then
		if (hidename == 0) then
			Perl_Player_Pet_Debuff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_NameFrame", "TOPLEFT", 5, 15);
		else
			_, englishclass = UnitClass("player");
			if (englishclass == "HUNTER") then
				Perl_Player_Pet_Debuff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_LevelFrame", "TOPLEFT", 5, 15);
			else
				Perl_Player_Pet_Debuff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_StatsFrame", "TOPLEFT", 5, 15);
			end
		end
	elseif (debufflocation == 2) then
		if (hidename == 0) then
			Perl_Player_Pet_Debuff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_NameFrame", "TOPLEFT", 5, 0);
		else
			_, englishclass = UnitClass("player");
			if (englishclass == "HUNTER") then
				Perl_Player_Pet_Debuff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_LevelFrame", "TOPLEFT", 5, 0);
			else
				Perl_Player_Pet_Debuff1:SetPoint("BOTTOMLEFT", "Perl_Player_Pet_StatsFrame", "TOPLEFT", 5, 0);
			end
		end
	elseif (debufflocation == 3) then
		Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_NameFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 4) then
		Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -5);
	elseif (debufflocation == 5) then
		Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -20);
	elseif (debufflocation == 6) then
		_, englishclass = UnitClass("player");
		if (englishclass == "HUNTER") then
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, 0);
		else
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "BOTTOMLEFT", 5, 0);
		end
	elseif (debufflocation == 7) then
		_, englishclass = UnitClass("player");
		if (englishclass == "HUNTER") then
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, -15);
		else
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "BOTTOMLEFT", 5, -15);
		end
	end
end

function Perl_Player_Pet_Reset_Buffs()
	local button, debuff, icon;

	for buffnum=1,16 do
		button = _G["Perl_Player_Pet_Buff"..buffnum];
		icon = _G[button:GetName().."Icon"];
		debuff = _G[button:GetName().."DebuffBorder"];
		button:SetHeight(buffsize);
		button:SetWidth(buffsize);
		icon:SetHeight(buffsize);
		icon:SetWidth(buffsize);
		debuff:SetHeight(buffsize);
		debuff:SetWidth(buffsize);
		button:Hide();

		button = _G["Perl_Player_Pet_Debuff"..buffnum];
		icon = _G[button:GetName().."Icon"];
		debuff = _G[button:GetName().."DebuffBorder"];
		button:SetHeight(debuffsize);
		button:SetWidth(debuffsize);
		icon:SetHeight(debuffsize);
		icon:SetWidth(debuffsize);
		debuff:SetHeight(debuffsize);
		debuff:SetWidth(debuffsize);
		button:Hide();
	end
end

function Perl_Player_Pet_SetBuffTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	if (self:GetID() > 16) then
		GameTooltip:SetUnitDebuff("pet", self:GetID()-16);
	else
		GameTooltip:SetUnitBuff("pet", self:GetID());
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Player_Pet_CastClickOverlay_OnLoad(self)
	self:SetAttribute("unit", "pet");
	self:SetAttribute("*type1", "target");
	self:SetAttribute("*type2", "togglemenu");
	self:SetAttribute("type2", "togglemenu");

	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_Player_Pet_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Player_Pet_Frame:StartMoving();
	end
end

function Perl_Player_Pet_DragStop()
	Perl_Player_Pet_Frame:StopMovingOrSizing();
	Perl_Player_Pet_Set_Frame_Position();
end

function Perl_Player_Pet_Target_CastClickOverlay_OnLoad(self)
	self:SetAttribute("unit", "pettarget");
	self:SetAttribute("*type1", "target");
	self:SetAttribute("*type2", "togglemenu");
	self:SetAttribute("type2", "togglemenu");

	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_Player_Pet_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Player_Pet_Target_Frame:StartMoving();
	end
end

function Perl_Player_Pet_Target_DragStop()
	Perl_Player_Pet_Target_Frame:StopMovingOrSizing();
	Perl_Player_Pet_Set_Frame_Position();
end
