
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
            
            trans_obj.setBottom(p.Results.Bottom);
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
            samples=(1:trans_obj.Data.Nb_samples)';
            if nargin>=2
                idx=varargin{1};
                samples=samples(idx);
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
            pings=(1:trans_obj.Data.Nb_pings);
            if nargin>=2
                idx=varargin{1};
                pings=pings(idx);
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
        
        function idx=find_regions_tag(trans_obj,tag)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(strcmp({trans_obj.Regions(:).Tag},tag));
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
                IDs=[];
            else
                IDs=[trans_obj.Regions(:).Unique_ID];
            end
        end
        
        function IDs=get_reg_first_Unique_ID(trans_obj)
            if isempty(trans_obj.Regions)
                IDs=[];
            else
                IDs=[trans_obj.Regions(1).Unique_ID];
            end
        end
        
        function fileID=get_fileID(trans_obj)
            fileID=trans_obj.Data.FileId;
        end
        
        
        function idx=find_regions_ID(trans_obj,ID)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(ID)
                    idx=union(idx,find([trans_obj.Regions(:).ID]==ID(i)));
                end
            end
        end
        
        function idx=find_regions_Unique_ID(trans_obj,ID)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(ID)
                    idx=union(idx,find([trans_obj.Regions(:).Unique_ID]==ID(i)));
                end
            end
        end
        
        function reg=get_region_from_Unique_ID(trans_obj,ID)
            idx=find_regions_Unique_ID(trans_obj,ID);
            if ~isempty(idx)
                reg=trans_obj.Regions(idx);
            else
                reg=[];
            end
        end
        
        function idx=find_regions_name(trans_obj,name)
            if isempty(trans_obj.Regions)
                idx=[];
            else
                idx=find(strcmpi({trans_obj.Regions(:).Name},name));
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
            reg_curr=trans_obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Name),(name))
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            trans_obj.Regions=reg_new;
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
            reg_new=[];
            
            trans_obj.Regions=reg_new;
        end
        
        function rm_region_name_id(trans_obj,name,ID)
            reg_curr=trans_obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Name),(name))||(reg_curr(i).ID~=ID)
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            trans_obj.Regions=reg_new;
        end
        
        function rm_region_type_id(trans_obj,type,ID)
            reg_curr=trans_obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Type),(type))||(reg_curr(i).ID~=ID)
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            trans_obj.Regions=reg_new;
        end
        
        function rm_region_id(trans_obj,unique_ID)
            reg_curr=trans_obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if reg_curr(i).Unique_ID~=unique_ID;
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            if isempty(reg_new)
                trans_obj.Regions=[];
            else
                trans_obj.Regions=reg_new;
            end
        end
        
        function rm_region_origin(trans_obj,origin)
            reg_curr=trans_obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi(reg_curr(i).Origin,origin)
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            trans_obj.Regions=reg_new;
        end
        
        
        
        function id=new_id(trans_obj)
            reg_curr=trans_obj.Regions;
            id_list=[];
            for i=1:length(reg_curr)
                id_list=[reg_curr(i).ID id_list];
            end
            if~isempty(id_list)
                new_id=setdiff(1:nanmax(id_list)+1,id_list);
                id=new_id(1);
            else
                id=1;
            end
        end
        
        function unique_id=new_unique_id(trans_obj)
            reg_curr=trans_obj.Regions;
            id_list=nan(size(reg_curr));
            for i=1:length(reg_curr)
                id_list(i)=reg_curr(i).Unique_ID;
            end
            unique_id=str2double(datestr(now,'yyyymmddHHMMSSFFF'));
            while any(unique_id==id_list)
                unique_id=str2double(datestr(now,'yyyymmddHHMMSSFFF'));
            end
        end
        
        function [idx,found]=find_reg_idx(trans,u_id)
            
            idx=[];
            for ii=1:length(trans.Regions)
                
                if u_id==trans.Regions(ii).Unique_ID
                    idx=[idx ii];
                    found=1;
                end
            end
            
            if isempty(idx)
                idx=1;
                found=0;
            end
            
            if length(idx)>1
                warning('several regions with the same ID')
            end
            
        end
        
        function [idx,found]=find_reg_name_id(trans_obj,name,ID)
            reg_curr=trans_obj.Regions;
            idx=[];
            found=0;
            for i=1:length(reg_curr)
                if (strcmpi((reg_curr(i).Name),(name))&&((reg_curr(i).ID)==ID))
                    idx=[idx i];
                    found=found+1;
                end
            end
            
            if isempty(idx)
                idx=1;
                found=0;
            end
            
        end
        
        
        function [idx,found]=find_reg_idx_id(trans,id)
            idx=[];
            for ii=1:length(trans.Regions)
                if id==trans.Regions(ii).ID
                    idx=[idx ii];
                    found=1;
                end
            end
            if isempty(idx)
                idx=1;
                found=0;
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
            Sv=trans_obj.Data.get_datamat('sv');
            idx=find_regions_type(trans_obj,'Bad Data');
            
            for i=idx
                curr_reg=trans_obj.Regions(i);
                Sv_temp=Sv(idx_r_curr,idx_pings_curr);
                mask=curr_reg.create_mask();
                Sv(mask)=nan;
                Sv(idx_r_curr,idx_pings_curr)=Sv_temp;
            end
            range=trans_obj.get_transceiver_range();
            
            Sv(:,(trans_obj.Bottom.Tag==0))=NaN;
            bot_r=trans_obj.get_bottom_range();
            bot_r(bot_r==0)=range(end);
            bot_r(isnan(bot_r))=range(end);
            
            Sv(repmat(bot_r,size(Sv,1),1)<=repmat(trans_obj.get_transceiver_range(),1,size(Sv,2)))=NaN;
            
            idx_r=active_reg.Idx_r;
            idx_pings=active_reg.Idx_pings;
            bot_r_pings=bot_r(idx_pings);
            
            switch active_reg.Shape
                case 'Polygon'
                    Sv_reg=active_reg.Sv_reg;
                otherwise
                    Sv_reg=Sv(idx_r,idx_pings);
            end
            Sv_reg(repmat(bot_r_pings,size(Sv_reg,1),1)<=repmat(trans_obj.get_transceiver_range(idx_r),1,size(Sv_reg,2)))=NaN;
            
            Sv_reg(Sv_reg<-70)=nan;
            range=double(trans_obj.get_transceiver_range(idx_r));
            Sa=10*log10(nansum(10.^(Sv_reg/10).*nanmean(diff(range))));
            
            mean_depth= nansum(10.^(Sv_reg/20).*repmat(range,1,size(Sv_reg,2)))./nansum(10.^(Sv_reg/20));
            mean_depth(Sa<-70)=NaN;
            
        end
        
        function set_position(trans_obj,pos_trans,trans_angle)
            trans_obj.Config.Position=pos_trans;
            trans_obj.Config.Angles=trans_angle;
        end
        
        
    end
    
    
end

