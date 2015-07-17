function [layers,layer]=shuffle_layers(layers,layers_temp)

accolate=1;
[~,found]=find_layer_idx(layers,0);

if  found==1
    layers=[];
end

if accolate==1
    layers_temp=[layers layers_temp];
    old_layers=layers;
    layers=[];
end


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
                if nansum(layers_grp(uu).time_end(:,kki)==layers_grp(uu).time_end(:,kkj)|...
                        layers_grp(uu).time_start(:,kki)==layers_grp(uu).time_start(:,kkj)|...
                        (layers_grp(uu).time_start(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                        layers_grp(uu).time_start(:,kki)<=layers_grp(uu).time_end(:,kkj))|...
                        (layers_grp(uu).time_end(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                        layers_grp(uu).time_end(:,kki)<=layers_grp(uu).time_end(:,kkj)))...
                        ==trans_nb(uu)
                    continue;
                end
                
                if nansum(layers_grp(uu).time_end(:,kki)+ 5*layers_grp(uu).dt(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                        layers_grp(uu).time_end(:,kki)-5*layers_grp(uu).dt(:,kki)<=layers_grp(uu).time_start(:,kkj))==trans_nb(uu)
                    idx_to_concatenate{uu}{kk}=[idx_to_concatenate{uu}{kk}; [idx(kki) idx(kkj)]];
                end
            end
        end
        %idx_to_concatenate{uu}{kk}=unique(idx_to_concatenate{uu}{kk}(:));%not good but will have to wait a bit!
        if ~isempty(idx_to_concatenate{uu}{kk})
            idx_not_to_concatenate{uu}{kk}=setxor(unique(idx_to_concatenate{uu}{kk}),idx);
        else
            idx_not_to_concatenate{uu}{kk}=idx;
        end
    end
end





new_layers=[];

for uui=1:length(idx_to_concatenate)
    
    for kki=1:length(idx_to_concatenate{uui})
        couples=idx_to_concatenate{uui}{kki};
        idx_looked=[];
        new_chains={};
        new_chains_start=[];
        new_chains_end=[];
        kkki=1;
        while length(idx_looked)<size(couples,1)
            [chains_start,chains_end,chains,idx_looked]=get_chains(couples,[],[],{},idx_looked);
            new_chains={new_chains{:} chains{:}};
            new_chains_start=[new_chains_start chains_start];
            new_chains_end=[new_chains_end chains_end];
            kkki=kkki+1;
        end
        
        for i=1:length(new_chains)
            for j=1:length(new_chains)
                if ~isempty(intersect(new_chains{i},new_chains{j}))&&(j~=i)
                    time_i=layers_temp(new_chains{i}(end)).Transceivers(1).Data.Time(end)-layers_temp(new_chains{i}(1)).Transceivers(1).Data.Time(1);
                    time_j=layers_temp(new_chains{j}(end)).Transceivers(1).Data.Time(end)-layers_temp(new_chains{j}(1)).Transceivers(1).Data.Time(1);
                    
                    if time_j>=time_i
                        idx_not_to_concatenate{uui}={idx_not_to_concatenate{uui}{:} setdiff(new_chains{i},new_chains{j})};
                        new_chains{i}=[];
                    else
                       idx_not_to_concatenate{uui}={idx_not_to_concatenate{uui}{:} setdiff(new_chains{j},new_chains{i})};
                       new_chains{j}=[];
                    end
                    
                end
            end
        end
        
        
        for iik=1:length(new_chains)
            curr_layers=layers_temp(new_chains{iik});
            
            if length(curr_layers)>1
                layer_conc=curr_layers(1);
                for kk=1:length(curr_layers)-1
                    if layer_conc.Transceivers(1).Data.Time(end)<=curr_layers(kk+1).Transceivers(1).Data.Time(end)
                        layer_conc=concatenate_Layer(layer_conc,curr_layers(kk+1));
                    else
                        layer_conc=concatenate_Layer(curr_layers(kk+1),layer_conc);
                    end
                    
                end
                new_layers=[layer_conc new_layers ];
            end
        end
        for kkj=1:length(idx_not_to_concatenate{uui})
            new_layers=[layers_temp(idx_not_to_concatenate{uui}{kkj}) new_layers ];
        end
    end
    
    
    for u=1:length(new_layers)
        layer=new_layers(u);
        if ~isempty(layers)
            [~,found]=find_layer_idx(layers,layer.ID_num);
        else
            found=0;
        end
        if found==1
            warning('Who, that''s extremely unlikely!')
        end
        layers=[layers layer];
    end
    
end
