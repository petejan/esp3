%% generate_output_v2.m
%
% Key function for integration of surveys. Everything happens here. It
% needs cleaning, commenting and the output needs to be optimized.
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |surv_obj|: TODO: write description and info on variable
% * |layers|: TODO: write description and info on variable
% * |PathToResults|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel). 
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function generate_output_v2(surv_obj,layers,varargin)

p = inputParser;

addRequired(p,'surv_obj',@(obj) isa(obj,'survey_cl'));
addRequired(p,'layers',@(obj) isa(obj,'layer_cl')||isempty(obj));
addParameter(p,'PathToResults',pwd,@ischar);
addParameter(p,'load_bar_comp',[]);
parse(p,surv_obj,layers,varargin{:});


surv_in_obj=surv_obj.SurvInput;

vert_slice = surv_in_obj.Options.Vertical_slice_size;
vert_slice_units = surv_in_obj.Options.Vertical_slice_units;
horz_slice = surv_in_obj.Options.Horizontal_slice_size;

output=layers.list_layers_survey_data();

[snaps,strat,trans,regs_trans]=surv_in_obj.merge_survey_input_for_integration();

[~,~,strat_vec_num]=unique(strat);
strat_couple=unique([snaps(:)';strat_vec_num(:)']','rows');
trans_triple=unique([snaps(:)';strat_vec_num(:)';trans(:)']','rows');

reg_nb_vec=cellfun(@length,regs_trans);
surv_out_obj=survey_output_cl(size(strat_couple,1),size(trans_triple,1),nansum(reg_nb_vec));

snap_temp=[surv_in_obj.Snapshots{:}];
folders={snap_temp.Folder};
reg_descr_table=[];
idx_lay_processed=[];
i_trans=0;
i_reg=0;

fprintf('\n----------------Integration-----------------\n');
for isn=1:length(snaps)
    try
    snap_num=snaps(isn);
    strat_name=strat{isn};
    trans_num=trans(isn);
    regs_tmp=regs_trans{isn};
    
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
        trans_obj=layer_obj_tr.get_trans(surv_in_obj.Options.Frequency);
        [perc_temp,nb_ping_temp]=trans_obj.get_badtrans_perc();
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
        trans_obj=layer_obj_tr.get_trans(surv_in_obj.Options.Frequency);
        tag_add=trans_obj.Bottom.Tag;
        bot_depth_add=trans_obj.get_bottom_depth();
        gps_add=trans_obj.GPSDataPing;
        
        if i>1
            gps_tot=concatenate_GPSData(gps_tot,gps_add);
        else
            gps_tot=gps_add;
        end
        
        gps_add.Long(gps_add.Long>180)=gps_add.Long(gps_add.Long>180)-360;
        idx_pings=1:length(gps_add.Time);
        idx_in_transect=find(gps_add.Time(:)>=nanmin(output.StartTime(idx_lay(i)))&gps_add.Time(:)<=nanmax(output.EndTime(idx_lay(i))));
        idx_good_pings_add=intersect(idx_pings,idx_in_transect);
        idx_good_pings_add=intersect(idx_good_pings_add,find(tag_add(:)>0));
        idx_good_pings_dist=intersect(idx_good_pings_add,find(~isnan(gps_add.Lat(:))));
        
        if ~isempty(idx_good_pings_dist)
           [dist_km,timediff]=gps_add.get_straight_dist_and_time_diff(idx_good_pings_dist);
           dist_add=dist_km/1.852;
        else
            dist_add=0;
            timediff=0;
        end
        
        dist_tot=dist_tot+dist_add;
        timediff_tot=timediff_tot+timediff;
        nb_good_pings=nb_good_pings+length(idx_good_pings_add);
        mean_bot(i)=nanmean(bot_depth_add);
        mean_bot_w=mean_bot_w+mean_bot(i)*length(idx_good_pings_add);
        av_speed(i)=dist_add/timediff;
        idx_good_pings=union(idx_good_pings,idx_good_pings_add+iping0);
        iping0=length(idx_pings);
    end
    
    if isempty(idx_good_pings)
        warning('    No good pings in Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
        continue;
    end
    
    av_speed_tot=dist_tot/timediff_tot;
    
    good_bot_tot=mean_bot_w/nb_good_pings;
    
    ir=0;
    for ilay=idx_lay
        ir=ir+1;
        layer_obj_tr=layers(output.Layer_idx(ilay));
        [trans_obj_tr,idx_freq_main]=layer_obj_tr.get_trans(surv_in_obj.Options.Frequency);
        [idx_freq_sec,found]=layer_obj_tr.find_freq_idx(surv_in_obj.Options.FrequenciesToLoad);
        idx_freq_sec(found==0)=[];
        idx_freq_sec=union(idx_freq_sec,idx_freq_main);
        
        gps=trans_obj_tr.GPSDataPing;
        gps.Long(gps.Long>180)=gps.Long(gps.Long>180)-360;
 
        if isnan(good_bot_tot)
            depth=trans_obj_tr.get_transceiver_depth([],[]);
            good_bot_tot= nanmax(depth(:));
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
        
        reg_tot=trans_obj_tr.get_reg_specs_to_integrate(regs_tmp);
        
        
        if isempty(reg_tot)
            reg_tot=struct('name','','id',nan,'unique_id',nan,'startDepth',nan,'finishDepth',nan,'startSlice',nan,'finishSlice',nan);
        end
        
        if ~isempty(~strcmp({reg_tot(:).id},''))
            idx_reg=trans_obj_tr.find_regions_Unique_ID({reg_tot(:).id});
        else
            idx_reg=[];
        end
       
        
        %%%%%%%%%%Transect Integration%%%%%%%%
%         profile on;
        [output_2D_surf_t,output_2D_bot_t,regs_t,regCellInt_t,reg_descr_table_n,output_2D_sh_t,shadow_height_est_t,idx_freq_out_tot]=layer_obj_tr.multi_freq_slice_transect2D(...
            'idx_main_freq',idx_freq_main,...
            'idx_sec_freq',idx_freq_sec,...
            'Slice_w',vert_slice,'Slice_w_units',vert_slice_units,...
            'Slice_h',horz_slice,...
            'StartTime',output.StartTime(ilay),'EndTime',output.EndTime(ilay),...
            'Denoised',surv_in_obj.Options.Denoised,...
            'Motion_correction',surv_in_obj.Options.Motion_correction,...
            'Shadow_zone',surv_in_obj.Options.Shadow_zone,...
            'Shadow_zone_height',surv_in_obj.Options.Shadow_zone_height,...
            'DepthMin',surv_in_obj.Options.DepthMin,...
            'DepthMax',surv_in_obj.Options.DepthMax,...
            'RegInt',1,...
            'Remove_ST',surv_in_obj.Options.Remove_ST,...
            'idx_regs',idx_reg,'load_bar_comp',p.Results.load_bar_comp,...
            'sv_thr',surv_in_obj.Options.SvThr);
        %%%%%%%%%%
%         profile off;
%         profile viewer;
        
        idx_f=idx_freq_main==idx_freq_out_tot;
        output_2D_surf=output_2D_surf_t{idx_f};
        output_2D_bot=output_2D_bot_t{idx_f};
        output_2D_sh=output_2D_sh_t{idx_f};
        regCellInt=regCellInt_t{idx_f};
        regs=regs_t{idx_f};
        shadow_height_est=shadow_height_est_t{idx_f};
        
        if isempty(output_2D_surf)&&isempty(output_2D_bot)
             warning('Nothing to integrate in Snapshot %.0f Stratum %s Transect %d in layer %d\n',snap_num,strat_name,trans_num,ilay);
            continue;
        end
        
        if ~isempty(output_2D_surf)
            num_slice=size(output_2D_surf.eint,2);
        else
            num_slice=size(output_2D_bot.eint,2);
        end
             
        if ~isempty(output_2D_surf) 
            surf_slice_int=nansum(output_2D_surf.eint);
            good_pings_surf=nanmax(output_2D_surf.Nb_good_pings,[],1);
        end
        
        if ~isempty(output_2D_bot)
            bot_slice_int=nansum(output_2D_bot.eint);
            good_pings_bot=nanmax(output_2D_bot.Nb_good_pings,[],1);
        else
            bot_slice_int=zeros(1,num_slice);
            good_pings_bot=[];
        end
        
        if ~isempty(output_2D_sh)
            sh_slice_int=nansum(output_2D_sh.eint).*shadow_height_est/surv_in_obj.Options.Shadow_zone_height;
            good_pings_sh=nanmax(output_2D_sh.Nb_good_pings,[],1);
        else
            sh_slice_int=zeros(1,num_slice);
            good_pings_sh=[];
        end
        %reg_descr_table=[reg_descr_table;reg_descr_table_n];
        reg_descr_table=[reg_descr_table;reg_descr_table_n];
     
        if  surv_in_obj.Options.ExportSlicedTransects>0   
             
            if ~isempty(output_2D_surf)
                outputFileXLS = fullfile(p.Results.PathToResults,sprintf('%s_snap_%d_strat_%s_trans_%d_%d_surf.csv',surv_in_obj.Infos.Title,snap_num,strat_name,trans_num,ir));   
                if exist(outputFileXLS,'file')>0
                    delete(outputFileXLS);
                end
                
                reg_output_table=reg_output_to_table(output_2D_surf);
                writetable(reg_output_table,outputFileXLS);
            end
            
            if ~isempty(output_2D_bot)
                outputFileXLS = fullfile(p.Results.PathToResults,sprintf('%s_snap_%d_strat_%s_trans_%d_%d_bot.csv',surv_in_obj.Infos.Title,snap_num,strat_name,trans_num,ir));
                if exist(outputFileXLS,'file')>0
                    delete(outputFileXLS);
                end
                reg_output_table=reg_output_to_table(output_2D_bot);
                writetable(reg_output_table,outputFileXLS);
            end
            
            if ~isempty(output_2D_sh)
                outputFileXLS = fullfile(p.Results.PathToResults,sprintf('%s_snap_%d_strat_%s_trans_%d_%d_sh.csv',surv_in_obj.Infos.Title,snap_num,strat_name,trans_num,ir));
            if exist(outputFileXLS,'file')>0
                delete(outputFileXLS);
            end
                reg_output_table=reg_output_to_table(output_2D_sh);
                writetable(reg_output_table,outputFileXLS);
            end
        end
        
        good_pings=nanmax([good_pings_sh;good_pings_bot;good_pings_surf],[],1);     
        

        sliced_output.slice_abscf=(surf_slice_int+bot_slice_int)./good_pings;
        sliced_output.slice_abscf(isnan(sliced_output.slice_abscf))=0;
        sliced_output.slice_size=vert_slice;
        sliced_output.num_slices=num_slice;
        sliced_output.shadow_zone_slice_abscf=sh_slice_int./good_pings;
        sliced_output.shadow_zone_slice_abscf(isnan(sliced_output.shadow_zone_slice_abscf))=0;
        
        sliced_output.slice_lat=output_2D_surf.Lat_S;
        sliced_output.slice_lon=output_2D_surf.Lon_S;
        sliced_output.slice_lat_s=output_2D_surf.Lat_S;
        sliced_output.slice_lon_s=output_2D_surf.Lon_S;
        sliced_output.slice_lat_e=output_2D_surf.Lat_E;
        sliced_output.slice_lon_e=output_2D_surf.Lon_E;
        
        sliced_output.slice_time_start=output_2D_surf.Time_S;
        sliced_output.slice_time_end=output_2D_surf.Time_E;
        sliced_output.slice_nb_tracks=zeros(size(good_pings));
        sliced_output.slice_nb_st=zeros(size(good_pings));

            
        Output_echo=[Output_echo sliced_output];

        clear sliced_output;
        for j=1:length(regs)
            
            reg_curr =regs{j};
            regCellInt_r=regCellInt{j};
            if isempty(regCellInt_r)
               continue; 
            end
            
            if nansum(nansum(nansum(regCellInt_r.eint)))==0
                continue; 
            end
            
            i_reg=i_reg+1;
            startPing = regCellInt_r.Ping_S(1);
            stopPing = regCellInt_r.Ping_E(end);
            ix = (startPing:stopPing);
            ix_good=intersect(ix,find(trans_obj_tr.Bottom.Tag>0));
            
            
            switch reg_curr.Reference
                case 'Surface'
                      refType = 's';
                    if~isnan(nanmin(regCellInt_r.Sample_S(:)))&&~isnan(nanmin(regCellInt_r.Ping_S(:)))
                        start_d = trans_obj_tr.get_transceiver_depth(nanmin(regCellInt_r.Sample_S(:)),nanmin(regCellInt_r.Ping_S(:)));
                    else
                        start_d=0;
                    end
                    if~isnan(nanmin(regCellInt_r.Sample_S(:)))&&~isnan(nanmax(regCellInt_r.Ping_E(:)))
                        finish_d = trans_obj_tr.get_transceiver_depth(nanmin(regCellInt_r.Sample_S(:)),nanmax(regCellInt_r.Ping_S(:)));
                    else
                        finish_d=0;
                    end
                case 'Bottom'
                    refType = 'b';
                    start_d = 0;
                    finish_d = 0;
            end
            
            
            surv_out_obj.regionsIntegrated.snapshot(i_reg)=snap_num;
            surv_out_obj.regionsIntegrated.stratum{i_reg}=strat_name;
            surv_out_obj.regionsIntegrated.transect(i_reg)=trans_num;
            surv_out_obj.regionsIntegrated.file{i_reg}=layer_obj_tr.Filename;
            surv_out_obj.regionsIntegrated.Region{i_reg}=reg_curr;
            surv_out_obj.regionsIntegrated.RegOutput{i_reg}=regCellInt_r;
            
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
            surv_out_obj.regionSum.time_end(i_reg)=regCellInt_r.Time_E(end);
            surv_out_obj.regionSum.time_start(i_reg)=regCellInt_r.Time_S(1);
            surv_out_obj.regionSum.ref{i_reg}=refType;
            surv_out_obj.regionSum.slice_size(i_reg)=reg_curr.Cell_h;
            surv_out_obj.regionSum.good_pings(i_reg)=length(ix_good);
            surv_out_obj.regionSum.start_d(i_reg)= start_d;
            surv_out_obj.regionSum.mean_d(i_reg)=mean_bot(ir);
            surv_out_obj.regionSum.finish_d(i_reg)=finish_d;
            surv_out_obj.regionSum.av_speed(i_reg)=av_speed(ir);
            surv_out_obj.regionSum.vbscf(i_reg)= nansum(nansum(regCellInt_r.eint))./nansum(nansum(regCellInt_r.Nb_good_pings.*regCellInt_r.Thickness_tot));
            surv_out_obj.regionSum.abscf(i_reg)= nansum(nansum(regCellInt_r.eint))./nansum(nanmax(regCellInt_r.Nb_good_pings));%Abscf Region
            surv_out_obj.regionSum.tag{i_reg}=reg_curr.Tag;
            
            %% Region Summary (abscf by vertical slice) (5th Mbs Output Block)
            surv_out_obj.regionSumAbscf.time_end{i_reg}=regCellInt_r.Time_E(end);
            surv_out_obj.regionSumAbscf.time_start{i_reg}=regCellInt_r.Time_S(1);
            surv_out_obj.regionSumAbscf.num_v_slices(i_reg)=size(regCellInt_r.eint,2);
            surv_out_obj.regionSumAbscf.transmit_start{i_reg} = regCellInt_r.Ping_S; % transmit Start vertical slice
            surv_out_obj.regionSumAbscf.latitude{i_reg} = regCellInt_r.Lat_S; % lat vertical slice
            surv_out_obj.regionSumAbscf.longitude{i_reg} = regCellInt_r.Lon_S; % lon vertical slice
            surv_out_obj.regionSumAbscf.column_abscf{i_reg} = nansum(regCellInt_r.eint)./nanmax(regCellInt_r.Nb_good_pings);%sum up all abcsf per vertical slice
            
            %% Region vbscf (6th Mbs Output Block)
            surv_out_obj.regionSumVbscf.time_end{i_reg}=regCellInt_r.Time_E;
            surv_out_obj.regionSumVbscf.time_start{i_reg}=regCellInt_r.Time_S;
            surv_out_obj.regionSumVbscf.num_h_slices(i_reg) = size(regCellInt_r.Sv_mean_lin,1);% num_h_slices
            surv_out_obj.regionSumVbscf.num_v_slices(i_reg) = size(regCellInt_r.Sv_mean_lin,2); % num_v_slices
            tmp=surv_out_obj.regionSum.vbscf(i_reg);
            tmp(isnan(tmp))=0;
            surv_out_obj.regionSumVbscf.region_vbscf(i_reg) = tmp; % Vbscf Region
            surv_out_obj.regionSumVbscf.vbscf_values{i_reg} = regCellInt_r.Sv_mean_lin; %
            
            %% Region echo integral for Transect Summary
            eint =eint + nansum(regCellInt_r.eint(:));

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
    surv_out_obj.transectSum.shadow_zone_abscf(i_trans)=nansum([Output_echo(:).shadow_zone_slice_abscf])/surv_out_obj.transectSum.pings(i_trans);
    surv_out_obj.transectSum.tot_pings(i_trans)=numel(gps_tot.Lat);
    
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
    surv_out_obj.slicedTransectSum.latitude{i_trans} = [Output_echo(:).slice_lat_s]; % latitude
    surv_out_obj.slicedTransectSum.longitude{i_trans} = [Output_echo(:).slice_lon_s]; % longitude
    
    surv_out_obj.slicedTransectSum.latitude_e{i_trans} = [Output_echo(:).slice_lat_e]; % latitude
    surv_out_obj.slicedTransectSum.longitude_e{i_trans} = [Output_echo(:).slice_lon_e]; % longitude
   
    surv_out_obj.slicedTransectSum.longitude{i_trans}(surv_out_obj.slicedTransectSum.longitude{i_trans}>180)=surv_out_obj.slicedTransectSum.longitude{i_trans}(surv_out_obj.slicedTransectSum.longitude{i_trans}>180)-360;
    surv_out_obj.slicedTransectSum.longitude_e{i_trans}(surv_out_obj.slicedTransectSum.longitude_e{i_trans}>180)=surv_out_obj.slicedTransectSum.longitude_e{i_trans}(surv_out_obj.slicedTransectSum.longitude_e{i_trans}>180)-360;
    
    surv_out_obj.slicedTransectSum.time_start{i_trans} = [Output_echo(:).slice_time_start]; %
    surv_out_obj.slicedTransectSum.time_end{i_trans} = [Output_echo(:).slice_time_end]; %
    surv_out_obj.slicedTransectSum.slice_abscf{i_trans} = [Output_echo(:).slice_abscf]; % slice_abscf
    surv_out_obj.slicedTransectSum.slice_nb_tracks{i_trans} = [Output_echo(:).slice_nb_tracks];
    surv_out_obj.slicedTransectSum.slice_nb_st{i_trans} = [Output_echo(:).slice_nb_st];
    slice_shadow_zone_abscf_temp=[Output_echo(:).shadow_zone_slice_abscf];
    slice_shadow_zone_abscf_temp(surv_out_obj.slicedTransectSum.slice_abscf{i_trans}==0)=0;
    surv_out_obj.slicedTransectSum.slice_shadow_zone_abscf{i_trans}=slice_shadow_zone_abscf_temp;
    catch err        
        warning('    Could not Integrate Snapshot %.0f Stratum %s Transect %d\n',snap_num,strat_name,trans_num);
        [~,f_temp,e_temp]=fileparts(err.stack(1).file);
        fprintf('Error in file %s, line %d\n',[f_temp e_temp],err.stack(1).line);
        disp(err.message);
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
        
        

        jx = strcmpi(surv_out_obj.transectSum.stratum(ix), strats{j});
        idx=ix(jx);
        
        [design,radius]=surv_in_obj.get_start_design_and_radius(snapshots(isn),strats{j});
        i_trans_strat=find(surv_out_obj.slicedTransectSum.snapshot==snapshots(isn)&strcmp(strats{j},surv_out_obj.slicedTransectSum.stratum)); 
        il=0;
        slice_trans_obj=surv_out_obj.slicedTransectSum;
        switch design
            case 'hill'
                [~,~,lat_trans,long_trans] = find_centre(slice_trans_obj.latitude(i_trans_strat),...
                    slice_trans_obj.longitude(i_trans_strat));
               
                for it=i_trans_strat
                     il=il+1; 
                    [surv_out_obj.slicedTransectSum.slice_hill_weight{it},~,~]=compute_slice_weight_hills(...
                        slice_trans_obj.latitude{it},slice_trans_obj.longitude{it},...
                        slice_trans_obj.latitude_e{it},slice_trans_obj.longitude_e{it},...
                        lat_trans(il),long_trans(il),radius);
                end
            otherwise
                 for it=i_trans_strat
                     il=il+1; 
                    surv_out_obj.slicedTransectSum.slice_hill_weight{it}=zeros(size(surv_out_obj.slicedTransectSum.latitude{it}));
                end
        end
        
        surv_out_obj.stratumSum.snapshot(i_strat) =surv_out_obj.transectSum.snapshot(idx(1));
        surv_out_obj.stratumSum.stratum{i_strat} =surv_out_obj.transectSum.stratum{idx(1)};
        surv_out_obj.stratumSum.time_start(i_strat) = nanmin(surv_out_obj.transectSum.time_start(idx));
        surv_out_obj.stratumSum.time_end(i_strat) = nanmax(surv_out_obj.transectSum.time_end(idx));
        surv_out_obj.stratumSum.no_transects(i_strat) = length(surv_out_obj.transectSum.transect(idx));

        dist=surv_out_obj.transectSum.dist(idx);
        trans_abscf=surv_out_obj.transectSum.abscf(idx);
        trans_abscf_with_shz=trans_abscf+surv_out_obj.transectSum.shadow_zone_abscf(idx);

        [surv_out_obj.stratumSum.abscf_mean(i_strat),surv_out_obj.stratumSum.abscf_sd(i_strat)]=calc_abscf_and_sd(trans_abscf);
        [surv_out_obj.stratumSum.abscf_wmean(i_strat),surv_out_obj.stratumSum.abscf_var(i_strat)]=calc_weighted_abscf_and_var(trans_abscf,dist);
        
        [surv_out_obj.stratumSum.abscf_with_shz_mean(i_strat),surv_out_obj.stratumSum.abscf_with_shz_sd(i_strat)]=calc_abscf_and_sd(trans_abscf_with_shz);
        [surv_out_obj.stratumSum.abscf_with_shz_wmean(i_strat),surv_out_obj.stratumSum.abscf_with_shz_var(i_strat)]=calc_weighted_abscf_and_var(trans_abscf_with_shz,dist);
        
        
    end
end
surv_obj.SurvOutput=surv_out_obj;

surv_obj.clean_output();

if surv_in_obj.Options.ExportRegions>0&&~isempty(reg_descr_table)
    outputFileXLS = fullfile(p.Results.PathToResults,[surv_obj.SurvInput.Infos.Title '_reg_descriptors.csv']);
    if exist(outputFileXLS,'file')>1
        delete(outputFileXLS);
    end
    writetable(reg_descr_table,outputFileXLS);
end
        

end




