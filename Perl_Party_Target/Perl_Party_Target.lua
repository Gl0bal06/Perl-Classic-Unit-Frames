---------------
-- Variables --
---------------
Perl_Party_Target_Config = {};
local Perl_Party_Target_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Party_Target_GetVars)
local locked = 0;						-- unlocked by default
local scale = 1.0;						-- default scale for party target
local focusscale = 1.0;					-- default scale for focus target
local transparency = 1;					-- transparency for frames
local hidepowerbars = 0;				-- Power bars are shown by default
local classcolorednames = 0;			-- names are colored based on pvp status by default
local enabled = 1;						-- mod is shown by default
local partyhiddeninraid = 0;			-- party target is not hidden in raids by default
local enabledfocus = 1;					-- focus target is on by default
local focushiddeninraid = 0;			-- focus target is not hidden in raids by default
local xposition1 = 298;					-- target 1 default x position
local yposition1 = -214;				-- target 1 default y position
local xposition2 = 298;					-- target 2 default x position
local yposition2 = -309;				-- target 2 default y position
local xposition3 = 298;					-- target 3 default x position
local yposition3 = -404;				-- target 3 default y position
local xposition4 = 298;					-- target 4 default x position
local yposition4 = -499;				-- target 4 default y position
local xposition5 = 419;					-- focus target default x position
local yposition5 = -650;				-- focus target default y position


-- Default Local Variables
local Initialized = nil;				-- waiting to be initialized
local Perl_Party_Target_Time_Update_Rate = 0.2;			-- the update interval
local mouseoverhealthflag = 0;							-- is the mouse over the health bar?
local mouseovermanaflag = 0;							-- is the mouse over the mana bar?
local Perl_Party_Target_One_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_Two_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_Three_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_Four_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_Five_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_One_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Two_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Three_ManaBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_Four_ManaBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Target_Five_ManaBar_Fade_Color = 1;	-- the color fading interval

-- Local variables to save memory
local r, g, b, currentunit, partytargethealth, partytargethealthmax, partytargethealthpercent, partytargetmana, partytargetmanamax, partytargetpower, englishclass, raidpartytargetindex;


----------------------
-- Loading Function --
----------------------
function Perl_Party_Target_Script_OnLoad(self)
	-- Variables
	self.TimeSinceLastUpdate = 0;

	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");

	-- Scripts
	self:SetScript("OnEvent",
		function(self, event, ...)
			Perl_Party_Target_Events[event](self, ...);
		end
	);
	self:SetScript("OnUpdate", Perl_Party_Target_OnUpdate);
end

function Perl_Party_Target_OnLoad(self)
	self.id = self:GetID();
	if (self.id == 5) then
		self.unit = "focustarget";
	else
		self.unit = "party"..self.id.."target";
	end

	self.nameFrame = _G["Perl_Party_Target"..self.id.."_NameFrame"];
	self.nameText = _G["Perl_Party_Target"..self.id.."_NameFrame_NameBarText"];
	self.raidIcon = _G["Perl_Party_Target"..self.id.."_RaidIconFrame_RaidTargetIcon"];
	self.statsFrame = _G["Perl_Party_Target"..self.id.."_StatsFrame"];

	self.healthBar = _G["Perl_Party_Target"..self.id.."_StatsFrame_HealthBar"];
	self.healthBarBG = _G["Perl_Party_Target"..self.id.."_StatsFrame_HealthBarBG"];
	self.healthBarText = _G["Perl_Party_Target"..self.id.."_StatsFrame_HealthBar_HealthBarText"];
	self.healthBarFadeBar = _G["Perl_Party_Target"..self.id.."_StatsFrame_HealthBarFadeBar"];
	self.manaBar = _G["Perl_Party_Target"..self.id.."_StatsFrame_ManaBar"];
	self.manaBarBG = _G["Perl_Party_Target"..self.id.."_StatsFrame_ManaBarBG"];
	self.manaBarText = _G["Perl_Party_Target"..self.id.."_StatsFrame_ManaBar_ManaBarText"];
	self.manaBarFadeBar = _G["Perl_Party_Target"..self.id.."_StatsFrame_ManaBarFadeBar"];
end


------------
-- Events --
------------
function Perl_Party_Target_Events:GROUP_ROSTER_UPDATE()
	Perl_Party_Target_Check_Hidden();
end

function Perl_Party_Target_Events:PLAYER_LOGIN()
	Perl_Party_Target_Initialize();
end
Perl_Party_Target_Events.PLAYER_ENTERING_WORLD = Perl_Party_Target_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Party_Target_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Party_Target_Set_Scale_Actual();	-- Set the frame scale
		Perl_Party_Target_Set_Transparency();	-- Set the frame transparency
		Perl_Party_Target1:ClearAllPoints();
		Perl_Party_Target2:ClearAllPoints();
		Perl_Party_Target3:ClearAllPoints();
		Perl_Party_Target4:ClearAllPoints();
		Perl_Party_Target5:ClearAllPoints();
		Perl_Party_Target1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition1, yposition1);
		Perl_Party_Target2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition2, yposition2);
		Perl_Party_Target3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition3, yposition3);
		Perl_Party_Target4:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition4, yposition4);
		Perl_Party_Target5:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition5, yposition5);
		Perl_Party_Target_Check_Hidden();		-- Hide the frames if in a raid
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	Perl_Config_Migrate_Vars_Old_To_New("Party_Target");
	if (type(Perl_Party_Target_Config[GetRealmName("player").."-"..UnitName("player")]) == "table") then
		Perl_Party_Target_GetVars();
	else
		Perl_Party_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Party_Target_Initialize_Frame_Color();	-- Color the frame borders
	Perl_Party_Target_Frame_Style();			-- Initialize the mod and set any frame settings

	-- Set the ID of the frame
	for num=1,5 do
		_G["Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"]:SetID(num);
		_G["Perl_Party_Target"..num.."_StatsFrame_CastClickOverlay"]:SetID(num);
		_G["Perl_Party_Target"..num.."_StatsFrame_HealthBar_CastClickOverlay"]:SetID(num);
		_G["Perl_Party_Target"..num.."_StatsFrame_ManaBar_CastClickOverlay"]:SetID(num);
	end

	-- Button Click Overlays (in order of occurrence in XML)
	for num=1,5 do
		_G["Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_NameFrame"]:GetFrameLevel() + 1);
		_G["Perl_Party_Target"..num.."_StatsFrame_CastClickOverlay"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_StatsFrame"]:GetFrameLevel() + 1);
		_G["Perl_Party_Target"..num.."_StatsFrame_HealthBar_CastClickOverlay"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_StatsFrame"]:GetFrameLevel() + 2);
		_G["Perl_Party_Target"..num.."_StatsFrame_ManaBar_CastClickOverlay"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_StatsFrame"]:GetFrameLevel() + 2);
		_G["Perl_Party_Target"..num.."_RaidIconFrame"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"]:GetFrameLevel() - 1);
		_G["Perl_Party_Target"..num.."_StatsFrame_HealthBarFadeBar"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_StatsFrame_HealthBar"]:GetFrameLevel() - 1);
		_G["Perl_Party_Target"..num.."_StatsFrame_ManaBarFadeBar"]:SetFrameLevel(_G["Perl_Party_Target"..num.."_StatsFrame_ManaBar"]:GetFrameLevel() - 1);
	end

	-- IFrameManager Support (Deprecated)
	for num=1,5 do
		_G["Perl_Party_Target"..num]:SetUserPlaced(true);
	end

	Initialized = 1;
end

function Perl_Party_Target_Initialize_Frame_Color()
	for partynum=1,5 do
		_G["Perl_Party_Target"..partynum.."_NameFrame"]:SetBackdropColor(0, 0, 0, 1);
		_G["Perl_Party_Target"..partynum.."_NameFrame"]:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		_G["Perl_Party_Target"..partynum.."_StatsFrame"]:SetBackdropColor(0, 0, 0, 1);
		_G["Perl_Party_Target"..partynum.."_StatsFrame"]:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		_G["Perl_Party_Target"..partynum.."_StatsFrame_HealthBar_HealthBarText"]:SetTextColor(1, 1, 1, 1);
		_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_ManaBarText"]:SetTextColor(1, 1, 1, 1);
	end
end


-------------------------
-- The Update Function --
-------------------------
function Perl_Party_Target_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if (self.TimeSinceLastUpdate > Perl_Party_Target_Time_Update_Rate) then
		self.TimeSinceLastUpdate = 0;
		if (UnitExists(Perl_Party_Target1:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target1);
		end
		if (UnitExists(Perl_Party_Target2:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target2);
		end
		if (UnitExists(Perl_Party_Target3:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target3);
		end
		if (UnitExists(Perl_Party_Target4:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target4);
		end
		if (UnitExists(Perl_Party_Target5:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target5);
		end
	end
end

function Perl_Party_Target_Work(self)
	-- Begin: Set the name
	self.nameText:SetText(UnitName(self.unit));
	-- End: Set the name

	-- Begin: Set the name text color
	if (UnitPlayerControlled(self.unit)) then					-- is it a player
		if (UnitCanAttack(self.unit, "player")) then			-- are we in an enemy controlled zone
			-- Hostile players are red
			if (not UnitCanAttack("player", self.unit)) then	-- enemy is not pvp enabled
				r = 0.5;
				g = 0.5;
				b = 1.0;
			else												-- enemy is pvp enabled
				r = 1.0;
				g = 0.0;
				b = 0.0;
			end
		elseif (UnitCanAttack("player", self.unit)) then		-- enemy in a zone controlled by friendlies or when we're a ghost
			-- Players we can attack but which are not hostile are yellow
			r = 1.0;
			g = 1.0;
			b = 0.0;
		elseif (UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit) and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
		self.nameText:SetTextColor(r, g, b);
	elseif (not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit)) then
		self.nameText:SetTextColor(0.5,0.5,0.5);				-- not our tap
	else
		if (UnitIsVisible(self.unit)) then
			reaction = UnitReaction(self.unit, "player");
			if (reaction) then
				r = PERL_FACTION_BAR_COLORS[reaction].r;
				g = PERL_FACTION_BAR_COLORS[reaction].g;
				b = PERL_FACTION_BAR_COLORS[reaction].b;
				self.nameText:SetTextColor(r, g, b);
			else
				self.nameText:SetTextColor(0.5, 0.5, 1.0);
			end
		else
			if (UnitCanAttack(self.unit, "player")) then		-- are we in an enemy controlled zone
				-- Hostile players are red
				if (not UnitCanAttack("player", self.unit)) then	-- enemy is not pvp enabled
					r = 0.5;
					g = 0.5;
					b = 1.0;
				else											-- enemy is pvp enabled
					r = 1.0;
					g = 0.0;
					b = 0.0;
				end
			elseif (UnitCanAttack("player", self.unit)) then	-- enemy in a zone controlled by friendlies or when we're a ghost
				-- Players we can attack but which are not hostile are yellow
				r = 1.0;
				g = 1.0;
				b = 0.0;
			elseif (UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit) and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
			self.nameText:SetTextColor(r, g, b);
		end
	end

	if (classcolorednames == 1) then
		if (UnitIsPlayer(self.unit)) then
			local _;
			_, englishclass = UnitClass(self.unit);
			self.nameText:SetTextColor(PERL_RAID_CLASS_COLORS[englishclass].r,PERL_RAID_CLASS_COLORS[englishclass].g,PERL_RAID_CLASS_COLORS[englishclass].b);
		end
	end
	-- End: Set the name text color

	-- Begin: Update the health bar
	partytargethealth = UnitHealth(self.unit);
	partytargethealthmax = UnitHealthMax(self.unit);
	partytargethealthpercent = floor(partytargethealth/partytargethealthmax*100+0.5);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then	-- This prevents negative health
		partytargethealth = 0;
		partytargethealthpercent = 0;
	end

	Perl_Party_Target_HealthBar_Fade_Check(self);

	self.healthBar:SetMinMaxValues(0, partytargethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		self.healthBar:SetValue(partytargethealthmax - partytargethealth);
	else
		self.healthBar:SetValue(partytargethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((partytargethealthpercent <= 100) and (partytargethealthpercent > 75)) then
--			self.healthBar:SetStatusBarColor(0, 0.8, 0);
--			self.healthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((partytargethealthpercent <= 75) and (partytargethealthpercent > 50)) then
--			self.healthBar:SetStatusBarColor(1, 1, 0);
--			self.healthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((partytargethealthpercent <= 50) and (partytargethealthpercent > 25)) then
--			self.healthBar:SetStatusBarColor(1, 0.5, 0);
--			self.healthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			self.healthBar:SetStatusBarColor(1, 0, 0);
--			self.healthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = partytargethealth / partytargethealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		self.healthBar:SetStatusBarColor(red, green, 0, 1);
		self.healthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		self.healthBar:SetStatusBarColor(0, 0.8, 0);
		self.healthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (tonumber(mouseoverhealthflag) == tonumber(self.id)) then
		Perl_Party_Target_HealthShow(self);
	else
		self.healthBarText:SetText(partytargethealthpercent.."%");
	end
	-- End: Update the health bar

	if (hidepowerbars == 0) then
		-- Begin: Update the mana bar color
		partytargetpower = UnitPowerType(self.unit);

		-- Set mana bar color
		if (UnitPowerMax(self.unit) == 0) then
			self.manaBar:SetStatusBarColor(0, 0, 0, 0);
			self.manaBarBG:SetStatusBarColor(0, 0, 0, 0);
		elseif (partytargetpower) then
			self.manaBar:SetStatusBarColor(PERL_POWER_TYPE_COLORS[partytargetpower].r, PERL_POWER_TYPE_COLORS[partytargetpower].g, PERL_POWER_TYPE_COLORS[partytargetpower].b, 1);
			self.manaBarBG:SetStatusBarColor(PERL_POWER_TYPE_COLORS[partytargetpower].r, PERL_POWER_TYPE_COLORS[partytargetpower].g, PERL_POWER_TYPE_COLORS[partytargetpower].b, 0.25);
		else
			self.manaBar:SetStatusBarColor(0, 0, 1, 1);
			self.manaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		end
		-- End: Update the mana bar color

		-- Begin: Update the mana bar
		partytargetmana = UnitPower(self.unit);
		partytargetmanamax = UnitPowerMax(self.unit);

		if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then	-- This prevents negative mana
			partytargetmana = 0;
		end

		Perl_Party_Target_ManaBar_Fade_Check(self);

		self.manaBar:SetMinMaxValues(0, partytargetmanamax);
		if (PCUF_INVERTBARVALUES == 1) then
			self.manaBar:SetValue(partytargetmanamax - partytargetmana);
		else
			self.manaBar:SetValue(partytargetmana);
		end

		if (tonumber(mouseovermanaflag) == tonumber(self.id)) then
			if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 2 or UnitPowerType(self.unit) == 6) then
				self.manaBarText:SetText(partytargetmana);
			else
				self.manaBarText:SetText(partytargetmana.."/"..partytargetmanamax);
			end
		else
			self.manaBarText:SetText();
		end
		-- End: Update the mana bar
	end

	-- Begin: Raid Icon
	Perl_Party_Target_Update_Raid_Icon(self);
	-- End: Raid Icon

	-- Begin: Update buffs and debuffs
	Perl_Party_Target_Update_Buffs(self);
	-- End: Update buffs and debuffs
end

function Perl_Party_Target_HealthShow(self)
	partytargethealth = UnitHealth(self.unit);
	partytargethealthmax = UnitHealthMax(self.unit);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then	-- This prevents negative health
		partytargethealth = 0;
		partytargethealthpercent = 0;
	end

	self.healthBarText:SetText(partytargethealth.."/"..partytargethealthmax);
	mouseoverhealthflag = self.id;
end

function Perl_Party_Target_HealthHide(self)
	if (UnitHealthMax(self.unit) > 0) then
		self.healthBarText:SetText(floor(UnitHealth(self.unit)/UnitHealthMax(self.unit)*100+0.5).."%");
	else
		self.healthBarText:SetText("0%");
	end
	mouseoverhealthflag = 0;
end

function Perl_Party_Target_ManaShow(self)
	partytargetmana = UnitPower(self.unit);
	partytargetmanamax = UnitPowerMax(self.unit);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then	-- This prevents negative mana
		partytargetmana = 0;
	end

	if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 2 or UnitPowerType(self.unit) == 6) then
		self.manaBarText:SetText(partytargetmana);
	else
		self.manaBarText:SetText(partytargetmana.."/"..partytargetmanamax);
	end
	mouseovermanaflag = self.id;
end

function Perl_Party_Target_ManaHide(self)
	self.manaBarText:SetText();
	mouseovermanaflag = 0;
end

function Perl_Party_Target_Update_Raid_Icon(self)
	raidpartytargetindex = GetRaidTargetIndex(self.unit);
	if (raidpartytargetindex) then
		PerlSetRaidTargetIconTexture(self.raidIcon, raidpartytargetindex);
		self.raidIcon:Show();
	else
		self.raidIcon:Hide();
	end
end

function Perl_Party_Target_Update_Buffs(self)
	local debuffType;
	local curableDebuffFound = 0;
	local _;

	for debuffnum=1,40 do													-- Start main debuff loop
		_, _, _, debuffType, _, _ = UnitDebuff(self.unit, debuffnum, 1);	-- Get the texture and debuff stacking information if any
		if (debuffType) then
			if (PCUF_COLORFRAMEDEBUFF == 1) then
				if (curableDebuffFound == 0) then
					if (UnitIsFriend("player", self.unit)) then
						if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
							local color = PerlDebuffTypeColor[debuffType];
							self.nameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							self.statsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							curableDebuffFound = 1;
							break;
						end
					end
				end
			end
		end
	end

	if (curableDebuffFound == 0) then
		self.nameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		self.statsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Party_Target_HealthBar_Fade_Check(self)
	if (PCUF_FADEBARS == 1) then
		if (partytargethealth < self.healthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partytargethealth > self.healthBar:GetValue())) then
			self.healthBarFadeBar:SetMinMaxValues(0, partytargethealthmax);
			self.healthBarFadeBar:SetValue(self.healthBar:GetValue());
			self.healthBarFadeBar:Show();
			-- We don't reset the values since this breaks fading due to not using individual variables for all 4 frames (not a big deal, still looks fine)
			_G["Perl_Party_Target"..self.id.."_HealthBar_Fade_OnUpdate_Frame"]:Show();
		end
	end
end

function Perl_Party_Target_ManaBar_Fade_Check(self)
	if (PCUF_FADEBARS == 1) then
		if (partytargetmana < self.manaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partytargetmana > self.manaBar:GetValue())) then
			self.manaBarFadeBar:SetMinMaxValues(0, partytargetmanamax);
			self.manaBarFadeBar:SetValue(self.manaBar:GetValue());
			self.manaBarFadeBar:Show();
			-- We don't reset the values since this breaks fading due to not using individual variables for all 4 frames (not a big deal, still looks fine)
			_G["Perl_Party_Target"..self.id.."_ManaBar_Fade_OnUpdate_Frame"]:Show();
		end
	end
end

function Perl_Party_Target_One_HealthBar_Fade(self, elapsed)
	Perl_Party_Target_One_HealthBar_Fade_Color = Perl_Party_Target_One_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Party_Target1_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_One_HealthBar_Fade_Color, 0, Perl_Party_Target_One_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_One_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target1_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target1_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Two_HealthBar_Fade(self, elapsed)
	Perl_Party_Target_Two_HealthBar_Fade_Color = Perl_Party_Target_Two_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Party_Target2_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Two_HealthBar_Fade_Color, 0, Perl_Party_Target_Two_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Two_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target2_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target2_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Three_HealthBar_Fade(self, elapsed)
	Perl_Party_Target_Three_HealthBar_Fade_Color = Perl_Party_Target_Three_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Party_Target3_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Three_HealthBar_Fade_Color, 0, Perl_Party_Target_Three_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Three_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target3_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target3_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Four_HealthBar_Fade(self, elapsed)
	Perl_Party_Target_Four_HealthBar_Fade_Color = Perl_Party_Target_Four_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Party_Target4_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Four_HealthBar_Fade_Color, 0, Perl_Party_Target_Four_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Four_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target4_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target4_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Five_HealthBar_Fade(self, elapsed)
	Perl_Party_Target_Five_HealthBar_Fade_Color = Perl_Party_Target_Five_HealthBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	Perl_Party_Target5_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Five_HealthBar_Fade_Color, 0, Perl_Party_Target_Five_HealthBar_Fade_Color);

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Five_HealthBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target5_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target5_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_One_ManaBar_Fade(self, elapsed)
	Perl_Party_Target_One_ManaBar_Fade_Color = Perl_Party_Target_One_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("party1target") == 0) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 1) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 2) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, (Perl_Party_Target_One_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 3) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color, 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 6) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_One_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target1_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Two_ManaBar_Fade(self, elapsed)
	Perl_Party_Target_Two_ManaBar_Fade_Color = Perl_Party_Target_Two_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("party2target") == 0) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 1) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 2) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, (Perl_Party_Target_Two_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 3) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color, 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 6) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Two_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target2_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Three_ManaBar_Fade(self, elapsed)
	Perl_Party_Target_Three_ManaBar_Fade_Color = Perl_Party_Target_Three_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("party3target") == 0) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 1) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 2) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, (Perl_Party_Target_Three_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 3) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color, 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 6) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Three_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target3_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Four_ManaBar_Fade(self, elapsed)
	Perl_Party_Target_Four_ManaBar_Fade_Color = Perl_Party_Target_Four_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("party4target") == 0) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 1) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 2) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, (Perl_Party_Target_Four_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 3) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color, 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 6) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Four_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target4_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Five_ManaBar_Fade(self, elapsed)
	Perl_Party_Target_Five_ManaBar_Fade_Color = Perl_Party_Target_Five_ManaBar_Fade_Color - elapsed;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if (UnitPowerType("focustarget") == 0) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 1) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 2) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, (Perl_Party_Target_Five_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 3) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color, 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 6) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color);
	end

	if (self.TimeSinceLastUpdate > 1) then
		Perl_Party_Target_Five_ManaBar_Fade_Color = 1;
		self.TimeSinceLastUpdate = 0;
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target5_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Party_Target_Frame_Style()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Frame_Style);
	else
		if (enabled == 1) then
			Perl_Party_Target_Register_All(1, 0);
		else
			Perl_Party_Target_Unregister_All(1, 0);
		end

		if (enabledfocus == 1) then
			Perl_Party_Target_Register_All(0, 1);
		else
			Perl_Party_Target_Unregister_All(0, 1);
		end

		Perl_Party_Target_Check_Hidden();

		if (hidepowerbars == 1) then
			for partynum=1,5 do
				_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBar"]:Hide();
				_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBarBG"]:Hide();
				_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_CastClickOverlay"]:Hide();
				_G["Perl_Party_Target"..partynum.."_StatsFrame"]:SetHeight(30);
				_G["Perl_Party_Target"..partynum.."_StatsFrame_CastClickOverlay"]:SetHeight(30);
			end
		else
			for partynum=1,5 do
				_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBar"]:Show();
				_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBarBG"]:Show();
				_G["Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_CastClickOverlay"]:Show();
				_G["Perl_Party_Target"..partynum.."_StatsFrame"]:SetHeight(42);
				_G["Perl_Party_Target"..partynum.."_StatsFrame_CastClickOverlay"]:SetHeight(42);
			end
		end

		for partynum=1,5 do
			_G["Perl_Party_Target"..partynum.."_NameFrame_NameBarText"]:SetWidth(_G["Perl_Party_Target"..partynum.."_NameFrame"]:GetWidth() - 13);
			_G["Perl_Party_Target"..partynum.."_NameFrame_NameBarText"]:SetHeight(_G["Perl_Party_Target"..partynum.."_NameFrame"]:GetHeight() - 10);
			_G["Perl_Party_Target"..partynum.."_NameFrame_NameBarText"]:SetNonSpaceWrap(false);
			_G["Perl_Party_Target"..partynum.."_NameFrame_NameBarText"]:SetJustifyH("LEFT");
		end
	end
end

function Perl_Party_Target_Check_Hidden()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Check_Hidden);
	else
		if (partyhiddeninraid == 1 or focushiddeninraid == 1) then
			if (UnitInRaid("player")) then
				Perl_Party_Target_Unregister_All(partyhiddeninraid, focushiddeninraid);
			else
				Perl_Party_Target_Register_All(enabled, enabledfocus);
			end
		end
	end
end

function Perl_Party_Target_Register_All(party, focus)
	if (party == 1) then
		RegisterUnitWatch(Perl_Party_Target1);
		RegisterUnitWatch(Perl_Party_Target2);
		RegisterUnitWatch(Perl_Party_Target3);
		RegisterUnitWatch(Perl_Party_Target4);
	end
	if (focus == 1) then
		RegisterUnitWatch(Perl_Party_Target5);
	end
	if (enabled == 0 and enabledfocus == 0) then
		Perl_Party_Target_Script_Frame:Hide();
	else
		Perl_Party_Target_Script_Frame:Show();
	end
end

function Perl_Party_Target_Unregister_All(party, focus)
	if (party == 1) then
		UnregisterUnitWatch(Perl_Party_Target1);
		UnregisterUnitWatch(Perl_Party_Target2);
		UnregisterUnitWatch(Perl_Party_Target3);
		UnregisterUnitWatch(Perl_Party_Target4);
		Perl_Party_Target1:Hide();
		Perl_Party_Target2:Hide();
		Perl_Party_Target3:Hide();
		Perl_Party_Target4:Hide();
	end
	if (focus == 1) then
		UnregisterUnitWatch(Perl_Party_Target5);
		Perl_Party_Target5:Hide();
	end
	if (enabled == 0 and enabledfocus == 0) then
		Perl_Party_Target_Script_Frame:Hide();
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Party_Target_Allign()
	Perl_Party_Target1:SetUserPlaced(true);	-- This makes WoW remember the changes if the frames have never been moved before
	Perl_Party_Target2:SetUserPlaced(true);
	Perl_Party_Target3:SetUserPlaced(true);
	Perl_Party_Target4:SetUserPlaced(true);
	Perl_Party_Target5:SetUserPlaced(true);

	Perl_Party_Target1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 298, -214);
	Perl_Party_Target2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 298, -309);
	Perl_Party_Target3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 298, -404);
	Perl_Party_Target4:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 298, -499);
	if (Perl_Focus_PortraitFrame:IsShown()) then
		Perl_Party_Target5:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 481, -650);
	else
		Perl_Party_Target5:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 419, -650);
	end

	Perl_Party_Target_Set_Frame_Position();
end

function Perl_Party_Target_Set_Enabled(newvalue)
	enabled = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Enabled_Focus(newvalue)
	enabledfocus = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Party_Hidden_In_Raid(newvalue)
	partyhiddeninraid = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Focus_Hidden_In_Raid(newvalue)
	focushiddeninraid = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Hide_Power_Bars(newvalue)
	hidepowerbars = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Frame_Position()
	xposition1 = floor(Perl_Party_Target1:GetLeft() + 0.5);
	yposition1 = floor(Perl_Party_Target1:GetTop() - (UIParent:GetTop() / Perl_Party_Target1:GetScale()) + 0.5);
	xposition2 = floor(Perl_Party_Target2:GetLeft() + 0.5);
	yposition2 = floor(Perl_Party_Target2:GetTop() - (UIParent:GetTop() / Perl_Party_Target2:GetScale()) + 0.5);
	xposition3 = floor(Perl_Party_Target3:GetLeft() + 0.5);
	yposition3 = floor(Perl_Party_Target3:GetTop() - (UIParent:GetTop() / Perl_Party_Target3:GetScale()) + 0.5);
	xposition4 = floor(Perl_Party_Target4:GetLeft() + 0.5);
	yposition4 = floor(Perl_Party_Target4:GetTop() - (UIParent:GetTop() / Perl_Party_Target4:GetScale()) + 0.5);
	xposition5 = floor(Perl_Party_Target5:GetLeft() + 0.5);
	yposition5 = floor(Perl_Party_Target5:GetTop() - (UIParent:GetTop() / Perl_Party_Target5:GetScale()) + 0.5);
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);
	end
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Set_Scale_Actual();
end

function Perl_Party_Target_Focus_Set_Scale(number)
	if (number ~= nil) then
		focusscale = (number / 100);
	end
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Set_Scale_Actual();
end

function Perl_Party_Target_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;			-- run it through the scaling formula introduced in 1.9
		local unsavedscaletwo = 1 - UIParent:GetEffectiveScale() + focusscale;	-- run it through the scaling formula introduced in 1.9
		Perl_Party_Target1:SetScale(unsavedscale);
		Perl_Party_Target2:SetScale(unsavedscale);
		Perl_Party_Target3:SetScale(unsavedscale);
		Perl_Party_Target4:SetScale(unsavedscale);
		Perl_Party_Target5:SetScale(unsavedscaletwo);
	end
end

function Perl_Party_Target_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);
	end
	Perl_Party_Target1:SetAlpha(transparency);
	Perl_Party_Target2:SetAlpha(transparency);
	Perl_Party_Target3:SetAlpha(transparency);
	Perl_Party_Target4:SetAlpha(transparency);
	Perl_Party_Target5:SetAlpha(transparency);
	Perl_Party_Target_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Party_Target_GetVars(index, updateflag)
	if (index == nil) then
		index = GetRealmName("player").."-"..UnitName("player");
	end

	locked = Perl_Party_Target_Config[index]["Locked"];
	scale = Perl_Party_Target_Config[index]["Scale"];
	focusscale = Perl_Party_Target_Config[index]["FocusScale"];
	transparency = Perl_Party_Target_Config[index]["Transparency"];
	hidepowerbars = Perl_Party_Target_Config[index]["HidePowerBars"];
	classcolorednames = Perl_Party_Target_Config[index]["ClassColoredNames"];
	enabled = Perl_Party_Target_Config[index]["Enabled"];
	partyhiddeninraid = Perl_Party_Target_Config[index]["PartyHiddenInRaid"];
	enabledfocus = Perl_Party_Target_Config[index]["EnabledFocus"];
	focushiddeninraid = Perl_Party_Target_Config[index]["FocusHiddenInRaid"];
	xposition1 = Perl_Party_Target_Config[index]["XPosition1"];
	yposition1 = Perl_Party_Target_Config[index]["YPosition1"];
	xposition2 = Perl_Party_Target_Config[index]["XPosition2"];
	yposition2 = Perl_Party_Target_Config[index]["YPosition2"];
	xposition3 = Perl_Party_Target_Config[index]["XPosition3"];
	yposition3 = Perl_Party_Target_Config[index]["YPosition3"];
	xposition4 = Perl_Party_Target_Config[index]["XPosition4"];
	yposition4 = Perl_Party_Target_Config[index]["YPosition4"];
	xposition5 = Perl_Party_Target_Config[index]["XPosition5"];
	yposition5 = Perl_Party_Target_Config[index]["YPosition5"];

	if (locked == nil) then
		locked = 0;
	end
	if (scale == nil) then
		scale = 1.0;
	end
	if (focusscale == nil) then
		focusscale = 1.0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (hidepowerbars == nil) then
		hidepowerbars = 0;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (enabled == nil) then
		enabled = 1;
	end
	if (partyhiddeninraid == nil) then
		partyhiddeninraid = 0;
	end
	if (enabledfocus == nil) then
		enabledfocus = 1;
	end
	if (focushiddeninraid == nil) then
		focushiddeninraid = 0;
	end
	if (xposition1 == nil) then
		xposition1 = 298;
	end
	if (yposition1 == nil) then
		yposition1 = -214;
	end
	if (xposition2 == nil) then
		xposition2 = 298;
	end
	if (yposition2 == nil) then
		yposition2 = -309;
	end
	if (xposition3 == nil) then
		xposition3 = 298;
	end
	if (yposition3 == nil) then
		yposition3 = -404;
	end
	if (xposition4 == nil) then
		xposition4 = 298;
	end
	if (yposition4 == nil) then
		yposition4 = -499;
	end
	if (xposition5 == nil) then
		xposition5 = 419;
	end
	if (yposition5 == nil) then
		yposition5 = -650;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Party_Target_UpdateVars();

		-- Call any code we need to activate them
		Perl_Party_Target_Set_Scale_Actual();
		Perl_Party_Target_Set_Transparency();
		Perl_Party_Target_Frame_Style();
		Perl_Party_Target1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition1, yposition1);
		Perl_Party_Target2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition2, yposition2);
		Perl_Party_Target3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition3, yposition3);
		Perl_Party_Target4:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition4, yposition4);
		Perl_Party_Target5:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition5, yposition5);
		return;
	end

	local vars = {
		["locked"] = locked,
		["scale"] = scale,
		["focusscale"] = focusscale,
		["transparency"] = transparency,
		["hidepowerbars"] = hidepowerbars,
		["classcolorednames"] = classcolorednames,
		["enabled"] = enabled,
		["partyhiddeninraid"] = partyhiddeninraid,
		["enabledfocus"] = enabledfocus,
		["focushiddeninraid"] = focushiddeninraid,
		["xposition1"] = xposition1,
		["yposition1"] = yposition1,
		["xposition2"] = xposition2,
		["yposition2"] = yposition2,
		["xposition3"] = xposition3,
		["yposition3"] = yposition3,
		["xposition4"] = xposition4,
		["yposition4"] = yposition4,
		["xposition5"] = xposition5,
		["yposition5"] = yposition5,
	}
	return vars;
end

function Perl_Party_Target_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["FocusScale"] ~= nil) then
				focusscale = vartable["Global Settings"]["FocusScale"];
			else
				focusscale = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["HidePowerBars"] ~= nil) then
				hidepowerbars = vartable["Global Settings"]["HidePowerBars"];
			else
				hidepowerbars = nil;
			end
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["Enabled"] ~= nil) then
				enabled = vartable["Global Settings"]["Enabled"];
			else
				enabled = nil;
			end
			if (vartable["Global Settings"]["PartyHiddenInRaid"] ~= nil) then
				partyhiddeninraid = vartable["Global Settings"]["PartyHiddenInRaid"];
			else
				partyhiddeninraid = nil;
			end
			if (vartable["Global Settings"]["EnabledFocus"] ~= nil) then
				enabledfocus = vartable["Global Settings"]["EnabledFocus"];
			else
				enabledfocus = nil;
			end
			if (vartable["Global Settings"]["FocusHiddenInRaid"] ~= nil) then
				focushiddeninraid = vartable["Global Settings"]["FocusHiddenInRaid"];
			else
				focushiddeninraid = nil;
			end
			if (vartable["Global Settings"]["XPosition1"] ~= nil) then
				xposition1 = vartable["Global Settings"]["XPosition1"];
			else
				xposition1 = nil;
			end
			if (vartable["Global Settings"]["YPosition1"] ~= nil) then
				yposition1 = vartable["Global Settings"]["YPosition1"];
			else
				yposition1 = nil;
			end
			if (vartable["Global Settings"]["XPosition2"] ~= nil) then
				xposition2 = vartable["Global Settings"]["XPosition2"];
			else
				xposition2 = nil;
			end
			if (vartable["Global Settings"]["YPosition2"] ~= nil) then
				yposition2 = vartable["Global Settings"]["YPosition2"];
			else
				yposition2 = nil;
			end
			if (vartable["Global Settings"]["XPosition3"] ~= nil) then
				xposition3 = vartable["Global Settings"]["XPosition3"];
			else
				xposition3 = nil;
			end
			if (vartable["Global Settings"]["YPosition3"] ~= nil) then
				yposition3 = vartable["Global Settings"]["YPosition3"];
			else
				yposition3 = nil;
			end
			if (vartable["Global Settings"]["XPosition4"] ~= nil) then
				xposition4 = vartable["Global Settings"]["XPosition4"];
			else
				xposition4 = nil;
			end
			if (vartable["Global Settings"]["YPosition4"] ~= nil) then
				yposition4 = vartable["Global Settings"]["YPosition4"];
			else
				yposition4 = nil;
			end
			if (vartable["Global Settings"]["XPosition5"] ~= nil) then
				xposition5 = vartable["Global Settings"]["XPosition5"];
			else
				xposition5 = nil;
			end
			if (vartable["Global Settings"]["YPosition5"] ~= nil) then
				yposition5 = vartable["Global Settings"]["YPosition5"];
			else
				yposition5 = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (scale == nil) then
			scale = 1.0;
		end
		if (focusscale == nil) then
			focusscale = 1.0;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (hidepowerbars == nil) then
			hidepowerbars = 0;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (enabled == nil) then
			enabled = 1;
		end
		if (partyhiddeninraid == nil) then
			partyhiddeninraid = 0;
		end
		if (enabledfocus == nil) then
			enabledfocus = 1;
		end
		if (focushiddeninraid == nil) then
			focushiddeninraid = 0;
		end
		if (xposition1 == nil) then
			xposition1 = 298;
		end
		if (yposition1 == nil) then
			yposition1 = -214;
		end
		if (xposition2 == nil) then
			xposition2 = 298;
		end
		if (yposition2 == nil) then
			yposition2 = -309;
		end
		if (xposition3 == nil) then
			xposition3 = 298;
		end
		if (yposition3 == nil) then
			yposition3 = -404;
		end
		if (xposition4 == nil) then
			xposition4 = 298;
		end
		if (yposition4 == nil) then
			yposition4 = -499;
		end
		if (xposition5 == nil) then
			xposition5 = 419;
		end
		if (yposition5 == nil) then
			yposition5 = -650;
		end

		-- Call any code we need to activate them
		Perl_Party_Target_Set_Scale_Actual();
		Perl_Party_Target_Set_Transparency();
		Perl_Party_Target_Frame_Style();
		Perl_Party_Target1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition1, yposition1);
		Perl_Party_Target2:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition2, yposition2);
		Perl_Party_Target3:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition3, yposition3);
		Perl_Party_Target4:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition4, yposition4);
		Perl_Party_Target5:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xposition5, yposition5);
	end

	Perl_Party_Target_Config[GetRealmName("player").."-"..UnitName("player")] = {
		["Locked"] = locked,
		["Scale"] = scale,
		["FocusScale"] = focusscale,
		["Transparency"] = transparency,
		["HidePowerBars"] = hidepowerbars,
		["ClassColoredNames"] = classcolorednames,
		["Enabled"] = enabled,
		["PartyHiddenInRaid"] = partyhiddeninraid,
		["EnabledFocus"] = enabledfocus,
		["FocusHiddenInRaid"] = focushiddeninraid,
		["XPosition1"] = xposition1,
		["YPosition1"] = yposition1,
		["XPosition2"] = xposition2,
		["YPosition2"] = yposition2,
		["XPosition3"] = xposition3,
		["YPosition3"] = yposition3,
		["XPosition4"] = xposition4,
		["YPosition4"] = yposition4,
		["XPosition5"] = xposition5,
		["YPosition5"] = yposition5,
	};
end


--------------------
-- Click Handlers --
--------------------
function Perl_Party_Target_CastClickOverlay_OnLoad(self)
	if (self:GetParent():GetParent():GetID() == 5) then
		self:SetAttribute("unit", "focustarget");
	else
		self:SetAttribute("unit", "party"..self:GetParent():GetParent():GetID().."target");
	end
	self:SetAttribute("*type1", "target");
	self:SetAttribute("*type2", "togglemenu");
	self:SetAttribute("type2", "togglemenu");

	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_Party_Target_DragStart(self, button)
	if (button == "LeftButton" and locked == 0) then
		_G["Perl_Party_Target"..self:GetID()]:StartMoving();
	end
end

function Perl_Party_Target_DragStop(self)
	_G["Perl_Party_Target"..self:GetID()]:SetUserPlaced(true);
	_G["Perl_Party_Target"..self:GetID()]:StopMovingOrSizing();
	Perl_Party_Target_Set_Frame_Position();
end
