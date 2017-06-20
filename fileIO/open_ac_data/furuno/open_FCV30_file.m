function new_layers=open_FCV30_file(file_lst,varargin)

p = inputParser;

[def_path_m,~,~]=fileparts(file_lst);

addRequired(p,'file_lst',@(x) ischar(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'load_bar_comp',[]);

parse(p,file_lst,varargin{:});

list_files=importdata(file_lst);
filename_ini=cell(1,length(list_files));

for i=1:length(list_files)
    str_temp=strsplit(list_files{i},',');
    filename_ini{i}=str_temp{2};
end
filename_ini=unique(filename_ini);

[fidx,cancel]=listdlg('ListString',filename_ini,'InitialValue',1:length(filename_ini),'Name','Choose Files to open');

if cancel==0
    return;
end


new_layers=open_FCV30_file_stdalone(file_lst,...
    'PathToMemmap',p.Results.PathToMemmap,'load_bar_comp',p.Results.load_bar_comp,'file_idx',fidx);

