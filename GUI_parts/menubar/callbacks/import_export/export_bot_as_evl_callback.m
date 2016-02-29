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


if ~isempty(layer.get_survey_data())
    file=layer.get_survey_data().print_survey_data();
else
    if length(layer.Filename)>1
        [path_f,f_1,~]=fileparts(layer.Filename{1});
        [~,f_2,~]=fileparts(layer.Filename{end});
        file=fullfile(path_f,[f_1 '_' f_2]);
    else
        file=layer.Filename{1};
    end
    file=regexprep(file,'.raw','');
end

[Filename,PathToFile]= uiputfile([file '.evl'], 'Name an .evl');
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