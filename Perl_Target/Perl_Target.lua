---------------
-- Variables --
---------------
Perl_Target_Config = {};

-- Default Saved Variables (also set in Perl_Target_GetVars)
local locked = 0;		-- unlocked by default
local showcp = 1;		-- combo points displayed by default
local showclassicon = 1;	-- show the class icon
local showclassframe = 1;	-- show the class frame
local showpvpicon = 1;		-- show the pvp icon
local numbuffsshown = 16;	-- buff row is 16 long
local numdebuffsshown = 16;	-- debuff row is 16 long
local mobhealthsupport = 1;	-- mobhealth support is on by default
local scale = 1;		-- default scale
local colorhealth = 0;		-- progressively colored health bars are off by default
local showpvprank = 0;		-- hide the pvp rank by default

-- Default Local Variables
local Initialized = nil;	-- waiting to be initialized
local transparency = 1;		-- 0.8 default from perl

-- Empty variables used for localization
local pt_localized_creature, pt_localized_notspecified;

-- Variables for position of the class icon texture.
local Perl_Target_ClassPosRight = {};
local Perl_Target_ClassPosLeft = {};
local Perl_Target_ClassPosTop = {};
local Perl_Target_ClassPosBottom = {};


----------------------
-- Loading Function --
----------------------
function Perl_Target_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_DISABLE");
	this:RegisterEvent("PARTY_MEMBER_ENABLE");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PLAYER_COMBO_POINTS");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_DYNAMIC_FLAGS");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_FOCUS");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Slash Commands
	SlashCmdList["PERL_TARGET"] = Perl_Target_SlashHandler;
	SLASH_PERL_TARGET1 = "/perltarget";
	SLASH_PERL_TARGET2 = "/pt";

	table.insert(UnitPopupFrames,"Perl_Target_DropDown");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame by Perl loaded successfully.");
	end
end


-------------------
-- Event Handler --
-------------------
function Perl_Target_OnEvent(event)
	if ((event == "PLAYER_TARGET_CHANGED") or (event == "PARTY_MEMBERS_CHANGED") or (event == "PARTY_LEADER_CHANGED") or (event == "PARTY_MEMBER_ENABLE") or (event == "PARTY_MEMBER_DISABLE")) then
		if (UnitExists("target")) then
			Perl_Target_Update_Once();		-- Set the unchanging info for the target
		else
			Perl_Target_Frame:Hide();
		end
		return;
	elseif (event == "UNIT_HEALTH") then
		if (arg1 == "target") then
			Perl_Target_Update_Health();		-- Update health values
		end
		return;
	elseif ((event == "UNIT_ENERGY") or (event == "UNIT_MANA") or (event == "UNIT_RAGE") or (event == "UNIT_FOCUS")) then
		if (arg1 == "target") then
			Perl_Target_Update_Mana();		-- Update energy/mana/rage values
		end
		return;
	elseif (event == "UNIT_AURA") then
		if (arg1 == "target") then
			Perl_Target_Buff_UpdateAll();		-- Update the buffs
		end
		return;
	elseif (event == "UNIT_DYNAMIC_FLAGS") then
		if (arg1 == "target") then
			Perl_Target_Update_Text_Color();	-- Has the target been tapped by someone else?
		end
		return;
	elseif (event == "UNIT_PVP_UPDATE") then
		Perl_Target_Update_Text_Color();		-- Is the character PvP flagged?
		Perl_Target_Update_PvP_Status_Icon();		-- Set pvp status icon
		return;
	elseif (event == "UNIT_LEVEL") then
		if (arg1 == "target") then
			Perl_Target_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
		end
		return;
	elseif (event == "PLAYER_COMBO_POINTS") then
		Perl_Target_Update_Combo_Points();		-- How many combo points are we at?
		return;
	elseif (event == "UNIT_DISPLAYPOWER") then
		if (arg1 == "target") then
			Perl_Target_Update_Mana_Bar();		-- What type of energy are they using now?
			Perl_Target_Update_Mana();		-- Update the energy info immediately
		end
		return;
	elseif (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD") then
		Perl_Target_Initialize();
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_Target") then
			Perl_Target_myAddOns_Support();
		end
		return;
	else
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_Target_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Target_Unlock();
		return;
	elseif (string.find(msg, "lock")) then
		Perl_Target_Lock();
		return;
	elseif (string.find(msg, "combopoints")) then
		Perl_Target_ToggleCP();
		return;
	elseif (string.find(msg, "icon")) then
		Perl_Target_ToggleClassIcon();
		return;
	elseif (string.find(msg, "class")) then
		Perl_Target_ToggleClassFrame();
		return;
	elseif (string.find(msg, "pvp")) then
		Perl_Target_TogglePvPIcon();
		return;
	elseif (string.find(msg, "mobhealth")) then
		Perl_Target_ToggleMobHealth();
		return;
	elseif (string.find(msg, "health")) then
		Perl_Target_ToggleColoredHealth();
		return;
	elseif (string.find(msg, "rank")) then
		Perl_Target_TogglePvPRank();
		return;
	elseif (string.find(msg, "status")) then
		Perl_Target_Status();
		return;
	elseif (string.find(msg, "debuffs")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			local number = tonumber(arg1);
			if (number >= 0 and number <= 16) then
				Perl_Target_Set_Debuffs(number)
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number (0-16)");
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of debuffs to display (0-16): /pt debuffs #");
		end
	elseif (string.find(msg, "buffs")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			local number = tonumber(arg1);
			if (number >= 0 and number <= 16) then
				Perl_Target_Set_Buffs(number)
				return;
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number (0-16)");
				return;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of buffs to display (0-16): /pt buffs #");
			return;
		end
	elseif (string.find(msg, "scale")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			if (arg1 == "ui") then
				Perl_Target_Set_ParentUI_Scale();
				return;
			end
			local number = tonumber(arg1);
			if (number > 0 and number < 150) then
				Perl_Target_Set_Scale(number);
				return;
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/pt scale ui' to set to the current UI scale.");
				return;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/pt scale ui' to set to the current UI scale.");
			return;
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Target Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff health |cffffff00- Toggle the displaying of progressively colored health bars.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff combopoints |cffffff00- Toggle the displaying of combo points.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff class |cffffff00- Toggle the displaying of class frame.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff icon |cffffff00- Toggle the displaying of class icon.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff pvp |cffffff00- Toggle the displaying of pvp status icon.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff rank |cffffff00- Toggle the displaying of pvp rank icon.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff mobhealth |cffffff00- Toggle the displaying of integrated MobHealth support.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff buffs # |cffffff00- Show the number of buffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff debuffs # |cffffff00- Show the number of debuffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff scale # |cffffff00- Set the scale. (1-149) You may also do '/pt scale ui' to set to the current UI scale.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
		return;
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Target_Initialize()
	if (Initialized) then
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Target_Config[UnitName("player")]) == "table") then
		Perl_Target_GetVars();
	else
		Perl_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Target_StatsFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_NameFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_ClassNameFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_ClassNameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_LevelFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_BuffFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_DebuffFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_DebuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_CPFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Target_CPFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	Perl_Target_Frame:Hide();

	Perl_Target_HealthBarText:SetTextColor(1,1,1,1);
	Perl_Target_ManaBarText:SetTextColor(1,1,1,1);
	Perl_Target_ClassNameBarText:SetTextColor(1,1,1);

	Perl_Target_Set_Localized_ClassIcons();

	-- The following UnregisterEvent calls were taken from Nymbia's Perl
	-- Blizz Target Frame Events
	TargetFrame:UnregisterEvent("UNIT_HEALTH");
	TargetFrame:UnregisterEvent("UNIT_LEVEL");
	TargetFrame:UnregisterEvent("UNIT_FACTION");
	TargetFrame:UnregisterEvent("UNIT_DYNAMIC_FLAGS");
	TargetFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
	TargetFrame:UnregisterEvent("PLAYER_PVPLEVEL_CHANGED");
	TargetFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
	TargetFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
	TargetFrame:UnregisterEvent("PARTY_LEADER_CHANGED");
	TargetFrame:UnregisterEvent("PARTY_MEMBER_ENABLE");
	TargetFrame:UnregisterEvent("PARTY_MEMBER_DISABLE");
	TargetFrame:UnregisterEvent("UNIT_AURA");
	TargetFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	ComboFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
	ComboFrame:UnregisterEvent("PLAYER_COMBO_POINTS");
	TargetFrameHealthBar:UnregisterEvent("UNIT_HEALTH");
	TargetFrameHealthBar:UnregisterEvent("UNIT_MAXHEALTH");
	-- ManaBar Events
	TargetFrameManaBar:UnregisterEvent("UNIT_MANA");
	TargetFrameManaBar:UnregisterEvent("UNIT_RAGE");
	TargetFrameManaBar:UnregisterEvent("UNIT_FOCUS");
	TargetFrameManaBar:UnregisterEvent("UNIT_ENERGY");
	TargetFrameManaBar:UnregisterEvent("UNIT_HAPPINESS");
	TargetFrameManaBar:UnregisterEvent("UNIT_MAXMANA");
	TargetFrameManaBar:UnregisterEvent("UNIT_MAXRAGE");
	TargetFrameManaBar:UnregisterEvent("UNIT_MAXFOCUS");
	TargetFrameManaBar:UnregisterEvent("UNIT_MAXENERGY");
	TargetFrameManaBar:UnregisterEvent("UNIT_MAXHAPPINESS");
	TargetFrameManaBar:UnregisterEvent("UNIT_DISPLAYPOWER");
	-- UnitFrame Events
	TargetFrame:UnregisterEvent("UNIT_NAME_UPDATE");
	TargetFrame:UnregisterEvent("UNIT_PORTRAIT_UPDATE");
	TargetFrame:UnregisterEvent("UNIT_DISPLAYPOWER");

	Initialized = 1;
end


--------------------------
-- The Update Functions --
--------------------------
function Perl_Target_Update_Once()
	if (UnitExists("target")) then
		Perl_Target_Frame:Show();		-- Show frame
		Perl_Target_Frame:SetScale(scale);	-- Set the scale (easier ways exist, but this is the safest)
		ComboFrame:Hide();			-- Hide default Combo Points
		Perl_Target_Frame_Set_Name();		-- Set the target's name
		Perl_Target_Update_Text_Color();	-- Has the target been tapped by someone else?
		Perl_Target_Update_Health();		-- Set the target's health
		Perl_Target_Update_Mana_Bar();		-- What type of mana bar is it?
		Perl_Target_Update_Mana();		-- Set the target's mana
		Perl_Target_Update_PvP_Status_Icon();	-- Set pvp status icon
		Perl_Target_Frame_Set_PvPRank();	-- Set the pvp rank icon
		Perl_Target_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
		Perl_Target_Set_Character_Class_Icon();	-- Draw the class icon?
		Perl_Target_Set_Target_Class();		-- Set the target's class in the class frame
		Perl_Target_Buff_UpdateAll();		-- Update the buffs
	end
end

function Perl_Target_Update_Health()
	local targethealth = UnitHealth("target");
	local targethealthmax = UnitHealthMax("target");
	local targethealthpercent = floor(targethealth/targethealthmax*100+0.5);

	Perl_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
	Perl_Target_HealthBar:SetValue(targethealth);

	if (colorhealth == 1) then
		if ((targethealthpercent <= 100) and (targethealthpercent > 75)) then
			Perl_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
			Perl_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
		elseif ((targethealthpercent <= 75) and (targethealthpercent > 50)) then
			Perl_Target_HealthBar:SetStatusBarColor(1, 1, 0);
			Perl_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		elseif ((targethealthpercent <= 50) and (targethealthpercent > 25)) then
			Perl_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
			Perl_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		else
			Perl_Target_HealthBar:SetStatusBarColor(1, 0, 0);
			Perl_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		end
	else
		Perl_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (targethealthmax == 100) then
		-- Begin Mobhealth support
		if (mobhealthsupport == 1) then
			if (MobHealthFrame) then
				MobHealthFrame:Hide();

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
							Perl_Target_HealthBarText:SetText(targethealth.."%");
						end
						s, e, pts, pct = string.find(MobHealthDB[index], "^(%d+)/(%d+)$");
					else
						if (type(MobHealthPlayerDB[index]) ~= "string") then
							Perl_Target_HealthBarText:SetText(targethealth.."%");
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
						Perl_Target_HealthBarText:SetText(string.format("%d", (currentPct * pointsPerPct) + 0.5).."/"..string.format("%d", (100 * pointsPerPct) + 0.5).." | "..targethealth.."%");	-- Stored unit info from the DB
					end
				else
					Perl_Target_HealthBarText:SetText(targethealth.."%");	-- Unit not in MobHealth DB
				end
			-- End MobHealth Support
			else
				Perl_Target_HealthBarText:SetText(targethealth.."%");	-- MobHealth isn't installed
			end
		else	-- mobhealthsupport == 0
			if (MobHealthFrame) then
				MobHealthFrame:Show();
			end
			Perl_Target_HealthBarText:SetText(targethealth.."%");	-- MobHealth support is disabled
		end
	else
		Perl_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);	-- Self/Party/Raid member
	end

	-- Set Dead Icon (for pve)
	if (UnitIsDead("target")) then
		Perl_Target_DeadStatus:Show();
	else
		Perl_Target_DeadStatus:Hide();
	end
end

function Perl_Target_Update_Mana()
	local targetmana = UnitMana("target");
	local targetmanamax = UnitManaMax("target");

	Perl_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
	Perl_Target_ManaBar:SetValue(targetmana);

	if (UnitPowerType("target") == 1 or UnitPowerType("target") == 2) then
		Perl_Target_ManaBarText:SetText(targetmana);
	else
		Perl_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
	end
end

function Perl_Target_Update_Mana_Bar()
	local targetmanamax = UnitManaMax("target");
	local targetpower = UnitPowerType("target");

	-- Set mana bar color
	if (targetmanamax == 0) then
		Perl_Target_ManaBar:Hide();
		Perl_Target_ManaBarBG:Hide();
		Perl_Target_StatsFrame:SetHeight(30);
	elseif (targetpower == 1) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(42);
	elseif (targetpower == 2) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(42);
	elseif (targetpower == 3) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(42);
	else
		Perl_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(42);
	end
end

function Perl_Target_Update_Combo_Points()
	-- Set combo points
	ComboFrame:Hide();	-- Hide default Combo Points
	if (showcp == 1) then
		local combopoints = GetComboPoints();
		Perl_Target_CPText:SetText(combopoints);
		if (combopoints == 5) then
			Perl_Target_CPFrame:Show();
			Perl_Target_CPText:SetTextColor(1, 0, 0); -- red text
			Perl_Target_CPText:SetTextHeight(20);
		elseif (combopoints == 4) then
			Perl_Target_CPFrame:Show();
			Perl_Target_CPText:SetTextColor(1, 0.5, 0); -- orange text
			Perl_Target_CPText:SetTextHeight(15);
		elseif (combopoints == 3) then
			Perl_Target_CPFrame:Show();
			Perl_Target_CPText:SetTextColor(1, 1, 0); -- yellow text
			Perl_Target_CPText:SetTextHeight(12);
		elseif (combopoints == 2) then
			Perl_Target_CPFrame:Show();
			Perl_Target_CPText:SetTextColor(0.5, 1, 0); -- yellow-green text
			Perl_Target_CPText:SetTextHeight(11);
		elseif (combopoints == 1) then
			Perl_Target_CPFrame:Show();
			Perl_Target_CPText:SetTextColor(0, 1, 0); -- green text
			Perl_Target_CPText:SetTextHeight(8);
		else
			Perl_Target_CPFrame:Hide();
		end
	else
		Perl_Target_CPFrame:Hide();
	end
end

function Perl_Target_Update_PvP_Status_Icon()
	if (showpvpicon == 1) then
		local factionGroup = UnitFactionGroup("target");
		if (UnitIsPVPFreeForAll("target")) then
			Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			Perl_Target_PVPStatus:Show();
		elseif (factionGroup and UnitIsPVP("target")) then
			Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
			Perl_Target_PVPStatus:Show();
		else
			Perl_Target_PVPStatus:Hide();
		end
	else
		Perl_Target_PVPStatus:Hide();
	end
end

function Perl_Target_Update_Text_Color()
	if (UnitIsPlayer("target") or UnitPlayerControlled("target")) then		-- is it a player
		local r, g, b;
		if (UnitCanAttack("target", "player")) then				-- are we in an enemy controlled zone
			-- Hostile players are red
			if (not UnitCanAttack("player", "target")) then			-- enemy is not pvp enabled
				r = 0.5;
				g = 0.5;
				b = 1.0;
			else								-- enemy is pvp enabled
				r = 1.0;
				g = 0.0;
				b = 0.0;
			end
		elseif (UnitCanAttack("player", "target")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
			-- Players we can attack but which are not hostile are yellow
			r = 1.0;
			g = 1.0;
			b = 0.0;
		elseif (UnitIsPVP("target")) then					-- friendly pvp enabled character
			-- Players we can assist but are PvP flagged are green
			r = 0.0;
			g = 1.0;
			b = 0.0;
		else									-- friendly non pvp enabled character
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.5;
			g = 0.5;
			b = 1.0;
		end
		Perl_Target_NameBarText:SetTextColor(r, g, b);
	elseif (UnitIsTapped("target") and not UnitIsTappedByPlayer("target")) then
		Perl_Target_NameBarText:SetTextColor(0.5,0.5,0.5);			-- not our tap
	else
		local reaction = UnitReaction("target", "player");
		if (reaction) then
			local r, g, b;
			r = UnitReactionColor[reaction].r;
			g = UnitReactionColor[reaction].g;
			b = UnitReactionColor[reaction].b;
			Perl_Target_NameBarText:SetTextColor(r, g, b);
		else
			Perl_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
		end
	end
end

function Perl_Target_Frame_Set_Name()
	local targetname = UnitName("target");
	-- Set name
	if (strlen(targetname) > 20) then
		targetname = strsub(targetname, 1, 19).."...";
	end
	Perl_Target_NameBarText:SetText(targetname);
end

function Perl_Target_Frame_Set_PvPRank()
	if (showpvprank == 1) then
		if (UnitIsPlayer("target")) then
			local rankNumber = UnitPVPRank("target");
			if (rankNumber == 0) then
				Perl_Target_PVPRank:Hide();
			elseif (rankNumber < 14) then
				rankNumber = rankNumber - 4;
				Perl_Target_PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank0"..rankNumber);
				Perl_Target_PVPRank:Show();
			else
				rankNumber = rankNumber - 4;
				Perl_Target_PVPRank:SetTexture("Interface\\PvPRankBadges\\PvPRank"..rankNumber);
				Perl_Target_PVPRank:Show();
			end
		else
			Perl_Target_PVPRank:Hide();
		end
	else
		Perl_Target_PVPRank:Hide();
	end
end

function Perl_Target_Frame_Set_Level()
	local targetlevel = UnitLevel("target");
	local targetlevelcolor = GetDifficultyColor(targetlevel);
	local targetclassification = UnitClassification("target");

	Perl_Target_LevelBarText:SetVertexColor(targetlevelcolor.r, targetlevelcolor.g, targetlevelcolor.b);
	if ((targetclassification == "worldboss") or (targetlevel < 0)) then
		Perl_Target_LevelBarText:SetTextColor(1, 0, 0);
		targetlevel = "??";
	end

	if (targetclassification == "rareelite") then
		targetlevel = targetlevel.."r+";
	elseif (targetclassification == "elite") then
		targetlevel = targetlevel.."+";
	elseif (targetclassification == "rare") then
		targetlevel = targetlevel.."r";
	end

	Perl_Target_LevelBarText:SetText(targetlevel);
end

function Perl_Target_Set_Character_Class_Icon()
	if (showclassicon == 1) then
		if (UnitIsPlayer("target")) then
			local PlayerClass = UnitClass("target");
			Perl_Target_ClassTexture:SetTexCoord(Perl_Target_ClassPosRight[PlayerClass], Perl_Target_ClassPosLeft[PlayerClass], Perl_Target_ClassPosTop[PlayerClass], Perl_Target_ClassPosBottom[PlayerClass]);							
			Perl_Target_ClassTexture:Show();
		else
			Perl_Target_ClassTexture:Hide();
		end
	else
		Perl_Target_ClassTexture:Hide();
	end
end

function Perl_Target_Set_Target_Class()
	if (showclassframe == 1) then
		if (UnitIsPlayer("target")) then
			local targetClass = UnitClass("target");
			Perl_Target_ClassNameBarText:SetText(targetClass);
			Perl_Target_ClassNameFrame:Show();
		else
			local targetCreatureType = UnitCreatureType("target");
			if (targetCreatureType == pt_localized_notspecified) then
				targetCreatureType = pt_localized_creature;
			end
			Perl_Target_ClassNameBarText:SetText(targetCreatureType);
			Perl_Target_ClassNameFrame:Show();
		end
	else
		Perl_Target_ClassNameFrame:Hide();
	end
end

function Perl_Target_Set_Localized_ClassIcons()
	local pt_translate_druid;
	local pt_translate_hunter;
	local pt_translate_mage;
	local pt_translate_paladin;
	local pt_translate_priest;
	local pt_translate_rogue;
	local pt_translate_shaman;
	local pt_translate_warlock;
	local pt_translate_warrior;

	if (GetLocale() == "deDE") then
		pt_translate_druid = "Druide";
		pt_translate_hunter = "J\195\164ger";
		pt_translate_mage = "Magier";
		pt_translate_paladin = "Paladin";
		pt_translate_priest = "Priester";
		pt_translate_rogue = "Schurke";
		pt_translate_shaman = "Schamane";
		pt_translate_warlock = "Hexenmeister";
		pt_translate_warrior = "Krieger";

		pt_localized_creature = "Kreatur";
		pt_localized_notspecified = "Nicht spezifiziert";
	end

	if (GetLocale() == "enUS") then
		pt_translate_druid = "Druid";
		pt_translate_hunter = "Hunter";
		pt_translate_mage = "Mage";
		pt_translate_paladin = "Paladin";
		pt_translate_priest = "Priest";
		pt_translate_rogue = "Rogue";
		pt_translate_shaman = "Shaman";
		pt_translate_warlock = "Warlock";
		pt_translate_warrior = "Warrior";

		pt_localized_creature = "Creature";
		pt_localized_notspecified = "Not specified";
	end

	if (GetLocale() == "frFR") then
		pt_translate_druid = "Druide";
		pt_translate_hunter = "Chasseur";
		pt_translate_mage = "Mage";
		pt_translate_paladin = "Paladin";
		pt_translate_priest = "Pr\195\170tre";
		pt_translate_rogue = "Voleur";
		pt_translate_shaman = "Chaman";
		pt_translate_warlock = "D\195\169moniste";
		pt_translate_warrior = "Guerrier";

		pt_localized_creature = "Cr\195\169ature";
		pt_localized_notspecified = "Non indiqu\195\169";
	end

	Perl_Target_ClassPosRight = {
		[pt_translate_druid] = 0.75,
		[pt_translate_hunter] = 0,
		[pt_translate_mage] = 0.25,
		[pt_translate_paladin] = 0,
		[pt_translate_priest] = 0.5,
		[pt_translate_rogue] = 0.5,
		[pt_translate_shaman] = 0.25,
		[pt_translate_warlock] = 0.75,
		[pt_translate_warrior] = 0,
	};
	Perl_Target_ClassPosLeft = {
		[pt_translate_druid] = 1,
		[pt_translate_hunter] = 0.25,
		[pt_translate_mage] = 0.5,
		[pt_translate_paladin] = 0.25,
		[pt_translate_priest] = 0.75,
		[pt_translate_rogue] = 0.75,
		[pt_translate_shaman] = 0.5,
		[pt_translate_warlock] = 1,
		[pt_translate_warrior] = 0.25,
	};
	Perl_Target_ClassPosTop = {
		[pt_translate_druid] = 0,
		[pt_translate_hunter] = 0.25,
		[pt_translate_mage] = 0,
		[pt_translate_paladin] = 0.5,
		[pt_translate_priest] = 0.25,
		[pt_translate_rogue] = 0,
		[pt_translate_shaman] = 0.25,
		[pt_translate_warlock] = 0.25,
		[pt_translate_warrior] = 0,
		
	};
	Perl_Target_ClassPosBottom = {
		[pt_translate_druid] = 0.25,
		[pt_translate_hunter] = 0.5,
		[pt_translate_mage] = 0.25,
		[pt_translate_paladin] = 0.75,
		[pt_translate_priest] = 0.5,
		[pt_translate_rogue] = 0.25,
		[pt_translate_shaman] = 0.5,
		[pt_translate_warlock] = 0.5,
		[pt_translate_warrior] = 0.25,
	};
end


----------------------
-- Config functions --
----------------------
function Perl_Target_Lock()
	locked = 1;
	Perl_Target_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is now |cffffffffLocked|cffffff00.");
end

function Perl_Target_Unlock()
	locked = 0;
	Perl_Target_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is now |cffffffffUnlocked|cffffff00.");
end

function Perl_Target_ToggleCP()
	if (showcp == 1) then
		showcp = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Combo Points are now |cffffffffHidden|cffffff00.");
	else
		showcp = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Combo Points are now |cffffffffShown|cffffff00.");
	end
	Perl_Target_UpdateVars();
end

function Perl_Target_ToggleClassIcon()
	if (showclassicon == 1) then
		showclassicon = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Icon is now |cffffffffHidden|cffffff00.");
	else
		showclassicon = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Icon is now |cffffffffShown|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_ToggleClassIcon()
	if (showclassicon == 1) then
		showclassicon = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Icon is now |cffffffffHidden|cffffff00.");
	else
		showclassicon = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Icon is now |cffffffffShown|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_ToggleClassFrame()
	if (showclassframe == 1) then
		showclassframe = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Frame is now |cffffffffHidden|cffffff00.");
	else
		showclassframe = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Frame is now |cffffffffShown|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_TogglePvPIcon()
	if (showpvpicon == 1) then
		showpvpicon = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame PvP Icon is now |cffffffffHidden|cffffff00.");
	else
		showpvpicon = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame PvP Icon is now |cffffffffShown|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_Set_Buffs(newbuffnumber)
	if (newbuffnumber == nil) then
		newbuffnumber = 16;
	end
	numbuffsshown = newbuffnumber;
	Perl_Target_UpdateVars();
	Perl_Target_Reset_Buffs();	-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();	-- Repopulate the buff icons
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numbuffsshown.."|cffffff00 buffs.");
end

function Perl_Target_Set_Debuffs(newdebuffnumber)
	if (newdebuffnumber == nil) then
		newdebuffnumber = 16;
	end
	numdebuffsshown = newdebuffnumber;
	Perl_Target_UpdateVars();
	Perl_Target_Reset_Buffs();	-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();	-- Repopulate the buff icons
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numdebuffsshown.."|cffffff00 debuffs.");
end

function Perl_Target_ToggleMobHealth()
	if (mobhealthsupport == 1) then
		mobhealthsupport = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame MobHealth support is now |cffffffffDisabled|cffffff00.");
	else
		mobhealthsupport = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame MobHealth support is now |cffffffffEnabled|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_Set_ParentUI_Scale()
	scale = UIParent:GetScale();
	Perl_Target_Frame:SetScale(scale);
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Target Display is now scaled to |cffffffff"..(scale * 100).."|cffffff00.");
	Perl_Target_UpdateVars();
end

function Perl_Target_Set_Scale(number)
	scale = (number / 100);
	Perl_Target_Frame:SetScale(scale);
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Target Display is now scaled to |cffffffff"..(scale * 100).."|cffffff00.");
	Perl_Target_UpdateVars();
end

function Perl_Target_ToggleColoredHealth()
	if (colorhealth == 1) then
		colorhealth = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is now displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		colorhealth = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is now displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_TogglePvPRank()
	if (showpvprank == 1) then
		showpvprank = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is now |cffffffffHiding PvP Rank|cffffff00.");
	else
		showpvprank = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is now |cffffffffDisplaying PvP Rank|cffffff00.");
	end
	Perl_Target_UpdateVars();
	Perl_Target_Update_Once();
end

function Perl_Target_Status()
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffLocked|cffffff00.");
	end

	if (colorhealth == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end

	if (showcp == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Combo Points are |cffffffffHidden|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Combo Points are |cffffffffShown|cffffff00.");
	end

	if (showclassicon == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Icon is |cffffffffHidden|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Icon is |cffffffffShown|cffffff00.");
	end

	if (showclassframe == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Frame is |cffffffffHidden|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Frame is |cffffffffShown|cffffff00.");
	end

	if (showpvpicon == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame PvP Icon is |cffffffffHidden|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame PvP Icon is |cffffffffShown|cffffff00.");
	end

	if (showpvprank == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffHiding PvP Rank|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffDisplaying PvP Rank|cffffff00.");
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numbuffsshown.."|cffffff00 buffs.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numdebuffsshown.."|cffffff00 debuffs.");

	if (mobhealthsupport == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Frame has MobHealth support |cffffffffDisabled|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame Class Frame has MobHealth support |cffffffffEnabled|cffffff00.");
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying at a scale of |cffffffff"..(scale * 100).."%|cffffff00.");
end

function Perl_Target_GetVars()
	locked = Perl_Target_Config[UnitName("player")]["Locked"];
	showcp = Perl_Target_Config[UnitName("player")]["ComboPoints"];
	showclassicon = Perl_Target_Config[UnitName("player")]["ClassIcon"];
	showclassframe = Perl_Target_Config[UnitName("player")]["ClassFrame"];
	showpvpicon = Perl_Target_Config[UnitName("player")]["PvPIcon"]; 
	numbuffsshown = Perl_Target_Config[UnitName("player")]["Buffs"];
	numdebuffsshown = Perl_Target_Config[UnitName("player")]["Debuffs"];
	mobhealthsupport = Perl_Target_Config[UnitName("player")]["MobHealthSupport"];
	scale = Perl_Target_Config[UnitName("player")]["Scale"];
	colorhealth = Perl_Target_Config[UnitName("player")]["ColorHealth"];
	showpvprank = Perl_Target_Config[UnitName("player")]["ShowPvPRank"];

	if (locked == nil) then
		locked = 0;
	end
	if (showcp == nil) then
		showcp = 1;
	end
	if (showclassicon == nil) then
		showclassicon = 1;
	end
	if (showpvpicon == nil) then
		showpvpicon = 1;
	end
	if (showclassframe == nil) then
		showclassframe = 1;
	end
	if (numbuffsshown == nil) then
		numbuffsshown = 16;
	end
	if (numdebuffsshown == nil) then
		numdebuffsshown = 16;
	end
	local tempnumbuffsshown = tonumber(numbuffsshown);
	if (tempnumbuffsshown > 16) then
		numbuffsshown = 16;
	end
	if (mobhealthsupport == nil) then
		mobhealthsupport = 1;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (colorhealth == nil) then
		colorhealth = 0;
	end
	if (showpvprank == nil) then
		showpvprank = 0;
	end
end

function Perl_Target_UpdateVars()
	Perl_Target_Config[UnitName("player")] = {
						["Locked"] = locked,
						["ComboPoints"] = showcp,
						["ClassIcon"] = showclassicon,
						["ClassFrame"] = showclassframe,
						["PvPIcon"] = showpvpicon,
						["Buffs"] = numbuffsshown,
						["Debuffs"] = numdebuffsshown,
						["MobHealthSupport"] = mobhealthsupport,
						["Scale"] = scale,
						["ColorHealth"] = colorhealth,
						["ShowPvPRank"] = showpvprank,
						};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Target_Buff_UpdateAll()
	local friendly;
	if (UnitName("target")) then
		if (UnitIsFriend("player", "target")) then
			friendly = 1;
		else
			friendly = 0;
		end

		local buffmax = 0;
		for buffnum=1,numbuffsshown do
			local button = getglobal("Perl_Target_Buff"..buffnum);
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");

			if (UnitBuff("target", buffnum)) then
				icon:SetTexture(UnitBuff("target", buffnum));
				button.isdebuff = 0;
				debuff:Hide();
				button:Show();
				buffmax = buffnum;
			else
				button:Hide();
			end
		end

		local debuffmax = 0;
		local debuffCount, debuffTexture, debuffApplications;
		for debuffnum=1,numdebuffsshown do
			debuffTexture, debuffApplications = UnitDebuff("target", debuffnum);
			local button = getglobal("Perl_Target_Debuff"..debuffnum);
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");

			if (UnitDebuff("target", debuffnum)) then
				icon:SetTexture(debuffTexture);
				button.isdebuff = 1;
				debuff:Show();
				button:Show();
				debuffCount = getglobal("Perl_Target_Debuff"..debuffnum.."Count");
				if (debuffApplications > 1) then
					debuffCount:SetText(debuffApplications);
					debuffCount:Show();
				else
					debuffCount:Hide();
				end
				debuffmax = debuffnum;
			else
				button:Hide();
			end
		end

		if (buffmax == 0) then
			Perl_Target_BuffFrame:Hide();
		else
			if (friendly == 1) then
				Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, 5);
			else
				if (debuffmax > 8) then
					Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -51);
				else
					Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -25);
				end
			end
			Perl_Target_BuffFrame:Show();
			if (buffmax > 8) then
				Perl_Target_BuffFrame:SetWidth(221);	-- 5 + 8 * 27
				Perl_Target_BuffFrame:SetHeight(61);
			else
				Perl_Target_BuffFrame:SetWidth(5 + buffmax * 27);
				Perl_Target_BuffFrame:SetHeight(34);
			end
		end

		if (debuffmax == 0) then
			Perl_Target_DebuffFrame:Hide();
		else
			if (friendly == 1) then
				if (buffmax > 8) then
					Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -51);
				else
					Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -25);
				end
			else
				Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, 5);
			end
			Perl_Target_DebuffFrame:Show();
			if (debuffmax > 8) then
				Perl_Target_DebuffFrame:SetWidth(221);	-- 5 + 8 * 27
				Perl_Target_DebuffFrame:SetHeight(61);
			else
				Perl_Target_DebuffFrame:SetWidth(5 + debuffmax * 27);
				Perl_Target_DebuffFrame:SetHeight(34);
			end
		end
	end
end

function Perl_Target_Reset_Buffs()
	local button;
	for buffnum=1,16 do
		button = getglobal("Perl_Target_Buff"..buffnum);
		button:Hide();
		button = getglobal("Perl_Target_Debuff"..buffnum);
		button:Hide();
	end
end

function Perl_Target_SetBuffTooltip()
	local buffmapping = 0;
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT");
	if (this.isdebuff == 1) then
		GameTooltip:SetUnitDebuff("target", this:GetID()-buffmapping);
	else
		GameTooltip:SetUnitBuff("target", this:GetID());
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_TargetDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_TargetDropDown_Initialize, "MENU");
end

function Perl_TargetDropDown_Initialize()
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
		UnitPopup_ShowMenu(Perl_Target_DropDown, menu, "target");
	end
end

function Perl_Target_MouseUp(button)
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("target");
		elseif (CursorHasItem()) then
			DropItemOnUnit("target");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_Target_DropDown, "Perl_Target_NameFrame", 40, 0);
	end

	Perl_Target_Frame:StopMovingOrSizing();
end

function Perl_Target_MouseDown(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Target_Frame:StartMoving();
	end
end

function Perl_Target_OnShow()
	if ( UnitIsEnemy("target", "player") ) then
		PlaySound("igCreatureAggroSelect");
	elseif ( UnitIsFriend("player", "target") ) then
		PlaySound("igCharacterNPCSelect");
	else
		PlaySound("igCreatureNeutralSelect");
	end
end


-------------
-- Tooltip --
-------------
function Perl_Target_Tip()
	UnitFrame_Initialize("target")
end

function UnitFrame_Initialize(unit)	-- Hopefully this doesn't break any mods
	this.unit = unit;
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Target_myAddOns_Details = {
			name = "Perl_Target",
			version = "v0.27",
			releaseDate = "December 21, 2005",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Target_myAddOns_Help = {};
		Perl_Target_myAddOns_Help[1] = "/perltarget\n/pt\n";
		myAddOnsFrame_Register(Perl_Target_myAddOns_Details, Perl_Target_myAddOns_Help);
	end
end