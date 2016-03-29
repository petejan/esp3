function export_regions(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);
if found==0
    return;
end

Transceiver=layer.Transceivers(idx_freq);
Regions=Transceiver.Regions;
if isempty(Regions)
    return;
end
output=[];


for ir=1:length(Regions)
    output=[output Regions(ir).integrate_region(Transceiver)];
end

Freq=layer.Frequencies(idx_freq);
Filename=layer.Filename{1};

file_outputs_def=[Filename(1:end-5) '_' num2str(Freq) '_outputs.csv'];

[file_outputs,path_out] = uiputfile('*_outputs.csv','Select Filename for saving output',file_outputs_def);

if ~isequal(file_outputs,0)&&~isequal(path_out,0)
    
    new_struct=regions_to_struct(Regions,output);  
    struct2csv(new_struct,fullfile(path_out,file_outputs));
    
end

end