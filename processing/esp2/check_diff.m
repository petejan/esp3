

function check_diff(echo_file,esp2_file)

[~,echobsdata]  = read_mbs(echo_file);
[~,esp2mbsdata]  = read_mbs(esp2_file);

%
%% Stratum Summary
fn = fieldnames(esp2mbsdata.stratum(1,1));
for i = 4:length(fn);
    strat_data_echo=nan(1,length(echobsdata.stratum));
    strat_data_esp2=nan(1,length(esp2mbsdata.stratum));

    for j = 1:length(echobsdata.stratum)
        strat_num=[];
        for k=1:length(esp2mbsdata.stratum)
            if  strcmp(esp2mbsdata.stratum(1,k).stratum,echobsdata.stratum(1,j).stratum)&&...
                    esp2mbsdata.stratum(1,k).snapshot==echobsdata.stratum(1,j).snapshot
                strat_num=k;
            end
        end
        if isempty(strat_num)
            continue;
        end
        
        strat_data_echo(j) = echobsdata.stratum(1,j).(fn{i});
        strat_data_esp2(j) = esp2mbsdata.stratum(1,strat_num).(fn{i});    
        strat{j}=echobsdata.stratum(1,j).stratum;
   
    end
%     diff_strata_mean= nansum(strat_data_echo-strat_data_esp2)/(nansum(strat_data_esp2));


    figure(24);
    clf;
    ax=axes();
    plot(strat_data_echo,'-+r');hold on;
    plot(strat_data_esp2,'-ok');
    grid on;
    legend('Matlab','Esp2')
    title(sprintf('Snapshot: %.0f : %s',echobsdata.stratum(1,j).snapshot,fn{i}));
    set(ax,'xtick',1:length(strat_data_echo),'xticklabel',strat);
    hold off;
    pause();

    if abs(diff_strata_mean) < 0.001
        fprintf(1, 'Stratum Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if diff_strata_mean > 0
            fprintf(1, 'Stratum Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(diff_strata_mean));
        else
            fprintf(1, 'Stratum Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(diff_strata_mean));
        end
    end

end
fprintf(1,'\n');


%% Transect Summary
fn = fieldnames(esp2mbsdata.transect_summary(1,1));
for i = 4:length(fn);
    
    trans_data_echo=nan(1,length(echobsdata.transect_summary));
    trans_data_esp2=nan(1,length(echobsdata.transect_summary));

    for j = 1:length(echobsdata.transect_summary)
        trans_num=[];
        for k=1:length(esp2mbsdata.transect_summary)
            if  strcmp(esp2mbsdata.transect_summary(1,k).stratum,echobsdata.transect_summary(1,j).stratum)&&...
                    esp2mbsdata.transect_summary(1,k).snapshot==echobsdata.transect_summary(1,j).snapshot&&...
                    esp2mbsdata.transect_summary(1,k).transect==echobsdata.transect_summary(1,j).transect
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        
        trans_data_echo(j) = echobsdata.transect_summary(1,j).(fn{i});
        trans_data_esp2(j) = esp2mbsdata.transect_summary(1,trans_num).(fn{i});
        label{j}=sprintf('T: %d S: %s',echobsdata.transect_summary(1,j).transect,echobsdata.transect_summary(1,j).stratum);

    end
    diff_trans_mean =nansum(trans_data_echo-trans_data_esp2)./nansum(trans_data_esp2)*100;
    
    figure(24);
    clf;
    ax=axes();
    plot(trans_data_echo,'-+r');hold on;
    plot(trans_data_esp2,'-ok');
    grid on;
    legend('Matlab','Esp2')
    title(sprintf('%s Snap: %.0f',fn{i},echobsdata.transect_summary(1,j).snapshot));
    set(ax,'xtick',1:length(trans_data_echo),'xticklabel',label);
    set(ax,'XTickLabelRotation',-90);
    hold off;
    pause();

    if abs(diff_trans_mean) < 0.001
        fprintf(1, 'Transect Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if diff_trans_mean > 0
            fprintf(1, 'Transect Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(diff_trans_mean));
        else
            fprintf(1, 'Transect Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(diff_trans_mean));
        end
    end
end
fprintf(1,'\n');

%% Sliced transect
fn = fieldnames(echobsdata.transect(1,1));
for i = 3:length(fn);
    trans_sliced_data_echo=cell(1,length(echobsdata.transect));
    trans_sliced_data_esp2=cell(1,length(echobsdata.transect));
    diff_trans_sliced=nan(1,length(echobsdata.transect));
    denom_trans_sliced=nan(1,length(echobsdata.transect));
    for j = 1:length(echobsdata.transect)
        trans_num=[];
        for k=1:length(esp2mbsdata.transect)
            if  strcmp(esp2mbsdata.transect(1,k).stratum,echobsdata.transect(1,j).stratum)&&...
                    esp2mbsdata.transect(1,k).snapshot==echobsdata.transect(1,j).snapshot&&...
                    esp2mbsdata.transect(1,k).transect==echobsdata.transect(1,j).transect
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        
        trans_sliced_data_echo{j} = echobsdata.transect(1,j).(fn{i});
        trans_sliced_data_esp2{j} = esp2mbsdata.transect(1,trans_num).(fn{i});
        
        if i==8
            figure(24);
            clf;
            title(fn{i})
            plot(trans_sliced_data_echo{j},'-+r');
            hold on;
            plot(trans_sliced_data_esp2{j},'-ok');
            grid on;
            legend('Matlab','Esp2')
            title(sprintf('Sliced Transect: %0.f Stratum: %s',echobsdata.transect(1,j).transect,echobsdata.transect(1,j).stratum));
            hold off;
            xlabel('Slice Number');
            pause();
        end
        
        
        ln=nanmin(length(trans_sliced_data_echo{j}),length(trans_sliced_data_esp2{j}));
        diff_trans_sliced(j) = nansum((trans_sliced_data_echo{j}(1:ln)-trans_sliced_data_esp2{j}(1:ln)));
        denom_trans_sliced(j)=nansum(trans_sliced_data_esp2{j}(1:ln));
    end
    diff_trans_sliced_mean=nansum(diff_trans_sliced)./nansum(denom_trans_sliced)*100;

    if abs(diff_trans_sliced_mean) < 0.001
        fprintf(1, 'Sliced Transect Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if diff_trans_sliced_mean > 0
            fprintf(1, 'Sliced Transect Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(diff_trans_sliced_mean));
        else
            fprintf(1, 'Sliced Transect Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(diff_trans_sliced_mean));
        end
    end

end

fprintf(1,'\n');
%% Region Summary

fn = fieldnames(echobsdata.region_summary(1,1));
for i = 7:length(fn);

    region_data_echo=nan(1,length(echobsdata.region_summary));
    region_data_esp2=nan(1,length(echobsdata.region_summary));

    for j = 1:length(echobsdata.region_summary)
        trans_num=[];
        for k=1:length(esp2mbsdata.region_summary)
            if  strcmp(esp2mbsdata.region_summary(1,k).stratum,echobsdata.region_summary(1,j).stratum)&&...
                    esp2mbsdata.region_summary(1,k).snapshot==echobsdata.region_summary(1,j).snapshot&&...
                    esp2mbsdata.region_summary(1,k).transect==echobsdata.region_summary(1,j).transect&&...
                    esp2mbsdata.region_summary(1,k).region_id==echobsdata.region_summary(1,j).region_id
                trans_num=k;
            end
        end
        label_reg{j}=sprintf('R: %d T: %d %St: %s',echobsdata.region_summary(1,j).region_id,echobsdata.region_summary(1,j).transect,echobsdata.region_summary(1,j).stratum);
        if isempty(trans_num)
            continue;
        end
        
        region_data_echo(j) = echobsdata.region_summary(1,j).(fn{i});
        region_data_esp2(j) = esp2mbsdata.region_summary(1,trans_num).(fn{i});

    end
    figure(24);
    clf;
    ax=axes();
    plot(region_data_echo,'-+r');hold on;
    plot(region_data_esp2,'-ok');
    grid on;
    legend('Matlab','Esp2')
    title(sprintf('Region summary: %s',fn{i}));
    set(ax,'xtick',1:length(region_data_echo),'xticklabel',label_reg);
    set(ax,'XTickLabelRotation',-90);
    hold off;
    pause();

    
    region_data_diff_mean=nansum(region_data_echo-region_data_esp2)/nansum(region_data_esp2);
   

    if isnan(region_data_diff_mean); region_data_diff_mean=0; end
    if abs(region_data_diff_mean) < 0.001
        fprintf(1, 'Region Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if region_data_diff_mean > 0
            fprintf(1, 'Region Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(region_data_diff_mean));
        else
            fprintf(1, 'Region Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(region_data_diff_mean));
        end
    end

end
fprintf(1,'\n');

%% Region vbscf
fn = fieldnames(echobsdata.region_detail(1,1));
for i = 6:length(fn);
    for j = 1:length(echobsdata.region_detail)
        trans_num=[];
        
    region_vbscf_echo=cell(1,length(echobsdata.region_detail));
    region_vbscf_esp2=cell(1,length(echobsdata.region_detail));
    diff_vbscf=nan(1,length(echobsdata.region_detail));
    denom_vbscf=nan(1,length(echobsdata.region_detail));

        for k=1:length(esp2mbsdata.region_detail)
            if  strcmp(esp2mbsdata.region_detail(1,k).stratum,echobsdata.region_detail(1,j).stratum)&&...
                    esp2mbsdata.region_detail(1,k).snapshot==echobsdata.region_detail(1,j).snapshot&&...
                    esp2mbsdata.region_detail(1,k).transect==echobsdata.region_detail(1,j).transect&&...
                    esp2mbsdata.region_detail(1,k).region_id==echobsdata.region_detail(1,j).region_id
                trans_num=k;
            end
        end
        if isempty(trans_num)
              continue;
        end
        region_vbscf_echo{j} = echobsdata.region_detail(1,j).(fn{i});
        region_vbscf_esp2{j} = esp2mbsdata.region_detail(1,trans_num).(fn{i});
        
        if i==9
            figure(24);
            title(fn{i})
            plot(region_vbscf_echo{j}(:),'-+r');hold on;
            plot(region_vbscf_esp2{j}(:),'-ok');
            grid on;
            legend('Matlab','Esp2')
            title(sprintf('Region vbscf values \n Region: %0.f File: %s',echobsdata.region_detail(1,j).region_id,echobsdata.region_detail(1,j).filename));
            hold off;
            pause();
        end
        
        if length(region_vbscf_echo{j}(:))~=length(region_vbscf_esp2{j}(:))
            diff_vbscf(j)=nan;
            denom_vbscf(j) = nan;
            continue;
        end
       
        diff_vbscf(j)=nansum(region_vbscf_echo{j}(:)-region_vbscf_esp2{j}(:));
        denom_vbscf(j) = nansum(region_vbscf_esp2{j}(:));
        
        
    end
    
    diff_vbscf_mean =nansum(diff_vbscf)/nansum(denom_vbscf)*100;

    if isnan(diff_vbscf_mean); diff_vbscf_mean=0; end
    if abs(diff_vbscf_mean) < 0.001
        fprintf(1, 'Region vbscf %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if diff_vbscf_mean  > 0
            fprintf(1, 'Region vbscf %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(diff_vbscf_mean));
        else
            fprintf(1, 'Region vbscf %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(diff_vbscf_mean));
        end
    end
    clear a b c diff esp2
end

fprintf(1,'\n');

%% Region Summary (abscf by vertical slice)
fn = fieldnames(echobsdata.region(1,1));
for i = 7:length(fn);
    for j = 1:length(echobsdata.region)
        trans_num=[];
        region_sliced_echo=cell(1,length(echobsdata.region));
        region_sliced_esp2=cell(1,length(echobsdata.region));
        diff_region_sliced=nan(1,length(echobsdata.region));
        denom_region_sliced=nan(1,length(echobsdata.region));
        for k=1:length(esp2mbsdata.region)
            if  strcmp(esp2mbsdata.region(1,k).stratum,echobsdata.region(1,j).stratum)&&...
                    esp2mbsdata.region(1,k).snapshot==echobsdata.region(1,j).snapshot&&...
                    esp2mbsdata.region(1,k).transect==echobsdata.region(1,j).transect&&...
                    esp2mbsdata.region(1,k).region_id==echobsdata.region(1,j).region_id
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        region_sliced_echo{j} = echobsdata.region(1,j).(fn{i});
        region_sliced_esp2{j}= esp2mbsdata.region(1,trans_num).(fn{i});

       
        figure(24);
        plot(region_sliced_echo{j}(:),'-+r');hold on;
        plot(region_sliced_esp2{j}(:),'-ok');
        grid on;
        legend('Matlab','Esp2')
        title(sprintf('Region abscf \n Region: %0.f File: %s',echobsdata.region(1,j).region_id,echobsdata.region(1,j).filename));
        hold off;
        pause();

        
 
        ln=nanmin(length(region_sliced_echo{j}(:)),length(region_sliced_esp2{j}(:)));
        diff_region_sliced(j) = nansum((region_sliced_echo{j}(1:ln)-region_sliced_esp2{j}(1:ln)));
        denom_region_sliced(j)=nansum(region_sliced_esp2{j}(1:ln));
           
    end
    diff_region_sliced_mean=nansum(diff_region_sliced)/nansum(denom_region_sliced);

    if isnan(diff_region_sliced_mean); diff_region_sliced_mean=0; end
    if abs(diff_region_sliced_mean) < 0.001
        fprintf(1, 'Region Summary (abscf by vertical slice) %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if diff_region_sliced_mean > 0
            fprintf(1, 'Region Summary (abscf by vertical slice) %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(diff_region_sliced_mean));
        else
            fprintf(1, 'Region Summary (abscf by vertical slice) %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(diff_region_sliced_mean));
        end
    end
    
    clear a b c
end



end

