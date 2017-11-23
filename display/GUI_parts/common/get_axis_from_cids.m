function [echo_im_tot,echo_ax_tot,echo_im_bt_tot,trans_obj,text_size]=get_axis_from_cids(main_figure,main_or_mini)


echo_im_tot=[];
echo_ax_tot=[];
echo_im_bt_tot=[];
trans_obj={};
text_size=[];

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
secondary_freq=getappdata(main_figure,'Secondary_freq');
for im=1:length(main_or_mini)
    switch main_or_mini{im}
        case 'main'
            axes_panel_comp=getappdata(main_figure,'Axes_panel');
            echo_im_tmp=axes_panel_comp.main_echo;
            echo_ax_tmp=axes_panel_comp.main_axes;
            echo_im_bt_tmp=axes_panel_comp.bad_transmits;
            set(axes_panel_comp.bottom_plot,'vis',curr_disp.DispBottom);
            [trans_obj_temp,~]=layer.get_trans(curr_disp);
            
            if isempty(trans_obj_temp)
                continue;
            end
            trans_obj{numel(trans_obj)+1}=trans_obj_temp;
            text_size(numel(text_size)+1)=10;
        case 'mini'
            mini_axes_comp=getappdata(main_figure,'Mini_axes');
            echo_im_tmp=mini_axes_comp.mini_echo;
            echo_ax_tmp=mini_axes_comp.mini_ax;
            echo_im_bt_tmp=mini_axes_comp.mini_echo_bt;
            
            [trans_obj_temp,~]=layer.get_trans(curr_disp);
            
            if isempty(trans_obj_temp)
                continue;
            end
            trans_obj{numel(trans_obj)+1}=trans_obj_temp;
            text_size(numel(text_size)+1)=6;
        otherwise
            if~isempty(secondary_freq)&&curr_disp.DispSecFreqs>0
                idx=(strcmp(main_or_mini{im},{secondary_freq.echoes(:).Tag}));
                echo_ax_tmp=secondary_freq.axes(idx);
                echo_im_tmp=secondary_freq.echoes(idx);
                echo_im_bt_tmp=secondary_freq.echoes_bt(idx);
                for i=1:length(echo_ax_tmp)
                    [trans_obj_temp,~]=layer.get_trans(main_or_mini{im});
                    if isempty(trans_obj_temp)
                        continue;
                    end
                    trans_obj{numel(trans_obj)+1}=trans_obj_temp;
                    text_size(numel(text_size)+1)=6;
                end
            else
                continue;
            end
    end
    echo_im_tot=[echo_im_tot echo_im_tmp];
    echo_ax_tot=[echo_ax_tot echo_ax_tmp];
    echo_im_bt_tot=[echo_im_bt_tot echo_im_bt_tmp];
end