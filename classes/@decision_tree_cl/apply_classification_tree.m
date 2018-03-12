function tag=apply_classification_tree(tree_obj,school_struct)

tag='';
if(any(cellfun(@(x) ~any(strcmp(x,fields(school_struct))),tree_obj.Variables)))
    warning('All Variables not defined, cannot classify');
    return;
end
school=school_struct;
IDs_cond=tree_obj.get_condition_node();
IDs_class=tree_obj.get_class_node();
if ~isempty(IDs_cond)
    ID_goto=nanmin(IDs_cond);
end
classified=0;

while classified==0  
    node=tree_obj.get_node(ID_goto);    
    if any(ID_goto==IDs_cond)
        try
            output=eval(node.Condition);
        catch
            warning('Failed on evaluation of condition %s...',node.Condition);
            return;
        end
        if output>=1
            ID_goto=node.true_target;
        else
            ID_goto=node.false_target;
        end
    elseif any(ID_goto==IDs_class)
        tag=node.Class;
        classified=1;
    else
        warning('Cannot use this tree...');
        return;
    end
     
end