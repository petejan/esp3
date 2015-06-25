classdef attitude_nav_cl < handle
    properties
        Heading
        Heave
        Pitch
        Roll
        Time
    end
    
    methods
        function obj = attitude_nav_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Heading',[],@isnumeric);
            addParameter(p,'Roll',[],@isnumeric);
            addParameter(p,'Heave',[],@isnumeric);
            addParameter(p,'Pitch',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
                      
            parse(p,varargin{:});
           
            results=p.Results;
            props=fieldnames(results);
 
            for i=1:length(props)  
                obj.(props{i})=results.(props{i});        
            end
        end
        
        function attitude_out=concatenate_AttitudeNavPing(attitude_1,attitude_2)
            
            if size(attitude_2.Roll,1)~=1
                attitude_2.Heading=attitude_2.Heading';
                attitude_2.Roll=attitude_2.Roll';
                attitude_2.Heave=attitude_2.Heave';
                attitude_2.Pitch=attitude_2.Pitch';
                attitude_2.Time=attitude_2.Time';
            end
            
            
            if size(attitude_1.Roll,1)==1
                heading=[attitude_1.Heading attitude_2.Heading];
                roll=[attitude_1.Roll attitude_2.Roll];
                heave=[attitude_1.Heave attitude_2.Heave];
                pitch=[attitude_1.Pitch attitude_2.Pitch];
                time=[attitude_1.Time attitude_2.Time];
            else
                heading=[attitude_1.Heading' attitude_2.Heading];
                roll=[attitude_1.Roll' attitude_2.Roll];
                heave=[attitude_1.Heave' attitude_2.Heave];
                pitch=[attitude_1.Pitch' attitude_2.Pitch];
                time=[attitude_1.Time' attitude_2.Time];
            end
            
            
        attitude_out=attitude_nav_cl('Heading',heading,...
            'Roll',roll,...
            'Heave',heave,...
            'Pitch',pitch,...
            'Time',time);
        
        end
        
    end
    
end