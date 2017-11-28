function load_bottom_regions_from_folder(layer,folder,varargin)

p = inputParser;

addRequired(p,'layer',@(obj) isa(obj,'layer_cl'));
addRequired(p,'folder',@ischar);
addParameter(p,'Bot',1);
addParameter(p,'Reg',1);
addParameter(p,'Freq',38000);


parse(p,layer,folder,varargin{:});

bot=p.Results.Bot;
reg=p.Results.Reg;

if strcmp(layer.OriginCrest,'')
    return;
end

[dpath,dFileName,~]=fileparts(layer.OriginCrest);


num = dFileName((end-6):end);

iFileName = sprintf('i%07d', num);
rFileName = sprintf('r%07d', num);
bFileName = sprintf('b%07d', num);

ifile_info=parse_ifile(fullfile(dpath,iFileName));

if bot>0&&exist(fullfile(folder,bFileName),'file')>0
    
    sample_idx = load_bottom_file(fullfile(folder,bFileName));
    
   
    bad = load_bad_transmits(fullfile(folder,bFileName))';
    
    bottom=bottom_cl(...
        'Origin','Esp2',...
        'Sample_idx',sample_idx,...
        'Tag',double(bad==0));
    
    trans_obj.Bottom=bottom;
else
    
    fprintf('Could not find Bottom for file %s\n', dFileName);
end


if reg>0&&exist(fullfile(folder,rFileName),'file')>0
    
trans_obj.Regions=[];
trans_obj.rm_region_origin('Esp2');

    regions = readEsp2regions(fullfile(folder,rFileName));
    if ~strcmpi(layer.Filetype,'CREST')
        for ii=1:length(regions)
            regions(ii).Idx_pings=regions(ii).Idx_pings+1;
            regions(ii).Idx_r=regions(ii).Idx_r+1;
        end
    end
    
    trans_obj.add_region(regions,'Origin','Esp2');

else
    
    fprintf('Could not find regions for file %s\n', dFileName);
end