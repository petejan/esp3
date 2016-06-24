function new_layers=open_raw_file_standalone(Filename_cell,varargin)
p = inputParser;

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

if isempty(Filename_cell)
    new_layers=[];
    return;
end

[def_path_m,~,~]=fileparts(Filename_cell{1});

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'Calibration',[]);
addParameter(p,'Frequencies',[]);
addParameter(p,'PingRange',[1 inf]);
addParameter(p,'SampleRange',[1 inf]);
addParameter(p,'FieldNames',{});
addParameter(p,'EsOffset',[]);
addParameter(p,'GPSOnly',0);

parse(p,Filename_cell,varargin{:});

ftype=cell(1,length(Filename_cell));

for i=1:length(Filename_cell)
    ftype{i}=get_ftype(Filename_cell{i});
end

idx_EK60=find(strcmpi(ftype,'EK60'));
idx_EK80=find(strcmpi(ftype,'EK80'));

new_layers_EK60=[];
new_layers_EK80=[];

if ~isempty(idx_EK60)
    new_layers_EK60=open_EK60_file_stdalone(Filename_cell(idx_EK60),...
        'PathToMemmap',p.Results.PathToMemmap,'Frequencies',p.Results.Frequencies,...
        'PingRange',p.Results.PingRange,'SampleRange',p.Results.SampleRange,'EsOffset',p.Results.EsOffset,'FieldNames',p.Results.FieldNames,'GPSOnly',p.Results.GPSOnly);
end

if ~isempty(idx_EK80)
    new_layers_EK80=open_EK80_file_stdalone(Filename_cell(idx_EK80),...
        'PathToMemmap',p.Results.PathToMemmap,'Frequencies',p.Results.Frequencies,'PingRange',p.Results.PingRange,'FieldNames',p.Results.FieldNames,'GPSOnly',p.Results.GPSOnly);
end

new_layers=[new_layers_EK60 new_layers_EK80];

end