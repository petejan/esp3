function initialize_echo_logbook_file(datapath)
disp('Creating .xml logbook file, this might take a couple minutes...');

dir_raw=dir(fullfile(datapath,'*.raw'));
list_raw={dir_raw(:).name};
nb_files=length(list_raw);


xml_file=fullfile(datapath,'echo_logbook.xml');
if exist(xml_file,'file')==2
    return;
end


docNode = com.mathworks.xml.XMLUtils.createDocument('echo_logbook');
echo_logbook=docNode.getDocumentElement;
echo_logbook.setAttribute('version','0.1');
surv_init=survey_data_cl();
survey_node = docNode.createElement('survey');
survey_node.setAttribute('SurveyName',surv_init.SurveyName);
survey_node.setAttribute('Voyage',surv_init.Voyage);
echo_logbook.appendChild(survey_node);

for i=1:nb_files
    fprintf('Getting Start and End Date from file %s (%i/%i)\n',list_raw{i},i,nb_files);
    [start_date,end_date]=start_end_time_from_file(fullfile(datapath,list_raw{i}));    
    lineNode=surv_init.surv_data_to_logbook_xml(docNode,list_raw{i},'StartTime',start_date,'EndTime',end_date);
    survey_node.appendChild(lineNode);
end

xmlwrite(xml_file,docNode);

% xsl_file=fullfile(whereisEcho,'echo_logbook.xsl');
% copyfile(xsl_file,fullfile(datapath,'echo_logbook.xsl'));



end