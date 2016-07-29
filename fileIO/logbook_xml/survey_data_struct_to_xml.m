function survey_data_struct_to_xml(path_f,surv_data_struct)

dir_raw=dir(fullfile(path_f,'*.raw'));
list_raw={dir_raw(:).name};
nb_files=length(list_raw);

xml_file=fullfile(path_f,'echo_logbook.xml');
try
    docNode = com.mathworks.xml.XMLUtils.createDocument('echo_logbook');
    echo_logbook=docNode.getDocumentElement;
    echo_logbook.setAttribute('version','0.1');
    survey_node = docNode.createElement('survey');
    echo_logbook.appendChild(survey_node);
    survdata_temp=survey_data_cl();
    for i=1:nb_files
        file_curr=deblank(list_raw{i});
        idx_file_xml=find(strcmpi(file_curr,surv_data_struct.Filename));
        
            if ~isempty(idx_file_xml)
                for is=idx_file_xml
                    survdata_temp=surv_data_struct.SurvDataObj{is};
                    start_time=survdata_temp.StartTime;
                    end_time=survdata_temp.EndTime;
                    
                    if isnan(start_time)||(start_time==0)
                        start_time=get_start_date_from_raw(fullfile(path_f,list_raw{i}));
                    end
                    
                    if isnan(end_time)||(end_time==1)
                        [~,end_time]=start_end_time_from_file(fullfile(path_f,list_raw{i}));
                    end
                    
                    lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw{i},'StartTime',start_time,'EndTime',end_time);
                    survey_node.appendChild(lineNode);
                end
            else
                [start_time,end_time]=start_end_time_from_file(fullfile(path_f,list_raw{i}));
                
                lineNode=survdata_temp.surv_data_to_logbook_xml(docNode,list_raw{i},'StartTime',start_time,'EndTime',end_time);
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

