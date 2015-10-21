function classify_regions_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
hfigs=getappdata(main_figure,'ExternalFigures');

[idx_38,found_38]=find_freq_idx(layer,38000);
[idx_18,found_18]=find_freq_idx(layer,18000);
[idx_120,found_120]=find_freq_idx(layer,120000);

if ~found_18||~found_120||~found_38
    warning('Cannot find every frequency!Pass...');
    return;
end


idx_to_process=[idx_18 idx_38 idx_120];

idx_school_38 = layer.Transceivers(idx_38).list_regions_name('School');

if ~isempty(idx_school_38)
         choice = questdlg('Do you want to detect schools using Gauthier/Oeffner parameters (1) your own (2), or those already detected (3)?', ...
        'Parameters',...
        '(1)','(2)','(3)', ...
        '(1)');
    % Handle response
    switch choice
        case '(1)'
            own=0;
            reprocess=1;
        case '(2)'
            own=1;
            reprocess=1;
        case '(3)'
            own=1;
            reprocess=0;
            
    end
else
     choice = questdlg('Do you want to detect schools using Gauthier/Oeffner parameters (1) or your own (2)', ...
        'Parameters',...
        '(1)','(2)', ...
        '(1)');
    % Handle response
    switch choice
        case '(1)'
            own=0;    
        case '(2)'
            own=1;
    end
    reprocess=1;
end


for i=1:length(layer.Transceivers)
    if i==idx_38
        continue;
    end
    layer.Transceivers(i).rm_region_name('School');
    for ii=1:length(idx_school_38)
        layer.Transceivers(i).rm_region_id(layer.Transceivers(idx_38).Regions(idx_school_38(ii)).Unique_ID)
    end
end

layer.prepare_classification(idx_to_process,reprocess,own);
idx_school_38 = layer.Transceivers(idx_38).list_regions_name('School');

if isempty(idx_school_38)
    warning('Cannot find 38 kHz Schools...Pass...');
    setappdata(main_figure,'Layer',layer);
    return;
end
    
id_to_remove=[];
for ii=1:length(idx_school_38)
    if length(layer.Transceivers(idx_38).Regions(idx_school_38(ii)).Output.Sv_mean(:))<50
        id_to_remove=[id_to_remove layer.Transceivers(idx_38).Regions(idx_school_38(ii)).Unique_ID];
    end
end

for uuu=id_to_remove
    layer.Transceivers(idx_38).rm_region_id(uuu);
end

idx_school_38 = layer.Transceivers(idx_38).list_regions_name('School');
for ii=1:length(idx_school_38)
    new_fig=layer.apply_classification(idx_38,idx_school_38(ii));
end

hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Curr_disp',curr_disp);
update_display(main_figure,0);
end