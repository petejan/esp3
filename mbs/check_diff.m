% This script performs a quick check between the original Esp2 MBS output
% and the through MBSApp.m generated Echoview MBS output. It loops through
% startum, transect and region summary and returns the difference of the
% two outputs in the command window
%
%     \_________/       written by Johannes Oeffner
%         / \           in September 2013
%        /   \
%       / <>< \         Fisheries Acoustics
%      /<>< <><\        NIWA - National Institute of Water & Atmospheric Research

function check_diff(evm_file,esp2_file)

[~,evmbsdata]  = read_mbs(evm_file);
[~,esp2mbsdata]  = read_mbs(esp2_file);


% [evmbsheader,evmbsdata]  = read_mbs('CR2013_MatlabMBS_output.txt');
% [esp2mbsheader,esp2mbsdata]  = read_mbs('mbscr2013_output.txt');
%% stratum summary
% a = evmbsdata.stratum.abscf_mean;
% b = esp2mbsdata.stratum.abscf_mean;
% c = 100/a*b-100;
%
% if c>0
%     fprintf(1, 'stratum abscf : matlabmbs is %2.4f%% more than esp2mbs\n', abs(c));
% else
%     fprintf(1, 'stratums abscf : matlabmbs is %2.4f%% less than esp2mbs\n', abs(c));
% end
% clear c

%% transect summary
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
        
        a = evmbsdata.transect_summary(1,j).(fn{i});
        b = esp2mbsdata.transect_summary(1,trans_num).(fn{i});
        c(j) = 100/a*b-100;
    end
    c = nanmean((c));
    if abs(c) < 0.0001
        fprintf(1, 'transect summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c  < 0
            fprintf(1, 'transect summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'transect summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear c
end

%% region  summary
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
        c(j) = 100/a*b-100;
    end
    c = nanmean(c(:));
    if isnan(c); c=0; end
    if abs(c) < 0.0001
        fprintf(1, 'region summary %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c  < 0
            fprintf(1, 'region summary %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'region summary %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear c
end
%% details region  summary
fn = fieldnames(evmbsdata.region_detail(1,1));
for i = 8:length(fn);
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
        c(j) = 100/a(:)*b(:)-100;
%         figure();
%         imagesc(a-b)
    end
    c = nanmean(c(:));
    if isnan(c); c=0; end
    if abs(c) < 0.0001
        fprintf(1, 'region details %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c  < 0
            fprintf(1, 'region details %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'region details %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear c
end

%% siced region  summary
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
        c(j) = 100/a(:)*b(:)-100;
%         figure();
%         imagesc(a-b)
    end
    c = nanmean(c(:));
    if isnan(c); c=0; end
    if abs(c) < 0.0001
        fprintf(1, 'sliced details %s : matlabmbs is on average the same than esp2mbs\n', fn{i});
    else
        if c  < 0
            fprintf(1, 'sliced details %s : matlabmbs is on average %2.4f%% more than esp2mbs\n', fn{i}, abs(c));
        else
            fprintf(1, 'sliced details %s : matlabmbs is on average %2.4f%% less than esp2mbs\n', fn{i}, abs(c));
        end
    end
    clear c
end

end

