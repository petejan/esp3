function  open_dfile(hObject,PathToFile,Filename_cell,CVScheck,multi_layer)
layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');



if ~isequal(Filename_cell, 0)
    
    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end
    
    
    for uu=1:length(Filename_cell)
        if iscell(PathToFile)
            path=PathToFile{uu};
        else
            path=PathToFile;
        end
        
        FileName=Filename_cell{uu};
        
        ifileInfo = parse_ifile(path, str2double(FileName(2:end)));
        RawFilename=ifileInfo.rawFileName;
        survey_data=survey_data_cl('Snapshot',ifileInfo.snapshot,'Stratum',ifileInfo.stratum,'Transect',ifileInfo.transect);
        origin=fullfile(path,FileName);
        
        [~,PathToRawFile]=find_file_recursive(path,RawFilename);
        
        if isempty(PathToRawFile)
            warning('Could not find associated .*raw file');
            return;
        end
        
        if exist(fullfile(PathToRawFile{end},'cal_echo.csv'),'file')>0
            cal=csv2struct(fullfile(PathToRawFile{end},'cal_echo.csv'));
        else
            cal=[];
        end
        
        layer_temp(uu)=open_EK60_file_stdalone(PathToRawFile{1},RawFilename,...
            'PathToMemmap',app_path.data,'Frequencies',[],'Calibration',cal);
        layer_temp(uu).OriginCrest=origin;
        
        layer_temp(uu).set_survey_data(survey_data);

        if CVScheck>0
            layer_temp(uu).CVS_BottomRegions(app_path.cvs_root)
        end
    end
    
    layer=layer_temp(end);
    layers=[layer_temp,layers];
    setappdata(hObject,'Layer',layer);
    setappdata(hObject,'Layers',layers);
    
end