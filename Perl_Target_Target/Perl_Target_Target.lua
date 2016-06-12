---------------
-- Variables --
---------------
Perl_Target_Target_Config = {};

-- Default Saved Variables (also set in Perl_Target_Target_GetVars)
local colorhealth = 0;		-- progressively colored health bars are off by default
local locked = 0;		-- unlocked by default
local mobhealthsupport = 1;	-- mobhealth support is on by default
local scale = 1;		-- default scale
local totsupport = 1;		-- target of target support enabled by default
local tototsupport = 1;		-- target of target of target support enabled by default
local transparency = 1;		-- transparency for frames

-- Default Local Variables
local Initialized = nil;				-- waiting to be initialized
local Perl_Target_Target_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Target_Target_Time_Update_Rate = 0.2;	-- the update interval
local mouseovertargettargethealthflag = 0;		-- is the mouse over the health bar for healer mode?
local mouseovertargettargetmanaflag = 0;		-- is the mouse over the mana bar for healer mode?
local mouseovertargettargettargethealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovertargettargettargetmanaflag = 0;		-- is the mouse over the mana bar for healer mode?


----------------------
-- Loading Function --
----------------------
function Perl_Target_Target_OnLoad()
	-- Events
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("VARIABLES_LOADED");

	-- Slash Commands
	SlashCmdList["PERL_TARGET_TARGET"] = Perl_Target_Target_SlashHandler;
	SLASH_PERL_TARGET_TARGET1 = "/perltargettarget";
	SLASH_PERL_TARGET_TARGET2 = "/ptt";

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame by Global loaded successfully.");
	end
end


-------------------
-- Event Handler --
-------------------
function Perl_Target_Target_OnEvent(event)
	if (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD") then
		Perl_Target_Target_Initialize();
		return;
	elseif (event == "ADDON_LOADED") then
		if (arg1 == "Perl_Target_Target") then
			Perl_Target_Target_myAddOns_Support();
		end
		return;
	else
		return;
	end
end


-------------------
-- Slash Handler --
-------------------
function Perl_Target_Target_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Target_Target_Unlock();
		return;
	elseif (string.find(msg, "lock")) then
		Perl_Target_Target_Lock();
		return;
	elseif (string.find(msg, "totot")) then
		Perl_Target_Target_ToggleToToT();
		return;
	elseif (string.find(msg, "tot")) then
		Perl_Target_Target_ToggleToT();
		return;
	elseif (string.find(msg, "mobhealth")) then
		Perl_Target_Target_ToggleMobHealth();
		return;
	elseif (string.find(msg, "health")) then
		Perl_Target_Target_ToggleColoredHealth();
		return;
	elseif (string.find(msg, "scale")) then
		local _, _, cmd, arg1 = string.find(msg, "(%w+)[ ]?([-%w]*)");
		if (arg1 ~= "") then
			if (arg1 == "ui") then
				Perl_Target_Target_Set_ParentUI_Scale();
				return;
			end
			local number = tonumber(arg1);
			if (number > 0 and number < 150) then
				Perl_Target_Target_Set_Scale(number);
				return;
			else
				DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/ptt scale ui' to set to the current UI scale.");
				return;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("You need to specify a valid number. (1-149)  You may also do '/ptt scale ui' to set to the current UI scale.");
			return;
		end
	elseif (string.find(msg, "status")) then
		Perl_Target_Target_Status();
		return;
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Target of Target Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff tot |cffffff00- Toggle the Target of Target frame.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff totot |cffffff00- Toggle the Target of Target of Target frame.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff health |cffffff00- Toggle the displaying of progressively colored health bars.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff mobhealth |cffffff00- Toggle the displaying of integrated MobHealth support.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff scale # |cffffff00- Set the scale. (1-149) You may also do '/ptt scale ui' to set to the current UI scale.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
		return;
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Target_Target_Initialize()
	if (Initialized) then
		Perl_Target_Target_Set_Scale();		-- Set the scale
		Perl_Target_Target_Set_Transparency();	-- Set the transparency
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Target_Target_Config[UnitName("player")]) == "table") then
		Perl_Target_Target_GetVars();
	else
		Perl_Target_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Target_Target_Initialize_Frame_Color();
	Perl_Target_Target_Frame:Hide();
	Perl_Target_Target_Target_Frame:Hide();

	Initialized = 1;
end

function Perl_Target_Target_Initialize_Frame_Color()
	Perl_Target_Target_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Target_Target_ManaBarText:SetTextColor(1, 1, 1, 1);

	Perl_Target_Target_Target_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_Target_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Target_Target_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
end


--------------------------
-- The Update Functions --
--------------------------
function Perl_Target_Target_OnUpdate(arg1)
	Perl_Target_Target_Time_Elapsed = Perl_Target_Target_Time_Elapsed + arg1;
	if (Perl_Target_Target_Time_Elapsed > Perl_Target_Target_Time_Update_Rate) then
		Perl_Target_Target_Time_Elapsed = 0;

		if (UnitExists("targettarget") and totsupport == 1) then
			Perl_Target_Target_Frame:Show();			-- Show the frame

			-- Begin: Set the name
			local targettargetname = UnitName("targettarget");
			if (strlen(targettargetname) > 11) then
				targettargetname = strsub(targettargetname, 1, 10).."...";
			end
			Perl_Target_Target_NameBarText:SetText(targettargetname);
			-- End: Set the name

			-- Begin: Set the name text color
			if (UnitIsPlayer("targettarget") or UnitPlayerControlled("targettarget")) then		-- is it a player
				local r, g, b;
				if (UnitCanAttack("targettarget", "player")) then				-- are we in an enemy controlled zone
					-- Hostile players are red
					if (not UnitCanAttack("player", "targettarget")) then			-- enemy is not pvp enabled
						r = 0.5;
						g = 0.5;
						b = 1.0;
					else									-- enemy is pvp enabled
						r = 1.0;
						g = 0.0;
						b = 0.0;
					end
				elseif (UnitCanAttack("player", "targettarget")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
					-- Players we can attack but which are not hostile are yellow
					r = 1.0;
					g = 1.0;
					b = 0.0;
				elseif (UnitIsPVP("targettarget")) then						-- friendly pvp enabled character
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
				Perl_Target_Target_NameBarText:SetTextColor(r, g, b);
			elseif (UnitIsTapped("targettarget") and not UnitIsTappedByPlayer("targettarget")) then
				Perl_Target_Target_NameBarText:SetTextColor(0.5,0.5,0.5);			-- not our tap
			else
				local reaction = UnitReaction("targettarget", "player");
				if (reaction) then
					local r, g, b;
					r = UnitReactionColor[reaction].r;
					g = UnitReactionColor[reaction].g;
					b = UnitReactionColor[reaction].b;
					Perl_Target_Target_NameBarText:SetTextColor(r, g, b);
				else
					Perl_Target_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
				end
			end
			-- End: Set the name text color

			-- Begin: Update the health bar
			local targettargethealth = UnitHealth("targettarget");
			local targettargethealthmax = UnitHealthMax("targettarget");
			local targettargethealthpercent = floor(targettargethealth/targettargethealthmax*100+0.5);

			Perl_Target_Target_HealthBar:SetMinMaxValues(0, targettargethealthmax);
			Perl_Target_Target_HealthBar:SetValue(targettargethealth);

			if (colorhealth == 1) then
				if ((targettargethealthpercent <= 100) and (targettargethealthpercent > 75)) then
					Perl_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
					Perl_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
				elseif ((targettargethealthpercent <= 75) and (targettargethealthpercent > 50)) then
					Perl_Target_Target_HealthBar:SetStatusBarColor(1, 1, 0);
					Perl_Target_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
				elseif ((targettargethealthpercent <= 50) and (targettargethealthpercent > 25)) then
					Perl_Target_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
					Perl_Target_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
				else
					Perl_Target_Target_HealthBar:SetStatusBarColor(1, 0, 0);
					Perl_Target_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
				end
			else
				Perl_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
				Perl_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
			end

			if (mouseovertargettargethealthflag == 1) then
				Perl_Target_Target_HealthShow();
			else
				Perl_Target_Target_HealthBarText:SetText(targettargethealthpercent.."%");
			end
			-- End: Update the health bar

			-- Begin: Update the mana bar
			local targettargetmana = UnitMana("targettarget");
			local targettargetmanamax = UnitManaMax("targettarget");

			Perl_Target_Target_ManaBar:SetMinMaxValues(0, targettargetmanamax);
			Perl_Target_Target_ManaBar:SetValue(targettargetmana);

			if (mouseovertargettargetmanaflag == 1) then
				if (UnitPowerType("targettarget") == 1 or UnitPowerType("targettarget") == 2) then
					Perl_Target_Target_ManaBarText:SetText(targettargetmana);
				else
					Perl_Target_Target_ManaBarText:SetText(targettargetmana.."/"..targettargetmanamax);
				end
			else
				Perl_Target_Target_ManaBarText:Hide();
			end
			-- End: Update the mana bar

			-- Begin: Update the mana bar color
			local targettargetmanamax = UnitManaMax("targettarget");
			local targettargetpower = UnitPowerType("targettarget");

			-- Set mana bar color
			if (targettargetmanamax == 0) then
				Perl_Target_Target_ManaBar:Hide();
				Perl_Target_Target_ManaBarBG:Hide();
				Perl_Target_Target_StatsFrame:SetHeight(30);
			elseif (targettargetpower == 1) then
				Perl_Target_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
				Perl_Target_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
				Perl_Target_Target_ManaBar:Show();
				Perl_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_StatsFrame:SetHeight(42);
			elseif (targettargetpower == 2) then
				Perl_Target_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
				Perl_Target_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
				Perl_Target_Target_ManaBar:Show();
				Perl_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_StatsFrame:SetHeight(42);
			elseif (targettargetpower == 3) then
				Perl_Target_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
				Perl_Target_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
				Perl_Target_Target_ManaBar:Show();
				Perl_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_StatsFrame:SetHeight(42);
			else
				Perl_Target_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
				Perl_Target_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
				Perl_Target_Target_ManaBar:Show();
				Perl_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_StatsFrame:SetHeight(42);
			end
			-- End: Update the mana bar color
		else
			Perl_Target_Target_Frame:Hide();			-- Hide the frame
		end

		if (UnitExists("targettargettarget") and tototsupport == 1) then
			Perl_Target_Target_Target_Frame:Show();			-- Show the frame

			-- Begin: Set the name
			local targettargettargetname = UnitName("targettargettarget");
			if (strlen(targettargettargetname) > 11) then
				targettargettargetname = strsub(targettargettargetname, 1, 10).."...";
			end
			Perl_Target_Target_Target_NameBarText:SetText(targettargettargetname);
			-- End: Set the name

			-- Begin: Set the name text color
			if (UnitIsPlayer("targettargettarget") or UnitPlayerControlled("targettargettarget")) then	-- is it a player
				local r, g, b;
				if (UnitCanAttack("targettargettarget", "player")) then					-- are we in an enemy controlled zone
					-- Hostile players are red
					if (not UnitCanAttack("player", "targettargettarget")) then			-- enemy is not pvp enabled
						r = 0.5;
						g = 0.5;
						b = 1.0;
					else										-- enemy is pvp enabled
						r = 1.0;
						g = 0.0;
						b = 0.0;
					end
				elseif (UnitCanAttack("player", "targettargettarget")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
					-- Players we can attack but which are not hostile are yellow
					r = 1.0;
					g = 1.0;
					b = 0.0;
				elseif (UnitIsPVP("targettargettarget")) then						-- friendly pvp enabled character
					-- Players we can assist but are PvP flagged are green
					r = 0.0;
					g = 1.0;
					b = 0.0;
				else											-- friendly non pvp enabled character
					-- All other players are blue (the usual state on the "blue" server)
					r = 0.5;
					g = 0.5;
					b = 1.0;
				end
				Perl_Target_Target_Target_NameBarText:SetTextColor(r, g, b);
			elseif (UnitIsTapped("targettargettarget") and not UnitIsTappedByPlayer("targettargettarget")) then
				Perl_Target_Target_Target_NameBarText:SetTextColor(0.5,0.5,0.5);			-- not our tap
			else
				local reaction = UnitReaction("targettargettarget", "player");
				if (reaction) then
					local r, g, b;
					r = UnitReactionColor[reaction].r;
					g = UnitReactionColor[reaction].g;
					b = UnitReactionColor[reaction].b;
					Perl_Target_Target_Target_NameBarText:SetTextColor(r, g, b);
				else
					Perl_Target_Target_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
				end
			end
			-- End: Set the name text color

			-- Begin: Update the health bar
			local targettargettargethealth = UnitHealth("targettargettarget");
			local targettargettargethealthmax = UnitHealthMax("targettargettarget");
			local targettargettargethealthpercent = floor(targettargettargethealth/targettargettargethealthmax*100+0.5);

			Perl_Target_Target_Target_HealthBar:SetMinMaxValues(0, targettargettargethealthmax);
			Perl_Target_Target_Target_HealthBar:SetValue(targettargettargethealth);

			if (colorhealth == 1) then
				if ((targettargettargethealthpercent <= 100) and (targettargettargethealthpercent > 75)) then
					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
				elseif ((targettargettargethealthpercent <= 75) and (targettargettargethealthpercent > 50)) then
					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(1, 1, 0);
					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
				elseif ((targettargettargethealthpercent <= 50) and (targettargettargethealthpercent > 25)) then
					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
				else
					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(1, 0, 0);
					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
				end
			else
				Perl_Target_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
				Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
			end

			if (mouseovertargettargettargethealthflag == 1) then
				Perl_Target_Target_Target_HealthShow();
			else
				Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealthpercent.."%");
			end
			-- End: Update the health bar

			-- Begin: Update the mana bar
			local targettargettargetmana = UnitMana("targettargettarget");
			local targettargettargetmanamax = UnitManaMax("targettargettarget");

			Perl_Target_Target_Target_ManaBar:SetMinMaxValues(0, targettargettargetmanamax);
			Perl_Target_Target_Target_ManaBar:SetValue(targettargettargetmana);

			if (mouseovertargettargettargetmanaflag == 1) then
				if (UnitPowerType("targettargettarget") == 1 or UnitPowerType("targettargettarget") == 2) then
					Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana);
				else
					Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana.."/"..targettargettargetmanamax);
				end
			else
				Perl_Target_Target_Target_ManaBarText:Hide();
			end
			-- End: Update the mana bar

			-- Begin: Update the mana bar color
			local targettargettargetmanamax = UnitManaMax("targettargettarget");
			local targettargettargetpower = UnitPowerType("targettargettarget");

			-- Set mana bar color
			if (targettargettargetmanamax == 0) then
				Perl_Target_Target_Target_ManaBar:Hide();
				Perl_Target_Target_Target_ManaBarBG:Hide();
				Perl_Target_Target_Target_StatsFrame:SetHeight(30);
			elseif (targettargettargetpower == 1) then
				Perl_Target_Target_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
				Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
				Perl_Target_Target_Target_ManaBar:Show();
				Perl_Target_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_Target_StatsFrame:SetHeight(42);
			elseif (targettargettargetpower == 2) then
				Perl_Target_Target_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
				Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
				Perl_Target_Target_Target_ManaBar:Show();
				Perl_Target_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_Target_StatsFrame:SetHeight(42);
			elseif (targettargettargetpower == 3) then
				Perl_Target_Target_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
				Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
				Perl_Target_Target_Target_ManaBar:Show();
				Perl_Target_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_Target_StatsFrame:SetHeight(42);
			else
				Perl_Target_Target_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
				Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
				Perl_Target_Target_Target_ManaBar:Show();
				Perl_Target_Target_Target_ManaBarBG:Show();
				Perl_Target_Target_Target_StatsFrame:SetHeight(42);
			end
			-- End: Update the mana bar color
		else
			Perl_Target_Target_Target_Frame:Hide();			-- Hide the frame
		end

	end
end


-------------------------
-- Mouseover Functions --
-------------------------
-- Target of Target Start
function Perl_Target_Target_HealthShow()
	local targettargethealth = UnitHealth("targettarget");
	local targettargethealthmax = UnitHealthMax("targettarget");

	if (targettargethealth < 0) then			-- This prevents negative health
		targettargethealth = 0;
	end

	if (targettargethealthmax == 100) then
		-- Begin Mobhealth support
		if (mobhealthsupport == 1) then
			if (MobHealthFrame) then

				local index;
				if UnitIsPlayer("targettarget") then
					index = UnitName("targettarget");
				else
					index = UnitName("targettarget")..":"..UnitLevel("targettarget");
				end

				if ((MobHealthDB and MobHealthDB[index]) or (MobHealthPlayerDB and MobHealthPlayerDB[index])) then
					local s, e;
					local pts;
					local pct;

					if MobHealthDB[index] then
						if (type(MobHealthDB[index]) ~= "string") then
							Perl_Target_Target_HealthBarText:SetText(targettargethealth.."%");
						end
						s, e, pts, pct = string.find(MobHealthDB[index], "^(%d+)/(%d+)$");
					else
						if (type(MobHealthPlayerDB[index]) ~= "string") then
							Perl_Target_Target_HealthBarText:SetText(targettargethealth.."%");
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

					local currentPct = UnitHealth("targettarget");
					if (pointsPerPct > 0) then
						Perl_Target_Target_HealthBarText:SetText(string.format("%d", (currentPct * pointsPerPct) + 0.5).."/"..string.format("%d", (100 * pointsPerPct) + 0.5));	-- Stored unit info from the DB
					end
				else
					Perl_Target_Target_HealthBarText:SetText(targettargethealth.."%");	-- Unit not in MobHealth DB
				end
			-- End MobHealth Support
			else
				Perl_Target_Target_HealthBarText:SetText(targettargethealth.."%");	-- MobHealth isn't installed
			end
		else	-- mobhealthsupport == 0
			Perl_Target_Target_HealthBarText:SetText(targettargethealth.."%");	-- MobHealth support is disabled
		end
	else
		Perl_Target_Target_HealthBarText:SetText(targettargethealth.."/"..targettargethealthmax);	-- Self/Party/Raid member
	end

	mouseovertargettargethealthflag = 1;
end

function Perl_Target_Target_HealthHide()
	local targettargethealthpercent = floor(UnitHealth("targettarget")/UnitHealthMax("targettarget")*100+0.5);
	Perl_Target_Target_HealthBarText:SetText(targettargethealthpercent.."%");
	mouseovertargettargethealthflag = 0;
end

function Perl_Target_Target_ManaShow()
	local targettargetmana = UnitMana("targettarget");
	local targettargetmanamax = UnitManaMax("targettarget");
	if (UnitPowerType("targettarget") == 1) then
		Perl_Target_Target_ManaBarText:SetText(targettargetmana);
	else
		Perl_Target_Target_ManaBarText:SetText(targettargetmana.."/"..targettargetmanamax);
	end
	Perl_Target_Target_ManaBarText:Show();
	mouseovertargettargetmanaflag = 1;
end

function Perl_Target_Target_ManaHide()
	Perl_Target_Target_ManaBarText:Hide();
	mouseovertargettargetmanaflag = 0;
end
-- Target of Target End

-- Target of Target of Target Start
function Perl_Target_Target_Target_HealthShow()
	local targettargettargethealth = UnitHealth("targettargettarget");
	local targettargettargethealthmax = UnitHealthMax("targettargettarget");

	if (targettargettargethealth < 0) then			-- This prevents negative health
		targettargettargethealth = 0;
	end

	if (targettargettargethealthmax == 100) then
		-- Begin Mobhealth support
		if (mobhealthsupport == 1) then
			if (MobHealthFrame) then

				local index;
				if UnitIsPlayer("targettargettarget") then
					index = UnitName("targettargettarget");
				else
					index = UnitName("targettargettarget")..":"..UnitLevel("targettargettarget");
				end

				if ((MobHealthDB and MobHealthDB[index]) or (MobHealthPlayerDB and MobHealthPlayerDB[index])) then
					local s, e;
					local pts;
					local pct;

					if MobHealthDB[index] then
						if (type(MobHealthDB[index]) ~= "string") then
							Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."%");
						end
						s, e, pts, pct = string.find(MobHealthDB[index], "^(%d+)/(%d+)$");
					else
						if (type(MobHealthPlayerDB[index]) ~= "string") then
							Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."%");
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

					local currentPct = UnitHealth("targettargettarget");
					if (pointsPerPct > 0) then
						Perl_Target_Target_Target_HealthBarText:SetText(string.format("%d", (currentPct * pointsPerPct) + 0.5).."/"..string.format("%d", (100 * pointsPerPct) + 0.5));	-- Stored unit info from the DB
					end
				else
					Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."%");	-- Unit not in MobHealth DB
				end
			-- End MobHealth Support
			else
				Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."%");	-- MobHealth isn't installed
			end
		else	-- mobhealthsupport == 0
			Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."%");	-- MobHealth support is disabled
		end
	else
		Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."/"..targettargettargethealthmax);	-- Self/Party/Raid member
	end

	mouseovertargettargettargethealthflag = 1;
end

function Perl_Target_Target_Target_HealthHide()
	local targettargettargethealthpercent = floor(UnitHealth("targettargettarget")/UnitHealthMax("targettargettarget")*100+0.5);
	Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealthpercent.."%");
	mouseovertargettargettargethealthflag = 0;
end

function Perl_Target_Target_Target_ManaShow()
	local targettargettargetmana = UnitMana("targettargettarget");
	local targettargettargetmanamax = UnitManaMax("targettargettarget");
	if (UnitPowerType("targettargettarget") == 1) then
		Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana);
	else
		Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana.."/"..targettargettargetmanamax);
	end
	Perl_Target_Target_Target_ManaBarText:Show();
	mouseovertargettargettargetmanaflag = 1;
end

function Perl_Target_Target_Target_ManaHide()
	Perl_Target_Target_Target_ManaBarText:Hide();
	mouseovertargettargettargetmanaflag = 0;
end
-- Target of Target of Target End


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Target_Target_Set_ToT(newvalue)
	totsupport = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_ToToT(newvalue)
	tototsupport = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_MobHealth(newvalue)
	mobhealthsupport = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Progressive_Color(newvalue)
	colorhealth = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		scale = (number / 100);					-- convert the user input to a wow acceptable value
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Display is now scaled to |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");	-- only display if the user gave us a number
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Target_Target_Frame:SetScale(unsavedscale);
	Perl_Target_Target_Target_Frame:SetScale(unsavedscale);
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);				-- convert the user input to a wow acceptable value
	end
	Perl_Target_Target_Frame:SetAlpha(transparency);
	Perl_Target_Target_Target_Frame:SetAlpha(transparency);
	Perl_Target_Target_UpdateVars();
end


----------------------
-- Config functions --
----------------------
function Perl_Target_Target_Lock()
	locked = 1;
	Perl_Target_Target_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now |cffffffffLocked|cffffff00.");
end

function Perl_Target_Target_Unlock()
	locked = 0;
	Perl_Target_Target_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now |cffffffffUnlocked|cffffff00.");
end

function Perl_Target_Target_ToggleToT()
	if (totsupport == 1) then
		totsupport = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now |cffffffffHiding Target of Target Frame|cffffff00.");
	else
		totsupport = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now |cffffffffDisplaying Target of Target Frame|cffffff00.");
	end
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_ToggleToToT()
	if (tototsupport == 1) then
		tototsupport = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now |cffffffffHiding Target of Target of Target Frame|cffffff00.");
	else
		tototsupport = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now |cffffffffDisplaying Target of Target of Target Frame|cffffff00.");
	end
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_ToggleMobHealth()
	if (mobhealthsupport == 1) then
		mobhealthsupport = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame MobHealth support is now |cffffffffDisabled|cffffff00.");
	else
		mobhealthsupport = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame MobHealth support is now |cffffffffEnabled|cffffff00.");
	end
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_ToggleColoredHealth()
	if (colorhealth == 1) then
		colorhealth = 0;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		colorhealth = 1;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is now displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_ParentUI_Scale()
	local unsavedscale;
	scale = UIParent:GetEffectiveScale();
	unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
	Perl_Target_Target_Frame:SetScale(unsavedscale);
	Perl_Target_Target_Target_Frame:SetScale(unsavedscale);
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Display is now scaled to |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Status()
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is |cffffffffLocked|cffffff00.");
	end

	if (totsupport == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is |cffffffffHiding Target of Target|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is |cffffffffDisplaying Target of Target|cffffff00.");
	end

	if (tototsupport == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is |cffffffffHiding Target of Target of Target|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is |cffffffffDisplaying Target of Target of Target|cffffff00.");
	end

	if (colorhealth == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is displaying |cffffffffSingle Colored Health Bars|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is displaying |cffffffffProgressively Colored Health Bars|cffffff00.");
	end

	if (mobhealthsupport == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame Class Frame has MobHealth support |cffffffffDisabled|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame Class Frame has MobHealth support |cffffffffEnabled|cffffff00.");
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Target of Target Frame is displaying at a scale of |cffffffff"..floor(scale * 100 + 0.5).."%|cffffff00.");
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Target_Target_GetVars()
	colorhealth = Perl_Target_Target_Config[UnitName("player")]["ColorHealth"];
	locked = Perl_Target_Target_Config[UnitName("player")]["Locked"];
	mobhealthsupport = Perl_Target_Target_Config[UnitName("player")]["MobHealthSupport"];
	scale = Perl_Target_Target_Config[UnitName("player")]["Scale"];
	totsupport = Perl_Target_Target_Config[UnitName("player")]["ToTSupport"];
	tototsupport = Perl_Target_Target_Config[UnitName("player")]["ToToTSupport"];
	transparency = Perl_Target_Target_Config[UnitName("player")]["Transparency"];

	if (colorhealth == nil) then
		colorhealth = 0;
	end
	if (locked == nil) then
		locked = 0;
	end
	if (mobhealthsupport == nil) then
		mobhealthsupport = 1;
	end
	if (scale == nil) then
		scale = 1;
	end
	if (totsupport == nil) then
		totsupport = 1;
	end
	if (tototsupport == nil) then
		tototsupport = 1;
	end
	if (transparency == nil) then
		transparency = 1;
	end

	local vars = {
		["colorhealth"] = colorhealth,
		["locked"] = locked,
		["mobhealthsupport"] = mobhealthsupport,
		["scale"] = scale,
		["totsupport"] = totsupport,
		["tototsupport"] = tototsupport,
		["transparency"] = transparency,
	}
	return vars;
end

function Perl_Target_Target_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["ColorHealth"] ~= nil) then
				colorhealth = vartable["Global Settings"]["ColorHealth"];
			else
				colorhealth = nil;
			end
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["MobHealthSupport"] ~= nil) then
				mobhealthsupport = vartable["Global Settings"]["MobHealthSupport"];
			else
				mobhealthsupport = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["ToTSupport"] ~= nil) then
				totsupport = vartable["Global Settings"]["ToTSupport"];
			else
				totsupport = nil;
			end
			if (vartable["Global Settings"]["ToToTSupport"] ~= nil) then
				tototsupport = vartable["Global Settings"]["ToToTSupport"];
			else
				tototsupport = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (colorhealth == nil) then
			colorhealth = 0;
		end
		if (locked == nil) then
			locked = 0;
		end
		if (mobhealthsupport == nil) then
			mobhealthsupport = 1;
		end
		if (scale == nil) then
			scale = 1;
		end
		if (totsupport == nil) then
			totsupport = 1;
		end
		if (tototsupport == nil) then
			tototsupport = 1;
		end
		if (transparency == nil) then
			transparency = 1;
		end

		-- Call any code we need to activate them
		Perl_Target_Target_Set_Scale();
		Perl_Target_Target_Set_Transparency();
	end

	Perl_Target_Target_Config[UnitName("player")] = {
		["ColorHealth"] = colorhealth,
		["Locked"] = locked,
		["MobHealthSupport"] = mobhealthsupport,
		["Scale"] = scale,
		["ToTSupport"] = totsupport,
		["ToToTSupport"] = tototsupport,
		["Transparency"] = transparency,
	};
end


--------------------
-- Click Handlers --
--------------------
-- Target of Target Start
function Perl_TargetTargetDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_TargetTargetDropDown_Initialize, "MENU");
end

function Perl_TargetTargetDropDown_Initialize()
	local menu = nil;
	if (UnitIsEnemy("targettarget", "player")) then
		return;
	end
	if (UnitIsUnit("targettarget", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("targettarget", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("targettarget")) then
		if (UnitInParty("targettarget")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Target_Target_DropDown, menu, "targettarget");
	end
end

function Perl_Target_Target_MouseUp(button)
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("targettarget");
		elseif (CursorHasItem()) then
			DropItemOnUnit("targettarget");
		else
			TargetUnit("targettarget");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_Target_Target_DropDown, "Perl_Target_Target_NameFrame", 40, 0);
	end

	Perl_Target_Target_Frame:StopMovingOrSizing();
end

function Perl_Target_Target_MouseDown(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Target_Target_Frame:StartMoving();
	end
end
-- Target of Target End

-- Target of Target of Target Start
function Perl_TargetTargetTargetDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_TargetTargetTargetDropDown_Initialize, "MENU");
end

function Perl_TargetTargetTargetDropDown_Initialize()
	local menu = nil;
	if (UnitIsEnemy("targettargettarget", "player")) then
		return;
	end
	if (UnitIsUnit("targettargettarget", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("targettargettarget", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("targettargettarget")) then
		if (UnitInParty("targettargettarget")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Target_Target_Target_DropDown, menu, "targettargettarget");
	end
end

function Perl_Target_Target_Target_MouseUp(button)
	if (SpellIsTargeting() and button == "RightButton") then
		SpellStopTargeting();
		return;
	end
	if (button == "LeftButton") then
		if (SpellIsTargeting()) then
			SpellTargetUnit("targettargettarget");
		elseif (CursorHasItem()) then
			DropItemOnUnit("targettargettarget");
		else
			TargetUnit("targettargettarget");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_Target_Target_Target_DropDown, "Perl_Target_Target_Target_NameFrame", 40, 0);
	end

	Perl_Target_Target_Target_Frame:StopMovingOrSizing();
end

function Perl_Target_Target_Target_MouseDown(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Target_Target_Target_Frame:StartMoving();
	end
end
-- Target of Target of Target End


-------------
-- Tooltip --
-------------
function Perl_Target_Target_Tip()
	UnitFrame_Initialize("targettarget")
end

function Perl_Target_Target_Target_Tip()
	UnitFrame_Initialize("targettargettarget")
end

function UnitFrame_Initialize(unit)	-- Hopefully this doesn't break any mods
	this.unit = unit;
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Target_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Target_Target_myAddOns_Details = {
			name = "Perl_Target_Target",
			version = "v0.36",
			releaseDate = "January 25, 2006",
			author = "Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Target_Target_myAddOns_Help = {};
		Perl_Target_Target_myAddOns_Help[1] = "/perltargettarget\n/ptt\n";
		myAddOnsFrame_Register(Perl_Target_Target_myAddOns_Details, Perl_Target_Target_myAddOns_Help);
	end
end