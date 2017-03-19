function tags = list_tags_only_regions_xml(reg_xml_file)
% [copy_function_code_line_here_so_typical_call_to_function_shows_in_help]
%
% DESCRIPTION
%
% List tags contained in a region XML file
%
% USE
%
%
% PROCESSING SUMMARY
%
%
% INPUT VARIABLES
%
% -reg_xml_file: full path to region XML file
%
% OUTPUT VARIABLES
% -tags: cell containing tags for each regions
% RESEARCH NOTES

%
% NEW FEATURES
%
% 2017-03-16: first version.
%
% EXAMPLE
%
%
%%%
% Yoann Ladroit NIWA
%%%


fileID=fopen(reg_xml_file,'r');
txt=fread(fileID,'*char');
fclose(fileID);
tags=regexp(txt','Tag="([^\s]+)"','tokens');
tags=unique([tags{:}]);