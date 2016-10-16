function new_layers=open_raw_file_standalone_v2(Filename_cell,varargin)
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
addParameter(p,'LoadEKbot',0);
addParameter(p,'load_bar_comp',[]);

parse(p,Filename_cell,varargin{:});


new_layers=open_EK_file_stdalone(Filename_cell,...
    'PathToMemmap',p.Results.PathToMemmap,'Frequencies',p.Results.Frequencies,...
    'PingRange',p.Results.PingRange,'SampleRange',p.Results.SampleRange,'EsOffset',p.Results.EsOffset,...
    'FieldNames',p.Results.FieldNames,'GPSOnly',p.Results.GPSOnly,'LoadEKbot',p.Results.LoadEKbot,...
    'load_bar_comp',p.Results.load_bar_comp);



end