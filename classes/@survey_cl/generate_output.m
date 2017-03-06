function generate_output(surv_obj,layers,varargin)

p = inputParser;

addRequired(p,'surv_obj',@(obj) isa(obj,'survey_cl'));
addRequired(p,'layers',@(obj) isa(obj,'layer_cl')||isempty(obj));
addParameter(p,'PathToMemmap','',@ischar);
parse(p,surv_obj,layers,varargin{:});


surv_in_obj=surv_obj.SurvInput;

vert_slice = surv_in_obj.Options.Vertical_slice_size;
vert_slice_units = surv_in_obj.Options.Vertical_slice_units;

output=layers.list_layers_survey_data();

[snaps,strat,trans,regs_trans]=surv_in_obj.merge_survey_input_for_integration();
[~,~,strat_vec_num]=unique(strat);
strat_couple=unique([snaps(:)';strat_vec_num(:)']','rows');
trans_triple=unique([snaps(:)';strat_vec_num(:)';trans(:)']','rows');

reg_nb_vec=cellfun(@length,regs_trans);
surv_out_obj=survey_output_cl(size(strat_couple,1),size(trans_triple,1),nansum(reg_nb_vec));

snap_temp=[surv_in_obj.Snapshots{:}];
folders={snap_temp.Folder};

idx_lay_processed=[];
i_trans=0;
i_reg=0;

fprintf('\n----------------Integration-----------------\n');
for isn=1:length(snaps)
    try
    snap_num=snaps(isn);
    strat_name=strat{isn};
    trans_num=trans(isn);
    regs_t=regs_trans{isn};
    
    fprintf('Integrating Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num); 
    i_trans=i_trans+1;
    idx_lay=find(trans_num==output.Transect&snap_num==output.Snapshot&strcmpi(strat_name,output.Stratum)&cellfun(@(x) any(strcmpi(x,fullfile(folders,'\'))),fullfile(output.Folder,'\')));
 
    if isempty(idx_lay)
        warning('    Could not find layers for Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
        continue;
    end
    
    idx_lay=setdiff(idx_lay,idx_lay_processed);
    idx_lay_processed=union(idx_lay_processed,idx_lay);
    
    if isempty(idx_lay)
        fprintf('     Already integrated\n');
        continue;
    end
    
    nb_bad_trans=0;
    nb_ping_tot=0;
    for i_test_bt=idx_lay
        layer_obj_tr=layers(output.Layer_idx(i_test_bt));
        idx_freq=layer_obj_tr.find_freq_idx(surv_in_obj.Options.Frequency);
        [perc_temp,nb_ping_temp]=layer_obj_tr.Transceivers(idx_freq).get_badtrans_perc();
        nb_bad_trans=nb_bad_trans+nb_ping_temp*perc_temp/100;
        nb_ping_tot=nb_ping_tot+nb_ping_temp;
    end
    
    if nb_bad_trans/nb_ping_tot>surv_in_obj.Options.BadTransThr/100
        fprintf('    Too much bad pings on Snapshot %.0f Stratum %s Transect %d. Removing it.\n',snap_num,strat_name,trans_num);
        continue;
    end
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
    
    dist_tot=0;
    timediff_tot=0;
    nb_good_pings=0;
    mean_bot_w=0;
    mean_bot=nan(1,length(idx_lay));
    av_speed=nan(1,length(idx_lay));
    idx_good_pings=[];
    iping0=0;
    for i=1:length(idx_lay)
        layer_obj_tr=layers(output.Layer_idx(idx_lay(i)));
        idx_freq=find_freq_idx(layer_obj_tr,surv_in_obj.Options.Frequency);
        tag_add=layer_obj_tr.Transceivers(idx_freq).Bottom.Tag;
        bot_range_add=layer_obj_tr.Transceivers(idx_freq).get_bottom_range();
        gps_add=layer_obj_tr.Transceivers(idx_freq).GPSDataPing;
        
        if i>1
            gps_tot=concatenate_GPSData(gps_tot,gps_add);
        else
            gps_tot=gps_add;
        end
        
        gps_add.Long(gps_add.Long>180)=gps_add.Long(gps_add.Long>180)-360;
        idx_pings=1:length(gps_add.Time);
        idx_good_pings_add=intersect(idx_pings,find(tag_add(:)>0&gps_add.Time(:)>=nanmin(output.StartTime(idx_lay(:)))&gps_add.Time(:)<=nanmax(output.EndTime(idx_lay(:)))));
        idx_good_pings_dist=intersect(idx_good_pings_add,find(~isnan(gps_add.Lat(:))));
        
        if ~isempty(idx_good_pings_dist)
            dist_add=m_lldist([gps_add.Long(idx_good_pings_dist(1)) gps_add.Long(idx_good_pings_dist(end))],[gps_add.Lat(idx_good_pings_dist(1)) gps_add.Lat(idx_good_pings_dist(end))])/1.852;
            timediff=(gps_add.Time(idx_good_pings_dist(end))-gps_add.Time(idx_good_pings_dist(1)))*24;
        else
            dist_add=0;
            timediff=0;
        end
        dist_tot=dist_tot+dist_add;
        timediff_tot=timediff_tot+timediff;
        nb_good_pings=nb_good_pings+length(idx_good_pings_add);
        mean_bot(i)=nanmean(bot_range_add);
        mean_bot_w=mean_bot_w+mean_bot(i)*length(idx_good_pings_add);
        av_speed(i)=dist_add/timediff;
        idx_good_pings=union(idx_good_pings,idx_good_pings_add+iping0);
        iping0=length(idx_pings);
    end
    
    
    av_speed_tot=dist_tot/timediff_tot;
    
    good_bot_tot=mean_bot_w/nb_good_pings;
    
    ir=0;
    for ilay=idx_lay
        ir=ir+1;
        layer_obj_tr=layers(output.Layer_idx(ilay));
        idx_freq=layer_obj_tr.find_freq_idx(surv_in_obj.Options.Frequency);
        gps=layer_obj_tr.Transceivers(idx_freq).GPSDataPing;
        %bot=layer_obj_tr.Transceivers(idx_freq).Bottom;
        gps.Long(gps.Long>180)=gps.Long(gps.Long>180)-360;
        trans_obj_tr=layer_obj_tr.Transceivers(idx_freq);
        
        if isnan(good_bot_tot)
            good_bot_tot= trans_obj_tr.Data.Range(end);
        end
        
        if ~isempty(trans_obj_tr.ST.TS_comp)
            nb_st=nb_st+length(trans_obj_tr.ST.TS_comp);
        end
        
        if ~isempty(trans_obj_tr.Tracks)
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
            
            idx_time_out=output.StartTime(ilay)<time_track|time_track>output.EndTime(ilay);
            lat_track(idx_time_out)=[];
            lon_track(idx_time_out)=[];
            time_track(idx_time_out)=[];
            depth_track(idx_time_out)=[];
            ping_num_track(idx_time_out)=[];
            TS_mean_track(idx_time_out)=[];
            
        end
        
        reg_tot=trans_obj_tr.get_reg_specs_to_integrate(regs_t);
        
        [sliced_output,regs,regCellInt_tot]=trans_obj_tr.slice_transect('reg',reg_tot,'Slice_w',vert_slice,'Slice_units',vert_slice_units,'StartTime',output.StartTime(ilay),'EndTime',output.EndTime(ilay),'Denoised',surv_in_obj.Options.Denoised);
        %[sliced_output_2D,regCellInt_tot]=trans_obj.slice_transect2D,'Slice_w',vert_slice,'Slice_units','pings','StartTime',output.StartTime(ilay),'EndTime',output.EndTime(ilay));
        
        Output_echo=[Output_echo sliced_output];
        
        for j=1:length(regs)
            i_reg=i_reg+1;
            reg_curr =regs{j};
            regCellInt=regCellInt_tot{j};
            startPing = regCellInt.Ping_S(1);
            stopPing = regCellInt.Ping_E(end);
            ix = (startPing:stopPing);
            ix_good=intersect(ix,find(trans_obj_tr.Bottom.Tag>0));
            
            
            switch reg_curr.Reference
                case 'Surface';
                    refType = 's';
                    start_d = trans_obj_tr.get_transceiver_range(nanmin(regCellInt.Sample_S(:)));
                    finish_d = trans_obj_tr.get_transceiver_range(nanmin(regCellInt.Sample_S(:)));
                case 'Bottom';
                    refType = 'b';
                    start_d = 0;
                    finish_d = 0;
            end
            
            
            surv_out_obj.regionsIntegrated.snapshot(i_reg)=snap_num;
            surv_out_obj.regionsIntegrated.stratum{i_reg}=strat_name;
            surv_out_obj.regionsIntegrated.transect(i_reg)=trans_num;
            surv_out_obj.regionsIntegrated.file{i_reg}=layer_obj_tr.Filename;
            surv_out_obj.regionsIntegrated.Region{i_reg}=reg_curr;
            surv_out_obj.regionsIntegrated.RegOutput{i_reg}=regCellInt;
            
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
            surv_out_obj.regionSum.time_end(i_reg)=regCellInt.Time_E(end);
            surv_out_obj.regionSum.time_start(i_reg)=regCellInt.Time_S(1);
            surv_out_obj.regionSum.ref{i_reg}=refType;
            surv_out_obj.regionSum.slice_size(i_reg)=reg_curr.Cell_h;
            surv_out_obj.regionSum.good_pings(i_reg)=length(ix_good);
            surv_out_obj.regionSum.start_d(i_reg)= start_d;
            surv_out_obj.regionSum.mean_d(i_reg)=mean_bot(ir);
            surv_out_obj.regionSum.finish_d(i_reg)=finish_d;
            surv_out_obj.regionSum.av_speed(i_reg)=av_speed(ir);
            surv_out_obj.regionSum.vbscf(i_reg)= nansum(nansum(regCellInt.Sa_lin))./nansum(nansum(regCellInt.Nb_good_pings_esp2.*regCellInt.Thickness_esp2));
            surv_out_obj.regionSum.abscf(i_reg)= nansum(nansum(regCellInt.Sa_lin))./nansum(nanmax(regCellInt.Nb_good_pings_esp2));%Abscf Region
            surv_out_obj.regionSum.tag{i_reg}=reg_curr.Tag;
            
            %% Region Summary (abscf by vertical slice) (5th Mbs Output Block)
            surv_out_obj.regionSumAbscf.time_end{i_reg}=regCellInt.Time_E(end,:);
            surv_out_obj.regionSumAbscf.time_start{i_reg}=regCellInt.Time_S(1,:);
            surv_out_obj.regionSumAbscf.num_v_slices(i_reg)=size(regCellInt.Lat_S,2);
            surv_out_obj.regionSumAbscf.transmit_start{i_reg} = nanmax(regCellInt.Ping_S); % transmit Start vertical slice
            surv_out_obj.regionSumAbscf.latitude{i_reg} = nanmax(regCellInt.Lat_S); % lat vertical slice
            surv_out_obj.regionSumAbscf.longitude{i_reg} = nanmax(regCellInt.Lon_S); % lon vertical slice
            surv_out_obj.regionSumAbscf.column_abscf{i_reg} = nansum(regCellInt.Sa_lin)./nanmax(regCellInt.Nb_good_pings_esp2);%sum up all abcsf per vertical slice
            
            %% Region vbscf (6th Mbs Output Block)
            surv_out_obj.regionSumVbscf.time_end{i_reg}=regCellInt.Time_E;
            surv_out_obj.regionSumVbscf.time_start{i_reg}=regCellInt.Time_S;
            surv_out_obj.regionSumVbscf.num_h_slices(i_reg) = size(regCellInt.Sv_mean_lin_esp2,1);% num_h_slices
            surv_out_obj.regionSumVbscf.num_v_slices(i_reg) = size(regCellInt.Sv_mean_lin_esp2,2); % num_v_slices
            tmp=surv_out_obj.regionSum.vbscf(i_reg);
            tmp(isnan(tmp))=0;
            surv_out_obj.regionSumVbscf.region_vbscf(i_reg) = tmp; % Vbscf Region
            surv_out_obj.regionSumVbscf.vbscf_values{i_reg} = regCellInt.Sv_mean_lin_esp2; %
            
            %% Region echo integral for Transect Summary
            eint =eint + nansum(nansum(regCellInt.Sa_lin(:)));
            
        end%end of regions iteration for this file
    end%end of layer iteration for this transect
    
    
    
    %% Transect Summary
    idx_s=intersect(idx_good_pings,find(~isnan(gps_tot.Long)));
    surv_out_obj.transectSum.snapshot(i_trans) = snap_num;
    surv_out_obj.transectSum.stratum{i_trans} = strat_name;
    surv_out_obj.transectSum.transect(i_trans) = trans_num;
    surv_out_obj.transectSum.dist(i_trans) = dist_tot;
    surv_out_obj.transectSum.mean_d(i_trans) = nanmean(good_bot_tot); % mean_d
    surv_out_obj.transectSum.pings(i_trans) = length(idx_good_pings); % pings %
    surv_out_obj.transectSum.av_speed(i_trans) = av_speed_tot; % av_speed
    surv_out_obj.transectSum.start_lat(i_trans) = gps_tot.Lat(idx_s(1)); % start_lat
    surv_out_obj.transectSum.start_lon(i_trans) = gps_tot.Long(idx_s(1)); % start_lon
    surv_out_obj.transectSum.finish_lat(i_trans) = gps_tot.Lat(idx_s(end)); % finish_lat
    surv_out_obj.transectSum.finish_lon(i_trans) = gps_tot.Long(idx_s(end)); % finish_lon
    surv_out_obj.transectSum.time_start(i_trans) = gps_tot.Time(idx_s(1)); % finish_lat
    surv_out_obj.transectSum.time_end(i_trans) = gps_tot.Time(idx_s(end)); % finish_lon
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
    catch err
        disp(err.message);
        warning('    Could not Integrate Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
        continue;
    end
end


%% Stratum Summary (1st mbs Output block)

i_strat=0;

snapshots=unique(snaps);
for isn = 1:length(snapshots)
    % loop over all snapshots and get Data subset
    ix = find(surv_out_obj.transectSum.snapshot==snapshots(isn));
    strats = unique(surv_out_obj.transectSum.stratum(ix));
    
    for j = 1:length(strats)
        i_strat=i_strat+1;
        % loop over all strata and get Data subset
        jx = strcmpi(surv_out_obj.transectSum.stratum(ix), strats{j});
        idx=ix(jx);
        
        surv_out_obj.stratumSum.snapshot(i_strat) =surv_out_obj.transectSum.snapshot(idx(1));
        surv_out_obj.stratumSum.stratum{i_strat} =surv_out_obj.transectSum.stratum{idx(1)};
        surv_out_obj.stratumSum.time_start(i_strat) = nanmin(surv_out_obj.transectSum.time_start(idx));
        surv_out_obj.stratumSum.time_end(i_strat) = nanmin(surv_out_obj.transectSum.time_end(idx));
        surv_out_obj.stratumSum.no_transects(i_strat) = length(surv_out_obj.transectSum.transect(idx));
        sum_abscf=nansum(surv_out_obj.transectSum.abscf(idx));
        surv_out_obj.stratumSum.abscf_mean(i_strat) =sum_abscf/surv_out_obj.stratumSum.no_transects(i_strat) ;
        sum_sq_abscf=nansum((surv_out_obj.transectSum.abscf(idx)).^2);
        
        dist=surv_out_obj.transectSum.dist(idx);
        trans_abscf=surv_out_obj.transectSum.abscf(idx);
        abscf_mean_j=surv_out_obj.stratumSum.abscf_mean(i_strat);
        
        nb_trans_j=surv_out_obj.stratumSum.no_transects(i_strat);
        
        if surv_out_obj.stratumSum.no_transects(i_strat)>1
            %surv_out_obj.stratumSum.abscf_sd(i_strat) = sqrt((sum_sq_abscf-abscf_mean_j.^2.*nb_trans_j)/(nb_trans_j-1)); %
            surv_out_obj.stratumSum.abscf_sd(i_strat) = sqrt(nansum((trans_abscf-abscf_mean_j).^2)/(nb_trans_j-1)); %
        else
            surv_out_obj.stratumSum.abscf_sd(i_strat)=0;
        end
        
        surv_out_obj.stratumSum.abscf_wmean(i_strat) = nansum(dist.*trans_abscf)/...
            nansum(dist); % abscf_wmean according to esp2 formula
        abscf_wmean_j=surv_out_obj.stratumSum.abscf_wmean(i_strat);
        
        if nb_trans_j>1
            surv_out_obj.stratumSum.abscf_var(i_strat) = (nansum(dist.^2.*trans_abscf.^2)...
                -2*abscf_wmean_j*nansum(dist.^2.*trans_abscf)+...
                abscf_wmean_j^2*nansum(dist.^2))*...
                nb_trans_j/((nb_trans_j-1)*nansum(dist)^2); % abscf_var according to esp2 formula
        else
            surv_out_obj.stratumSum.abscf_var(i_strat)=0;
        end
        
    end
end
surv_obj.SurvOutput=surv_out_obj;

surv_obj.clean_output();

end



