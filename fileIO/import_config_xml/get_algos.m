function algo_cell=get_algos(algo_node)
nb_algos=length(algo_node.Children);
algo_cell=cell(1,nb_algos);
for i=1:nb_algos
    algo_cell{i}.Name=algo_node.Children(i).Name;
    for j=1:length(algo_node.Children(i).Attributes)
        algo_cell{i}.Varargin.(algo_node.Children(i).Attributes(j).Name)=algo_node.Children(i).Attributes(j).Value;
    end
end
end