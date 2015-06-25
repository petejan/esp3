classdef curr_state_disp_cl <handle
    
    properties (SetObservable = true)
        Freq
        Type
        Xaxes
        Cax
        DispBottom 
        DispTracks
        DispBadTrans
        DispReg
    end
    
    methods
        function obj =curr_state_disp_cl(varargin)
            
            p = inputParser;
            addParameter(p,'Freq',38000,@isnumeric);
            addParameter(p,'Type','Sv',@ischar);
            addParameter(p,'Cax',[-100 -90],@ischar);
            addParameter(p,'DispBottom','on',@ischar);
            addParameter(p,'DispTracks','on',@ischar);
            addParameter(p,'DispBadTrans',true,@islogical);
            addParameter(p,'DispReg',true,@islogical);
            addParameter(p,'Xaxes','Number',@ischar);
            parse(p,varargin{:});            
            results=p.Results;
            props=fieldnames(results);
            
            for i=1:length(props)
                
                obj.(props{i})=results.(props{i});
                
            end
            
        end
    end
    
end

