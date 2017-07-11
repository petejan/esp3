%% keyboard_func.m
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
% * |src|: TODO: write description and info on variable
% * |callbackdata|: TODO: write description and info on variable
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
function keyboard_func(src,callbackdata,main_figure)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
%curr_disp=getappdata(main_figure,'Curr_disp');

% if ~any(strcmpi(curr_disp.CursorMode,{'Normal','Edit Bottom'}))
%     return;
% end
% profile on;

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
if ~isempty(layer)
    [idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
    trans=layer.Transceivers(idx_freq);
    number_lay=trans.get_transceiver_pings();
    samples=trans.get_transceiver_samples();
    
    xdata=number_lay;
    ydata=samples;
else
    layer=layer_cl();
    idx_freq=1;
    trans=transceiver_cl();
    xdata=[1 1];
    ydata=[1 1];
end

replace_interaction(src,'interaction','KeyPressFcn','id',1);
try
    switch callbackdata.Key
        
        case {'leftarrow','rightarrow','uparrow','downarrow','a','d'}
            
            axes_panel_comp=getappdata(main_figure,'Axes_panel');
            main_axes=axes_panel_comp.main_axes;
            
            if ~isfield(axes_panel_comp,'main_echo')
                
                return;
            end
            
            x_lim=double(get(main_axes,'xlim'));
            y_lim=double(get(main_axes,'ylim'));
            dx=(x_lim(2)-x_lim(1));
            dy=(y_lim(2)-y_lim(1));
            
            switch callbackdata.Key
                case {'leftarrow' 'a'}
                    if x_lim(1)>xdata(1)
                        x_lim=[nanmax(xdata(1),x_lim(1)-0.2*dx),nanmax(xdata(1),x_lim(1)-0.2*dx)+dx];
                        
                        set(main_axes,'xlim',x_lim);
                        set(main_axes,'ylim',y_lim);
                    end
                case {'rightarrow' 'd'}
                    if x_lim(2)<xdata(end)
                        x_lim=[nanmin(xdata(end),x_lim(2)+0.2*dx)-dx,nanmin(xdata(end),x_lim(2)+0.2*dx)];
                        set(main_axes,'xlim',x_lim);
                        set(main_axes,'ylim',y_lim);
                    end
                case 'downarrow'
                    if y_lim(2)<ydata(end)
                        y_lim=[nanmin(ydata(end),y_lim(2)+0.2*dy)-dy,nanmin(ydata(end),y_lim(2)+0.2*dy)];
                        set(main_axes,'ylim',y_lim);
                    end
                case 'uparrow'
                    if y_lim(1)>ydata(1)
                        y_lim=[nanmax(ydata(1),y_lim(1)-0.2*dy),nanmax(ydata(1),y_lim(1)-0.2*dy)+dy];
                        set(main_axes,'ylim',y_lim);
                    end
            end
        case {'0' 'numpad0'}
            curr_disp.CursorMode='Normal';
        case {'1' 'numpad1'}
            
            if isempty(callbackdata.Modifier)
                zi='zin';
            elseif strcmpi(callbackdata.Modifier,'shift')
                zi='zout';
            else
                return;
            end
            
            switch zi
                case 'zin'
                    
                    switch get(cursor_mode_tool_comp.zoom_in,'state');
                        case 'off'
                            set(cursor_mode_tool_comp.zoom_in,'state','on');
                            curr_disp.CursorMode='Zoom In';
                        case 'on'
                            set(cursor_mode_tool_comp.zoom_in,'state','off');
                            curr_disp.CursorMode='Normal';
                    end
                case 'zout'
                    switch get(cursor_mode_tool_comp.zoom_out,'state');
                        case 'off'
                            set(cursor_mode_tool_comp.zoom_out,'state','on');
                            curr_disp.CursorMode='Zoom Out';
                        case 'on'
                            set(cursor_mode_tool_comp.zoom_out,'state','off');
                            curr_disp.CursorMode='Normal';
                            
                    end
            end
        case {'2' 'numpad2'}
            
            switch get(cursor_mode_tool_comp.bad_trans,'state');
                case 'off'
                    set(cursor_mode_tool_comp.bad_trans,'state','on');
                    curr_disp.CursorMode='Bad Transmits';
                case 'on'
                    set(cursor_mode_tool_comp.bad_trans,'state','off');
                    curr_disp.CursorMode='Normal';
            end
        case {'3' 'numpad3'}
            
            switch get(cursor_mode_tool_comp.edit_bottom,'state');
                case 'off'
                    set(cursor_mode_tool_comp.edit_bottom,'state','on');
                    curr_disp.CursorMode='Edit Bottom';
                case 'on'
                    set(cursor_mode_tool_comp.edit_bottom,'state','off');
                    curr_disp.CursorMode='Normal';
            end
        case {'4' 'numpad4'}
            switch get(cursor_mode_tool_comp.create_reg,'state');
                case 'off'
                    set(cursor_mode_tool_comp.create_reg,'state','on');
                    curr_disp.CursorMode='Create Region';
                case 'on'
                    set(cursor_mode_tool_comp.create_reg,'state','off');
                    curr_disp.CursorMode='Normal';
            end
        case {'6' 'numpad6'}
            switch curr_disp.CursorMode
                case 'Draw Line'
                    curr_disp.CursorMode='Normal';
                otherwise
                    curr_disp.CursorMode='Draw Line';
            end
        case {'5' 'numpad5'}
            switch get(cursor_mode_tool_comp.measure,'state');
                case 'off'
                    set(cursor_mode_tool_comp.measure,'state','on');
                    curr_disp.CursorMode='Measure';
                case 'on'
                    set(cursor_mode_tool_comp.measure,'state','off');
                    curr_disp.CursorMode='Normal';
            end
        case {'b','pagedown'}
            
            switch curr_disp.DispUnderBottom
                case 'off'
                    curr_disp.DispUnderBottom='on';
                case 'on'
                    curr_disp.DispUnderBottom='off';
            end
            
        case 'r'
            
            switch curr_disp.DispReg
                case 'off'
                    curr_disp.DispReg='on';
                case 'on'
                    curr_disp.DispReg='off';
            end
        case 't'
            switch curr_disp.DispBadTrans
                case 'off'
                    curr_disp.DispBadTrans='on';
                case 'on'
                    curr_disp.DispBadTrans='off';
            end
            
        case 'c'
            cmaps={'ek60' 'esp2' 'ek500' 'asl' 'jet' 'hsv' };
            id_map=find(strcmp(curr_disp.Cmap,cmaps));
            if isempty(id_map)
                id_map=0;
            end
            curr_disp.Cmap=cmaps{nanmin(rem(id_map,length(cmaps))+1,length(cmaps))};
        case 'f'
            if length(layer.Frequencies)>1
                curr_disp.Freq=layer.Frequencies(nanmin(rem(idx_freq,length(layer.Frequencies))+1,length(layer.Frequencies)));
            end
        case 'e'
            if~isempty(trans.Data)
                if length(trans.Data.Fieldname)>1
                    fields=trans.Data.Fieldname;
                    id_field=find(strcmp(curr_disp.Fieldname,fields));
                    curr_disp.setField(fields{nanmin(rem(id_field,length(fields))+1,length(fields))});
                end
            end
            
        case 'n'
            change_layer_callback([],[],main_figure,'next');
        case 'p'
            change_layer_callback([],[],main_figure,'prev');
        case 'add'
            curr_disp=getappdata(main_figure,'Curr_disp');
            curr_disp.setCax(curr_disp.Cax+1);
        case 'subtract'
            curr_disp=getappdata(main_figure,'Curr_disp');
            curr_disp.setCax(curr_disp.Cax-1);
        case 'delete'
            if ~isempty(get(gco,'Tag'))
                switch get(gco,'Tag')
                    case {'region','region_text'}
                        id=get(gco,'Userdata');
                        idx= trans.find_regions_Unique_ID(id);
                        trans.rm_region_id(get(gco,'Userdata'));
                        display_regions(main_figure,'both');
                        
                        if ~isempty(trans.Regions)
                            curr_disp.Active_reg_ID=trans.Regions(nanmax(idx-1,1)).Unique_ID;
                        else
                            curr_disp.Active_reg_ID=[];
                        end
                               
                        order_stacks_fig(main_figure);
                end
            end
        case 'l'
            if isempty(callbackdata.Modifier)
                load_survey_data_fig_from_db(main_figure,0);
            elseif  strcmpi(callbackdata.Modifier,'shift')
               load_survey_data_fig_from_db(main_figure,0,1);
            end
            
        case 'w'
            keyboard_zoom(-1,main_figure);
        case 's'
            if isempty(callbackdata.Modifier)
                keyboard_zoom(1,main_figure)
            elseif strcmpi(callbackdata.Modifier,'control')
                save_bot_reg_xml_to_db_callback([],[],main_figure,0,0);
            end
        case 'y'
            if  strcmpi(callbackdata.Modifier,'control')
                uiundo(main_figure,'execRedo')
            end
        case 'z'
            if isempty(callbackdata.Modifier)
                go_to_ping(1,main_figure);
            elseif  strcmpi(callbackdata.Modifier,'control')
                uiundo(main_figure,'execUndo')
            end
            
        case 'x'
            go_to_ping(length(number_lay),main_figure);
    end
catch
   if~isdeployed
      disp('Error in Keyboard_func');    
   end
end
replace_interaction(src,'interaction','KeyPressFcn','id',1,'interaction_fcn',{@keyboard_func,main_figure});
%
% profile off;
%
% profile viewer;
end