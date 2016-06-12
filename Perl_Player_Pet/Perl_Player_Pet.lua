---------------
-- Variables --
---------------
Perl_Player_Pet_Config = {};

-- Default Saved Variables (also set in Perl_Player_Pet_GetVars)
local locked = 0;			-- unlocked by default
local showxp = 0;			-- xp bar is hidden by default
local scale = 1;			-- default scale
local numpetbuffsshown = 16;		-- buff row is 16 long
local numpetdebuffsshown = 16;		-- debuff row is 16 long
local colorhealth = 0;			-- progressively colored health bars are off by default
local transparency = 1;			-- transparency for frames
local bufflocation = 1;			-- default buff location
local debufflocation = 2;		-- default debuff location

-- Default Local Variables
local Initialized = nil;		-- waiting to be initialized


----------------------
-- Loading Function --
----------------------
function Perl_Player_Pet_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_PET_CHANGED");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_FOCUS");
	this:RegisterEvent("UNIT_HAPPINESS");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_PET");
	this:RegisterEvent("UNIT_PET_EXPERIENCE");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Slash Commands
	SlashCmdList["Perl_Player_Pet"] = Perl_Player_Pet_SlashHandler;
	SLASH_Perl_Player_Pet1 = "/perlplayerpet";
	SLASH_Perl_Player_Pet2 = "/ppp";

	table.insert(UnitPopupFrames,"Perl_Player_Pet_DropDown");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame by Perl loaded successfully.");
	end
end


-------------------
-- Event Handler --
-------------------
function Perl_Player_Pet_OnEvent(event)
	if (event == "UNIT_HEALTH") then
		if (arg1 == "pet") then
			Perl_Player_Pet_Update_Health();	-- Update health values
		end
		return;
	elseif (event == "UNIT_FOCUS" or event == "UNIT_MANA") then
		if (arg1 == "pet") then
			Perl_Player_Pet_Update_Mana();		-- Update energy/mana/rage values
		end
		return;
	elseif (event == "UNIT_HAPPINESS") then
		Perl_Player_PetFrame_SetHappiness();
		return;
	elseif (event == "UNIT_NAME_UPDATE") then
		if (arg1 == "pet") then
			Perl_Player_Pet_NameBarText:SetText(UnitName("pet"));	-- Set name
		end
		return;
	elseif (event == "UNIT_AURA") then
		if (arg1 == "pet") then
			Perl_Player_Pet_Buff_UpdateAll();	-- Update the buff/debuff list
		end
		return;
	elseif (event == "UNIT_PET_EXPERIENCE") then
		if (showxp == 1) then
			Perl_Player_Pet_Update_Experience();	-- Set the experience bar info
		end
		return;
	elseif (event == "UNIT_LEVEL") then
		if (arg1 == "pet") then
			Perl_Player_Pet_LevelBarText:SetText(UnitLevel("pet"));		-- Set Level
		end
		return;
	elseif (event == "UNIT_DISPLAYPOWER") then
		if (arg1 == "pet") then
			Perl_Player_Pet_Update_Mana_Bar();	-- What type of energy are we using now?
			Perl_Player_Pet_Update_Mana();		-- Update the energy info immediately
		end
		return;
	elseif (event == "PLAYER_PET_CHANGED") then
		Perl_Player_Pet_Update_Once();
		return;
	elseif (event == "UNIT_PET") then
		if (arg1 == "player") then
			Perl_Player_Pet_Update_Once();
		end
		return;
	elseif (event == "VARIABLES_LOADED") or (event == "PLAYER_ENTERING_WORLD") then
		Perl_Player_Pet_Initialize();
		Perl_Player_Pet_Update_Once();
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_Player_Pet") then
			Perl_Player_Pet_myAddOns_Support();
		end
		return;
	else
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_Player_Pet_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Player_Pet_Unlock();
	elseif (string.find(msg, "lock")) then
		Perl_Player_Pet_Lock();
	elseif (string.find(msg, "xp")) then
		Perl_Player_Pet_Toggle_XPMode();
	elseif (string.find(msg, "health")) then
		Perl_Player_Pet_ToggleColoredHealth();
		return;
	elseif (string.find(msg, "debuffs")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			local number = tonumber(arg1);
			if (number >= 0 and number <= 16) then
				Perl_Player_Pet_Set_Debuffs(number)
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number (0-16)");
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of debuffs to display (0-16): /ppp debuffs #");
		end
	elseif (string.find(msg, "buffs")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			local number = tonumber(arg1);
			if (number >= 0 and number <= 16) then
				Perl_Player_Pet_Set_Buffs(number)
				return;
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number (0-16)");
				return;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of buffs to display (0-16): /ppp buffs #");
			return;
		end
	elseif (string.find(msg, "scale")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			if (arg1 == "ui") then
				Perl_Player_Pet_Set_ParentUI_Scale();
				return;
			end
			local number = tonumber(arg1);
			if (number > 0 and number < 150) then
				Perl_Player_Pet_Set_Scale(number);
				return;
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/ppp scale ui' to set to the current UI scale.");
				return;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/ppp scale ui' to set to the current UI scale.");
			return;
		end
	elseif (string.find(msg, "status")) then
		Perl_Player_Pet_Status();
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Player Pet Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff xp |cffffff00- Toggle the pet experience bar.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff health |cffffff00- Toggle the displaying of progressively colored health bars.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff buffs # |cffffff00- Show the number of buffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff debuffs # |cffffff00- Show the number of debuffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff scale # |cffffff00- Set the scale. (1-149) You may also do '/ppp scale ui' to set to the current UI scale.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Player_Pet_Initialize()
	-- Check if we loaded the mod already.
	if (Initialized) then
		Perl_Player_Pet_Set_Scale();
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Player_Pet_Config[UnitName("player")]) == "table") then
		Perl_Player_Pet_GetVars();
	else
		Perl_Player_Pet_UpdateVars();
	end

	-- Major config options.
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

	Perl_Player_Pet_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Player_Pet_ManaBarText:SetTextColor(1, 1, 1, 1);

	-- The following UnregisterEvent calls were taken from Nymbia's Perl
	-- Blizz Pet Frame Events
	PetFrame:UnregisterEvent("UNIT_COMBAT");
	PetFrame:UnregisterEvent("UNIT_SPELLMISS");
	PetFrame:UnregisterEvent("UNIT_AURA");
	PetFrame:UnregisterEvent("PLAYER_PET_CHANGED");
	PetFrame:UnregisterEvent("PET_ATTACK_START");
	PetFrame:UnregisterEvent("PET_ATTACK_STOP");
	PetFrame:UnregisterEvent("UNIT_HAPPINESS");
	PetFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");

	Initialized = 1;
end


-------------------------
-- The Update Function --
-------------------------
function Perl_Player_Pet_Update_Once()
	if (UnitExists("pet")) then
		Perl_Player_Pet_NameBarText:SetText(UnitName("pet"));		-- Set name
		Perl_Player_Pet_LevelBarText:SetText(UnitLevel("pet"));		-- Set Level
		Perl_Player_Pet_Set_Scale();					-- Set the scale
		Perl_Player_Pet_Set_Transparency();				-- Set transparency
		Perl_Player_Pet_Update_Health();				-- Set health
		Perl_Player_Pet_Update_Mana();					-- Set mana values
		Perl_Player_Pet_Update_Mana_Bar();				-- Set the type of mana
		Perl_Player_PetFrame_SetHappiness();				-- Set Happiness
		Perl_Player_Pet_Buff_UpdateAll();				-- Set buff frame
		Perl_Player_Pet_Frame:Show();
		Perl_Player_Pet_ShowXP();
	else
		Perl_Player_Pet_Frame:Hide();
	end
end

function Perl_Player_Pet_Update_Health()
	local pethealth = UnitHealth("pet");
	local pethealthmax = UnitHealthMax("pet");

	if (pethealth < 0) then			-- This prevents negative health
		pethealth = 0;
	end

	Perl_Player_Pet_HealthBar:SetMinMaxValues(0, pethealthmax);
	Perl_Player_Pet_HealthBar:SetValue(pethealth);

	if (colorhealth == 1) then
		local playerpethealthpercent = floor(pethealth/pethealthmax*100+0.5);
		if ((playerpethealthpercent <= 100) and (playerpethealthpercent > 75)) then
			Perl_Player_Pet_HealthBar:SetStatusBarColor(0, 0.8, 0);
			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
		elseif ((playerpethealthpercent <= 75) and (playerpethealthpercent > 50)) then
			Perl_Player_Pet_HealthBar:SetStatusBarColor(1, 1, 0);
			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		elseif ((playerpethealthpercent <= 50) and (playerpethealthpercent > 25)) then
			Perl_Player_Pet_HealthBar:SetStatusBarColor(1, 0.5, 0);
			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		else
			Perl_Player_Pet_HealthBar:SetStatusBarColor(1, 0, 0);
			Perl_Player_Pet_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		end
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
	local petmana = UnitMana("pet");
	local petmanamax = UnitManaMax("pet");

	Perl_Player_Pet_ManaBar:SetMinMaxValues(0, petmanamax);
	Perl_Player_Pet_ManaBar:SetValue(petmana);

	Perl_Player_Pet_ManaBarText:SetText(petmana);
end

function Perl_Player_Pet_Update_Mana_Bar()
	local petpower = UnitPowerType("pet");
	-- Set mana bar color
	if (petpower == 1) then
		Perl_Player_Pet_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_Player_Pet_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
	elseif (petpower == 2) then
		Perl_Player_Pet_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_Player_Pet_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
	elseif (petpower == 3) then
		Perl_Player_Pet_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Player_Pet_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
	else
		Perl_Player_Pet_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Player_Pet_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	end
end

function Perl_Player_PetFrame_SetHappiness()
	local happiness, damagePercentage, loyaltyRate = GetPetHappiness();

	if (happiness == 1) then
		Perl_Player_PetHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	elseif (happiness == 2) then
		Perl_Player_PetHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	elseif (happiness == 3) then
		Perl_Player_PetHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
	end

	if (happiness ~= nil) then
		Perl_Player_PetHappiness.tooltip = getglobal("PET_HAPPINESS"..happiness);
		Perl_Player_PetHappiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
		if (loyaltyRate < 0) then
			Perl_Player_PetHappiness.tooltipLoyalty = getglobal("LOSING_LOYALTY");
		elseif (loyaltyRate > 0) then
			Perl_Player_PetHappiness.tooltipLoyalty = getglobal("GAINING_LOYALTY");
		else
			Perl_Player_PetHappiness.tooltipLoyalty = nil;
		end
	end
end

function Perl_Player_Pet_ShowXP()
	if (showxp == 0) then
		Perl_Player_Pet_XPBar:Hide();
		Perl_Player_Pet_XPBarBG:Hide();
		Perl_Player_Pet_XPBarText:SetText();
		Perl_Player_Pet_StatsFrame:SetHeight(34);
	else
		Perl_Player_Pet_XPBar:Show();
		Perl_Player_Pet_XPBarBG:Show();
		Perl_Player_Pet_StatsFrame:SetHeight(47);
		Perl_Player_Pet_Update_Experience();
	end
end

function Perl_Player_Pet_Update_Experience()
	-- XP Bar stuff
	local playerpetxp, playerpetxpmax;
	playerpetxp, playerpetxpmax = GetPetExperience();

	Perl_Player_Pet_XPBar:SetMinMaxValues(0, playerpetxpmax);
	Perl_Player_Pet_XPBar:SetValue(playerpetxp);

	-- Set xp text
	local xptext = playerpetxp.."/"..playerpetxpmax;

	Perl_Player_Pet_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);
	Perl_Player_Pet_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);
	Perl_Player_Pet_XPBarText:SetText(xptext);
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Player_Pet_Set_Buffs(newbuffnumber)
	if (newbuffnumber == nil) then
		newbuffnumber = 16;
	end
	numpetbuffsshown = newbuffnumber;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Reset_Buffs();	-- Reset the buff icons
	Perl_Player_Pet_Buff_UpdateAll();	-- Repopulate the buff icons
	--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is displaying |cffffffff"..numpetbuffsshown.."|cffffff00 buffs.");
end

function Perl_Player_Pet_Set_Debuffs(newdebuffnumber)
	if (newdebuffnumber == nil) then
		newdebuffnumber = 16;
	end
	numpetdebuffsshown = newdebuffnumber;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Reset_Buffs();		-- Reset the buff icons
	Perl_Player_Pet_Buff_UpdateAll();	-- Repopulate the buff icons
	--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is displaying |cffffffff"..numpetdebuffsshown.."|cffffff00 debuffs.");
end

function Perl_Player_Pet_Set_Buff_Location(newvalue)
	if (newvalue ~= nil) then
		bufflocation = newvalue;
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Reset_Buffs();		-- Reset the buff icons
	Perl_Player_Pet_Buff_UpdateAll();	-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_Debuff_Location(newvalue)
	if (newvalue ~= nil) then
		debufflocation = newvalue;
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Reset_Buffs();		-- Reset the buff icons
	Perl_Player_Pet_Buff_UpdateAll();	-- Repopulate the buff icons
end

function Perl_Player_Pet_Set_ShowXP(newvalue)
	showxp = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_ShowXP();
end

function Perl_Player_Pet_Set_Progressive_Color(newvalue)
	colorhealth = newvalue;
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Update_Health();
end

function Perl_Player_Pet_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_Set_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		scale = (number / 100);					-- convert the user input to a wow acceptable value
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Player Pet Display is now scaled to |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");	-- only display if the user gave us a number
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Player_Pet_Frame:SetScale(unsavedscale);
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);				-- convert the user input to a wow acceptable value
	end
	Perl_Player_Pet_Frame:SetAlpha(transparency);
	Perl_Player_Pet_UpdateVars();
end


----------------------
-- Config functions --
----------------------
function Perl_Player_Pet_Lock()
	locked = 1;
	Perl_Player_Pet_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cffffffffLocked|cffffff00.");
end

function Perl_Player_Pet_Unlock()
	locked = 0;
	Perl_Player_Pet_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cffffffffUnlocked|cffffff00.");
end

function Perl_Player_Pet_Toggle_XPMode()
	if (showxp == 1) then
		showxp = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cffffffffHiding Experience|cffffff00.");
	else
		showxp = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cffffffffShowing Experience|cffffff00.");
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_ShowXP();
end

function Perl_Player_Pet_Set_ParentUI_Scale()
	local unsavedscale;
	scale = UIParent:GetEffectiveScale();
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Player_Pet_Frame:SetScale(unsavedscale);
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Player Pet Display is now scaled to |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");
	Perl_Player_Pet_UpdateVars();
end

function Perl_Player_Pet_ToggleColoredHealth()
	if (colorhealth == 1) then
		colorhealth = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		colorhealth = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end
	Perl_Player_Pet_UpdateVars();
	Perl_Player_Pet_Update_Health();
end

function Perl_Player_Pet_Status()
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is |cffffffffLocked|cffffff00.");
	end

	if (colorhealth == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end

	if (showxp == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is |cffffffffHiding Experience|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is |cffffffffShowing Experience|cffffff00.");
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is displaying |cffffffff"..numpetbuffsshown.."|cffffff00 buffs.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is displaying |cffffffff"..numpetdebuffsshown.."|cffffff00 debuffs.");

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is displaying at a scale of |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Player_Pet_GetVars()
	locked = Perl_Player_Pet_Config[UnitName("player")]["Locked"];
	showxp = Perl_Player_Pet_Config[UnitName("player")]["ShowXP"];
	scale = Perl_Player_Pet_Config[UnitName("player")]["Scale"];
	numpetbuffsshown = Perl_Player_Pet_Config[UnitName("player")]["Buffs"];
	numpetdebuffsshown = Perl_Player_Pet_Config[UnitName("player")]["Debuffs"];
	colorhealth = Perl_Player_Pet_Config[UnitName("player")]["ColorHealth"];
	transparency = Perl_Player_Pet_Config[UnitName("player")]["Transparency"];
	bufflocation = Perl_Player_Pet_Config[UnitName("player")]["BuffLocation"];
	debufflocation = Perl_Player_Pet_Config[UnitName("player")]["DebuffLocation"];

	if (locked == nil) then
		locked = 0;
	end
	if (showxp == nil) then
		showxp = 0;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (numpetbuffsshown == nil) then
		numpetbuffsshown = 16;
	end
	if (numpetdebuffsshown == nil) then
		numpetdebuffsshown = 16;
	end
	if (colorhealth == nil) then
		colorhealth = 0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (bufflocation == nil) then
		bufflocation = 1;
	end
	if (debufflocation == nil) then
		debufflocation = 2;
	end

	local vars = {
		["locked"] = locked,
		["showxp"] = showxp,
		["scale"] = scale,
		["numpetbuffsshown"] = numpetbuffsshown,
		["numpetdebuffsshown"] = numpetdebuffsshown,
		["colorhealth"] = colorhealth,
		["transparency"] = transparency,
		["bufflocation"] = bufflocation,
		["debufflocation"] = debufflocation,
	}
	return vars;
end

function Perl_Player_Pet_UpdateVars()
	Perl_Player_Pet_Config[UnitName("player")] = {
		["Locked"] = locked,
		["ShowXP"] = showxp,
		["Scale"] = scale,
		["Buffs"] = numpetbuffsshown,
		["Debuffs"] = numpetdebuffsshown,
		["ColorHealth"] = colorhealth,
		["Transparency"] = transparency,
		["BuffLocation"] = bufflocation,
		["DebuffLocation"] = debufflocation,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Player_Pet_Buff_UpdateAll()
	if (UnitName("pet")) then
		local buffmax = 0;
		for buffnum=1,numpetbuffsshown do
			local button = getglobal("Perl_Player_Pet_Buff"..buffnum);
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");

			if (UnitBuff("pet", buffnum)) then
				icon:SetTexture(UnitBuff("pet", buffnum));
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
		for debuffnum=1,numpetdebuffsshown do
			debuffTexture, debuffApplications = UnitDebuff("pet", debuffnum);
			local button = getglobal("Perl_Player_Pet_Debuff"..debuffnum);
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");
			
			if (UnitDebuff("pet", debuffnum)) then
				icon:SetTexture(UnitDebuff("pet", debuffnum));
				button.isdebuff = 1;
				debuff:Show();
				button:Show();
				debuffCount = getglobal("Perl_Player_Pet_Debuff"..debuffnum.."Count");
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
			Perl_Player_Pet_BuffFrame:Hide();
		else
			Perl_Player_Pet_BuffFrame:Show();
			Perl_Player_Pet_BuffFrame:SetWidth(5 + buffmax * 17);
		end

		if (debuffmax == 0) then
			Perl_Player_Pet_DebuffFrame:Hide();
		else
			Perl_Player_Pet_DebuffFrame:Show();
			Perl_Player_Pet_DebuffFrame:SetWidth(5 + debuffmax * 17);
		end

		if (bufflocation == 1) then
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -5);
		elseif (bufflocation == 2) then
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -20);
		elseif (bufflocation == 3) then
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, 0);
		else
			Perl_Player_Pet_Buff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, -15);
		end

		if (debufflocation == 1) then
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -5);
		elseif (debufflocation == 2) then
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_StatsFrame", "TOPRIGHT", 0, -20);
		elseif (debufflocation == 3) then
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, 0);
		else
			Perl_Player_Pet_Debuff1:SetPoint("TOPLEFT", "Perl_Player_Pet_LevelFrame", "BOTTOMLEFT", 5, -15);
		end
	end
end

function Perl_Player_Pet_Reset_Buffs()
	local button;
	for buffnum=1,16 do
		button = getglobal("Perl_Player_Pet_Buff"..buffnum);
		button:Hide();
		button = getglobal("Perl_Player_Pet_Debuff"..buffnum);
		button:Hide();
	end
end

function Perl_Player_Pet_SetBuffTooltip()
	local buffmapping = 0;
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
	if (this.isdebuff == 1) then
		GameTooltip:SetUnitDebuff("pet", this:GetID()-buffmapping);
	else
		GameTooltip:SetUnitBuff("pet", this:GetID());
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Player_Pet_DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Player_Pet_DropDown_Initialize, "MENU");
end

function Perl_Player_Pet_DropDown_Initialize()
	UnitPopup_ShowMenu(Perl_Player_Pet_DropDown, "PET", "pet");
end

function Perl_Player_Pet_MouseUp(button)
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end

	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("pet");
		else
			TargetUnit("pet");
		end
	else
		if (this:GetName() == "Perl_Player_Pet_Frame") then
			ToggleDropDownMenu(1, nil, Perl_Player_Pet_DropDown, "Perl_Player_Pet_NameFrame", 40, 0);
		else
			return;
		end
	end

	Perl_Player_Pet_Frame:StopMovingOrSizing();
end

function Perl_Player_Pet_MouseDown(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Player_Pet_Frame:StartMoving();
	end
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Player_Pet_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_Player_Pet_myAddOns_Details = {
			name = "Perl_Player_Pet",
			version = "v0.33",
			releaseDate = "January 21, 2006",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Player_Pet_myAddOns_Help = {};
		Perl_Player_Pet_myAddOns_Help[1] = "/perlplayerpet\n/ppp\n";
		myAddOnsFrame_Register(Perl_Player_Pet_myAddOns_Details, Perl_Player_Pet_myAddOns_Help);
	end
end