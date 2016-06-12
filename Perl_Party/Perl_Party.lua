---------------
-- Variables --
---------------
Perl_Party_Config = {};

-- Defaults
local transparency = 1.0;
local Perl_Party_State = 1;
local Initialized = nil;	-- waiting to be initialized
local buffmapping = {
	["buffmapping1"] = 0,
	["buffmapping2"] = 0,
	["buffmapping3"] = 0,
	["buffmapping4"] = 0,
};
local locked = 0;
local compactmode = 0;		-- compact mode is disabled by default

-- Variables for position of the class icon texture.
local Perl_Party_ClassPosRight = {
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
local Perl_Party_ClassPosLeft = {
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
local Perl_Party_ClassPosTop = {
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
local Perl_Party_ClassPosBottom = {
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
function Perl_Party_OnLoad()
	--Events
	this:RegisterEvent("ADDON_LOADED"); --
	this:RegisterEvent("PARTY_LEADER_CHANGED"); --
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_DISABLE"); --
	this:RegisterEvent("PARTY_MEMBER_ENABLE"); --
	this:RegisterEvent("PARTY_MEMBERS_CHANGED"); --
	this:RegisterEvent("PLAYER_ENTERING_WORLD"); --
	this:RegisterEvent("UNIT_AURA"); --
	this:RegisterEvent("UNIT_DISPLAYPOWER"); --
	this:RegisterEvent("UNIT_ENERGY"); --
	--this:RegisterEvent("UNIT_FOCUS");
	this:RegisterEvent("UNIT_HEALTH"); --
	this:RegisterEvent("UNIT_LEVEL"); --
	this:RegisterEvent("UNIT_MANA"); --
	this:RegisterEvent("UNIT_PVP_UPDATE"); --
	this:RegisterEvent("UNIT_RAGE"); --
	this:RegisterEvent("VARIABLES_LOADED"); --

	-- Slash Commands
	SlashCmdList["PERL_PARTY"] = Perl_Party_SlashHandler;
	SLASH_PERL_PARTY1 = "/perlparty";
	SLASH_PERL_PARTY2 = "/ppty";
	
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame1_DropDown");
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame2_DropDown");
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame3_DropDown");
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame4_DropDown");
	
	HidePartyFrame();
end


-------------------
-- Event Handler --
-------------------
function Perl_Party_OnEvent(event)
	if (event == "UNIT_HEALTH") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Health();
			Perl_Party_Update_Dead_Status();	-- Is the target dead?
		end
		return;
	elseif ((event == "UNIT_MANA") or (event == "UNIT_ENERGY") or (event == "UNIT_RAGE")) then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Mana();
		end
		return;
	elseif (event == "UNIT_AURA") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Buff_UpdateAll();
		end
		return;
	elseif (event == "UNIT_DISPLAYPOWER") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Mana_Bar();		-- What type of energy are we using now?
			Perl_Party_Update_Mana();		-- Update the energy info immediately
		end
		return;
	elseif (event == "UNIT_PVP_UPDATE") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_PvP_Status();		-- Is the character PvP flagged?
		end
		return;
	elseif (event == "UNIT_LEVEL") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Level();		-- Set the player's level
		end
		return;
	elseif ((event == "PARTY_MEMBERS_CHANGED") or (event == "PARTY_LEADER_CHANGED") or (event == "PARTY_MEMBER_ENABLE") or (event == "PARTY_MEMBER_DISABLE")) then
		Perl_Party_MembersUpdate();			-- How many members are in the group and show the correct frames and do UpdateOnce things
		Perl_Party_Update_Leader_Loot_Method();		-- Who is the group leader and who is the master looter
		return;
	elseif (event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED") then
		Perl_Party_Initialize();
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_Party") then
			Perl_Party_myAddOns_Support();
		end
		return;
	else
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_Party_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Party_Unlock();
	elseif (string.find(msg, "lock")) then
		Perl_Party_Lock();
	elseif (string.find(msg, "compact")) then
		Perl_Party_Toggle_CompactMode();
	elseif (string.find(msg, "status")) then
		Perl_Party_Status();
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Party Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff compact |cffffff00- Toggle compact mode.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Party_Initialize()
	-- Check if we loaded the mod already.
	if (Initialized) then
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Party_Config[UnitName("player")]) == "table") then
		Perl_Party_GetVars();
	else
		Perl_Party_UpdateVars();
	end

	-- Major config options.
	getglobal(this:GetName().."_NameFrame"):SetBackdropColor(0, 0, 0, transparency);
	getglobal(this:GetName().."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	getglobal(this:GetName().."_LevelFrame"):SetBackdropColor(0, 0, 0, transparency);
	getglobal(this:GetName().."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);
	getglobal(this:GetName().."_StatsFrame"):SetBackdropColor(0, 0, 0, transparency);
	getglobal(this:GetName().."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, transparency);

	if (compactmode == 0) then
		getglobal(this:GetName().."_StatsFrame"):SetWidth(240);
	else
		getglobal(this:GetName().."_StatsFrame"):SetWidth(170);
	end

	Perl_Party_MembersUpdate();
end


----------------------
-- Update Functions --
----------------------
function Perl_Party_MembersUpdate()
	local partymax = 0;
	for partynum=1,4 do
		local partyid = "party"..partynum;
		local frame = getglobal("Perl_Party_MemberFrame"..partynum);
		if (UnitName(partyid) ~= nil) then
			frame:Show();
			partymax = partynum;
		else
			frame:Hide();
		end
	end
	Perl_Party_Set_Name();
	Perl_Party_Update_PvP_Status();
	Perl_Party_Set_Class_Icon();
	Perl_Party_Update_Level();
	Perl_Party_Update_Health();
	Perl_Party_Update_Dead_Status();
	Perl_Party_Update_Mana();
	Perl_Party_Update_Mana_Bar();
	Perl_Party_Update_Leader_Loot_Method();
	Perl_Party_Buff_UpdateAll();
	getglobal(this:GetName().."_NameFrame_PVPStatus"):Hide();	-- Set pvp status icon (need to remove the xml code eventually)
	HidePartyFrame();
end

function Perl_Party_Update_Health()
	local partyid = "party"..this:GetID();
	local partyhealth = UnitHealth(partyid);
	local partyhealthmax = UnitHealthMax(partyid);
	local partyhealthpercent = floor(partyhealth/partyhealthmax*100+0.5);

	getglobal(this:GetName().."_StatsFrame_HealthBar"):SetMinMaxValues(0, partyhealthmax);
	getglobal(this:GetName().."_StatsFrame_HealthBar"):SetValue(partyhealth);

	if (compactmode == 0) then
		getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarText"):SetText(partyhealth.."/"..partyhealthmax);
		getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealthpercent.."%");
	else
		getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarText"):SetText();
		getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
	end
end

function Perl_Party_Update_Mana()
	local partyid = "party"..this:GetID();
	local partymana = UnitMana(partyid);
	local partymanamax = UnitManaMax(partyid);
	local partymanapercent = floor(partymana/partymanamax*100+0.5);

	getglobal(this:GetName().."_StatsFrame_ManaBar"):SetMinMaxValues(0, partymanamax);
	getglobal(this:GetName().."_StatsFrame_ManaBar"):SetValue(partymana);

	if (compactmode == 0) then
		getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarText"):SetText(partymana.."/"..partymanamax);
		getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymanapercent.."%");
	else
		getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarText"):SetText();
		getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
	end
end

function Perl_Party_Update_Mana_Bar()
	local partyid = "party"..this:GetID();
	local partypower = UnitPowerType(partyid);

	-- Set mana bar color
	if (partypower == 1) then
		getglobal(this:GetName().."_StatsFrame_ManaBar"):SetStatusBarColor(1, 0, 0, 1);
		getglobal(this:GetName().."_StatsFrame_ManaBarBG"):SetStatusBarColor(1, 0, 0, 0.25);
	elseif (partypower == 2) then
		getglobal(this:GetName().."_StatsFrame_ManaBar"):SetStatusBarColor(1, 0.5, 0, 1);
		getglobal(this:GetName().."_StatsFrame_ManaBarBG"):SetStatusBarColor(1, 0.5, 0, 0.25);
	elseif (partypower == 3) then
		getglobal(this:GetName().."_StatsFrame_ManaBar"):SetStatusBarColor(1, 1, 0, 1);
		getglobal(this:GetName().."_StatsFrame_ManaBarBG"):SetStatusBarColor(1, 1, 0, 0.25);
	else
		getglobal(this:GetName().."_StatsFrame_ManaBar"):SetStatusBarColor(0, 0, 1, 1);
		getglobal(this:GetName().."_StatsFrame_ManaBarBG"):SetStatusBarColor(0, 0, 1, 0.25);
	end
end

function Perl_Party_Set_Name()
	local partyid = "party"..this:GetID();
	local partyname = UnitName(partyid);
	-- Set name
	if (UnitName(partyid) ~= nil) then
		if (strlen(partyname) > 20) then
			Partyname = strsub(partyname, 1, 19).."...";
		end
		getglobal(this:GetName().."_NameFrame_NameBarText"):SetText(partyname);
	end
end

function Perl_Party_Update_PvP_Status()
	local partyid = "party"..this:GetID();
	-- Color their name if PvP flagged
	if (UnitIsPVP(partyid)) then
		getglobal(this:GetName().."_NameFrame_NameBarText"):SetTextColor(0,1,0);
	else
		getglobal(this:GetName().."_NameFrame_NameBarText"):SetTextColor(0.5,0.5,1);
	end
end

function Perl_Party_Update_Level()
	local partyid = "party"..this:GetID();
	local partylevel = UnitLevel(partyid);
	-- Set Level
	getglobal(this:GetName().."_LevelFrame_LevelBarText"):SetText(partylevel);
end

function Perl_Party_Update_Leader_Loot_Method()
	-- Set Leader Icon / Master
	local id = this:GetID();
	local icon = getglobal(this:GetName().."_NameFrame_LeaderIcon");
	if (GetPartyLeaderIndex() == id ) then
		icon:Show();
	else
		icon:Hide();
	end
	icon = getglobal(this:GetName().."_NameFrame_MasterIcon");
	local lootMethod;
	local lootMaster;
	lootMethod, lootMaster = GetLootMethod();
	if (id == lootMaster) then
		icon:Show();
	else
		icon:Hide();
	end
end

function Perl_Party_Update_Dead_Status()
	local partyid = "party"..this:GetID();
	-- Set Dead Icon
	if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then
		getglobal(this:GetName().."_NameFrame_DeadStatus"):Show();
	else
		getglobal(this:GetName().."_NameFrame_DeadStatus"):Hide();
	end
end

function Perl_Party_Set_Class_Icon()
	local partyid = "party"..this:GetID();
	-- Set Class Icon
	if (UnitIsPlayer(partyid)) then
		local PlayerClass = UnitClass(partyid);
		getglobal(this:GetName().."_LevelFrame_ClassTexture"):SetTexCoord(Perl_Party_ClassPosRight[PlayerClass], Perl_Party_ClassPosLeft[PlayerClass], Perl_Party_ClassPosTop[PlayerClass], Perl_Party_ClassPosBottom[PlayerClass]); -- Set the player's class icon
		getglobal(this:GetName().."_LevelFrame_ClassTexture"):Show();
	else
		getglobal(this:GetName().."_LevelFrame_ClassTexture"):Hide();
	end
end


----------------------
-- Config Functions --
----------------------
function Perl_Party_Lock()
	locked = 1;
	Perl_Party_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffLocked|cffffff00.");
end

function Perl_Party_Unlock()
	locked = 0;
	Perl_Party_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffUnlocked|cffffff00.");
end

function Perl_Party_Toggle_CompactMode()
	if (compactmode == 0) then
		compactmode = 1;
		--getglobal(this:GetName().."_StatsFrame"):SetWidth(170);
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now displaying in |cffffffffCompact Mode|cffffff00.");
	else
		compactmode = 0;
		--Perl_Party_Update_Health();
		--Perl_Party_Update_Mana();
		--getglobal(this:GetName().."_StatsFrame"):SetWidth(240);
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now displaying in |cffffffffNormal Mode|cffffff00.");
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Please relog or '/console reloadui' for changes to take effect.");
	Perl_Party_UpdateVars();
	--Initialized = nil;
	--Perl_Party_Initialize();
end

function Perl_Party_Status()
	if (Perl_Player_State == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is |cffffffffDisabled|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is |cffffffffEnabled|cffffff00.");
	end

	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is |cffffffffLocked|cffffff00.");
	end

	if (compactmode == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is displaying in |cffffffffNormal Mode|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is displaying in |cffffffffCompact Mode|cffffff00.");
	end
end

function Perl_Party_GetVars()
	locked = Perl_Party_Config[UnitName("player")]["Locked"];
	compactmode = Perl_Party_Config[UnitName("player")]["CompactMode"];

	if (locked == nil) then
		locked = 0;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
end

function Perl_Party_UpdateVars()
	Perl_Party_Config[UnitName("player")] = {
					["Locked"] = locked,
					["CompactMode"] = compactmode,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Party_Buff_UpdateAll()
	local partyid = "party"..this:GetID();
	local mapid = "buffmapping"..this:GetID();
	if (UnitName(partyid)) then
		for buffnum=1,8 do
			local button = getglobal(this:GetName().."_BuffFrame_Buff"..buffnum);
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");

			if (UnitBuff(partyid, buffnum)) then
				icon:SetTexture(UnitBuff(partyid, buffnum));
				debuff:Hide();
				button:Show();
			else
				button:Hide();
			end
		end

		--DEFAULT_CHAT_FRAME:AddMessage(partyid..buffmapping[mapid]);
		for buffnum=1,8 do
			local button = getglobal(this:GetName().."_BuffFrame_Debuff"..(buffnum));
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");

			if (UnitDebuff(partyid, buffnum)) then
				icon:SetTexture(UnitDebuff(partyid, buffnum));
				debuff:Show();
				button:Show();
			else
				button:Hide();
			end
		end
	end
end

function Perl_Party_SetBuffTooltip()
	local partyid = "party"..this:GetParent():GetParent():GetID();
	GameTooltip:SetOwner(this,"ANCHOR_BOTTOMRIGHT");
	if (this.isdebuff == 1) then
		GameTooltip:SetUnitDebuff(partyid, this:GetID()-0);
	else
		GameTooltip:SetUnitBuff(partyid, this:GetID());
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_PartyDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_PartyDropDown_Initialize, "MENU");
end

function Perl_PartyDropDown_Initialize()
	local dropdown;
	if ( UIDROPDOWNMENU_OPEN_MENU ) then
		dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	else
		dropdown = this;
	end
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..this:GetID());
end

function Perl_Party_MouseUp(button)
	local id = this:GetID();
	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("party"..id);
		elseif ( CursorHasItem() ) then
			DropItemOnUnit("party"..id);
		else
			TargetUnit("party"..id);
		end
	else
		ToggleDropDownMenu(1, nil, getglobal(this:GetName().."_DropDown"), this:GetName(), 0, 0);
	end
	
	Perl_Party_Frame:StopMovingOrSizing();
end

function Perl_Party_MouseDown(button)
	if ( button == "LeftButton" and locked == 0 and this:GetID() == 1) then
		Perl_Party_Frame:StartMoving();
	end
end

function Perl_Party_PlayerTip()
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:SetUnit("party"..this:GetID());
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Party_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Party_myAddOns_Details = {
			name = "Perl_Party",
			version = "v0.13",
			releaseDate = "October 29, 2005",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Party_myAddOns_Help = {};
		Perl_Party_myAddOns_Help[1] = "/perlparty\n/ppty\n";
		myAddOnsFrame_Register(Perl_Party_myAddOns_Details, Perl_Party_myAddOns_Help);
	end
end