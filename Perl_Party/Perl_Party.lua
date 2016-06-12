---------------
-- Variables --
---------------
Perl_Party_Config = {};

-- Default Saved Variables (also set in Perl_Party_GetVars)
local locked = 0;		-- unlocked by default
local compactmode = 0;		-- compact mode is disabled by default
local partyhidden = 0;		-- party frame is set to always show by default
local partyspacing = -80;	-- default spacing between party member frames
local scale = 1;		-- default scale
local showpets = 1;		-- show pets by default
local colorhealth = 0;		-- progressively colored health bars are off by default
local healermode = 0;		-- nurfed unit frame style
local transparency = 1.0;	-- transparency for frames
local bufflocation = 4;		-- default buff location
local debufflocation = 1;	-- default debuff location
local verticalalign = 1;	-- default alignment is vertically

-- Default Local Variables
local Initialized = nil;	-- waiting to be initialized
local mouseoverhealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovermanaflag = 0;	-- is the mouse over the mana bar for healer mode?
local mouseoverpethealthflag = 0;	-- is the mouse over the pet health bar for healer mode?

-- Variables for position of the class icon texture.
local Perl_Party_ClassPosRight = {};
local Perl_Party_ClassPosLeft = {};
local Perl_Party_ClassPosTop = {};
local Perl_Party_ClassPosBottom = {};


----------------------
-- Loading Function --
----------------------
function Perl_Party_Script_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Perl Classic: Party loaded successfully.");
	end
end

function Perl_Party_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED"); 
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("PARTY_MEMBER_DISABLE");
	this:RegisterEvent("PARTY_MEMBER_ENABLE");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_PET");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("VARIABLES_LOADED");

	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame1_DropDown");
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame2_DropDown");
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame3_DropDown");
	table.insert(UnitPopupFrames,"Perl_PartyMemberFrame4_DropDown");

	HidePartyFrame();
	ShowPartyFrame = HidePartyFrame;	-- This is to fix the annoyance 1.9 introduced
end


-------------------
-- Event Handler --
-------------------
function Perl_Party_Script_OnEvent(event)				-- All this just to ensure party frames are hidden/shown on zoning
	if (event == "PLAYER_ENTERING_WORLD") then
		if (Initialized) then
			Perl_Target_Set_Hidden();			-- Are we running a hidden mode?
		end
		return;
	else
		return;
	end
end

function Perl_Party_OnEvent(event)
	if (event == "UNIT_HEALTH") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Health();
		elseif ((arg1 == "partypet1") or (arg1 == "partypet2") or (arg1 == "partypet3") or (arg1 == "partypet4")) then
			Perl_Party_Update_Pet_Health();
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
	elseif (event == "UNIT_NAME_UPDATE") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Set_Name();			-- Set the player's name and class icon
		end
		return;
	elseif (event == "UNIT_PET") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Pet();		-- Set the player's level
		end
		return;
	elseif (event == "UNIT_LEVEL") then
		if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
			Perl_Party_Update_Level();		-- Set the player's level
		end
		return;
	elseif (event == "PARTY_MEMBERS_CHANGED") then	-- or (event == "RAID_ROSTER_UPDATE") or (event == "PARTY_MEMBER_ENABLE") or (event == "PARTY_MEMBER_DISABLE")
		Perl_Party_MembersUpdate();			-- How many members are in the group and show the correct frames and do UpdateOnce things
		return;
	elseif (event == "RAID_ROSTER_UPDATE") then
		Perl_Party_Check_Raid_Hidden();			-- Are we running a hidden mode?
		return;
	elseif (event == "PARTY_LEADER_CHANGED") then
		Perl_Party_Update_Leader();			-- Who is the group leader
		return;
	elseif (event == "PARTY_LOOT_METHOD_CHANGED") then
		Perl_Party_Update_Loot_Method();		-- Who is the master looter if any
		return;
	elseif (event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED") then
		Perl_Party_Initialize();
		Perl_Target_Set_Hidden();			-- Are we running a hidden mode?
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


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Party_Initialize()
	-- Check if we loaded the mod already.
	if (Initialized) then
		Perl_Party_Set_Scale();
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Party_Config[UnitName("player")]) == "table") then
		Perl_Party_GetVars();
	else
		Perl_Party_UpdateVars();
	end

	-- Major config options.
	Perl_Party_Initialize_Frame_Color();
	Perl_Party_Set_Localized_ClassIcons();
	Perl_Party_Set_Transparency();

	if (compactmode == 0) then	-- I'd usually put this in a method, but this is just easier for the party frames
		getglobal(this:GetName().."_StatsFrame"):SetWidth(240);
	else
		getglobal(this:GetName().."_StatsFrame"):SetWidth(170);
	end

	-- Unregister the Blizzard frames via the 1.8 function
	for num = 1, 4 do
		frame = getglobal("PartyMemberFrame"..num);
		HealthBar = getglobal("PartyMemberFrame"..num.."HealthBar");
		ManaBar = getglobal("PartyMemberFrame"..num.."ManaBar");

		frame:UnregisterAllEvents();
		HealthBar:UnregisterAllEvents();
		ManaBar:UnregisterAllEvents();
	end

	Initialized = 1;
	Perl_Party_MembersUpdate();
end

function Perl_Party_Initialize_Frame_Color(flag)
	if (flag == nil) then
		getglobal(this:GetName().."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal(this:GetName().."_LevelFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal(this:GetName().."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	else
		for partynum=1,4 do
			getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		end
	end
end


----------------------
-- Update Functions --
----------------------
function Perl_Party_MembersUpdate()
	for partynum=1,4 do
		local partyid = "party"..partynum;
		local frame = getglobal("Perl_Party_MemberFrame"..partynum);
		if (UnitName(partyid) ~= nil) then
			if (partyhidden == 0) then
				frame:Show();
			else
				if (partyhidden == 1) then
					frame:Hide();
				end
				if (partyhidden == 2) then
					if (UnitInRaid("player")) then
						frame:Hide();
					else
						frame:Show();
					end
				end
			end
		else
			frame:Hide();
		end
	end
	Perl_Party_Set_Name();
	Perl_Party_Set_Scale();
	Perl_Party_Update_PvP_Status();
	Perl_Party_Update_Level();
	Perl_Party_Set_Text_Positions();
	Perl_Party_Update_Health();
	Perl_Party_Update_Mana();
	Perl_Party_Update_Mana_Bar();
	Perl_Party_Update_Leader();
	Perl_Party_Update_Loot_Method();
	Perl_Party_Update_Pet();		-- Call instead of Perl_Party_Set_Space to ensure spacing is correctly set for pets
	Perl_Party_Update_Pet_Health();
	Perl_Party_Buff_UpdateAll();
	HidePartyFrame();
end

function Perl_Party_Update_Health()
	local id = this:GetID();
	local partyid = "party"..id;
	local partyhealth = UnitHealth(partyid);
	local partyhealthmax = UnitHealthMax(partyid);
	local partyhealthpercent = floor(partyhealth/partyhealthmax*100+0.5);

	if (UnitIsDead(partyid)) then				-- This prevents negative health
		partyhealth = 0;
		partyhealthpercent = 0;
	end

	getglobal(this:GetName().."_StatsFrame_HealthBar"):SetMinMaxValues(0, partyhealthmax);
	getglobal(this:GetName().."_StatsFrame_HealthBar"):SetValue(partyhealth);

	if (colorhealth == 1) then
		if ((partyhealthpercent <= 100) and (partyhealthpercent > 75)) then
			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(0, 0.8, 0);
			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0.25);
		elseif ((partyhealthpercent <= 75) and (partyhealthpercent > 50)) then
			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(1, 1, 0);
			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(1, 1, 0, 0.25);
		elseif ((partyhealthpercent <= 50) and (partyhealthpercent > 25)) then
			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(1, 0.5, 0);
			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(1, 0.5, 0, 0.25);
		else
			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(1, 0, 0);
			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(1, 0, 0, 0.25);
		end
	else
		getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(0, 0.8, 0);
		getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (compactmode == 0) then
		if (healermode == 1) then
			getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarText"):SetText("-"..partyhealthmax - partyhealth);
			if (tonumber(mouseoverhealthflag) == tonumber(id)) then
				getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
			else
				getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
			end
		else
			getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarText"):SetText(partyhealth.."/"..partyhealthmax);
			getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealthpercent.."%");
		end
	else
		if (healermode == 1) then
			getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarText"):SetText("-"..partyhealthmax - partyhealth);
			if (tonumber(mouseoverhealthflag) == tonumber(id)) then
				getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
			else
				getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
			end
		else
			getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarText"):SetText();
			getglobal(this:GetName().."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
		end
	end

	-- Handle disconnected state
	if (UnitIsConnected(partyid)) then
		getglobal(this:GetName().."_NameFrame_DisconnectStatus"):Hide();
	else
		getglobal(this:GetName().."_NameFrame_DisconnectStatus"):Show();
	end

	-- Handle death state
	if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then
		getglobal(this:GetName().."_NameFrame_DeadStatus"):Show();
	else
		getglobal(this:GetName().."_NameFrame_DeadStatus"):Hide();
	end
end

function Perl_Party_Update_Mana()
	local id = this:GetID();
	local partyid = "party"..id;
	local partymana = UnitMana(partyid);
	local partymanamax = UnitManaMax(partyid);
	local partymanapercent = floor(partymana/partymanamax*100+0.5);

	if (UnitIsDead(partyid)) then				-- This prevents negative mana
		partymana = 0;
		partymanapercent = 0;
	end

	getglobal(this:GetName().."_StatsFrame_ManaBar"):SetMinMaxValues(0, partymanamax);
	getglobal(this:GetName().."_StatsFrame_ManaBar"):SetValue(partymana);

	if (compactmode == 0) then
		if (healermode == 1) then
			getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarText"):SetText();
			if (tonumber(mouseovermanaflag) == tonumber(id)) then
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
			else
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
			end
		else
			getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarText"):SetText(partymana.."/"..partymanamax);
			if (UnitPowerType(partyid) == 1) then
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
			else
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymanapercent.."%");
			end
		end
	else
		if (healermode == 1) then
			getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarText"):SetText();
			if (tonumber(mouseovermanaflag) == tonumber(id)) then
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
			else
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
			end
		else
			getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarText"):SetText();
			if (UnitPowerType(partyid) == 1) then
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
			else
				getglobal(this:GetName().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
			end
		end
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

function Perl_Party_Update_Pet()
	local id = this:GetID();

	if (showpets == 1) then
		if (UnitIsConnected("party"..id) and UnitExists("partypet"..id)) then
			getglobal(this:GetName().."_StatsFrame_PetHealthBar"):Show();
			getglobal(this:GetName().."_StatsFrame_PetHealthBarBG"):Show();
			getglobal(this:GetName().."_StatsFrame"):SetHeight(54);

			getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetMinMaxValues(0, 1);		-- Set health to zero in order to keep the bars sane
			getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetValue(0);			-- Info should be updated automatically anyway
			if (colorhealth == 1) then
				getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 0, 0);
			else
				getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(0, 0.8, 0);
			end
			if (compactmode == 0) then
				if (healermode == 1) then
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-0");
					if (tonumber(mouseoverpethealthflag) == tonumber(id)) then
						getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText("0/0");
					else
						getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
					end
				else
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("0/0");
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText("0%");
				end
			else
				if (healermode == 1) then
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-0");
					if (tonumber(mouseoverpethealthflag) == tonumber(id)) then
						getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText("0/0");
					else
						getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
					end
				else
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText();
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText("0/0");
				end
			end											-- End waste of code to keep it sane

			if (verticalalign == 1) then
				local idspace = id + 1;
				local partypetspacing = partyspacing - 12;
				if (id == 1 or id == 2 or id == 3) then
					local idspace = id + 1;
					local partypetspacing = partyspacing - 12;
					getglobal("Perl_Party_MemberFrame"..idspace):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id, "TOPLEFT", 0, partypetspacing);
				end
			else
				local horizontalspacing;
				if (partyspacing < 0) then
					horizontalspacing = partyspacing - 195;
				else
					horizontalspacing = partyspacing + 195;
				end
				Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", horizontalspacing, 0);
				Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", horizontalspacing, 0);
				Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", horizontalspacing, 0);
			end
		else
			getglobal(this:GetName().."_StatsFrame_PetHealthBar"):Hide();
			getglobal(this:GetName().."_StatsFrame_PetHealthBarBG"):Hide();
			getglobal(this:GetName().."_StatsFrame"):SetHeight(42);

			if (verticalalign == 1) then
				if (id == 1) then
					Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", 0, partyspacing);
				elseif (id == 2) then
					Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", 0, partyspacing);
				elseif (id == 3) then
					Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", 0, partyspacing);
				end
			else
				local horizontalspacing;
				if (partyspacing < 0) then
					horizontalspacing = partyspacing - 195;
				else
					horizontalspacing = partyspacing + 195;
				end
				Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", horizontalspacing, 0);
				Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", horizontalspacing, 0);
				Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", horizontalspacing, 0);
			end
		end
	else
		getglobal(this:GetName().."_StatsFrame_PetHealthBar"):Hide();
		getglobal(this:GetName().."_StatsFrame_PetHealthBarBG"):Hide();
		getglobal(this:GetName().."_StatsFrame"):SetHeight(42);
		
		if (verticalalign == 1) then
			if (id == 1) then
				Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", 0, partyspacing);
			elseif (id == 2) then
				Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", 0, partyspacing);
			elseif (id == 3) then
				Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", 0, partyspacing);
			end
		else
			local horizontalspacing;
			if (partyspacing < 0) then
				horizontalspacing = partyspacing - 195;
			else
				horizontalspacing = partyspacing + 195;
			end
			Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", horizontalspacing, 0);
			Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", horizontalspacing, 0);
			Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", horizontalspacing, 0);
		end
	end
end

function Perl_Party_Update_Pet_Health()
	local id = this:GetID();

	if (UnitIsConnected("party"..id) and UnitExists("partypet"..id)) then
		local partypethealth = UnitHealth("partypet"..id);
		local partypethealthmax = UnitHealthMax("partypet"..id);
		local partypethealthpercent = floor(partypethealth/partypethealthmax*100+0.5);

		if (UnitIsDead("partypet"..id)) then				-- This prevents negative health
			partypethealth = 0;
			partypethealthpercent = 0;
		end

		getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetMinMaxValues(0, partypethealthmax);
		getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetValue(partypethealth);

		if (colorhealth == 1) then
			if ((partypethealthpercent <= 100) and (partypethealthpercent > 75)) then
				getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(0, 0.8, 0);
			elseif ((partypethealthpercent <= 75) and (partypethealthpercent > 50)) then
				getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 1, 0);
			elseif ((partypethealthpercent <= 50) and (partypethealthpercent > 25)) then
				getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 0.5, 0);
			else
				getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 0, 0);
			end
		else
			getglobal(this:GetName().."_StatsFrame_PetHealthBar"):SetStatusBarColor(0, 0.8, 0);
		end

		if (compactmode == 0) then
			if (healermode == 1) then
				getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-"..partypethealthmax - partypethealth);
				if (tonumber(mouseoverpethealthflag) == tonumber(id)) then
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
				else
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
				end
			else
				getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText(partypethealth.."/"..partypethealthmax);
				getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealthpercent.."%");
			end
		else
			if (healermode == 1) then
				getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-"..partypethealthmax - partypethealth);
				if (tonumber(mouseoverpethealthflag) == tonumber(id)) then
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
				else
					getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
				end
			else
				getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText();
				getglobal(this:GetName().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
			end
		end

	else
		-- do nothing, should be hidden
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

	-- Set Class Icon
	if (UnitIsPlayer(partyid)) then
		local PlayerClass = UnitClass(partyid);
		getglobal(this:GetName().."_LevelFrame_ClassTexture"):SetTexCoord(Perl_Party_ClassPosRight[PlayerClass], Perl_Party_ClassPosLeft[PlayerClass], Perl_Party_ClassPosTop[PlayerClass], Perl_Party_ClassPosBottom[PlayerClass]); -- Set the player's class icon
		getglobal(this:GetName().."_LevelFrame_ClassTexture"):Show();
	else
		getglobal(this:GetName().."_LevelFrame_ClassTexture"):Hide();
	end
end

function Perl_Party_Update_PvP_Status()
	local partyid = "party"..this:GetID();
	local factionGroup = UnitFactionGroup(partyid);
	if (factionGroup == nil) then
		factionGroup = UnitFactionGroup("player");
	end
	-- Color their name if PvP flagged
	if (UnitIsPVP(partyid)) then
		getglobal(this:GetName().."_NameFrame_NameBarText"):SetTextColor(0,1,0);
		getglobal(this:GetName().."_NameFrame_PVPStatus"):SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		getglobal(this:GetName().."_NameFrame_PVPStatus"):Show();
	else
		getglobal(this:GetName().."_NameFrame_NameBarText"):SetTextColor(0.5,0.5,1);
		getglobal(this:GetName().."_NameFrame_PVPStatus"):Hide();
	end
end

function Perl_Party_Update_Level()
	local partyid = "party"..this:GetID();
	local partylevel = UnitLevel(partyid);
	-- Set Level
	getglobal(this:GetName().."_LevelFrame_LevelBarText"):SetText(partylevel);
end

function Perl_Party_Update_Leader()
	local id = this:GetID();
	local icon = getglobal(this:GetName().."_NameFrame_LeaderIcon");
	if (GetPartyLeaderIndex() == id) then
		icon:Show();
	else
		icon:Hide();
	end
end

function Perl_Party_Update_Loot_Method()
	local lootMethod, lootMaster;
	lootMethod, lootMaster = GetLootMethod();
	if (this:GetID() == lootMaster) then
		getglobal(this:GetName().."_NameFrame_MasterIcon"):Show();
	else
		getglobal(this:GetName().."_NameFrame_MasterIcon"):Hide();
	end
end

function Perl_Party_Check_Raid_Hidden()
	if (partyhidden == 2) then
		Perl_Party_MemberFrame1:Hide();
		Perl_Party_MemberFrame2:Hide();
		Perl_Party_MemberFrame3:Hide();
		Perl_Party_MemberFrame4:Hide();
	end
end

function Perl_Party_Set_Text_Positions()
	if (compactmode == 0) then
		for partynum=1,4 do
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", 70, 0);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOP", 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", 70, 0);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOP", 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", 70, 0);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOP", 0, 1);
		end
	else
		if (healermode == 1) then
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", -10, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOP", -40, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", -10, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOP", -40, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", -10, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOP", -40, 1);
			end
		else
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", 70, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOP", 0, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", 70, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOP", 0, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", 70, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOP", 0, 1);
			end
		end
	end
end

function Perl_Party_HealthShow()
	if (healermode == 1) then
		local id = this:GetID();
		if (id == 0) then
			local name=this:GetName();
			id = string.sub(name, 23, 23);
		end
		local partyid = "party"..id;
		local partyhealth = UnitHealth(partyid);
		local partyhealthmax = UnitHealthMax(partyid);

		if (UnitIsDead(partyid)) then				-- This prevents negative health
			partyhealth = 0;
		end

		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
		mouseoverhealthflag = id;
	end
end

function Perl_Party_HealthHide()
	if (healermode == 1) then
		local id = this:GetID();
		if (id == 0) then
			local name=this:GetName();
			id = string.sub(name, 23, 23);
		end
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
		mouseoverhealthflag = 0;
	end
end

function Perl_Party_ManaShow()
	if (healermode == 1) then
		local id = this:GetID();
		if (id == 0) then
			local name=this:GetName();
			id = string.sub(name, 23, 23);
		end
		local partyid = "party"..id;
		local partymana = UnitMana(partyid);
		local partymanamax = UnitManaMax(partyid);

		if (UnitIsDead(partyid)) then				-- This prevents negative mana
			partymana = 0;
		end

		if (UnitPowerType(partyid) == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
		end
		mouseovermanaflag = id;
	end
end

function Perl_Party_ManaHide()
	if (healermode == 1) then
		local id = this:GetID();
		if (id == 0) then
			local name=this:GetName();
			id = string.sub(name, 23, 23);
		end
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
		mouseovermanaflag = 0;
	end
end

function Perl_Party_Pet_HealthShow()
	if (healermode == 1) then
		local id = this:GetID();
		if (id == 0) then
			local name=this:GetName();
			id = string.sub(name, 23, 23);
		end
		local partyid = "partypet"..id;
		local partypethealth = UnitHealth(partyid);
		local partypethealthmax = UnitHealthMax(partyid);

		if (UnitIsDead(partyid)) then				-- This prevents negative health
			partypethealth = 0;
		end

		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
		mouseoverpethealthflag = id;
	end
end

function Perl_Party_Pet_HealthHide()
	if (healermode == 1) then
		local id = this:GetID();
		if (id == 0) then
			local name=this:GetName();
			id = string.sub(name, 23, 23);
		end
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
		mouseoverpethealthflag = 0;
	end
end

function Perl_Party_Update_Health_Mana()
	local partyhealth, partyhealthmax, partyhealthpercent, partymana, partymanamax, partymanapercent, partypethealth, partypethealthmax, partypethealthpercent;

	for partynum=1,4 do
		local partyid = "party"..partynum;
		if (UnitName(partyid) ~= nil) then
			partyhealth = UnitHealth(partyid);
			partyhealthmax = UnitHealthMax(partyid);
			partyhealthpercent = floor(partyhealth/partyhealthmax*100+0.5);
			partymana = UnitMana(partyid);
			partymanamax = UnitManaMax(partyid);
			partymanapercent = floor(partymana/partymanamax*100+0.5);
			partypethealth = UnitHealth("partypet"..partynum);
			partypethealthmax = UnitHealthMax("partypet"..partynum);
			partypethealthpercent = floor(partypethealth/partypethealthmax*100+0.5);

			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar"):SetMinMaxValues(0, partyhealthmax);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar"):SetValue(partyhealth);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar"):SetMinMaxValues(0, partymanamax);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar"):SetValue(partymana);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar"):SetMinMaxValues(0, partypethealthmax);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar"):SetValue(partypethealth);

			if (compactmode == 0) then
				if (healermode == 1) then
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetText("-"..partyhealthmax - partyhealth);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-"..partypethealthmax - partypethealth);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
				else
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetText(partyhealth.."/"..partyhealthmax);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealthpercent.."%");
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetText(partymana.."/"..partymanamax);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymanapercent.."%");
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText(partypethealth.."/"..partypethealthmax);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealthpercent.."%");
				end
			else
				if (healermode == 1) then
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetText("-"..partyhealthmax - partyhealth);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-"..partypethealthmax - partypethealth);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
				else
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
				end
			end
		else
			-- Do nothing since it's hidden anyway
		end
	end
end

function Perl_Party_Set_Localized_ClassIcons()
	local ppty_translate_druid;
	local ppty_translate_hunter;
	local ppty_translate_mage;
	local ppty_translate_paladin;
	local ppty_translate_priest;
	local ppty_translate_rogue;
	local ppty_translate_shaman;
	local ppty_translate_warlock;
	local ppty_translate_warrior;

	local localization = Perl_Config_Get_Localization();

	ppty_translate_druid = localization["druid"];
	ppty_translate_hunter = localization["hunter"];
	ppty_translate_mage = localization["mage"];
	ppty_translate_paladin = localization["paladin"];
	ppty_translate_priest = localization["priest"];
	ppty_translate_rogue = localization["rogue"];
	ppty_translate_shaman = localization["shaman"];
	ppty_translate_warlock = localization["warlock"];
	ppty_translate_warrior = localization["warrior"];

	Perl_Party_ClassPosRight = {
		[ppty_translate_druid] = 0.75,
		[ppty_translate_hunter] = 0,
		[ppty_translate_mage] = 0.25,
		[ppty_translate_paladin] = 0,
		[ppty_translate_priest] = 0.5,
		[ppty_translate_rogue] = 0.5,
		[ppty_translate_shaman] = 0.25,
		[ppty_translate_warlock] = 0.75,
		[ppty_translate_warrior] = 0,
	};
	Perl_Party_ClassPosLeft = {
		[ppty_translate_druid] = 1,
		[ppty_translate_hunter] = 0.25,
		[ppty_translate_mage] = 0.5,
		[ppty_translate_paladin] = 0.25,
		[ppty_translate_priest] = 0.75,
		[ppty_translate_rogue] = 0.75,
		[ppty_translate_shaman] = 0.5,
		[ppty_translate_warlock] = 1,
		[ppty_translate_warrior] = 0.25,
	};
	Perl_Party_ClassPosTop = {
		[ppty_translate_druid] = 0,
		[ppty_translate_hunter] = 0.25,
		[ppty_translate_mage] = 0,
		[ppty_translate_paladin] = 0.5,
		[ppty_translate_priest] = 0.25,
		[ppty_translate_rogue] = 0,
		[ppty_translate_shaman] = 0.25,
		[ppty_translate_warlock] = 0.25,
		[ppty_translate_warrior] = 0,
		
	};
	Perl_Party_ClassPosBottom = {
		[ppty_translate_druid] = 0.25,
		[ppty_translate_hunter] = 0.5,
		[ppty_translate_mage] = 0.25,
		[ppty_translate_paladin] = 0.75,
		[ppty_translate_priest] = 0.5,
		[ppty_translate_rogue] = 0.25,
		[ppty_translate_shaman] = 0.5,
		[ppty_translate_warlock] = 0.5,
		[ppty_translate_warrior] = 0.25,
	};
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Party_Set_Space(number)
	if (number ~= nil) then
		partyspacing = -number;
	end

	if (verticalalign == 1) then

		Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", 0, partyspacing);
		Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", 0, partyspacing);
		Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", 0, partyspacing);

		if (showpets == 1) then
			local partypetspacing = partyspacing - 12;
			for partynum=1,4 do
				local partyid = "party"..partynum;
				local frame = getglobal("Perl_Party_MemberFrame"..partynum);
				if (UnitName(partyid) ~= nil) then
					if (UnitIsConnected(partyid) and UnitExists("partypet"..partynum)) then
						if (partynum == 1) then
							Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", 0, partypetspacing);
						elseif (partynum == 2) then
							Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", 0, partypetspacing);
						elseif (partynum == 3) then
							Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", 0, partypetspacing);
						end
					end
				else
					-- should be hidden, and will correctly adjust later when needed
				end
			end
		else
			-- do nothing, no spacing required
		end

	else
		local horizontalspacing;
		if (partyspacing < 0) then
			horizontalspacing = partyspacing - 195;
		else
			horizontalspacing = partyspacing + 195;
		end
		Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", horizontalspacing, 0);
		Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", horizontalspacing, 0);
		Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", horizontalspacing, 0);
	end

	Perl_Party_UpdateVars();
end

function Perl_Target_Set_Hidden(newvalue)
	if (newvalue ~= nil) then
		partyhidden = newvalue;
		Perl_Party_UpdateVars();
	end

	if (partyhidden == 1) then		-- copied from below sort of, delete below when slash commands are removed
		Perl_Party_MemberFrame1:Hide();
		Perl_Party_MemberFrame2:Hide();
		Perl_Party_MemberFrame3:Hide();
		Perl_Party_MemberFrame4:Hide();
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffAlways Hidden|cffffff00.");
	elseif (partyhidden == 2) then
		if (UnitInRaid("player")) then
			Perl_Party_MemberFrame1:Hide();
			Perl_Party_MemberFrame2:Hide();
			Perl_Party_MemberFrame3:Hide();
			Perl_Party_MemberFrame4:Hide();
		else
			for partynum=1,4 do
				local partyid = "party"..partynum;
				local frame = getglobal("Perl_Party_MemberFrame"..partynum);
				if (UnitName(partyid) ~= nil) then
					frame:Show();
				else
					frame:Hide();
				end
			end
		end
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffHidden in Raids|cffffff00.");
	else
		for partynum=1,4 do
			local partyid = "party"..partynum;
			local frame = getglobal("Perl_Party_MemberFrame"..partynum);
			if (UnitName(partyid) ~= nil) then
				frame:Show();
			else
				frame:Hide();
			end
		end
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffAlways Shown|cffffff00.");
	end
end

function Perl_Party_Set_Compact(newvalue)
	compactmode = newvalue;
	Perl_Party_UpdateVars();

	Perl_Party_Set_Text_Positions();	-- copied from below sort of, delete below when slash commands are removed
	if (compactmode == 1) then
		Perl_Party_MemberFrame1_StatsFrame:SetWidth(170);
		Perl_Party_MemberFrame2_StatsFrame:SetWidth(170);
		Perl_Party_MemberFrame3_StatsFrame:SetWidth(170);
		Perl_Party_MemberFrame4_StatsFrame:SetWidth(170);
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now displaying in |cffffffffCompact Mode|cffffff00.");
	else
		Perl_Party_MemberFrame1_StatsFrame:SetWidth(240);
		Perl_Party_MemberFrame2_StatsFrame:SetWidth(240);
		Perl_Party_MemberFrame3_StatsFrame:SetWidth(240);
		Perl_Party_MemberFrame4_StatsFrame:SetWidth(240);
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now displaying in |cffffffffNormal Mode|cffffff00.");
	end
	Perl_Party_Set_Text_Positions();
	Perl_Party_Update_Health_Mana();
	Perl_Party_Update_Buffs();
end

function Perl_Party_Set_Healer(newvalue)
	healermode = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Text_Positions();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Pets(newvalue)
	showpets = newvalue;
	Perl_Party_UpdateVars();

	if (showpets == 0) then			-- copied from below sort of, delete below when slash commands are removed
		Perl_Party_MemberFrame1_StatsFrame_PetHealthBar:Hide();
		Perl_Party_MemberFrame1_StatsFrame_PetHealthBarBG:Hide();
		Perl_Party_MemberFrame1_StatsFrame:SetHeight(42);
		Perl_Party_MemberFrame2_StatsFrame_PetHealthBar:Hide();
		Perl_Party_MemberFrame2_StatsFrame_PetHealthBarBG:Hide();
		Perl_Party_MemberFrame2_StatsFrame:SetHeight(42);
		Perl_Party_MemberFrame3_StatsFrame_PetHealthBar:Hide();
		Perl_Party_MemberFrame3_StatsFrame_PetHealthBarBG:Hide();
		Perl_Party_MemberFrame3_StatsFrame:SetHeight(42);
		Perl_Party_MemberFrame4_StatsFrame_PetHealthBar:Hide();
		Perl_Party_MemberFrame4_StatsFrame_PetHealthBarBG:Hide();
		Perl_Party_MemberFrame4_StatsFrame:SetHeight(42);
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffHiding Pets|cffffff00.");
	else
		local partypethealth, partypethealthmax, partypethealthpercent;
		for partynum=1,4 do
			local partyid = "party"..partynum;
			local frame = getglobal("Perl_Party_MemberFrame"..partynum);
			if (UnitName(partyid) ~= nil) then
				if (UnitIsConnected(partyid) and UnitExists("partypet"..partynum)) then
					partypethealth = UnitHealth("partypet"..partynum);
					partypethealthmax = UnitHealthMax("partypet"..partynum);
					partypethealthpercent = floor(partypethealth/partypethealthmax*100+0.5);

					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar"):Show();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBarBG"):Show();
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetHeight(54);

					if (partynum == 1 or partynum == 2 or partynum == 3) then
						local partynumspace = partynum + 1;
						local partypetspacing = partyspacing - 12;
						getglobal("Perl_Party_MemberFrame"..partynumspace):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..partynum, "TOPLEFT", 0, partypetspacing);
					end

					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar"):SetMinMaxValues(0, partypethealthmax);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar"):SetValue(partypethealth);

					if (compactmode == 0) then
						getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText(partypethealth.."/"..partypethealthmax);
						getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealthpercent.."%");
					else
						getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText();
						getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
					end
				end
			else
				-- should be hidden, and will correctly adjust later when needed
			end
		end
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Party Frame is now |cffffffffShowing Pets|cffffff00.");
	end
	Perl_Party_Set_Space();
	Perl_Party_Update_Buffs();
end

function Perl_Party_Set_Progressive_Color(newvalue)
	colorhealth = newvalue;
	Perl_Party_UpdateVars();
end

function Perl_Party_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Party_UpdateVars();
end

function Perl_Party_Set_VerticalAlign(newvalue)
	verticalalign = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Space();
end

function Perl_Party_Set_Buff_Location(newvalue)
	if (newvalue ~= nil) then
		bufflocation = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Debuff_Location(newvalue)
	if (newvalue ~= nil) then
		debufflocation = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		scale = (number / 100);
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Party_MemberFrame1:SetScale(unsavedscale);
	Perl_Party_MemberFrame2:SetScale(unsavedscale);
	Perl_Party_MemberFrame3:SetScale(unsavedscale);
	Perl_Party_MemberFrame4:SetScale(unsavedscale);
	Perl_Party_UpdateVars();
end

function Perl_Party_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);
	end
	Perl_Party_MemberFrame1:SetAlpha(transparency);
	Perl_Party_MemberFrame2:SetAlpha(transparency);
	Perl_Party_MemberFrame3:SetAlpha(transparency);
	Perl_Party_MemberFrame4:SetAlpha(transparency);
	Perl_Party_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Party_GetVars()
	locked = Perl_Party_Config[UnitName("player")]["Locked"];
	compactmode = Perl_Party_Config[UnitName("player")]["CompactMode"];
	partyhidden = Perl_Party_Config[UnitName("player")]["PartyHidden"];
	partyspacing = Perl_Party_Config[UnitName("player")]["PartySpacing"];
	scale = Perl_Party_Config[UnitName("player")]["Scale"];
	showpets = Perl_Party_Config[UnitName("player")]["ShowPets"];
	colorhealth = Perl_Party_Config[UnitName("player")]["ColorHealth"];
	healermode = Perl_Party_Config[UnitName("player")]["HealerMode"];
	transparency = Perl_Party_Config[UnitName("player")]["Transparency"];
	bufflocation = Perl_Party_Config[UnitName("player")]["BuffLocation"];
	debufflocation = Perl_Party_Config[UnitName("player")]["DebuffLocation"];
	verticalalign = Perl_Party_Config[UnitName("player")]["VerticalAlign"];

	if (locked == nil) then
		locked = 0;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
	if (partyhidden == nil) then
		partyhidden = 0;
	end
	if (partyspacing == nil) then
		partyspacing = -80;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (showpets == nil) then
		showpets = 1;
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
	if (bufflocation == nil) then
		bufflocation = 4;
	end
	if (debufflocation == nil) then
		debufflocation = 1;
	end
	if (verticalalign == nil) then
		verticalalign = 1;
	end

	local vars = {
		["locked"] = locked,
		["compactmode"] = compactmode,
		["partyhidden"] = partyhidden,
		["partyspacing"] = partyspacing,
		["scale"] = scale,
		["showpets"] = showpets,
		["colorhealth"] = colorhealth,
		["healermode"] = healermode,
		["transparency"] = transparency,
		["bufflocation"] = bufflocation,
		["debufflocation"] = debufflocation,
		["verticalalign"] = verticalalign,
	}
	return vars;
end

function Perl_Party_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["CompactMode"] ~= nil) then
				compactmode = vartable["Global Settings"]["CompactMode"];
			else
				compactmode = nil;
			end
			if (vartable["Global Settings"]["PartyHidden"] ~= nil) then
				partyhidden = vartable["Global Settings"]["PartyHidden"];
			else
				partyhidden = nil;
			end
			if (vartable["Global Settings"]["PartySpacing"] ~= nil) then
				partyspacing = vartable["Global Settings"]["PartySpacing"];
			else
				partyspacing = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["ShowPets"] ~= nil) then
				showpets = vartable["Global Settings"]["ShowPets"];
			else
				showpets = nil;
			end
			if (vartable["Global Settings"]["ColorHealth"] ~= nil) then
				colorhealth = vartable["Global Settings"]["ColorHealth"];
			else
				colorhealth = nil;
			end
			if (vartable["Global Settings"]["HealerMode"] ~= nil) then
				healermode = vartable["Global Settings"]["HealerMode"];
			else
				healermode = nil;
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
			if (vartable["Global Settings"]["VerticalAlign"] ~= nil) then
				verticalalign = vartable["Global Settings"]["VerticalAlign"];
			else
				verticalalign = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (compactmode == nil) then
			compactmode = 0;
		end
		if (partyhidden == nil) then
			partyhidden = 0;
		end
		if (partyspacing == nil) then
			partyspacing = -80;
		end
		if (scale == nil) then
			scale = 1;
		end
		if (showpets == nil) then
			showpets = 1;
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
		if (bufflocation == nil) then
			bufflocation = 4;
		end
		if (debufflocation == nil) then
			debufflocation = 1;
		end
		if (verticalalign == nil) then
			verticalalign = 1;
		end

		-- Call any code we need to activate them
		Perl_Party_Set_Space();				-- This probably isn't needed, but one extra call for this won't matter
		Perl_Target_Set_Hidden(partyhidden);
		Perl_Party_Set_Compact(compactmode);
		Perl_Party_Set_Healer(healermode);
		Perl_Party_Set_Pets(showpets);
		Perl_Party_Reset_Buffs();		-- Reset the buff icons
		Perl_Party_Update_Buffs();		-- Repopulate the buff icons
		Perl_Party_Set_Scale();
		Perl_Party_Set_Transparency();
	end

	Perl_Party_Config[UnitName("player")] = {
		["Locked"] = locked,
		["CompactMode"] = compactmode,
		["PartyHidden"] = partyhidden,
		["PartySpacing"] = partyspacing,
		["Scale"] = scale,
		["ShowPets"] = showpets,
		["ColorHealth"] = colorhealth,
		["HealerMode"] = healermode,
		["Transparency"] = transparency,
		["BuffLocation"] = bufflocation,
		["DebuffLocation"] = debufflocation,
		["VerticalAlign"] = verticalalign,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Party_Buff_UpdateAll(partymember)
	local id, partyid;
	if (partymember == nil) then
		id = this:GetID();
		partyid = "party"..id;
	else
		id = partymember;
		partyid = "party"..id;
	end
	
	if (UnitName(partyid)) then
		for buffnum=1,12 do
			local button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff"..buffnum);
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

		local debuffCount, debuffTexture, debuffApplications;
		for buffnum=1,8 do
			debuffTexture, debuffApplications = UnitDebuff(partyid, buffnum);
			local button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff"..buffnum);
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");

			if (UnitDebuff(partyid, buffnum)) then
				icon:SetTexture(UnitDebuff(partyid, buffnum));
				debuff:Show();
				button:Show();
				debuffCount = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff"..(buffnum).."Count");
				if (debuffApplications > 1) then
					debuffCount:SetText(debuffApplications);
					debuffCount:Show();
				else
					debuffCount:Hide();
				end
			else
				button:Hide();
			end
		end

		Perl_Party_Buff_Position_Update(id, partyid);
	end
end

function Perl_Party_Update_Buffs()
	Perl_Party_Buff_UpdateAll(1);
	Perl_Party_Buff_UpdateAll(2);
	Perl_Party_Buff_UpdateAll(3);
	Perl_Party_Buff_UpdateAll(4);
end

function Perl_Party_Buff_Position_Update(id, partyid)
	if (bufflocation == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 2) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -23);
	elseif (bufflocation == 4) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, 0);
	elseif (bufflocation == 5) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, -20);
	end

	if (debufflocation == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 2) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -23);
	elseif (debufflocation == 4) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, 0);
	elseif (debufflocation == 5) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, -20);
	end
end

function Perl_Party_Reset_Buffs()
	local button;
	for buffnum=1,12 do
		button = getglobal("Perl_Party_MemberFrame1_BuffFrame_Buff"..buffnum)
		button:Hide();
	end
	for buffnum=1,8 do
		button = getglobal("Perl_Party_MemberFrame1_BuffFrame_Debuff"..buffnum)
		button:Hide();
	end
end

function Perl_Party_SetBuffTooltip()
	local partyid = "party"..this:GetParent():GetParent():GetID();
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
	if (this:GetID() > 8) then
		GameTooltip:SetUnitDebuff(partyid, this:GetID()-12);	-- 12 being the number of buffs before debuffs in the xml
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
	if (UIDROPDOWNMENU_OPEN_MENU) then
		dropdown = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	else
		dropdown = this;
	end
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..this:GetID());
end

function Perl_Party_MouseUp(button)
	local id = this:GetID();
	if (id == 0) then
		local name=this:GetName();
		id = string.sub(name, 23, 23);
	end
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("party"..id);
		elseif (CursorHasItem()) then
			DropItemOnUnit("party"..id);
		else
			TargetUnit("party"..id);
		end
	else
		if (this:GetID() == 0) then
			return;
		else
			ToggleDropDownMenu(1, nil, getglobal(this:GetName().."_DropDown"), this:GetName(), 0, 0);
		end
	end

	Perl_Party_Frame:StopMovingOrSizing();
end

function Perl_Party_Pet_MouseUp(button)
	local id = this:GetID();
	if (id == 0) then
		local name=this:GetName();
		id = string.sub(name, 23, 23);
	end
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("partypet"..id);
		elseif (CursorHasItem()) then
			DropItemOnUnit("partypet"..id);
		else
			TargetUnit("partypet"..id);
		end
	end
end

function Perl_Party_MouseDown(button)
	if (button == "LeftButton" and locked == 0 and this:GetID() == 1) then
		Perl_Party_Frame:StartMoving();
	end
end


-------------
-- Tooltip --
-------------
function Perl_Party_Tip()
	UnitFrame_Initialize("party"..this:GetID())
end

function UnitFrame_Initialize(unit)	-- Hopefully this doesn't break any mods
	this.unit = unit;
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Party_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Party_myAddOns_Details = {
			name = "Perl_Party",
			version = "v0.43",
			releaseDate = "February 16, 2006",
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