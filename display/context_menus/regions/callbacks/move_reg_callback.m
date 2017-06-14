%% move_reg_callback.m
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
% * |obj|: TODO: write description and info on variable
% * |ID|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
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
% * 2017-05-24: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function move_reg_callback(obj,~,ID,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
reg_curr=trans_obj.get_region_from_Unique_ID(ID);

if ~ismember(curr_disp.CursorMode,{'Normal'})
    return;
end

if ~(isa(obj,'matlab.graphics.primitive.Patch')||isa(obj,'matlab.graphics.primitive.Image')) 
    %fprintf('Not moving this is %s\n',class(obj));
    return;
end

switch main_figure.SelectionType
    case 'normal'

        modifier = get(main_figure,'CurrentModifier');
        control = ismember({'alt'},modifier);
        
        if ~any(control)
            if~isdeployed()
                fprintf('Not Moving, did not see alt\n');
            end
            return;
        end
        curr_disp.UIupdate=0;
        switch obj.Type
            case 'patch'
                move_patch_select(obj,[],main_figure);
            case 'image'
                move_image_select(obj,[],main_figure);
        end
        
        waitfor(curr_disp,'UIupdate',1);
        
        r_min=nanmin(obj.YData);
        samples=trans_obj.get_transceiver_samples();
        [~,idx_r_min]=nanmin(abs(r_min-samples));
        
        idx_p_min=ceil(nanmin(obj.XData));
        
        if reg_curr.Idx_r(1)==idx_p_min&&reg_curr.Idx_r(1)==idx_r_min
           return; 
        end
        
        reg_curr.Idx_pings=reg_curr.Idx_pings-reg_curr.Idx_pings(1)+idx_p_min;
        reg_curr.Idx_r=reg_curr.Idx_r-reg_curr.Idx_r(1)+idx_r_min;
        
        layer.Transceivers(idx_freq).add_region(reg_curr);
        
        setappdata(main_figure,'Layer',layer);
       
        clear_regions(main_figure,reg_curr.Unique_ID);
        display_regions(main_figure,'both');
        order_stacks_fig(main_figure);
    case 'open'
        regCellInt=trans_obj.integrate_region_v2(reg_curr);
        
        if isempty(regCellInt)
            return;
        end
        
        hfig=display_region_stat_fig(main_figure,regCellInt);
        set(hfig,'Name',reg_curr.print());
        
        
end








