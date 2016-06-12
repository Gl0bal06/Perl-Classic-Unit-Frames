---------------
-- Variables --
---------------
Perl_Party_Config = {};
local Perl_Party_Events = {};		-- event manager
local Perl_Party_Script_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Party_GetVars)
local locked = 0;		-- unlocked by default
local compactmode = 0;		-- compact mode is disabled by default
local partyhidden = 0;		-- party frame is set to always show by default
local partyspacing = -90;	-- default spacing between party member frames
local scale = 1;		-- default scale
local showpets = 1;		-- show pets by default
local healermode = 0;		-- nurfed unit frame style
local transparency = 1.0;	-- transparency for frames
local bufflocation = 6;		-- default buff location
local debufflocation = 3;	-- default debuff location
local verticalalign = 1;	-- default alignment is vertically
local compactpercent = 0;	-- percents are not shown in compact mode by default
local showportrait = 0;		-- portrait is hidden by default
local showfkeys = 1;		-- show appropriate F key in the name frame by default
local displaycastablebuffs = 0;	-- display all buffs by default
local threedportrait = 0;	-- 3d portraits are off by default
local buffsize = 16;		-- default buff size is 16
local debuffsize = 16;		-- default debuff size is 16
local numbuffsshown = 16;	-- buff row is 16 long
local numdebuffsshown = 16;	-- debuff row is 16 long
local classcolorednames = 0;	-- names are colored based on pvp status by default
local shortbars = 0;		-- Health/Power/Experience bars are all normal length
local hideclasslevelframe = 0;	-- Showing the class icon and level frame by default
local showmanadeficit = 0;	-- Mana deficit in healer mode is off by default
local showpvpicon = 1;		-- show the pvp icon
local showbarvalues = 0;	-- healer mode will have the bar values hidden by default

-- Default Local Variables
local Initialized = nil;	-- waiting to be initialized
local mouseoverhealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovermanaflag = 0;	-- is the mouse over the mana bar for healer mode?
local mouseoverpethealthflag = 0;	-- is the mouse over the pet health bar for healer mode?

-- Fade Bar Variables
local Perl_Party_One_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_One_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Two_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Two_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Three_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Three_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Four_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Four_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_One_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_One_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Two_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Two_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Three_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Three_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Four_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Four_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_One_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Two_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Three_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Four_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0

-- Local variables to save memory
local partyhealth, partyhealthmax, partyhealthpercent, partymana, partymanamax, partymanapercent, partypethealth, partypethealthmax, partypethealthpercent, englishclass;


----------------------
-- Loading Function --
----------------------
function Perl_Party_Script_OnLoad()
	-- Events
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("RAID_ROSTER_UPDATE");

	-- Scripts
	this:SetScript("OnEvent", Perl_Party_Script_OnEvent);
end

function Perl_Party_OnLoad()
	-- Events
	this:RegisterEvent("PARTY_LEADER_CHANGED");
	this:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("PLAYER_ALIVE");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_FACTION");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_MAXENERGY");
	this:RegisterEvent("UNIT_MAXHEALTH");
	this:RegisterEvent("UNIT_MAXMANA");
	this:RegisterEvent("UNIT_MAXRAGE");
	this:RegisterEvent("UNIT_MODEL_CHANGED");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_PET");
	this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	this:RegisterEvent("UNIT_PVP_UPDATE");
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Scripts
	this:SetScript("OnEvent", Perl_Party_OnEvent);

	-- Forcefully Hide Blizzard Party Frame
	--HidePartyFrame();
	--ShowPartyFrame = HidePartyFrame;	-- This is to fix the annoyance 1.9 introduced

	-- WoW 2.0 Secure API Stuff
	this:SetAttribute("unit", "party"..this:GetID());
	RegisterUnitWatch(this);
end


-------------------
-- Event Handler --
-------------------
function Perl_Party_Script_OnEvent()
	local func = Perl_Party_Script_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Party: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Party_Script_Events:PLAYER_ENTERING_WORLD()
	if (Initialized) then
		Perl_Party_Check_Hidden();	-- Are we running a hidden mode?
	end
end

function Perl_Party_Script_Events:RAID_ROSTER_UPDATE()
	Perl_Party_Check_Hidden();
end


function Perl_Party_OnEvent()
	local func = Perl_Party_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Party: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Party_Events:UNIT_HEALTH()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_Health();
	elseif (showpets == 1) then
		if ((arg1 == "partypet1") or (arg1 == "partypet2") or (arg1 == "partypet3") or (arg1 == "partypet4")) then
			Perl_Party_Update_Pet_Health();
		end
	end
end
Perl_Party_Events.UNIT_MAXHEALTH = Perl_Party_Events.UNIT_HEALTH;

function Perl_Party_Events:UNIT_ENERGY()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_Mana();
	end
end
Perl_Party_Events.UNIT_MAXENERGY = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MANA = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MAXMANA = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_RAGE = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MAXRAGE = Perl_Party_Events.UNIT_ENERGY;

function Perl_Party_Events:UNIT_AURA()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Buff_UpdateAll();
	end
end

function Perl_Party_Events:UNIT_DISPLAYPOWER()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_Mana_Bar();		-- What type of energy are we using now?
		Perl_Party_Update_Mana();		-- Update the power info immediately
	end
end

function Perl_Party_Events:UNIT_FACTION()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_PvP_Status();		-- Is the character PvP flagged?
	end
end
Perl_Party_Events.UNIT_PVP_UPDATE = Perl_Party_Events.UNIT_FACTION;

function Perl_Party_Events:UNIT_NAME_UPDATE()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Set_Name();			-- Set the player's name and class icon
	end
end

function Perl_Party_Events:UNIT_PET()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_Pet();		-- Set the player's level
	end
end

function Perl_Party_Events:UNIT_LEVEL()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_Level();		-- Set the player's level
	end
end

function Perl_Party_Events:PARTY_MEMBERS_CHANGED()
	Perl_Party_MembersUpdate();			-- How many members are in the group and show the correct frames and do UpdateOnce things
end

function Perl_Party_Events:PARTY_LEADER_CHANGED()
	Perl_Party_Update_Leader();			-- Who is the group leader
end

function Perl_Party_Events:UNIT_PORTRAIT_UPDATE()
	if ((arg1 == "party1") or (arg1 == "party2") or (arg1 == "party3") or (arg1 == "party4")) then
		Perl_Party_Update_Portrait();
	end
end
Perl_Party_Events.UNIT_MODEL_CHANGED = Perl_Party_Events.UNIT_PORTRAIT_UPDATE;

function Perl_Party_Events:PARTY_LOOT_METHOD_CHANGED()
	Perl_Party_Update_Loot_Method();		-- Who is the master looter if any
end

function Perl_Party_Events:PLAYER_ALIVE()
	Perl_Party_Check_Hidden();			-- Are we running a hidden mode? (Hopefully the last check we need to add for this)
end

function Perl_Party_Events:VARIABLES_LOADED()
	Perl_Party_Initialize();			-- We also force update info here in case of a /console reloadui
end
Perl_Party_Events.PLAYER_ENTERING_WORLD = Perl_Party_Events.VARIABLES_LOADED;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Party_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Party_Set_Scale_Actual();		-- Set the frame scale
		Perl_Party_Set_Transparency();		-- Set the frame transparency
		Perl_Party_Force_Update()		-- Attempt to forcefully update information
		Perl_Party_Set_Pets();			-- Also not called
		Perl_Party_Update_Health_Mana();	-- You know the drill
		Perl_Party_Check_Hidden();		-- Are we running a hidden mode?
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Party_Config[UnitName("player")]) == "table") then
		Perl_Party_GetVars();
	else
		Perl_Party_UpdateVars();
	end

	-- Major config options.
	Perl_Party_Initialize_Frame_Color();		-- Color the frame borders
	Perl_Party_Frame_Style();

	-- Unregister and Hide the Blizzard frames
	Perl_clearBlizzardFrameDisable(PartyMemberFrame1);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame1PetFrame);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame2);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame2PetFrame);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame3);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame3PetFrame);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame4);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame4PetFrame);

	hooksecurefunc("ShowPartyFrame",		-- Thanks Zek
		function()
			if (not InCombatLockdown()) then
				for i = 1,4 do
					getglobal("PartyMemberFrame"..i):Hide();
				end
			end
		end
	);

	-- Set the ID of the frame
	for num = 1, 4 do
		getglobal("Perl_Party_MemberFrame"..num.."_NameFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_MemberFrame"..num.."_PortraitFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetID(num);
	end

	-- Button Click Overlays (in order of occurrence in XML)
	for num = 1, 4 do
		getglobal("Perl_Party_MemberFrame"..num.."_NameFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..num.."_PortraitFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_PortraitFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):GetFrameLevel() - 1);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):GetFrameLevel() - 1);
		getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):GetFrameLevel() - 1);
	end

	-- MyAddOns Support
	Perl_Party_myAddOns_Support();

	-- IFrameManager Support
	if (IFrameManager) then
		Perl_Party_IFrameManager();
	end

	Initialized = 1;
	Perl_Party_MembersUpdate();
end

function Perl_Party_IFrameManager()
	local iface = IFrameManager:Interface();
	function iface:getName(frame)
		return "Perl Party";
	end
	function iface:getBorder(frame)
		local bottom, left, right, top;
		if (verticalalign == 1) then
			if (partyspacing < 0) then
				if (showpets == 0) then
					bottom = -3 * partyspacing + 25;
					top = -5;
				else
					bottom = (-3 * partyspacing) + 25 + (4 * 12);
					top = -5;
				end
			else
				if (showpets == 0) then
					top = 3 * partyspacing - 5;
					bottom = 25;
				else
					top = (3 * partyspacing) - 5 + (3 * 12);
					bottom = 37;
				end
			end
			if (showportrait == 1) then
				left = 55;
			else
				left = 0;
			end
			if (compactmode == 0) then
				right = 70;
			else
				if (compactpercent == 0) then
					if (shortbars == 0) then
						right = 0;
					else
						right = -35;
					end
				else
					if (shortbars == 0) then
						right = 35;
					else
						right = 0;
					end
				end
			end
			local buffflag;
			if (bufflocation == 4 or debufflocation == 4) then
				bottom = bottom + 16;
				buffflag = 1;
			end
			if (bufflocation == 5 or debufflocation == 5) then
				if (buffflag == 1) then
					bottom = bottom + 16;
				else
					bottom = bottom + 36;
				end
			end
			-- Offsets since the party frame is weird
			left = left - 5;
			right = right - 20;
		else
			if (partyspacing < 0) then
				left = 3 * (-(partyspacing) + 195);
				if (compactmode == 0) then
					right = 70;
				else
					if (compactpercent == 0) then
						if (shortbars == 0) then
							right = 0;
						else
							right = -35;
						end
					else
						if (shortbars == 0) then
							right = 35;
						else
							right = 0;
						end
					end
				end
			else
				left = 0;
				right = 3 * (partyspacing + 195);
				if (compactmode == 0) then
					right = right + 70;
				else
					if (compactpercent == 0) then
						if (shortbars == 0) then
							right = right + 0;
						else
							right = right - 35;
						end
					else
						if (shortbars == 0) then
							right = right + 35;
						else
							right = right + 0;
						end
					end
				end
			end
			if (showportrait == 1) then
				left = left + 55;
			end
			if (showpets == 0) then
				bottom = 25;
			else
				bottom = 37;
			end
			local buffflag;
			if (bufflocation == 4 or debufflocation == 4) then
				bottom = bottom + 16;
				buffflag = 1;
			end
			if (bufflocation == 5 or debufflocation == 5) then
				if (buffflag == 1) then
					bottom = bottom + 16;
				else
					bottom = bottom + 36;
				end
			end
			-- Offsets since the party frame is weird
			left = left - 5;
			right = right - 20;
			top = -5;
		end
		return top, right, bottom, left;
	end
	IFrameManager:Register(Perl_Party_Frame, iface);
end

function Perl_Party_Initialize_Frame_Color(flag)
	if (flag == nil) then
		getglobal(this:GetName().."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal(this:GetName().."_LevelFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal(this:GetName().."_PortraitFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_PortraitFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal(this:GetName().."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal(this:GetName().."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	else
		for partynum=1,4 do
			getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		end
	end
end


----------------------
-- Update Functions --
----------------------
function Perl_Party_MembersUpdate()
	Perl_Party_Set_Name();
	Perl_Party_Update_PvP_Status();
	Perl_Party_Update_Level();
	Perl_Party_Update_Health();
	Perl_Party_Update_Mana();
	Perl_Party_Update_Mana_Bar();
	Perl_Party_Update_Pet_Health();
	Perl_Party_Update_Leader();
	Perl_Party_Update_Loot_Method();
	Perl_Party_Update_Portrait();
	Perl_Party_Buff_UpdateAll();
	Perl_Party_Buff_Position_Update();
end

function Perl_Party_Update_Health(id)
	if (id == nil) then
		id = this:GetID()
	end
	local partyid = "party"..id;

	partyhealth = UnitHealth(partyid);
	partyhealthmax = UnitHealthMax(partyid);
	partyhealthpercent = floor(partyhealth/partyhealthmax*100+0.5);

	if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then				-- This prevents negative health
		partyhealth = 0;
		partyhealthpercent = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (partyhealth < getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):GetValue()) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBarFadeBar"):SetMinMaxValues(0, partyhealthmax);
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBarFadeBar"):SetValue(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):GetValue());
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBarFadeBar"):Show();
			if (id == 1) then						-- This makes the bars fade much smoother when lots of change is happening to a given bar
				Perl_Party_One_HealthBar_Fade_Color = 1;
				Perl_Party_One_HealthBar_Fade_Time_Elapsed = 0;
			elseif (id == 2) then
				Perl_Party_Two_HealthBar_Fade_Color = 1;
				Perl_Party_Two_HealthBar_Fade_Time_Elapsed = 0;
			elseif (id == 3) then
				Perl_Party_Three_HealthBar_Fade_Color = 1;
				Perl_Party_Three_HealthBar_Fade_Time_Elapsed = 0;
			elseif (id == 4) then
				Perl_Party_Four_HealthBar_Fade_Color = 1;
				Perl_Party_Four_HealthBar_Fade_Time_Elapsed = 0;
			end
			getglobal("Perl_Party_"..id.."_HealthBar_Fade_OnUpdate_Frame"):Show();
		end
	end

	getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):SetMinMaxValues(0, partyhealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):SetValue(partyhealthmax - partyhealth);
	else
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):SetValue(partyhealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((partyhealthpercent <= 100) and (partyhealthpercent > 75)) then
--			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(0, 0.8, 0);
--			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((partyhealthpercent <= 75) and (partyhealthpercent > 50)) then
--			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(1, 1, 0);
--			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((partyhealthpercent <= 50) and (partyhealthpercent > 25)) then
--			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(1, 0.5, 0);
--			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			getglobal(this:GetName().."_StatsFrame_HealthBar"):SetStatusBarColor(1, 0, 0);
--			getglobal(this:GetName().."_StatsFrame_HealthBarBG"):SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = partyhealth / partyhealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):SetStatusBarColor(red, green, 0, 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBarBG"):SetStatusBarColor(red, green, 0, 0.25);
	else
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):SetStatusBarColor(0, 0.8, 0);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (compactmode == 0) then
		if (healermode == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText("-"..partyhealthmax - partyhealth);
			if (showbarvalues == 0) then
				if (tonumber(mouseoverhealthflag) == tonumber(id)) then
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
				end
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
			end
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText(partyhealth.."/"..partyhealthmax);
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealthpercent.."%");
		end
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextCompactPercent"):SetText();						-- Hide the compact mode percent text in full mode
	else
		if (healermode == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText("-"..partyhealthmax - partyhealth);
			if (showbarvalues == 0) then
				if (tonumber(mouseoverhealthflag) == tonumber(id)) then
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
				end
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
			end
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText();
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
		end

		if (compactpercent == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextCompactPercent"):SetText(partyhealthpercent.."%");
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextCompactPercent"):SetText();
		end
	end

	-- Handle death state
	if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_DeadStatus"):Show();
		if (UnitClass(partyid) == PERL_LOCALIZED_HUNTER) then	-- If the dead is a hunter, check for Feign Death
			local buffnum = 1;
			local currentlyfd = 0;
			local _, _, buffTexture = UnitBuff(partyid, buffnum);
			while (buffTexture) do
				if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
					if (compactmode == 0) then
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
					else
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
					end
					currentlyfd = 1;
					break;
				end
				buffnum = buffnum + 1;
				_, _, buffTexture = UnitBuff(partyid, buffnum);
			end
			if (currentlyfd == 0) then				-- If the hunter is not Feign Death, then lol
				if (compactmode == 0) then
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText(PERL_LOCALIZED_STATUS_DEAD);
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_DEAD);
				end
			end
		else								-- If the dead is not a hunter, well...
			if (compactmode == 0) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText(PERL_LOCALIZED_STATUS_DEAD);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_DEAD);
			end
		end
	else
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_DeadStatus"):Hide();
	end

	-- Handle disconnected state
	if (UnitIsConnected(partyid)) then
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_DisconnectStatus"):Hide();
	else
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_DisconnectStatus"):Show();
		if (compactmode == 0) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText(PERL_LOCALIZED_STATUS_OFFLINE);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_OFFLINE);
		end
	end
end

function Perl_Party_Update_Mana(id)
	if (id == nil) then
		id = this:GetID()
	end
	local partyid = "party"..id;

	partymana = UnitMana(partyid);
	partymanamax = UnitManaMax(partyid);
	partymanapercent = floor(partymana/partymanamax*100+0.5);

	if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then				-- This prevents negative mana
		partymana = 0;
		partymanapercent = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (partymana < getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):GetValue()) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarFadeBar"):SetMinMaxValues(0, partymanamax);
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarFadeBar"):SetValue(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):GetValue());
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarFadeBar"):Show();
			if (id == 1) then						-- This makes the bars fade much smoother when lots of change is happening to a given bar
				Perl_Party_One_ManaBar_Fade_Color = 1;
				Perl_Party_One_ManaBar_Fade_Time_Elapsed = 0;
			elseif (id == 2) then
				Perl_Party_Two_ManaBar_Fade_Color = 1;
				Perl_Party_Two_ManaBar_Fade_Time_Elapsed = 0;
			elseif (id == 3) then
				Perl_Party_Three_ManaBar_Fade_Color = 1;
				Perl_Party_Three_ManaBar_Fade_Time_Elapsed = 0;
			elseif (id == 4) then
				Perl_Party_Four_ManaBar_Fade_Color = 1;
				Perl_Party_Four_ManaBar_Fade_Time_Elapsed = 0;
			end
			getglobal("Perl_Party_"..id.."_ManaBar_Fade_OnUpdate_Frame"):Show();
		end
	end

	getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):SetMinMaxValues(0, partymanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):SetValue(partymanamax - partymana);
	else
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):SetValue(partymana);
	end

	if (compactmode == 0) then
		if (healermode == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetTextColor(0.5, 0.5, 0.5, 1);
			if (showmanadeficit == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetText("-"..partymanamax - partymana);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetText();
			end
			if (showbarvalues == 0) then
				if (tonumber(mouseovermanaflag) == tonumber(id)) then
					if (UnitPowerType(partyid) == 1) then
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
					else
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
					end
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
				end
			else
				if (UnitPowerType(partyid) == 1) then
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
				end
			end
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetTextColor(1, 1, 1, 1);
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetText(partymana.."/"..partymanamax);
			if (UnitPowerType(partyid) == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymanapercent.."%");
			end
		end
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextCompactPercent"):SetText();						-- Hide the compact mode percent text in full mode
	else
		if (healermode == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetTextColor(0.5, 0.5, 0.5, 1);
			if (showmanadeficit == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetText("-"..partymanamax - partymana);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetText();
			end
			if (showbarvalues == 0) then
				if (tonumber(mouseovermanaflag) == tonumber(id)) then
					if (UnitPowerType(partyid) == 1) then
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
					else
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
					end
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
				end
			else
				if (UnitPowerType(partyid) == 1) then
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
				end
			end
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetTextColor(1, 1, 1, 1);
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarText"):SetText();
			if (UnitPowerType(partyid) == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText(partymana.."/"..partymanamax);
			end
		end

		if (compactpercent == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextCompactPercent"):SetText(partymanapercent.."%");
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_ManaBarTextCompactPercent"):SetText();
		end
	end
end

function Perl_Party_Update_Mana_Bar(id)
	if (id == nil) then
		id = this:GetID()
	end
	local partypower = UnitPowerType("party"..id);

	-- Set mana bar color
	if (partypower == 0) then
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):SetStatusBarColor(0, 0, 1, 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarBG"):SetStatusBarColor(0, 0, 1, 0.25);
	elseif (partypower == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):SetStatusBarColor(1, 0, 0, 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarBG"):SetStatusBarColor(1, 0, 0, 0.25);
	elseif (partypower == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):SetStatusBarColor(1, 1, 0, 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarBG"):SetStatusBarColor(1, 1, 0, 0.25);
	end
end

function Perl_Party_Update_Pet(id)
	if (id == nil) then
		id = this:GetID()
	end
	Perl_Party_Update_Pet_Health(id);
end

function Perl_Party_Update_Pet_Health(id)
	if (id == nil) then
		id = this:GetID()
	end
	local partypetid = "partypet"..id;

	if (UnitIsConnected("party"..id) and UnitExists(partypetid)) then
		partypethealth = UnitHealth(partypetid);
		partypethealthmax = UnitHealthMax(partypetid);
		partypethealthpercent = floor(partypethealth/partypethealthmax*100+0.5);

		if (UnitIsDead(partypetid) or UnitIsGhost(partypetid)) then				-- This prevents negative health
			partypethealth = 0;
			partypethealthpercent = 0;
		end

		if (PCUF_FADEBARS == 1) then
			if (partypethealth < getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):GetValue()) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarFadeBar"):SetMinMaxValues(0, partypethealthmax);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarFadeBar"):SetValue(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):GetValue());
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarFadeBar"):Show();
				if (id == 1) then						-- This makes the bars fade much smoother when lots of change is happening to a given bar
					Perl_Party_One_PetHealthBar_Fade_Color = 1;
					Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = 0;
				elseif (id == 2) then
					Perl_Party_Two_PetHealthBar_Fade_Color = 1;
					Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = 0;
				elseif (id == 3) then
					Perl_Party_Three_PetHealthBar_Fade_Color = 1;
					Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = 0;
				elseif (id == 4) then
					Perl_Party_Four_PetHealthBar_Fade_Color = 1;
					Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = 0;
				end
				getglobal("Perl_Party_"..id.."_PetHealthBar_Fade_OnUpdate_Frame"):Show();
			end
		end

		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetMinMaxValues(0, partypethealthmax);
		if (PCUF_INVERTBARVALUES == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetValue(partypethealthmax - partypethealth);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetValue(partypethealth);
		end

		if (PCUF_COLORHEALTH == 1) then
			if ((partypethealthpercent <= 100) and (partypethealthpercent > 75)) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetStatusBarColor(0, 0.8, 0);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0.25);
			elseif ((partypethealthpercent <= 75) and (partypethealthpercent > 50)) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 1, 0);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):SetStatusBarColor(1, 1, 0, 0.25);
			elseif ((partypethealthpercent <= 50) and (partypethealthpercent > 25)) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 0.5, 0);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):SetStatusBarColor(1, 0.5, 0, 0.25);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetStatusBarColor(1, 0, 0);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):SetStatusBarColor(1, 0, 0, 0.25);
			end
		else
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetStatusBarColor(0, 0.8, 0, 1);
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0.25);
		end

		if (compactmode == 0) then
			if (healermode == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-"..partypethealthmax - partypethealth);
				if (showbarvalues == 0) then
					if (tonumber(mouseoverpethealthflag) == tonumber(id)) then
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
					else
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
					end
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
				end
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText(partypethealth.."/"..partypethealthmax);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealthpercent.."%");
			end
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextCompactPercent"):SetText();				-- Hide the compact mode percent text in full mode
		else
			if (healermode == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText("-"..partypethealthmax - partypethealth);
				if (showbarvalues == 0) then
					if (tonumber(mouseoverpethealthflag) == tonumber(id)) then
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
					else
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
					end
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
				end
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
			end

			if (compactpercent == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextCompactPercent"):SetText(partypethealthpercent.."%");
			else
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextCompactPercent"):SetText();
			end
		end

	else
--		-- do nothing, should be hidden
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetStatusBarColor(0, 0.8, 0, 0);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):SetStatusBarColor(0, 0.8, 0, 0);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):SetValue(0);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetText();
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextCompactPercent"):SetText();
	end
end

function Perl_Party_Set_Name(id)
	if (id == nil) then
		id = this:GetID()
	end
	local partyid = "party"..id;

	-- Set name
	if (UnitName(partyid) ~= nil) then
		local partyname = UnitName(partyid);

		if (GetLocale() == "koKR") then
			if (strlen(partyname) > 40) then
				partyname = strsub(partyname, 1, 39).."...";
			end
		elseif (GetLocale() == "zhCN") then
			if (strlen(partyname) > 40) then
				partyname = strsub(partyname, 1, 39).."...";
			end
		else
			if (strlen(partyname) > 20) then
				partyname = strsub(partyname, 1, 19).."...";
			end
		end

		if (showfkeys == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_FKeyText"):SetText("F"..(id + 1));
		else
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_FKeyText"):SetText();
		end

		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_NameBarText"):SetText(partyname);
	end

	-- Set Class Icon
	if (UnitIsPlayer(partyid)) then
		_, englishclass = UnitClass(partyid);
		getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame_ClassTexture"):SetTexCoord(PCUF_CLASSPOSRIGHT[englishclass], PCUF_CLASSPOSLEFT[englishclass], PCUF_CLASSPOSTOP[englishclass], PCUF_CLASSPOSBOTTOM[englishclass]);	-- Set the party member's class icon
		getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame_ClassTexture"):Show();
	else
		getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame_ClassTexture"):Hide();
	end
end

function Perl_Party_Update_PvP_Status(id)				-- Modeled after 1.9 code
	if (id == nil) then
		id = this:GetID()
	end
	local partyid = "party"..id;

	local factionGroup = UnitFactionGroup(partyid);
	if (factionGroup == nil) then
		factionGroup = UnitFactionGroup("player");
	end

	-- Color their name if PvP flagged
	if (UnitIsPVPFreeForAll(partyid)) then
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_NameBarText"):SetTextColor(0,1,0);							-- FFA PvP will still use normal PvP coloring since you're grouped
		if (showpvpicon == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");		-- Set the FFA PvP icon
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):Show();								-- Show the icon
		else
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):Hide();								-- Hide the icon
		end
	elseif (factionGroup and UnitIsPVP(partyid) and not UnitIsPVPSanctuary(partyid)) then
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_NameBarText"):SetTextColor(0,1,0);							-- Color the name for PvP
		if (showpvpicon == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);	-- Set the correct team icon
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):Show();								-- Show the icon
		else
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):Hide();								-- Hide the icon
		end
	else
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_NameBarText"):SetTextColor(0.5,0.5,1);						-- Set the non PvP name color
		getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_PVPStatus"):Hide();									-- Hide the icon
	end

	if (not UnitPlayerControlled(partyid)) then													-- is it a player (added this check for charmed party members)
		if (UnitIsVisible(partyid)) then
			local reaction = UnitReaction(partyid, "player");
			if (reaction) then
				getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_NameBarText"):SetTextColor(UnitReactionColor[reaction].r, UnitReactionColor[reaction].g, UnitReactionColor[reaction].b);
			end
		end
	end

	if (classcolorednames == 1) then
		_, englishclass = UnitClass(partyid);
		if (englishclass) then
			getglobal("Perl_Party_MemberFrame"..id.."_NameFrame_NameBarText"):SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
		end
	end
end

function Perl_Party_Update_Level(id)
	if (id == nil) then
		id = this:GetID()
	end

	if (id ~= 0) then		-- Do this check to prevent showing a player level of zero when the player is zoning or dead or cant have info received (linkdead)
		getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame_LevelBarText"):SetText(UnitLevel("party"..id));
	end
end

function Perl_Party_Update_Leader()
	if (GetPartyLeaderIndex() == this:GetID()) then
		getglobal(this:GetName().."_NameFrame_LeaderIcon"):Show();
	else
		getglobal(this:GetName().."_NameFrame_LeaderIcon"):Hide();
	end
end

function Perl_Party_Update_Loot_Method()
	local lootMaster;
	_, lootMaster = GetLootMethod();
	if (this:GetID() == lootMaster) then
		getglobal(this:GetName().."_NameFrame_MasterIcon"):Show();
	else
		getglobal(this:GetName().."_NameFrame_MasterIcon"):Hide();
	end
end

function Perl_Party_Check_Hidden()
	if (partyhidden == 1) then
		if (InCombatLockdown()) then
			Perl_Config_Queue_Add(Perl_Party_Unregister_All);
		else
			Perl_Party_Unregister_All();
		end
	elseif (partyhidden == 2) then
		if (UnitInRaid("player")) then
			if (InCombatLockdown()) then
				Perl_Config_Queue_Add(Perl_Party_Unregister_All);
			else
				Perl_Party_Unregister_All();
			end
		else
			if (InCombatLockdown()) then
				Perl_Config_Queue_Add(Perl_Party_Register_All);
			else
				Perl_Party_Register_All();
			end
		end
	else
		if (InCombatLockdown()) then
			Perl_Config_Queue_Add(Perl_Party_Register_All);
		else
			Perl_Party_Register_All();
		end
	end
end

function Perl_Party_Register_All()
	RegisterUnitWatch(Perl_Party_MemberFrame1);
	RegisterUnitWatch(Perl_Party_MemberFrame2);
	RegisterUnitWatch(Perl_Party_MemberFrame3);
	RegisterUnitWatch(Perl_Party_MemberFrame4);
end

function Perl_Party_Unregister_All()
	UnregisterUnitWatch(Perl_Party_MemberFrame1);
	UnregisterUnitWatch(Perl_Party_MemberFrame2);
	UnregisterUnitWatch(Perl_Party_MemberFrame3);
	UnregisterUnitWatch(Perl_Party_MemberFrame4);
	Perl_Party_MemberFrame1:Hide();
	Perl_Party_MemberFrame2:Hide();
	Perl_Party_MemberFrame3:Hide();
	Perl_Party_MemberFrame4:Hide();
end

function Perl_Party_HealthShow()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			local id = this:GetID();
			local partyid = "party"..id;
			partyhealth = UnitHealth(partyid);
			partyhealthmax = UnitHealthMax(partyid);

			if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then				-- This prevents negative health
				partyhealth = 0;
			end

			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(partyhealth.."/"..partyhealthmax);
			mouseoverhealthflag = id;
		end
	end
end

function Perl_Party_HealthHide()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			local id = this:GetID();
			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText();
			mouseoverhealthflag = 0;

			if (compactmode == 1) then
				local partyid = "party"..id;
				if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then
					if (UnitClass(partyid) == PERL_LOCALIZED_HUNTER) then
						local buffnum = 1;
						local currentlyfd = 0;
						local _, _, buffTexture = UnitBuff(partyid, buffnum);
						while (buffTexture) do
							if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
								getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
								currentlyfd = 1;
								break;
							end
							buffnum = buffnum + 1;
							_, _, buffTexture = UnitBuff(partyid, buffnum);
						end
						if (currentlyfd == 0) then
							getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_DEAD);
						end
					else
						getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_DEAD);
					end
				end
			end

			-- Handle disconnected state
			if (not UnitIsConnected("party"..id)) then
				if (compactmode == 0) then
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_OFFLINE);
				else
					getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_OFFLINE);
				end
			end
		end
	end
end

function Perl_Party_ManaShow()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			local id = this:GetID();
			local partyid = "party"..id;
			partymana = UnitMana(partyid);
			partymanamax = UnitManaMax(partyid);

			if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then				-- This prevents negative mana
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
end

function Perl_Party_ManaHide()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			getglobal("Perl_Party_MemberFrame"..this:GetID().."_StatsFrame_ManaBar_ManaBarTextPercent"):SetText();
			mouseovermanaflag = 0;
		end
	end
end

function Perl_Party_Pet_HealthShow()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			local id = this:GetID();
			local partyid = "partypet"..id;
			partypethealth = UnitHealth(partyid);
			partypethealthmax = UnitHealthMax(partyid);

			if (UnitIsDead(partyid) or UnitIsGhost(partyid)) then				-- This prevents negative health
				partypethealth = 0;
			end

			getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText(partypethealth.."/"..partypethealthmax);
			mouseoverpethealthflag = id;
		end
	end
end

function Perl_Party_Pet_HealthHide()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			getglobal("Perl_Party_MemberFrame"..this:GetID().."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetText();
			mouseoverpethealthflag = 0;
		end
	end
end

function Perl_Party_Update_Portrait(id)
	if (showportrait == 1) then
		if (id == nil) then
			id = this:GetID()
		end
		local partyid = "party"..id;

		if (threedportrait == 0) then
			SetPortraitTexture(getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_Portrait"), partyid);		-- Load the correct 2d graphic
		else
			if (UnitIsVisible(partyid)) then
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_PartyModel"):SetUnit(partyid);			-- Load the correct 3d graphic
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_PartyModel"):SetCamera(0);
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_Portrait"):Hide();				-- Hide the 2d graphic
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_PartyModel"):Show();				-- Show the 3d graphic
			else
				SetPortraitTexture(getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_Portrait"), partyid);	-- Load the correct 2d graphic
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_PartyModel"):Hide();				-- Hide the 3d graphic
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_Portrait"):Show();				-- Show the 2d graphic
			end
		end
	end
end

function Perl_Party_Update_Health_Mana()
	for partynum=1,4 do
		local partyid = "party"..partynum;
		if (UnitName(partyid) ~= nil) then
			Perl_Party_Update_Health(partynum);
			Perl_Party_Update_Mana(partynum);
			Perl_Party_Update_Pet_Health(partynum);
		end
	end
end

function Perl_Party_Force_Update()
	Perl_Party_Reset_Buffs();			-- Reset Buffs

	for id = 1, 4 do
		Perl_Party_Set_Name(id);		-- Set Name & Class Icon
		Perl_Party_Update_Level(id);		-- Set Level
		Perl_Party_Update_Health(id);		-- Set Death State & Disconnected State
		Perl_Party_Update_PvP_Status(id);	-- Set PvP Info & Name Color
		Perl_Party_Update_Mana_Bar(id);		-- Set Power Bar Color
		Perl_Party_Update_Portrait(id);		-- Set Portraits
		Perl_Party_Buff_UpdateAll(id);		-- Set Buffs
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Party_One_HealthBar_Fade(arg1)
	Perl_Party_One_HealthBar_Fade_Color = Perl_Party_One_HealthBar_Fade_Color - arg1;
	Perl_Party_One_HealthBar_Fade_Time_Elapsed = Perl_Party_One_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame1_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_One_HealthBar_Fade_Color, 0, Perl_Party_One_HealthBar_Fade_Color);

	if (Perl_Party_One_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_One_HealthBar_Fade_Color = 1;
		Perl_Party_One_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame1_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_1_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Two_HealthBar_Fade(arg1)
	Perl_Party_Two_HealthBar_Fade_Color = Perl_Party_Two_HealthBar_Fade_Color - arg1;
	Perl_Party_Two_HealthBar_Fade_Time_Elapsed = Perl_Party_Two_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame2_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Two_HealthBar_Fade_Color, 0, Perl_Party_Two_HealthBar_Fade_Color);

	if (Perl_Party_Two_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Two_HealthBar_Fade_Color = 1;
		Perl_Party_Two_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame2_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_2_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Three_HealthBar_Fade(arg1)
	Perl_Party_Three_HealthBar_Fade_Color = Perl_Party_Three_HealthBar_Fade_Color - arg1;
	Perl_Party_Three_HealthBar_Fade_Time_Elapsed = Perl_Party_Three_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame3_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Three_HealthBar_Fade_Color, 0, Perl_Party_Three_HealthBar_Fade_Color);

	if (Perl_Party_Three_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Three_HealthBar_Fade_Color = 1;
		Perl_Party_Three_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame3_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_3_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Four_HealthBar_Fade(arg1)
	Perl_Party_Four_HealthBar_Fade_Color = Perl_Party_Four_HealthBar_Fade_Color - arg1;
	Perl_Party_Four_HealthBar_Fade_Time_Elapsed = Perl_Party_Four_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame4_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Four_HealthBar_Fade_Color, 0, Perl_Party_Four_HealthBar_Fade_Color);

	if (Perl_Party_Four_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Four_HealthBar_Fade_Color = 1;
		Perl_Party_Four_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame4_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_4_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_One_ManaBar_Fade(arg1)
	Perl_Party_One_ManaBar_Fade_Color = Perl_Party_One_ManaBar_Fade_Color - arg1;
	Perl_Party_One_ManaBar_Fade_Time_Elapsed = Perl_Party_One_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party1") == 0) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1") == 1) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_One_ManaBar_Fade_Color, 0, 0, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1") == 3) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color, 0, Perl_Party_One_ManaBar_Fade_Color);
	end

	if (Perl_Party_One_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_One_ManaBar_Fade_Color = 1;
		Perl_Party_One_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_1_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Two_ManaBar_Fade(arg1)
	Perl_Party_Two_ManaBar_Fade_Color = Perl_Party_Two_ManaBar_Fade_Color - arg1;
	Perl_Party_Two_ManaBar_Fade_Time_Elapsed = Perl_Party_Two_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party2") == 0) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2") == 1) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_One_ManaBar_Fade_Color, 0, 0, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2") == 3) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color, 0, Perl_Party_One_ManaBar_Fade_Color);
	end

	if (Perl_Party_One_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Two_ManaBar_Fade_Color = 1;
		Perl_Party_Two_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_2_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Three_ManaBar_Fade(arg1)
	Perl_Party_Three_ManaBar_Fade_Color = Perl_Party_Three_ManaBar_Fade_Color - arg1;
	Perl_Party_Three_ManaBar_Fade_Time_Elapsed = Perl_Party_Three_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party3") == 0) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Three_ManaBar_Fade_Color, Perl_Party_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3") == 1) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Three_ManaBar_Fade_Color, 0, 0, Perl_Party_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3") == 3) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Three_ManaBar_Fade_Color, Perl_Party_Three_ManaBar_Fade_Color, 0, Perl_Party_Three_ManaBar_Fade_Color);
	end

	if (Perl_Party_Three_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Three_ManaBar_Fade_Color = 1;
		Perl_Party_Three_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_3_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Four_ManaBar_Fade(arg1)
	Perl_Party_Four_ManaBar_Fade_Color = Perl_Party_Four_ManaBar_Fade_Color - arg1;
	Perl_Party_Four_ManaBar_Fade_Time_Elapsed = Perl_Party_Four_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party4") == 0) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Four_ManaBar_Fade_Color, Perl_Party_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4") == 1) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Four_ManaBar_Fade_Color, 0, 0, Perl_Party_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4") == 3) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Four_ManaBar_Fade_Color, Perl_Party_Four_ManaBar_Fade_Color, 0, Perl_Party_Four_ManaBar_Fade_Color);
	end

	if (Perl_Party_Four_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Four_ManaBar_Fade_Color = 1;
		Perl_Party_Four_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_4_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_One_PetHealthBar_Fade(arg1)
	Perl_Party_One_PetHealthBar_Fade_Color = Perl_Party_One_PetHealthBar_Fade_Color - arg1;
	Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = Perl_Party_One_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame1_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_One_PetHealthBar_Fade_Color, 0, Perl_Party_One_PetHealthBar_Fade_Color);

	if (Perl_Party_One_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_One_PetHealthBar_Fade_Color = 1;
		Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame1_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_1_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Two_PetHealthBar_Fade(arg1)
	Perl_Party_Two_PetHealthBar_Fade_Color = Perl_Party_Two_PetHealthBar_Fade_Color - arg1;
	Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame2_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Two_PetHealthBar_Fade_Color, 0, Perl_Party_Two_PetHealthBar_Fade_Color);

	if (Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Two_PetHealthBar_Fade_Color = 1;
		Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame2_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_2_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Three_PetHealthBar_Fade(arg1)
	Perl_Party_Three_PetHealthBar_Fade_Color = Perl_Party_Three_PetHealthBar_Fade_Color - arg1;
	Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame3_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Three_PetHealthBar_Fade_Color, 0, Perl_Party_Three_PetHealthBar_Fade_Color);

	if (Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Three_PetHealthBar_Fade_Color = 1;
		Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame3_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_3_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Four_PetHealthBar_Fade(arg1)
	Perl_Party_Four_PetHealthBar_Fade_Color = Perl_Party_Four_PetHealthBar_Fade_Color - arg1;
	Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame4_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Four_PetHealthBar_Fade_Color, 0, Perl_Party_Four_PetHealthBar_Fade_Color);

	if (Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Four_PetHealthBar_Fade_Color = 1;
		Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame4_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_4_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Party_Frame_Style()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Frame_Style);
	else
		-- Begin: Set the frame size for pets
		if (showpets == 1) then
			for id=1,4 do
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):SetHeight(54);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_CastClickOverlay"):SetHeight(54);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):Show();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):Show();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_CastClickOverlay"):Show();
			end
		else
			for id=1,4 do
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):SetHeight(42);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_CastClickOverlay"):SetHeight(42);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):Hide();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):Hide();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_CastClickOverlay"):Hide();
			end
		end
		-- End: Set the frame size for pets

		-- Begin: Set the frame spacing
		if (verticalalign == 1) then
			Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", 0, partyspacing);
			Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", 0, partyspacing);
			Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", 0, partyspacing);

			if (showpets == 1) then
				local partypetspacing;
				if (partyspacing < 0) then			-- Frames are normal
					partypetspacing = partyspacing - 12;
				else						-- Frames are inverted
					partypetspacing = partyspacing + 12;
				end
				for partynum=1,4 do
					local partyid = "party"..partynum;
					local frame = getglobal("Perl_Party_MemberFrame"..partynum);
					if (UnitName(partyid) ~= nil) then
						if (UnitIsConnected(partyid) and UnitExists("partypet"..partynum)) then
							if (partyspacing < 0) then			-- Frames are normal
								if (partynum == 1 or partynum == 2 or partynum == 3) then
									local idspace = partynum + 1;
									local partypetspacing;
									partypetspacing = partyspacing - 12;
									getglobal("Perl_Party_MemberFrame"..idspace):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..partynum, "TOPLEFT", 0, partypetspacing);
								end
							else						-- Frames are inverted
								if (partynum == 2 or partynum == 3 or partynum == 4) then
									local idspace = partynum - 1;
									local partypetspacing;
									partypetspacing = partyspacing + 12;
									getglobal("Perl_Party_MemberFrame"..partynum):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..idspace, "TOPLEFT", 0, partypetspacing);
								end
							end
						end
					end
				end
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
		-- End: Set the frame spacing

		-- Begin: Compact Mode
		if (compactmode == 0) then
			Perl_Party_MemberFrame1_StatsFrame:SetWidth(240);
			Perl_Party_MemberFrame2_StatsFrame:SetWidth(240);
			Perl_Party_MemberFrame3_StatsFrame:SetWidth(240);
			Perl_Party_MemberFrame4_StatsFrame:SetWidth(240);
			Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(240);
			Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(240);
			Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(240);
			Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(240);
		else
			if (shortbars == 0) then
				if (compactpercent == 0) then
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(170);
				else
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(205);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(205);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(205);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(205);
				end
			else
				if (compactpercent == 0) then
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(135);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(135);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(135);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(135);
				else
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(170);
				end
			end
		end
		-- End: Compact Mode

		-- Begin: Short Bars
		if (compactmode == 1 and shortbars == 1) then
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"):SetWidth(165);
				getglobal("Perl_Party_MemberFrame"..num.."_NameFrame_CastClickOverlay"):SetWidth(165);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetWidth(115);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetWidth(115);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetWidth(115);
			end
		else
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"):SetWidth(200);
				getglobal("Perl_Party_MemberFrame"..num.."_NameFrame_CastClickOverlay"):SetWidth(200);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetWidth(150);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetWidth(150);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetWidth(150);
			end
		end
		-- End: Short Bars

		-- Begin: Hide Class Level Frame
		if (hideclasslevelframe == 1) then
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame"):Hide();
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):SetPoint("TOPLEFT", getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"), "BOTTOMLEFT", 0, 5);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_CastClickOverlay"):GetWidth() + 30);
				
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):GetWidth() + 30);
				
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):GetWidth() + 30);
				
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):GetWidth() + 30);
			end
		else
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame"):Show();
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):SetPoint("TOPLEFT", getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"), "BOTTOMLEFT", 30, 5);
			end
		end
		-- End: Hide Class Level Frame

		-- Begin: Set Text Positions
		for partynum=1,4 do
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):ClearAllPoints();
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):ClearAllPoints();
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):ClearAllPoints();
		end
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
			if (healermode == 0) then
				for partynum=1,4 do
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", 70, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOP", 0, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", 70, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOP", 0, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", 70, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOP", 0, 1);
				end
			else
				for partynum=1,4 do
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", -10, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOPLEFT", 5, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", -10, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOPLEFT", 5, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", -10, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOPLEFT", 5, 1);
				end
			end
		end
		-- End: Set Text Positions

		-- Begin: Show/Hide the portrait frame
		for id=1,4 do
			if (showportrait == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame"):Show();			-- Show the main portrait frame
				if (threedportrait == 0) then
					getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_PartyModel"):Hide();	-- Hide the 3d graphic
					getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_Portrait"):Show();	-- Show the 2d graphic
				end
			else
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame"):Hide();			-- Hide the frame and 2d/3d portion
			end
		end
		-- End: Show/Hide the portrait frame
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Party_Set_Space(number)
	if (number ~= nil) then
		partyspacing = -number;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
end

function Perl_Party_Set_Hidden(newvalue)
	if (newvalue ~= nil) then
		partyhidden = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Check_Hidden();
end

function Perl_Party_Set_Compact(newvalue)
	if (newvalue ~= nil) then
		compactmode = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Healer(newvalue)
	if (newvalue ~= nil) then
		healermode = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Pets(newvalue)
	if (newvalue ~= nil) then
		showpets = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Party_UpdateVars();
end

function Perl_Party_Set_VerticalAlign(newvalue)
	verticalalign = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
end

function Perl_Party_Set_Compact_Percent(newvalue)
	compactpercent = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Compact();
end

function Perl_Party_Set_Short_Bars(newvalue)
	shortbars = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Compact();
end

function Perl_Party_Set_Portrait(newvalue)
	showportrait = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Portrait(1);
	Perl_Party_Update_Portrait(2);
	Perl_Party_Update_Portrait(3);
	Perl_Party_Update_Portrait(4);
end

function Perl_Party_Set_3D_Portrait(newvalue)
	threedportrait = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Portrait(1);
	Perl_Party_Update_Portrait(2);
	Perl_Party_Update_Portrait(3);
	Perl_Party_Update_Portrait(4);
end

function Perl_Party_Set_FKeys(newvalue)
	showfkeys = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Force_Update();
end

function Perl_Party_Set_Mana_Deficit(newvalue)
	showmanadeficit = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Class_Buffs(newvalue)
	if (newvalue ~= nil) then
		displaycastablebuffs = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Buff_Location(newvalue)
	if (newvalue ~= nil) then
		bufflocation = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Buff_Position_Update(1);
	Perl_Party_Buff_Position_Update(2);
	Perl_Party_Buff_Position_Update(3);
	Perl_Party_Buff_Position_Update(4);
end

function Perl_Party_Set_Debuff_Location(newvalue)
	if (newvalue ~= nil) then
		debufflocation = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Buff_Position_Update(1);
	Perl_Party_Buff_Position_Update(2);
	Perl_Party_Buff_Position_Update(3);
	Perl_Party_Buff_Position_Update(4);
end

function Perl_Party_Set_Buff_Size(newvalue)
	if (newvalue ~= nil) then
		buffsize = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Debuff_Size(newvalue)
	if (newvalue ~= nil) then
		debuffsize = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Buffs(newvalue)
	if (newvalue ~= nil) then
		numbuffsshown = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Debuffs(newvalue)
	if (newvalue ~= nil) then
		numdebuffsshown = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Force_Update();
end

function Perl_Party_Set_Hide_Class_Level_Frame(newvalue)
	hideclasslevelframe = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Compact();
	Perl_Party_Buff_Position_Update(1);
	Perl_Party_Buff_Position_Update(2);
	Perl_Party_Buff_Position_Update(3);
	Perl_Party_Buff_Position_Update(4);
end

function Perl_Party_Set_PvP_Icon(newvalue)
	showpvpicon = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Force_Update();
end

function Perl_Party_Set_Show_Bar_Values(newvalue)
	showbarvalues = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);
	end
	Perl_Party_UpdateVars();
	Perl_Party_Set_Scale_Actual();
end

function Perl_Party_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Set_Scale_Actual);
	else
		Perl_Party_Frame:SetScale(1 - UIParent:GetEffectiveScale() + scale);	-- run it through the scaling formula introduced in 1.9
	end
end

function Perl_Party_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);
	end
	Perl_Party_UpdateVars();
	Perl_Party_MemberFrame1:SetAlpha(transparency);
	Perl_Party_MemberFrame2:SetAlpha(transparency);
	Perl_Party_MemberFrame3:SetAlpha(transparency);
	Perl_Party_MemberFrame4:SetAlpha(transparency);
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Party_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Party_Config[name]["Locked"];
	compactmode = Perl_Party_Config[name]["CompactMode"];
	partyhidden = Perl_Party_Config[name]["PartyHidden"];
	partyspacing = Perl_Party_Config[name]["PartySpacing"];
	scale = Perl_Party_Config[name]["Scale"];
	showpets = Perl_Party_Config[name]["ShowPets"];
	healermode = Perl_Party_Config[name]["HealerMode"];
	transparency = Perl_Party_Config[name]["Transparency"];
	bufflocation = Perl_Party_Config[name]["BuffLocation"];
	debufflocation = Perl_Party_Config[name]["DebuffLocation"];
	verticalalign = Perl_Party_Config[name]["VerticalAlign"];
	compactpercent = Perl_Party_Config[name]["CompactPercent"];
	showportrait = Perl_Party_Config[name]["ShowPortrait"];
	showfkeys = Perl_Party_Config[name]["ShowFKeys"];
	displaycastablebuffs = Perl_Party_Config[name]["DisplayCastableBuffs"];
	threedportrait = Perl_Party_Config[name]["ThreeDPortrait"];
	buffsize = Perl_Party_Config[name]["BuffSize"];
	debuffsize = Perl_Party_Config[name]["DebuffSize"];
	numbuffsshown = Perl_Party_Config[name]["Buffs"];
	numdebuffsshown = Perl_Party_Config[name]["Debuffs"];
	classcolorednames = Perl_Party_Config[name]["ClassColoredNames"];
	shortbars = Perl_Party_Config[name]["ShortBars"];
	hideclasslevelframe = Perl_Party_Config[name]["HideClassLevelFrame"];
	showmanadeficit = Perl_Party_Config[name]["ShowManaDeficit"];
	showpvpicon = Perl_Party_Config[name]["ShowPvPIcon"];
	showbarvalues = Perl_Party_Config[name]["ShowBarValues"];

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
		partyspacing = -90;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (showpets == nil) then
		showpets = 1;
	end
	if (healermode == nil) then
		healermode = 0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (bufflocation == nil) then
		bufflocation = 6;
	end
	if (debufflocation == nil) then
		debufflocation = 3;
	end
	if (verticalalign == nil) then
		verticalalign = 1;
	end
	if (compactpercent == nil) then
		compactpercent = 0;
	end
	if (showportrait == nil) then
		showportrait = 0;
	end
	if (showfkeys == nil) then
		showfkeys = 1;
	end
	if (displaycastablebuffs == nil) then
		displaycastablebuffs = 0;
	end
	if (threedportrait == nil) then
		threedportrait = 0;
	end
	if (buffsize == nil) then
		buffsize = 16;
	end
	if (debuffsize == nil) then
		debuffsize = 16;
	end
	if (numbuffsshown == nil) then
		numbuffsshown = 16;
	end
	if (numdebuffsshown == nil) then
		numdebuffsshown = 16;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (shortbars == nil) then
		shortbars = 0;
	end
	if (hideclasslevelframe == nil) then
		hideclasslevelframe = 0;
	end
	if (showmanadeficit == nil) then
		showmanadeficit = 0;
	end
	if (showpvpicon == nil) then
		showpvpicon = 1;
	end
	if (showbarvalues == nil) then
		showbarvalues = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Party_UpdateVars();

		-- Call any code we need to activate them
		Perl_Party_Check_Hidden();
		Perl_Party_Set_Compact();
		Perl_Party_Set_Healer();
		Perl_Party_Set_Pets();
		Perl_Party_Reset_Buffs();		-- Reset the buff icons and set sizes
		Perl_Party_Update_Buffs();		-- Repopulate the buff icons
		Perl_Party_Frame_Style();
		Perl_Party_Set_Scale_Actual();
		Perl_Party_Set_Transparency();
		return;
	end

	local vars = {
		["locked"] = locked,
		["compactmode"] = compactmode,
		["partyhidden"] = partyhidden,
		["partyspacing"] = partyspacing,
		["scale"] = scale,
		["showpets"] = showpets,
		["healermode"] = healermode,
		["transparency"] = transparency,
		["bufflocation"] = bufflocation,
		["debufflocation"] = debufflocation,
		["verticalalign"] = verticalalign,
		["compactpercent"] = compactpercent,
		["showportrait"] = showportrait,
		["showfkeys"] = showfkeys,
		["displaycastablebuffs"] = displaycastablebuffs,
		["threedportrait"] = threedportrait,
		["buffsize"] = buffsize,
		["debuffsize"] = debuffsize,
		["numbuffsshown"] = numbuffsshown,
		["numdebuffsshown"] = numdebuffsshown,
		["classcolorednames"] = classcolorednames,
		["shortbars"] = shortbars,
		["hideclasslevelframe"] = hideclasslevelframe,
		["showmanadeficit"] = showmanadeficit,
		["showpvpicon"] = showpvpicon,
		["showbarvalues"] = showbarvalues,
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
			if (vartable["Global Settings"]["CompactPercent"] ~= nil) then
				compactpercent = vartable["Global Settings"]["CompactPercent"];
			else
				compactpercent = nil;
			end
			if (vartable["Global Settings"]["ShowPortrait"] ~= nil) then
				showportrait = vartable["Global Settings"]["ShowPortrait"];
			else
				showportrait = nil;
			end
			if (vartable["Global Settings"]["ShowFKeys"] ~= nil) then
				showfkeys = vartable["Global Settings"]["ShowFKeys"];
			else
				showfkeys = nil;
			end
			if (vartable["Global Settings"]["DisplayCastableBuffs"] ~= nil) then
				displaycastablebuffs = vartable["Global Settings"]["DisplayCastableBuffs"];
			else
				displaycastablebuffs = nil;
			end
			if (vartable["Global Settings"]["ThreeDPortrait"] ~= nil) then
				threedportrait = vartable["Global Settings"]["ThreeDPortrait"];
			else
				threedportrait = nil;
			end
			if (vartable["Global Settings"]["BuffSize"] ~= nil) then
				buffsize = vartable["Global Settings"]["BuffSize"];
			else
				buffsize = nil;
			end
			if (vartable["Global Settings"]["DebuffSize"] ~= nil) then
				debuffsize = vartable["Global Settings"]["DebuffSize"];
			else
				debuffsize = nil;
			end
			if (vartable["Global Settings"]["Buffs"] ~= nil) then
				numbuffsshown = vartable["Global Settings"]["Buffs"];
			else
				numbuffsshown = nil;
			end
			if (vartable["Global Settings"]["Debuffs"] ~= nil) then
				numdebuffsshown = vartable["Global Settings"]["Debuffs"];
			else
				numdebuffsshown = nil;
			end
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["ShortBars"] ~= nil) then
				shortbars = vartable["Global Settings"]["ShortBars"];
			else
				shortbars = nil;
			end
			if (vartable["Global Settings"]["HideClassLevelFrame"] ~= nil) then
				hideclasslevelframe = vartable["Global Settings"]["HideClassLevelFrame"];
			else
				hideclasslevelframe = nil;
			end
			if (vartable["Global Settings"]["ShowManaDeficit"] ~= nil) then
				showmanadeficit = vartable["Global Settings"]["ShowManaDeficit"];
			else
				showmanadeficit = nil;
			end
			if (vartable["Global Settings"]["ShowPvPIcon"] ~= nil) then
				showpvpicon = vartable["Global Settings"]["ShowPvPIcon"];
			else
				showpvpicon = nil;
			end
			if (vartable["Global Settings"]["ShowBarValues"] ~= nil) then
				showbarvalues = vartable["Global Settings"]["ShowBarValues"];
			else
				showbarvalues = nil;
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
			partyspacing = -90;
		end
		if (scale == nil) then
			scale = 1;
		end
		if (showpets == nil) then
			showpets = 1;
		end
		if (healermode == nil) then
			healermode = 0;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (bufflocation == nil) then
			bufflocation = 6;
		end
		if (debufflocation == nil) then
			debufflocation = 3;
		end
		if (verticalalign == nil) then
			verticalalign = 1;
		end
		if (compactpercent == nil) then
			compactpercent = 0;
		end
		if (showportrait == nil) then
			showportrait = 0;
		end
		if (showfkeys == nil) then
			showfkeys = 1;
		end
		if (displaycastablebuffs == nil) then
			displaycastablebuffs = 0;
		end
		if (threedportrait == nil) then
			threedportrait = 0;
		end
		if (buffsize == nil) then
			buffsize = 16;
		end
		if (debuffsize == nil) then
			debuffsize = 16;
		end
		if (numbuffsshown == nil) then
			numbuffsshown = 16;
		end
		if (numdebuffsshown == nil) then
			numdebuffsshown = 16;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (shortbars == nil) then
			shortbars = 0;
		end
		if (hideclasslevelframe == nil) then
			hideclasslevelframe = 0;
		end
		if (showmanadeficit == nil) then
			showmanadeficit = 0;
		end
		if (showpvpicon == nil) then
			showpvpicon = 1;
		end
		if (showbarvalues == nil) then
			showbarvalues = 0;
		end

		-- Call any code we need to activate them
		Perl_Party_Check_Hidden();
		Perl_Party_Set_Compact();
		Perl_Party_Set_Healer();
		Perl_Party_Set_Pets();
		Perl_Party_Reset_Buffs();		-- Reset the buff icons and set sizes
		Perl_Party_Update_Buffs();		-- Repopulate the buff icons
		Perl_Party_Frame_Style();
		Perl_Party_Set_Scale_Actual();
		Perl_Party_Set_Transparency();
	end

	-- IFrameManager Support
	if (IFrameManager) then
		IFrameManager:Refresh();
	end

	Perl_Party_Config[UnitName("player")] = {
		["Locked"] = locked,
		["CompactMode"] = compactmode,
		["PartyHidden"] = partyhidden,
		["PartySpacing"] = partyspacing,
		["Scale"] = scale,
		["ShowPets"] = showpets,
		["HealerMode"] = healermode,
		["Transparency"] = transparency,
		["BuffLocation"] = bufflocation,
		["DebuffLocation"] = debufflocation,
		["VerticalAlign"] = verticalalign,
		["CompactPercent"] = compactpercent,
		["ShowPortrait"] = showportrait,
		["ShowFKeys"] = showfkeys,
		["DisplayCastableBuffs"] = displaycastablebuffs,
		["ThreeDPortrait"] = threedportrait,
		["BuffSize"] = buffsize,
		["DebuffSize"] = debuffsize,
		["Buffs"] = numbuffsshown,
		["Debuffs"] = numdebuffsshown,
		["ClassColoredNames"] = classcolorednames,
		["ShortBars"] = shortbars,
		["HideClassLevelFrame"] = hideclasslevelframe,
		["ShowManaDeficit"] = showmanadeficit,
		["ShowPvPIcon"] = showpvpicon,
		["ShowBarValues"] = showbarvalues,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Party_Buff_UpdateAll(id)
	if (id == nil) then
		id = this:GetID()
	end
	local partyid = "party"..id;
	
	if (UnitName(partyid)) then
		local button, buffCount, buffTexture, buffApplications, color, debuffType;					-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)

		for buffnum=1,numbuffsshown do											-- Start main buff loop
			_, _, buffTexture, buffApplications = UnitBuff(partyid, buffnum, displaycastablebuffs);			-- Get the texture, buff stacking, and class specific information if any
			button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff"..buffnum);				-- Create the main icon for the buff
			if (buffTexture) then											-- If there is a valid texture, proceed with buff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);					-- Set the texture
				getglobal(button:GetName().."DebuffBorder"):Hide();						-- Hide the debuff border
				buffCount = getglobal(button:GetName().."Count");						-- Declare the buff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);							-- Set the text to the number of applications if greater than 0
					buffCount:Show();									-- Show the text
				else
					buffCount:Hide();									-- Hide the text if equal to 0
				end
				button:Show();											-- Show the final buff icon
			else
				button:Hide();											-- Hide the icon since there isn't a buff in this position
			end
		end														-- End main buff loop

		for debuffnum=1,numdebuffsshown do										-- Start main debuff loop
			_, _, buffTexture, buffApplications, debuffType = UnitDebuff(partyid, debuffnum, displaycastablebuffs);	-- Get the texture, debuff stacking, and class specific information if any
			button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff"..debuffnum);			-- Create the main icon for the debuff
			if (buffTexture) then											-- If there is a valid texture, proceed with debuff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);					-- Set the texture
				if (debuffType) then
					color = DebuffTypeColor[debuffType];
				else
					color = DebuffTypeColor[PERL_LOCALIZED_BUFF_NONE];
				end
				getglobal(button:GetName().."DebuffBorder"):SetVertexColor(color.r, color.g, color.b);		-- Set the debuff border color
				getglobal(button:GetName().."DebuffBorder"):Show();						-- Show the debuff border
				buffCount = getglobal(button:GetName().."Count");						-- Declare the debuff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);							-- Set the text to the number of applications if greater than 0
					buffCount:Show();									-- Show the text
				else
					buffCount:Hide();									-- Hide the text if equal to 0
				end
				button:Show();											-- Show the final debuff icon
			else
				button:Hide();											-- Hide the icon since there isn't a debuff in this position
			end
		end														-- End main debuff loop

		if (UnitIsDead(partyid)) then
			if (UnitClass(partyid) == PERL_LOCALIZED_HUNTER) then	-- If the dead is a hunter, check for Feign Death
				local buffnum = 1;
				_, _, buffTexture = UnitBuff(partyid, buffnum);
				while (buffTexture) do
					if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
						if (compactmode == 0) then
							getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarText"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
						else
							getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
						end
						break;
					end
					buffnum = buffnum + 1;
					_, _, buffTexture = UnitBuff(partyid, buffnum);
				end
			end
		end
	end
end

function Perl_Party_Update_Buffs()
	Perl_Party_Buff_UpdateAll(1);
	Perl_Party_Buff_UpdateAll(2);
	Perl_Party_Buff_UpdateAll(3);
	Perl_Party_Buff_UpdateAll(4);
end

function Perl_Party_Buff_Position_Update(id)
	if (id == nil) then
		id = this:GetID();
	end

	getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):ClearAllPoints();
	if (bufflocation == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 5, 20);
	elseif (bufflocation == 2) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 5, 0);
	elseif (bufflocation == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 4) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 5) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -23);
	elseif (bufflocation == 6) then
		if (hideclasslevelframe == 0) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, 0);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, 0);
		end
	elseif (bufflocation == 7) then
		if (hideclasslevelframe == 0) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, -20);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, -20);
		end
	end

	getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):ClearAllPoints();
	if (debufflocation == 1) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 5, 20);
	elseif (debufflocation == 2) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 5, 0);
	elseif (debufflocation == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 4) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 5) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -23);
	elseif (debufflocation == 6) then
		if (hideclasslevelframe == 0) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, 0);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, 0);
		end
	elseif (debufflocation == 7) then
		if (hideclasslevelframe == 0) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, -20);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, -20);
		end
	end
end

function Perl_Party_Reset_Buffs()
	local button, debuff, icon;
	for id=1,4 do
		for buffnum=1,16 do
			button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff"..buffnum);
			icon = getglobal(button:GetName().."Icon");
			debuff = getglobal(button:GetName().."DebuffBorder");
			button:SetHeight(buffsize);
			button:SetWidth(buffsize);
			icon:SetHeight(buffsize);
			icon:SetWidth(buffsize);
			debuff:SetHeight(buffsize);
			debuff:SetWidth(buffsize);
			button:Hide();
			debuff:Hide();
		end
		for buffnum=1,16 do
			button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff"..buffnum);
			icon = getglobal(button:GetName().."Icon");
			debuff = getglobal(button:GetName().."DebuffBorder");
			button:SetHeight(debuffsize);
			button:SetWidth(debuffsize);
			icon:SetHeight(debuffsize);
			icon:SetWidth(debuffsize);
			debuff:SetHeight(debuffsize);
			debuff:SetWidth(debuffsize);
			button:Hide();
			debuff:Hide();
		end
	end
end

function Perl_Party_SetBuffTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
	if (this:GetID() > 16) then
		GameTooltip:SetUnitDebuff("party"..this:GetParent():GetParent():GetID(), this:GetID()-16, displaycastablebuffs);	-- 16 being the number of buffs before debuffs in the xml
	else
		GameTooltip:SetUnitBuff("party"..this:GetParent():GetParent():GetID(), this:GetID(), displaycastablebuffs);
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Party_CastClickOverlay_OnLoad()
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("Perl_Party_MemberFrame"..this:GetParent():GetParent():GetID().."_DropDown"), "Perl_Party_MemberFrame"..this:GetParent():GetParent():GetID(), 0, 0);
	end
	SecureUnitButton_OnLoad(this, "party"..this:GetParent():GetParent():GetID(), showmenu);

	this:SetAttribute("unit", "party"..this:GetParent():GetParent():GetID());
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[this] = true;
end

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
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..dropdown:GetParent():GetID());
end

function Perl_Party_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Party_Frame:StartMoving();
	end
end

function Perl_Party_DragStop(button)
	Perl_Party_Frame:StopMovingOrSizing();
end

function Perl_Party_Pet_CastClickOverlay_OnLoad()
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("Perl_Party_MemberFrame"..this:GetParent():GetParent():GetID().."_DropDown"), "Perl_Party_MemberFrame"..this:GetParent():GetParent():GetID(), 0, 0);
	end
	SecureUnitButton_OnLoad(this, "partypet"..this:GetParent():GetParent():GetID(), showmenu);

	this:SetAttribute("unit", "partypet"..this:GetParent():GetParent():GetID());
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[this] = true;
end


-------------
-- Tooltip --
-------------
function Perl_Party_Tip()
	UnitFrame_Initialize("party"..this:GetID());
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
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Party_myAddOns_Help = {};
		Perl_Party_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Party_myAddOns_Details, Perl_Party_myAddOns_Help);
	end
end