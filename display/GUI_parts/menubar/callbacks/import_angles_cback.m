function import_angles_cback(~,~,main_figure) 

layer=getappdata(main_figure,'Layer');

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);


list_freq_str=cell(1,length(layer.Frequencies));

for ki=1:length(layer.Frequencies)
    list_freq_str{ki}=num2str(layer.Frequencies(ki)/1e3,'%.0f kHz');
end

[select,val] = listdlg('ListString',list_freq_str,'SelectionMode','single','Name','Choose Frequency','PromptString','Choose Frequency to import angles from','InitialValue',idx_freq);

if val==0||isempty(select)||select==idx_freq
    return;
end


acrossangle_ori=trans_obj.Data.get_datamat('acrossangle');
acrossangle_new=layer.Transceivers(select).Data.get_datamat('acrossangle');
alongangle_new=layer.Transceivers(select).Data.get_datamat('alongangle');

trans_obj.Data.replace_sub_data_v2('acrossangle',imresize(acrossangle_new,size(acrossangle_ori),'nearest'),[],0);
trans_obj.Data.replace_sub_data_v2('alongangle',imresize(alongangle_new,size(acrossangle_ori),'nearest'),[],0);
update_display(main_figure,0);
update_mini_ax(main_figure,1)
end