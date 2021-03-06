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
function update_reglist_tab(main_figure,force_repop)

layer=getappdata(main_figure,'Layer');

reglist_tab_comp=getappdata(main_figure,'Reglist_tab');

if isempty(reglist_tab_comp)
    opt_panel=getappdata(main_figure,'option_tab_panel');
    load_reglist_tab(main_figure,opt_panel);
    return;
end

if isempty(layer)    
	reglist_tab_comp.table.Data(:)=[];
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

% try
%     jView = reglist_tab_comp.jScroll.getViewport();
%     curr_rect=jView.getViewRect();
% catch
%     if ~isdeployed()
%         disp('Error while updating reg_list_tab');
%     end
% end


if isempty(layer.GPSData.Lat)
    units_w= {'pings','seconds'};
else
    units_w= {'meters','pings','seconds'};
  
end
columnformat = {'char' 'numeric','char',{'Data','Bad Data'},{'Surface','Bottom'},'numeric',units_w,'numeric',{'meters','samples'},'numeric'};

set(reglist_tab_comp.cell_w_unit,'String',units_w);
reglist_tab_comp.table.ColumnFormat=columnformat;
if reglist_tab_comp.cell_w_unit.Value>numel(units_w)
    reglist_tab_comp.cell_w_unit.Value=1;
end

regions=trans_obj.Regions;

%{regions(:).Unique_ID}
if ~isempty(reglist_tab_comp.table.Data)&&~force_repop
    if isempty(regions)
        reglist_tab_comp.table.Data(:)=[];
        return;
    end
    [~,idx_reg_to_rem]=setdiff(reglist_tab_comp.table.Data(:,10),{regions(:).Unique_ID});
    
    if ~isempty(idx_reg_to_rem)
        reglist_tab_comp.table.Data(idx_reg_to_rem,:)=[];
    end
    
    [~,idx_reg_to_add]=setdiff({regions(:).Unique_ID},reglist_tab_comp.table.Data(:,10));
    
    if ~isempty(idx_reg_to_add)
        update_reg_data_table(regions(idx_reg_to_add),reglist_tab_comp.table);
    end
    
    if numel({regions(:).Tag})==numel(reglist_tab_comp.table.Data(:,3))
        idx_reg_to_update=find(~strcmpi({regions(:).Tag},reglist_tab_comp.table.Data(:,3)'));
        
        if ~isempty(idx_reg_to_update)
            update_reg_data_table(regions(idx_reg_to_update),reglist_tab_comp.table);
        end

    end
else
    reglist_tab_comp.table.Data(:)=[];
    update_reg_data_table(regions,reglist_tab_comp.table);    
end

if isempty(curr_disp.Active_reg_ID)
    return;
end

% idx_reg=find(strcmpi(curr_disp.Active_reg_ID,reglist_tab_comp.table.Data(:,10)));
%
% if isempty(idx_reg)
%     return;
% end

%reglist_tab_comp.table.Data{idx_reg,1}=strcat('<html><FONT color="Red"><b>',reglist_tab_comp.table.Data{idx_reg,1},'</b></html>');
% reglist_tab_comp.table.Data{idx_reg,3}=strcat('<html><FONT color="Red"><b>',reglist_tab_comp.table.Data{idx_reg,3},'</b></html>');

%
% try
%     drawnow;
%     nb_reg=length(regions);
%     rect=jView.getViewSize;
%     pos=java.awt.Point(0,round(rect.height*(idx_reg-1)/nb_reg));
%
%     old_pos=java.awt.Point(0,curr_rect.y);
%
%     if ~(pos.y>=curr_rect.y&&pos.y<=(curr_rect.y+curr_rect.height))||new
%         jView.setViewPosition(pos)
%         %fprintf('Moving to %.0f\n',pos.y);
%     else
%         jView.setViewPosition(old_pos)
%         %fprintf('Back to %.0f\n',old_pos.y);
%     end
%
%     reglist_tab_comp.jScroll.repaint();    % workaround for any visual glitches
%
% catch
%     if ~isdeployed()
%         disp('Error while updating reg_list_tab');
%     end
% end


end