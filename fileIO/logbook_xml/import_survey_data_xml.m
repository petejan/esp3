function surv_data_struct=import_survey_data_xml(FileN)
surv_data_struct=[];


if exist(FileN,'file')==2

    xml_struct=parseXML(FileN);
    
    head_survey_data=get_node_att(xml_struct.Children);
    nb_lines=length(xml_struct.Children.Children);
    surv_data_struct=struct('Voyage',{cell(1,nb_lines)},'SurveyName',{cell(1,nb_lines)},...
        'Filename',{cell(1,nb_lines)},...
        'Snapshot',zeros(1,nb_lines),...
        'Stratum',{cell(1,nb_lines)},...
        'Transect',zeros(1,nb_lines),...
        'Comment',{cell(1,nb_lines)},...
        'StartTime',zeros(1,nb_lines),...
        'EndTime',ones(1,nb_lines),...
        'SurvDataObj',{cell(1,nb_lines)});
    
    for i=1:length(xml_struct.Children.Children)
        surv_data_struct.SurveyName{i}=head_survey_data.SurveyName;
        surv_data_struct.Voyage{i}=head_survey_data.Voyage;
        survey_data_xml=get_node_att(xml_struct.Children.Children(i));
        fi_tmp=fields(survey_data_xml);
        for ifi=1:length(fi_tmp)
            if iscell(surv_data_struct.(fi_tmp{ifi}))
                surv_data_struct.(fi_tmp{ifi}){i}=survey_data_xml.(fi_tmp{ifi});
                if isnumeric(surv_data_struct.(fi_tmp{ifi}){i})
                    surv_data_struct.(fi_tmp{ifi}){i}=num2str(surv_data_struct.(fi_tmp{ifi}){i});
                end
            else
                surv_data_struct.(fi_tmp{ifi})(i)=survey_data_xml.(fi_tmp{ifi});
            end
        end
    end
    

    if ~iscell(surv_data_struct.Voyage)
        idx_nan=isnan(surv_data_struct.Voyage);
        surv_data_struct.Voyage=replace_vec_per_cell(surv_data_struct.Voyage);
        surv_data_struct.Voyage(idx_nan)={''};
    end
    
    if ~iscell(surv_data_struct.SurveyName)
        idx_nan=isnan(surv_data_struct.SurveyName);
        surv_data_struct.SurveyName=replace_vec_per_cell(surv_data_struct.SurveyName);
        surv_data_struct.SurveyName(idx_nan)={''};
    end
    
    if ~iscell(surv_data_struct.Stratum)
        idx_nan=isnan(surv_data_struct.Stratum);
        surv_data_struct.Stratum=replace_vec_per_cell(surv_data_struct.Stratum);
        surv_data_struct.Stratum(idx_nan)={''};
    end
    
    
    if ~iscell(surv_data_struct.Comment)
        idx_nan=isnan(surv_data_struct.Comment);
        surv_data_struct.Comment=replace_vec_per_cell(surv_data_struct.Comment);
        surv_data_struct.Comment(idx_nan)={''};
    end
   surv_data_struct.Comment(cellfun(@isempty,surv_data_struct.Comment))={''};
   surv_data_struct.SurvDataObj=cell(1,length(surv_data_struct.Stratum));
   
    
    for i=1:length(surv_data_struct.Stratum)
                    if surv_data_struct.StartTime(i)==0
                        st=0;
                    else
                        st=datenum(num2str(surv_data_struct.StartTime(i)),'yyyymmddHHMMSS');
                    end
                    
                    if surv_data_struct.EndTime(i)==1
                        et=1;
                    else
                        et=datenum(num2str(surv_data_struct.EndTime(i)),'yyyymmddHHMMSS');
                    end

                    
                    surv_data_struct.SurvDataObj{i}=survey_data_cl(...
                        'Voyage',surv_data_struct.Voyage{i},...
                        'SurveyName',surv_data_struct.SurveyName{i},...
                        'Snapshot',surv_data_struct.Snapshot(i),...
                        'Stratum',surv_data_struct.Stratum{i},...
                        'Transect',surv_data_struct.Transect(i),...
                        'Comment',surv_data_struct.Comment{i},...
                        'StartTime',st,...
                        'EndTime',et);
        
    end
    
     [~,idx_struct]=sort(surv_data_struct.StartTime);
     field_struct=fieldnames(surv_data_struct);
     for ifi=1:length(field_struct)
         surv_data_struct.(field_struct{ifi})=surv_data_struct.(field_struct{ifi})(idx_struct);
     end
     
    
end
