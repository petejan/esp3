function clear_lines(ah)

u=findobj(ah,'Type','line','-not',{'Tag','bottom','-or','Tag','track','-or','Tag','region','-or','Tag','region_cont','-or','Tag','file_id','-or','Tag','surv_id'});
delete(u);

end