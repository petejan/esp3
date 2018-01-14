
function set_active_reg(src,~,ID,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');

switch main_figure.SelectionType
    case 'alt'
        
        modifier = get(main_figure,'CurrentModifier');
        control = ismember({'control'},modifier);
        
        if any(control)
            if ~ismember(ID,curr_disp.Active_reg_ID)
                curr_disp.setActive_reg_ID(union(ID,curr_disp.Active_reg_ID));
            else
                curr_disp.setActive_reg_ID(setdiff(curr_disp.Active_reg_ID,{ID}));
            end
            
        end
        
    case 'normal'
        curr_disp.setActive_reg_ID(ID);
    otherwise
        return;
end
end
