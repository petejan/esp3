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

depthFactor = ifile_info.depth_factor;

if bot>0&&exist(fullfile(folder,bFileName),'file')>0
    
    sample_idx = load_bottom_file(fullfile(folder,bFileName));
    if isempty(sample_idx)
        bottom=bottom_cl(...
            'Origin','Esp2',...
            'Range',[],...
            'Sample_idx',[],'Tag',[]);
    end
    
    bottom = sample_idx/depthFactor;
    
    bad = load_bad_transmits(fullfile(folder,bFileName))';
    
    bottom=bottom_cl(...
        'Origin','Esp2',...
        'Range',bottom,...
        'Sample_idx',sample_idx,...
        'Tag',bad==0);
    
    layer.Transceivers(idx_freq).setBottom(bottom);
end


if reg>0&&exist(fullfile(folder,rFileName),'file')>0
    
layer.Transceivers(idx_freq).Regions=[];
layer.Transceivers(idx_freq).rm_region_origin('Esp2');

    regions = readEsp2regions(fullfile(folder,rFileName));
    if ~strcmpi(layer.Filetype,'CREST')
        for ii=1:length(regions)
            regions(ii).Idx_pings=regions(ii).Idx_pings+1;
            regions(ii).Idx_r=regions(ii).Idx_r+1;
        end
    end
    
    layer.Transceivers(idx_freq).add_region(regions,'Origin','Esp2');

end