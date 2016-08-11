function logbook_dispedit_callback(~,~,main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
hfigs(~isvalid(hfigs))=[];
idx_tag=find(strcmp({hfigs(:).Tag},'logbook'));
if ~isempty(idx_tag)
    figure(hfigs(idx_tag(1)))
else
    load_survey_data_fig(main_figure);
end
end