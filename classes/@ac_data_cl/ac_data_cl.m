
classdef ac_data_cl < handle
    properties
        SubData
        Fieldname
        Type
        FileId
        Nb_samples
        Nb_pings
        MemapName
    end
    
    
    methods
        function obj = ac_data_cl(varargin)
            p = inputParser;
            
            check_sub_ac_data_class=@(sub_ac_data_obj) isa(sub_ac_data_obj,'sub_ac_data_cl')||isempty(sub_ac_data_obj);
            checkname=@(name) iscell(name)||ischar(name);
            
            
            addParameter(p,'SubData',[],check_sub_ac_data_class);
            addParameter(p,'Nb_samples',[],@isnumeric);
            addParameter(p,'Nb_pings',[],@isnumeric);
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
                obj.FileId=ones(1,obj.Nb_pings);
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
        
        function ac_data_file=get_data_idx_file(ac_data_obj,file_id)
            ac_data_file=ac_data_cl();
            for isub=1:numel(ac_data_obj.SubData)
                ac_data_file.SubData=[ac_data_file.SubData ac_data_obj.SubData(isub).get_sub_data_file_id(file_id)];
            end
            
            idx=find(ac_data_obj.FileId==file_id);
            ac_data_file.Fieldname=ac_data_obj.Fieldname;
            ac_data_file.Type=ac_data_obj.Type;
            ac_data_file.FileId=ones(size(idx));
            ac_data_file.Nb_samples=ac_data_obj.Nb_samples;
            ac_data_file.Nb_pings=numel(idx);
            ac_data_file.MemapName=ac_data_obj.MemapName(file_id);
        end
        
        function delete(obj)     
            if ~isdeployed
                 c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        

    end
end

