function clear_lines(ah)

u=findall(ah,'Type','line','-not',{'Tag','SelectLine','-or','Tag','bottom','-or','Tag','bottom_temp','-or','Tag','line_temp',...
    '-or','Tag','measurement','-or','Tag','track','-or','Tag','region','-or','Tag','region_cont',...
    '-or','Tag','file_id','-or','Tag','surv_id','-or','Tag','lines','-or','Tag','reg_temp'});
delete(u);

u=findall(ah,'Type','text','-and','Tag','');

delete(u);
%disp('clear lines')
end