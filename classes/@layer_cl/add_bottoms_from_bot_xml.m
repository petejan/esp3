function pres=add_bottoms_from_bot_xml(layer_obj,varargin)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'Frequencies',[]);
addParameter(p,'Version',-1);

parse(p,layer_obj,varargin{:});

new_bottom=cell(1,length(layer_obj.Transceivers));

[path_xml,~,bot_file_str]=layer_obj.create_files_str();

pres=ones(length(bot_file_str));
init_bot=ones(1,length(layer_obj.Transceivers));

for ix=1:length(bot_file_str)
    xml_file=fullfile(path_xml{ix},bot_file_str{ix});
    if exist(xml_file,'file')==0
        pres(ix)=0;
        %fprintf('No xml bottom file for %s\n',layer_obj.Filename{ix});
        continue;
    end
    
    [bottom_xml_tot,ver]=parse_bottom_xml(xml_file);
    
    if isempty(bottom_xml_tot)
        pres(ix)=0;
        fprintf('Cannot parse bottom file for %s\n',layer_obj.Filename{ix});
        continue;
    end
    
    for itrans=1:length(bottom_xml_tot)
         
        bottom_xml=bottom_xml_tot{itrans};
        if ~isempty(p.Results.Frequencies)&&~any(bottom_xml.Infos.Freq==p.Results.Frequencies)
            continue;
        end
        

        [trans_obj,idx_freq]=layer_obj.get_trans(bottom_xml.Infos);
        if isempty(trans_obj)
            %fprintf('Could not load bottoms for frequency %.0f kHz, it is not there...',bottom_xml.Infos.Freq);
            continue;
        end
  
        if ~strcmp(deblank(trans_obj.Config.ChannelID),bottom_xml.Infos.ChannelID)
            fprintf('Those bottoms have been written for a different GPT %.0f kHz',bottom_xml.Infos.Freq);
        end
        
        bot_xml=bottom_xml.Bottom;
        if init_bot(idx_freq)==1
            init_bot(idx_freq)=0;
            new_bottom{idx_freq}= bottom_cl(...
                'Origin',sprintf('XML_v%s',ver),...
                'Sample_idx',nan(size(trans_obj.Time)),...
                'Tag',nan(size(trans_obj.Time)),...
                'Version',p.Results.Version);
        end
        
        switch ver
            case '0.1'
                time=bot_xml.Time;
                range=bot_xml.Range;
                tag=bot_xml.Tag;
                
                if time(1)<=trans_obj.Time(1)
                    [~,idx_ping_start]=nanmin(abs(trans_obj.Time(1)-time(1)));
                    idx_start_file=1;
                else
                    idx_ping_start=1;
                    [~,idx_start_file]=nanmin(abs(trans_obj.Time-time(1)));
                end
                
                if time(end)>=trans_obj.Time(end)
                    [~,idx_ping_end]=nanmin(abs(trans_obj.Time(end)-time));
                    idx_end_file=length(trans_obj.Time);
                else
                    idx_ping_end=length(time);
                    [~,idx_end_file]=nanmin(abs(trans_obj.Time-time(end)));
                end
                
                if  time(end)<=trans_obj.Time(1)||time(1)>=trans_obj.Time(end)
                    warning('No common time between file an bottom file');
                    continue;
                end
                
                depth_resampled=resample_data_v2(range(idx_ping_start:idx_ping_end),time(idx_ping_start:idx_ping_end),trans_obj.Time(idx_start_file:idx_end_file),'Opt','Nearest');
                sample_idx=resample_data_v2((1:length(trans_obj.get_transceiver_range())),trans_obj.get_transceiver_range(),depth_resampled,'Opt','Nearest');
                tag_resampled=resample_data_v2(tag(idx_ping_start:idx_ping_end),time(idx_ping_start:idx_ping_end),trans_obj.Time(idx_start_file:idx_end_file),'Opt','Nearest');
                
                sample_idx(sample_idx<=1)=nan;
                
                new_bottom{idx_freq}.Sample_idx(idx_start_file:idx_end_file)=sample_idx;
                new_bottom{idx_freq}.Tag(idx_start_file:idx_end_file)=tag_resampled;
            case '0.2'
                pings=bot_xml.Ping;
                samples=bot_xml.Sample;
                samples(samples<=1)=nan;
                tag=bot_xml.Tag;
                
                iping_ori=find(layer_obj.Transceivers(idx_freq).Data.FileId==ix,1);
                
                new_bottom{idx_freq}.Sample_idx(pings+iping_ori-1)=samples;
                new_bottom{idx_freq}.Tag(pings+iping_ori-1)=tag;
        end
    end   
end

for idx_freq=1:length(layer_obj.Transceivers)
    trans_obj=layer_obj.Transceivers(idx_freq);
    if isempty(new_bottom{idx_freq})
        continue;
    end
    trans_obj.Bottom=new_bottom{idx_freq};
    
end

end



