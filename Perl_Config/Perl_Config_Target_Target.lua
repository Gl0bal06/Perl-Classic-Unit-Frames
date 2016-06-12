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
		Perl_Config_Target_Target_Frame_CheckButton1:SetChecked(1);
	else
		Perl_Config_Target_Target_Frame_CheckButton1:SetChecked(nil);
	end

	if (vartable["tototsupport"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton2:SetChecked(1);
	else
		Perl_Config_Target_Target_Frame_CheckButton2:SetChecked(nil);
	end

	if (vartable["mobhealthsupport"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton3:SetChecked(1);
	else
		Perl_Config_Target_Target_Frame_CheckButton3:SetChecked(nil);
	end

	if (vartable["colorhealth"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton4:SetChecked(1);
	else
		Perl_Config_Target_Target_Frame_CheckButton4:SetChecked(nil);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_Target_Target_Frame_CheckButton5:SetChecked(1);
	else
		Perl_Config_Target_Target_Frame_CheckButton5:SetChecked(nil);
	end

	Perl_Config_Target_Target_Frame_Slider1Low:SetText("Small");
	Perl_Config_Target_Target_Frame_Slider1High:SetText("Big");
	Perl_Config_Target_Target_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(1);
	else
		Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(nil);
	end

	Perl_Config_Target_Target_Frame_Slider2Low:SetText("0");
	Perl_Config_Target_Target_Frame_Slider2High:SetText("100");
	Perl_Config_Target_Target_Frame_Slider2:SetValue(vartable["transparency"]*100);
end

function Perl_Config_Target_Target_ToT_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton1:GetChecked() == 1) then
		Perl_Target_Target_Set_ToT(1);
	else
		Perl_Target_Target_Set_ToT(0);
	end
end

function Perl_Config_Target_Target_ToToT_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton2:GetChecked() == 1) then
		Perl_Target_Target_Set_ToToT(1);
	else
		Perl_Target_Target_Set_ToToT(0);
	end
end

function Perl_Config_Target_Target_MobHealth_Update()
	if (Perl_Config_Target_Frame_CheckButton3:GetChecked() == 1) then
		Perl_Target_Target_Set_MobHealth(1);
	else
		Perl_Target_Target_Set_MobHealth(0);
	end
end

function Perl_Config_Target_Target_Progressive_Color_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton4:GetChecked() == 1) then
		Perl_Target_Target_Set_Progressive_Color(1);
	else
		Perl_Target_Target_Set_Progressive_Color(0);
	end
end

function Perl_Config_Target_Target_Lock_Update()
	if (Perl_Config_Target_Target_Frame_CheckButton5:GetChecked() == 1) then
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
			Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(1);
		else
			Perl_Config_Target_Target_Frame_CheckButton6:SetChecked(nil);
		end
	end
end

function Perl_Config_Target_Target_Set_Transparency(value)
	if (Perl_Target_Target_Script_Frame) then	-- this check is to prevent errors if you aren't using Player
		Perl_Target_Target_Set_Transparency(value);
	end
end