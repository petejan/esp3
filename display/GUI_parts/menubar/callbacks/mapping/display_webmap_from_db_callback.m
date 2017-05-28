%% display_webmap_from_db_callback.m
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
% * |main_figure|: Handle to main ESP3 window
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
% * 2017-05-27: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function display_webmap_from_db_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

[gps_data,files]=layer.get_gps_data_from_db();

wmap=webmap('Ocean Basemap');
LatLim=[nan;nan];
LongLim=[nan;nan];

for i=1:length(gps_data)
    LatLim(1)=nanmin(LatLim(1),nanmin(gps_data(i).Lat));
    LatLim(2)=nanmax(LatLim(2),nanmax(gps_data(i).Lat));
    LongLim(1)=nanmin(LongLim(1),nanmin(gps_data(i).Long));
    LongLim(2)=nanmax(LongLim(2),nanmax(gps_data(i).Long));
    wmline(wmap,gps_data(i).Lat,gps_data(i).Long);
end
wmlimits(wmap,LatLim,LongLim);

end