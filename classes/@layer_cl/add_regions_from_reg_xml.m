function add_regions_from_reg_xml(layer_obj,xml_file,IDs)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addRequired(p,'xml_file',@iscell);
addRequired(p,'IDs',@isnumeric);

parse(p,layer_obj,xml_file,IDs);

for idx_freq=1:length(layer_obj.Transceivers)
    trans_obj=layer_obj.Transceivers(idx_freq);
    trans_obj.rm_all_region();
end



for ix=1:length(xml_file)
    if exist(xml_file{ix},'file')==0
        sprintf('Cannot find xml region file for %s\n',layer_obj.Filename{ix});
        continue;
    end
    
    region_xml_tot=parse_region_xml(xml_file{ix});
    
    if isempty(region_xml_tot)
        sprintf('Cannot parse xml region file for %s\n',layer_obj.Filename{ix});
        return;
    end
    
    
    
    for itrans=1:length(region_xml_tot)
        region_xml=region_xml_tot{itrans};
        [idx_freq,found]=find_freq_idx(layer_obj,region_xml.Infos.Freq);
        
        if found==0
            warning('Could not load regions for frequency %.0fkHz, it is not there...',region_xml.Infos.Freq);
            continue;
        end
        trans_obj=layer_obj.Transceivers(idx_freq);
        
        if ~strcmp(deblank(trans_obj.Config.ChannelID),region_xml.Infos.ChannelID)
            warning('Those regions have been written for a different GPT %.0fkHz',region_xml.Infos.Freq);
        end
        
        t_max=nanmax(trans_obj.Data.Time);
        t_min=nanmin(trans_obj.Data.Time);
        
        Origin='RegXML';
        
        reg_xml=region_xml.Regions;
        
        
        for i=1:length(reg_xml)
            idx_good=find(reg_xml{i}.ID==IDs);
            idx_bad=find(reg_xml{i}.ID==-IDs);
            if ~(isempty(IDs)||~isempty(idx_good)||~isempty(idx_bad))
                continue;
            end
            
            ID=reg_xml{i}.ID;
            Unique_ID=reg_xml{i}.Unique_ID;
            Tag=reg_xml{i}.Tag;
            if isempty(Tag)
                Tag='';
            end
            Name=reg_xml{i}.Name;
            switch reg_xml{i}.Type
                case 'Data'
                    if isempty(idx_good)
                        Type='Bad Data';
                    else
                        Type='Data';
                    end
                case 'Bad Data'
                    if isempty(idx_good)
                        Type='Data';
                    else
                        Type='Bad Data';
                    end
                    
            end
            Cell_w_unit=reg_xml{i}.Cell_w_unit;
            Cell_h_unit=reg_xml{i}.Cell_h_unit;
            Cell_w=reg_xml{i}.Cell_w;
            Cell_h=reg_xml{i}.Cell_h;
            Shape=reg_xml{i}.Shape;
            Reference=reg_xml{i}.Reference;
            
            time_box=reg_xml{i}.bbox_t;
            time_box(time_box<t_min)=t_min;
            time_box(time_box>t_max)=t_max;
            pings=resample_data_v2(1:length(trans_obj.Data.Time),trans_obj.Data.Time,time_box,'Opt','Nearest');
            
            depth_box=reg_xml{i}.bbox_r;
            samples=resample_data_v2(1:length(trans_obj.Data.get_range()),trans_obj.Data.get_range(),depth_box,'Opt','Nearest');
            
            Idx_pings=pings(1):pings(2);
            Idx_r=samples(1):samples(2);
            
            if nansum(isnan(Idx_pings))==length(Idx_pings)
                continue;
            end
            
            switch Shape
                case 'Rectangular'
                    X_cont=[];
                    Y_cont=[];
                case 'Polygon'
                    i_cont=0;
                    for ic=1:length(reg_xml{i}.Contours)
                        idx_rem=reg_xml{i}.Contours{ic}.Time>t_max|reg_xml{i}.Contours{ic}.Time<t_min;
                        reg_xml{i}.Contours{ic}.Time(idx_rem)=[];
                        reg_xml{i}.Contours{ic}.Range(idx_rem)=[];
                        if isempty(reg_xml{i}.Contours{ic}.Time)
                            continue;
                        end
                        i_cont=i_cont+1;
                        X_cont{i_cont}=resample_data_v2(1:length(trans_obj.Data.Time),trans_obj.Data.Time,reg_xml{i}.Contours{ic}.Time,'Opt','Nearest');
                        X_cont{i_cont}=X_cont{i_cont}-Idx_pings(1)+1;
                        Y_cont{i_cont}=resample_data_v2(1:length(trans_obj.Data.get_range()),trans_obj.Data.get_range(),reg_xml{i}.Contours{ic}.Range,'Opt','Nearest');
                        Y_cont{i_cont}=Y_cont{i_cont}-Idx_r(1)+1;
                    end
                    
            end
            new_reg=region_cl(...
                'ID',ID,...
                'Unique_ID',Unique_ID,...
                'Name',Name,...
                'Tag',Tag,...
                'Type',Type,...
                'Origin',Origin,...
                'Idx_pings',Idx_pings,...
                'Idx_r',Idx_r,...
                'Shape',Shape,...
                'X_cont',X_cont,...
                'Y_cont',Y_cont,...
                'Reference',Reference,...
                'Cell_w',Cell_w,...
                'Cell_w_unit',Cell_w_unit,...
                'Cell_h',Cell_h,...
                'Cell_h_unit',Cell_h_unit);
            
            trans_obj.add_region(new_reg);
        end
        
    end
    
    
    
end



