function add_undo_region_action(main_figure,trans_obj,old_regs,new_regs)

    % Prepare an undo/redo action
    cmd.Name = sprintf('Region Modifications');
    cmd.Function        = @region_undo_fcn;       % Redo action
    cmd.Varargin        = {main_figure,trans_obj,new_regs};
    cmd.InverseFunction = @region_undo_fcn;       % Undo action
    cmd.InverseVarargin = {main_figure,trans_obj,old_regs};
    uiundo(main_figure,'function',cmd);

end
