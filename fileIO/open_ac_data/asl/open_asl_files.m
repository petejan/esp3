function new_layers=open_asl_files(Filename,varargin)

p = inputParser;

if ~iscell(Filename)
    Filename={Filename};
end

if isempty(Filename)
    new_layers=[];
    return;
end

[def_path_m,~,~]=fileparts(Filename{1});

addRequired(p,'Filename',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'Frequencies',[],@isnumeric);
addParameter(p,'load_bar_comp',[]);

parse(p,Filename,varargin{:});


files_out={};
dates=[];

id = 1;
if ~iscell(Filename)
    [path_tmp,~,~]=fileparts(Filename);
    file_list=dir(fullfile(path_tmp,'*.*A'));
    for k=1:length(file_list)
        out=textscan(file_list(k).name,'%02f%02f%02f%02f.%02fA');
        dates=[dates datenum([out{1}+2000 out{2} out{3} out{4} zeros(size(out{1})) zeros(size(out{1}))])];
        files_out{id}=fullfile(file_list(k).folder, file_list(k).name);
        id=id+1;
    end
else
    [path_tmp,~,~]=cellfun(@fileparts,Filename,'UniformOutput',0);
    path_tmp=unique(path_tmp);
    for i=1:length(path_tmp)
        file_list=dir(fullfile(path_tmp{i},'*.*A'));
        for k=1:length(file_list)
            out=textscan(file_list(k).name,'%02f%02f%02f%02f.%02fA');
            dates=[dates datenum([out{1}+2000 out{2} out{3} out{4} zeros(size(out{1})) zeros(size(out{1}))])];
            files_out{id}=fullfile(file_list(k).folder, file_list(k).name);
            id=id+1;
        end
    end
end

idx_selected_cell=cellfun(@(x)  find(strcmp(x,files_out)),Filename,'UniformOutput',false);
idx_selected=[idx_selected_cell{:}];

dates_selected=floor(dates(idx_selected));

dates_to_load=unique(floor(dates));

[~,idx_to_load_selected]=intersect(dates_to_load,dates_selected);

dates_to_load_str=datestr(dates_to_load);

[idx_out,cancel]=listdlg('ListString',dates_to_load_str,'InitialValue',idx_to_load_selected,'Name','Choose dates to load');

if cancel==0
    return;
end

dates_selected=unique(floor(dates_to_load(idx_out)));
idx_to_open=[];

for id=1:length(dates_selected)
    idx_to_open=union(idx_to_open,find(floor(dates)==dates_selected(id)));
end

Filename_out=files_out(idx_to_open);
%dates_out=dates(idx_to_open);
[pathname,~]=fileparts(Filename_out{end});

try
    xmlfile = dir(fullfile(pathname,'*.xml'));
    xmlfilename = char(xmlfile(1).name);
    calParms = LoadAZFPxml(pathname,xmlfilename,[]);
catch
    
    [xmlfilename, pathname] = uigetfile({fullfile(pathname,'*.xml')}, 'Select instrument coefficients file');
    if xmlfilename==0
        calParms=[];
    else
        calParms = LoadAZFPxml(pathname,xmlfilename,[]);
    end
end


str_disp=sprintf('Openning %.0f day(s), that is %d files\n',length(idx_out),length(idx_to_open));

if ~isempty(p.Results.load_bar_comp)
    p.Results.load_bar_comp.status_bar.setText(str_disp);
else
    disp(str_disp)
end


new_layers=read_asl(Filename_out,...
    'PathToMemmap',p.Results.PathToMemmap,'calParms',calParms,'load_bar_comp',p.Results.load_bar_comp);


end