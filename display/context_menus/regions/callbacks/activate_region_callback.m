%% activate_region_callback.m
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
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function activate_region_callback(Unique_ID,main_figure)

if isempty(Unique_ID)
    return;
end
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans_obj=trans_obj;
reg_curr=trans_obj.get_region_from_Unique_ID(Unique_ID);


if~isdeployed()
    fprintf('Activate region %.0f\n',reg_curr.ID);
end

if ~ismember(curr_disp.CursorMode,{'Normal','Create Region','Zoom In','Zoom Out'})
     return;
end

[ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_disp.Cmap);

axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_ax_comp=getappdata(main_figure,'Mini_axes');


ah=[axes_panel_comp.main_axes mini_ax_comp.mini_ax];


for i=1:length(ah)
    reg_text=findobj(ah(i),'Tag','region_text');
    set(reg_text,'color',txt_col);
    
    for ireg=1:numel(trans_obj.Regions)
        if trans_obj.Regions(ireg).Unique_ID==reg_curr.Unique_ID
           
            col=ac_data_col;
            switch trans_obj.Regions(ireg).Type
                case 'Data'
                    col=ac_data_col;
                case 'Bad Data'
                    col=ac_bad_data_col;
            end
        else
            switch trans_obj.Regions(ireg).Type
                case 'Data'
                    col=in_data_col;
                case 'Bad Data'
                    col=in_bad_data_col;
            end
        end
        reg_lines_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','line','-not','color',col);
        set(reg_lines_ac,'color',col);
        if ~isempty(reg_lines_ac)
            reg_image_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','Image','-not','color',col);
            
            if ~isempty(reg_image_ac)
                cdata=get(reg_image_ac,'CData');
                cdata(:,:,1)=col(1);
                cdata(:,:,2)=col(2);
                cdata(:,:,3)=col(3);
                set(reg_image_ac,'Cdata',cdata);
            end
        end
        reg_patch_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},'-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','Patch','-not','FaceColor',col);
        set(reg_patch_ac,'FaceColor',col,'EdgeColor',col);
    end 
end

setappdata(main_figure,'Layer',layer);

     
end








