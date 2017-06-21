function save_bot_reg_xml_to_db_callback(~,~,main_figure,bot,reg)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
if ~isempty(reg)
    layer.write_reg_to_reg_xml();
    curr_disp.Reg_changed_flag=2;
    if reg>0
        [~,reg_ver]=layer.save_bot_reg_to_db('bot',0,'reg',1);        
        sprintf('Saving Regions to database as version %.0f',reg_ver);
        curr_disp.Reg_changed_flag=3;
    end
end

if ~isempty(bot)
    layer.write_bot_to_bot_xml();
    curr_disp.Bot_changed_flag=2;
    if bot>0
        [bot_ver,~]=layer.save_bot_reg_to_db('bot',1,'reg',0);
        sprintf('Saving Bottom to database as version %.0f',bot_ver);
        curr_disp.Bot_changed_flag=3;
    end
end
setappdata(main_figure,'Curr_disp',curr_disp);
load_survey_data_fig_from_db(main_figure,1);
end


