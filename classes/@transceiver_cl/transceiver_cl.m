%
%            Data: [1x1 ac_data_cl]
%          Bottom: [1x1 bottom_cl]
%          IdxBad: []
%         Regions: []
%          Params: [1x1 params_cl]
%          Config: [1x1 config_cl]
%         Filters: [1x1 filter_cl]
%     GPSDataPing: [1x1 gps_data_cl]
%            Algo: [1x4 algo_cl]
%            Mode: 'CW'
%
%
%
% Methods for class transceiver_cl:
%
% add_region         list_regions       rm_region          transceiver_cl
% find_algo_idx      new_id             rm_region_type_id


classdef transceiver_cl < handle
    
    properties
        Data
        Bottom
        IdxBad
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
        function obj = transceiver_cl(varargin)
            p = inputParser;
            
            
            check_data_class=@(obj) isa(obj,'ac_data_cl')||isempty(obj);
            check_bottom_class=@(obj) isa(obj,'bottom_cl');
            check_region_class=@(obj) isa(obj,'region_cl')||isempty(obj);
            check_param_class=@(obj) isa(obj,'params_cl');
            check_config_class=@(obj) isa(obj,'config_cl');
            check_filter_class=@(obj) isa(obj,'filter_cl');
            check_gps_class=@(obj) isa(obj,'gps_data_cl');
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_algo_class=@(obj) isa(obj,'algo_cl')||isempty(obj);
            
            
            addParameter(p,'Data',[],check_data_class);
            addParameter(p,'Bottom',bottom_cl(),check_bottom_class);
            addParameter(p,'IdxBad',[],@(obj)(isnumeric(obj)||islogical(obj)));
            addParameter(p,'ST',init_st_struct(),@isstruct);
            addParameter(p,'Tracks',struct('target_id',{},'target_ping_number',{}),@isstruct);
            addParameter(p,'Regions',[],check_region_class);
            addParameter(p,'Params',params_cl(),check_param_class);
            addParameter(p,'Config',config_cl(),check_config_class);
            addParameter(p,'Filters',filter_cl.empty(),check_filter_class);
            addParameter(p,'GPSDataPing',gps_data_cl(),check_gps_class);
            addParameter(p,'AttitudeNavPing',attitude_nav_cl.empty(),check_att_class);
            addParameter(p,'Algo',[],check_algo_class);
            addParameter(p,'Mode','CW',@ischar);
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
%             if isempty(p.Results.Data)
%                 obj.Data=ac_data_cl();
%             end
            
        end
        
        
        
        function list=list_regions(obj)
            if isempty(obj.Regions)
                list={};
            else
                list=cell(1,length(obj.Regions));
                for i=1:length(obj.Regions)
                    list{i}=sprintf('%s %0.f %s',obj.Regions(i).Name,obj.Regions(i).ID,obj.Regions(i).Type);
                end
            end
        end

        function idx=list_regions_origin(obj,origin)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(obj.Regions)
                    if strcmpi(obj.Regions(i).Origin,origin)
                        idx=[idx i];
                    end
                end
            end
        end
        
        
        function idx=list_regions_type(obj,type)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(obj.Regions)
                    if strcmp(obj.Regions(i).Type,type)
                        idx=[idx i];
                    end
                end
            end
        end

        function idx=list_regions_ID(obj,ID)
            if isempty(obj.Regions)
                idx=[];
            else
              idx=[];
                for i=1:length(ID)
                    idx=union(idx,find([obj.Regions(:).ID]==ID(i)));
                end
            end
        end

        function idx=list_regions_Unique_ID(obj,ID)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(ID)
                    idx=union(idx,find([obj.Regions(:).Unique_ID]==ID(i)));
                end
            end
        end
        
        function idx=list_regions_name(obj,name)
            if isempty(obj.Regions)
                idx=[];
            else
                idx=[];
                for i=1:length(obj.Regions)
                    if strcmp(obj.Regions(i).Name,name)
                        idx=[idx i];
                    end
                end
            end
        end
        
        function rm_all_region(obj)
            obj.Regions=[];
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
        
        function rm_region_type_id(obj,type,ID)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~strcmpi((reg_curr(i).Type),(type))&&~strcmpi((reg_curr(i).ID),ID)
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
            obj.Regions=reg_new;
        end
        
        
        function rm_region_name_id(obj,name,ID)
            reg_curr=obj.Regions;
            reg_new=[];
            for i=1:length(reg_curr)
                if ~(strcmpi((reg_curr(i).Name),(name))&&((reg_curr(i).ID)==ID))
                    reg_new=[reg_new reg_curr(i)];
                end
            end
            obj.Regions=reg_new;
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
      
        
        
        
        function id=new_id(obj,name)
            reg_curr=obj.Regions;
            id_list=[];
            for i=1:length(reg_curr)
                if strcmpi((reg_curr(i).Name),name)
                    id_list=[reg_curr(i).ID id_list];
                end
            end
            if~isempty(id_list)
                id=nanmax(id_list)+1;
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
            unique_id=unidrnd(2^64);
            while ~isempty(find(unique_id==id_list,1))
                unique_id=unidrnd(2^64);
            end
        end
        
        function [idx,found]=find_reg_idx(trans,id)
            
            idx=[];
            for ii=1:length(trans.Regions)
                if id==trans.Regions(ii).Unique_ID
                    idx=ii;
                    found=1;
                end
            end
            
            if isempty(idx)
                idx=1;
                found=0;
            end
            
        end
        
        function [idx,found]=find_reg_name_id(obj,name,ID)
            reg_curr=obj.Regions;
            idx=[];
            found=0;
            for i=1:length(reg_curr)
                if (strcmpi((reg_curr(i).Name),(name))&&((reg_curr(i).ID)==ID))
                    idx=i;
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
            end
            active_reg=obj.Regions(reg_idx);
            Sv=obj.Data.get_datamat('sv');
            idx=list_regions_type(obj,'Bad Data');
            
            for i=idx
                curr_reg=obj.Regions(i);
                idx_r_curr=curr_reg.Idx_r;
                idx_pings_curr=curr_reg.Idx_pings;
                switch curr_reg.Shape
                    case 'Rectangular'
                        Sv(idx_r_curr,idx_pings_curr)=NaN;
                    case 'Polygon'
                        Sv(idx_r_curr,idx_pings_curr)=curr_reg.Sv_reg;
                end
            end
            
            Sv(:,obj.IdxBad)=NaN;
            bot_r=obj.Bottom.Range;
            bot_r(bot_r==0)=obj.Data.Range(end);
            bot_r(isnan(bot_r))=obj.Data.Range(end);
            
            Sv(repmat(bot_r,size(Sv,1),1)<=repmat(obj.Data.Range,1,size(Sv,2)))=NaN;
            
            idx_r=active_reg.Idx_r;
            idx_pings=active_reg.Idx_pings;
            bot_r_pings=bot_r(idx_pings);
            
            switch active_reg.Shape
                case 'Polygon'
                    Sv_reg=active_reg.Sv_reg;
                otherwise
                    Sv_reg=Sv(idx_r,idx_pings);
            end
            Sv_reg(repmat(bot_r_pings,size(Sv_reg,1),1)<=repmat(obj.Data.Range(idx_r),1,size(Sv_reg,2)))=NaN;
            idx_field=find_field_idx(obj.Data,'sv');
            cax=obj.Data.SubData(idx_field).CaxisDisplay;
            
            Sv_reg(Sv_reg<cax(1))=nan;
            range=double(obj.Data.Range(idx_r));
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

