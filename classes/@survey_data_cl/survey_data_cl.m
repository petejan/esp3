classdef survey_data_cl < handle
    properties
        Voyage='';
        SurveyName='';
        Snapshot=0;
        Stratum='';
        Type='';
        Transect=0;
        Comment='';
        StartTime=0;
        EndTime=1;
    end
    
    
    methods
        function obj = survey_data_cl(varargin)
            p = inputParser;
            
            ver_fmt=@(x) ischar(x)||isnumeric(x);
            
            addParameter(p,'SurveyName','',ver_fmt);
            addParameter(p,'Snapshot',0,@isnumeric);
            addParameter(p,'Stratum','',ver_fmt);
            addParameter(p,'Type','',@ischar);
            addParameter(p,'Transect',0,@isnumeric);
            addParameter(p,'Comment',' ',ver_fmt);
            addParameter(p,'Voyage','',ver_fmt);
            addParameter(p,'StartTime',0,@isnumeric);
            addParameter(p,'EndTime',1,@isnumeric);
            parse(p,varargin{:});
            
            results=p.Results;
            
            obj.Voyage=results.Voyage;
            obj.SurveyName=results.SurveyName;
            obj.Snapshot=results.Snapshot;
            obj.Type=results.Type;
            obj.Stratum=results.Stratum;
            obj.Comment=results.Comment;
            obj.Transect=results.Transect;
            obj.StartTime=results.StartTime;
            obj.EndTime=results.EndTime;
    
        end
        
        function set.Voyage(obj,voy)
            if isnumeric(voy)
                obj.Voyage=num2str(voy);
            else
               obj.Voyage=voy; 
            end
        end
        
        function set.SurveyName(obj,s)
            if isnumeric(s)
                obj.SurveyName=num2str(s);
            else
                obj.SurveyName=s;
            end
        end
        
        function set.Snapshot(obj,s)
            if isnumeric(s)
               s_tmp=s;
            else
                s_tmp=str2double(s);
            end
            if ~isnan(s_tmp)&&~isempty(s_tmp)
                obj.Snapshot=s_tmp;
            end
        end
        
        function set.Transect(obj,s)
            if isnumeric(s)
                s_tmp=s;
            else
                s_tmp=str2double(s);
            end
            if ~isnan(s_tmp)&&~isempty(s_tmp)
                obj.Transect=s_tmp;
            end
        end
        
        function set.Stratum(obj,s)
            if isnumeric(s)
                obj.Stratum=num2str(s);
            else
                obj.Stratum=s;
            end
        end
        
        function set.Comment(obj,s)
            if isnumeric(s)
                obj.Comment=num2str(s);
            else
                obj.Comment=s;
            end
        end
        
        function set.Type(obj,t)
            if isnumeric(t)
                t_temp=num2str(t);
            else
                t_temp=t;
            end
            if ismember(t_temp,init_trans_type())
                obj.Type=t_temp;
            end   
        end
        
        function i_str=print_survey_data(obj)
            i_str=sprintf('%s Snap %d, %s, Strat. %s, Trans. %d',...
                obj.Voyage,obj.Snapshot,obj.Type,obj.Stratum,obj.Transect);
            if obj.Snapshot==0&&strcmp(obj.Type,'')&&strcmp(obj.Stratum,'')&&obj.Transect==0
                i_str='';
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