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


layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');



if ~ismember(curr_disp.CursorMode,{'Normal','Create Region','Zoom In','Zoom Out'})
     return;
end

[ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_disp.Cmap);

[~,ah,~,trans_ax,~,~]=get_axis_from_cids(main_figure,union({'main' 'mini'},layer.ChannelID));

for i=1:length(ah)
    reg_text=findobj(ah(i),'Tag','region_text');
    set(reg_text,'color',txt_col);
    trans_obj=trans_ax{i};
    if isempty(trans_obj)
        continue;
    end
    for ireg=1:numel(trans_obj.Regions)
        
        if ismember(trans_obj.Regions(ireg).Unique_ID,Unique_ID) 
            
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
        reg_patch_ac=findobj(ah(i),{'Tag','region','-or','Tag','region_cont'},...
            '-and','UserData',trans_obj.Regions(ireg).Unique_ID,'-and','Type','Patch','-not','FaceColor',col);
        set(reg_patch_ac,'FaceColor',col,'EdgeColor','none');
    end 
end

setappdata(main_figure,'Layer',layer);

     
end








