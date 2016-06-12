-----------------------------------
-- Default options setup for now --
-----------------------------------
Perl_CombatDisplay_Options_VariableList = {
					["state"] = 3,
					["manapersist"] = 0,
					["healthpersist"] = 0,
					["locked"] = 0,
					["partyspacing"] = -80,
					["scale"] = 1,
}

Perl_CombatDisplay_Options_Text = {
	[1] = {
		["GROUP"] = "CombatDisplay",
		["NAME"] = "state",
		["TEXT"] = "... always.",
		["TOOLTIP"] = "Enables or disables the use of CombatDisplay.",
		["RADIOGROUP"] = 1,
		["VALUE"] = 1,
	},
	[2] = {
		["GROUP"] = "CombatDisplay",
		["NAME"] = "state",
		["TEXT"] = "... with auto-attack.",
		["TOOLTIP"] = "Enables or disables the use of CombatDisplay.",
		["RADIOGROUP"] = 1,
		["VALUE"] = 2,
	},
	[3] = {
		["GROUP"] = "CombatDisplay",
		["NAME"] = "state",
		["TEXT"] = "... on aggro.",
		["TOOLTIP"] = "Enables or disables the use of CombatDisplay.",
		["RADIOGROUP"] = 1,
		["VALUE"] = 3,
	},
	[4] = {
		["GROUP"] = "CombatDisplay",
		["NAME"] = "healthpersist",
		["TEXT"] = "Enable health-persistance.",
		["TOOLTIP"] = "",
		["RADIOGROUP"] = 0,
		["VALUE"] = 1,
	},
	[5] = {
		["GROUP"] = "CombatDisplay",
		["NAME"] = "manapersist",
		["TEXT"] = "Enable mana-persistance.",
		["TOOLTIP"] = "",
		["RADIOGROUP"] = 0,
		["VALUE"] = 1,
	},
	[6] = {
		["GROUP"] = "CombatDisplay",
		["NAME"] = "locked",
		["TEXT"] = "Lock CombatDisplay in place",
		["TOOLTIP"] = "",
		["RADIOGROUP"] = 0,
		["VALUE"] = 1,
	},
}

Perl_CombatDisplay_Options_RadioGroups = {
	[1] = {1, 2, 3},
}

Perl_CombatDisplay_Options_Buttons = {}
-- End Options -- 


---------------------
-- OnFoo functions --
---------------------
function Perl_CombatDisplay_Options_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function Perl_CombatDisplay_Options_OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		Perl_CombatDisplay_Options_LoadVars();
	end
end


-----------------------
-- Set up Checkboxes --
-----------------------
function Perl_CombatDisplay_Options_LoadVars()
	-- Set up checkboxes
	for i in Perl_CombatDisplay_Options_Text do
		checkbox = getglobal("Perl_CombatDisplay_Options_CheckOption"..i);
		checkboxtext = getglobal(checkbox:GetName().."Text");

		checkbox.id = i;
		checkbox.variable = Perl_CombatDisplay_Options_Text[i]["NAME"];
		checkbox.group = Perl_CombatDisplay_Options_Text[i]["GROUP"];
		checkbox.radiogroup = Perl_CombatDisplay_Options_Text[i]["RADIOGROUP"];
		checkbox.value = Perl_CombatDisplay_Options_Text[i]["VALUE"];
		checkboxtext:SetText(Perl_CombatDisplay_Options_Text[i]["TEXT"]);

		Perl_CombatDisplay_Options_Buttons[i] = checkbox;
	end
end


--------------------------------------
-- Make sure boxes are set properly --
--------------------------------------
function Perl_CombatDisplay_Options_OnShow()
		Perl_CombatDisplay_Options_VariableList = Perl_CombatDisplay_GetVars();

		if (Perl_CombatDisplay_Options_VariableList[this.variable] == this.value) then
			this:SetChecked(1);
		else
			this:SetChecked(0);
		end
end


---------------------------
-- When a box is checked --
---------------------------
function Perl_CombatDisplay_Options_BoxChecked()
	if (Perl_CombatDisplay_Options_VariableList[this.variable] == this.value) then
		this:SetChecked(0);
		Perl_CombatDisplay_Options_VariableList[this.variable] = 0;
	else
		if (this.radiogroup > 0) then
			for groupid in Perl_CombatDisplay_Options_RadioGroups[this.radiogroup] do
				Perl_CombatDisplay_Options_Buttons[groupid]:SetChecked(0);
			end
		end
		this:SetChecked(1);
		Perl_CombatDisplay_Options_VariableList[this.variable] = this.value;
	end

	Perl_CombatDisplay_SetVars(Perl_CombatDisplay_Options_VariableList);
	Perl_CombatDisplay_UpdateDisplay();
end


-------------------------
-- The Toggle Function --
-------------------------
function Perl_CombatDisplay_Options_Toggle()
	if (Perl_CombatDisplay_Options_Frame:IsVisible()) then
		Perl_CombatDisplay_Options_Frame:Hide();
	else
		Perl_CombatDisplay_Options_Frame:Show();
	end
end
