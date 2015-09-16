function CVS_BottomRegions(layer)

if strcmp(layer.Filetype,'CREST')
    PathToFile=layer.PathToFile;
    FileName=layer.Filename;
else
    [PathToFile,FileName]=fileparts(layer.OriginCrest);
end

if ~isempty(PathToFile)&&~isempty(FileName)
    
    idx_str=strfind(PathToFile,':');
    linuxFilePath=fullfile('/data/ac1/',PathToFile(idx_str(1)+1:end));
    linuxFilePath=strrep(linuxFilePath, '\', '/');
    ifileInfo = get_ifile_info(PathToFile,str2double(FileName(2:end)));
    RawFilename=ifileInfo.rawFileName;
    voyage=RawFilename(1:7);
    display(['converting bottom and bad pings for dfile ' FileName]);
    [IdxBad,bot,~]= get_bottom_from_esp2(linuxFilePath,FileName,voyage);
 
    display(['converting regions for dfile ' FileName]);
    regions = get_regions_from_esp2(linuxFilePath,FileName,voyage);
 
    [idx_freq,found]=find_freq_idx(layer,38000);
    if found>0
        layer.Transceivers(idx_freq).setBottomIdxBad(bot,IdxBad);
        layer.Transceivers(idx_freq).Regions=[];
        layer.Transceivers(idx_freq).add_region(regions);
    end
end

end