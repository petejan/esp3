function CVS_BottomRegions(layer,cvsroot,varargin)

p = inputParser;

addRequired(p,'layer',@(obj) isa(obj,'layer_cl'));
addRequired(p,'cvsroot',@ischar);
addParameter(p,'BotCVS',1);
addParameter(p,'RegCVS',1);
addParameter(p,'BotRev',[]);
addParameter(p,'RegRev',[]);
addParameter(p,'RegId',[]);


parse(p,layer,cvsroot,varargin{:});

bot_cvs=p.Results.BotCVS;
reg_cvs=p.Results.RegCVS;
bot_rev=p.Results.BotRev;
reg_rev=p.Results.RegRev;

reg_id=p.Results.RegId;

if strcmp(layer.Filetype,'CREST')
    PathToFile=layer.PathToFile;
    FileName=layer.Filename;
else
    [PathToFile,FileName]=fileparts(layer.OriginCrest);
end

if ~isempty(PathToFile)&&~isempty(FileName)
    


    idx_slash=union(strfind(PathToFile,'\'),strfind(PathToFile,'/'));
    if length(idx_slash)>=2
        voyage=PathToFile(idx_slash(1)+1:idx_slash(2)-1);
    else
        warning('cannot find voyage name here...');
        return;
    end

    [idx_freq,found]=find_freq_idx(layer,38000);
    if found>0
        
        if bot_cvs==1
            display(['converting bottom and bad pings for dfile ' FileName]);
            [IdxBad,bot,~]= get_bottom_from_esp2(PathToFile,FileName,voyage,cvsroot,bot_rev);  
              
            
            layer.Transceivers(idx_freq).setBottomIdxBad(bot,IdxBad); 
        end
              
        if reg_cvs==1
            display(['converting regions for dfile ' FileName]);
            regions = get_regions_from_esp2(PathToFile,FileName,voyage,cvsroot,reg_rev);
            
            if ~strcmp(layer.Filetype,'CREST')
                for ii=1:length(regions)
                    regions(ii).Idx_pings=regions(ii).Idx_pings+1;
                    regions(ii).Idx_r=regions(ii).Idx_r+1;
                end
            end
            
            layer.Transceivers(idx_freq).Regions=[];
            
            if~isempty(reg_id) 
                for iu=1:length(regions)
                   if nansum(regions(iu).ID==reg_id)>0
                       layer.Transceivers(idx_freq).add_region(regions(iu));
                   end
                end
            else
                layer.Transceivers(idx_freq).add_region(regions);
            end
        end
        
    end
end

end