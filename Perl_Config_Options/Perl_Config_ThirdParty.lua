function Perl_Config_ThirdParty_Display()
	Perl_Config_Hide_All();
	Perl_Config_ThirdParty_Frame:Show();
end

function Perl_Config_ThirdParty_DisplayOptions_Perl_ColorChange()
	Perl_Config_Hide_All();
	if (Perl_ColorChange) then
		Perl_Config_ColorChange_Frame:ClearAllPoints();
		Perl_Config_ColorChange_Frame:SetPoint("TOPLEFT", Perl_Config_Frame, "TOPLEFT", 0, -120);
		Perl_Config_ColorChange_Display();
	else
		Perl_Config_NotInstalled_Frame:Show();
	end
end