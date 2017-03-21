%% list_tags_only_regions_xml.m
%
% List tags contained in a region XML file
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |reg_xml_file|: Full path to region XML file.
%
% *OUTPUT VARIABLES*
%
% * |tags|: Cell containing tags for each regions.
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-16: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function tags = list_tags_only_regions_xml(reg_xml_file)


fileID=fopen(reg_xml_file,'r');
txt=fread(fileID,'*char');
fclose(fileID);
tags=regexp(txt','Tag="([^\s]+)"','tokens');
tags=unique([tags{:}]);