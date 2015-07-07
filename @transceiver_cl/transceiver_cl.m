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
            
            
            check_data_class=@(obj) isa(obj,'ac_data_cl');
            check_bottom_class=@(obj) isa(obj,'bottom_cl');
            check_region_class=@(obj) isa(obj,'region_cl')||isempty(obj);
            check_param_class=@(obj) isa(obj,'params_cl');
            check_config_class=@(obj) isa(obj,'config_cl');
            check_filter_class=@(obj) isa(obj,'filter_cl');
            check_gps_class=@(obj) isa(obj,'gps_data_cl');
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_algo_class=@(obj) isa(obj,'algo_cl')||isempty(obj);
            
            addParameter(p,'Data',ac_data_cl(),check_data_class);
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
        end
        
         function trans_out=concatenate_Transceivers(trans_1,trans_2)
            if length(trans_1)==length(trans_2)
             for i=1:length(trans_1)
                 trans_out(i)=transceiver_cl('Data',concatenate_Data(trans_1(i).Data,trans_2(i).Data),...
                     'Bottom',concatenate_Bottom(trans_1(i).Bottom,trans_2(i).Bottom),...
                     'IdxBad',[trans_1(i).IdxBad; trans_2(i).IdxBad],...
                     'Algo',trans_1(i).Algo,...
                     'GPSDataPing',concatenate_GPSData(trans_1(i).GPSDataPing,trans_2(i).GPSDataPing),...
                     'Mode',trans_1(i).Mode,...
                     'AttitudeNavPing',concatenate_AttitudeNavPing(trans_1(i).AttitudeNavPing,trans_2(i).AttitudeNavPing),...
                     'Params',trans_1(i).Params,...
                     'Config',trans_1(i).Config,...
                     'Filters',trans_1(i).Filters);
             end
            else
                error('Cannot concatenate two files with diff frequencies')
            end
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
        
        function rm_region(obj,name)
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
                if ~strcmpi((reg_curr(i).Name),(name))&&~strcmpi((reg_curr(i).ID),ID)
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
        
        function add_region(obj,regions)
            for i=1:length(regions)
                obj.Regions=[obj.Regions regions(i)];
            end
        end
        
        
        function id=new_id(obj,name)
            
            reg_curr=obj.Regions;
            reg_new=[];
            id_list=[];
            for i=1:length(reg_curr)
                if strcmpi((reg_curr(i).Name),(name))
                    id_list=[reg_curr(i).ID id_list];
                end
            end
            if~isempty(id_list)
            id=nanmax(id_list+1);
            else
                id=1;
            end
        end
        
        function [idx,found]=find_reg_idx(trans,id)
            
            idx=[];
            for ii=1:length(trans.Regions)
                if id==trans.Regions(ii).ID
                    idx=ii;
                    found=1;
                end
            end
            
            if isempty(idx)
                idx=1;
                found=0;
            end
            
        end
        
    end
    
    
end

