function generate_output(surv_obj,layers,varargin)

p = inputParser;

addRequired(p,'surv_obj',@(obj) isa(obj,'survey_cl'));
addRequired(p,'layers',@(obj) isa(obj,'layer_cl')||isempty(obj));
addParameter(p,'PathToMemmap','',@ischar);
parse(p,surv_obj,layers,varargin{:});

if isempty(layers)
    layers=load_files_from_survey_input(surv_obj,'PathToMemmap',p.Results.PathToMemmap);
end

surv_in_obj=surv_obj.SurvInput;

vert_slice = surv_in_obj.Options.Vertical_slice_size;

snap_lay=nan(1,length(layers));
strat_lay=cell(1,length(layers));
trans_lay=nan(1,length(layers));
nb_reg_lay=nan(1,length(layers));

for it=1:length(layers)
    snap_lay(it)=layers(it).SurveyData.Snapshot;
    strat_lay{it}=layers(it).SurveyData.Stratum;
    trans_lay(it)=layers(it).SurveyData.Transect;
    idx_freq=find_freq_idx(layers(it),surv_in_obj.Options.Frequency);
    idx_reg=layers(it).Transceivers(idx_freq).list_regions_type('Data');
    nb_reg_lay(it)=length(idx_reg);
    
end

nb_reg=nansum(nb_reg_lay);
[snap_vec,stratum_vec,transect_vec]=surv_in_obj.list_transects();

[~,nb_strat,nb_trans]=get_num_trans(snap_lay,strat_lay,trans_lay);

surv_out_obj=survey_output_cl(nb_strat,nb_trans,nansum(nb_reg_lay));
snapshots=surv_in_obj.Snapshots;

i_trans=0;
i_reg=0;
for isn=1:length(snapshots)
    snap_num=snapshots{isn}.Number;
    stratum=snapshots{isn}.Stratum;
    for ist=1:length(stratum)
        strat_name=stratum{ist}.Name;
        transects=stratum{ist}.Transects;
        for itr=1:length(transects)
            i_trans=i_trans+1;
            trans_num=transects{itr}.number;
            idx_lay=find(trans_num==trans_lay&snap_num==snap_lay&strcmpi(strat_name,strat_lay));
            
            if isempty(idx_lay)
                warning('Could not find layers for Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
                continue;
            end
            fprintf('Integrating Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
            
            Output_echo=[];
            eint=0;
            nb_tracks=0;
            nb_st=0;
            lat_track=[];
            lon_track=[];
            depth_track=[];
            ping_num_track=[];
            time_track=[];
            TS_mean_track=[];
            for ilay=idx_lay
                layer_obj_tr=layers(ilay);
                idx_freq=find_freq_idx(layer_obj_tr,surv_in_obj.Options.Frequency);
                gps=layer_obj_tr.Transceivers(idx_freq).GPSDataPing;
                bot=layer_obj_tr.Transceivers(idx_freq).Bottom;
                gps.Long(gps.Long>180)=gps.Long(gps.Long>180)-360;
                trans_obj_tr=layer_obj_tr.Transceivers(idx_freq);
                
                if ~isempty(trans_obj_tr.ST.TS_comp)
                    nb_st=nb_st+length(trans_obj_tr.ST.TS_comp);
                end
                                  
                if ~isempty(trans_obj_tr.Tracks.target_id)
                    nb_tracks=nb_tracks+length(trans_obj_tr.Tracks.target_id);
                    lat_st=trans_obj_tr.GPSDataPing.Lat(trans_obj_tr.ST.Ping_number);
                    lon_st=trans_obj_tr.GPSDataPing.Long(trans_obj_tr.ST.Ping_number);
                    time_st=trans_obj_tr.GPSDataPing.Time(trans_obj_tr.ST.Ping_number);
                    depth_st=trans_obj_tr.ST.Target_range;
                    ping_num_st=trans_obj_tr.ST.Ping_number;
                    TS_st=trans_obj_tr.ST.TS_comp;
                    
                    for itracks=1:length(trans_obj_tr.Tracks.target_id)
                        idx_tr=trans_obj_tr.Tracks.target_id{itracks};
                        lat_track=[lat_track nanmean(lat_st(idx_tr))];
                        lon_track=[lon_track nanmean(lon_st(idx_tr))];
                        time_track=[time_track nanmean(time_st(idx_tr))];
                        depth_track=[depth_track nanmean(depth_st(idx_tr))];
                        ping_num_track=[ping_num_track nanmean(ping_num_st(idx_tr))];
                        TS_mean_track=[TS_mean_track  pow2db_perso(nanmean(db2pow_perso(TS_st(idx_tr))))];
                    end
                end
                
                idx_reg=trans_obj_tr.list_regions_type('Data');
                reg_tot=trans_obj_tr.get_reg_spec(idx_reg);
                [sliced_output,regs,regCellInt_tot]=trans_obj_tr.slice_transect('reg',reg_tot,'Slice_w',vert_slice,'Slice_units','pings');
                Output_echo=[Output_echo sliced_output];
                for j=1:length(regs)
                    i_reg=i_reg+1;
                    reg_curr =regs{j};
                    reg=reg_tot(j);
                    regCellInt=regCellInt_tot{j};
                    startPing = regCellInt.Ping_S(1);
                    stopPing = regCellInt.Ping_E(end);
                    ix = (startPing:stopPing);
                    ix_good=intersect(ix,find(trans_obj_tr.Bottom.Tag>0));
                    good_bot=bot.Range(ix_good);

                    
                    switch reg_curr.Reference
                        case 'Surface';
                            refType = 's';
                            start_d = trans_obj_tr.Data.Range(reg_curr.Idx_r(1));
                            finish_d = trans_obj_tr.Data.Range(reg_curr.Idx_r(1));
                        case 'Bottom';
                            refType = 'b';
                            start_d = 0;
                            finish_d = 0;
                    end
                    
                    dist = m_lldist([gps.Long(reg_curr.Idx_pings(1)) gps.Long(reg_curr.Idx_pings(end))],[gps.Lat(reg_curr.Idx_pings(1)) gps.Lat(reg_curr.Idx_pings(end))])/1.852;% get distance as esp2 does... Straigth line estimate
                    time_s = regCellInt.Time_S(1);
                    time_e = regCellInt.Time_E(end);
                    timediff = (time_e-time_s)*24;
                    av_speed=dist/timediff;
                    
                    regCellIntSub = getCellIntSubSet(regCellInt,reg,refType);
                    regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)=regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)-360;
                    
                    surv_out_obj.regionsIntegrated.snapshot(i_reg)=snap_num;
                    surv_out_obj.regionsIntegrated.stratum{i_reg}=strat_name;
                    surv_out_obj.regionsIntegrated.transect(i_reg)=trans_num;
                    surv_out_obj.regionsIntegrated.file{i_reg}=layer_obj_tr.Filename;
                    surv_out_obj.regionsIntegrated.Region{i_reg}=reg_curr;
                    
                    surv_out_obj.regionSum.snapshot(i_reg)=snap_num;
                    surv_out_obj.regionSumAbscf.snapshot(i_reg)=snap_num;
                    surv_out_obj.regionSumVbscf.snapshot(i_reg)=snap_num;
                    
                    surv_out_obj.regionSum.stratum{i_reg}=strat_name;
                    surv_out_obj.regionSumAbscf.stratum{i_reg}=strat_name;
                    surv_out_obj.regionSumVbscf.stratum{i_reg}=strat_name;
                    
                    surv_out_obj.regionSum.transect(i_reg)=trans_num;
                    surv_out_obj.regionSumAbscf.transect(i_reg)=trans_num;
                    surv_out_obj.regionSumVbscf.transect(i_reg)=trans_num;
                    
                    surv_out_obj.regionSum.file{i_reg}=layer_obj_tr.Filename;
                    surv_out_obj.regionSumAbscf.file{i_reg}=layer_obj_tr.Filename;
                    surv_out_obj.regionSumVbscf.file{i_reg}=layer_obj_tr.Filename;
                    
                    surv_out_obj.regionSum.region_id(i_reg)=reg_curr.ID;
                    surv_out_obj.regionSumAbscf.region_id(i_reg)=reg_curr.ID;
                    surv_out_obj.regionSumVbscf.region_id(i_reg)=reg_curr.ID;
                    
                    %% Region Summary (4th Mbs Output Block)
                    surv_out_obj.regionSum.time_end(i_reg)=regCellIntSub.Time_E(end);
                    surv_out_obj.regionSum.time_start(i_reg)=regCellIntSub.Time_S(1);
                    surv_out_obj.regionSum.ref{i_reg}=refType;
                    surv_out_obj.regionSum.slice_size(i_reg)=reg_curr.Cell_h;
                    surv_out_obj.regionSum.good_pings(i_reg)=length(ix_good);
                    surv_out_obj.regionSum.start_d(i_reg)= start_d;
                    surv_out_obj.regionSum.mean_d(i_reg)=nanmean(good_bot);
                    surv_out_obj.regionSum.finish_d(i_reg)=finish_d;
                    surv_out_obj.regionSum.av_speed(i_reg)=av_speed;
                    surv_out_obj.regionSum.vbscf(i_reg)= nansum(nansum(regCellIntSub.Sa_lin))./nansum(nansum(regCellIntSub.Nb_good_pings_esp2.*regCellIntSub.Thickness_esp2));
                    surv_out_obj.regionSum.abscf(i_reg)= nansum(nansum(regCellIntSub.Sa_lin))./nansum(nanmax(regCellIntSub.Nb_good_pings_esp2));%Abscf Region
                    
                    %% Region Summary (abscf by vertical slice) (5th Mbs Output Block)
                    surv_out_obj.regionSumAbscf.time_end{i_reg}=regCellIntSub.Time_E(end,:);
                    surv_out_obj.regionSumAbscf.time_start{i_reg}=regCellIntSub.Time_S(1,:);
                    surv_out_obj.regionSumAbscf.num_v_slices(i_reg)=size(regCellIntSub.Lat_S,2);
                    surv_out_obj.regionSumAbscf.transmit_start{i_reg} = nanmax(regCellIntSub.Ping_S); % transmit Start vertical slice
                    surv_out_obj.regionSumAbscf.latitude{i_reg} = nanmax(regCellIntSub.Lat_S); % lat vertical slice
                    surv_out_obj.regionSumAbscf.longitude{i_reg} = nanmax(regCellIntSub.Lon_S); % lon vertical slice
                    surv_out_obj.regionSumAbscf.column_abscf{i_reg} = nansum(regCellIntSub.Sa_lin)./nanmax(regCellIntSub.Nb_good_pings_esp2);%sum up all abcsf per vertical slice
                    
                    %% Region vbscf (6th Mbs Output Block)
                    surv_out_obj.regionSumVbscf.time_end{i_reg}=regCellIntSub.Time_E;
                    surv_out_obj.regionSumVbscf.time_start{i_reg}=regCellIntSub.Time_S;
                    surv_out_obj.regionSumVbscf.num_h_slices(i_reg) = size(regCellIntSub.Sv_mean_lin_esp2,1);% num_h_slices
                    surv_out_obj.regionSumVbscf.num_v_slices(i_reg) = size(regCellIntSub.Sv_mean_lin_esp2,2); % num_v_slices
                    tmp=surv_out_obj.regionSum.vbscf(i_reg);
                    tmp(isnan(tmp))=0;
                    surv_out_obj.regionSumVbscf.region_vbscf(i_reg) = tmp; % Vbscf Region
                    surv_out_obj.regionSumVbscf.vbscf_values{i_reg} = regCellIntSub.Sv_mean_lin_esp2; %
                    
                    %% Region echo integral for Transect Summary
                    eint =eint + nansum(nansum(regCellIntSub.Sa_lin(:)));
                    
                end%end of regions iteration for this file
            end%end of layer iteration for this transect
            
            gps_tot=layers(idx_lay(1)).Transceivers(idx_freq).GPSDataPing;
            bot_tot=layers(idx_lay(1)).Transceivers(idx_freq).Bottom;
            dist_tot = m_lldist([gps_tot.Long(1) gps_tot.Long(end)],[gps_tot.Lat(1) gps_tot.Lat(end)])/1.852;% get distance as esp2 does... Straigth line estimate
            time_s_tot = gps_tot.Time(1);
            time_e_tot = gps_tot.Time(end);
            timediff_tot = (time_e_tot-time_s_tot)*24;
            if length(idx_lay)>1
                for i=2:length(idx_lay)
                    idx_freq=find_freq_idx(layers(idx_lay(i)),38000);
                    if layers(idx_lay(i)).Transceivers(idx_freq).GPSDataPing.Time(1)> gps_tot.Time(end)
                        bot_tot=concatenate_Bottom(bot_tot,layers(idx_lay(i)).Transceivers(idx_freq).Bottom);
                    else
                        bot_tot=concatenate_Bottom(layers(idx_lay(i)).Transceivers(idx_freq).Bottom,bot_tot);
                    end
                    gps_add=layers(idx_lay(i)).Transceivers(idx_freq).GPSDataPing;
                    gps_tot=concatenate_GPSData(gps_tot,gps_add);
                    
                    dist_tot = dist_tot+m_lldist([gps_add.Long(1) gps_add.Long(end)],[gps_add.Lat(1) gps_add.Lat(end)])/1.852;
                    time_s_add = gps_add.Time(1);
                    time_e_add = gps_add.Time(end);
                    timediff_add = (time_e_add-time_s_add)*24;
                    timediff_tot=timediff_add+timediff_tot;
                end
            end
            
            gps_tot.Long(gps_tot.Long>180)=gps_tot.Long(gps_tot.Long>180)-360;
            
            
            
            idx_pings=1:length(gps_tot.Time);
            idx_good_pings=intersect(idx_pings,find(bot_tot.Tag>0));
            
            av_speed_tot=dist_tot/timediff_tot;
            good_bot_tot=nanmean(bot_tot.Range(idx_good_pings));
            %% Transect Summary
            surv_out_obj.transectSum.snapshot(i_trans) = snap_num;
            surv_out_obj.transectSum.stratum{i_trans} = strat_name;
            surv_out_obj.transectSum.transect(i_trans) = trans_num;
            surv_out_obj.transectSum.dist(i_trans) = dist_tot;
            surv_out_obj.transectSum.mean_d(i_trans) = nanmean(good_bot_tot); % mean_d
            surv_out_obj.transectSum.pings(i_trans) = length(idx_good_pings); % pings %
            surv_out_obj.transectSum.av_speed(i_trans) = av_speed_tot; % av_speed
            surv_out_obj.transectSum.start_lat(i_trans) = gps_tot.Lat(1); % start_lat
            surv_out_obj.transectSum.start_lon(i_trans) = gps_tot.Long(1); % start_lon
            surv_out_obj.transectSum.finish_lat(i_trans) = gps_tot.Lat(end); % finish_lat
            surv_out_obj.transectSum.finish_lon(i_trans) = gps_tot.Long(end); % finish_lon
            surv_out_obj.transectSum.time_start(i_trans) = gps_tot.Time(1); % finish_lat
            surv_out_obj.transectSum.time_end(i_trans) = gps_tot.Time(end); % finish_lon
            surv_out_obj.transectSum.vbscf(i_trans) = eint/(surv_out_obj.transectSum.mean_d(i_trans)*surv_out_obj.transectSum.pings(i_trans)); % vbscf according to Esp2 formula
            surv_out_obj.transectSum.abscf(i_trans) = eint/surv_out_obj.transectSum.pings(i_trans); % abscf according to Esp2 formula
            
           %Tracks/ST transect summary
            surv_out_obj.transectSumTracks.snapshot(i_trans) = snap_num;
            surv_out_obj.transectSumTracks.stratum{i_trans} = strat_name;
            surv_out_obj.transectSumTracks.transect(i_trans) = trans_num;
            surv_out_obj.transectSumTracks.nb_st(i_trans) = nb_st;
            surv_out_obj.transectSumTracks.nb_tracks(i_trans) = nb_tracks;
            surv_out_obj.transectSumTracks.lat_track{i_trans}=lat_track;
            surv_out_obj.transectSumTracks.lon_track{i_trans}=lon_track;
            surv_out_obj.transectSumTracks.time_track{i_trans}=time_track;
            surv_out_obj.transectSumTracks.depth_track{i_trans}=depth_track;
            surv_out_obj.transectSumTracks.TS_mean_track{i_trans}=TS_mean_track;
            surv_out_obj.transectSumTracks.ping_num_track{i_trans}=ping_num_track;
            
            
            
            %% Sliced Transect Summary
            surv_out_obj.slicedTransectSum.snapshot(i_trans) = snap_num;
            surv_out_obj.slicedTransectSum.stratum{i_trans} = strat_name;
            surv_out_obj.slicedTransectSum.transect(i_trans) = trans_num;
            surv_out_obj.slicedTransectSum.slice_size(i_trans) = nanmean([Output_echo(:).slice_size]); % slice_size
            surv_out_obj.slicedTransectSum.num_slices(i_trans) = nansum([Output_echo(:).num_slices]); % num_slices
            surv_out_obj.slicedTransectSum.latitude{i_trans} = [Output_echo(:).slice_lat_esp2]; % latitude
            surv_out_obj.slicedTransectSum.longitude{i_trans} = [Output_echo(:).slice_lon_esp2]; % longitude
            surv_out_obj.slicedTransectSum.time_start{i_trans} = [Output_echo(:).slice_time_start]; %
            surv_out_obj.slicedTransectSum.time_end{i_trans} = [Output_echo(:).slice_time_end]; %
            surv_out_obj.slicedTransectSum.longitude{i_trans}(surv_out_obj.slicedTransectSum.longitude{i_trans}>180)=surv_out_obj.slicedTransectSum.longitude{i_trans}(surv_out_obj.slicedTransectSum.longitude{i_trans}>180)-360;
            surv_out_obj.slicedTransectSum.slice_abscf{i_trans} = [Output_echo(:).slice_abscf]; % slice_abscf
            surv_out_obj.slicedTransectSum.slice_nb_tracks{i_trans} = [Output_echo(:).slice_nb_tracks];
            surv_out_obj.slicedTransectSum.slice_nb_st{i_trans} = [Output_echo(:).slice_nb_st];
            
        end
    end%end of transect iteration for this stratum
end

%% Stratum Summary (1st mbs Output block)

for isn = 1:length(snap_vec)
    % loop over all snapshots and get Data subset
    ix = find(surv_out_obj.transectSum.snapshot==snap_vec(isn));
    strats = unique(surv_out_obj.transectSum.stratum(ix));
    
    for j = 1:length(strats)
        % loop over all strata and get Data subset
        jx = strcmpi(surv_out_obj.transectSum.stratum(ix), strats{j});
        idx=ix(jx);
        
        surv_out_obj.stratumSum.snapshot(j) =surv_out_obj.transectSum.snapshot(ix(1));
        surv_out_obj.stratumSum.stratum{j} =surv_out_obj.transectSum.stratum{ix(1)};
        surv_out_obj.stratumSum.time_start(j) = nanmin(surv_out_obj.transectSum.time_start(idx));
        surv_out_obj.stratumSum.time_end(j) = nanmin(surv_out_obj.transectSum.time_end(idx));
        surv_out_obj.stratumSum.no_transects(j) = length(surv_out_obj.transectSum.transect(idx));
        sum_abscf=nansum(surv_out_obj.transectSum.abscf(idx));
        surv_out_obj.stratumSum.abscf_mean(j) =sum_abscf/surv_out_obj.stratumSum.no_transects(j) ;
        sum_sq_abscf=nansum((surv_out_obj.transectSum.abscf(idx)).^2);
        
        dist=surv_out_obj.transectSum.dist(idx);
        trans_abscf=surv_out_obj.transectSum.abscf(idx);
        abscf_mean_j=surv_out_obj.stratumSum.abscf_mean(j);
        
        nb_trans_j=surv_out_obj.stratumSum.no_transects(j);
        
        if surv_out_obj.stratumSum.no_transects(j)>1
            surv_out_obj.stratumSum.abscf_sd(j) = sqrt((sum_sq_abscf-abscf_mean_j.^2.*nb_trans_j)/(nb_trans_j-1)); %
        else
            surv_out_obj.stratumSum.abscf_sd(j)=0;
        end
        
        surv_out_obj.stratumSum.abscf_wmean(j) = nansum(dist.*trans_abscf)/...
            nansum(dist); % abscf_wmean according to esp2 formula
        abscf_wmean_j=surv_out_obj.stratumSum.abscf_wmean(j);
        
        if nb_trans_j>1
            surv_out_obj.stratumSum.abscf_var(j) = nb_trans_j*(nansum(dist.^2.*trans_abscf.^2)-2*abscf_wmean_j*nansum(dist.^2.*trans_abscf)+abscf_wmean_j^2*nansum(dist.^2))...
                /((nb_trans_j-1)*nansum(dist.^2)); % abscf_var according to esp2 formula
        else
            surv_out_obj.stratumSum.abscf_var(j)=0;
        end
    end
    surv_obj.SurvOutput=surv_out_obj;
end





end

function [nb_snap,nb_strat,nb_trans]=get_num_trans(snap,strat,trans)
snap_un=unique(snap);
nb_snap=length(snap_un);
nb_strat=zeros(1,nb_snap);
for is=1:nb_snap
    curr_snap=snap_un(is);
    strat_snap=unique(strat(snap==curr_snap));
    nb_strat(is)=length(strat_snap);
    for ist=1:nb_strat(is)
        nb_trans(is,ist)=length(unique(trans(strcmp(strat,strat_snap(ist)))));
    end
end
end

