function listenEcho(~,~,main_figure)
%disp('ListenEcho')
layer=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');
nb_layers=length(layers);
curr_disp=getappdata(main_figure,'Curr_disp');

if nb_layers==0
    return;
end

[idx_freq,found_freq]=find_freq_idx(layer,curr_disp.Freq);
[~,found_field]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

if found_freq==0
    idx_freq=1;
    %disp('Cannot Find Frequency...');
    curr_disp.Freq=layer.Frequencies(idx_freq);   
end

if found_field==0
    [~,found]=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
    if found==0
        field=layer.Transceivers(idx_freq).Data.Fieldname{1};
    else
        field='sv';
    end
    curr_disp.setField(field);
end
setappdata(main_figure,'Curr_disp',curr_disp);

if ~isempty(layer)
   if layer.ID_num==curr_disp.CurrLayerID&&nb_layers==curr_disp.NbLayers
       flag=0;
   else
       flag=1;
       curr_disp.CurrLayerID=layer.ID_num;
       curr_disp.NbLayers=nb_layers;
       %disp('New Layer')
   end
end

setappdata(main_figure,'Curr_disp',curr_disp);
update_display(main_figure,flag);

end

