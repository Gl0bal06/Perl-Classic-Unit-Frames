function Perl_Config_Focus_Display()
	Perl_Config_Hide_All();
	if (Perl_Focus_Frame) then
		Perl_Config_Focus_Frame:Show();
		Perl_Config_Focus_Set_Values();
	else
		Perl_Config_Focus_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_Focus_Set_Values()
	local vartable = Perl_Focus_GetVars();

	Perl_Config_Focus_Frame_Slider2Low:SetText("0");
	Perl_Config_Focus_Frame_Slider2High:SetText("16");
	Perl_Config_Focus_Frame_Slider2:SetValue(vartable["numbuffsshown"]);

	Perl_Config_Focus_Frame_Slider3Low:SetText("0");
	Perl_Config_Focus_Frame_Slider3High:SetText("16");
	Perl_Config_Focus_Frame_Slider3:SetValue(vartable["numdebuffsshown"]);

	if (vartable["showclassicon"] == 1) then
		Perl_Config_Focus_Frame_CheckButton1:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton1:SetChecked(false);
	end

	if (vartable["showpvpicon"] == 1) then
		Perl_Config_Focus_Frame_CheckButton3:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton3:SetChecked(false);
	end

	if (vartable["showclassframe"] == 1) then
		Perl_Config_Focus_Frame_CheckButton4:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton4:SetChecked(false);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_Focus_Frame_CheckButton8:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton8:SetChecked(false);
	end

	if (vartable["showportrait"] == 1) then
		Perl_Config_Focus_Frame_CheckButton10:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton10:SetChecked(false);
	end

	if (vartable["threedportrait"] == 1) then
		Perl_Config_Focus_Frame_CheckButton11:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton11:SetChecked(false);
	end

	if (vartable["portraitcombattext"] == 1) then
		Perl_Config_Focus_Frame_CheckButton12:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton12:SetChecked(false);
	end

	if (vartable["showrareeliteframe"] == 1) then
		Perl_Config_Focus_Frame_CheckButton13:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton13:SetChecked(false);
	end

	if (vartable["nameframecombopoints"] == 1) then
		Perl_Config_Focus_Frame_CheckButton14:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton14:SetChecked(false);
	end

	if (vartable["framestyle"] == 2) then
		Perl_Config_Focus_Frame_CheckButton16:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton16:SetChecked(false);
	end

	if (vartable["compactmode"] == 1) then
		Perl_Config_Focus_Frame_CheckButton17:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton17:SetChecked(false);
	end

	if (vartable["compactpercent"] == 1) then
		Perl_Config_Focus_Frame_CheckButton18:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton18:SetChecked(false);
	end

	if (vartable["hidebuffbackground"] == 1) then
		Perl_Config_Focus_Frame_CheckButton19:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton19:SetChecked(false);
	end

	if (vartable["shortbars"] == 1) then
		Perl_Config_Focus_Frame_CheckButton20:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton20:SetChecked(false);
	end

	if (vartable["healermode"] == 1) then
		Perl_Config_Focus_Frame_CheckButton21:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton21:SetChecked(false);
	end

	if (vartable["displaycastablebuffs"] == 1) then
		Perl_Config_Focus_Frame_CheckButton23:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton23:SetChecked(false);
	end

	if (vartable["classcolorednames"] == 1) then
		Perl_Config_Focus_Frame_CheckButton24:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton24:SetChecked(false);
	end

	if (vartable["showmanadeficit"] == 1) then
		Perl_Config_Focus_Frame_CheckButton25:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton25:SetChecked(false);
	end

	if (vartable["invertbuffs"] == 1) then
		Perl_Config_Focus_Frame_CheckButton26:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton26:SetChecked(false);
	end

	if (vartable["displaycurabledebuff"] == 1) then
		Perl_Config_Focus_Frame_CheckButton27:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton27:SetChecked(false);
	end

	if (vartable["displaybufftimers"] == 1) then
		Perl_Config_Focus_Frame_CheckButton28:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton28:SetChecked(false);
	end

	if (vartable["displayonlymydebuffs"] == 1) then
		Perl_Config_Focus_Frame_CheckButton29:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton29:SetChecked(false);
	end

	Perl_Config_Focus_Frame_Slider1Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Focus_Frame_Slider1High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Focus_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_Focus_Frame_CheckButton9:SetChecked(true);
	else
		Perl_Config_Focus_Frame_CheckButton9:SetChecked(false);
	end

	Perl_Config_Focus_Frame_Slider4Low:SetText("0");
	Perl_Config_Focus_Frame_Slider4High:SetText("100");
	Perl_Config_Focus_Frame_Slider4:SetValue(vartable["transparency"]*100);

	Perl_Config_Focus_Frame_Slider5Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Focus_Frame_Slider5High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Focus_Frame_Slider5:SetValue(floor(vartable["buffdebuffscale"]*100+0.5));
end

function Perl_Config_Focus_Set_Buffs(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		Perl_Focus_Set_Buffs(value);
	end
end

function Perl_Config_Focus_Set_Debuffs(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		Perl_Focus_Set_Debuffs(value);
	end
end

function Perl_Config_Focus_Class_Icon_Update()
	if (Perl_Config_Focus_Frame_CheckButton1:GetChecked() == true) then
		Perl_Focus_Set_Class_Icon(1);
	else
		Perl_Focus_Set_Class_Icon(0);
	end
end

function Perl_Config_Focus_PvP_Status_Icon_Update()
	if (Perl_Config_Focus_Frame_CheckButton3:GetChecked() == true) then
		Perl_Focus_Set_PvP_Status_Icon(1);
	else
		Perl_Focus_Set_PvP_Status_Icon(0);
	end
end

function Perl_Config_Focus_Class_Frame_Update()
	if (Perl_Config_Focus_Frame_CheckButton4:GetChecked() == true) then
		Perl_Focus_Set_Class_Frame(1);
	else
		Perl_Focus_Set_Class_Frame(0);
	end
end

function Perl_Config_Focus_Lock_Update()
	if (Perl_Config_Focus_Frame_CheckButton8:GetChecked() == true) then
		Perl_Focus_Set_Lock(1);
	else
		Perl_Focus_Set_Lock(0);
	end
end

function Perl_Config_Focus_Portrait_Update()
	if (Perl_Config_Focus_Frame_CheckButton10:GetChecked() == true) then
		Perl_Focus_Set_Portrait(1);
	else
		Perl_Focus_Set_Portrait(0);
	end
end

function Perl_Config_Focus_3D_Portrait_Update()
	if (Perl_Config_Focus_Frame_CheckButton11:GetChecked() == true) then
		Perl_Focus_Set_3D_Portrait(1);
	else
		Perl_Focus_Set_3D_Portrait(0);
	end
end

function Perl_Config_Focus_Portrait_Combat_Text_Update()
	if (Perl_Config_Focus_Frame_CheckButton12:GetChecked() == true) then
		Perl_Focus_Set_Portrait_Combat_Text(1);
	else
		Perl_Focus_Set_Portrait_Combat_Text(0);
	end
end

function Perl_Config_Focus_Rare_Elite_Update()
	if (Perl_Config_Focus_Frame_CheckButton13:GetChecked() == true) then
		Perl_Focus_Set_Rare_Elite(1);
	else
		Perl_Focus_Set_Rare_Elite(0);
	end
end

function Perl_Config_Focus_Combo_Name_Frame_Update()
	if (Perl_Config_Focus_Frame_CheckButton14:GetChecked() == true) then
		Perl_Focus_Set_Combo_Name_Frame(1);
	else
		Perl_Focus_Set_Combo_Name_Frame(0);
	end
end

function Perl_Config_Focus_Alternate_Frame_Style_Update()
	if (Perl_Config_Focus_Frame_CheckButton16:GetChecked() == true) then
		Perl_Focus_Set_Frame_Style(2);
	else
		Perl_Focus_Set_Frame_Style(1);
	end
end

function Perl_Config_Focus_Compact_Mode_Update()
	if (Perl_Config_Focus_Frame_CheckButton17:GetChecked() == true) then
		Perl_Focus_Set_Compact_Mode(1);
	else
		Perl_Focus_Set_Compact_Mode(0);
	end
end

function Perl_Config_Focus_Compact_Percents_Update()
	if (Perl_Config_Focus_Frame_CheckButton18:GetChecked() == true) then
		Perl_Focus_Set_Compact_Percents(1);
	else
		Perl_Focus_Set_Compact_Percents(0);
	end
end

function Perl_Config_Focus_Short_Bars_Update()
	if (Perl_Config_Focus_Frame_CheckButton20:GetChecked() == true) then
		Perl_Focus_Set_Short_Bars(1);
	else
		Perl_Focus_Set_Short_Bars(0);
	end
end

function Perl_Config_Focus_Buff_Background_Update()
	if (Perl_Config_Focus_Frame_CheckButton19:GetChecked() == true) then
		Perl_Focus_Set_Buff_Debuff_Background(1);
	else
		Perl_Focus_Set_Buff_Debuff_Background(0);
	end
end

function Perl_Config_Focus_Healer_Update()
	if (Perl_Config_Focus_Frame_CheckButton21:GetChecked() == true) then
		Perl_Focus_Set_Healer(1);
	else
		Perl_Focus_Set_Healer(0);
	end
end

function Perl_Config_Focus_Class_Buffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton23:GetChecked() == true) then
		Perl_Focus_Set_Class_Buffs(1);
	else
		Perl_Focus_Set_Class_Buffs(0);
	end
end

function Perl_Config_Focus_Class_Colored_Names_Update()
	if (Perl_Config_Focus_Frame_CheckButton24:GetChecked() == true) then
		Perl_Focus_Set_Class_Colored_Names(1);
	else
		Perl_Focus_Set_Class_Colored_Names(0);
	end
end

function Perl_Config_Focus_Mana_Deficit_Update()
	if (Perl_Config_Focus_Frame_CheckButton25:GetChecked() == true) then
		Perl_Focus_Set_Mana_Deficit(1);
	else
		Perl_Focus_Set_Mana_Deficit(0);
	end
end

function Perl_Config_Focus_Invert_Buffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton26:GetChecked() == true) then
		Perl_Focus_Set_Invert_Buffs(1);
	else
		Perl_Focus_Set_Invert_Buffs(0);
	end
end

function Perl_Config_Focus_Class_Debuffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton27:GetChecked() == true) then
		Perl_Focus_Set_Class_Debuffs(1);
	else
		Perl_Focus_Set_Class_Debuffs(0);
	end
end

function Perl_Config_Focus_Buff_Timers_Update()
	if (Perl_Config_Focus_Frame_CheckButton28:GetChecked() == true) then
		Perl_Focus_Set_Buff_Timers(1);
	else
		Perl_Focus_Set_Buff_Timers(0);
	end
end

function Perl_Config_Focus_Only_Self_Debuffs_Update()
	if (Perl_Config_Focus_Frame_CheckButton29:GetChecked() == true) then
		Perl_Focus_Set_Only_Self_Debuffs(1);
	else
		Perl_Focus_Set_Only_Self_Debuffs(0);
	end
end

function Perl_Config_Focus_Set_Scale(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Focus_Frame_Slider1Text:SetText(value);
			Perl_Config_Focus_Frame_Slider1:SetValue(value);
		end
		Perl_Focus_Set_Scale(value);

		vartable = Perl_Focus_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_Focus_Frame_CheckButton9:SetChecked(true);
		else
			Perl_Config_Focus_Frame_CheckButton9:SetChecked(false);
		end
	end
end

function Perl_Config_Focus_Set_BuffDebuff_Scale(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Focus_Frame_Slider5Text:SetText(value);
			Perl_Config_Focus_Frame_Slider5:SetValue(value);
		end
		Perl_Focus_Set_BuffDebuff_Scale(value);
	end
end

function Perl_Config_Focus_Set_Transparency(value)
	if (Perl_Focus_Frame) then	-- this check is to prevent errors if you aren't using Focus
		Perl_Focus_Set_Transparency(value);
	end
end