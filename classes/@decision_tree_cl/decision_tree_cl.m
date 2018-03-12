classdef decision_tree_cl
    properties
        Title='';
        Frequencies
        Variables
        Nodes
    end
    
    
    methods
        function obj = decision_tree_cl(XMLFileName)
            p = inputParser;
            addRequired(p,'XMLFileName',@ischar);
            
            parse(p,XMLFileName);
            
            if exist(XMLFileName,'file')>0
                [obj.Frequencies,obj.Variables,obj.Nodes,obj.Title]=parse_classification_xml(XMLFileName);
            else
                warning('Could not find Classification XML file') ;
                obj.Title='';
                obj.Frequencies=[];
                obj.Variables={};
                obj.Nodes={};
            end
        end
        
        
        function IDs=get_node_ids(obj)
            IDs=nan(1,length(obj.Nodes));
            for i=1:length(obj.Nodes)
                IDs(i)=obj.Nodes{i}.id;
            end
        end
        
        function IDs=get_condition_node(obj)
            IDs=[];
            for i=1:length(obj.Nodes)
                if isfield(obj.Nodes{i},'Condition')
                    IDs=[IDs obj.Nodes{i}.id];
                end
            end
        end
        
        function IDs=get_class_node(obj)
            IDs=[];
            for i=1:length(obj.Nodes)
                if isfield(obj.Nodes{i},'Class')
                    IDs=[IDs obj.Nodes{i}.id];
                end
            end
        end
        
        function node=get_node(obj,id)
            IDs=obj.get_node_ids();
            idx=find(IDs==id);
            
            if ~isempty(idx)
                node=obj.Nodes{idx};
            else
                node={};
            end
        end
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
        
        function vars=get_variables(obj)
            vars=obj.Variables;
        end
        
        function vars=get_frequencies(obj)
            vars=obj.Frequencies;
        end
        
    end
    
end