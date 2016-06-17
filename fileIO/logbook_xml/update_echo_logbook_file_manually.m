function update_echo_logbook_file_manually(file_full,survey_data)%one full file name and one survey data

[path_f,file_name,file_ext]=fileparts(file_full);
file_lay=[file_name file_ext];

surv_data_struct=load_logbook_to_struct(path_f);
list_raw=ls(fullfile(path_f,'*.raw'));
nb_files=size(list_raw,1);


xml_file=fullfile(path_f,'echo_logbook.xml');
try
    docNode = com.mathworks.xml.XMLUtils.createDocument('echo_logbook');
    echo_logbook=docNode.getDocumentElement;
    echo_logbook.setAttribute('version','0.1');
    survey_node = docNode.createElement('survey');
    echo_logbook.appendChild(survey_node);
    survdata_temp=survey_data_cl();
    for i=1:nb_files
        file_curr=deblank(list_raw(i,:));
        isfile=strcmpi(file_curr,file_lay);
        idx_file_cvs=find(strcmpi(file_curr,surv_data_struct.Filename));
        
        if isfile==0
            if ~isempty(idx_file_cvs)
                for is=idx_file_cvs
                    survdata_temp=surv_data_struct.SurvDataObj{is};
                    start_time=survdata_temp.StartTime;
                    end_time=survdata_temp.EndTime;
                    
                    if isnan(start_time)||(start_time==0)
                        start_time=get_start_date_from_raw(fullfile(path_f,list_raw(i,:)));
                    end
                    
                    if isnan(end_time)||(end_time==1)
                        [~,end_time]=start_end_time_from_file(fullfile(path_f,list_raw(i,:)));
                    end
                    
                    lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw(i,:),'StartTime',start_time,'EndTime',end_time);
                    survey_node.appendChild(lineNode);
                end
            else
                [start_time,end_time]=start_end_time_from_file(fullfile(path_f,list_raw(i,:)));
                
                lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw(i,:),'StartTime',start_time,'EndTime',end_time);
                survey_node.appendChild(lineNode);
            end
            
            
        else
            survdata_temp=survey_data;
            
            if isempty(survdata_temp)
                survdata_temp=survey_data_cl();
            end
            
            start_time=survdata_temp.StartTime;
            end_time=survdata_temp.EndTime;
            
            if isnan(start_time)||(start_time==0)
                start_time=get_start_date_from_raw(list_raw(i,:));
            end
            
            if isnan(end_time)||(end_time==1)
                [~,end_time]=start_end_time_from_file(fullfile(path_f,list_raw(i,:)));
            end
            
            lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw(i,:),'StartTime',start_time,'EndTime',end_time);
            survey_node.appendChild(lineNode);

        end
    end
    
    survey_node.setAttribute('SurveyName',survdata_temp.SurveyName);
    survey_node.setAttribute('Voyage',survdata_temp.Voyage);
    

    xmlwrite(xml_file,docNode);
    htmlfile=fullfile(path_f,'echo_logbook.html');
    xslt(xml_file, fullfile(whereisEcho,'echo_logbook.xsl'), htmlfile);

catch err
    disp(err.message);
    warning('Error when updating the logbook. Restoring previous version...') ;
   
end
end

