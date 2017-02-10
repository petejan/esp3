function load_offset_line_cback(~,~,main_figure) 

layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find(layer.Frequencies==curr_disp.Freq);
if ~isempty(layer)
    if ~isempty(layer.Filename)
        [path_f,~,~]=fileparts(layer.Filename{1});
    else
        path_f=pwd;
    end
    
else
    return;
end

[Filename,path_line]= uigetfile({fullfile(path_f,'*.evl;*.dat;*.txt;*.mat;*converted.cnv')}, 'Pick a line file','MultiSelect','off');
if Filename==0
    return;
end

line_offset=import_line(path_line,Filename);
layer.Transceivers(idx_freq).OffsetLine=line_offset;

display_offset_echogram(main_figure,line_offset);
end