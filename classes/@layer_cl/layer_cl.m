
classdef layer_cl < handle
    properties
        ID_num=0;
        Filename={''};
        Filetype='';
        PathToFile='';
        Transceivers
        OriginCrest
        Lines
        Frequencies
        GPSData
        AttitudeNav
        EnvData
        Curves
        SurveyData
    end
    
    
    methods
        function obj = layer_cl(varargin)
            p = inputParser;
            
            
            check_att_class=@(obj) isa(obj,'attitude_nav_cl');
            check_gps_class=@(gps_data_obj) isa(gps_data_obj,'gps_data_cl');
            check_curve_cl=@(curve_obj) isempty(curve_obj)|isa(curve_obj,'curve_cl');
            check_env_class=@(env_data_obj) isa(env_data_obj,'env_data_cl');
            check_transceiver_class=@(transceiver_obj) isa(transceiver_obj,'transceiver_cl')|isempty(transceiver_obj);
            check_line_class=@(obj) isa(obj,'line_cl')|isempty(obj);
            
            addParameter(p,'ID_num',0,@isnumeric);
            addParameter(p,'Filename',{'No Data'},@(fname)(iscell(fname)));
            addParameter(p,'Filetype','',@(ftype)(ischar(ftype)));
            addParameter(p,'PathToFile','',@(fname)(ischar(fname)||iscell(fname)));
            addParameter(p,'Transceivers',[],check_transceiver_class);
            addParameter(p,'Lines',[],check_line_class);
            addParameter(p,'Frequencies',[],@isnumeric);
            addParameter(p,'GPSData',gps_data_cl(),check_gps_class);
            addParameter(p,'Curves',[],check_curve_cl);
            addParameter(p,'AttitudeNav',attitude_nav_cl(),check_att_class);
            addParameter(p,'EnvData',env_data_cl(),check_env_class);
            addParameter(p,'OriginCrest','');
            addParameter(p,'SurveyData',[],@(obj) isa(obj,'survey_data_cl')|isempty(obj))
            
            parse(p,varargin{:});
            
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)               
                obj.(props{i})=results.(props{i});               
            end
            obj.(props{i})=results.(props{i});          

        end
        
        function delete(layer)
            
            for kk=1:length(layer.Transceivers)
                for uu=1:length(layer.Transceivers(kk).Data.SubData)
                    layer.Transceivers(kk).Data.SubData(uu).delete();
                end
                
            end
        end
        
       
        
        function rm_region_across_id(layer,ID)                                
            for i=1:length(layer.Transceivers)
                layer.Transceivers(i).rm_region_id(ID);
            end           
        end
        
        
        
        function list=list_lines(obj)
            if isempty(obj.Lines)
                list={};
            else
                list=cell(1,length(obj.Lines));
                for i=1:length(obj.Lines)
                    [~,name,ext]=fileparts(obj.Lines(i).File_origin);
                    list{i}=sprintf('%s %s',obj.Lines(i).Name,[name ext]);
                end
            end
        end
        
        function rm_line_id(obj,unique_ID)
            lines_curr=obj.Lines;
            lines_new=[];
            for i=1:length(lines_curr)
                if lines_curr(i).ID~=unique_ID;
                    lines_new=[lines_new lines_curr(i)];
                end
            end
            obj.Lines=lines_new;
        end
        
        function add_lines(obj,lines)
            for i=1:length(lines)
                obj.rm_line_id(lines(i).ID);
                obj.Lines=[obj.Lines lines(i)];
            end
        end
        
        function add_curves(obj,curves)
            for i=1:length(curves)
               obj.Curves=[obj.Curves curves(i)]; 
            end
        end
        
        function tags=get_curves_tag(obj)
            tags=cell(1,length(obj.Curves));
            for i=1:length(obj.Curves)
                tags{i}=obj.Curves(i).Tag;
            end
            tags=unique(tags);
        end
        
        function idx=get_curves_per_tag(obj,tag)
            idx=[];
            for i=1:length(obj.Curves)
                if strcmp(obj.Curves(i).Tag,tag);
                    idx=[idx i];
                end
            end
        end
        
        function clear_curves(obj)
            obj.Curves=[];
        end
        
    end
    
end