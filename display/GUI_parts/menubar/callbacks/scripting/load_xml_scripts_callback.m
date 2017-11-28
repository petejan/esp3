%% load_xml_scripts_callback.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |hObject|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel). 
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
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
[~,idx_sort]=sort([Filenames(:).datenum],'descend');

k=0;
for i=idx_sort
    try
        xml_surveys_input_tmp=parse_survey_xml(fullfile(scripts,Filenames(i).name),{'survey'});
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