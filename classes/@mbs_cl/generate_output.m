function generate_output(mbs,layers,varargin)

p = inputParser;

addRequired(p,'mbs',@(obj) isa(obj,'mbs_cl'));
addRequired(p,'layers',@(obj) isa(obj,'layer_cl'));
addParameter(p,'idx_trans',[],@isnumeric);
parse(p,mbs,layers,varargin{:});

idx_trans=p.Results.idx_trans;


transects=mbs.Input.transect;

if length(idx_trans) > length(transects)||isempty(idx_trans)
    warning('Requested index > num transects, using num transects');
    idx_trans=1:length(transects);
end

snap_lay=nan(1,length(layers));
strat_lay=cell(1,length(layers));
trans_lay=nan(1,length(layers));

for it=1:length(layers)
    snap_lay(it)=layers(it).SurveyData.Snapshot;
    strat_lay{it}=layers(it).SurveyData.Stratum;
    trans_lay(it)=layers(it).SurveyData.Transect;
end

processed=zeros(1,length(layers));
ii=0;

for uit=idx_trans
    
    idx_lay=(mbs.Input.transect(uit)==trans_lay&mbs.Input.snapshot(uit)==snap_lay&strcmp(mbs.Input.stratum(uit),strat_lay));
    idx_lay(processed==1)=0;
    processed(idx_lay)=1;
    idx_lay=find(idx_lay);
    
    if isempty(idx_lay)
        continue;
    end
    ii=ii+1;
    eint=0;
    
    reg_tot=[];
    end_ping=zeros(1,length(idx_lay));
    Output_echo={};
    for ifi=idx_lay
        dfile_Curr=fullfile(mbs.Input.dfileDir{ifi},sprintf('d%07d',mbs.Input.dfileNum(ifi)));
        dfile_Curr=strrep(dfile_Curr,'\','/');
        idx_freq=find_freq_idx(layers(ifi),38000);
        gps=layers(ifi).Transceivers(idx_freq).GPSDataPing;
        bot=layers(ifi).Transceivers(idx_freq).Bottom;
        gps.Long(gps.Long>180)=gps.Long(gps.Long>180)-360;
        
        
        trans=layers(ifi).Transceivers(idx_freq);
        idx_reg=1:length(trans.Regions);
        
        
        rs={};
        rsv={};
        rsa={};
        reg_tot=mbs.Input.reg{ifi};
        mbsVS = (mbs.Header.vertical_slice_size);
        
        Output_echo{ifi}=trans.slice_transect('reg',reg_tot,'Slice_w',mbsVS,'Slice_units','pings');
        
        for j=idx_reg
            
            reg_curr=trans.Regions(j);
            reg_tot=reg_tot(j);
            regCellInt = reg_curr.Output;
            startPing = regCellInt.Ping_S(1);
            stopPing = regCellInt.Ping_E(end);
            ix = (startPing:stopPing);
            ix_good=setdiff(ix,trans.IdxBad);
            
            horzSlice = reg_curr.Cell_h;
            %vertSlice = reg_curr.Cell_w;
            
            
            switch reg_curr.Reference
                case 'Surface';
                    refType = 's';
                    if isnan(reg.startDepth); start_d = trans.Data.Range(reg_curr.Idx_r(1)); else start_d = reg.startDepth; end
                    if isnan(reg.finishDepth); finish_d = trans.Data.Range(reg_curr.Idx_r(1)); else finish_d = reg.finishDepth; end
                case 'Bottom';
                    refType = 'b';
                    if isnan(reg.startDepth); start_d = 0; else start_d = reg.startDepth; end
                    if isnan(reg.finishDepth); finish_d = 0; else finish_d = reg.finishDepth; end
            end
            
            
            dist = m_lldist([gps.Long(reg_curr.Idx_pings(1)) gps.Long(reg_curr.Idx_pings(end))],[gps.Lat(reg_curr.Idx_pings(1)) gps.Lat(reg_curr.Idx_pings(end))])/1.852;% get distance as esp2 does... Straigth line estimate
            time_s = regCellInt.Time_S(1);
            time_e = regCellInt.Time_E(end);
            timediff = (time_e-time_s)*24;
            av_speed=dist/timediff;
            
            regCellIntSub = getCellIntSubSet(regCellInt,reg,refType);
            regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)=regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)-360;
            
            %% Region Summary (4th Mbs Output Block)
            rs{j,1} = mbs.Input.snapshot(ifi);
            rs{j,2} = mbs.Input.stratum{ifi};
            rs{j,3} = mbs.Input.transect(ifi);
            rs{j,4} = dfile_Curr;
            rs{j,5} = reg.id;
            rs{j,6} = refType;
            rs{j,7} = horzSlice;
            rs{j,8} = length(ix_good);
            rs{j,9} = start_d;
            good_bot=bot.Range(ix_good);
            rs{j,10} = nanmean(good_bot);% find bottom pings in good pings and only take mean from good ones
            rs{j,11} = finish_d;
            rs{j,12} = av_speed;
            rs{j,13} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nansum(regCellIntSub.Nb_good_pings_esp2.*regCellIntSub.Thickness_esp2));
            rs{j,14} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nanmax(regCellIntSub.Nb_good_pings_esp2));%Abscf Region
            
            %% Region Summary (abscf by vertical slice) (5th Mbs Output Block)
            rsa{j,1} = mbs.Input.snapshot(ifi);
            rsa{j,2} = mbs.Input.stratum{ifi};
            rsa{j,3} = mbs.Input.transect(ifi);
            rsa{j,4} = dfile_Curr;
            rsa{j,5} = reg.id;
            rsa{j,6} = size(regCellIntSub.Lat_S,2);  % num_v_slices
            rsa{j,7} = nanmax(regCellIntSub.Ping_S); % transmit Start vertical slice
            rsa{j,8} = nanmax(regCellIntSub.Lat_S); % lat vertical slice
            rsa{j,9} = nanmax(regCellIntSub.Lon_S); % lon vertical slice
            rsa{j,10} = nansum(regCellIntSub.Sa_lin)./nanmax(regCellIntSub.Nb_good_pings_esp2);%sum up all abcsf per vertical slice
            rsa{j,11} = nanmax(regCellIntSub.Ping_E);
            
            
            %% Region vbscf (6th Mbs Output Block)
            rsv{j,1} = mbs.Input.snapshot(ifi);
            rsv{j,2} = mbs.Input.stratum{ifi};
            rsv{j,3} = mbs.Input.transect(ifi);
            rsv{j,4} = dfile_Curr;
            rsv{j,5} = reg.id;
            rsv{j,6} = size(regCellIntSub.Sa_lin,1);% num_h_slices
            rsv{j,7} = size(regCellIntSub.Lat_S,2); % num_v_slices
            rsv{j,8} = rs{j,13}; % Vbscf Region
            [I,~]=find(~isnan(regCellIntSub.Sa_lin'));
            idx_first=nanmin(I);
            tmp = regCellIntSub.Sv_mean_lin_esp2(idx_first:(idx_first+rsv{j,6})-1,:);
            tmp(isnan(tmp))=0;
            tmp=tmp';
            tmp=tmp(:);
            rsv{j,9} = tmp; % vbscf_values (Sv_mean), reshape vbscf to Output horizontal slice by vertical slice like Esp2
            
            %% Region echo integral for File Summary
            eint =eint + nansum(nansum(regCellIntSub.Sa_lin));
            
        end
        
        if ~isempty(trans.Regions)
            mbs.Output.regionSum.Data =  [mbs.Output.regionSum.Data  ; rs];
            mbs.Output.regionSumAbscf.Data =  [mbs.Output.regionSumAbscf.Data  ; rsa];
            mbs.Output.regionSumVbscf.Data =  [mbs.Output.regionSumVbscf.Data  ; rsv];
        end
        
    end
    
    gps_tot=layer(1).Transceivers(idx_freq).GPSDataPing;
    bot_tot=layer(1).Transceivers(idx_freq).Bottom;
    IdxBad_tot=layer(1).Transceivers(idx_freq).IdxBad;
    
    if length(layer)>1
        for i=2:length(idx_lay)
            idx_freq=find_freq_idx(layers(idx_lay(i)),38000);
            if layers(idx_lay(i)).Transceivers(idx_freq).GPSDataPing.Time(1)> gps_tot.Time(end)
                bot_tot=concatenate_Bottom(bot_tot,layers(idx_lay(i)).Transceivers(idx_freq).Bottom);
                IdxBad_tot=[IdxBad_tot(:) ; layers(idx_lay(i)).Transceivers(idx_freq).IdxBad(:)];
            else
                bot_tot=concatenate_Bottom(layers(idx_lay(i)).Transceivers(idx_freq).Bottom,bot_tot);
                IdxBad_tot=[layers(idx_lay(i)).Transceivers(idx_freq).IdxBad(:) ; IdxBad_tot(:)];
            end
            gps_tot=concatenate_GPSData(gps_tot,layers(idx_lay(i)).Transceivers(idx_freq).GPSDataPing);
        end
    end
    layer.delete_layers([]);
    clear layer;
    
    gps_tot.Long(gps_tot.Long>180)=gps_tot.Long(gps_tot.Long>180)-360;
    
    
    %% File Summary (part of 2nd Mbs Output Block)
    idx_pings=1:length(gps_tot.Time);
    idx_good_pings=setdiff(idx_pings,IdxBad_tot);
    
    dist_tot = m_lldist([gps_tot.Long(1) gps_tot.Long(end)],[gps_tot.Lat(1) gps_tot.Lat(end)])/1.852;% get distance as esp2 does... Straigth line estimate
    time_s_tot = gps_tot.Time(1);
    time_e_tot = gps_tot.Time(end);
    timediff_tot = (time_e_tot-time_s_tot)*24;
    av_speed_tot=dist_tot/timediff_tot;
    good_bot_tot=nanmean(bot_tot.Range(idx_good_pings));
    
    
    %Will be used for Transect Summary
    fs{ii,1} = mbs.Input.snapshot(uit);
    fs{ii,2} = mbs.Input.stratum{uit};
    fs{ii,3} = mbs.Input.transect(uit);
    fs{ii,4} = dist_tot; % dist
    fs{ii,7} = nanmean(good_bot_tot); % mean_d
    fs{ii,8}= length(idx_good_pings); % pings %
    fs{ii,9} = av_speed_tot; % av_speed
    fs{ii,10} = gps.Lat(1); % start_lat
    fs{ii,11} = gps.Long(1); % start_lon
    fs{ii,12} = gps.Lat(end); % finish_lat
    fs{ii,13} = gps.Long(end); % finish_lon
    fs{ii,14} = eint; % Echo Integral
    fs{ii,15} = nansum(fs{ii,8}.*fs{ii,7}); % mean bottom depth * pings
    fs{ii,5} = fs{ii,14}/fs{ii,15}; % vbscf according to Esp2 formula
    fs{ii,6} = fs{ii,14}/fs{ii,8}; % abscf according to Esp2 formula
    
    %% Sliced File Summary
    % Export Integration by Cell for the whole Echogram gridded
    % to the defined vertical slice size from the mbs script to
    % get spatial information. The calculation of abscf is done
    % by summing all region abscf (rsa) for each slice (bin)
    
    
    %will be used for Sliced Transect Summary
    sfs{ii,1} = mbs.Input.snapshot(uit);
    sfs{ii,2} = mbs.Input.stratum{uit};
    sfs{ii,3} = mbs.Input.transect(uit);
    sfs{ii,4} = Output_echo(ii).slice_size; % slice_size
    sfs{ii,5} = Output_echo(ii).num_slices; % num_slices
    sfs{ii,6} = Output_echo(ii).slice_lat_esp2; % latitude
    sfs{ii,7} = Output_echo(ii).slice_lon_esp2; % longitude
    sfs{ii,8} = Output_echo(ii).slice_abscf; % slice_abscf
    
    if length(idx_lay)>1
        layer_tot.delete_layers([]);
    end
end



mbs.Output.stratumSum.Data = [];
mbs.Output.slicedTransectSum.Data = [];
mbs.Output.transectSum.Data = [];

for ii = 1:size(fs,1)
    % this for loop fills all empty cells with NaNs
    for jj = 1:size(fs,2)
        if isempty(fs{ii,jj})
            fs{ii,jj} = NaN;
        end
    end
end

%% Transect and Sliced Transect Summary (2nd and 3rd mbs Output block)
% calculate transect and sliced transect summary
tmp = cell2mat(fs(:,1));
snaps = unique(tmp(~isnan(tmp)));
mbs.Output.transectSum.Data=[];
mbs.Output.slicedTransectSum.Data=[];
mbs.Output.transectSum.Data = [];

for i = 1:length(snaps)
    % loop over all snapshots and get Data subset
    ix = find(cell2mat(fs(:,1))==snaps(i));
    tmpSn =fs(ix,:);
    tmpSnSl =sfs(ix,:);
    strats = unique(tmpSn(:,2));
    for j = 1:length(strats)
        % loop over all strata and get Data subset
        jx = (strcmp(tmpSn(:,2), strats{j}));
        idx=ix(jx);
        trans = unique(cell2mat(tmpSn(jx,3)));
        subtmpSn=tmpSn(jx,:);
        subtmpSnSl=tmpSnSl(jx,:);
        
        ln=size(mbs.Output.transectSum.Data,1);
        for k = 1:length(trans)
            mbs.Output.transectSum.Data = [mbs.Output.transectSum.Data ; subtmpSn(k,1:13)];
            mbs.Output.slicedTransectSum.Data = [mbs.Output.slicedTransectSum.Data ; subtmpSnSl(k,:)];
            mbs.Output.transectSum.Data{ln+k,5} =  nansum(cell2mat(subtmpSn(k,14)))/nansum(cell2mat(subtmpSn(k,15))); % vbscf according to Esp2 formula
            mbs.Output.transectSum.Data{ln+k,6} =  nansum(cell2mat(subtmpSn(k,14)))/nansum(cell2mat(subtmpSn(k,8))); % abscf according to Esp2 formula
            
        end
    end
    
end

%% Stratum Summary (1st mbs Output block)
% calculate stratum summary from transect summary Data
% according to esp2 formula
for i = 1:length(snaps)
    % loop over all snapshots and get Data subset
    ix = find(cell2mat(mbs.Output.transectSum.Data(:,1))==snaps(i));
    strats = unique(mbs.Output.transectSum.Data(ix,2));
    for j = 1:length(strats)
        % loop over all strata and get Data subset
        jx = (strcmp(mbs.Output.transectSum.Data(ix,2), strats{j}));
        idx=ix(jx);
        ss{j,1} = mbs.Output.transectSum.Data{idx(1),1}; % snapshot
        ss{j,2} = mbs.Output.transectSum.Data{idx(1),2}; % stratum
        ss{j,3} = length(mbs.Output.transectSum.Data(idx,6)); % % no_transects
        sum_abscf=nansum(cell2mat(mbs.Output.transectSum.Data(idx,6)));
        ss{j,4} =sum_abscf/ss{j,3} ; % abscf_mean
        sum_sq_abscf=nansum(cell2mat(mbs.Output.transectSum.Data(idx,6)).^2);
        if ss{j,3}>1
            ss{j,5} = sqrt((sum_sq_abscf-ss{j,4}.^2.*ss{j,3})/(ss{j,3}-1)); % abscf_sd
        else
            ss{j,5}=0;
        end
        
        ss{j,6} = nansum(cell2mat(mbs.Output.transectSum.Data(idx,4)).*cell2mat(mbs.Output.transectSum.Data(idx,6)))/...
            nansum(cell2mat(mbs.Output.transectSum.Data(idx,4))); % abscf_wmean according to esp2 formula
        if ss{j,3}>1
            ss{j,7} = (nansum((cell2mat(mbs.Output.transectSum.Data(idx,4)).^2).*(cell2mat(mbs.Output.transectSum.Data(idx,6)).^2))-2*ss{j,6}*...
                nansum((cell2mat(mbs.Output.transectSum.Data(idx,4)).^2).*(cell2mat(mbs.Output.transectSum.Data(idx,6))))+...
                ss{j,6}^2*nansum(cell2mat(mbs.Output.transectSum.Data(idx,4)).^2))*...
                ss{j,3}/((ss{j,3}-1)*nansum(cell2mat(mbs.Output.transectSum.Data(idx,4)))^2); % abscf_var according to esp2 formula
        else
            ss{j,7}=0;
        end
    end
    mbs.Output.stratumSum.Data = [mbs.Output.stratumSum.Data ; ss];
end


end