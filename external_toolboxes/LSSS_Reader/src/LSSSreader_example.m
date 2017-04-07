%% Initialize

whr = which('LSSSreader_readsnapfiles');
[dr,~,~] = fileparts(whr);
dr = dr(1:end-3);

% Recursively list relevant data in the example directory. This can be used
% to search files in callisto.
files.snap = rdir(fullfile(dr,'exampledata','**','*.snap'));
files.work = rdir(fullfile(dr,'exampledata','**','*.work'));
files.raw = rdir(fullfile(dr,'exampledata','**','*.raw'));

% Match the different files
files=LSSSreader_pairfiles(files);


%% Pick a file
for file=1:size(files.F,1)
    snap = files.F{file,1};
    work = files.F{file,2};
    raw  = files.F{file,3};
    if isempty(snap)
        snap=work;
    end
    
    % Read snap file
    [school,layer,exclude,erased] = LSSSreader_readsnapfiles(snap);
    
    % Read raw file and convert to sv
    [raw_header,raw_data] = readEKRaw(raw);
    raw_cal = readEKRaw_GetCalParms(raw_header, raw_data);
    Sv = readEKRaw_Power2Sv(raw_data,raw_cal);
    
    % Get the transducer depth
    f=1;
    if length(raw_data.pings) > 1
        f=2; % Use 38 kHz if we can (which is usually channel 2 on IMR ships)
    end
    td = double(median(raw_data.pings(f).transducerdepth));
    
    % Plot result
    [fh, ih] = readEKRaw_SimpleEchogram(Sv.pings(f).Sv, 1:length(Sv.pings(f).time), Sv.pings(f).range);
    
    % Plot the interpretation mask
    hold on
    cs = cool;
    for i=1:length(layer)
        if length(layer)>1
            col = round(interp1(linspace(1,length(layer),size(cs,1)),1:size(cs,1),i));
        else
            col=1;
        end
        patch(layer(i).x,layer(i).y-td,cs(col,:),'FaceColor',cs(col,:),'FaceAlpha',.3)
    end
    
    cs = hot;
    for i=1:length(school)
        col = round(interp1(linspace(1,length(school),size(cs,1)),1:size(cs,1),i));
        patch(school(i).x,school(i).y-td,cs(col,:),'FaceColor',cs(col,:),'FaceAlpha',.3)
    end
    
    % Plot erased regions
    if ~isempty(erased)
        k = find(f == [erased.channel.channelID]); % erased data for channel f.
        if ~isempty(k == 1)
            for i=1:length(erased.channel(k).x) % loop over each ping with erased samples
                ping = erased.channel(k).x(i);
                ranges = erased.channel(k).y{i};
                for j=1:size(ranges,1) % loop over each contingous block of erased samples
                    startR = ranges(j,1);
                    endR = startR + ranges(j,2);
                    patch([ping ping+1 ping+1 ping], ...
                        [startR startR endR endR]-td, 'k', ...
                        'FaceAlpha', 0.8, 'EdgeColor', 'None')
                end
            end
        end
    end
    
    if ~isempty(exclude)
        % Plot exclude regions
        maxRange = max(Sv.pings(f).range);
        for i=1:length(exclude)
            [~, startPing] = min(abs(exclude(i).startTime - Sv.pings(f).time));
            endPing = startPing + exclude(i).numOfPings;
            patch([startPing startPing endPing endPing], ...
                [0 maxRange maxRange 0]-td, 'k', 'FaceAlpha', 0.7)
        end
    end
end
