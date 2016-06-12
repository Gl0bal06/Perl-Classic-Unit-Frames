---------------
-- Variables --
---------------
Perl_Player_Config = {};

-- Defaults
local Perl_Player_State = 1;
local locked = 0;
local InCombat = nil;
local framefade = 0;
--local hidebarart = 1;
--local showbuffs = 0;
--local buffalerts = 0;
local BlizzardPlayerFrame_Update = PlayerFrame_UpdateStatus;
local transparency = 1;  -- general transparency for frames relative to bars/text  default is 0.8
local idletransparency = 0.5; -- mouseout transparency.
local Initialized = nil;
--local VariablesLoaded = nil;

-- Buff constants
-- Play with these if you'd like.  It's simply a sine wave of magnitude
-- (BuffAlphaMax - BuffAlphaMin), frequency BuffCycleSpeed, and it will start
-- at BuffWarnTime.  Note that it will clip the function if it goes above 1 or
-- below 0.
local BuffWarnTime = 31;  -- Onset of flashing.
local BuffCycleSpeed = 0.75; -- Cycles per second.
local BuffAlphaMin = 0.25;  -- Minimum alpha for the sine modulation.
local BuffAlphaMax = 1;  -- Max alpha.

-- Special stuff for using hidden tooltips so that money doesn't become hidden.
-- Props to Telo for this trick.
local lOriginal_GameTooltip_ClearMoney;

local function Perl_Player_MoneyToggle()
	if( lOriginal_GameTooltip_ClearMoney ) then
		GameTooltip_ClearMoney = lOriginal_GameTooltip_ClearMoney;
		lOriginal_GameTooltip_ClearMoney = nil;
	else
		lOriginal_GameTooltip_ClearMoney = GameTooltip_ClearMoney;
		GameTooltip_ClearMoney = Perl_Player_GameTooltip_ClearMoney;
	end	
end

function Perl_Player_GameTooltip_ClearMoney()
	-- Intentionally empty; don't clear money while we use hidden tooltips
end



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
function Perl_Player_OnLoad()

	-- Events
	this:RegisterEvent("UNIT_COMBAT");
	this:RegisterEvent("UNIT_MAXMANA");
	this:RegisterEvent("PLAYER_UPDATE_RESTING");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("PLAYER_XP_UPDATE");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_REGEN_ENABLED");
	this:RegisterEvent("PLAYER_REGEN_DISABLED");
	this:RegisterEvent("ADDON_LOADED");
		
	-- Slash Commands
	SlashCmdList["PERL_PLAYER"] = Perl_Player_SlashHandler;
	SLASH_PERL_PLAYER1 = "/PerlPlayer";
	SLASH_PERL_PLAYER2 = "/PP";
	
	table.insert(UnitPopupFrames,"Perl_Player_DropDown");

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame by Perl loaded successfully.");
	end
	UIErrorsFrame:AddMessage("|cffffff00Player Frame by Perl loaded successfully.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
end

-------------------
-- Event Handler --
-------------------
function Perl_Player_OnEvent(event)
	if (event == "UNIT_NAME_UPDATE") then
		if (UnitName("pet") and not (UnitName("pet") == "Unknown Entity")) then
			Perl_Player_Pet_VarInit();
		end
		if (UnitName("player") == "Unknown Entity") then
			return;
		else 
			Perl_Player_Initialize();
		end
		return;
	elseif (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD") then
		Perl_Player_Initialize();
		--VariablesLoaded = 1;
		if (UnitName("pet") and not (UnitName("pet") == "Unknown Entity")) then
			Perl_Player_Pet_VarInit();
		end
		return;
	elseif (event == "ADDON_LOADED" and arg1 == "Perl_Player") then
		Perl_Player_myAddOns_Support();
		return;
--	elseif (event == "PLAYER_ENTERING_WORLD") then
--		Perl_Player_Initialize();
--		if (UnitName("pet") and not (UnitName("pet") == "Unknown Entity")) then
--			Perl_Player_Pet_VarInit();
--		end
--	elseif (event == "VARIABLES_LOADED") then
--		VariablesLoaded = 1;
	elseif (event == "PLAYER_REGEN_ENABLED") then
		InCombat = nil;
		Perl_Player_UpdateDisplay();
		return;
	elseif (event == "PLAYER_REGEN_DISABLED") then
		InCombat = 1;
		Perl_Player_UpdateDisplay();
		return;
	else	
		Perl_Player_UpdateDisplay();
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
	elseif (string.find(msg, "toggle")) then
		Perl_Player_TogglePlayer();
	elseif (string.find(msg, "status")) then
		Perl_Player_Status();
	--elseif (string.find(msg, "hideart")) then
		--Perl_Player_ToggleHideBarArt();
	--elseif (string.find(msg, "buff")) then
		--Perl_Player_ToggleBuffs();
	--elseif (string.find(msg, "alert")) then
		--Perl_Player_ToggleBuffAlerts();
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Player Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff toggle |cffffff00- Toggle the player frame on and off.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffffff buffs |cffffff00- Toggle the built in buff monitor on the player frame.");
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffffff alerts |cffffff00- Toggle warning messages for buffs (at 30 seconds left).");
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffffff hideart |cffffff00- Hide most of the art on the bottom bar (cosmetic).");
	end
end

-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Player_Initialize() 

	--if (Initialized or (not VariablesLoaded)) then
	if (Initialized) then
		return;
	end

	-- Major config options.
	Perl_Player_StatsFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_LevelFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_NameFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Frame:Hide();
	
	Perl_Player_HealthBarText:SetTextColor(1,1,1,1);
	Perl_Player_ManaBarText:SetTextColor(1,1,1,1);
	
	-- Set Name
	Perl_Player_NameBarText:SetText(UnitName("player"));
	
	-- Set Class
	local PlayerClass = UnitClass("player");
	Perl_Player_ClassTexture:SetTexCoord(Perl_Target_ClassPosRight[PlayerClass], Perl_Target_ClassPosLeft[PlayerClass], Perl_Target_ClassPosTop[PlayerClass], Perl_Target_ClassPosBottom[PlayerClass]);
	
	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Player_Config[UnitName("player")]) == "table") then
		Perl_Player_GetVars();
	else
		Perl_Player_Config[UnitName("player")] = {
							["Locked"] = locked
							--["buffs"] = showbuffs,
							--["hidebarart"] = hidebarart,
							--["alerts"] = buffalerts
							};
	end

	-- Load Variables
--	local strlocked;
--	local strstate;
--
--	if (Perl_Player_State == 1) then
--		strstate = "|cffffffffEnabled|cffffff00";
--	else
--		strstate = "|cffffffffDisabled|cffffff00";
--	end
--	
--	if (locked == 1) then
--		strlocked = "|cffffffffLocked|cffffff00";
--	else
--		strlocked = "|cffffffffUnlocked|cffffff00";
--	end
--	
--	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame by Perl loaded successfully. "..strstate..", and "..strlocked..".");

--	if (getglobal('PERL_COMMON')) then
--		Perl_Player_HealthBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--		Perl_Player_ManaBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--		Perl_Player_XPBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--		Perl_Player_XPRestBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--	end

	
	
--	if (framefade == 1) then
--		Perl_Player_Frame:SetAlpha(idletransparency);
--	end
	

	-- Bar Art hiding stuff.	
--	ExhaustionTick_Update_Backup = ExhaustionTick_Update;  -- store old function.
--	Perl_Player_HideBarArt();
	
	
	
	if (Perl_Player_State == 1) then
		PlayerFrame_UpdateStatus = Perl_Player_UpdateDisplay;
		Perl_Player_Frame:Show();
		Perl_Player_UpdateDisplay();
	else
		Perl_Player_Frame:Hide();
		PlayerFrame_UpdateStatus = BlizzardPlayerFrame_Update;
	end

	Initialized = 1;
end

function Perl_Player_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_Player_myAddOns_Details = {
			name = "Perl_Player",
			version = "v0.03",
			releaseDate = "October 6, 2005",
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

-------------------------
-- The Update Function --
-------------------------
function Perl_Player_UpdateDisplay()
  if (Perl_Player_State == 0) then
		Perl_Player_Frame:Hide();
		PlayerFrame_UpdateStatus = BlizzardPlayerFrame_Update;
	else

	-- set common variables
	local playermana = UnitMana("player");
	local playermanamax = UnitManaMax("player");
	local playermanapercent = floor(UnitMana("player")/UnitManaMax("player")*100+0.5);
	local playerhealth = UnitHealth("player");
	local playerhealthmax = UnitHealthMax("player");
	local playerhealthpercent = floor(UnitHealth("player")/UnitHealthMax("player")*100+0.5);
	local playerxp = UnitXP("player");
	local playerxpmax = UnitXPMax("player");
	local playerxprest = GetXPExhaustion();
	local playerlevel = UnitLevel("player");
	local playerpower = UnitPowerType("player");
	
	-- PVP Status settings
	if (UnitIsPVP("player")) then
		Perl_Player_NameBarText:SetTextColor(0,1,0);
		Perl_Player_PVPStatus:Hide();
		--Perl_Player_PVPStatus:Show();
		--if (UnitFactionGroup('player') == "Horde") then
			--Perl_Player_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde");
		--else
			--Perl_Player_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance");
		--end
	else
		Perl_Player_NameBarText:SetTextColor(0.5,0.5,1);
		Perl_Player_PVPStatus:Hide();
	end
	
	-- Rest/Combat Status Icon
	if (InCombat == 1) then
		Perl_Player_ActivityStatus:SetTexCoord(0.5, 1.0, 0.0, 0.5);
		Perl_Player_ActivityStatus:Show();
	elseif (IsResting()) then
		Perl_Player_ActivityStatus:SetTexCoord(0, 0.5, 0.0, 0.5);
		Perl_Player_ActivityStatus:Show();
	else
		Perl_Player_ActivityStatus:Hide();
	end
	
	-- Team Leader Icon setting
	if (IsPartyLeader()) then
		Perl_Player_LeaderIcon:Show();
	else
		Perl_Player_LeaderIcon:Hide();
	end
		
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
	
	
	-- Set Statistics
	Perl_Player_HealthBar:SetMinMaxValues(0, playerhealthmax);
	Perl_Player_ManaBar:SetMinMaxValues(0, playermanamax);
	Perl_Player_XPBar:SetMinMaxValues(0, playerxpmax);
	Perl_Player_XPRestBar:SetMinMaxValues(0, playerxpmax);
	
	Perl_Player_HealthBar:SetValue(playerhealth);
	Perl_Player_ManaBar:SetValue(playermana);
	Perl_Player_XPBar:SetValue(playerxp);
	
	--if (getglobal('PERL_COMMON')) then
		--Perl_SetSmoothBarColor(Perl_Player_HealthBar);
		--Perl_SetSmoothBarColor(Perl_Player_HealthBarBG, Perl_Player_HealthBar, 0.25);
	--end
	
	-- Set Level
	Perl_Player_LevelFrame_LevelBarText:SetText(playerlevel);
	
	-- Set xp text
	local xptext = playerxp.."/"..playerxpmax;
	local xptextpercent = floor(playerxp/playerxpmax*100+0.5);

	if (playerxprest) then
		xptext = xptext .."(+"..(playerxprest)..")";
		Perl_Player_XPBar:SetStatusBarColor(0.3, 0.3, 1, 1);
		Perl_Player_XPRestBar:SetStatusBarColor(0.3, 0.3, 1, 0.5);
		Perl_Player_XPBarBG:SetStatusBarColor(0.3, 0.3, 1, 0.25);
		Perl_Player_XPRestBar:SetValue(playerxp + playerxprest);
	else
		Perl_Player_XPBar:SetStatusBarColor(0.6, 0, 0.6, 1);
		Perl_Player_XPRestBar:SetStatusBarColor(0.6, 0, 0.6, 0.5);
		Perl_Player_XPBarBG:SetStatusBarColor(0.6, 0, 0.6, 0.25);
		Perl_Player_XPRestBar:SetValue(playerxp);
	end
	
	
	Perl_Player_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
	Perl_Player_HealthBarTextPercent:SetText(playerhealthpercent .. "%");
	Perl_Player_ManaBarText:SetText(playermana.."/"..playermanamax);
	Perl_Player_ManaBarTextPercent:SetText(playermanapercent .. "%");
	Perl_Player_XPBarText:SetText(xptextpercent.."%");
	
	PlayerFrame:Hide();  -- Hide default frame
	end
end

----------------------
-- Config functions --
----------------------
function Perl_Player_TogglePlayer()
	if (Perl_Player_State == 0) then
		Perl_Player_State = 1;
		PlayerFrame_UpdateStatus = Perl_Player_UpdateDisplay;
		PlayerFrame:Hide();  -- Hide default frame
		Perl_Player_Frame:Show();
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Player Display is now |cffffffffEnabled|cffffff00.");
		Perl_Target_UpdateDisplay();
	else
		Perl_Player_State = 0;
		PlayerFrame_UpdateStatus = BlizzardPlayerFrame_Update;
		Perl_Player_Frame:Hide();
		PlayerFrame:Show();  -- Show default frame
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Player Display is now |cffffffffDisabled|cffffff00.");
	end
	Perl_Target_UpdateVars();
end

function Perl_Player_Lock ()
	locked = 1;
	Perl_Player_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffLocked|cffffff00.");
end

function Perl_Player_Unlock ()
	locked = 0;
	Perl_Player_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is now |cffffffffUnlocked|cffffff00.");
end

function Perl_Player_Status()
  if (Perl_Player_State == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffDisabled|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffEnabled|cffffff00.");
	end
	
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffLocked|cffffff00.");
	end
end

function Perl_Player_UpdateVars()
	Perl_Player_Config[UnitName("player")] = {
		["Locked"] = locked
		--["buffs"] = showbuffs,
		--["hidebarart"] = hidebarart,
		--["alerts"] = buffalerts
	};
end

function Perl_Player_GetVars()
	locked = Perl_Player_Config[UnitName("player")]["Locked"];
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

function Perl_Player_MouseUp(button)

	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("player");
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("player");
		else
			TargetUnit("player");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_Player_DropDown, "Perl_Player_NameFrame", 40, 0);
	end
	
	Perl_Player_Frame:StopMovingOrSizing();
end

function Perl_Player_MouseDown(button)
	if ( button == "LeftButton" and locked == 0) then
		Perl_Player_Frame:StartMoving();
	end
end

---------------------------------
-- Mouse enter/leave functions --
---------------------------------
function Perl_Player_MouseEnter()
	if (framefade == 1) then
		Perl_Player_Frame:SetAlpha(1);
	end
end

function Perl_Player_MouseLeave()
	if (framefade == 1) then
		Perl_Player_Frame:SetAlpha(idletransparency);
	end
end

function Perl_Player_XPTooltip()
	local playerxp = UnitXP("player");
	local playerxpmax = UnitXPMax("player");
	local playerxprest = GetXPExhaustion();
	local xptext = playerxp.."/"..playerxpmax;

	if (playerxprest) then
		xptext = xptext .."(+"..(playerxprest)..")";
	end

	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:SetText(xptext, 255/255, 209/255, 0/255);
	GameTooltip:Show();
end