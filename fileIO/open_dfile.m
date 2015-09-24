function  open_dfile(hObject,PathToFile,Filename_cell,CVScheck)
curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');


if ~isequal(Filename_cell, 0)
    
    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end
    
    
    for uu=1:length(Filename_cell)
        
        FileName=Filename_cell{uu};
        
        ifileInfo = get_ifile_info(PathToFile, str2double(FileName(2:end)));
        RawFilename=ifileInfo.rawFileName;
        
        origin=fullfile(PathToFile,FileName);
        
        [~,PathToRawFile]=find_file_recursive(PathToFile,RawFilename);
        
        if isempty(PathToRawFile)
            warning('Could not find associated .*raw file');
            return;
        end
        
        if exist(fullfile(PathToRawFile{1},'cal_echo.csv'),'file')>0
            cal=csv2struct(fullfile(PathToRawFile{1},'cal_echo.csv'));
        else
            cal=[];
        end
 
        layer_temp(uu)=open_EK60_file_stdalone(PathToRawFile{1},RawFilename,...
            'PathToMemmap',app_path.data,'Frequencies',[],'Calibration',cal);
        layer_temp(uu).OriginCrest=origin;
        
        if CVScheck>0
            layer_temp(uu).CVS_BottomRegions(app_path.cvs_root)
        end
    end
    
    disp('Shuffling layers');
    [layers,layer]=shuffle_layers(layers,layer_temp,1,0);
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    curr_disp.Freq=layer.Frequencies(idx_freq);
    curr_disp.setField('sv');
    
    setappdata(hObject,'Layer',layer);
    setappdata(hObject,'Layers',layers);
    setappdata(hObject,'Curr_disp',curr_disp);
    
end