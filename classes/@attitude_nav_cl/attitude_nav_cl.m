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
                        switch props_obj{i}
                            case 'Heading'
                                obj.Heading=nan(size(obj.Time));
                            otherwise
                                obj.(props_obj{i})=zeros(size(obj.Time));
                        end
                    end
                end
                
            else
                nb_pings=size(p.Results.Time);
                obj.Heading=-999*ones(nb_pings);
                obj.Roll=zeros(nb_pings);
                obj.Pitch=zeros(nb_pings);
                obj.Heave=zeros(nb_pings);
                obj.Yaw=zeros(nb_pings);
                obj.Time=p.Results.Time;
                %obj.SOG=zeros(nb_pings);
                
            end
            
        end
        
        function save_attitude_to_file(obj,fileN,idx_pings)
            
            if isempty(idx_pings)
                idx_pings=1:length(obj.Time);
            end
            
            struct_obj.Heading=obj.Heading(idx_pings);
            struct_obj.Roll=obj.Roll(idx_pings);
            struct_obj.Pitch=obj.Pitch(idx_pings);
            struct_obj.Heave=obj.Heave(idx_pings);
            struct_obj.Yaw=obj.Yaw(idx_pings);
            
            
            
            struct_obj.Time=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS'),(num2cell(obj.Time(idx_pings))),'UniformOutput',0);
            
            struct2csv(struct_obj,fileN);
            
        end
        
        
        function attitude_out=concatenate_AttitudeNavPing(attitude_1,attitude_2)
            
            if ~isempty(attitude_1)&&~isempty(attitude_2)
                
                heading=[attitude_1.Heading(:); attitude_2.Heading(:)];
                roll=[attitude_1.Roll(:); attitude_2.Roll(:)];
                heave=[attitude_1.Heave(:); attitude_2.Heave(:)];
                pitch=[attitude_1.Pitch(:); attitude_2.Pitch(:)];
                yaw=[attitude_1.Yaw(:); attitude_2.Yaw(:)];
                time=[attitude_1.Time(:); attitude_2.Time(:)];
                
                
                attitude_out=attitude_nav_cl('Heading',heading,...
                    'Roll',roll,...
                    'Heave',heave,...
                    'Pitch',pitch,...
                    'Yaw',yaw,...
                    'Time',time);
            else
                attitude_out=attitude_nav_cl.empty();
            end
            
        end
        
    end
    
    methods(Static)
        
        
        function obj=load_att_from_file(fileN)
            if ~iscell(fileN)
                fileN={fileN};
            end
            
            for ifi=1:length(fileN)
                fprintf('Importing attitude from file %s\n',fileN{ifi});
                try
                    temp=csv2struct(fileN{ifi});
                    fields = isfield(temp,{'Heading','Roll','Heave','Pitch','Yaw','Time'});
                    temp.Time=cellfun(@(x) strrep(x,'a.m.','AM'),temp.Time,'UniformOutput',0);
                    temp.Time=cellfun(@(x) strrep(x,'p.m.','PM'),temp.Time,'UniformOutput',0);
                    time_temp=cellfun(@(x) datenum(x,'dd/mm/yyyy HH:MM:SS AM'),temp.Time);
                    
                    if iscell(temp.Heading)
                        temp.Heading=nan(size(temp.Time));
                    end
                    
                    if all(fields)
                        obj_temp=attitude_nav_cl('Heave',temp.Heave,'Heading',temp.Heading,'Yaw',temp.Yaw,'Pitch',temp.Pitch,'Roll',temp.Roll,'Time',time_temp);
                    else
                        [pathf,filen,ext]=fileparts(fileN{ifi});
                        obj_temp=csv_to_attitude(pathf,[filen ext]);
                    end
                    
                catch
                    [pathf,filen,ext]=fileparts(fileN{ifi});
                    obj_temp=csv_to_attitude(pathf,[filen ext]);
                end
                fprintf('Attitude import finished\n');
                if ifi==1
                    obj=obj_temp;
                else
                    obj=concatenate_AttitudeNavPing(obj,obj_temp);
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