local Locked = 0;

local transparency = 0.8;

----------------------
-- Loading Function --
----------------------
function Perl_Player_Pet_OnLoad()

	-- Events
	this:RegisterEvent("UNIT_RAGE");
	this:RegisterEvent("UNIT_ENERGY");
	this:RegisterEvent("UNIT_MANA");
	this:RegisterEvent("UNIT_HEALTH");
	this:RegisterEvent("UNIT_LEVEL");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
		
	-- Slash Commands
	table.insert(UnitPopupFrames,"Perl_Player_Pet_DropDown");
end

-------------------
-- Event Handler --
-------------------
function Perl_Player_Pet_OnEvent(event)
	Perl_Player_Pet_UpdateDisplay();
end

-------------------------
-- The Update Function --
-------------------------
function Perl_Player_Pet_UpdateDisplay ()

	-- set common variables
	local petmana = UnitMana("pet");
	local petmanamax = UnitManaMax("pet");
	local pethealth = UnitHealth("pet");
	local pethealthmax = UnitHealthMax("pet");
	local petlevel = UnitLevel("pet");
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
	
	
	-- Set Statistics
	Perl_Player_Pet_HealthBar:SetMinMaxValues(0, pethealthmax);
	Perl_Player_Pet_ManaBar:SetMinMaxValues(0, petmanamax);
	
	Perl_Player_Pet_HealthBar:SetValue(pethealth);
	Perl_Player_Pet_ManaBar:SetValue(petmana);
	
	if (getglobal('PERL_COMMON')) then
		Perl_SetSmoothBarColor(Perl_Player_Pet_HealthBar);
		Perl_SetSmoothBarColor(Perl_Player_Pet_HealthBarBG, Perl_Player_Pet_HealthBar, 0.25);
	end
	
	-- Set Level
	Perl_Player_Pet_LevelBarText:SetText(petlevel);
	
	-- Set Happiness
	Perl_Player_PetFrame_SetHappiness();
	
	-- Set Text
	Perl_Player_Pet_HealthBarText:SetText(pethealth.."/"..pethealthmax);
	Perl_Player_Pet_ManaBarText:SetText(petmana.."/"..petmanamax);
	
end

----------------------
-- Config functions --
----------------------
function Perl_Player_Pet_Lock ()
	Locked = 1;
	Perl_Player_Pet_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cfffffffflocked|cffffff00.");
end

function Perl_Player_Pet_Unlock ()
	Locked = 0;
	Perl_Player_Pet_UpdateVars();
	DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Player Pet Frame is now |cffffffffunlocked|cffffff00.");
end

-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Player_Pet_VarInit() 

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
	
	-- Set name
	Perl_Player_Pet_NameBarText:SetText(UnitName("pet"));
	
--	if (getglobal('PERL_COMMON')) then
--		Perl_Player_Pet_HealthBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--		Perl_Player_Pet_ManaBarTex:SetTexture("Interface\\AddOns\\Perl_Common\\Perl_StatusBar.tga");
--	end

	Perl_Player_Pet_Frame:Show();  
	Perl_Player_Pet_UpdateDisplay();
	
end

--------------------
-- Buff Functions --
--------------------
function Perl_Player_Pet_Buff_UpdateAll ()
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
	if ( button == "LeftButton" and Locked == 0) then
		Perl_Player_Pet_Frame:StartMoving();
	end
end
