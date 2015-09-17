function CVS_BottomRegions(layer,varargin)


p = inputParser;


addRequired(p,'layer',@(obj) isa(obj,'layer_cl'));
addParameter(p,'BotCVS',1);
addParameter(p,'RegCVS',1);

parse(p,layer,varargin{:});

bot_cvs=p.Results.BotCVS;
reg_cvs=p.Results.RegCVS;


if strcmp(layer.Filetype,'CREST')
    PathToFile=layer.PathToFile;
    FileName=layer.Filename;
else
    [PathToFile,FileName]=fileparts(layer.OriginCrest);
end

if ~isempty(PathToFile)&&~isempty(FileName)
    
%     idx_str=strfind(PathToFile,':');
%     linuxFilePath=fullfile('/data/ac1/',PathToFile(idx_str(1)+1:end));
%     linuxFilePath=strrep(linuxFilePath, '\', '/');
    ifileInfo = get_ifile_info(PathToFile,str2double(FileName(2:end)));
    RawFilename=ifileInfo.rawFileName;
    if ~isempty(RawFilename)
        voyage=RawFilename(1:7);
    else
        idx_slash=strfind(PathToFile,'\');
        if length(idx_slash)>=2
        voyage=PathToFile(idx_slash(1)+1:idx_slash(2)-1);
        else
           warning('cannot find voyage name here...');
           return;
        end
    end
    
    if bot_cvs==1
    display(['converting bottom and bad pings for dfile ' FileName]);
    [IdxBad,bot,~]= get_bottom_from_esp2(PathToFile,FileName,voyage);
    end
    
    if reg_cvs==1
    display(['converting regions for dfile ' FileName]);
    regions = get_regions_from_esp2(PathToFile,FileName,voyage);
    end
 
    [idx_freq,found]=find_freq_idx(layer,38000);
    if found>0
        layer.Transceivers(idx_freq).setBottomIdxBad(bot,IdxBad);
        layer.Transceivers(idx_freq).Regions=[];
        layer.Transceivers(idx_freq).add_region(regions);
    end
end

end