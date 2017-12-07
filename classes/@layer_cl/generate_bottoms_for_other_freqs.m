function [bots,idx_freq_end]=generate_bottoms_for_other_freqs(layer,idx_freq,idx_freq_end)

if isempty(idx_freq_end)
    idx_freq_end=1:length(layer.Transceivers);
end

idx_freq_end=setdiff(idx_freq_end,idx_freq);

trans_obj=layer.Transceivers(idx_freq);

range_ori=trans_obj.get_transceiver_range();
time_ori=trans_obj.Time;

dr_ori=nanmean(diff(range_ori));

bot_idx_ori=trans_obj.get_bottom_idx();
bot_ori=trans_obj.Bottom;

bots=[];

for i=1:length(layer.Transceivers)
    if i==idx_freq||nansum(i==idx_freq_end)==0
        continue;
    end
    
    trans_obj_sec=layer.Transceivers(i);
    new_bot=trans_obj.Bottom;
    new_range=trans_obj_sec.get_transceiver_range();
    new_time=trans_obj_sec.Time;
    
    r_factor=dr_ori/nanmean(diff(new_range));
    
    bot_idx_tmp=round(bot_idx_ori*r_factor);
    
    if numel(new_time)==numel(time_ori)
        if all(new_time-time_ori)
            bot_idx_new=bot_idx_tmp;
            bot_tag_new=new_bot.Tag;
        else
            bot_idx_new=resample_data_v2(bot_idx_tmp,time_ori,new_time);
            bot_tag_new=resample_data_v2(new_bot.Tag,time_ori,new_time,'Opt','Nearest');
        end
    else
        bot_idx_new=resample_data_v2(new_bot.Tag,time_ori,new_time);
        bot_tag_new=resample_data_v2(new_bot.Tag,time_ori,new_time,'Opt','Nearest');
    end
    
    bot_idx_new=round(bot_idx_new);
    bot_idx_new(bot_idx_new<=0)=1;
    bot_idx_new(bot_idx_new>numel(new_range))=numel(new_range);
     
    bots=[bots bottom_cl('Origin',bot_ori.Origin,...
        'Sample_idx',bot_idx_new,...
        'Tag',bot_tag_new)];
    
end

end