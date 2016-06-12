function Perl_Config_Target_Display()
	Perl_Config_Hide_All();
	if (Perl_Target_Frame) then
		Perl_Config_Target_Frame:Show();
		Perl_Config_Target_Set_Values();
	else
		Perl_Config_Target_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_Target_Set_Values()
	local vartable = Perl_Target_GetVars();

	Perl_Config_Target_Frame_Slider2Low:SetText("0");
	Perl_Config_Target_Frame_Slider2High:SetText("20");
	Perl_Config_Target_Frame_Slider2:SetValue(vartable["numbuffsshown"]);

	Perl_Config_Target_Frame_Slider3Low:SetText("0");
	Perl_Config_Target_Frame_Slider3High:SetText("40");
	Perl_Config_Target_Frame_Slider3:SetValue(vartable["numdebuffsshown"]);

	if (vartable["showclassicon"] == 1) then
		Perl_Config_Target_Frame_CheckButton1:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton1:SetChecked(false);
	end

	if (vartable["showpvpicon"] == 1) then
		Perl_Config_Target_Frame_CheckButton3:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton3:SetChecked(false);
	end

	if (vartable["showclassframe"] == 1) then
		Perl_Config_Target_Frame_CheckButton4:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton4:SetChecked(false);
	end

	if (vartable["showcp"] == 1) then
		Perl_Config_Target_Frame_CheckButton5:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton5:SetChecked(false);
	end

	if (vartable["locked"] == 1) then
		Perl_Config_Target_Frame_CheckButton8:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton8:SetChecked(false);
	end

	if (vartable["showportrait"] == 1) then
		Perl_Config_Target_Frame_CheckButton10:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton10:SetChecked(false);
	end

	if (vartable["threedportrait"] == 1) then
		Perl_Config_Target_Frame_CheckButton11:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton11:SetChecked(false);
	end

	if (vartable["portraitcombattext"] == 1) then
		Perl_Config_Target_Frame_CheckButton12:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton12:SetChecked(false);
	end

	if (vartable["showrareeliteframe"] == 1) then
		Perl_Config_Target_Frame_CheckButton13:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton13:SetChecked(false);
	end

	if (vartable["nameframecombopoints"] == 1) then
		Perl_Config_Target_Frame_CheckButton14:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton14:SetChecked(false);
	end

	if (vartable["comboframedebuffs"] == 1) then
		Perl_Config_Target_Frame_CheckButton15:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton15:SetChecked(false);
	end

	if (vartable["framestyle"] == 2) then
		Perl_Config_Target_Frame_CheckButton16:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton16:SetChecked(false);
	end

	if (vartable["compactmode"] == 1) then
		Perl_Config_Target_Frame_CheckButton17:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton17:SetChecked(false);
	end

	if (vartable["compactpercent"] == 1) then
		Perl_Config_Target_Frame_CheckButton18:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton18:SetChecked(false);
	end

	if (vartable["hidebuffbackground"] == 1) then
		Perl_Config_Target_Frame_CheckButton19:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton19:SetChecked(false);
	end

	if (vartable["shortbars"] == 1) then
		Perl_Config_Target_Frame_CheckButton20:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton20:SetChecked(false);
	end

	if (vartable["healermode"] == 1) then
		Perl_Config_Target_Frame_CheckButton21:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton21:SetChecked(false);
	end

	if (vartable["soundtargetchange"] == 1) then
		Perl_Config_Target_Frame_CheckButton22:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton22:SetChecked(false);
	end

	if (vartable["displaycastablebuffs"] == 1) then
		Perl_Config_Target_Frame_CheckButton23:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton23:SetChecked(false);
	end

	if (vartable["classcolorednames"] == 1) then
		Perl_Config_Target_Frame_CheckButton24:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton24:SetChecked(false);
	end

	if (vartable["showmanadeficit"] == 1) then
		Perl_Config_Target_Frame_CheckButton25:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton25:SetChecked(false);
	end

	if (vartable["invertbuffs"] == 1) then
		Perl_Config_Target_Frame_CheckButton26:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton26:SetChecked(false);
	end

	if (vartable["showguildname"] == 1) then
		Perl_Config_Target_Frame_CheckButton27:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton27:SetChecked(false);
	end

	if (vartable["eliteraregraphic"] == 1) then
		Perl_Config_Target_Frame_CheckButton28:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton28:SetChecked(false);
	end

	if (vartable["displaycurabledebuff"] == 1) then
		Perl_Config_Target_Frame_CheckButton29:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton29:SetChecked(false);
	end

	if (vartable["displaybufftimers"] == 1) then
		Perl_Config_Target_Frame_CheckButton30:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton30:SetChecked(false);
	end

	if (vartable["displaynumbericthreat"] == 1) then
		Perl_Config_Target_Frame_CheckButton31:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton31:SetChecked(false);
	end

	if (vartable["displayonlymydebuffs"] == 1) then
		Perl_Config_Target_Frame_CheckButton32:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton32:SetChecked(false);
	end

	Perl_Config_Target_Frame_Slider1Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Target_Frame_Slider1High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Target_Frame_Slider1:SetValue(floor(vartable["scale"]*100+0.5));

	if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
		Perl_Config_Target_Frame_CheckButton9:SetChecked(true);
	else
		Perl_Config_Target_Frame_CheckButton9:SetChecked(false);
	end

	Perl_Config_Target_Frame_Slider4Low:SetText("0");
	Perl_Config_Target_Frame_Slider4High:SetText("100");
	Perl_Config_Target_Frame_Slider4:SetValue(vartable["transparency"]*100);

	Perl_Config_Target_Frame_Slider5Low:SetText(PERL_LOCALIZED_CONFIG_SMALL);
	Perl_Config_Target_Frame_Slider5High:SetText(PERL_LOCALIZED_CONFIG_BIG);
	Perl_Config_Target_Frame_Slider5:SetValue(floor(vartable["buffdebuffscale"]*100+0.5));
end

function Perl_Config_Target_Set_Buffs(value)
	if (Perl_Target_Frame) then	-- this check is to prevent errors if you aren't using Target
		Perl_Target_Set_Buffs(value);
	end
end

function Perl_Config_Target_Set_Debuffs(value)
	if (Perl_Target_Frame) then	-- this check is to prevent errors if you aren't using Target
		Perl_Target_Set_Debuffs(value);
	end
end

function Perl_Config_Target_Class_Icon_Update()
	if (Perl_Config_Target_Frame_CheckButton1:GetChecked() == true) then
		Perl_Target_Set_Class_Icon(1);
	else
		Perl_Target_Set_Class_Icon(0);
	end
end

function Perl_Config_Target_PvP_Status_Icon_Update()
	if (Perl_Config_Target_Frame_CheckButton3:GetChecked() == true) then
		Perl_Target_Set_PvP_Status_Icon(1);
	else
		Perl_Target_Set_PvP_Status_Icon(0);
	end
end

function Perl_Config_Target_Class_Frame_Update()
	if (Perl_Config_Target_Frame_CheckButton4:GetChecked() == true) then
		Perl_Target_Set_Class_Frame(1);
	else
		Perl_Target_Set_Class_Frame(0);
	end
end

function Perl_Config_Target_Combo_Points_Update()
	if (Perl_Config_Target_Frame_CheckButton5:GetChecked() == true) then
		local _, class = UnitClass("player");
		if (class == "ROGUE" or class == "DRUID" or class == "WARRIOR" or class == "PRIEST" or class == "PALADIN" or class == "MAGE") then
			Perl_Target_Set_Combo_Points(1);
		else
			Perl_Config_Target_Frame_CheckButton5:SetChecked(0);
			Perl_Target_Set_Combo_Points(0);
		end
	else
		Perl_Target_Set_Combo_Points(0);
	end
end

function Perl_Config_Target_Lock_Update()
	if (Perl_Config_Target_Frame_CheckButton8:GetChecked() == true) then
		Perl_Target_Set_Lock(1);
	else
		Perl_Target_Set_Lock(0);
	end
end

function Perl_Config_Target_Portrait_Update()
	if (Perl_Config_Target_Frame_CheckButton10:GetChecked() == true) then
		Perl_Target_Set_Portrait(1);
	else
		Perl_Target_Set_Portrait(0);
	end
end

function Perl_Config_Target_3D_Portrait_Update()
	if (Perl_Config_Target_Frame_CheckButton11:GetChecked() == true) then
		Perl_Target_Set_3D_Portrait(1);
	else
		Perl_Target_Set_3D_Portrait(0);
	end
end

function Perl_Config_Target_Portrait_Combat_Text_Update()
	if (Perl_Config_Target_Frame_CheckButton12:GetChecked() == true) then
		Perl_Target_Set_Portrait_Combat_Text(1);
	else
		Perl_Target_Set_Portrait_Combat_Text(0);
	end
end

function Perl_Config_Target_Rare_Elite_Update()
	if (Perl_Config_Target_Frame_CheckButton13:GetChecked() == true) then
		Perl_Target_Set_Rare_Elite(1);
	else
		Perl_Target_Set_Rare_Elite(0);
	end
end

function Perl_Config_Target_Combo_Name_Frame_Update()
	if (Perl_Config_Target_Frame_CheckButton14:GetChecked() == true) then
		Perl_Target_Set_Combo_Name_Frame(1);
	else
		Perl_Target_Set_Combo_Name_Frame(0);
	end
end

function Perl_Config_Target_Combo_Frame_Debuffs_Update()
	if (Perl_Config_Target_Frame_CheckButton15:GetChecked() == true) then
		Perl_Target_Set_Combo_Frame_Debuffs(1);
	else
		Perl_Target_Set_Combo_Frame_Debuffs(0);
	end
end

function Perl_Config_Target_Alternate_Frame_Style_Update()
	if (Perl_Config_Target_Frame_CheckButton16:GetChecked() == true) then
		Perl_Target_Set_Frame_Style(2);
	else
		Perl_Target_Set_Frame_Style(1);
	end
end

function Perl_Config_Target_Compact_Mode_Update()
	if (Perl_Config_Target_Frame_CheckButton17:GetChecked() == true) then
		Perl_Target_Set_Compact_Mode(1);
	else
		Perl_Target_Set_Compact_Mode(0);
	end
end

function Perl_Config_Target_Compact_Percents_Update()
	if (Perl_Config_Target_Frame_CheckButton18:GetChecked() == true) then
		Perl_Target_Set_Compact_Percents(1);
	else
		Perl_Target_Set_Compact_Percents(0);
	end
end

function Perl_Config_Target_Short_Bars_Update()
	if (Perl_Config_Target_Frame_CheckButton20:GetChecked() == true) then
		Perl_Target_Set_Short_Bars(1);
	else
		Perl_Target_Set_Short_Bars(0);
	end
end

function Perl_Config_Target_Buff_Background_Update()
	if (Perl_Config_Target_Frame_CheckButton19:GetChecked() == true) then
		Perl_Target_Set_Buff_Debuff_Background(1);
	else
		Perl_Target_Set_Buff_Debuff_Background(0);
	end
end

function Perl_Config_Target_Healer_Update()
	if (Perl_Config_Target_Frame_CheckButton21:GetChecked() == true) then
		Perl_Target_Set_Healer(1);
	else
		Perl_Target_Set_Healer(0);
	end
end

function Perl_Config_Target_Sound_Target_Change_Update()
	if (Perl_Config_Target_Frame_CheckButton22:GetChecked() == true) then
		Perl_Target_Set_Sound_Target_Change(1);
	else
		Perl_Target_Set_Sound_Target_Change(0);
	end
end

function Perl_Config_Target_Class_Buffs_Update()
	if (Perl_Config_Target_Frame_CheckButton23:GetChecked() == true) then
		Perl_Target_Set_Class_Buffs(1);
	else
		Perl_Target_Set_Class_Buffs(0);
	end
end

function Perl_Config_Target_Class_Colored_Names_Update()
	if (Perl_Config_Target_Frame_CheckButton24:GetChecked() == true) then
		Perl_Target_Set_Class_Colored_Names(1);
	else
		Perl_Target_Set_Class_Colored_Names(0);
	end
end

function Perl_Config_Target_Mana_Deficit_Update()
	if (Perl_Config_Target_Frame_CheckButton25:GetChecked() == true) then
		Perl_Target_Set_Mana_Deficit(1);
	else
		Perl_Target_Set_Mana_Deficit(0);
	end
end

function Perl_Config_Target_Invert_Buffs_Update()
	if (Perl_Config_Target_Frame_CheckButton26:GetChecked() == true) then
		Perl_Target_Set_Invert_Buffs(1);
	else
		Perl_Target_Set_Invert_Buffs(0);
	end
end

function Perl_Config_Target_Show_Guild_Name_Update()
	if (Perl_Config_Target_Frame_CheckButton27:GetChecked() == true) then
		Perl_Target_Set_Show_Guild_Name(1);
	else
		Perl_Target_Set_Show_Guild_Name(0);
	end
end

function Perl_Config_Target_Elite_Rare_Graphic_Update()
	if (Perl_Config_Target_Frame_CheckButton28:GetChecked() == true) then
		Perl_Target_Set_Elite_Rare_Graphic(1);
	else
		Perl_Target_Set_Elite_Rare_Graphic(0);
	end
end

function Perl_Config_Target_Curable_Debuffs_Update()
	if (Perl_Config_Target_Frame_CheckButton29:GetChecked() == true) then
		Perl_Target_Set_Curable_Debuffs(1);
	else
		Perl_Target_Set_Curable_Debuffs(0);
	end
end

function Perl_Config_Target_Buff_Timers_Update()
	if (Perl_Config_Target_Frame_CheckButton30:GetChecked() == true) then
		Perl_Target_Set_Buff_Timers(1);
	else
		Perl_Target_Set_Buff_Timers(0);
	end
end

function Perl_Config_Target_Display_Numeric_Threat_Update()
	if (Perl_Config_Target_Frame_CheckButton31:GetChecked() == true) then
		Perl_Target_Set_Display_Numeric_Threat(1);
	else
		Perl_Target_Set_Display_Numeric_Threat(0);
	end
end

function Perl_Config_Target_Only_Self_Debuffs_Update()
	if (Perl_Config_Target_Frame_CheckButton32:GetChecked() == true) then
		Perl_Target_Set_Only_Self_Debuffs(1);
	else
		Perl_Target_Set_Only_Self_Debuffs(0);
	end
end

function Perl_Config_Target_Set_Scale(value)
	if (Perl_Target_Frame) then	-- this check is to prevent errors if you aren't using Target
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Target_Frame_Slider1Text:SetText(value);
			Perl_Config_Target_Frame_Slider1:SetValue(value);
		end
		Perl_Target_Set_Scale(value);

		vartable = Perl_Target_GetVars();
		if (floor(vartable["scale"]*100+0.5) == floor(UIParent:GetScale()*100+0.5)) then
			Perl_Config_Target_Frame_CheckButton9:SetChecked(true);
		else
			Perl_Config_Target_Frame_CheckButton9:SetChecked(false);
		end
	end
end

function Perl_Config_Target_Set_BuffDebuff_Scale(value)
	if (Perl_Target_Frame) then	-- this check is to prevent errors if you aren't using Target
		if (value == nil) then
			value = floor(UIParent:GetScale()*100+0.5);
			Perl_Config_Target_Frame_Slider5Text:SetText(value);
			Perl_Config_Target_Frame_Slider5:SetValue(value);
		end
		Perl_Target_Set_BuffDebuff_Scale(value);
	end
end

function Perl_Config_Target_Set_Transparency(value)
	if (Perl_Target_Frame) then	-- this check is to prevent errors if you aren't using Target
		Perl_Target_Set_Transparency(value);
	end
end
