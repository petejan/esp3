classdef attitude_nav_cl < handle
    properties
        Heading
        Heave
        Pitch
        Roll
        Time
        SOG
    end
    
    methods
        function obj = attitude_nav_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Heading',[],@isnumeric);
            addParameter(p,'Roll',[],@isnumeric);
            addParameter(p,'Heave',[],@isnumeric);
            addParameter(p,'Pitch',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
            addParameter(p,'SOG',[],@isnumeric);
                      
            parse(p,varargin{:});
           
            results=p.Results;
            props=fieldnames(results);
 
            for i=1:length(props)  
                obj.(props{i})=results.(props{i});        
            end
        end
        
        function attitude_out=concatenate_AttitudeNavPing(attitude_1,attitude_2)
            
            if ~isempty(attitude_1)&&~isempty(attitude_2)
            
            heading=[attitude_1.Heading(:); attitude_2.Heading(:)];
            roll=[attitude_1.Roll(:); attitude_2.Roll(:)];
            heave=[attitude_1.Heave(:); attitude_2.Heave(:)];
            pitch=[attitude_1.Pitch(:); attitude_2.Pitch(:)];
            time=[attitude_1.Time(:); attitude_2.Time(:)];
            
            
        attitude_out=attitude_nav_cl('Heading',heading,...
            'Roll',roll,...
            'Heave',heave,...
            'Pitch',pitch,...
            'Time',time);
            else
                attitude_out=attitude_nav_cl.empty();
            end
        
        end
        
    end
    
end