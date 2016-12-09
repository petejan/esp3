function [bot_ver,reg_ver]=get_loaded_bot_reg_version(trans_obj)
        
    bot_ver=trans_obj.Bottom.Version;
    reg_ver=-1;
        for i=1:length(trans_obj.Regions)
            reg_ver=nanmax(reg_ver,trans_obj.Regions(i).Version);
        end
        
end