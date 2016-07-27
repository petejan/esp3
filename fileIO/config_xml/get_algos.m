function algo_cell=get_algos(algo_node)
nb_algos=length(algo_node.Children);
algo_cell=cell(1,nb_algos);
for i=1:nb_algos
    if strcmp(algo_node.Children(i).Name,'#comment')
        continue;
    end
    algo_cell{i}.Name=algo_node.Children(i).Name;
    for j=1:length(algo_node.Children(i).Attributes)
        algo_cell{i}.Varargin.(algo_node.Children(i).Attributes(j).Name)=algo_node.Children(i).Attributes(j).Value;
    end
    
    if isfield(algo_cell{i}.Varargin,'Frequencies')
        if ischar(algo_cell{i}.Varargin.Frequencies)
            algo_cell{i}.Varargin.Frequencies=str2double(strsplit(algo_cell{i}.Varargin.Frequencies,';'));
            if isnan(algo_cell{i}.Varargin.Frequencies)
                algo_cell{i}.Varargin.Frequencies=[];
            end
        end
    else
        algo_cell{i}.Varargin.Frequencies=[];
    end
end
algo_cell(cellfun(@isempty,algo_cell))=[];
end