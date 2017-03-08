function  open_dfile(main_figure,Filename_cell,CVScheck)
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');



if ~isequal(Filename_cell, 0)
    
    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end
    
    
    for uu=1:length(Filename_cell)

        
        FileName=Filename_cell{uu};
        [path_f,~,~]=fileparts(FileName);
        ifileInfo = parse_ifile(FileName);
        RawFilename=ifileInfo.rawFileName;
        
        if strcmp(RawFilename,'')
           warning('Could not find associated .*raw file');
           open_dfile_crest(main_figure,Filename,CVSCheck); 
           return;
        end
        
        survey_data=survey_data_cl('Snapshot',ifileInfo.snapshot,'Stratum',ifileInfo.stratum,'Transect',ifileInfo.transect);
        origin=FileName;
        
        [~,PathToRawFile]=find_file_recursive(path_f,RawFilename);
        
        if isempty(PathToRawFile)
            warning('Could not find associated .*raw file');
            return;
        end
        
        if exist(fullfile(PathToRawFile{end},'cal_echo.csv'),'file')>0
            cal=csv2struct_perso(fullfile(PathToRawFile{end},'cal_echo.csv'));
        else
            cal=[];
        end
        
        layer_temp(uu)=open_EK_file_stdalone(fullfile(PathToRawFile{1},RawFilename),...
            'PathToMemmap',app_path.data_temp,'Frequencies',[],'Calibration',cal);
        layer_temp(uu).OriginCrest=origin;
        
        layer_temp(uu).set_survey_data(survey_data);

        if CVScheck>0
            layer_temp(uu).CVS_BottomRegions(app_path.cvs_root)
        end
    end
    
    layer=layer_temp(end);
    layers=[layer_temp,layers];
    setappdata(main_figure,'Layer',layer);
    setappdata(main_figure,'Layers',layers);
    
end