function layers_out=rearrange_layers(layers_in,multi_layer)

%multi_layer=-1: force concatenation of compatible layers
%multi_layer=0: concatenate only consecutive/compatible layers
%multi_layer=1: do nothing

if multi_layer==1
    layers_out=layers_in;
    return;
end

nb_transceivers=nan(1,length(layers_in));
filetype=cell(1,length(layers_in));

for i=1:length(layers_in)
    curr_layer=layers_in(i);
    nb_transceivers(i)=length(curr_layer.Transceivers);
    filetype{i}=curr_layer.Filetype;
    %fold_temp=curr_layer.get_folder();
end

trans_nb=unique(nb_transceivers);

idx_to_concatenate=cell(1,length(trans_nb));
idx_not_to_concatenate=cell(1,length(trans_nb));

for uu=1:length(trans_nb)
    idx=find(nb_transceivers==trans_nb(uu));
   
    for jj=1:length(idx)
        curr_layer=layers_in(idx(jj));
        if (trans_nb(uu))>0
            for ii=1:trans_nb(uu)
                curr_trans=curr_layer.Transceivers(ii);
                layers_grp(uu).freqs(ii,jj)=curr_trans.Config.Frequency;
                layers_grp(uu).time_start(ii,jj)=curr_trans.Data.Time(1);
                layers_grp(uu).time_end(ii,jj)=curr_trans.Data.Time(end);
                layers_grp(uu).dt(ii,jj)=(curr_trans.Data.Time(end)-curr_trans.Data.Time(1))/length(curr_trans.Data.Time);
                layers_grp(uu).nb_samples_range(ii,jj)=length(curr_trans.get_transceiver_range());
            end
        else
                layers_grp(uu).freqs(1,jj)=0;
                if~isempty(curr_layer.GPSData.Time)
                    layers_grp(uu).time_start(1,jj)=curr_layer.GPSData.Time(1);
                    layers_grp(uu).time_end(1,jj)=curr_layer.GPSData.Time(end);
                    layers_grp(uu).dt(1,jj)=(curr_layer.GPSData.Time(end)-curr_layer.GPSData.Time(1))/length(curr_layer.GPSData.Time)*10;
                end
                layers_grp(uu).nb_samples_range(1,jj)=0;
        end
        
    end
    
    samples_nb=unique(layers_grp(uu).nb_samples_range','rows')';
    idx_to_concatenate{uu}=cell(1,size(samples_nb,2));
    idx_not_to_concatenate{uu}=[];
    for kk=1:size(samples_nb,2)
        idx_to_concatenate{uu}{kk}=[];
        
        if trans_nb(uu)>0
            idx_same_samples=find(nansum(layers_grp(uu).nb_samples_range==repmat(samples_nb(:,kk),1,size(layers_grp(uu).nb_samples_range,2)),1)==trans_nb(uu));
        else
             idx_same_samples=find(nansum(layers_grp(uu).nb_samples_range==repmat(samples_nb(:,kk),1,size(layers_grp(uu).nb_samples_range,2)),1));
             trans_nb(uu)=1;
        end
        
        if multi_layer==0
            for kki=idx_same_samples
                for kkj=idx_same_samples
                    if nansum(layers_grp(uu).time_end(:,kki)==layers_grp(uu).time_end(:,kkj)|...
                            layers_grp(uu).time_start(:,kki)==layers_grp(uu).time_start(:,kkj)|...
                            (layers_grp(uu).time_start(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                            layers_grp(uu).time_start(:,kki)<=layers_grp(uu).time_end(:,kkj))|...
                            (layers_grp(uu).time_end(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                            layers_grp(uu).time_end(:,kki)<=layers_grp(uu).time_end(:,kkj)))...
                            ==trans_nb(uu)||...
                            length(intersect(layers_grp(uu).freqs(:,kki),layers_grp(uu).freqs(:,kkj)))~=trans_nb(uu);
                        continue;
                    end
                    
                    if nansum(layers_grp(uu).time_end(:,kki)+ 15*layers_grp(uu).dt(:,kki)>=layers_grp(uu).time_start(:,kkj)&...
                            layers_grp(uu).time_end(:,kki)-15*layers_grp(uu).dt(:,kki)<=layers_grp(uu).time_start(:,kkj))==trans_nb(uu)
                        idx_to_concatenate{uu}{kk}=[idx_to_concatenate{uu}{kk}; [idx(kki) idx(kkj)]];
                        
                    end
                end
            end
        elseif multi_layer==-1
            [~,idx_sort]=sort(layers_grp(uu).time_start(1,idx_same_samples));
            if length(idx_sort)>=2
                idx_to_concatenate{uu}{kk}=[idx(idx_same_samples(idx_sort(1:end-1)));idx(idx_same_samples(idx_sort(2:end)))]';
            else
                idx_to_concatenate{uu}{kk}=[];
            end
        end
        
        if ~isempty(idx_to_concatenate{uu}{kk})
            new_not_to=setdiff(idx(idx_same_samples),unique(idx_to_concatenate{uu}{kk}(:)));
            idx_not_to_concatenate{uu}=unique([idx_not_to_concatenate{uu}(:);new_not_to(:)]);
        else
            new_to=idx(idx_same_samples(:));
            idx_not_to_concatenate{uu}=unique([idx_not_to_concatenate{uu}(:) ; new_to(:)]);
        end
    end
end

layers_out=[];

for uui=1:length(idx_to_concatenate)
    for kki=1:length(idx_to_concatenate{uui})
        couples=idx_to_concatenate{uui}{kki};
        
        if multi_layer>-1
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
                        time_i=layers_in(new_chains{i}(end)).Transceivers(1).Data.Time(end)-layers_in(new_chains{i}(1)).Transceivers(1).Data.Time(1);
                        time_j=layers_in(new_chains{j}(end)).Transceivers(1).Data.Time(end)-layers_in(new_chains{j}(1)).Transceivers(1).Data.Time(1);
                        
                        if time_j>=time_i
                            temp_u=setdiff(new_chains{i},new_chains{j});
                            new_chains{i}=[];
                        else
                            temp_u=setdiff(new_chains{j},new_chains{i});
                            new_chains{j}=[];
                        end
                        idx_not_to_concatenate{uui}=unique([idx_not_to_concatenate{uui}(:); temp_u(:)]);
                    end
                end
            end
        else
            if ~isempty(couples)
                new_chains{1}=[couples(:,1) ;couples(end,end)];
            else
                new_chains{1}=[];
            end
        end
        
        for iik=1:length(new_chains)
            curr_layers=layers_in(new_chains{iik});
            
            if length(curr_layers)>1
                layer_conc=curr_layers(1);
                for kk=1:length(curr_layers)-1
                    if ~isempty(layer_conc.Transceivers)
                        t_1=layer_conc.Transceivers(1).Data.Time(end);
                    elseif ~isempty(layer_conc.GPSData.Time)
                        t_1=layer_conc.GPSData.Time(end);
                    else
                       t_1=[]; 
                    end
                    
                    if ~isempty(curr_layers(kk+1).Transceivers)
                        t_2=curr_layers(kk+1).Transceivers(1).Data.Time(end);
                    elseif ~isempty(curr_layers(kk+1).GPSData.Time)
                        t_2=curr_layers(kk+1).GPSData.Time(end);
                    else
                        t_2=[];
                    end
                    
                    
                    if t_1<=t_2
                        layer_conc=concatenate_layers(layer_conc,curr_layers(kk+1));
                    else
                        layer_conc=concatenate_layers(curr_layers(kk+1),layer_conc);
                    end
                    
                end
                clear curr_layers;
                layers_out=[layers_out layer_conc];
            end
        end
    end
    
    for kkkj=1:length(idx_not_to_concatenate{uui})
        layers_out=[layers_out layers_in(idx_not_to_concatenate{uui}(kkkj))];
    end
    
    
    
end