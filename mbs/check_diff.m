

function check_diff(evm_file,esp2_file)

[~,evmbsdata]  = read_mbs(evm_file);
[~,esp2mbsdata]  = read_mbs(esp2_file);

% 
%% Stratum Summary
fn = fieldnames(esp2mbsdata.stratum(1,1));
for i = 2:length(fn);
    for j = 1:length(evmbsdata.stratum)
        strat_num=[];
        for k=1:length(esp2mbsdata.stratum)
            if  strcmp(esp2mbsdata.stratum(1,k).stratum,evmbsdata.stratum(1,j).stratum)&&...
                    esp2mbsdata.stratum(1,k).snapshot==evmbsdata.stratum(1,j).snapshot
                strat_num=k;
            end
        end
        if isempty(strat_num)
            continue;
        end
        
        a = evmbsdata.stratum(1,j).(fn{i});
        b = esp2mbsdata.stratum(1,strat_num).(fn{i});
        c(j) = nansum((a(:)-b(:)))./nansum(b(:))*100;
    end
    c = nanmean((c));
    if abs(c) < 0.001
        fprintf(1, 'Stratum Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c > 0
            fprintf(1, 'Stratum Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'Stratum Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear a b c
end
fprintf(1,'\n');


%% Transect Summary
fn = fieldnames(esp2mbsdata.transect_summary(1,1));
for i = 4:length(fn);
    for j = 1:length(evmbsdata.transect_summary)
        trans_num=[];
        for k=1:length(esp2mbsdata.transect_summary)
            if  strcmp(esp2mbsdata.transect_summary(1,k).stratum,evmbsdata.transect_summary(1,j).stratum)&&...
                    esp2mbsdata.transect_summary(1,k).snapshot==evmbsdata.transect_summary(1,j).snapshot&&...
                    esp2mbsdata.transect_summary(1,k).transect==evmbsdata.transect_summary(1,j).transect
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        
        a(j) = evmbsdata.transect_summary(1,j).(fn{i});
        b(j) = esp2mbsdata.transect_summary(1,trans_num).(fn{i});

        c(j) = nansum((a(j)-b(j)))./nansum(b(j))*100;
    end
    
    if strcmp(fn{i},'vbscf')
        figure(415564);
        title(fn{i})
        plot(a);hold on;
        plot(b);
        grid on;
        legend('Matlab','Esp2');
        pause(0.5);
        hold off;
    end
    
    c = nanmean((c));
    if abs(c) < 0.001
        fprintf(1, 'Transect Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c > 0
            fprintf(1, 'Transect Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'Transect Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear a b c
end
fprintf(1,'\n');
%% transect
fn = fieldnames(evmbsdata.transect(1,1));
for i = 3:length(fn);
    for j = 1:length(evmbsdata.transect)
        trans_num=[];
        for k=1:length(esp2mbsdata.transect)
            if  strcmp(esp2mbsdata.transect(1,k).stratum,evmbsdata.transect(1,j).stratum)&&...
                    esp2mbsdata.transect(1,k).snapshot==evmbsdata.transect(1,j).snapshot&&...
                    esp2mbsdata.transect(1,k).transect==evmbsdata.transect(1,j).transect
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        
        a = evmbsdata.transect(1,j).(fn{i});
        b = esp2mbsdata.transect(1,trans_num).(fn{i});
        
        if length(a)~=length(b)
            c(j)=nan;
            continue;
        end
        
        c(j) = nansum((a(:)-b(:)))./nansum(b(:))*100;
    end
    c = nanmean((c));
    if abs(c) < 0.001
        fprintf(1, 'Sliced Transect Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c > 0
            fprintf(1, 'Sliced Transect Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'Sliced Transect Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear a b c
end
fprintf(1,'\n');
%% Region Summary
fn = fieldnames(evmbsdata.region_summary(1,1));
for i = 7:length(fn);
    for j = 1:length(evmbsdata.region_summary)
        trans_num=[];
        for k=1:length(esp2mbsdata.region_summary)
            if  strcmp(esp2mbsdata.region_summary(1,k).stratum,evmbsdata.region_summary(1,j).stratum)&&...
                    esp2mbsdata.region_summary(1,k).snapshot==evmbsdata.region_summary(1,j).snapshot&&...
                    esp2mbsdata.region_summary(1,k).transect==evmbsdata.region_summary(1,j).transect&&...
                    strcmp(esp2mbsdata.region_summary(1,k).file,evmbsdata.region_summary(1,j).file)
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        
        a = evmbsdata.region_summary(1,j).(fn{i});
        b = esp2mbsdata.region_summary(1,trans_num).(fn{i});
        c(j) = nansum((a(:)-b(:)))./nansum(b(:))*100;
    end
    
    c = nanmean(c(:));
    if isnan(c); c=0; end
    if abs(c) < 0.001
        fprintf(1, 'Region Summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c > 0
            fprintf(1, 'Region Summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'Region Summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear a b c
end
fprintf(1,'\n');
%% Region vbscf
fn = fieldnames(evmbsdata.region_detail(1,1));
for i = 6:length(fn);
    for j = 1:length(evmbsdata.region_detail)
        trans_num=[];
        for k=1:length(esp2mbsdata.region_detail)
            if  strcmp(esp2mbsdata.region_detail(1,k).stratum,evmbsdata.region_detail(1,j).stratum)&&...
                    esp2mbsdata.region_detail(1,k).snapshot==evmbsdata.region_detail(1,j).snapshot&&...
                    esp2mbsdata.region_detail(1,k).transect==evmbsdata.region_detail(1,j).transect&&...
                    strcmp(esp2mbsdata.region_detail(1,k).filename,evmbsdata.region_detail(1,j).filename)&&...
                    esp2mbsdata.region_detail(1,k).region_id==evmbsdata.region_detail(1,j).region_id
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        a = evmbsdata.region_detail(1,j).(fn{i});
        b = esp2mbsdata.region_detail(1,trans_num).(fn{i});
        if length(a)~=length(b)
            a(a==0)=[];
            b(b==0)=[];
        end
        
%         if i==9
%             figure(41564);
%             title(fn{i})
%             plot(a);hold on;
%             plot(b);
%             grid on;
%             legend('Matlab','Esp2')
%             title(sprintf('Transect: %0.f File: %s',evmbsdata.region_detail(1,j).transect,evmbsdata.region_detail(1,j).filename));
%             %pause(1);
%             hold off;
%         end
        
        if length(a(:))~=length(b(:))
            diff(j)=nan;
            esp2(j) = nan;    
            continue;
        end
        diff(j)=nansum(a(:)-b(:));
        esp2(j) = nansum(b(:));
        
                     
    end
    
    c =nansum(diff)/nansum(esp2)*100;
    if isnan(c); c=0; end
    if abs(c) < 0.001
        fprintf(1, 'Region vbscf %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c  > 0
            fprintf(1, 'Region vbscf %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'Region vbscf %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear a b c diff esp2
end

fprintf(1,'\n');

%% Region Summary (abscf by vertical slice)
fn = fieldnames(evmbsdata.region(1,1));
for i = 7:length(fn);
    for j = 1:length(evmbsdata.region)
        trans_num=[];
        for k=1:length(esp2mbsdata.region)
            if  strcmp(esp2mbsdata.region(1,k).stratum,evmbsdata.region(1,j).stratum)&&...
                    esp2mbsdata.region(1,k).snapshot==evmbsdata.region(1,j).snapshot&&...
                    esp2mbsdata.region(1,k).transect==evmbsdata.region(1,j).transect&&...
                    strcmp(esp2mbsdata.region(1,k).filename,evmbsdata.region(1,j).filename)&&...
                    esp2mbsdata.region(1,k).region_id==evmbsdata.region(1,j).region_id
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        a = evmbsdata.region(1,j).(fn{i});
        b = esp2mbsdata.region(1,trans_num).(fn{i});
        c(j) = nansum((a(:)-b(:)))./nansum(b(:))*100;
        %         figure();
        %         imagesc(a-b)
        
    end
    c = nanmean(c(:));
    if isnan(c); c=0; end
    if abs(c) < 0.001
        fprintf(1, 'Region Summary (abscf by vertical slice) %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c > 0
            fprintf(1, 'Region Summary (abscf by vertical slice) %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'Region Summary (abscf by vertical slice) %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    
    clear a b c
end



end

