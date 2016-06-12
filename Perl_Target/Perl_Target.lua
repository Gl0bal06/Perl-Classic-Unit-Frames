---------------
-- Variables --
---------------
Perl_Target_Config = {};

-- Defaults
local Initialized = nil;
local transparency = 1; --0.8 default
local Perl_Target_State = 1;
local buffmapping = 0;
local locked = 0;
local showcp = 1;
local numbuffsshown = 20
local numdebuffsshown = 16
local BlizzardTargetFrame_Update = TargetFrame_Update;


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
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("PLAYER_COMBO_POINTS");
	this:RegisterEvent("ADDON_LOADED");
		
	-- Slash Commands
	SlashCmdList["PERL_TARGET"] = Perl_Target_SlashHandler;
	SLASH_PERL_TARGET1 = "/PerlTarget";
	SLASH_PERL_TARGET2 = "/PT";
	
	table.insert(UnitPopupFrames,"Perl_Target_DropDown");

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame by Perl loaded successfully.");
	end
	UIErrorsFrame:AddMessage("|cffffff00Target Frame by Perl loaded successfully.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
end

-------------------
-- Event Handler --
-------------------
function Perl_Target_OnEvent(event)
	--if (event == "PLAYER_ENTERING_WORLD") then
		--Perl_Target_Initialize();
	--elseif (event == "ADDON_LOADED") then
		--Perl_Target_Initialize();
	if (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD") then
		Perl_Target_Initialize();
		return;
	--end
	elseif (event == "ADDON_LOADED" and arg1 == "Perl_Target") then
		Perl_Target_myAddOns_Support();
		return;
	elseif ( event == "PLAYER_TARGET_CHANGED" or event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE") then
		Perl_Target_UpdateDisplay();
--		if ( event == "PARTY_MEMBERS_CHANGED" ) then
--			TargetFrame_CheckFaction();
--		end
		return;
	elseif (event == "UNIT_AURA" and arg1 == "target") then
		Perl_Target_Buff_UpdateAll();
		return;
	else
		Perl_Target_UpdateDisplay();
		return;
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
	elseif (string.find(msg, "status")) then
		Perl_Target_Status();
	elseif (string.find(msg, "toggle")) then
		Perl_Target_ToggleTarget();
	elseif (string.find(msg, "debuffs")) then
	  local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			Perl_Target_Set_Debuffs(arg1)
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of debuffs to display: /pt debuffs #");
		end
	elseif (string.find(msg, "buffs")) then
	  local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			Perl_Target_Set_Buffs(arg1)
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a number of buffs to display: /pt buffs #");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Target Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff combopoints |cffffff00- Toggle the displaying of combo points.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff buff # |cffffff00- Show the number of buffs to display.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff debuff # |cffffff00- Toggle the displaying of combo points.");
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
	
	

	
--	-- Check if a previous exists, if not, enable by default.
--	if (Perl_Target_Config[UnitName("player")]["State"] == nil) then
--		Perl_Target_Config[UnitName("player")]["State"] = 1;
--	else
--	  Perl_Target_State = Perl_Target_Config[UnitName("player")]["State"];  -- Move value to internal variable.
--	end

	

--	if (type(Perl_Target_Config[UnitName("player")]["Locked"]) == "table") then
--		Perl_Target_Config[UnitName("player")]["Locked"] = 0;
--	else
--		locked = Perl_Target_Config[UnitName("player")]["Locked"];  -- Move value to internal variable.
--	end
--	
--	if (type(Perl_Target_Config[UnitName("player")]["ComboPoints"]) == "table") then
--		Perl_Target_Config[UnitName("player")]["ComboPoints"] = 1;
--	else
--		showcp = Perl_Target_Config[UnitName("player")]["ComboPoints"];  -- Move value to internal variable.
--	end

	
		-- Load Variables
--	local strcombo;
--	local strlocked;
--	local strstate;
	
	-- Set locked state and strings.
	--if (Perl_Target_State > 1) then
		--locked = 1;
		--strlocked = "|cfffffffflocked|cffffff00";
		--Perl_Target_State = Perl_Target_State - 2;
	--else
		--strlocked = "|cffffffffunlocked|cffffff00";
	--end
--	if (Perl_Target_State == 1) then
--		strstate = "|cffffffffEnabled|cffffff00";
--	else
--		strstate = "|cffffffffDisabled|cffffff00";
--	end
--	
--	if (locked == 1) then
--	  strlocked = "|cffffffffLocked|cffffff00";
--	else
--		strlocked = "|cffffffffUnlocked|cffffff00";
--	end
--	
--	if (showcp == 1) then
--		strcombo = "|cffffffffShown|cffffff00";
--	else
--		strcombo = "|cffffffffHidden|cffffff00";
--	end
	
	--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame by Perl loaded successfully. "..strstate..", "..strlocked..", and CP "..strcombo..".");

	--if (getglobal('PERL_COMMON')) then
		--Perl_Target_HealthBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
		--Perl_Target_ManaBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
	--end

	
	
	if (Perl_Target_State == 1) then
		TargetFrame_Update = Perl_Target_UpdateDisplay;
		Perl_Target_UpdateDisplay();
	else
	  Perl_Target_Frame:Hide();
		TargetFrame_Update = BlizzardTargetFrame_Update;
	end

	Initialized = 1;
end

function Perl_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_Target_myAddOns_Details = {
			name = "Perl_Target",
			version = "v0.03",
			releaseDate = "October 6, 2005",
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


-------------------------
-- The Update Function --
-------------------------
function Perl_Target_UpdateDisplay()
	if (Perl_Target_State == 0) then
		Perl_Target_Frame:Hide();
		TargetFrame_Update = BlizzardTargetFrame_Update;
	else
		if (UnitExists("target")) then
		--if (UnitName("target") ~= nil) then
			-- set common variables
			local targetname = UnitName("target");
			local targetmana = UnitMana("target");
			local targetmanamax = UnitManaMax("target");
			local targethealth = UnitHealth("target");
			local targethealthmax = UnitHealthMax("target");
			local targetlevel = UnitLevel("target");
			local targetlevelcolor = GetDifficultyColor(targetlevel);
			local targetclassification = UnitClassification("target");
			local targetpower = UnitPowerType("target");
			
			-- show it
			Perl_Target_Frame:Show();
			
			-- Set name
			if (strlen(targetname) > 20) then
				targetname = strsub(targetname, 1, 19).."...";
			end
			Perl_Target_NameBarText:SetText(targetname);  
			
			-- Set Text Color
			if (UnitIsTapped("target") and not UnitIsTappedByPlayer("target")) then
				Perl_Target_NameBarText:SetTextColor(0.5,0.5,0.5);
			elseif (UnitIsPlayer("target")) then
				if (UnitFactionGroup("player") == UnitFactionGroup("target")) then
					if (UnitIsPVP("target")) then
						Perl_Target_NameBarText:SetTextColor(0,1,0);
					else
						Perl_Target_NameBarText:SetTextColor(0.5,0.5,1);
					end
				else
					if (UnitIsPVP("target")) then
						Perl_Target_NameBarText:SetTextColor(1,1,0);
					else
						Perl_Target_NameBarText:SetTextColor(0.5,0.5,1);
					end
				end
			else
				if (UnitFactionGroup("player") == UnitFactionGroup("target")) then
					Perl_Target_NameBarText:SetTextColor(0,1,0);
				elseif (UnitIsEnemy("player", "target")) then			
					Perl_Target_NameBarText:SetTextColor(1,0,0);					
				else					
					Perl_Target_NameBarText:SetTextColor(1,1,0);
				end
			end
			
			-- Set pvp status icon
			Perl_Target_PVPStatus:Hide();
			--if (UnitIsPVP("target")) then
				--if (UnitFactionGroup("target") == "Alliance") then
					--Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance");
				--elseif (UnitFactionGroup("target") == "Horde") then
					--Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde");
				--else
					--Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
				--end
				--Perl_Target_PVPStatus:Show();
				--Perl_Target_PVPStatus:Hide();
			--else
				--Perl_Target_PVPStatus:Hide();
			--end
			
			-- Set Dead Icon
			if (UnitIsDead("target")) then
				Perl_Target_DeadStatus:Show();
			else
				Perl_Target_DeadStatus:Hide();
			end
			
			
			-- Set Level
			
			
			--elseif (targetlevel > UnitLevel("player") + 4) then
				--Perl_Target_LevelBarText:SetTextColor(1, 0, 0);
			--elseif (targetlevel > UnitLevel("player") + 2) then
				--Perl_Target_LevelBarText:SetTextColor(1, 0.5, 0);
			--elseif (UnitIsTrivial("target")) then
				--Perl_Target_LevelBarText:SetTextColor(0.6, 0.6, 0.6);
			--elseif (targetlevel < UnitLevel("player") - 2) then
				--Perl_Target_LevelBarText:SetTextColor(0.5, 1, 0);
			--else
				--Perl_Target_LevelBarText:SetTextColor(1, 1, 0);
			--end
				
			Perl_Target_LevelBarText:SetVertexColor(targetlevelcolor.r, targetlevelcolor.g, targetlevelcolor.b);
			
			if ( targetclassification == "worldboss" ) then
			  Perl_Target_LevelBarText:SetTextColor(1, 0, 0);
			  targetlevel = "??";
			elseif (targetlevel < 0) then
				Perl_Target_LevelBarText:SetTextColor(1, 0, 0);
				targetlevel = "??";
			end
			
			if (UnitIsPlusMob("target")) then
				targetlevel = targetlevel.."+";
			end
			
			Perl_Target_LevelBarText:SetText(targetlevel);
			
			
			
			-- Set Class Icon
			if (UnitIsPlayer("target")) then
				local PlayerClass = UnitClass("target");
				Perl_Target_ClassTexture:SetTexCoord(Perl_Target_ClassPosRight[PlayerClass], Perl_Target_ClassPosLeft[PlayerClass], Perl_Target_ClassPosTop[PlayerClass], Perl_Target_ClassPosBottom[PlayerClass]);							
				Perl_Target_ClassTexture:Show();
			else
				Perl_Target_ClassTexture:Hide();
			end
			
			-- Set combo points
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
			
			
			-- Set Statistics
			Perl_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
			Perl_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
			Perl_Target_HealthBar:SetValue(targethealth);
			Perl_Target_ManaBar:SetValue(targetmana);
			
			--if (getglobal('PERL_COMMON')) then
				--Perl_SetSmoothBarColor(Perl_Target_HealthBar);
				--Perl_SetSmoothBarColor(Perl_Target_HealthBarBG, Perl_Target_HealthBar, 0.25);
			--end
			
			if (targethealthmax == 100) then
				Perl_Target_HealthBarText:SetText(targethealth.."%");
			else
				Perl_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);
			end	
			
			if (targetmanamax == 100) then
				Perl_Target_ManaBarText:SetText(targetmana.."%");
			else
				Perl_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
			end

			Perl_Target_Buff_UpdateAll();
			
			TargetFrame:Hide();  -- Hide default frame
			ComboFrame:Hide();  -- Hide Combo Points
			
		else
			Perl_Target_Frame:Hide();
			Perl_Target_Frame:StopMovingOrSizing();
		end
	end
end

--function TargetFrame_Update()
--	if ( UnitExists("target") ) then
--		this:Show();
--		UnitFrame_Update();
--		UnitFrame_UpdateManaType();
--		TargetFrame_CheckLevel();
--		TargetFrame_CheckFaction();
--		TargetFrame_CheckClassification();
--		TargetFrame_CheckDead();
--		if ( UnitIsPartyLeader("target") ) then
--			TargetLeaderIcon:Show();
--		else
--			TargetLeaderIcon:Hide();
--		end
--		TargetDebuffButton_Update();
--	else
--		this:Hide();
--	end
--end

----------------------
-- Config functions --
----------------------
function Perl_Target_ToggleTarget()
	if (Perl_Target_State == 0) then
		Perl_Target_State = 1;
		TargetFrame_Update = Perl_Target_UpdateDisplay;
		Perl_Target_Frame:Show();
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Target Display is now |cffffffffEnabled|cffffff00.");
		Perl_Target_UpdateDisplay();
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

function Perl_Target_Set_Buffs(newbuffnumber)
	numbuffsshown = newbuffnumber;
	Perl_Target_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numbuffsshown.."|cffffff00 buffs.");
end

function Perl_Target_Set_Debuffs(newdebuffnumber)
	numdebuffsshown = newdebuffnumber;
	Perl_Target_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numbuffsshown.."|cffffff00 debuffs.");
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
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numbuffsshown.."|cffffff00 buffs.");
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target Frame is displaying |cffffffff"..numdebuffsshown.."|cffffff00 debuffs.");
end

function Perl_Target_GetVars()
	Perl_Target_State = Perl_Target_Config[UnitName("player")]["State"];
	locked = Perl_Target_Config[UnitName("player")]["Locked"];
	showcp = Perl_Target_Config[UnitName("player")]["ComboPoints"];
	numbuffsshown = Perl_Target_Config[UnitName("player")]["Buffs"];
	numdebuffsshown = Perl_Target_Config[UnitName("player")]["Debuffs"];
end

function Perl_Target_UpdateVars()
	Perl_Target_Config[UnitName("player")] = {
						["State"] = Perl_Target_State,
						["Locked"] = locked,
						["ComboPoints"] = showcp,
						["Buffs"] = numbuffsshown,
						["Debuffs"] = numdebuffsshown
						};
end

--function Perl_Target_UpdateVars()
--	--Perl_Target_Config[UnitName("player")] = Perl_Target_State + 2*locked;
--	Perl_Target_Config[UnitName("player")] = Perl_Target_State;
--	Perl_Target_Config.Locked = locked;
--	Perl_Target_Config.ComboPoints = showcp;
--	Perl_Target_Config.Buffs = numbuffsshown;
--	Perl_Target_Config.Debuffs = numdebuffsshown;
--end

--------------------
-- Buff Functions --
--------------------
function Perl_Target_Buff_UpdateAll()
	local friendly;
	if (UnitName("target")) then
	  if ( UnitIsFriend("player", "target") ) then
--	    Perl_Target_Buff(1);
--	    Perl_Target_Debuff(1);
	    friendly = 1;
	  else
--	    Perl_Target_Debuff(0);
--	    Perl_Target_Buff(0);
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
	for debuffnum=1,numdebuffsshown do
		local button = getglobal("Perl_Target_Debuff"..debuffnum);
		local icon = getglobal(button:GetName().."Icon");
		local debuff = getglobal(button:GetName().."DebuffBorder");
			
		if (UnitDebuff("target", debuffnum)) then
			icon:SetTexture(UnitDebuff("target", debuffnum));
			button.isdebuff = 1;
			debuff:Show();
			button:Show();
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

function Perl_Target_Buff(friendly)
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
end

function Perl_Target_Debuff(friendly)
  local debuffmax = 0;
	for debuffnum=1,numdebuffsshown do
		local button = getglobal("Perl_Target_Debuff"..debuffnum);
		local icon = getglobal(button:GetName().."Icon");
		local debuff = getglobal(button:GetName().."DebuffBorder");
			
		if (UnitDebuff("target", debuffnum)) then
			icon:SetTexture(UnitDebuff("target", debuffnum));
			button.isdebuff = 1;
			debuff:Show();
			button:Show();
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

function Perl_Target_SetBuffTooltip()
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
	if ( UnitIsEnemy("target", "player") ) then
		return;
	end
	if ( UnitIsUnit("target", "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit("target", "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer("target") ) then
		if ( UnitInParty("target") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	end
	if ( menu ) then
		UnitPopup_ShowMenu(Perl_Target_DropDown, menu, "target");
	end
end

function Perl_Target_MouseUp(button)

	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("target");
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("target");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_Target_DropDown, "Perl_Target_NameFrame", 40, 0);
	end
	
	Perl_Target_Frame:StopMovingOrSizing();
end

function Perl_Target_MouseDown(button)
	if ( button == "LeftButton" and locked == 0) then
		Perl_Target_Frame:StartMoving();
	end
end

-------------
-- Tooltip --
-------------
function Perl_Target_Tooltip_OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:SetUnit("target");
end