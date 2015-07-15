
function  open_EK60_file(hObject,PathToFile,Filename,read_all)
curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');

multi_layers=0;

if ~isequal(Filename, 0)      
    if read_all==0&&multi_layers==1
        prompt={'First ping:',...
            'Last Ping:'};
        name='Pings to load';
        numlines=1;
        defaultanswer={'1','Inf'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        
        if isempty(answer)
            return
        end

        ping_start= str2double(answer{1});
        ping_end= str2double(answer{2});
    else
        ping_start=1;
        ping_end=Inf;
    end
    
%     profile on;
    layers_temp=open_EK60_file_stdalone(hObject,PathToFile,Filename,[],ping_start,ping_end);
%     profile off;
%     profile viewer
%     
    [layers,layer]=shuffle_layers(layers,layers_temp);
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    curr_disp.Freq=layer.Frequencies(idx_freq);
    
    idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
    curr_disp.Fieldname=layer.Transceivers(idx_freq).Data.SubData(idx_field).Fieldname;
    
    setappdata(hObject,'Layer',layer);
    setappdata(hObject,'Layers',layers);
    setappdata(hObject,'Curr_disp',curr_disp);
    if exist('opening_file','var')
        close(opening_file);
    end
    
    update_display(hObject,1);
    
end