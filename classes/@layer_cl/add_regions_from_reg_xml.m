function pres=add_regions_from_reg_xml(layer_obj,IDs,varargin)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addRequired(p,'IDs',@isnumeric);
addParameter(p,'Frequencies',[]);

parse(p,layer_obj,IDs,varargin{:});

for idx_freq=1:length(layer_obj.Transceivers)
    trans_obj=layer_obj.Transceivers(idx_freq);
    trans_obj.rm_all_region();
end

[path_xml,reg_file_str,~]=layer_obj.create_files_str();

pres=ones(length(reg_file_str));
for ix=1:length(reg_file_str)
    xml_file=fullfile(path_xml{ix},reg_file_str{ix});
    if exist(xml_file,'file')==0
        pres(ix)=0;
        fprintf('No xml region file for %s\n',layer_obj.Filename{ix});
        continue;
    end
    
    [region_xml_tot,ver]=parse_region_xml(xml_file);
    
    if isempty(region_xml_tot)
        pres(ix)=0;
        fprintf('Cannot parse xml region file for %s\n',layer_obj.Filename{ix});
        return;
    end
    
    iping_file=find(layer_obj.Transceivers(idx_freq).Data.FileId==ix);
    
    for itrans=1:length(region_xml_tot)
        region_xml=region_xml_tot{itrans};
        
        if ~isempty(p.Results.Frequencies)&&~any(region_xml.Infos.Freq==p.Results.Frequencies)
            continue;
        end
        
        [idx_freq,found]=find_freq_idx(layer_obj,region_xml.Infos.Freq);
        
        if found==0
            warning('Could not load regions for frequency %.0fkHz, there is none...',region_xml.Infos.Freq);
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
            
            if ~isempty(IDs)
                idx_good=find(reg_xml{i}.ID==IDs);
                idx_bad=find(reg_xml{i}.ID==-IDs,1);
                if (isempty(idx_good)&&isempty(idx_bad))
                    continue;
                end
            else
                idx_good=1;
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
            
            
            switch ver
                case '0.1'
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
                    
                case '0.2'
                    
                    
                    ping_box=reg_xml{i}.bbox_p+iping_file(1)-1;
                    sample_box=reg_xml{i}.bbox_s;
                    
                    Idx_pings=ping_box(1):ping_box(2);
                    Idx_r=sample_box(1):sample_box(2);

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
                                if isempty(reg_xml{i}.Contours{ic}.Ping)
                                    continue;
                                end
                                i_cont=i_cont+1;
                                X_cont{i_cont}=reg_xml{i}.Contours{ic}.Ping;
                                Y_cont{i_cont}=reg_xml{i}.Contours{ic}.Sample;
                            end
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



