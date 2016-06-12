function Perl_Config_All_Display()
	Perl_Config_Hide_All();
	Perl_Config_All_Frame:Show();
	Perl_Config_All_Set_Values();
end

function Perl_Config_All_Set_Values()
	vartable = Perl_Config_GetVars();

	if (vartable["texture"] ~= nil) then
		local num = vartable["texture"];
		if (num == 0) then
			num = 6;
		end
		Perl_Config_All_Frame_CheckButton6:SetChecked(nil);
		getglobal("Perl_Config_All_Frame_CheckButton"..num):SetChecked(1);
	end

	Perl_Config_All_Frame_Slider1Low:SetText("Small");
	Perl_Config_All_Frame_Slider1High:SetText("Big");
	--Perl_Config_All_Frame_Slider1:SetValue(nil);			-- Figure out how to get the slider to poof on every open
	--Perl_Config_All_Frame_CheckButton7:SetChecked(nil);		-- We want a clean scale bar when opening the frame since nothing is saved or loaded for it

	Perl_Config_All_Frame_Slider2Low:SetText("0");
	Perl_Config_All_Frame_Slider2High:SetText("100");
end

function Perl_Config_All_Texture_Update(texturenum)
	if (Perl_Config_All_Frame_CheckButton1:GetChecked() == 1 or Perl_Config_All_Frame_CheckButton2:GetChecked() == 1 or Perl_Config_All_Frame_CheckButton3:GetChecked() == 1 or Perl_Config_All_Frame_CheckButton4:GetChecked() == 1 or Perl_Config_All_Frame_CheckButton5:GetChecked() == 1) then
		-- do nothing
	else
		Perl_Config_All_Frame_CheckButton6:SetChecked(1);
		texturenum = 0;
	end

	Perl_Config_Set_Texture(texturenum);		-- Go save the value and texture the bars
end

function Perl_Config_All_Lock_Unlock(value)
	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Set_Lock(value);
	end

	if (Perl_Party_Frame) then
		Perl_Party_Set_Lock(value);
	end

	if (Perl_Player_Frame) then
		Perl_Player_Set_Lock(value);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Set_Lock(value);
	end

	if (Perl_Target_Frame) then
		Perl_Target_Set_Lock(value);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Set_Lock(value);
	end
end

function Perl_Config_All_Set_Scale(value)
	if (value == nil) then
		value = floor(UIParent:GetScale()*100+0.5);
		Perl_Config_All_Frame_Slider1Text:SetText(value);
		Perl_Config_All_Frame_Slider1:SetValue(value);
	end

	if (floor(value+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_All_Frame_CheckButton7:SetChecked(1);
	else
		Perl_Config_All_Frame_CheckButton7:SetChecked(nil);
	end

	if (Perl_CombatDisplay_Frame) then
		Perl_CombatDisplay_Set_Scale(value);
	end

	if (Perl_Party_Frame) then
		Perl_Party_Set_Scale(value);
	end

	if (Perl_Player_Frame) then
		Perl_Player_Set_Scale(value);
	end

	if (Perl_Player_Buff_Script_Frame) then
		Perl_Player_Buff_Set_Scale(value);
	end

	if (Perl_Player_Pet_Frame) then
		Perl_Player_Pet_Set_Scale(value);
	end

	if (Perl_Target_Frame) then
		Perl_Target_Set_Scale(value);
	end

	if (Perl_Target_Target_Script_Frame) then
		Perl_Target_Target_Set_Scale(value);
	end
end

function Perl_Config_All_Set_Transparency(value)
	Perl_Config_Set_Transparency(value);
end