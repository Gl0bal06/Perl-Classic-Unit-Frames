function Perl_Config_ArcaneBar_Display()
	Perl_Config_Hide_All();
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_Config_ArcaneBar_Frame:Show();
		Perl_Config_ArcaneBar_Set_Values();
	else
		Perl_Config_ArcaneBar_Frame:Hide();
	end
end

function Perl_Config_ArcaneBar_Set_Values()
	vartable = Perl_ArcaneBar_GetVars();

	if (vartable["enabled"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton1:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton1:SetChecked(nil);
	end

	if (vartable["showtimer"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton2:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton2:SetChecked(nil);
	end

	if (vartable["hideoriginal"] == 1) then
		Perl_Config_ArcaneBar_Frame_CheckButton3:SetChecked(1);
	else
		Perl_Config_ArcaneBar_Frame_CheckButton3:SetChecked(nil);
	end
end

function Perl_Config_ArcaneBar_Enabled_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton1:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Enabled(1);
	else
		Perl_ArcaneBar_Set_Enabled(0);
	end
end

function Perl_Config_ArcaneBar_Show_Timer_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton2:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Timer(1);
	else
		Perl_ArcaneBar_Set_Timer(0);
	end
end

function Perl_Config_ArcaneBar_Hide_Original_Update()
	if (Perl_Config_ArcaneBar_Frame_CheckButton3:GetChecked() == 1) then
		Perl_ArcaneBar_Set_Hide(1);
	else
		Perl_ArcaneBar_Set_Hide(0);
	end
end