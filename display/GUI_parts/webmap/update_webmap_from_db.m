%% update_webmap_from_db.m
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
function update_webmap_from_db(main_figure,force_open)


wmap=getappdata(main_figure,'Wmap');

if isempty(wmap)||~isvalid(wmap.map)
    if force_open>0
    wmap.map=webmap('Ocean Basemap');
    wmap.lines=[];
    wmap.curr_pos=[];
    wmap.files={};
    LatLim=[nan;nan];
    LongLim=[nan;nan];
    else
        return;
    end
else
    [LatLim,LongLim] = wmlimits(wmap.map);
end

layers=getappdata(main_figure,'Layers');

if isempty(layers)
    return;
end

new_file_list={};
old_file_list=wmap.files;
path_done={};
for ilay=1:length(layers)    
    path_new=layers(ilay).get_path_files();    
    if isempty(setdiff(path_new,path_done))
        continue;
    end
    path_done=union(path_done,path_new);
    [gps_data,files]=layers(ilay).get_gps_data_from_db();
    new_file_list=union(files,new_file_list);
    [~,idx_new_files] = setdiff(files,old_file_list,'legacy');
    for i=1:length(idx_new_files)
        LatLim(1)=nanmin(LatLim(1),nanmin(gps_data(idx_new_files(i)).Lat));
        LatLim(2)=nanmax(LatLim(2),nanmax(gps_data(idx_new_files(i)).Lat));
        LongLim(1)=nanmin(LongLim(1),nanmin(gps_data(idx_new_files(i)).Long));
        LongLim(2)=nanmax(LongLim(2),nanmax(gps_data(idx_new_files(i)).Long));
        line_tmp=wmline(wmap.map,gps_data(i).Lat,gps_data(i).Long,'autofit',0,'FeatureName', files{idx_new_files(i)});
        wmap.lines=[wmap.lines line_tmp];
        wmap.files=union(wmap.files,files{idx_new_files(i)});
    end   
end

[~,idx_to_remove]=setdiff(wmap.files,new_file_list);
if ~isempty(idx_to_remove)
    wmremove(wmap.lines(idx_to_remove));
    wmap.lines(idx_to_remove)=[];
    wmap.files(idx_to_remove)=[];
end


wmlimits(wmap.map,LatLim,LongLim);

setappdata(main_figure,'Wmap',wmap);

end