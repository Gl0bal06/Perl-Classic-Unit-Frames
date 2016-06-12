---------------
-- Variables --
---------------
Perl_Player_Config = {};

-- Default Saved Variables (also set in Perl_Player_GetVars)
local locked = 0;		-- unlocked by default
local xpbarstate = 1;		-- show default xp bar by default
local compactmode = 0;		-- compact mode is disabled by default
local showraidgroup = 1;	-- show the raid group number by default when in raids
local scale = 1;		-- default scale
local colorhealth = 0;		-- progressively colored health bars are off by default
local healermode = 0;		-- nurfed unit frame style
local transparency = 1;		-- transparency for frames

-- Default Local Variables
local InCombat = 0;		-- used to track if the player is in combat and if the icon should be displayed
local Initialized = nil;	-- waiting to be initialized
local mouseoverhealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovermanaflag = 0;	-- is the mouse over the mana bar for healer mode?

-- Variables for position of the class icon texture.
local Perl_Player_ClassPosRight = {};
local Perl_Player_ClassPosLeft = {};
local Perl_Player_ClassPosTop = {};
local Perl_Player_ClassPosBottom = {};


----------------------
-- Loading Function --
----------------------
function Perl_Player_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_UPDATE_RESTING");
	this:RegisterEvent("PLAYER_XP_UPDATE");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Slash Commands
	SlashCmdList["PERL_PLAYER"] = Perl_Player_SlashHandler;
	SLASH_PERL_PLAYER1 = "/perlplayer";
	SLASH_PERL_PLAYER2 = "/pp";
	
	table.insert(UnitPopupFrames,"Perl_Player_DropDown");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame by Perl loaded successfully.");
	end
end


-------------------
-- Event Handler --
-------------------
function Perl_Player_OnEvent(event)
	if (event == "UNIT_HEALTH") then
		if (arg1 == "player") then
			Perl_Player_Update_Health();		-- Update health values
		end
		return;
	elseif ((event == "UNIT_ENERGY") or (event == "UNIT_MANA") or (event == "UNIT_RAGE")) then
		if (arg1 == "player") then
			Perl_Player_Update_Mana();		-- Update energy/mana/rage values
		end
		return;
	elseif (event == "UNIT_DISPLAYPOWER") then
		if (arg1 == "player") then
			Perl_Player_Update_Mana_Bar();		-- What type of energy are we using now?
			Perl_Player_Update_Mana();		-- Update the energy info immediately
		end
		return;
	elseif ((event == "PLAYER_REGEN_DISABLED") or (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_UPDATE_RESTING")) then
		Perl_Player_Update_Combat_Status(event);	-- Are we fighting, resting, or none?
		return;
	elseif (event == "PLAYER_XP_UPDATE") then
		if (xpbarstate == 1) then
			Perl_Player_Update_Experience();	-- Set the experience bar info
		end
		return;
	elseif (event == "UNIT_PVP_UPDATE") then
		Perl_Player_Update_PvP_Status();		-- Is the character PvP flagged?
		return;
	elseif (event == "UNIT_LEVEL") then
		if (arg1 == "player") then
			Perl_Player_LevelFrame_LevelBarText:SetText(UnitLevel("player"));	-- Set the player's level
		end
		return;
	elseif (event == "RAID_ROSTER_UPDATE") then
		Perl_Player_Update_Raid_Group_Number();		-- What raid group number are we in?
		return;
	elseif (event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBERS_CHANGED") then
		Perl_Player_Update_Leader();			-- Are we the party leader?
		return;
	elseif (event == "PARTY_LOOT_METHOD_CHANGED") then
		Perl_Player_Update_Loot_Method();
		return;
	elseif (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD") then
		Perl_Player_Initialize();
		InCombat = 0;				-- You can't be fighting if you're zoning, and no event is sent, force it to no combat.
		Perl_Player_Update_Once();
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_Player") then
			Perl_Player_myAddOns_Support();
		end
		return;
	else
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_Player_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Player_Unlock();
	elseif (string.find(msg, "lock")) then
		Perl_Player_Lock();
	elseif (string.find(msg, "compact")) then
		Perl_Player_Toggle_CompactMode();
	elseif (string.find(msg, "health")) then
		Perl_Player_ToggleColoredHealth();
		return;
	elseif (string.find(msg, "raid")) then
		Perl_Player_Toggle_RaidGroupNumber();
	elseif (string.find(msg, "healer")) then
		Perl_Player_ToggleHealerMode();
	elseif (string.find(msg, "scale")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			if (arg1 == "ui") then
				Perl_Player_Set_ParentUI_Scale();
				return;
			end
			local number = tonumber(arg1);
			if (number > 0 and number < 150) then
				Perl_Player_Set_Scale(number);
				return;
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/pp scale ui' to set to the current UI scale.");
				return;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/pp scale ui' to set to the current UI scale.");
			return;
		end
	elseif (string.find(msg, "status")) then
		Perl_Player_Status();
	elseif (string.find(msg, "xp")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			local number = tonumber(arg1);
			if (number > 0 and number < 4) then
				Perl_Player_XPBar_Display(number);
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number: 1, 2, or 3");
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number: 1, 2, or 3");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Player Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff compact |cffffff00- Toggle compact mode.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff health |cffffff00- Toggle the displaying of progressively colored health bars.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff raid |cffffff00- Toggle the displaying of your group number while in a raid.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff healer |cffffff00- Toggle the 'healer' mode.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff xp # |cffffff00- Set the display mode of the experience bar: 1) default, 2) pvp rank, 3) off");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff scale # |cffffff00- Set the scale. (1-149) You may also do '/pp scale ui' to set to the current UI scale.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Player_Initialize()
	-- Check if we loaded the mod already.
	if (Initialized) then
		Perl_Player_Set_Scale();
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Player_Config[UnitName("player")]) == "table") then
		Perl_Player_GetVars();
	else
		Perl_Player_UpdateVars();
	end

	-- Major config options.
	Perl_Player_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_LevelFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_RaidGroupNumberFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_RaidGroupNumberFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	Perl_Player_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Player_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_Player_RaidGroupNumberBarText:SetTextColor(1, 1, 1);

	Perl_Player_Set_Localized_ClassIcons();

	-- The following UnregisterEvent calls were taken from Nymbia's Perl
	-- Blizz Player Frame Events
	PlayerFrame:UnregisterEvent("UNIT_LEVEL");
	PlayerFrame:UnregisterEvent("UNIT_COMBAT");
	PlayerFrame:UnregisterEvent("UNIT_SPELLMISS");
	PlayerFrame:UnregisterEvent("UNIT_PVP_UPDATE");
	PlayerFrame:UnregisterEvent("UNIT_MAXMANA");
	PlayerFrame:UnregisterEvent("PLAYER_ENTER_COMBAT");
	PlayerFrame:UnregisterEvent("PLAYER_LEAVE_COMBAT");
	PlayerFrame:UnregisterEvent("PLAYER_UPDATE_RESTING");
	PlayerFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
	PlayerFrame:UnregisterEvent("PARTY_LEADER_CHANGED");
	PlayerFrame:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED");
	PlayerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	PlayerFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
	PlayerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
	PlayerFrameHealthBar:UnregisterEvent("UNIT_HEALTH");
	PlayerFrameHealthBar:UnregisterEvent("UNIT_MAXHEALTH");
	-- ManaBar Events
	PlayerFrameManaBar:UnregisterEvent("UNIT_MANA");
	PlayerFrameManaBar:UnregisterEvent("UNIT_RAGE");
	PlayerFrameManaBar:UnregisterEvent("UNIT_FOCUS");
	PlayerFrameManaBar:UnregisterEvent("UNIT_ENERGY");
	PlayerFrameManaBar:UnregisterEvent("UNIT_HAPPINESS");
	PlayerFrameManaBar:UnregisterEvent("UNIT_MAXMANA");
	PlayerFrameManaBar:UnregisterEvent("UNIT_MAXRAGE");
	PlayerFrameManaBar:UnregisterEvent("UNIT_MAXFOCUS");
	PlayerFrameManaBar:UnregisterEvent("UNIT_MAXENERGY");
	PlayerFrameManaBar:UnregisterEvent("UNIT_MAXHAPPINESS");
	PlayerFrameManaBar:UnregisterEvent("UNIT_DISPLAYPOWER");
	-- UnitFrame Events
	PlayerFrame:UnregisterEvent("UNIT_NAME_UPDATE");
	PlayerFrame:UnregisterEvent("UNIT_PORTRAIT_UPDATE");
	PlayerFrame:UnregisterEvent("UNIT_DISPLAYPOWER");

	Perl_Player_Frame:Show();

	Initialized = 1;
end


----------------------
-- Update Functions --
----------------------
function Perl_Player_Update_Once()
	local PlayerClass = UnitClass("player");

	PlayerFrame:Hide();					-- Hide default frame
	Perl_Player_Set_Scale();				-- Set the scale
	Perl_Player_Set_Transparency();				-- Set the transparency
	Perl_Player_NameBarText:SetText(UnitName("player"));	-- Set the player's name
	Perl_Player_Update_PvP_Status();			-- Is the character PvP flagged?
	Perl_Player_ClassTexture:SetTexCoord(Perl_Player_ClassPosRight[PlayerClass], Perl_Player_ClassPosLeft[PlayerClass], Perl_Player_ClassPosTop[PlayerClass], Perl_Player_ClassPosBottom[PlayerClass]);	-- Set the player's class icon
	Perl_Player_Set_Text_Positions();			-- Align the text according to compact and healer mode
	Perl_Player_Update_Health();				-- Set the player's health on load or toggle
	Perl_Player_Update_Mana();				-- Set the player's mana/energy on load or toggle
	Perl_Player_Update_Mana_Bar();				-- Set the type of mana used
	Perl_Player_LevelFrame_LevelBarText:SetText(UnitLevel("player"));	-- Set the player's level
	Perl_Player_XPBar_Display(xpbarstate);			-- Set the xp bar mode and update the experience if needed
	Perl_Player_Update_Raid_Group_Number();			-- Are we in a raid at login?
	Perl_Player_Update_Leader();				-- Are we the party leader?
	Perl_Player_Update_Loot_Method();			-- Are we the master looter?
	Perl_Player_Update_Combat_Status();			-- Are we already fighting or resting?
	Perl_Player_Set_CompactMode();				-- Are we using compact mode?
end

function Perl_Player_Update_Health()
	local playerhealth = UnitHealth("player");
	local playerhealthmax = UnitHealthMax("player");
	local playerhealthpercent = floor(playerhealth/playerhealthmax*100+0.5);

	if (playerhealth < 0) then				-- This prevents negative health
		playerhealth = 0;
	end

	Perl_Player_HealthBar:SetMinMaxValues(0, playerhealthmax);
	Perl_Player_HealthBar:SetValue(playerhealth);

	if (colorhealth == 1) then
		if ((playerhealthpercent <= 100) and (playerhealthpercent > 75)) then
			Perl_Player_HealthBar:SetStatusBarColor(0, 0.8, 0);
			Perl_Player_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
		elseif ((playerhealthpercent <= 75) and (playerhealthpercent > 50)) then
			Perl_Player_HealthBar:SetStatusBarColor(1, 1, 0);
			Perl_Player_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		elseif ((playerhealthpercent <= 50) and (playerhealthpercent > 25)) then
			Perl_Player_HealthBar:SetStatusBarColor(1, 0.5, 0);
			Perl_Player_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		else
			Perl_Player_HealthBar:SetStatusBarColor(1, 0, 0);
			Perl_Player_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		end
	else
		Perl_Player_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_Player_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (compactmode == 0) then
		if (healermode == 1) then
			Perl_Player_HealthBarText:SetText("-"..playerhealthmax - playerhealth);
			if (mouseoverhealthflag == 0) then
				Perl_Player_HealthBarTextPercent:SetText();
			else
				Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
			end
		else
			Perl_Player_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
			Perl_Player_HealthBarTextPercent:SetText(playerhealthpercent .. "%");
		end
	else
		if (healermode == 1) then
			Perl_Player_HealthBarText:SetText("-"..playerhealthmax - playerhealth);
			if (mouseoverhealthflag == 0) then
				Perl_Player_HealthBarTextPercent:SetText();
			else
				Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
			end
		else
			Perl_Player_HealthBarText:SetText();
			Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
		end
	end
end

function Perl_Player_Update_Mana()
	local playermana = UnitMana("player");
	local playermanamax = UnitManaMax("player");
	local playermanapercent = floor(playermana/playermanamax*100+0.5);

	Perl_Player_ManaBar:SetMinMaxValues(0, playermanamax);
	Perl_Player_ManaBar:SetValue(playermana);

	if (compactmode == 0) then
		if (healermode == 1) then
			if (mouseovermanaflag == 0) then
				Perl_Player_ManaBarText:SetText();
				Perl_Player_ManaBarTextPercent:SetText();
			else
				if (UnitPowerType("player") == 1) then
					Perl_Player_ManaBarTextPercent:SetText(playermana);
				else
					Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
				end
			end
		else
			Perl_Player_ManaBarText:SetText(playermana.."/"..playermanamax);
			if (UnitPowerType("player") == 1) then
				Perl_Player_ManaBarTextPercent:SetText(playermana);
			else
				Perl_Player_ManaBarTextPercent:SetText(playermanapercent.."%");
			end
		end
	else
		if (healermode == 1) then
			if (mouseovermanaflag == 0) then
				Perl_Player_ManaBarText:SetText();
				Perl_Player_ManaBarTextPercent:SetText();
			else
				if (UnitPowerType("player") == 1) then
					Perl_Player_ManaBarTextPercent:SetText(playermana);
				else
					Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
				end
			end
		else
			Perl_Player_ManaBarText:SetText();
			if (UnitPowerType("player") == 1) then
				Perl_Player_ManaBarTextPercent:SetText(playermana);
			else
				Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
			end
		end
	end
end

function Perl_Player_Update_Mana_Bar()
	local playerpower = UnitPowerType("player");

	-- Set mana bar color
	if (playerpower == 1) then
		Perl_Player_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
	elseif (playerpower == 2) then
		Perl_Player_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
	elseif (playerpower == 3) then
		Perl_Player_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
	else
		Perl_Player_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	end
end

function Perl_Player_Update_Experience()
	if (UnitLevel("player") ~= 70) then
		-- XP Bar stuff
		local playerxp = UnitXP("player");
		local playerxpmax = UnitXPMax("player");
		local playerxprest = GetXPExhaustion();

		Perl_Player_XPBar:SetMinMaxValues(0, playerxpmax);
		Perl_Player_XPRestBar:SetMinMaxValues(0, playerxpmax);
		Perl_Player_XPBar:SetValue(playerxp);

		-- Set xp text
		local xptext = playerxp.."/"..playerxpmax;
		local xptextpercent = floor(playerxp/playerxpmax*100+0.5);

		if (playerxprest) then
			xptext = xptext .."(+"..(playerxprest)..")";
			Perl_Player_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);
			Perl_Player_XPRestBar:SetStatusBarColor(0, 0.6, 0.6, 0.5);
			Perl_Player_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);
			Perl_Player_XPRestBar:SetValue(playerxp + playerxprest);
		else
			Perl_Player_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);
			Perl_Player_XPRestBar:SetStatusBarColor(0, 0.6, 0.6, 0.5);
			Perl_Player_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);
			Perl_Player_XPRestBar:SetValue(playerxp);
		end

		Perl_Player_XPBarText:SetText(xptextpercent.."%");
	else
		Perl_Player_XPBar:SetMinMaxValues(0, 1);
		Perl_Player_XPRestBar:SetMinMaxValues(0, 1);
		Perl_Player_XPBar:SetValue(1);
		Perl_Player_XPRestBar:SetValue(1);

		Perl_Player_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);
		Perl_Player_XPRestBar:SetStatusBarColor(0, 0.6, 0.6, 0.5);
		Perl_Player_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);

		Perl_Player_XPBarText:SetText("Level 70");
	end
	
end

function Perl_Player_Update_Combat_Status(event)
	-- Rest/Combat Status Icon
	if (event == "PLAYER_REGEN_DISABLED") then
		InCombat = 1;
		Perl_Player_ActivityStatus:SetTexCoord(0.5, 1.0, 0.0, 0.5);
		Perl_Player_ActivityStatus:Show();
	elseif (event == "PLAYER_REGEN_ENABLED") then
		InCombat = 0;
		Perl_Player_ActivityStatus:Hide();
	elseif (IsResting()) then
		if (InCombat == 1) then
			return;
		else
			Perl_Player_ActivityStatus:SetTexCoord(0, 0.5, 0.0, 0.5);
			Perl_Player_ActivityStatus:Show();
		end
	else
		if (InCombat == 1) then
			return;
		else
			Perl_Player_ActivityStatus:Hide();
		end
	end
end

function Perl_Player_Update_Raid_Group_Number()		-- taken from 1.8
	if (showraidgroup == 1) then
		Perl_Player_RaidGroupNumberFrame:Hide();
		local name, rank, subgroup;
		if (GetNumRaidMembers() == 0) then
			Perl_Player_RaidGroupNumberFrame:Hide();
			Perl_Player_MasterIcon:Hide();				-- This was added to correctly hide the master loot icon after leaving a party/raid
			return;
		end
		local numRaidMembers = GetNumRaidMembers();
		for i=1, MAX_RAID_MEMBERS do
			if (i <= numRaidMembers) then
				name, rank, subgroup = GetRaidRosterInfo(i);
				-- Set the player's group number indicator
				if (name == UnitName("player")) then
					Perl_Player_RaidGroupNumberBarText:SetText("Group "..subgroup);
					Perl_Player_RaidGroupNumberFrame:Show();
					return;
				end
			end
		end
	else
		Perl_Player_RaidGroupNumberFrame:Hide();
	end
end

function Perl_Player_Update_Leader()
	if (IsPartyLeader()) then
		Perl_Player_LeaderIcon:Show();
	else
		Perl_Player_LeaderIcon:Hide();
	end
end

function Perl_Player_Update_Loot_Method()
	local lootMethod, lootMaster;
	lootMethod, lootMaster = GetLootMethod();
	if (lootMaster == 0) then
		Perl_Player_MasterIcon:Show();
	else
		Perl_Player_MasterIcon:Hide();
	end
end

function Perl_Player_Update_PvP_Status()
	if (UnitIsPVP("player")) then
		local factionGroup = UnitFactionGroup("player");
		Perl_Player_NameBarText:SetTextColor(0,1,0);
		Perl_Player_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		Perl_Player_PVPStatus:Show();
	else
		Perl_Player_NameBarText:SetTextColor(0.5,0.5,1);
		Perl_Player_PVPStatus:Hide();
	end
end

function Perl_Player_Set_CompactMode()
	if (compactmode == 0) then
		Perl_Player_Update_Health();
		Perl_Player_Update_Mana();
		Perl_Player_XPBar:SetWidth(220);
		Perl_Player_XPRestBar:SetWidth(220);
		Perl_Player_XPBarBG:SetWidth(220);
		Perl_Player_StatsFrame:SetWidth(240);
	else
		Perl_Player_Update_Health();
		Perl_Player_Update_Mana();
		Perl_Player_XPBar:SetWidth(150);
		Perl_Player_XPRestBar:SetWidth(150);
		Perl_Player_XPBarBG:SetWidth(150);
		Perl_Player_StatsFrame:SetWidth(170);
	end
end

function Perl_Player_Set_Text_Positions()
	if (compactmode == 0) then
		Perl_Player_HealthBarText:SetPoint("RIGHT", 70, 0);
		Perl_Player_HealthBarTextPercent:SetPoint("TOP", 0, 1);
		Perl_Player_ManaBarText:SetPoint("RIGHT", 70, 0);
		Perl_Player_ManaBarTextPercent:SetPoint("TOP", 0, 1);
	else
		if (healermode == 1) then
			Perl_Player_HealthBarText:SetPoint("RIGHT", -10, 0);
			Perl_Player_HealthBarTextPercent:SetPoint("TOP", -40, 1);
			Perl_Player_ManaBarText:SetPoint("RIGHT", -10, 0);
			Perl_Player_ManaBarTextPercent:SetPoint("TOP", -40, 1);
		else
			Perl_Player_HealthBarText:SetPoint("RIGHT", 70, 0);
			Perl_Player_HealthBarTextPercent:SetPoint("TOP", 0, 1);
			Perl_Player_ManaBarText:SetPoint("RIGHT", 70, 0);
			Perl_Player_ManaBarTextPercent:SetPoint("TOP", 0, 1);
		end
	end
end

function Perl_Player_HealthShow()
	if (healermode == 1) then
		local playerhealth = UnitHealth("player");
		local playerhealthmax = UnitHealthMax("player");
		Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
		mouseoverhealthflag = 1;
	end
end

function Perl_Player_HealthHide()
	if (healermode == 1) then
		Perl_Player_HealthBarTextPercent:SetText();
		mouseoverhealthflag = 0;
	end
end

function Perl_Player_ManaShow()
	if (healermode == 1) then
		local playermana = UnitMana("player");
		local playermanamax = UnitManaMax("player");
		if (UnitPowerType("player") == 1) then
			Perl_Player_ManaBarTextPercent:SetText(playermana);
		else
			Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
		end
		mouseovermanaflag = 1;
	end
end

function Perl_Player_ManaHide()
	if (healermode == 1) then
		Perl_Player_ManaBarTextPercent:SetText();
		mouseovermanaflag = 0;
	end
end

function Perl_Player_Set_Localized_ClassIcons()
	local pp_translate_druid;
	local pp_translate_hunter;
	local pp_translate_mage;
	local pp_translate_paladin;
	local pp_translate_priest;
	local pp_translate_rogue;
	local pp_translate_shaman;
	local pp_translate_warlock;
	local pp_translate_warrior;

	local localization = Perl_Config_Get_Localization();

	pp_translate_druid = localization["druid"];
	pp_translate_hunter = localization["hunter"];
	pp_translate_mage = localization["mage"];
	pp_translate_paladin = localization["paladin"];
	pp_translate_priest = localization["priest"];
	pp_translate_rogue = localization["rogue"];
	pp_translate_shaman = localization["shaman"];
	pp_translate_warlock = localization["warlock"];
	pp_translate_warrior = localization["warrior"];

	Perl_Player_ClassPosRight = {
		[pp_translate_druid] = 0.75,
		[pp_translate_hunter] = 0,
		[pp_translate_mage] = 0.25,
		[pp_translate_paladin] = 0,
		[pp_translate_priest] = 0.5,
		[pp_translate_rogue] = 0.5,
		[pp_translate_shaman] = 0.25,
		[pp_translate_warlock] = 0.75,
		[pp_translate_warrior] = 0,
	};
	Perl_Player_ClassPosLeft = {
		[pp_translate_druid] = 1,
		[pp_translate_hunter] = 0.25,
		[pp_translate_mage] = 0.5,
		[pp_translate_paladin] = 0.25,
		[pp_translate_priest] = 0.75,
		[pp_translate_rogue] = 0.75,
		[pp_translate_shaman] = 0.5,
		[pp_translate_warlock] = 1,
		[pp_translate_warrior] = 0.25,
	};
	Perl_Player_ClassPosTop = {
		[pp_translate_druid] = 0,
		[pp_translate_hunter] = 0.25,
		[pp_translate_mage] = 0,
		[pp_translate_paladin] = 0.5,
		[pp_translate_priest] = 0.25,
		[pp_translate_rogue] = 0,
		[pp_translate_shaman] = 0.25,
		[pp_translate_warlock] = 0.25,
		[pp_translate_warrior] = 0,
		
	};
	Perl_Player_ClassPosBottom = {
		[pp_translate_druid] = 0.25,
		[pp_translate_hunter] = 0.5,
		[pp_translate_mage] = 0.25,
		[pp_translate_paladin] = 0.75,
		[pp_translate_priest] = 0.5,
		[pp_translate_rogue] = 0.25,
		[pp_translate_shaman] = 0.5,
		[pp_translate_warlock] = 0.5,
		[pp_translate_warrior] = 0.25,
	};
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Player_XPBar_Display(state)
	if (state == 1) then
		Perl_Player_StatsFrame:SetHeight(54);
		Perl_Player_XPBar:Show();
		Perl_Player_XPBarBG:Show();
		Perl_Player_XPRestBar:Show();
		Perl_Player_Update_Experience();
	elseif (state == 2) then
		Perl_Player_StatsFrame:SetHeight(54);
		Perl_Player_XPBar:Show();
		Perl_Player_XPBarBG:Show();
		Perl_Player_XPRestBar:Show();
		local rankNumber, rankName, rankProgress;
		rankNumber = UnitPVPRank("player")
		if (rankNumber < 1) then
			rankName = "Unranked"
		else
			rankName = GetPVPRankInfo(rankNumber, "player");
		end
		rankProgress = GetPVPRankProgress();
		Perl_Player_XPBar:SetMinMaxValues(0, 1);
		Perl_Player_XPRestBar:SetMinMaxValues(0, 1);
		Perl_Player_XPBar:SetValue(rankProgress);
		Perl_Player_XPRestBar:SetValue(rankProgress);
		Perl_Player_XPBarText:SetText(rankName);
	elseif (state == 3) then
		Perl_Player_XPBar:Hide();
		Perl_Player_XPBarBG:Hide();
		Perl_Player_XPRestBar:Hide();
		Perl_Player_StatsFrame:SetHeight(42);
	end
	xpbarstate = state;
	Perl_Player_UpdateVars();
end

function Perl_Player_Set_Compact(newvalue)
	compactmode = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Set_Text_Positions();
	Perl_Player_Set_CompactMode();
end

function Perl_Player_Set_Healer(newvalue)
	healermode = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Set_Text_Positions();
	Perl_Player_Update_Health();
	Perl_Player_Update_Mana();
end

function Perl_Player_Set_RaidGroupNumber(newvalue)
	showraidgroup = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_Raid_Group_Number();
end

function Perl_Player_Set_Progressive_Color(newvalue)
	colorhealth = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_Health();
end

function Perl_Player_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Player_UpdateVars();
end

function Perl_Player_Set_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		scale = (number / 100);					-- convert the user input to a wow acceptable value
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Player Display is now scaled to |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");	-- only display if the user gave us a number
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Player_Frame:SetScale(unsavedscale);
	Perl_Player_UpdateVars();
end

function Perl_Player_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);				-- convert the user input to a wow acceptable value
	end
	Perl_Player_Frame:SetAlpha(transparency);
	Perl_Player_UpdateVars();
end


----------------------
-- Config Functions --
----------------------
function Perl_Player_Lock()
	locked = 1;
	Perl_Player_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffLocked|cffffff00.");
end

function Perl_Player_Unlock()
	locked = 0;
	Perl_Player_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffUnlocked|cffffff00.");
end

function Perl_Player_Toggle_CompactMode()
	if (compactmode == 0) then
		compactmode = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now displaying in |cffffffffCompact Mode|cffffff00.");
	else
		compactmode = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now displaying in |cffffffffNormal Mode|cffffff00.");
	end
	Perl_Player_UpdateVars();
	Perl_Player_Set_Text_Positions();
	Perl_Player_Set_CompactMode();
end

function Perl_Player_Toggle_RaidGroupNumber()
	if (showraidgroup == 0) then
		showraidgroup = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffDisplaying Raid Group Numbers|cffffff00.");
	else
		showraidgroup = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffHiding Raid Group Numbers|cffffff00.");
	end
	Perl_Player_Update_Raid_Group_Number();
	Perl_Player_UpdateVars();
end

function Perl_Player_Set_ParentUI_Scale()
	local unsavedscale;
	scale = UIParent:GetEffectiveScale();
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Player_Frame:SetScale(unsavedscale);
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Player Display is now scaled to |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");
	Perl_Player_UpdateVars();
end

function Perl_Player_ToggleColoredHealth()
	if (colorhealth == 1) then
		colorhealth = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		colorhealth = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end
	Perl_Player_UpdateVars();
	Perl_Player_Update_Health();
end

function Perl_Player_ToggleHealerMode()
	if (healermode == 1) then
		healermode = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffNot Displaying in Healer Mode|cffffff00.");
	else
		healermode = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffDisplaying in Healer Mode|cffffff00.");
	end
	Perl_Player_UpdateVars();
	Perl_Player_Set_Text_Positions();
	Perl_Player_Update_Health();
	Perl_Player_Update_Mana();
end

function Perl_Player_Status()
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffLocked|cffffff00.");
	end

	if (colorhealth == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end

	if (xpbarstate == 1) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffDisplaying Experience|cffffff00.");
	elseif (xpbarstate == 2) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffDisplaying PvP Rank|cffffff00.");
	elseif (xpbarstate == 3) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffHiding Experience Bar|cffffff00.");
	end

	if (compactmode == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying in |cffffffffNormal Mode|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying in |cffffffffCompact Mode|cffffff00.");
	end

	if (showraidgroup == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffHiding Raid Group Numbers|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffDisplaying Raid Group Numbers|cffffff00.");
	end

	if (healermode == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffNot Displaying in Healer Mode|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffDisplaying in Healer Mode|cffffff00.");
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying at a scale of |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Player_GetVars()
	locked = Perl_Player_Config[UnitName("player")]["Locked"];
	xpbarstate = Perl_Player_Config[UnitName("player")]["XPBarState"];
	compactmode = Perl_Player_Config[UnitName("player")]["CompactMode"];
	showraidgroup = Perl_Player_Config[UnitName("player")]["ShowRaidGroup"];
	scale = Perl_Player_Config[UnitName("player")]["Scale"];
	colorhealth = Perl_Player_Config[UnitName("player")]["ColorHealth"];
	healermode = Perl_Player_Config[UnitName("player")]["HealerMode"];
	transparency = Perl_Player_Config[UnitName("player")]["Transparency"];

	if (locked == nil) then
		locked = 0;
	end
	if (xpbarstate == nil) then
		xpbarstate = 1;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
	if (showraidgroup == nil) then
		showraidgroup = 1;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (colorhealth == nil) then
		colorhealth = 0;
	end
	if (healermode == nil) then
		healermode = 0;
	end
	if (transparency == nil) then
		transparency = 1;
	end

	local vars = {
		["locked"] = locked,
		["xpbarstate"] = xpbarstate,
		["compactmode"] = compactmode,
		["showraidgroup"] = showraidgroup,
		["scale"] = scale,
		["colorhealth"] = colorhealth,
		["healermode"] = healermode,
		["transparency"] = transparency,
	}
	return vars;
end

function Perl_Player_UpdateVars()
	Perl_Player_Config[UnitName("player")] = {
						["Locked"] = locked,
						["XPBarState"] = xpbarstate,
						["CompactMode"] = compactmode,
						["ShowRaidGroup"] = showraidgroup,
						["Scale"] = scale,
						["ColorHealth"] = colorhealth,
						["HealerMode"] = healermode,
						["Transparency"] = transparency,
	};
end


--------------------
-- Click Handlers --
--------------------
function Perl_PlayerDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_PlayerDropDown_Initialize, "MENU");
end

function Perl_PlayerDropDown_Initialize()
	UnitPopup_ShowMenu(Perl_Player_DropDown, "SELF", "player");
end

function test()
	getglobal(Perl_Config_Frame):Show();
end

function Perl_Player_MouseUp(button)
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
		if (this:GetName() == "Perl_Player_Frame") then
			ToggleDropDownMenu(1, nil, Perl_Player_DropDown, "Perl_Player_NameFrame", 40, 0);
		else
			return;
		end
	end

	Perl_Player_Frame:StopMovingOrSizing();
end

function Perl_Player_MouseDown(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Player_Frame:StartMoving();
	end
end


------------------------
-- Experience Tooltip --
------------------------
function Perl_Player_XPTooltip()
	local playerxp, playerxpmax, xptext
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	if (xpbarstate == 1) then
		local playerlevel = UnitLevel("player");			-- Player's next level
		if (playerlevel < 70) then
			playerxp = UnitXP("player");				-- Player's current XP
			playerxpmax = UnitXPMax("player");			-- Experience for the current level
			local playerxprest = GetXPExhaustion();			-- Amount of bonus xp we have
			local xptolevel = playerxpmax - playerxp		-- XP till level

			if (playerxprest) then
				xptext = playerxp.."/"..playerxpmax .." (+"..(playerxprest)..")";	-- Create the experience string w/ rest xp
			else
				xptext = playerxp.."/"..playerxpmax;		-- Create the experience string w/ no rest xp
			end

			GameTooltip:SetText(xptext, 255/255, 209/255, 0/255);
			GameTooltip:AddLine(xptolevel.." until level "..(playerlevel + 1), 255/255, 209/255, 0/255);
		else
			GameTooltip:SetText("You can't gain anymore experience!", 255/255, 209/255, 0/255);
		end
		
	else
		local rankNumber, rankName, rankProgress;			-- Some variables
		rankNumber = UnitPVPRank("player")				-- 
		if (rankNumber < 1) then
			rankName = "Unranked"
			GameTooltip:SetText("You are Unranked.", 255/255, 209/255, 0/255);
		else
			rankName = GetPVPRankInfo(rankNumber, "player");
			rankProgress = floor(GetPVPRankProgress() * 100);
			GameTooltip:SetText(rankProgress.."% into Rank "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
			if (rankNumber < 18) then
				rankNumber = rankNumber + 1;
				rankName = GetPVPRankInfo(rankNumber, "player");
				GameTooltip:AddLine((100 - rankProgress).."% until Rank "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
			end
		end
	end
	GameTooltip:Show();
end


-----------------------
-- Scripting Support --
-----------------------
function Perl_Player_InCombat()
	if (InCombat == 1) then
		return 1;
	else
		return nil;
	end
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Player_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Player_myAddOns_Details = {
			name = "Perl_Player",
			version = "v0.32",
			releaseDate = "January 21, 2006",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Player_myAddOns_Help = {};
		Perl_Player_myAddOns_Help[1] = "/perlplayer\n/pp\n";
		myAddOnsFrame_Register(Perl_Player_myAddOns_Details, Perl_Player_myAddOns_Help);
	end
end