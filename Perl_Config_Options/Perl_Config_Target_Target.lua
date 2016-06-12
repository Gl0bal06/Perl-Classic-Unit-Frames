function Perl_Config_Target_Target_Display()
	Perl_Config_Hide_All();
	if (Perl_Target_Target_Script_Frame) then
		Perl_Config_Target_Target_Frame:Show();
		Perl_Config_Target_Target_Set_Values();
	else
		Perl_Config_Target_Target_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_Target_Target_Set_Values()
	local vartable = Perl_Target_Target_GetVars();

	if (vartable["totsupport"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton1:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton1:SetChecked(false);
	end

	if (vartable["tototsupport"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton2:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton2:SetChecked(false);
	end

	if (vartable["alertmode"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton8:SetChecked(true);
		Perl_Config_Target_Target_Frame_CheckButton9:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton10:SetChecked(false);
	elseif (vartable["alertmode"] == 2) then
		Perl_Config_Target_Target_Frame_CheckButton8:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton9:SetChecked(true);
		Perl_Config_Target_Target_Frame_CheckButton10:SetChecked(false);
	elseif (vartable["alertmode"] == 3) then
		Perl_Config_Target_Target_Frame_CheckButton8:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton9:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton10:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton8:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton9:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton10:SetChecked(false);
	end

	if (vartable["alertsound"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton7:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton7:SetChecked(false);
	end

	if (vartable["alertsize"] == 0) then
		Perl_Config_Target_Target_Frame_CheckButton11:SetChecked(true);
		Perl_Config_Target_Target_Frame_CheckButton12:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton13:SetChecked(false);
	elseif (vartable["alertsize"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton11:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton12:SetChecked(true);
		Perl_Config_Target_Target_Frame_CheckButton13:SetChecked(false);
	elseif (vartable["alertsize"] == 2) then
		Perl_Config_Target_Target_Frame_CheckButton11:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton12:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton13:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton11:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton12:SetChecked(false);
		Perl_Config_Target_Target_Frame_CheckButton13:SetChecked(true);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton5:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton5:SetChecked(false);
	end

	if (vartable["showtotbuffs"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton14:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton14:SetChecked(false);
	end

	if (vartable["showtototbuffs"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton15:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton15:SetChecked(false);
	end

	if (vartable["hidepowerbars"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton16:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton16:SetChecked(false);
	end

	if (vartable["showtotdebuffs"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton17:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton17:SetChecked(false);
	end

	if (vartable["showtototdebuffs"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton18:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton18:SetChecked(false);
	end

	if (vartable["displaycastablebuffs"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton19:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton19:SetChecked(false);
	end

	if (vartable["classcolorednames"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton20:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton20:SetChecked(false);
	end

	if (vartable["showfriendlyhealth"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton21:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton21:SetChecked(false);
	end

	if (vartable["displaycurabledebuff"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton22:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton22:SetChecked(false);
	end

	if (vartable["displayonlymydebuffs"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton23:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton23:SetChecked(false);
	end

	Perl_Config_Target_Target_Frame_Slider1Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Target_Target_Frame_Slider1High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Target_Target_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(true);
	else
		Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(false);
	end

	Perl_Config_Target_Target_Frame_Slider2Low:SetText("0");
	Perl_Config_Target_Target_Frame_Slider2High:SetText("100");
	Perl_Config_Target_Target_Frame_Slider2:SetValue(vartable["transparency"]*100);
end

function Perl_Config_Target_Target_ToT_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton1:GetChecked() == true) then
		Perl_Target_Target_Set_ToT(1);
	else
		Perl_Target_Target_Set_ToT(0);
	end
end

function Perl_Config_Target_Target_ToToT_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton2:GetChecked() == true) then
		Perl_Target_Target_Set_ToToT(1);
	else
		Perl_Target_Target_Set_ToToT(0);
	end
end

function Perl_Config_Target_Target_Mode_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton8:GetChecked() == true) then
		Perl_Target_Target_Set_Mode(1);
	elseif (Perl_Config_Target_Target_Frame_CheckButton9:GetChecked() == true) then
		Perl_Target_Target_Set_Mode(2);
	elseif (Perl_Config_Target_Target_Frame_CheckButton10:GetChecked() == true) then
		Perl_Target_Target_Set_Mode(3);
	else
		Perl_Target_Target_Set_Mode(0);
	end
end

function Perl_Config_Target_Target_Sound_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton7:GetChecked() == true) then
		Perl_Target_Target_Set_Sound_Alert(1);
	else
		Perl_Target_Target_Set_Sound_Alert(0);
	end
end

function Perl_Config_Target_Target_Buff_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton14:GetChecked() == true) then
		Perl_Target_Target_Set_Buffs(1);
	else
		Perl_Target_Target_Set_Buffs(0);
	end
end

function Perl_Config_Target_Target_Target_Buff_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton15:GetChecked() == true) then
		Perl_Target_Target_Target_Set_Buffs(1);
	else
		Perl_Target_Target_Target_Set_Buffs(0);
	end
end

function Perl_Config_Target_Target_Debuff_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton17:GetChecked() == true) then
		Perl_Target_Target_Set_Debuffs(1);
	else
		Perl_Target_Target_Set_Debuffs(0);
	end
end

function Perl_Config_Target_Target_Target_Debuff_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton18:GetChecked() == true) then
		Perl_Target_Target_Target_Set_Debuffs(1);
	else
		Perl_Target_Target_Target_Set_Debuffs(0);
	end
end

function Perl_Config_Target_Target_Hide_Power_Bars_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton16:GetChecked() == true) then
		Perl_Target_Target_Set_Hide_Power_Bars(1);
	else
		Perl_Target_Target_Set_Hide_Power_Bars(0);
	end
end

function Perl_Config_Target_Target_Class_Buffs_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton19:GetChecked() == true) then
		Perl_Target_Target_Set_Class_Buffs(1);
	else
		Perl_Target_Target_Set_Class_Buffs(0);
	end
end

function Perl_Config_Target_Target_Class_Colored_Names_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton20:GetChecked() == true) then
		Perl_Target_Target_Set_Class_Colored_Names(1);
	else
		Perl_Target_Target_Set_Class_Colored_Names(0);
	end
end

function Perl_Config_Target_Target_Show_Friendly_Health_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton21:GetChecked() == true) then
		Perl_Target_Target_Set_Show_Friendly_Health(1);
	else
		Perl_Target_Target_Set_Show_Friendly_Health(0);
	end
end

function Perl_Config_Target_Target_Class_Debuffs_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton22:GetChecked() == true) then
		Perl_Target_Target_Set_Class_Debuffs(1);
	else
		Perl_Target_Target_Set_Class_Debuffs(0);
	end
end

function Perl_Config_Target_Target_Only_Self_Debuffs_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton23:GetChecked() == true) then
		Perl_Target_Target_Set_Only_Self_Debuffs(1);
	else
		Perl_Target_Target_Set_Only_Self_Debuffs(0);
	end
end

function Perl_Config_Target_Target_Alert_Size_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton11:GetChecked() == true) then
		Perl_Target_Target_Set_Alert_Size(0);
	elseif (Perl_Config_Target_Target_Frame_CheckButton12:GetChecked() == true) then
		Perl_Target_Target_Set_Alert_Size(1);
	elseif (Perl_Config_Target_Target_Frame_CheckButton13:GetChecked() == true) then
		Perl_Target_Target_Set_Alert_Size(2);
	else
		Perl_Config_Target_Target_Frame_CheckButton13:SetChecked(true);
		Perl_Target_Target_Set_Alert_Size(2);
	end
end

function Perl_Config_Target_Target_Lock_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton5:GetChecked() == true) then
		Perl_Target_Target_Set_Lock(1);
	else
		Perl_Target_Target_Set_Lock(0);
	end
end

function Perl_Config_Target_Target_Set_Scale(value)
	if (Perl_Target_Target_Script_Frame) then	-- this check is to prevent errors if you aren't using Target_Target
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Target_Target_Frame_Slider1Text:SetText(value);
			Perl_Config_Target_Target_Frame_Slider1:SetValue(value);
		end
		Perl_Target_Target_Set_Scale(value);

		vartable = Perl_Target_Target_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(true);
		else
			Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(false);
		end
	end
end

function Perl_Config_Target_Target_Set_Transparency(value)
	if (Perl_Target_Target_Script_Frame) then	-- this check is to prevent errors if you aren't using Target_Target
		Perl_Target_Target_Set_Transparency(value);
	end
end
