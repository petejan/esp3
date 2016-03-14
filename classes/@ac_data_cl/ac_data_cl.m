
classdef ac_data_cl < handle
    properties
        SubData
        Fieldname
        Type
        Samples
        Range
        FileId
        Time
        Number
        MemapName
    end
    
    
    methods
        function obj = ac_data_cl(varargin)
            p = inputParser;
            
            check_sub_ac_data_class=@(sub_ac_data_obj) isa(sub_ac_data_obj,'sub_ac_data_cl')||isempty(sub_ac_data_obj);
            checkname=@(name) iscell(name)||ischar(name);
            
            
            addParameter(p,'SubData',[],check_sub_ac_data_class);
            addParameter(p,'Range',[],@isnumeric);
            addParameter(p,'Samples',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
            addParameter(p,'Number',[],@isnumeric);
            addParameter(p,'FileId',[],@isnumeric);
            addParameter(p,'MemapName','',checkname);
            
            parse(p,varargin{:});
            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                obj.(props{i})=results.(props{i});
            end
            
            if ischar(obj.MemapName)
                obj.MemapName={obj.MemapName};
            end
            
            if isempty(p.Results.FileId)
                obj.FileId=ones(size(obj.Time));
            end
            
            if ~isempty(p.Results.SubData)
                
                fieldname=cell(1,length(obj.SubData));
                type=cell(1,length(obj.SubData));
                for i=1:length(obj.SubData)
                    fieldname{i}=obj.SubData(i).Fieldname;
                    type{i}=obj.SubData(i).Type;
                end
                obj.Fieldname=fieldname;
                obj.Type=type;
            else
                obj.Fieldname={};
                obj.Type={};
            end
        end
    end
end

