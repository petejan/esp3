

function check_diff(echo_file,esp2_file)

[~,echobsdata]  = read_mbs(echo_file);
[~,esp2mbsdata]  = read_mbs(esp2_file);

%
%% Stratum Summary
fn = fieldnames(esp2mbsdata.stratum(1,1));
for i = 2:length(fn);
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
        
        a = echobsdata.stratum(1,j).(fn{i});
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
        
        a(j) = echobsdata.transect_summary(1,j).(fn{i});
        b(j) = esp2mbsdata.transect_summary(1,trans_num).(fn{i});        
        c(j) = nansum((a(j)-b(j)))./nansum(b(j))*100;
    end
    
%     if strcmp(fn{i},'vbscf')
%         figure(415564);hold on;
%         title(fn{i})
%         plot(a(:));
%         plot(b(:));
%         grid on;
%         legend('Matlab','Esp2');
%         drawnow;
%         hold off;
%     end
%     
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
%% Sliced transect
fn = fieldnames(echobsdata.transect(1,1));
for i = 3:length(fn);
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
        
        a = echobsdata.transect(1,j).(fn{i});
        b = esp2mbsdata.transect(1,trans_num).(fn{i});
        
        a(isnan(a)|a==0)=[];
        b(isnan(b)|b==0)=[];
        if length(a)~=length(b)
            a(a==0)=[];
            b(b==0)=[];
        end
        
        if i==8
            figure(41564);
            title(fn{i})
            plot(a(:));hold on;
            plot(b(:));
            grid on;
            legend('Matlab','Esp2')
            title(sprintf('Sliced Transect: %0.f Stratum: %s',echobsdata.transect(1,j).transect,echobsdata.transect(1,j).stratum));
            hold off;
        end
        
        ln=nanmin(length(a),length(b));
        c(j) = nansum((a(1:ln)-b(1:ln)))./nansum(b(1:ln))*100;
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

fn = fieldnames(echobsdata.region_summary(1,1));
for i = 7:length(fn);
    c=zeros(1,length(echobsdata.region_summary));
    for j = 1:length(echobsdata.region_summary)
        trans_num=[];
        for k=1:length(esp2mbsdata.region_summary)
            if  strcmp(esp2mbsdata.region_summary(1,k).stratum,echobsdata.region_summary(1,j).stratum)&&...
                    esp2mbsdata.region_summary(1,k).snapshot==echobsdata.region_summary(1,j).snapshot&&...
                    esp2mbsdata.region_summary(1,k).transect==echobsdata.region_summary(1,j).transect&&...
                    strcmp(esp2mbsdata.region_summary(1,k).file,echobsdata.region_summary(1,j).file)&&...
                    esp2mbsdata.region_summary(1,k).region_id==echobsdata.region_summary(1,j).region_id
                trans_num=k;
            end
        end
        
        
        if isempty(trans_num)
            continue;
        end
        
        a = echobsdata.region_summary(1,j).(fn{i});
        b = esp2mbsdata.region_summary(1,trans_num).(fn{i});
        if b==0 && a==0
            c(j) =0;
        elseif b==0
            c(j) =nan;
        else
            c(j)= c(j)+(a-b)./b*100;
        end
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
fn = fieldnames(echobsdata.region_detail(1,1));
for i = 6:length(fn);
    for j = 1:length(echobsdata.region_detail)
        trans_num=[];
        for k=1:length(esp2mbsdata.region_detail)
            if  strcmp(esp2mbsdata.region_detail(1,k).stratum,echobsdata.region_detail(1,j).stratum)&&...
                    esp2mbsdata.region_detail(1,k).snapshot==echobsdata.region_detail(1,j).snapshot&&...
                    esp2mbsdata.region_detail(1,k).transect==echobsdata.region_detail(1,j).transect&&...
                    strcmp(esp2mbsdata.region_detail(1,k).filename,echobsdata.region_detail(1,j).filename)&&...
                    esp2mbsdata.region_detail(1,k).region_id==echobsdata.region_detail(1,j).region_id
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        a = echobsdata.region_detail(1,j).(fn{i});
        b = esp2mbsdata.region_detail(1,trans_num).(fn{i});
        a(isnan(a)|a==0)=[];
        b(isnan(b)|b==0)=[];
        if length(a)~=length(b)
            a(a==0)=[];
            b(b==0)=[];
        end
        
        if i==9
            figure(415664);
            title(fn{i})
            plot(a(:));hold on;
            plot(b(:));
            %plot((a(:)./b(:)));
            grid on;
            legend('Matlab','Esp2')
            title(sprintf('Region vbscf values \n Region: %0.f File: %s',echobsdata.region_detail(1,j).region_id,echobsdata.region_detail(1,j).filename));
            hold off;
            pause();
        end
        
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
fn = fieldnames(echobsdata.region(1,1));
for i = 7:length(fn);
    for j = 1:length(echobsdata.region)
        trans_num=[];
        for k=1:length(esp2mbsdata.region)
            if  strcmp(esp2mbsdata.region(1,k).stratum,echobsdata.region(1,j).stratum)&&...
                    esp2mbsdata.region(1,k).snapshot==echobsdata.region(1,j).snapshot&&...
                    esp2mbsdata.region(1,k).transect==echobsdata.region(1,j).transect&&...
                    strcmp(esp2mbsdata.region(1,k).filename,echobsdata.region(1,j).filename)&&...
                    esp2mbsdata.region(1,k).region_id==echobsdata.region(1,j).region_id
                trans_num=k;
            end
        end
        if isempty(trans_num)
            continue;
        end
        a = echobsdata.region(1,j).(fn{i});
        b = esp2mbsdata.region(1,trans_num).(fn{i});
        
        a(isnan(a)|a==0)=[];
        b(isnan(b)|b==0)=[];
        if length(a)~=length(b)
            a(a==0)=[];
            b(b==0)=[];
        end
        
        ln=nanmin(length(a),length(b));
        c(j) = nansum((a(1:ln)-b(1:ln)))./nansum(b(1:ln))*100;

        
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

