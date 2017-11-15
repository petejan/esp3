%% update_reglist_tab.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
% * |reg_uniqueID|: TODO: write description and info on variable
% * |new|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function update_reglist_tab(main_figure,reg_uniqueID,new)

layer=getappdata(main_figure,'Layer');

reglist_tab_comp=getappdata(main_figure,'Reglist_tab');

if isempty(reglist_tab_comp)
    opt_panel=getappdata(main_figure,'option_tab_panel');
    load_reglist_tab(main_figure,opt_panel);
    return;
end

if isempty(layer)||isempty(reglist_tab_comp)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

try     
    jView = reglist_tab_comp.jScroll.getViewport();
    curr_rect=jView.getViewRect();    
catch
    if ~isdeployed()
        disp('Error while updating reg_list_tab');
    end
end

regions=trans_obj.Regions;
if ~isempty(reg_uniqueID)&&new==0
    if reg_uniqueID>=0
        region_mod=trans_obj.get_region_from_Unique_ID(reg_uniqueID);
        reg_table_data=update_reg_data_table(region_mod,reglist_tab_comp.table.Data);
        set(reglist_tab_comp.table,'Data',reg_table_data);
    else
        idx_mod=find(strcmpi(reglist_tab_comp.table.Data{:,10},reg_uniqueID));
        if ~isempty(idx_mod)
            reglist_tab_comp.table.Data(idx_mod,:)=[];
        end
    end
else
    region_mod=regions;
    reg_table_data=update_reg_data_table(region_mod,[]);
    set(reglist_tab_comp.table,'Data',reg_table_data);
end

if isempty(curr_disp.Active_reg_ID)
    return;
end

idx_reg=find(strcmpi(curr_disp.Active_reg_ID,reglist_tab_comp.table.Data(:,10)));

if isempty(idx_reg)
    return;
end

reglist_tab_comp.table.Data{idx_reg,1}=strcat('<html><FONT color="Red"><b>',reglist_tab_comp.table.Data{idx_reg,1},'</b></html>');
% reglist_tab_comp.table.Data{idx_reg,3}=strcat('<html><FONT color="Red"><b>',reglist_tab_comp.table.Data{idx_reg,3},'</b></html>');


try
    drawnow; 
    nb_reg=length(regions);
    rect=jView.getViewSize;
    pos=java.awt.Point(0,round(rect.height*(idx_reg-1)/nb_reg));
    
    old_pos=java.awt.Point(0,curr_rect.y);
    
    if ~(pos.y>=curr_rect.y&&pos.y<=(curr_rect.y+curr_rect.height))||new
        jView.setViewPosition(pos)
        %fprintf('Moving to %.0f\n',pos.y);
    else
        jView.setViewPosition(old_pos)
        %fprintf('Back to %.0f\n',old_pos.y);
    end
    
    reglist_tab_comp.jScroll.repaint();    % workaround for any visual glitches
    
catch
    if ~isdeployed()
        disp('Error while updating reg_list_tab');
    end
end


end