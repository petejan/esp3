function export_bot_as_evl_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

if isempty(layer)
    return;
end

path=layer.PathToFile;


if ~isempty(layer.get_survey_data())
    file=layer.get_survey_data().print_survey_data();
else
    if length(layer.Filename)>1
        file=[layer.Filename{1} '_' layer.Filename{end}];
    else
        file=layer.Filename{1};
    end
    file=regexprep(file,'.raw','');
end

[Filename,PathToFile]= uiputfile({fullfile(path,[file '.evl'])}, 'Name an .evl');
if isempty(Filename)
    return;
end
evl_str=layer.Transceivers(idx_freq).bottom_to_evl_str;

fid=fopen(fullfile(PathToFile,Filename),'w+');

if fid==-1
    return;
end

fwrite(fid,evl_str);

fclose(fid);


end