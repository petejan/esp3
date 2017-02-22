classdef survey_cl < handle
    properties
        SurvInput
        SurvOutput
    end
    
    methods
        function obj=survey_cl(varargin)
            
            p = inputParser;
            def_in=survey_input_cl();
            def_out=[];
            addParameter(p,'SurvInput',def_in,@(obj) iempty(obj)|isa(obj,'survey_input_cl'));
            addParameter(p,'SurvOutput',def_out,@(obj) iempty(obj)|isa(obj,'survey_output_cl'));
            
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