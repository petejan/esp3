function add_regions_from_reg_xml(layer_obj,xml_file)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addRequired(p,'xml_file',@ischar);


parse(p,layer_obj,xml_file);

if exist(xml_file,'file')==0
    disp('Cannot find specified region .xml file');
    return;
end

region_xml_tot=parse_region_xml(xml_file);

if isempty(region_xml_tot)
    disp('Cannot parse specified .xml file');
    return;
end

for itrans=1:length(region_xml_tot)
    region_xml=region_xml_tot{itrans};
    [idx_freq,found]=find_freq_idx(layer_obj,region_xml.Infos.Freq);
    
    if isempty(found)
        warning('Could not load regions for frequency %.0fkHz',region_xml.Infos.Freq);
        continue;
    end
    trans_obj=layer_obj.Transceivers(idx_freq);
    if ~strcmp(deblank(trans_obj.Config.ChannelID),region_xml.Infos.ChannelID)
         warning('Those regions have been written for a different GPT %.0fkHz',region_xml.Infos.Freq);
    end
    
    
    nb_reg=length(region_xml.Regions);
    Origin='RegXML';
    
    reg_xml=region_xml.Regions;
    regions=[];
    
    for ui=1:length(reg_xml)
        
        for i=1:length(region_xml.Regions)
            ID=reg_xml{i}.ID;
            Tag=reg_xml{i}.Tag;
            Name=reg_xml{i}.Name;
            Type=reg_xml{i}.Type;
            Cell_w_unit=reg_xml{i}.Cell_w_unit;
            Cell_h_unit=reg_xml{i}.Cell_h_unit;
            Cell_w=reg_xml{i}.Cell_w;
            Cell_h=reg_xml{i}.Cell_h;
            Shape=reg_xml{i}.Shape;
            Reference=reg_xml{i}.Reference;
            
            time_box=reg_xml{i}.bbox_t;
            pings=resample_data_v2(1:length(trans_obj.Data.Time),trans_obj.Data.Time,time_box,'Opt','Nearest');
            
            depth_box=reg_xml{i}.bbox_r;
            samples=resample_data_v2(1:length(trans_obj.Data.Range),trans_obj.Data.Range,depth_box,'Opt','Nearest');
            
            Idx_pings=pings(1):pings(2);
            Idx_r=samples(1):samples(2);
            
            if nansum(isnan(Idx_pings))==length(Idx_pings)
                continue;
            end
            
            switch Shape
                case 'Rectangular'
                    MaskReg=[];
                case 'Polygon'
                    X_cont=cell(1,length(reg_xml{i}.Contours));
                    Y_cont=cell(1,length(reg_xml{i}.Contours));
                    for ic=1:length(reg_xml{i}.Contours)
                        X_cont{ic}=resample_data_v2(1:length(trans_obj.Data.Time),trans_obj.Data.Time,reg_xml{i}.Contours{ic}.Time,'Opt','Nearest');
                        X_cont{ic}=X_cont{ic}-Idx_pings(1)+1;
                        Y_cont{ic}=resample_data_v2(1:length(trans_obj.Data.Range),trans_obj.Data.Range,reg_xml{i}.Contours{ic}.Range,'Opt','Nearest');
                        Y_cont{ic}=Y_cont{ic}-Idx_r(1)+1;
                    end
                    X_grid=repmat((1:length(Idx_pings)),length(Idx_r),1);
                    Y_grid=repmat((1:length(Idx_r))',1,length(Idx_pings));
                    
                    MaskReg=mask_from_cont(X_grid,Y_grid,X_cont,Y_cont);
                    
            end
            regions=[regions region_cl(...
                'ID',ID,...
                'Name',Name,...
                'Tag',Tag,...
                'Type',Type,...
                'Origin',Origin,...
                'Idx_pings',Idx_pings,...
                'Idx_r',Idx_r,...
                'Shape',Shape,...
                'MaskReg',MaskReg,...
                'Reference',Reference,...
                'Cell_w',Cell_w,...
                'Cell_w_unit',Cell_w_unit,...
                'Cell_h',Cell_h,...
                'Cell_h_unit',Cell_h_unit)];
            
            nb_reg=nb_reg+1;
        end
        trans_obj.add_region(regions);
        
    end
    
end



