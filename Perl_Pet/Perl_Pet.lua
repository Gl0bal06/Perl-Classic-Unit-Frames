---------------
-- Variables --
---------------
Perl_Pet_Config = {};

-- Defaults
local Perl_Pet_State = 1;
local locked = 0;		-- unlocked by default
local transparency = 1;		-- 0.8 default from perl
local BlizzardPetFrame_Update = PetFrame_Update;	-- backup the original target function in case we toggle the mod off


----------------------
-- Loading Function --
----------------------
function Perl_Pet_OnLoad()
	-- Events

	
	
--	this:RegisterEvent("UNIT_COMBAT");
--	this:RegisterEvent("UNIT_SPELLMISS");
--	this:RegisterEvent("PET_ATTACK_START");
--	this:RegisterEvent("PET_ATTACK_STOP");
	

	
	this:RegisterEvent("ADDON_LOADED"); --
	this:RegisterEvent("PLAYER_ENTERING_WORLD"); --
	this:RegisterEvent("PLAYER_PET_CHANGED"); --
	this:RegisterEvent("UNIT_AURA"); --
	this:RegisterEvent("UNIT_DISPLAYPOWER"); --
	this:RegisterEvent("UNIT_ENERGY"); --
	this:RegisterEvent("UNIT_HAPPINESS"); --
	this:RegisterEvent("UNIT_HEALTH"); --
	this:RegisterEvent("UNIT_LEVEL"); --
	this:RegisterEvent("UNIT_MANA"); --
	this:RegisterEvent("UNIT_PET"); --
	this:RegisterEvent("UNIT_RAGE"); --
	this:RegisterEvent("VARIABLES_LOADED"); --


	-- Slash Commands
	SlashCmdList["PERL_PET"] = Perl_Pet_SlashHandler;
	SLASH_PERL_PET1 = "/PerlPlayerPet";
	SLASH_PERL_PET2 = "/PPP";

	table.insert(UnitPopupFrames,"Perl_Player_Pet_DropDown");

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Pet Frame by Perl loaded successfully.");
	end
	UIErrorsFrame:AddMessage("|cffffff00Pet Frame by Perl loaded successfully.", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);
end


-------------------
-- Event Handler --
-------------------
function Perl_Pet_OnEvent(event)
	if (Perl_Pet_State == 0) then
		return;
	else
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   ---Perl_Player_Pet_Frame:Event is "..event.." ---");
		if (event == "UNIT_HEALTH" and arg1 == "pet") then
			Perl_Pet_Update_Health();		-- Update health values
			return;
		elseif ((event == "UNIT_ENERGY" and arg1 == "playerpet") or (event == "UNIT_MANA" and arg1 == "pet") or (event == "UNIT_RAGE" and arg1 == "pet")) then
			Perl_Pet_Update_Mana();			-- Update energy/mana/rage values
			return;
		elseif (event == "UNIT_DISPLAYPOWER" and arg1 == "pet") then
			Perl_Pet_Update_Mana_Bar();		-- What type of energy are we using now?
			Perl_Pet_Update_Mana();			-- Update the energy info immediately
			return;
		elseif (event == "UNIT_AURA" and arg1 == "pet") then
			Perl_Player_Pet_Buff_UpdateAll();
			return;
		elseif (event == "UNIT_HAPPINESS") then
			Perl_Player_PetFrame_SetHappiness();
			Perl_Pet_Update_Mana();			-- Update energy/mana/rage values (because unit_energy doesnt seem to work)
			return;
		elseif (event == "UNIT_LEVEL" and arg1 == "pet") then
			Perl_Pet_Set_Level();		-- What level is the pet
			return;
		elseif (event == "PLAYER_PET_CHANGED" or (event == "UNIT_PET" and arg1 == "player")) then
			Perl_Player_Pet_UpdateDisplay();
			return;
		elseif (event == "VARIABLES_LOADED") or (event=="PLAYER_ENTERING_WORLD") then
			Perl_Pet_Initialize();
			Perl_Player_Pet_UpdateDisplay();
			return;
		elseif (event == "ADDON_LOADED" and arg1 == "Perl_Pet") then
			Perl_Pet_myAddOns_Support();
			return;
		else
			return;
		end
	end
	--Perl_Player_Pet_UpdateDisplay();
end


-------------------
-- Slash Handler --
-------------------
function Perl_Pet_SlashHandler(msg)
	if (string.find(msg, "unlock")) then
		Perl_Player_Pet_Lock();
	elseif (string.find(msg, "lock")) then
		Perl_Player_Pet_Unlock();
--	elseif (string.find(msg, "status")) then
--		Perl_Player_Pet_Status();
--	--elseif (string.find(msg, "hideart")) then
--		--Perl_Player_ToggleHideBarArt();
--	--elseif (string.find(msg, "buff")) then
--		--Perl_Player_ToggleBuffs();
--	--elseif (string.find(msg, "alert")) then
--		--Perl_Player_ToggleBuffAlerts();
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   --- Perl Player Pet Frame ---");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff lock |cffffff00- Lock the frame in place.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff unlock |cffffff00- Unlock the frame so it can be moved.");
		DEFAULT_CHAT_FRAME:AddMessage("|cffffffff status |cffffff00- Show the current settings.");
	end
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Pet_Initialize() 
	-- Major config options.
	Perl_Player_Pet_StatsFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_Pet_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_LevelFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_Pet_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_NameFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_Pet_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_Pet_BuffFrame:SetBackdropColor(0, 0, 0, transparency);
	Perl_Player_Pet_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	
	Perl_Player_Pet_HealthBarText:SetTextColor(1,1,1,1);
	Perl_Player_Pet_ManaBarText:SetTextColor(1,1,1,1);
	
	
--	if (getglobal('PERL_COMMON')) then
--		Perl_Player_Pet_HealthBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--		Perl_Player_Pet_ManaBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--	end

	--Perl_Player_Pet_Frame:Show();
	Perl_Player_Pet_UpdateDisplay();

--	if (Perl_Pet_State == 1) then
--		PetFrame_Update = Perl_Player_Pet_UpdateDisplay;
--	else
--		Perl_Player_Pet_Frame:Hide();
--		PetFrame_Update = BlizzardPetFrame_Update;
--	end

	Initialized = 1;

end


-------------------------
-- The Update Function --
-------------------------
function Perl_Player_Pet_UpdateDisplay()
	if ( UnitExists("pet") ) then
--		if ( Perl_Player_Pet_Frame:IsVisible() ) then
--			--UnitFrame_Update();
--		else
--			Perl_Player_Pet_Frame:Show();
--			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   ---Perl_Player_Pet_Frame:Show(); should be shown ---");
--		end
--		--this.flashState = 1;
--		--this.flashTimer = PET_FLASH_ON_TIME;
--		if ( UnitManaMax("pet") == 0 ) then
--			--PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame-NoMana");
--		else
--			--PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame");
--		end

		--PetFrame_SetHappiness();
		Perl_Player_Pet_Frame:Show();
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   ---Perl_Player_Pet_Frame:Show(); should be shown ---");
	else
		Perl_Player_Pet_Frame:Hide();
		--DEFAULT_CHAT_FRAME:AddMessage("|cffffff00   ---Perl_Player_Pet_Frame:Hide(); should be hidden ---");
	end


	-- Set Statistics
	Perl_Player_Pet_NameBarText:SetText(UnitName("pet"));	-- Set name
	Perl_Pet_Set_Level();					-- Set level
	Perl_Pet_Update_Health();				-- Set health
	Perl_Pet_Update_Mana();					-- Set mana values
	Perl_Pet_Update_Mana_Bar();				-- Set the type of mana
	Perl_Player_PetFrame_SetHappiness();			-- Set Happiness
	Perl_Player_Pet_Buff_UpdateAll();			-- Set buff frame
end

function Perl_Pet_Update_Health()
	local pethealth = UnitHealth("pet");
	local pethealthmax = UnitHealthMax("pet");
	
	Perl_Player_Pet_HealthBar:SetMinMaxValues(0, pethealthmax);
	Perl_Player_Pet_HealthBar:SetValue(pethealth);

	if (pethealthmax == 100) then
		Perl_Player_Pet_HealthBarText:SetText(pethealth.."%");
	else
		Perl_Player_Pet_HealthBarText:SetText(pethealth.."/"..pethealthmax);
	end
end

function Perl_Pet_Update_Mana()
	local petmana = UnitMana("pet");
	local petmanamax = UnitManaMax("pet");
	
	Perl_Player_Pet_ManaBar:SetMinMaxValues(0, petmanamax);
	Perl_Player_Pet_ManaBar:SetValue(petmana);

	if (petmanamax == 100) then
		Perl_Player_Pet_ManaBarText:SetText(petmana.."%");
	else
		Perl_Player_Pet_ManaBarText:SetText(petmana.."/"..petmanamax);
	end
end

function Perl_Pet_Update_Mana_Bar()
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

function Perl_Pet_Set_Level()
	local petlevel = UnitLevel("pet");
	-- Set Level
	Perl_Player_Pet_LevelBarText:SetText(petlevel);
end


----------------------
-- Config functions --
----------------------
function Perl_Player_Pet_Lock()
	locked = 1;
	Perl_Player_Pet_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cfffffffflocked|cffffff00.");
end

function Perl_Player_Pet_Unlock()
	locked = 0;
	Perl_Player_Pet_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cffffffffunlocked|cffffff00.");
end

function Perl_Player_Pet_Status()
	if (locked == 0) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffUnlocked|cffffff00.");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Frame is |cffffffffLocked|cffffff00.");
	end
end


--------------------
-- Buff Functions --
--------------------
function Perl_Player_Pet_Buff_UpdateAll()
	if (UnitName("pet")) then
		local buffmax = 0;
		for buffnum=1,12 do
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
		
		buffmapping = buffmax;
		
		debuffmax = 13 - buffmapping;
		
		for buffnum=1,debuffmax do
			local button = getglobal("Perl_Player_Pet_Buff"..(buffnum+buffmapping));
			local icon = getglobal(button:GetName().."Icon");
			local debuff = getglobal(button:GetName().."DebuffBorder");
			
			if (UnitDebuff("pet", buffnum)) then
				icon:SetTexture(UnitDebuff("pet", buffnum));
				button.isdebuff = 1;
				debuff:Show();
				button:Show();
				buffmax = buffnum+buffmapping;
			else
				button:Hide();
			end
		end
			
		
		if (buffmax == 0) then
			Perl_Player_Pet_BuffFrame:Hide();
		else
			Perl_Player_Pet_BuffFrame:Show();
			Perl_Player_Pet_BuffFrame:SetWidth(5 + buffmax*29);
		end
	end
end

function Perl_Player_Pet_SetBuffTooltip ()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
	if (this.isdebuff == 1) then
		GameTooltip:SetUnitDebuff("pet", this:GetID()-buffmapping);
	else
		GameTooltip:SetUnitBuff("pet", this:GetID());
	end
end


---------------
-- Happiness --
---------------
function Perl_Player_PetFrame_SetHappiness()
	local happiness, damagePercentage, loyaltyRate = GetPetHappiness();
	
	if ( happiness == 1 ) then
		Perl_Player_PetHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
	elseif ( happiness == 2 ) then
		Perl_Player_PetHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
	elseif ( happiness == 3 ) then
		Perl_Player_PetHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
	end
	if ( happiness ~= nil ) then
		Perl_Player_PetHappiness.tooltip = getglobal("PET_HAPPINESS"..happiness);
		Perl_Player_PetHappiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
		if ( loyaltyRate < 0 ) then
			Perl_Player_PetHappiness.tooltipLoyalty = getglobal("LOSING_LOYALTY");
		elseif ( loyaltyRate > 0 ) then
			Perl_Player_PetHappiness.tooltipLoyalty = getglobal("GAINING_LOYALTY");
		else
			Perl_Player_PetHappiness.tooltipLoyalty = nil;
		end
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Player_Pet_DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, Perl_Player_Pet_DropDown_Initialize, "MENU");
end
				
function Perl_Player_Pet_DropDown_Initialize ()
	if (PetCanBeRenamed()) then
		UnitPopup_ShowMenu(Perl_Player_Pet_DropDown, "PET_RENAME", "pet");
	else
		UnitPopup_ShowMenu(Perl_Player_Pet_DropDown, "PET", "pet");
	end
--	local menu = nil
--	if ( UnitIsUnit("target", "pet") ) then
--		menu = "PET";
--	end
--	if ( menu ) then
--		UnitPopup_ShowMenu(Perl_Player_Pet_DropDown, menu, "pet");
--	end
end

function Perl_Player_Pet_MouseUp(button)

	if ( SpellIsTargeting() and button == "RightButton" ) then
		SpellStopTargeting();
		return;
	end
	if ( button == "LeftButton" ) then
		if ( SpellIsTargeting() ) then
			SpellTargetUnit("pet");
		else
			TargetUnit("pet");
		end
	else
		ToggleDropDownMenu(1, nil, Perl_Player_Pet_DropDown, "Perl_Player_Pet_NameFrame", 40, 0);
	end
	
	Perl_Player_Pet_Frame:StopMovingOrSizing();
end

function Perl_Player_Pet_MouseDown(button)
	if ( button == "LeftButton" and locked == 0) then
		Perl_Player_Pet_Frame:StartMoving();
	end
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Pet_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_Pet_myAddOns_Details = {
			name = "Perl_Pet",
			version = "v0.06",
			releaseDate = "October 16, 2005",
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Pet_myAddOns_Help = {};
		Perl_Pet_myAddOns_Help[1] = "/perlplayerpet\n/ppp\n";
		myAddOnsFrame_Register(Perl_Pet_myAddOns_Details, Perl_Pet_myAddOns_Help);
	end
end