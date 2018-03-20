
classdef transceiver_cl < handle
    
    properties
        Data=ac_data_cl.empty();
        Range
        Time
        Bottom
        ST
        Tracks
        Regions
        Params
        Config
        Filters
        GPSDataPing
        AttitudeNavPing
        Algo
        Mode
        
    end
    
    
    methods
        function trans_obj = transceiver_cl(varargin)
            p = inputParser;
            
            
            check_data_class=@(trans_obj) isa(trans_obj,'ac_data_cl');
            check_bottom_class=@(trans_obj) isa(trans_obj,'bottom_cl');
            check_region_class=@(trans_obj) isa(trans_obj,'region_cl');
            check_param_class=@(trans_obj) isa(trans_obj,'params_cl');
            check_config_class=@(trans_obj) isa(trans_obj,'config_cl');
            check_filter_class=@(trans_obj) isa(trans_obj,'filter_cl');
            check_gps_class=@(trans_obj) isa(trans_obj,'gps_data_cl');
            check_att_class=@(trans_obj) isa(trans_obj,'attitude_nav_cl');
            check_algo_class=@(trans_obj) isa(trans_obj,'algo_cl');
            
            
            
            addParameter(p,'Data',ac_data_cl.empty(),check_data_class);
            addParameter(p,'Time',[],@isnumeric);
            addParameter(p,'Range',[],@isnumeric);
            addParameter(p,'Bottom',bottom_cl(),check_bottom_class);
            addParameter(p,'ST',init_st_struct(),@isstruct);
            addParameter(p,'Tracks',struct('target_id',{},'target_ping_number',{}),@isstruct);
            addParameter(p,'Regions',region_cl.empty(),check_region_class);
            addParameter(p,'Params',params_cl(),check_param_class);
            addParameter(p,'Config',config_cl(),check_config_class);
            addParameter(p,'Filters',filter_cl.empty(),check_filter_class);
            addParameter(p,'GPSDataPing',gps_data_cl.empty(),check_gps_class);
            addParameter(p,'AttitudeNavPing',attitude_nav_cl.empty(),check_att_class);
            addParameter(p,'Algo',init_algos,check_algo_class);
            addParameter(p,'Mode','CW',@ischar);
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                trans_obj.(props{i})=results.(props{i});
            end
            
            if ~isempty(p.Results.Data)
                if isempty(p.Results.GPSDataPing)
                    trans_obj.GPSDataPing=gps_data_cl('Time',p.Results.Time);
                end
                if isempty(p.Results.AttitudeNavPing)
                    trans_obj.AttitudeNavPing=attitude_nav_cl('Time',p.Results.Time);
                end
            end
            
            trans_obj.Bottom=p.Results.Bottom;
        end
        
        function set.Bottom(obj,bottom_obj)
            
            if isempty(bottom_obj)
                bottom_obj=bottom_cl();
            end
            
            samples=obj.get_transceiver_samples();
            pings=obj.get_transceiver_pings();
            
            IdxBad=find(bottom_obj.Tag==0);
            
            IdxBad(IdxBad<=0)=[];
            
            new_bot_sple=nan(size(pings));
            
            bot_sple=bottom_obj.Sample_idx;
            
            if ~isempty(bot_sple)
                i0=abs(length(bot_sple)-length(pings));
                
                if length(bot_sple)>length(pings)
                    new_bot_sple(1+i0:end)=bot_sple(1:end-(i0+1));
                    IdxBad=IdxBad+i0;
                elseif length(bot_sple)<length(pings)
                    new_bot_sple(1+i0:i0+length(bot_sple))=bot_sple;
                    IdxBad=IdxBad+i0;
                else
                    new_bot_sple=bot_sple;
                end
                
                while nanmax(IdxBad)>length(pings)
                    IdxBad=IdxBad-1;
                end
                
                new_bot_sple(new_bot_sple>length(samples))=length(samples);
                new_bot_sple(new_bot_sple<=0)=1;
            end
            
            tag=ones(size(new_bot_sple));
            tag(IdxBad)=0;
            
            new_bot_sple(isnan(new_bot_sple(:))&tag(:)==1)=length(samples);
            obj.Bottom=bottom_cl('Origin',bottom_obj.Origin(:)','Sample_idx',new_bot_sple(:)','Tag',tag(:)','Version',bottom_obj.Version);
            
        end
        
        
        
        function rm_ST(trans_obj)
            trans_tmp=transceiver_cl();
            trans_obj.ST=trans_tmp.ST;
        end
        
        function delete(trans_obj)
            if ~isdeployed
                c = class(trans_obj);
                disp(['ML trans_object destructor called for class ',c])
            end
        end
        
        function range=get_transceiver_range(trans_obj,varargin)
            if nargin>=2
                
                idx=varargin{1};
                if ~isempty(idx)
                    range=trans_obj.Range(idx);
                else
                    range=trans_obj.Range;
                end
            else
                range=trans_obj.Range;
            end
            
        end
        
        function depth=get_transceiver_depth(trans_obj,idx_r,idx_pings)
            depth=bsxfun(@plus,trans_obj.get_transceiver_range(idx_r),trans_obj.get_transducer_depth(idx_pings));
        end
        
        function depth=get_transducer_depth(trans_obj,varargin)
            depth=trans_obj.Params.TransducerDepth(:)';
            
            if nargin>=2
                idx=varargin{1};
                if ~isempty(idx)
                    depth=depth(idx);
                end
            end
        end
        
        
        
        
        function set_transceiver_range(trans_obj,range)
            trans_obj.Range=range;
            if size(trans_obj.Range,2)>1
                trans_obj.Range=trans_obj.Range';
            end
        end
        
        function set_transceiver_time(trans_obj,time)
            trans_obj.Time=time;
            if size(trans_obj.Time,1)>1
                trans_obj.Time=trans_obj.Time';
            end
        end
        
        function samples=get_transceiver_samples(trans_obj,varargin)
            if ~isempty(trans_obj.Data)
            samples=(1:trans_obj.Data.Nb_samples)';
            if nargin>=2
                idx=varargin{1};
                samples=samples(idx);
            end
            else
                samples=[];
            end
            
        end
        
        function time=get_transceiver_time(trans_obj,varargin)
            time=trans_obj.Time;
            if nargin>=2
                idx=varargin{1};
                time=time(idx);
            end
        end
        
        function pings=get_transceiver_pings(trans_obj,varargin)
            if ~isempty(trans_obj.Data)
                pings=(1:trans_obj.Data.Nb_pings);
                if nargin>=2
                    idx=varargin{1};
                    pings=pings(idx);
                    
                end
            else
                pings=[];
            end
        end
        
        
        function list=regions_to_str(trans_obj)
            if isempty(trans_obj.Regions)
                list={};
            else
                list=cell(1,length(trans_obj.Regions));
                for i=1:length(trans_obj.Regions)
                    new_name=sprintf('%s %0.f %s',trans_obj.Regions(i).Name,trans_obj.Regions(i).ID,trans_obj.Regions(i).Type);
                    u=1;
                    new_name_ori=new_name;
                    while nansum(strcmpi(new_name,list))>=1
                        new_name=[new_name_ori '_' num2str(u)];
                        u=u+1;
                    end
                    list{i}=new_name;
                end
            end
        end
        
        function idx=find_regions_origin(trans_obj,origin)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(strcmp({trans_obj.Regions(:).Origin},origin));
            end
        end
        
        
        function idx=find_regions_type(trans_obj,type)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(strcmp({trans_obj.Regions(:).Type},type));
            end
        end
        

        function idx=find_regions_tag(trans_obj,tags)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(ismember({trans_obj.Regions(:).Tag},tags));
            end
        end
        
        function tags=get_reg_tags(trans_obj)
            if isempty(trans_obj.Regions)
                tags={};
            else
                
                tags=unique({trans_obj.Regions(:).Tag});
            end
        end
        
        function IDs=get_reg_IDs(trans_obj)
            if isempty(trans_obj.Regions)
                IDs=[];
            else
                IDs=[trans_obj.Regions(:).ID];
            end
        end
        
        
        function IDs=get_reg_Unique_IDs(trans_obj)
            if isempty(trans_obj.Regions)
                IDs={};
            else
                IDs={trans_obj.Regions(:).Unique_ID};
            end
        end
        
        function IDs=get_reg_first_Unique_ID(trans_obj)
            if isempty(trans_obj.Regions)
                IDs={};
            else
                IDs=trans_obj.Regions(1).Unique_ID;
            end
        end
        
        function fileID=get_fileID(trans_obj)
            fileID=trans_obj.Data.FileId;
        end
        
        
        function idx=find_regions_ID(trans_obj,ID)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(ismember([trans_obj.Regions(:).ID],ID));
            end
        end
        
        function idx=find_regions_Unique_ID(trans_obj,ID)
            if~iscell(ID)
                ID={ID};
            end
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(ID)
                    idx=union(idx,find(strcmpi({trans_obj.Regions(:).Unique_ID},ID{i})));
                end
            end
        end
        function reg=get_region_from_name(trans_obj,names)
            idx=trans_obj.find_regions_name(names);
            if ~isempty(idx)
                reg=trans_obj.Regions(idx);
            else
                reg=[];
            end
        end
        
        
        function reg=get_region_from_Unique_ID(trans_obj,ID)
            idx=trans_obj.find_regions_Unique_ID(ID);
            if ~isempty(idx)
                reg=trans_obj.Regions(idx);
            else
                reg=[];
            end
        end
        
        function idx=find_regions_ref(trans_obj,Reference)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(strcmpi({trans_obj.Regions(:).Reference},Reference));
            end
        end
        
        function idx=find_regions_name(trans_obj,names)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(ismember(lower({trans_obj.Regions(:).Name}),lower(names)));
            end
        end
        
        function rm_all_region(trans_obj)
            trans_obj.Regions=[];
        end
        
        function rm_tracks(trans_obj)
            trans_tmp=transceiver_cl();
            trans_obj.Tracks=trans_tmp.Tracks;
        end
        
        
        
        function rm_region_name(trans_obj,name)
            if ~isempty(trans_obj.Regions)
                idx=strcmpi({trans_obj.Regions(:).Name},name);
                trans_obj.Regions(idx)=[];
            end          
        end
        
        function rm_region_name_idx_r_idx_p(trans_obj,name,idx_r,idx_p)      
            reg_curr=trans_obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi(reg_curr(i).Name,name)||(isempty(intersect(idx_r,reg_curr(i).Idx_r))&&~isempty(idx_r))||(isempty(intersect(idx_p,reg_curr(i).Idx_pings))&&~isempty(idx_p))%TODO
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            trans_obj.Regions=reg_new;
        end
        

        
        function rm_regions(trans_obj)
            trans_obj.Regions=[];
        end
        
        function rm_region_name_id(trans_obj,name,ID)
            if ~isempty(trans_obj.Regions)
                idx=strcmpi({trans_obj.Regions(:).Name},name)&([trans_obj.Regions(:).ID]==ID);
                trans_obj.Regions(idx)=[];
            end
        end
        
        function rm_region_type_id(trans_obj,type,ID)
            if ~isempty(trans_obj.Regions)
                idx=strcmpi({trans_obj.Regions(:).Type},type)&([trans_obj.Regions(:).ID]==ID);
                trans_obj.Regions(idx)=[];
            end
        end
        
        function rm_region_id(trans_obj,unique_ID)
            if ~isempty(trans_obj.Regions)
                idx=strcmpi({trans_obj.Regions(:).Unique_ID},unique_ID);
                trans_obj.Regions(idx)=[];
            end
            
            
        end
        
        function rm_region_origin(trans_obj,origin)
            if ~isempty(trans_obj.Regions)
                idx=strcmpi({trans_obj.Regions(:).Origin},origin);
                trans_obj.Regions(idx)=[];
            end
        end
        
        
        
        function id=new_id(trans_obj)
            reg_curr=trans_obj.Regions;
            
            if ~isempty(reg_curr)
                id_list=[reg_curr(:).ID];
            else
                id_list=[];
            end
            if~isempty(id_list)
                new_id=setdiff(1:nanmax(id_list)+1,id_list);
                id=new_id(1);
            else
                id=1;
            end
        end
        
        function [idx,found]=find_reg_idx(trans_obj,unique_ID)
            if ~isempty(trans_obj.Regions)
                idx=find(strcmpi({trans_obj.Regions(:).Unique_ID},unique_ID));
            else
                idx=[];
            end
            
            if isempty(idx)
                idx=1;
                found=0;
            else
                found=1;
            end
            
            if length(idx)>1
                warning('several regions with the same ID')
            end
            
        end
        
        function [idx,found]=find_reg_name(trans_obj,name)
            if ~isempty(trans_obj.Regions)
                idx=find(strcmpi({trans_obj.Regions(:).Name},name));
            else
                idx=[];
            end
            if isempty(idx)
                idx=1;
                found=0;
            else
                found=1;
            end
            
        end
        
        function [idx,found]=find_reg_name_id(trans_obj,name,ID)
            if ~isempty(trans_obj.Regions)
                idx=find(strcmpi({trans_obj.Regions(:).Name},name)&([trans_obj.Regions(:).ID]==ID));
            else
                idx=[];
            end
            if isempty(idx)
                idx=1;
                found=0;
            else
                found=1;
            end
            
        end
        
        
        function [idx,found]=find_reg_idx_id(trans_obj,ID)
            idx=strcmpi({trans_obj.Regions(:).Name},name)&([trans_obj.Regions(:).ID]==ID);
            
            if isempty(idx)
                idx=1;
                found=0;
            else
                found=1;
            end
            
        end
        
        
        function [mean_depth,Sa]=get_mean_depth_from_region(trans_obj,unique_id)
            
            [reg_idx,found]=trans_obj.find_reg_idx(unique_id);
            
            if found==0
                mean_depth=[];
                Sa=[];
                return;
            end
            active_reg=trans_obj.Regions(reg_idx);  

            [Sv,idx_r,idx_pings,bad_data_mask,bad_trans_vec,intersection_mask,below_bot_mask,mask_from_st]=get_data_from_region(trans_obj,active_reg,...
                'field','sv');
            
            Mask_reg = ~bad_data_mask & intersection_mask & ~mask_from_st & ~isnan(Sv)&~below_bot_mask;
            Mask_reg(:,bad_trans_vec) = false;
            Sv(Sv<-90) = -999;
            Sv(~Mask_reg) = nan;

            range=double(trans_obj.get_transceiver_range(idx_r));
            Sa=10*log10(nansum(10.^(Sv/10).*nanmean(diff(range))));
            
            mean_depth= nansum(10.^(Sv/20).*repmat(range,1,size(Sv,2)))./nansum(10.^(Sv/20));
            mean_depth(Sa<-90)=NaN;
            
        end
        
        function set_position(trans_obj,pos_trans,trans_angle)
            trans_obj.Config.Position=pos_trans;
            trans_obj.Config.Angles=trans_angle;
        end
        
        
    end
    
    
end

