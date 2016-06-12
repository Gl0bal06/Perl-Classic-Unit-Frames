---------------
-- Variables --
---------------
Perl_Target_Config = {};

-- Defaults(also set in Perl_Target_GetVars)
local Initialized = nil;	-- waiting to be initialized
local transparency = 1;		-- 0.8 default from perl
local Perl_Target_State = 1;	-- enabled by default
local locked = 0;		-- unlocked by default
local showcp = 1;		-- combo points displayed by default
local showclassicon = 1;	-- show the class icon
local showpvpicon = 1;		-- show the pvp icon
local showclassframe = 1;	-- show the class frame
local numbuffsshown = 20;	-- buff row is 20 long
local numdebuffsshown = 16;	-- debuff row is 16 long
local mobhealthsupport = 1;	-- mobhealth support is on by default
local BlizzardTargetFrame_Update = TargetFrame_Update;	-- backup the original target function in case we toggle the mod off
local BlizzardUnitFrame_OnEnter = UnitFrame_OnEnter;	-- may not need to back this up

-- Variables for position of the class icon texture.
local Perl_Target_ClassPosRight = {
	["Warrior"] = 0,
	["Mage"] = 0.25,
	["Rogue"] = 0.5,
	["Druid"] = 0.75,
	["Hunter"] = 0,
	["Shaman"] = 0.25,
	["Priest"] = 0.5,
	["Warlock"] = 0.75,
	["Paladin"] = 0,
};
local Perl_Target_ClassPosLeft = {
	["Warrior"] = 0.25,
	["Mage"] = 0.5,
	["Rogue"] = 0.75,
	["Druid"] = 1,
	["Hunter"] = 0.25,
	["Shaman"] = 0.5,
	["Priest"] = 0.75,
	["Warlock"] = 1,
	["Paladin"] = 0.25,
};
local Perl_Target_ClassPosTop = {
	["Warrior"] = 0,
	["Mage"] = 0,
	["Rogue"] = 0,
	["Druid"] = 0,
	["Hunter"] = 0.25,
	["Shaman"] = 0.25,
	["Priest"] = 0.25,
	["Warlock"] = 0.25,
	["Paladin"] = 0.5,
};
local Perl_Target_ClassPosBottom = {
	["Warrior"] = 0.25,
	["Mage"] = 0.25,
	["Rogue"] = 0.25,
	["Druid"] = 0.25,
	["Hunter"] = 0.5,
	["Shaman"] = 0.5,
	["Priest"] = 0.5,
	["Warlock"] = 0.5,
	["Paladin"] = 0.75,
};


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
	UIErrorsFrame:AddMessage("|cffffff00Target Frame by Perl loaded successfully.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
end


-------------------
-- Event Handler --
-------------------
function Perl_Target_OnEvent(event)
	if (Perl_Target_State == 0) then
		return;
	else
		if ((event == "PLAYER_TARGET_CHANGED") or (event == "PARTY_MEMBERS_CHANGED") or (event == "PARTY_LEADER_CHANGED") or (event == "PARTY_MEMBER_ENABLE") or (event == "PARTY_MEMBER_DISABLE")) then
			Perl_Target_Update_Once();			-- Set the unchanging info for the target
			return;
		elseif (event == "UNIT_HEALTH") then
			if (arg1 == "target") then
				Perl_Target_Update_Health();		-- Update health values
				Perl_Target_Update_Dead_Status();	-- Is the target dead?
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
			Perl_Target_Update_Frequently();
			return;
		end
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_Target_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Target_Unlock();
	elseif (string.find(msg, "lock")) then
		Perl_Target_Lock();
	elseif (string.find(msg, "combopoints")) then
		Perl_Target_ToggleCP();
	elseif (string.find(msg, "icon")) then
		Perl_Target_ToggleClassIcon();
	elseif (string.find(msg, "class")) then
		Perl_Target_ToggleClassFrame();
	elseif (string.find(msg, "pvp")) then
		Perl_Target_TogglePvPIcon();
	elseif (string.find(msg, "mobhealth")) then
		Perl_Target_ToggleMobHealth();
	elseif (string.find(msg, "status")) then
		Perl_Target_Status();
	elseif (string.find(msg, "toggle")) then
		Perl_Target_ToggleTarget();
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
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number (0-16)");
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of buffs to display (0-16): /pt buffs #");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Target Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff combopoints |cffffff00- Toggle the displaying of combo points.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff class |cffffff00- Toggle the displaying of class frame.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff icon |cffffff00- Toggle the displaying of class icon.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff pvp |cffffff00- Toggle the displaying of pvp status icon.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff mobhealth |cffffff00- Toggle the displaying of integrated MobHealth support.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff buffs # |cffffff00- Show the number of buffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff debuffs # |cffffff00- Show the number of debuffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff toggle |cffffff00- Toggle the target frame on and off.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
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

	if (Perl_Target_State == 1) then
		TargetFrame_Update = Perl_Target_Update_Frequently;
	else
		Perl_Target_Frame:Hide();
		TargetFrame_Update = BlizzardTargetFrame_Update;
	end

	Initialized = 1;
end


--------------------------
-- The Update Functions --
--------------------------
function Perl_Target_Update_Once()
	if (UnitExists("target")) then
		Perl_Target_Frame:Show();		-- Show frame
		ComboFrame:Hide();			-- Hide default Combo Points
		Perl_Target_Frame_Set_Name();		-- Set the target's name
		Perl_Target_Update_Text_Color();	-- Has the target been tapped by someone else?
		Perl_Target_Update_Health();		-- Set the target's health
		Perl_Target_Update_Mana_Bar();		-- What type of mana bar is it?
		Perl_Target_Update_Mana();		-- Set the target's mana
		Perl_Target_Update_Dead_Status();	-- Is the target dead?
		Perl_Target_Update_PvP_Status_Icon();	-- Set pvp status icon
		Perl_Target_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
		Perl_Target_Set_Character_Class_Icon();	-- Draw the class icon?
		Perl_Target_Set_Target_Class();		-- Set the target's class in the class frame
		Perl_Target_Buff_UpdateAll();		-- Update the buffs
	end
end

function Perl_Target_Update_Frequently()
	if (UnitExists("target")) then
		return;
	else
		Perl_Target_Frame:Hide();
		Perl_Target_Frame:StopMovingOrSizing();
	end
end

function Perl_Target_Update_Health()
	local targethealth = UnitHealth("target");
	local targethealthmax = UnitHealthMax("target");
	
	Perl_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
	Perl_Target_HealthBar:SetValue(targethealth);

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
end

function Perl_Target_Update_Mana()
	local targetmana = UnitMana("target");
	local targetmanamax = UnitManaMax("target");

	Perl_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
	Perl_Target_ManaBar:SetValue(targetmana);

	if (targetmanamax == 100) then
		Perl_Target_ManaBarText:SetText(targetmana.."%");
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
		Perl_Target_StatsFrame:SetHeight(40);
	elseif (targetpower == 2) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(40);
	elseif (targetpower == 3) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(40);
	else
		Perl_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
		Perl_Target_StatsFrame:SetHeight(40);
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

function Perl_Target_Update_Dead_Status()
	-- Set Dead Icon
	if (UnitIsDead("target")) then
	--if ((UnitHealth("target") <= 0) and UnitIsConnected("target")) then
		Perl_Target_DeadStatus:Show();
	else
		Perl_Target_DeadStatus:Hide();
	end
end

function Perl_Target_Update_PvP_Status_Icon()
	if (showpvpicon == 1) then
		-- Set pvp status icon
		if (UnitIsPVP("target")) then
			if (UnitFactionGroup("target") == "Alliance") then
				Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance");
			elseif (UnitFactionGroup("target") == "Horde") then
				Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde");
			else
				Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			end
			Perl_Target_PVPStatus:Show();
		else
			Perl_Target_PVPStatus:Hide();
		end
	else
		Perl_Target_PVPStatus:Hide();
	end
end

function Perl_Target_Update_Text_Color()
	-- Set Text Color
	if (UnitIsTapped("target") and not UnitIsTappedByPlayer("target")) then
		Perl_Target_NameBarText:SetTextColor(0.5,0.5,0.5);
	elseif (UnitIsPlayer("target")) then
		if (UnitFactionGroup("player") == UnitFactionGroup("target")) then
			if (UnitIsPVP("target")) then
				Perl_Target_NameBarText:SetTextColor(0,1,0);		-- friendly pvp enabled character
			else
				Perl_Target_NameBarText:SetTextColor(0.5,0.5,1);	-- friendly non pvp enabled character
			end
		else
			if (UnitIsPVP("target")) then
				Perl_Target_NameBarText:SetTextColor(1,1,0);		-- hostile pvp enabled character
			else
				Perl_Target_NameBarText:SetTextColor(0.5,0.5,1);	-- hostile non pvp enabled character
			end
		end
	else
		if (UnitFactionGroup("player") == UnitFactionGroup("target")) then
			Perl_Target_NameBarText:SetTextColor(0,1,0);			-- friendly npc
		elseif (UnitIsEnemy("player", "target")) then
			Perl_Target_NameBarText:SetTextColor(1,0,0);			-- hostile npc
		else
			Perl_Target_NameBarText:SetTextColor(1,1,0);			-- everything else
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
			Perl_Target_ClassNameBarText:SetText(targetCreatureType);
			Perl_Target_ClassNameFrame:Show();
		end
	else
		Perl_Target_ClassNameFrame:Hide();
	end
end


----------------------
-- Config functions --
----------------------
function Perl_Target_ToggleTarget()
	if (Perl_Target_State == 0) then
		Perl_Target_State = 1;
		TargetFrame:Hide();
		ComboFrame:Hide();
		TargetFrame_Update = Perl_Target_Update_Frequently;
		Perl_Target_Frame:Show();
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Target Display is now |cffffffffEnabled|cffffff00.");
		Perl_Target_Update_Frequently();
	else
		Perl_Target_State = 0;
		TargetFrame_Update = BlizzardTargetFrame_Update;
		Perl_Target_Frame:Hide();
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Target Display is now |cffffffffDisabled|cffffff00.");
	end
	Perl_Target_UpdateVars();
end

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

function Perl_Target_Status()
	if (Perl_Target_State == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffDisabled|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffEnabled|cffffff00.");
	end
	
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is |cffffffffLocked|cffffff00.");
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
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numbuffsshown.."|cffffff00 buffs.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numdebuffsshown.."|cffffff00 debuffs.");
end

function Perl_Target_GetVars()
	Perl_Target_State = Perl_Target_Config[UnitName("player")]["State"];
	locked = Perl_Target_Config[UnitName("player")]["Locked"];
	showcp = Perl_Target_Config[UnitName("player")]["ComboPoints"];
	showclassicon = Perl_Target_Config[UnitName("player")]["ClassIcon"];
	showclassframe = Perl_Target_Config[UnitName("player")]["ClassFrame"];
	showpvpicon = Perl_Target_Config[UnitName("player")]["PvPIcon"];
	numbuffsshown = Perl_Target_Config[UnitName("player")]["Buffs"];
	numdebuffsshown = Perl_Target_Config[UnitName("player")]["Debuffs"];

	if (Perl_Target_State == nil) then
		Perl_Target_State = 1;
	end
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
	if (numbuffsshown < 16) then
		numbuffsshown = 16;
	end
	if (numdebuffsshown == nil) then
		numdebuffsshown = 16;
	end
	if (mobhealthsupport == nil) then
		mobhealthsupport = 1;
	end
end

function Perl_Target_UpdateVars()
	Perl_Target_Config[UnitName("player")] = {
						["State"] = Perl_Target_State,
						["Locked"] = locked,
						["ComboPoints"] = showcp,
						["ClassIcon"] = showclassicon,
						["ClassFrame"] = showclassframe,
						["PvPIcon"] = showpvpicon,
						["Buffs"] = numbuffsshown,
						["Debuffs"] = numdebuffsshown,
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
		
		if (buffmax == 0) then
			Perl_Target_BuffFrame:Hide();
		else
			if (friendly == 1) then
				Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, 5);
			else
				Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -25);
			end
			Perl_Target_BuffFrame:Show();
			Perl_Target_BuffFrame:SetWidth(5 + buffmax*29);
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

		if (debuffmax == 0) then
			Perl_Target_DebuffFrame:Hide();
		else
			if (friendly == 1) then
				Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -25);
			else
				Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, 5);
			end
			Perl_Target_DebuffFrame:Show();
			Perl_Target_DebuffFrame:SetWidth(5 + debuffmax*29);
		end
	end
end

function Perl_Target_Reset_Buffs()
	for buffnum=1,20 do
		local button = getglobal("Perl_Target_Buff"..buffnum);
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


-------------
-- Tooltip --
-------------
-- Some of my failed attempt at tooltip support is below

--local Original_UnitFrame_OnEnter = nil;
--
--function Perl_Target_Tooltip_Hook()
--	Original_UnitFrame_OnEnter = UnitFrame_OnEnter;
--	UnitFrame_OnEnter = Perl_Target_Replacement_UnitFrame_OnEnter;
--end
--
--function Perl_Target_Tooltip_Unhook()
--	UnitFrame_OnEnter = Original_UnitFrame_OnEnter;
--end
--
--function Perl_Target_Replacement_UnitFrame_OnEnter()	-- Taken from 1.8 UnitFrame_OnEnter()
--	this.unit = "target";
--	if ( SpellIsTargeting() ) then
--		if ( SpellCanTargetUnit(this.unit) ) then
--			SetCursor("CAST_CURSOR");
--		else
--			SetCursor("CAST_ERROR_CURSOR");
--		end
--	end
--
--	GameTooltip_SetDefaultAnchor(GameTooltip, this);
--	-- If showing newbie tips then only show the explanation
--	if ( SHOW_NEWBIE_TIPS == "1" and this:GetName() ~= "PartyMemberFrame1" and this:GetName() ~= "PartyMemberFrame2" and this:GetName() ~= "PartyMemberFrame3" and this:GetName() ~= "PartyMemberFrame4") then
--		if ( this:GetName() == "PlayerFrame" ) then
--			GameTooltip_AddNewbieTip(PARTY_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PARTYOPTIONS);
--			return;
--		elseif ( UnitPlayerControlled("target") and not UnitIsUnit("target", "player") and not UnitIsUnit("target", "pet") ) then
--			GameTooltip_AddNewbieTip(PLAYER_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PLAYEROPTIONS);
--			return;
--		end
--	end
--	
--	if ( GameTooltip:SetUnit(this.unit) ) then
--		this.updateTooltip = TOOLTIP_UPDATE_TIME;
--	else
--		this.updateTooltip = nil;
--	end
--
--	this.r, this.g, this.b = GameTooltip_UnitColor(this.unit);
--	--GameTooltip:SetBackdropColor(this.r, this.g, this.b);
--	GameTooltipTextLeft1:SetTextColor(this.r, this.g, this.b);
--end

function Perl_Target_Tip()
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:SetUnit("target");
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Target_myAddOns_Details = {
			name = "Perl_Target",
			version = "v0.17",
			releaseDate = "November 9, 2005",
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