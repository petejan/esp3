function [layers,layer]=shuffle_layers(layers,layers_temp)

nb_transceivers=nan(1,length(layers_temp));
filetype=cell(1,length(layers_temp));
for i=1:length(layers_temp)
    curr_layer=layers_temp(i);
    nb_transceivers(i)=length(curr_layer.Transceivers);
    filetype{i}=curr_layer.Filetype;
end

trans_nb=unique(nb_transceivers);
idx_to_concatenate=cell(1,length(trans_nb));
idx_not_to_concatenate=cell(1,length(trans_nb));
for uu=length(trans_nb)
    idx=find(nb_transceivers==trans_nb(uu));
    for jj=idx
        curr_layer=layers_temp(jj);
        for ii=1:trans_nb(uu)
            curr_trans=curr_layer.Transceivers(ii);
            layers_grp(uu).time_start(ii,jj)=curr_trans.Data.Time(1);
            layers_grp(uu).time_end(ii,jj)=curr_trans.Data.Time(end);
            layers_grp(uu).dt(ii,jj)=(curr_trans.Data.Time(end)-curr_trans.Data.Time(1))/length(curr_trans.Data.Time);
            layers_grp(uu).nb_samples_range(ii,jj)=length(curr_trans.Data.Range);
        end
    end 
    
    samples_nb=unique(layers_grp(uu).nb_samples_range','rows')';
    idx_to_concatenate{uu}=cell(1,size(samples_nb,2));
    for kk=1:size(samples_nb,2)
        idx_to_concatenate{uu}{kk}=[];
        idx_not_to_concatenate{uu}{kk}=[];
        idx_same_samples=find(nansum(layers_grp(uu).nb_samples_range==repmat(samples_nb(:,kk),1,size(layers_grp(uu).nb_samples_range,2)))==trans_nb(uu));
        for kki=idx_same_samples
            for kkj=idx_same_samples
                if nansum(layers_grp(uu).time_end(:,kki)+ 5*layers_grp(uu).dt(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                        layers_grp(uu).time_end(:,kki)-5*layers_grp(uu).dt(:,kki)<=layers_grp(uu).time_start(:,kkj))==trans_nb(uu)
                    idx_to_concatenate{uu}{kk}=[idx_to_concatenate{uu}{kk} [idx(kki) idx(kkj)]];
                end
            end
        end
        idx_to_concatenate{uu}{kk}=unique(idx_to_concatenate{uu}{kk});
        if ~isempty(idx_to_concatenate{uu}{kk})
            idx_not_to_concatenate{uu}{kk}=setxor(idx_to_concatenate{uu}{kk},idx);
        else
             idx_not_to_concatenate{uu}{kk}=idx;
        end
    end
end

new_layers=[];

for uui=1:length(idx_to_concatenate)
    curr_layers=[];
    for kki=1:length(idx_to_concatenate{uui})
        curr_layers=[curr_layers layers_temp(idx_to_concatenate{uui}{kki})];
    end
    
    if length(curr_layers)>1
        layer_conc=curr_layers(1);
        for kk=1:length(curr_layers)-1
            if layer_conc.Transceivers(1).Data.Time(end)<=curr_layers(kk+1).Transceivers(1).Data.Time(end)
                layer_conc=concatenate_Layer(layer_conc,curr_layers(kk+1));
            else
                layer_conc=concatenate_Layer(curr_layers(kk+1),layer_conc);
            end
            
        end
        new_layers=[new_layers layer_conc];
    end
    
    for kkj=1:length(idx_not_to_concatenate{uui})
        new_layers=[new_layers layers_temp(idx_not_to_concatenate{uui}{kkj})];
    end
end


for u=1:length(new_layers)
    layer=new_layers(u);
    [~,found]=find_layer_idx(layers,layer.ID_num);
    
    if found==1
        warning('Who, that''s extremely unlikely!')
    end
    
    [~,found]=find_layer_idx(layers,0);
    if  found==1
        layers=layer;
    else
        layers=[layer layers];
    end
end

end