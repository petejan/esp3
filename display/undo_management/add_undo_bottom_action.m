function add_undo_bottom_action(main_figure,trans_obj,old_bot,new_bot)

cmd.Name = sprintf('Bottom/Bad Transmit');
cmd.Function        = @bottom_undo_fcn;       % Redo action
cmd.Varargin        = {main_figure,trans_obj,new_bot};
cmd.InverseFunction = @bottom_undo_fcn;       % Undo action
cmd.InverseVarargin = {main_figure,trans_obj,old_bot};
uiundo(main_figure,'function',cmd);

end

