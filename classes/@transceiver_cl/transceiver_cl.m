
classdef transceiver_cl < handle
    
    properties
        Data=ac_data_cl.empty();
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
        OffsetLine
        
    end
    
    
    methods
        function obj = transceiver_cl(varargin)
            p = inputParser;
            
            
            check_data_class=@(obj) isa(obj,'ac_data_cl');
            check_bottom_class=@(obj) isa(obj,'bottom_cl');
            check_region_class=@(obj) isa(obj,'region_cl');
            check_param_class=@(obj) isa(obj,'params_cl');
            check_config_class=@(obj) isa(obj,'config_cl');
            check_filter_class=@(obj) isa(obj,'filter_cl');
            check_gps_class=@(obj) isa(obj,'gps_data_cl');
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_algo_class=@(obj) isa(obj,'algo_cl');
            check_line_class=@(obj) isa(obj,'line_cl');
            
            
            addParameter(p,'Data',ac_data_cl.empty(),check_data_class);
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
            addParameter(p,'OffsetLine',line_cl.empty(),check_line_class);
            addParameter(p,'Mode','CW',@ischar);
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            if ~isempty(p.Results.Data)
                if isempty(p.Results.GPSDataPing)
                    obj.GPSDataPing=gps_data_cl('Time',p.Results.Data.Time);
                end
                if isempty(p.Results.AttitudeNavPing)
                    obj.AttitudeNavPing=attitude_nav_cl('Time',p.Results.Data.Time);
                end
            end
            
            obj.setBottom(p.Results.Bottom);
        end
        
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
        function range=get_transceiver_range(obj,varargin)
            if nargin>=2
                idx=varargin{1};
                range=obj.Data.get_range(idx);
            else
                range=obj.Data.get_range();
            end
            
%             if ~isempty(obj.Params.TransducerDepth)
%                 range=range+obj.Params.TransducerDepth;
%             end
            
        end
        
          function range=get_transceiver_samples(obj,varargin)
            if nargin>=2
                idx=varargin{1};
                range=obj.Data.get_samples(idx);
            else
                range=obj.Data.get_samples();
            end
            
%             if ~isempty(obj.Params.TransducerDepth)
%                 range=range+obj.Params.TransducerDepth;
%             end
            
        end
        
        function pings=get_transceiver_pings(obj,varargin)
            if nargin>=2
                idx=varargin{1};
                pings=obj.Data.get_numbers(idx);
            else
                pings=obj.Data.get_numbers();
            end
            
        end
        
        
        
        function list=regions_to_str(obj)
            if isempty(obj.Regions)
                list={};
            else
                list=cell(1,length(obj.Regions));
                for i=1:length(obj.Regions)
                    new_name=sprintf('%s %0.f %s',obj.Regions(i).Name,obj.Regions(i).ID,obj.Regions(i).Type);
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
        
        function idx=find_regions_origin(obj,origin)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=find(strcmp({obj.Regions(:).Origin},origin));
            end
        end
        
        
        function idx=find_regions_type(obj,type)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=find(strcmp({obj.Regions(:).Type},type));
            end
        end
        
        function idx=find_regions_tag(obj,tag)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=find(strcmp({obj.Regions(:).Tag},tag));
            end
        end
        
        function tags=get_reg_tags(obj)
            if isempty(obj.Regions)
                tags={};
            else
                
                tags=unique({obj.Regions(:).Tag});
            end
        end
        
        function IDs=get_reg_IDs(obj)
            if isempty(obj.Regions)
                IDs=[];
            else
                IDs=[obj.Regions(:).ID];
            end
        end
        
        
        function IDs=get_reg_Unique_IDs(obj)
            if isempty(obj.Regions)
                IDs=[];
            else
                IDs=[obj.Regions(:).Unique_ID];
            end
        end
        
        function idx=find_regions_ID(obj,ID)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(ID)
                    idx=union(idx,find([obj.Regions(:).ID]==ID(i)));
                end
            end
        end
        
        function idx=find_regions_Unique_ID(obj,ID)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(ID)
                    idx=union(idx,find([obj.Regions(:).Unique_ID]==ID(i)));
                end
            end
        end
        
        function idx=find_regions_name(obj,name)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=find(strcmpi({obj.Regions(:).Name},name));
            end
        end
        
        function rm_all_region(obj)
            obj.Regions=[];
        end
        
        function rm_tracks(obj)
            trans_tmp=transceiver_cl();
            obj.Tracks=trans_tmp.Tracks;
        end
        
        function rm_region_name(obj,name)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Name),(name))
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            obj.Regions=reg_new;
        end
        
        function rm_region_name_idx_r_idx_p(obj,name,idx_r,idx_p)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi(reg_curr(i).Name,name)||(isempty(intersect(idx_r,reg_curr(i).Idx_r))&&~isempty(idx_r))||(isempty(intersect(idx_p,reg_curr(i).Idx_pings))&&~isempty(idx_p))%TODO
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            obj.Regions=reg_new;
        end
        
        function rm_regions(obj)
            reg_new=[];
            
            obj.Regions=reg_new;
        end
        
        function rm_region_name_id(obj,name,ID)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Name),(name))||(reg_curr(i).ID~=ID)
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            obj.Regions=reg_new;
        end
        
        function rm_region_type_id(obj,type,ID)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Type),(type))||(reg_curr(i).ID~=ID)
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            obj.Regions=reg_new;
        end
        
        function rm_region_id(obj,unique_ID)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if reg_curr(i).Unique_ID~=unique_ID;
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            if isempty(reg_new)
                obj.Regions=[];
            else
                obj.Regions=reg_new;
            end
        end
        
        function rm_region_origin(obj,origin)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi(reg_curr(i).Origin,origin)
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            obj.Regions=reg_new;
        end
        
        
        
        function id=new_id(obj)
            reg_curr=obj.Regions;
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
        
        function unique_id=new_unique_id(obj)
            reg_curr=obj.Regions;
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
        
        function [idx,found]=find_reg_name_id(obj,name,ID)
            reg_curr=obj.Regions;
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
        
        
        function [mean_depth,Sa]=get_mean_depth_from_region(obj,unique_id)
            
            [reg_idx,found]=obj.find_reg_idx(unique_id);
            
            if found==0
                mean_depth=[];
                Sa=[];
                return;
            end
            active_reg=obj.Regions(reg_idx);
            Sv=obj.Data.get_datamat('sv');
            idx=find_regions_type(obj,'Bad Data');
            
            for i=idx
                curr_reg=obj.Regions(i);
                Sv_temp=Sv(idx_r_curr,idx_pings_curr);
                mask=curr_reg.create_mask();
                Sv(mask)=nan;
                Sv(idx_r_curr,idx_pings_curr)=Sv_temp;
            end
            
            Sv(:,(obj.Bottom.Tag==0))=NaN;
            bot_r=obj.get_bottom_range();
            bot_r(bot_r==0)=obj.Data.Range(2);
            bot_r(isnan(bot_r))=obj.Data.Range(2);
            
            Sv(repmat(bot_r,size(Sv,1),1)<=repmat(obj.get_transceiver_range(),1,size(Sv,2)))=NaN;
            
            idx_r=active_reg.Idx_r;
            idx_pings=active_reg.Idx_pings;
            bot_r_pings=bot_r(idx_pings);
            
            switch active_reg.Shape
                case 'Polygon'
                    Sv_reg=active_reg.Sv_reg;
                otherwise
                    Sv_reg=Sv(idx_r,idx_pings);
            end
            Sv_reg(repmat(bot_r_pings,size(Sv_reg,1),1)<=repmat(obj.get_transceiver_range(idx_r),1,size(Sv_reg,2)))=NaN;
            
            Sv_reg(Sv_reg<-70)=nan;
            range=double(obj.get_transceiver_range(idx_r));
            Sa=10*log10(nansum(10.^(Sv_reg/10).*nanmean(diff(range))));
            
            mean_depth= nansum(10.^(Sv_reg/20).*repmat(range,1,size(Sv_reg,2)))./nansum(10.^(Sv_reg/20));
            mean_depth(Sa<-70)=NaN;
            
        end
        
        function set_position(obj,pos_trans,trans_angle)
            obj.Config.Position=pos_trans;
            obj.Config.Angles=trans_angle;
        end
        
        
    end
    
    
end

