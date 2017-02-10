classdef attitude_nav_cl
    properties
        Heading
        Heave
        Pitch
        Roll
        Yaw
        Time
        %SOG
    end
    
    methods
        function obj = attitude_nav_cl(varargin)
            
            p = inputParser;
            
            addParameter(p,'Heading',[],@isnumeric);
            addParameter(p,'Roll',[],@isnumeric);
            addParameter(p,'Heave',[],@isnumeric);
            addParameter(p,'Pitch',[],@isnumeric);
            addParameter(p,'Yaw',[],@isnumeric);
            addParameter(p,'Time',[],@isnumeric);
            %addParameter(p,'SOG',[],@isnumeric);
            
            parse(p,varargin{:});
            
            if ~all([isempty(p.Results.Heading) isempty(p.Results.Roll) isempty(p.Results.Pitch) isempty(p.Results.Heave) isempty(p.Results.Yaw)])
                results=p.Results;
                props=fieldnames(results);
                props_obj=fieldnames(obj);
                
                for i=1:length(props)
                    if isprop(obj,props{i})
                        if size(results.(props{i}),2)==1
                            obj.(props{i})=results.(props{i});
                        else
                            obj.(props{i})=results.(props{i})';
                        end
                    end
                end
                
                [~,idx_sort]=sort(obj.Time);
                
                for i=1:length(props_obj)
                    if ~isempty(obj.(props_obj{i}))
                        obj.(props_obj{i})=obj.(props_obj{i})(idx_sort);
                    else
                        obj.(props_obj{i})=nan(size(obj.Time));
                    end
                end
                
            else
                nb_pings=length(p.Results.Time);
                obj.Heading=nan(nb_pings,1);
                obj.Roll=zeros(nb_pings,1);
                obj.Pitch=zeros(nb_pings,1);
                obj.Heave=zeros(nb_pings,1);
                obj.Yaw=zeros(nb_pings,1);
                obj.Time=p.Results.Time;
                %obj.SOG=zeros(nb_pings,1);
                
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