function Perl_Config_CombatDisplay_Display()
	Perl_Config_Hide_All();
	if (Perl_CombatDisplay_Frame) then
		Perl_Config_CombatDisplay_Frame:Show();
		Perl_Config_CombatDisplay_Set_Values();
	else
		Perl_Config_CombatDisplay_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_CombatDisplay_Set_Values()
	vartable = Perl_CombatDisplay_GetVars();

	if (vartable["state"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(1);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(nil);
	elseif (vartable["state"] == 2) then
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(1);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(nil);
	elseif (vartable["state"] == 3) then
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(1);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(nil);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton1:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton2:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton3:SetChecked(nil);
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(1);
	end

	if (vartable["healthpersist"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton5:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton5:SetChecked(nil);
	end

	if (vartable["manapersist"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton6:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton6:SetChecked(nil);
	end

	if (vartable["colorhealth"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton7:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton7:SetChecked(nil);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_CombatDisplay_Frame_CheckButton8:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton8:SetChecked(nil);
	end

	Perl_Config_CombatDisplay_Frame_Slider1Low:SetText("Small");
	Perl_Config_CombatDisplay_Frame_Slider1High:SetText("Big");
	Perl_Config_CombatDisplay_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(1);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(nil);
	end

	Perl_Config_CombatDisplay_Frame_Slider2Low:SetText("0");
	Perl_Config_CombatDisplay_Frame_Slider2High:SetText("100");
	Perl_Config_CombatDisplay_Frame_Slider2:SetValue(vartable["transparency"]*100);
end

function Perl_Config_CombatDisplay_Mode_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton1:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(1);
	elseif (Perl_Config_CombatDisplay_Frame_CheckButton2:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(2);
	elseif (Perl_Config_CombatDisplay_Frame_CheckButton3:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(3);
	elseif (Perl_Config_CombatDisplay_Frame_CheckButton4:GetChecked() == 1) then
		Perl_CombatDisplay_Set_State(0);
	else
		Perl_Config_CombatDisplay_Frame_CheckButton4:SetChecked(1);
		Perl_CombatDisplay_Set_State(0);
	end
end

function Perl_Config_CombatDisplay_Health_Persistance_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton5:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Health_Persistance(1);
	else
		Perl_CombatDisplay_Set_Health_Persistance(0);
	end
end

function Perl_Config_CombatDisplay_Mana_Persistance_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton6:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Mana_Persistance(1);
	else
		Perl_CombatDisplay_Set_Mana_Persistance(0);
	end
end

function Perl_Config_CombatDisplay_Progressive_Color_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton7:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Progressive_Color(1);
	else
		Perl_CombatDisplay_Set_Progressive_Color(0);
	end
end

function Perl_Config_CombatDisplay_Lock_Update()
	if (Perl_Config_CombatDisplay_Frame_CheckButton8:GetChecked() == 1) then
		Perl_CombatDisplay_Set_Lock(1);
	else
		Perl_CombatDisplay_Set_Lock(0);
	end
end

function Perl_Config_CombatDisplay_Set_Scale(value)
	if (Perl_CombatDisplay_Frame) then	-- this check is to prevent errors if you aren't using CombatDisplay
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_CombatDisplay_Frame_Slider1Text:SetText(value);
			Perl_Config_CombatDisplay_Frame_Slider1:SetValue(value);
		end
		Perl_CombatDisplay_Set_Scale(value);

		vartable = Perl_CombatDisplay_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(1);
		else
			Perl_Config_CombatDisplay_Frame_CheckButton9:SetChecked(nil);
		end
	end
end

function Perl_Config_CombatDisplay_Set_Transparency(value)
	if (Perl_CombatDisplay_Frame) then	-- this check is to prevent errors if you aren't using CombatDisplay
		Perl_CombatDisplay_Set_Transparency(value);
	end
end