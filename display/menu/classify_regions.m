function classify_regions(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_38=find_freq_idx(layer,38000);
idx_18=find_freq_idx(layer,18000);
idx_120=find_freq_idx(layer,120000);

idx_to_process=[idx_18 idx_38 idx_120];

idx_school_38 = layer.Transceivers(idx_38).list_regions_name('School');
if ~isempty(idx_school_38)
    choice = questdlg('Do you want to reprocess schools using Gauthier/Oeffner parameters?', ...
        'Reprocess',...
        'Yes','No', ...
        'No');
    % Handle response
    switch choice
        case 'Yes'
            reprocess=1;
        case 'No'
            reprocess=0;
    end
else
    reprocess=1;
end


for i=1:length(layer.Transceivers)
    if i==idx_38
        continue;
    end
    layer.Transceivers(i).rm_region('School');
    for ii=1:length(idx_school_38)
        layer.Transceivers(i).rm_region_id(layer.Transceivers(idx_38).Regions(idx_school_38(ii)).Unique_ID)
    end
end

layer.prepare_classification(idx_to_process,reprocess);
idx_school_38 = layer.Transceivers(idx_38).list_regions_name('School');

for ii=1:length(idx_school_38)
    layer.apply_classification(idx_38,idx_school_38(ii));
end

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Curr_disp',curr_disp);
update_display(main_figure,0);
end