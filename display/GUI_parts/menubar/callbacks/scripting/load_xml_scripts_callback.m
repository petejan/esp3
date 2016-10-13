function load_xml_scripts_callback(~,~,hObject)


app_path=getappdata(hObject,'App_path');

[xml_surveys_input,xml_files]=get_xml_scripts(app_path.scripts);

if isempty(xml_surveys_input)
    return;
end

for i=1:length(xml_files)  
    xmlSummary{i,1}=xml_surveys_input{i}.Infos.Title;
    xmlSummary{i,2}=xml_surveys_input{i}.Infos.Main_species;
    xmlSummary{i,3}=xml_surveys_input{i}.Infos.SurveyName;
    xmlSummary{i,4}=xml_surveys_input{i}.Infos.Areas;
    xmlSummary{i,5}=xml_surveys_input{i}.Infos.Author;
    xmlSummary{i,6}=xml_files{i};
    xmlSummary{i,7}=xml_surveys_input{i}.Infos.Created;
end

load_scripts_fig(hObject,xmlSummary,'xml');

end


function [xml_surveys_input,xml_files]=get_xml_scripts(scripts)

xml_surveys_input={};
xml_files={};
Filenames=dir(fullfile(scripts,'*.xml'));

k=0;
for i=1:length(Filenames)
    try
        xml_surveys_input_tmp=parse_survey_xml(fullfile(scripts,Filenames(i).name));
    catch
        fprintf('Could not parse xml survey from file %s\n',Filenames(i).name);
        continue;
    end
    if isempty(xml_surveys_input_tmp)
        fprintf('Could not parse xml survey from file %s\n',Filenames(i).name);
        continue;
    end
    k=k+1;
    xml_surveys_input{k}=xml_surveys_input_tmp;
    xml_files{k}=Filenames(i).name;
end

end