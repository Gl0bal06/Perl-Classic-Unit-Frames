function Perl_Config_Party_Pet_Display()
	Perl_Config_Hide_All();
	if (Perl_Party_Pet_Frame) then
		Perl_Config_Party_Pet_Frame:Show();
		Perl_Config_Party_Pet_Set_Values();
	else
		Perl_Config_Party_Pet_Frame:Hide();
		Perl_Config_NotInstalled_Frame:Show();
	end
end

function Perl_Config_Party_Pet_Set_Values()

end