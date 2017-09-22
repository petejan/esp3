function [algo_def,algo_alt,names_cell]=read_config_algo_xml(xml_file)

xml_struct=parseXML(xml_file);
algo_node=get_childs(xml_struct,'algos');
Algos=get_algos(algo_node);
algo_alt(numel(Algos))=algo_cl();
names_cell=cell(1,numel(Algos));


for ial=1:length(algo_alt)
    algo_alt(ial)=algo_cl('Name',Algos{ial}.Name,'Varargin',Algos{ial}.Varargin);
    names_cell{ial}=Algos{ial}.Varargin.savename;
end

idx_def=strcmpi(names_cell,'--');
algo_def=algo_alt(idx_def);