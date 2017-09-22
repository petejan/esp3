function write_config_algo_to_xml(algos,name_cell,rem)

[~,unique_algo_idx,rep_algo_idx]=unique({algos(:).Name});

for ial=1:numel(unique_algo_idx)
    
    [~,~,file_xml]=get_config_files(algos(unique_algo_idx(ial)).Name);
    
    if exist(file_xml{1},'file')==2
        [~,algo_alt,name_cell_alt]=read_config_algo_xml(file_xml{1});
    else
        algo_alt=[];
        name_cell_alt={};
    end
    
    docNode = com.mathworks.xml.XMLUtils.createDocument('config_file');
    
    config_file=docNode.getDocumentElement;
    config_file.setAttribute('version','0.2');
    
    algo_node = docNode.createElement('algos');
    
    idx_algos=find(rep_algo_idx==ial);
    
    for ial2=1:length(idx_algos)             
        idx_exist=strcmpi(name_cell{ial2},name_cell_alt);
        algo_alt(idx_exist)=[];
        name_cell_alt(idx_exist)=[];
        if rem==0||strcmpi('--',name_cell{ial2})
            algocurr_node=add_algo_node(docNode,algos(ial2),name_cell{ial2});
            algo_node.appendChild(algocurr_node);
        end
    end
    
    for ial3=1:length(algo_alt)
        algocurr_node=add_algo_node(docNode,algo_alt(ial3),name_cell_alt{ial3});
        algo_node.appendChild(algocurr_node);
    end
    
    config_file.appendChild(algo_node);
    
end

xmlwrite(file_xml{1},docNode);

type(file_xml{1});

end

function algocurr_node=add_algo_node(docNode,algocurr,name)
algocurr_node = docNode.createElement(algocurr.Name);
algocurr_node.setAttribute('savename',name);
f_algo=fieldnames(algocurr.Varargin);
for ivar=1:length(f_algo)
    if ~ismember(f_algo{ivar},{'reg_obj'})
        algocurr_node.setAttribute(f_algo{ivar},num2str(algocurr.Varargin.(f_algo{ivar}),'%f'));
    end
end
end