function add_bottoms_from_bot_xml(layer_obj,xml_file)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addRequired(p,'xml_file',@iscell);


parse(p,layer_obj,xml_file);

new_bottom=cell(1,length(layer_obj.Transceivers));

for i=1:length(xml_file)
    
    if exist(xml_file{i},'file')==0
        sprintf('Cannot find xml bottom file for %s\n',layer_obj.Filename{i});
        continue;
    end
    
    bottom_xml_tot=parse_bottom_xml(xml_file{i});
    
    if isempty(bottom_xml_tot)
        sprintf('Cannot find parse bottom file for %s\n',layer_obj.Filename{i});
        continue;
    end
    
    for itrans=1:length(bottom_xml_tot)
         
        bottom_xml=bottom_xml_tot{itrans};
        [idx_freq,found]=find_freq_idx(layer_obj,bottom_xml.Infos.Freq);
        
        if found==0
            warning('Could not load bottoms for frequency %.0fkHz, it is not there...',bottom_xml.Infos.Freq);
            continue;
        end
        
        trans_obj=layer_obj.Transceivers(idx_freq);
        if ~strcmp(deblank(trans_obj.Config.ChannelID),bottom_xml.Infos.ChannelID)
            warning('Those bottoms have been written for a different GPT %.0fkHz',bottom_xml.Infos.Freq);
        end
        
        
        
        bot_xml=bottom_xml.Bottom;
        
        time=bot_xml.Time;
        range=bot_xml.Range;
        tag=bot_xml.Tag;
        
        if time(1)<=trans_obj.Data.Time(1)
            [~,idx_ping_start]=nanmin(abs(trans_obj.Data.Time(1)-time(1)));
            idx_start_file=1;
        else
            idx_ping_start=1;
            [~,idx_start_file]=nanmin(abs(trans_obj.Data.Time-time(1)));
        end
        
        if time(end)>=trans_obj.Data.Time(end)
            [~,idx_ping_end]=nanmin(abs(trans_obj.Data.Time(end)-time));
            idx_end_file=length(trans_obj.Data.Time);
        else
            idx_ping_end=length(time);
            [~,idx_end_file]=nanmin(abs(trans_obj.Data.Time-time(end)));
        end
        
        if  time(end)<=trans_obj.Data.Time(1)||time(1)>=trans_obj.Data.Time(end)
            warning('No common time between file an bottom file');
            continue;
        end
        
        depth_resampled=resample_data_v2(range(idx_ping_start:idx_ping_end),time(idx_ping_start:idx_ping_end),trans_obj.Data.Time(idx_start_file:idx_end_file),'Opt','Nearest');
        sample_idx=resample_data_v2((1:length(trans_obj.Data.get_range())),trans_obj.Data.get_range(),depth_resampled,'Opt','Nearest');
        tag_resampled=resample_data_v2(tag(idx_ping_start:idx_ping_end),time(idx_ping_start:idx_ping_end),trans_obj.Data.Time(idx_start_file:idx_end_file),'Opt','Nearest');
        
        if i==1
        new_bottom{itrans}= bottom_cl(...
            'Range',nan(size(trans_obj.Data.Time)),...
            'Sample_idx',nan(size(trans_obj.Data.Time)),...
            'Tag',nan(size(trans_obj.Data.Time)));
        end
        
        new_bottom{itrans}.Range(idx_start_file:idx_end_file)=depth_resampled;
        new_bottom{itrans}.Sample_idx(idx_start_file:idx_end_file)=sample_idx;
        new_bottom{itrans}.Tag(idx_start_file:idx_end_file)=tag_resampled;
       
    end
    
end

for idx_freq=1:length(layer_obj.Transceivers)
    trans_obj=layer_obj.Transceivers(idx_freq);
    if isempty(new_bottom{idx_freq})
        continue;
    end
    trans_obj.setBottom(new_bottom{idx_freq});
    
end

end



