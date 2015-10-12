
function  open_EK60_file(hObject,PathToFile,Filename,vec_freq,ping_start,ping_end,multi_layer,join,load_reg)
curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');

app_path=getappdata(hObject,'App_path');

if exist(fullfile(PathToFile,'cal_echo.csv'),'file')>0
    cal=csv2struct(fullfile(PathToFile,'cal_echo.csv'));
else
    cal=[];
end
sple_start=1;
sple_end=inf;

if multi_layer==-1
    prompt={'First Sample:',...
        'Last Sample:'};
    name='Nb_samples to load from each files';
    numlines=1;
    defaultanswer={'1','Inf'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    
    if isempty(answer)
        return;
    end
    sple_start= str2double(answer{1});
    sple_end= str2double(answer{2});
end


%     profile on;

layers_temp=open_EK60_file_stdalone(PathToFile,Filename,...
    'PathToMemmap',app_path.data,'Frequencies',vec_freq,'PingRange',[ping_start ping_end],'SampleRange',[sple_start sple_end],'Calibration',cal);
%     profile off;
%     profile viewer
if exist('opening_file','var')
    close(opening_file);
end

if isempty(layers_temp)
    return;
end

disp('Shuffling layers');
[layers,layer]=shuffle_layers(layers,layers_temp,'multi_layer',multi_layer,'join',join,'load_reg',load_reg);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);
curr_disp.setField('sv');

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);
setappdata(hObject,'Curr_disp',curr_disp);


end