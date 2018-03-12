function load_echo_int_tab(main_figure,parent_tab_group)
import javax.swing.*
import java.awt.*

switch parent_tab_group.Type
    case 'uitabgroup'
        echo_int_tab_comp.echo_int_tab=new_echo_tab(main_figure,parent_tab_group,'Title','Echo Integration','UiContextMenuName','echoint');
    case 'figure'
        echo_int_tab_comp.echo_int_tab=parent_tab_group;
end

pos_tab=getpixelposition(echo_int_tab_comp.echo_int_tab);

opt_panel_size=[0 0 200 pos_tab(4)];
echo_int_tab_comp.opt_panel=uipanel(echo_int_tab_comp.echo_int_tab,'units','pixels','BackgroundColor','white','position',opt_panel_size);

setappdata(main_figure,'echo_int_tab',echo_int_tab_comp);
set(echo_int_tab_comp.echo_int_tab,'ResizeFcn',{@resize_echo_int_cback,main_figure})
end

function resize_echo_int_cback(src,~,main_figure)

echo_int_tab_comp=getappdata(main_figure,'echo_int_tab');
pos_tab=getpixelposition(echo_int_tab_comp.echo_int_tab);

opt_panel_size=[0 0 200 pos_tab(4)];

set(echo_int_tab_comp.opt_panel,'position',opt_panel_size);

end