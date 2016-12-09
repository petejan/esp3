function check_saved_bot_reg(main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
war_str=('Unsaved changes');
if curr_disp.Bot_changed_flag==1
    
    choice = questdlg('Bottom has been modified without being saved. Do you want save it?',...
        war_str,...
        'Yes','No', ...
        'Yes');
    % Handle response
    switch choice
        case 'Yes'
            layer.write_bot_to_bot_xml();
            layer.save_bot_reg_to_db('bot',1,'reg',0);
    end
    
end

if curr_disp.Reg_changed_flag==1
    
    choice = questdlg('Regions have been modified without being saved. Do you want save them?',...
        war_str,...
        'Yes','No', ...
        'Yes');
    % Handle response
    switch choice
        case 'Yes'
            layer.write_reg_to_reg_xml();
            layer.save_bot_reg_to_db('bot',0,'reg',1);
    end
end


end