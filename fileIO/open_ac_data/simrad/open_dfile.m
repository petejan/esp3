function  new_layers=open_dfile(Filename_cell,varargin)
p = inputParser;

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

if isempty(Filename_cell)
    new_layers=[];
    return;
end


[def_path_m,~,~]=fileparts(Filename_cell{1});

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'CVScheck',1,@isnumeric);
addParameter(p,'CVSroot','',@ischar);
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'EsOffset',[]);
addParameter(p,'load_bar_comp',[]);


parse(p,Filename_cell,varargin{:});


new_layers=[];

for uu=1:length(Filename_cell)
    
    
    FileName=Filename_cell{uu};
    [path_f,~,~]=fileparts(FileName);
    ifileInfo = parse_ifile(FileName);
    RawFilename=ifileInfo.rawFileName;
    
    if strcmp(RawFilename,'')
        warning('Could not find associated .*raw file');
        new_layers=[];
        return;
    end
    
    survey_data=survey_data_cl('Snapshot',ifileInfo.snapshot,'Stratum',ifileInfo.stratum,'Transect',ifileInfo.transect);
    origin=FileName;
    
    [~,PathToRawFile]=find_file_recursive(path_f,RawFilename);
    
    if isempty(PathToRawFile)
        warning('Could not find associated .*raw file');
        return;
    end
    
    lay_temp=open_EK_file_stdalone(fullfile(PathToRawFile{1},RawFilename),...
        'PathToMemmap',p.Results.PathToMemmap,'load_bar_comp',p.Results.load_bar_comp,'EsOffset',p.Results.EsOffset);
    lay_temp.OriginCrest=origin;
    
    lay_temp.set_survey_data(survey_data);
    
    if p.Results.CVScheck>0
        lay_temp.CVS_BottomRegions(p.Results.CVSroot)
    end
    new_layers=[new_layers lay_temp];
end



