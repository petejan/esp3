classdef mbs_cl < handle
    properties
        Header
        Input
        Output
        OutputFile
    end
    
    methods
        function obj=mbs_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Header',mbs_header_cl(),@(obj) isa(obj,'mbs_header_cl'));
            addParameter(p,'Input',mbs_input_cl(),@(obj) isa(obj,'mbs_input_cl'));
            addParameter(p,'Output',mbs_output_cl(),@(obj) isa(obj,'mbs_Output_cl'));
            addParameter(p,'OutputFile',fullfile(pwd,'mbs_run.txt'),@ischar);
            
            parse(p,varargin{:});
            
            props=fieldnames(p.Results);
            
            for i=1:length(props)
                if size(p.Results.(props{i}),2)==1
                    obj.(props{i})=p.Results.(props{i});
                else
                    obj.(props{i})=p.Results.(props{i})';
                end
            end
            
        end
        function delete(obj)
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end

          
        
    end
    
    
end