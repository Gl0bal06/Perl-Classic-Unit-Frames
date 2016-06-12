---------------
-- Variables --
---------------
Perl_Party_Target_Config = {};
local Perl_Party_Target_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Party_Target_GetVars)
local locked = 0;		-- unlocked by default
local scale = 1;		-- default scale
local transparency = 1;		-- transparency for frames
local mobhealthsupport = 1;	-- mobhealth support is on by default
local hidepowerbars = 0;	-- Power bars are shown by default
local classcolorednames = 0;	-- names are colored based on pvp status by default
local enabled = 1;		-- mod is shown by default
local hiddeninraid = 0;		-- mod is not hidden in raids by default
local enabledfocus = 1;		-- focus target is on by default

-- Default Local Variables
local Initialized = nil;			-- waiting to be initialized
local Perl_Party_Target_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Time_Update_Rate = 0.2;	-- the update interval
local mouseoverhealthflag = 0;			-- is the mouse over the health bar?
local mouseovermanaflag = 0;			-- is the mouse over the mana bar?
local Perl_Party_Target_One_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Two_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Three_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Four_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Five_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_One_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Two_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Three_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Four_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Five_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0

-- Local variables to save memory
local r, g, b, currentunit, partytargetname, partytargethealth, partytargethealthmax, partytargethealthpercent, partytargetmana, partytargetmanamax, partytargetpower, englishclass, raidpartytargetindex;


----------------------
-- Loading Function --
----------------------
function Perl_Party_Target_Script_OnLoad()
	-- Events
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LOGIN");
	this:RegisterEvent("RAID_ROSTER_UPDATE");

	-- Scripts
	this:SetScript("OnEvent", Perl_Party_Target_Script_OnEvent);
	this:SetScript("OnUpdate", Perl_Party_Target_OnUpdate);
end

function Perl_Party_Target_OnLoad(self)
	self.id = self:GetID();
	if (self.id == 5) then
		self.unit = "focustarget";
	else
		self.unit = "party"..self.id.."target";
	end

	self.nameFrame = getglobal("Perl_Party_Target"..self.id.."_NameFrame");
	self.nameText = getglobal("Perl_Party_Target"..self.id.."_NameFrame_NameBarText");
	self.raidIcon = getglobal("Perl_Party_Target"..self.id.."_RaidIconFrame_RaidTargetIcon");
	self.statsFrame = getglobal("Perl_Party_Target"..self.id.."_StatsFrame");

	self.healthBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBar");
	self.healthBarBG = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBarBG");
	self.healthBarText = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBar_HealthBarText");
	self.healthBarFadeBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBarFadeBar");
	self.manaBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBar");
	self.manaBarBG = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBarBG");
	self.manaBarText = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBar_ManaBarText");
	self.manaBarFadeBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBarFadeBar");
end


-------------------
-- Event Handler --
-------------------
function Perl_Party_Target_Script_OnEvent()
	local func = Perl_Party_Target_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Party Target: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Party_Target_Events:RAID_ROSTER_UPDATE()
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
		Perl_Party_Target_Set_Scale_Actual();			-- Set the frame scale
		Perl_Party_Target_Set_Transparency();		-- Set the frame transparency
		Perl_Party_Target_Check_Hidden();		-- Hide the frames if in a raid
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Party_Target_Config[UnitName("player")]) == "table") then
		Perl_Party_Target_GetVars();
	else
		Perl_Party_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Party_Target_Initialize_Frame_Color();		-- Color the frame borders
	Perl_Party_Target_Frame_Style();			-- Initialize the mod and set any frame settings

	-- Set the ID of the frame
	for num=1,5 do
		getglobal("Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetID(num);
	end

	-- Button Click Overlays (in order of occurrence in XML)
	for num=1,5 do
		getglobal("Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_NameFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_Target"..num.."_RaidIconFrame"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"):GetFrameLevel() - 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar"):GetFrameLevel() - 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar"):GetFrameLevel() - 1);
	end

	-- MyAddOns Support
	Perl_Party_Target_myAddOns_Support();

	-- IFrameManager Support
	if (IFrameManager) then
		Perl_Party_Target_IFrameManager();
	end

	Initialized = 1;
end

function Perl_Party_Target_IFrameManager()
	local iface = IFrameManager:Interface();
	function iface:getName(frame)
		if (frame == Perl_Party_Target1) then
			return "Perl Party Target 1";
		elseif (frame == Perl_Party_Target2) then
			return "Perl Party Target 2";
		elseif (frame == Perl_Party_Target3) then
			return "Perl Party Target 3";
		elseif (frame == Perl_Party_Target4) then
			return "Perl Party Target 4";
		elseif (frame == Perl_Party_Target5) then
			return "Perl Focus Target";
		end
	end
	function iface:getBorder(frame)
		local bottom = 38;
		local left = 0;
		local right = 0;
		local top = 0;
		if (hidepowerbars == 1) then
			bottom = bottom - 12;
		end
		return top, right, bottom, left;
	end
	IFrameManager:Register(Perl_Party_Target1, iface);
	IFrameManager:Register(Perl_Party_Target2, iface);
	IFrameManager:Register(Perl_Party_Target3, iface);
	IFrameManager:Register(Perl_Party_Target4, iface);
	IFrameManager:Register(Perl_Party_Target5, iface);
end

function Perl_Party_Target_Initialize_Frame_Color()
	for partynum=1,5 do
		getglobal("Perl_Party_Target"..partynum.."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_Target"..partynum.."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetTextColor(1, 1, 1, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetTextColor(1, 1, 1, 1);
	end
end


-------------------------
-- The Update Function --
-------------------------
function Perl_Party_Target_OnUpdate()
	Perl_Party_Target_Time_Elapsed = Perl_Party_Target_Time_Elapsed + arg1;
	if (Perl_Party_Target_Time_Elapsed > Perl_Party_Target_Time_Update_Rate) then
		Perl_Party_Target_Time_Elapsed = 0;
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
	partytargetname = UnitName(self.unit);
	if (GetLocale() == "koKR") then
		if (strlen(partytargetname) > 25) then
			partytargetname = strsub(partytargetname, 1, 24).."...";
		end
	elseif (GetLocale() == "zhCN") then
		if (strlen(partytargetname) > 21) then
			partytargetname = strsub(partytargetname, 1, 20).."...";
		end
	else
		if (strlen(partytargetname) > 11) then
			partytargetname = strsub(partytargetname, 1, 10).."...";
		end
	end
	self.nameText:SetText(partytargetname);
	-- End: Set the name

	-- Begin: Set the name text color
	if (UnitPlayerControlled(self.unit)) then						-- is it a player
		if (UnitCanAttack(self.unit, "player")) then					-- are we in an enemy controlled zone
			-- Hostile players are red
			if (not UnitCanAttack("player", self.unit)) then			-- enemy is not pvp enabled
				r = 0.5;
				g = 0.5;
				b = 1.0;
			else									-- enemy is pvp enabled
				r = 1.0;
				g = 0.0;
				b = 0.0;
			end
		elseif (UnitCanAttack("player", self.unit)) then				-- enemy in a zone controlled by friendlies or when we're a ghost
			-- Players we can attack but which are not hostile are yellow
			r = 1.0;
			g = 1.0;
			b = 0.0;
		elseif (UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit) and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
			-- Players we can assist but are PvP flagged are green
			r = 0.0;
			g = 1.0;
			b = 0.0;
		else										-- friendly non pvp enabled character
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.5;
			g = 0.5;
			b = 1.0;
		end
		self.nameText:SetTextColor(r, g, b);
	elseif (UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit)) then
		self.nameText:SetTextColor(0.5,0.5,0.5);					-- not our tap
	else
		if (UnitIsVisible(self.unit)) then
			reaction = UnitReaction(self.unit, "player");
			if (reaction) then
				r = UnitReactionColor[reaction].r;
				g = UnitReactionColor[reaction].g;
				b = UnitReactionColor[reaction].b;
				self.nameText:SetTextColor(r, g, b);
			else
				self.nameText:SetTextColor(0.5, 0.5, 1.0);
			end
		else
			if (UnitCanAttack(self.unit, "player")) then					-- are we in an enemy controlled zone
				-- Hostile players are red
				if (not UnitCanAttack("player", self.unit)) then			-- enemy is not pvp enabled
					r = 0.5;
					g = 0.5;
					b = 1.0;
				else									-- enemy is pvp enabled
					r = 1.0;
					g = 0.0;
					b = 0.0;
				end
			elseif (UnitCanAttack("player", self.unit)) then				-- enemy in a zone controlled by friendlies or when we're a ghost
				-- Players we can attack but which are not hostile are yellow
				r = 1.0;
				g = 1.0;
				b = 0.0;
			elseif (UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit) and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
				-- Players we can assist but are PvP flagged are green
				r = 0.0;
				g = 1.0;
				b = 0.0;
			else										-- friendly non pvp enabled character
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
			_, englishclass = UnitClass(self.unit);
			self.nameText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
		end
	end
	-- End: Set the name text color

	-- Begin: Update the health bar
	partytargethealth = UnitHealth(self.unit);
	partytargethealthmax = UnitHealthMax(self.unit);
	partytargethealthpercent = floor(partytargethealth/partytargethealthmax*100+0.5);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then				-- This prevents negative health
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
		if (UnitManaMax(self.unit) == 0) then
			self.manaBar:SetStatusBarColor(0, 0, 0, 0);
			self.manaBarBG:SetStatusBarColor(0, 0, 0, 0);
		elseif (partytargetpower == 1) then
			self.manaBar:SetStatusBarColor(1, 0, 0, 1);
			self.manaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		elseif (partytargetpower == 2) then
			self.manaBar:SetStatusBarColor(1, 0.5, 0, 1);
			self.manaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		elseif (partytargetpower == 3) then
			self.manaBar:SetStatusBarColor(1, 1, 0, 1);
			self.manaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		else
			self.manaBar:SetStatusBarColor(0, 0, 1, 1);
			self.manaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		end
		-- End: Update the mana bar color

		-- Begin: Update the mana bar
		partytargetmana = UnitMana(self.unit);
		partytargetmanamax = UnitManaMax(self.unit);

		if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then				-- This prevents negative mana
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
			if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 2) then
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

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then				-- This prevents negative health
		partytargethealth = 0;
		partytargethealthpercent = 0;
	end

	if (partytargethealthmax == 100) then
		-- Begin Mobhealth support
		if (mobhealthsupport == 1) then
			if (MobHealthFrame) then

				local index;
				if UnitIsPlayer(self.unit) then
					index = UnitName(self.unit);
				else
					index = UnitName(self.unit)..":"..UnitLevel(self.unit);
				end

				if ((MobHealthDB and MobHealthDB[index]) or (MobHealthPlayerDB and MobHealthPlayerDB[index])) then
					local s, e;
					local pts;
					local pct;

					if MobHealthDB[index] then
						if (type(MobHealthDB[index]) ~= "string") then
							self.healthBarText:SetText(partytargethealth.."%");
						end
						s, e, pts, pct = string.find(MobHealthDB[index], "^(%d+)/(%d+)$");
					else
						if (type(MobHealthPlayerDB[index]) ~= "string") then
							self.healthBarText:SetText(partytargethealth.."%");
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

					local currentPct = UnitHealth(self.unit);
					if (pointsPerPct > 0) then
						self.healthBarText:SetText(string.format("%d", (currentPct * pointsPerPct) + 0.5).."/"..string.format("%d", (100 * pointsPerPct) + 0.5));	-- Stored unit info from the DB
					end
				else
					self.healthBarText:SetText(partytargethealth.."%");	-- Unit not in MobHealth DB
				end
			-- End MobHealth Support
			else
				self.healthBarText:SetText(partytargethealth.."%");	-- MobHealth isn't installed
			end
		else	-- mobhealthsupport == 0
			self.healthBarText:SetText(partytargethealth.."%");	-- MobHealth support is disabled
		end
	else
		self.healthBarText:SetText(partytargethealth.."/"..partytargethealthmax);	-- Self/Party/Raid member
	end

	self.healthBarText:SetText(partytargethealth.."/"..partytargethealthmax);
	mouseoverhealthflag = self.id;
end

function Perl_Party_Target_HealthHide(self)
	self.healthBarText:SetText(floor(UnitHealth(self.unit)/UnitHealthMax(self.unit)*100+0.5));
	mouseoverhealthflag = 0;
end

function Perl_Party_Target_ManaShow(self)
	partytargetmana = UnitMana(self.unit);
	partytargetmanamax = UnitManaMax(self.unit);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then						-- This prevents negative mana
		partytargetmana = 0;
	end

	if (UnitPowerType(self.unit) == 1) then
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
		SetRaidTargetIconTexture(self.raidIcon, raidpartytargetindex);
		self.raidIcon:Show();
	else
		self.raidIcon:Hide();
	end
end

function Perl_Party_Target_Update_Buffs(self)
	local curableDebuffFound = 0;

	if (PCUF_COLORFRAMEDEBUFF == 1) then
		if (UnitIsFriend("player", self.unit)) then
			local debuffType;
			_, _, _, _, debuffType = UnitDebuff(self.unit, 1, 1);
			if (debuffType) then
				local color = DebuffTypeColor[debuffType];
				self.nameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
				self.statsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
				curableDebuffFound = 1;
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
		if (partytargethealth < self.healthBar:GetValue()) then
			self.healthBarFadeBar:SetMinMaxValues(0, partytargethealthmax);
			self.healthBarFadeBar:SetValue(self.healthBar:GetValue());
			self.healthBarFadeBar:Show();
			-- We don't reset the values since this breaks fading due to not using individual variables for all 4 frames (not a big deal, still looks fine)
			getglobal("Perl_Party_Target"..self.id.."_HealthBar_Fade_OnUpdate_Frame"):Show();
		end
	end
end

function Perl_Party_Target_ManaBar_Fade_Check(self)
	if (PCUF_FADEBARS == 1) then
		if (partytargetmana < self.manaBar:GetValue()) then
			self.manaBarFadeBar:SetMinMaxValues(0, partytargetmanamax);
			self.manaBarFadeBar:SetValue(self.manaBar:GetValue());
			self.manaBarFadeBar:Show();
			-- We don't reset the values since this breaks fading due to not using individual variables for all 4 frames (not a big deal, still looks fine)
			getglobal("Perl_Party_Target"..self.id.."_ManaBar_Fade_OnUpdate_Frame"):Show();
		end
	end
end

function Perl_Party_Target_One_HealthBar_Fade(arg1)
	Perl_Party_Target_One_HealthBar_Fade_Color = Perl_Party_Target_One_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target1_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_One_HealthBar_Fade_Color, 0, Perl_Party_Target_One_HealthBar_Fade_Color);

	if (Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_One_HealthBar_Fade_Color = 1;
		Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target1_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target1_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Two_HealthBar_Fade(arg1)
	Perl_Party_Target_Two_HealthBar_Fade_Color = Perl_Party_Target_Two_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target2_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Two_HealthBar_Fade_Color, 0, Perl_Party_Target_Two_HealthBar_Fade_Color);

	if (Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Two_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target2_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target2_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Three_HealthBar_Fade(arg1)
	Perl_Party_Target_Three_HealthBar_Fade_Color = Perl_Party_Target_Three_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target3_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Three_HealthBar_Fade_Color, 0, Perl_Party_Target_Three_HealthBar_Fade_Color);

	if (Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Three_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target3_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target3_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Four_HealthBar_Fade(arg1)
	Perl_Party_Target_Four_HealthBar_Fade_Color = Perl_Party_Target_Four_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target4_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Four_HealthBar_Fade_Color, 0, Perl_Party_Target_Four_HealthBar_Fade_Color);

	if (Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Four_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target4_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target4_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Five_HealthBar_Fade(arg1)
	Perl_Party_Target_Five_HealthBar_Fade_Color = Perl_Party_Target_Five_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target5_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Five_HealthBar_Fade_Color, 0, Perl_Party_Target_Five_HealthBar_Fade_Color);

	if (Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Five_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target5_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target5_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_One_ManaBar_Fade(arg1)
	Perl_Party_Target_One_ManaBar_Fade_Color = Perl_Party_Target_One_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party1target") == 0) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 1) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 2) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, (Perl_Party_Target_One_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 3) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color, 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_One_ManaBar_Fade_Color = 1;
		Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target1_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Two_ManaBar_Fade(arg1)
	Perl_Party_Target_Two_ManaBar_Fade_Color = Perl_Party_Target_Two_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party2target") == 0) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 1) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 2) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, (Perl_Party_Target_Two_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 3) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color, 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Two_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target2_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Three_ManaBar_Fade(arg1)
	Perl_Party_Target_Three_ManaBar_Fade_Color = Perl_Party_Target_Three_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party3target") == 0) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 1) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 2) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, (Perl_Party_Target_Three_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 3) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color, 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Three_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target3_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Four_ManaBar_Fade(arg1)
	Perl_Party_Target_Four_ManaBar_Fade_Color = Perl_Party_Target_Four_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party4target") == 0) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 1) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 2) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, (Perl_Party_Target_Four_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 3) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color, 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Four_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target4_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Five_ManaBar_Fade(arg1)
	Perl_Party_Target_Five_ManaBar_Fade_Color = Perl_Party_Target_Five_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("focustarget") == 0) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 1) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 2) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, (Perl_Party_Target_Five_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 3) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color, 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Five_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed = 0;
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
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar"):Hide();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBarBG"):Hide();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_CastClickOverlay"):Hide();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetHeight(30);
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_CastClickOverlay"):SetHeight(30);
			end
		else
			for partynum=1,5 do
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar"):Show();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBarBG"):Show();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_CastClickOverlay"):Show();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetHeight(42);
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_CastClickOverlay"):SetHeight(42);
			end
		end
	end
end

function Perl_Party_Target_Check_Hidden()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Check_Hidden);
	else
		if (hiddeninraid == 1) then
			if (UnitInRaid("player")) then
				Perl_Party_Target_Unregister_All(1, 1);
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
	Perl_Party_Target1:SetUserPlaced(1);		-- This makes WoW remember the changes if the frames have never been moved before
	Perl_Party_Target2:SetUserPlaced(1);
	Perl_Party_Target3:SetUserPlaced(1);
	Perl_Party_Target4:SetUserPlaced(1);
	Perl_Party_Target5:SetUserPlaced(1);

	Perl_Party_Target1:SetPoint("TOPLEFT", Perl_Party_MemberFrame1_StatsFrame, "TOPRIGHT", -4, 20);
	Perl_Party_Target2:SetPoint("TOPLEFT", Perl_Party_MemberFrame2_StatsFrame, "TOPRIGHT", -4, 20);
	Perl_Party_Target3:SetPoint("TOPLEFT", Perl_Party_MemberFrame3_StatsFrame, "TOPRIGHT", -4, 20);
	Perl_Party_Target4:SetPoint("TOPLEFT", Perl_Party_MemberFrame4_StatsFrame, "TOPRIGHT", -4, 20);
	Perl_Party_Target5:SetPoint("TOPLEFT", Perl_Focus_StatsFrame, "TOPRIGHT", -4, 20);

	Perl_Party_Target_UpdateVars();			-- Calling this to update the positions for IFrameManger
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

function Perl_Party_Target_Set_Hidden_In_Raid(newvalue)
	hiddeninraid = newvalue;
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

function Perl_Party_Target_Set_MobHealth(newvalue)
	mobhealthsupport = newvalue;
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);
	end
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Set_Scale_Actual();
end

function Perl_Party_Target_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
		Perl_Party_Target1:SetScale(unsavedscale);
		Perl_Party_Target2:SetScale(unsavedscale);
		Perl_Party_Target3:SetScale(unsavedscale);
		Perl_Party_Target4:SetScale(unsavedscale);
		Perl_Party_Target5:SetScale(unsavedscale);
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
function Perl_Party_Target_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Party_Target_Config[name]["Locked"];
	scale = Perl_Party_Target_Config[name]["Scale"];
	transparency = Perl_Party_Target_Config[name]["Transparency"];
	mobhealthsupport = Perl_Party_Target_Config[name]["MobHealthSupport"];
	hidepowerbars = Perl_Party_Target_Config[name]["HidePowerBars"];
	classcolorednames = Perl_Party_Target_Config[name]["ClassColoredNames"];
	enabled = Perl_Party_Target_Config[name]["Enabled"];
	hiddeninraid = Perl_Party_Target_Config[name]["HiddenInRaid"];
	enabledfocus = Perl_Party_Target_Config[name]["EnabledFocus"];

	if (locked == nil) then
		locked = 0;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (mobhealthsupport == nil) then
		mobhealthsupport = 1;
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
	if (hiddeninraid == nil) then
		hiddeninraid = 0;
	end
	if (enabledfocus == nil) then
		enabledfocus = 1;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Party_Target_UpdateVars();

		-- Call any code we need to activate them
		Perl_Party_Target_Set_Scale_Actual();
		Perl_Party_Target_Set_Transparency();
		Perl_Party_Target_Frame_Style();
		return;
	end

	local vars = {
		["locked"] = locked,
		["scale"] = scale,
		["transparency"] = transparency,
		["mobhealthsupport"] = mobhealthsupport,
		["hidepowerbars"] = hidepowerbars,
		["classcolorednames"] = classcolorednames,
		["enabled"] = enabled,
		["hiddeninraid"] = hiddeninraid,
		["enabledfocus"] = enabledfocus,
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
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["MobHealthSupport"] ~= nil) then
				mobhealthsupport = vartable["Global Settings"]["MobHealthSupport"];
			else
				mobhealthsupport = nil;
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
			if (vartable["Global Settings"]["HiddenInRaid"] ~= nil) then
				hiddeninraid = vartable["Global Settings"]["HiddenInRaid"];
			else
				hiddeninraid = nil;
			end
			if (vartable["Global Settings"]["EnabledFocus"] ~= nil) then
				enabledfocus = vartable["Global Settings"]["EnabledFocus"];
			else
				enabledfocus = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (scale == nil) then
			scale = 1;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (mobhealthsupport == nil) then
			mobhealthsupport = 1;
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
		if (hiddeninraid == nil) then
			hiddeninraid = 0;
		end
		if (enabledfocus == nil) then
			enabledfocus = 1;
		end

		-- Call any code we need to activate them
		Perl_Party_Target_Set_Scale_Actual();
		Perl_Party_Target_Set_Transparency();
		Perl_Party_Target_Frame_Style();
	end

	-- IFrameManager Support
	if (IFrameManager) then
		IFrameManager:Refresh();
	end

	Perl_Party_Target_Config[UnitName("player")] = {
		["Locked"] = locked,
		["Scale"] = scale,
		["Transparency"] = transparency,
		["MobHealthSupport"] = mobhealthsupport,
		["HidePowerBars"] = hidepowerbars,
		["ClassColoredNames"] = classcolorednames,
		["Enabled"] = enabled,
		["HiddenInRaid"] = hiddeninraid,
		["EnabledFocus"] = enabledfocus,
	};
end


--------------------
-- Click Handlers --
--------------------
function Perl_Party_Target_CastClickOverlay_OnLoad()
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("Perl_Party_Target"..this:GetParent():GetParent():GetID().."_DropDown"), "Perl_Party_Target"..this:GetParent():GetParent():GetID().."_NameFrame", 0, 0);
	end
	SecureUnitButton_OnLoad(this, "party"..this:GetParent():GetParent():GetID().."target", showmenu);

	if (this:GetParent():GetParent():GetID() == 5) then
		this:SetAttribute("unit", "focustarget");
	else
		this:SetAttribute("unit", "party"..this:GetParent():GetParent():GetID().."target");
	end
	
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[this] = true;
end

-- If there is a better way to do this please let me know
function Perl_Party_Target1DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Party_Target1DropDown_Initialize, "MENU");
end

function Perl_Party_Target2DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Party_Target2DropDown_Initialize, "MENU");
end

function Perl_Party_Target3DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Party_Target3DropDown_Initialize, "MENU");
end

function Perl_Party_Target4DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Party_Target4DropDown_Initialize, "MENU");
end

function Perl_Party_Target5DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Party_Target5DropDown_Initialize, "MENU");
end

function Perl_Party_Target1DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party1target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target1_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target2DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party2target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target2_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target3DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party3target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target3_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target4DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party4target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target4_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target5DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "focustarget";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "RAID_TARGET_ICON";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target5_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		getglobal("Perl_Party_Target"..this:GetID()):StartMoving();
	end
end

function Perl_Party_Target_DragStop(button)
	getglobal("Perl_Party_Target"..this:GetID()):SetUserPlaced(1);
	getglobal("Perl_Party_Target"..this:GetID()):StopMovingOrSizing();
end


-------------
-- Tooltip --
-------------
function Perl_Party_Target_Tip()
	if (this:GetID() == 5) then
		UnitFrame_Initialize("focustarget");
	else
		UnitFrame_Initialize("party"..this:GetID().."target");
	end
end

function UnitFrame_Initialize(unit)	-- Hopefully this doesn't break any mods
	this.unit = unit;
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Party_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_Party_Target_myAddOns_Details = {
			name = "Perl_Party_Target",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Party_Target_myAddOns_Help = {};
		Perl_Party_Target_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Party_Target_myAddOns_Details, Perl_Party_Target_myAddOns_Help);
	end
end