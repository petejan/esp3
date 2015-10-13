
function regionSummary_v2(mbs,cvsroot,varargin) % Calculate

p = inputParser;

addRequired(p,'mbs',@(obj) isa(obj,'mbs_cl'));
addRequired(p,'cvsroot',@ischar);
addParameter(p,'datapath',pwd);
addParameter(p,'idx_trans',[]);
addParameter(p,'type','crest');
addParameter(p,'mode','normal');



parse(p,mbs,cvsroot,varargin{:});

cvsroot=p.Results.cvsroot;
datapath=p.Results.datapath;
idx_trans=p.Results.idx_trans;
type=p.Results.type;
mode=p.Results.mode;


transects=mbs.input.data.transect;
snapshot=mbs.input.data.snapshot;
stratum=mbs.input.data.stratum;

if length(idx_trans) > length(transects)||isempty(idx_trans)
    warning('Requested index > num transects, using num transects');
    idx_trans=1:length(transects);
end


idx_transects=transects(idx_trans);
idx_snapshots=snapshot(idx_trans);
idx_strata=stratum(idx_trans);

mbs.output.regionSum.data = [] ;
mbs.output.regionSumAbscf.data = [];
mbs.output.regionSumVbscf.data = [];
cal_rev='';
svCorr=1;
mbs.input.data.svCorr=ones(1,length(mbs.input.data.transect));
processed=zeros(1,length(idx_transects));
for ii=1:length(idx_transects)
    % Loop through all files
    %% Setup
    curr_transect=idx_transects(ii);
    curr_snapshot=idx_snapshots(ii);
    curr_stratum=idx_strata(ii);
    idx_transect_files=(mbs.input.data.transect==curr_transect&mbs.input.data.snapshot==curr_snapshot&strcmp(mbs.input.data.stratum,curr_stratum));
    idx_transect_files(processed==1)=0;
    processed(idx_transect_files)=1;
    
    idx_transect_files=find(idx_transect_files);
    
    if isempty(idx_transect_files)
        continue;
    end

    rsa_temp={};
    eint=[];
    end_num=zeros(1,length(idx_transect_files));
    %reg_files=struct('name','','id',[],'unique_id',[],'startDepth',nan,'finishDepth',nan,'startSlice',nan,'finishSlice',nan,'spec','');

    for i=1:length(idx_transect_files)
     
        fprintf(1,'Opening file d%07d, (%s)\n',mbs.input.data.dfile(idx_transect_files(i)),mbs.input.data.rawFileName{idx_transect_files(i)});
        
        switch type
            case 'raw'
                if exist(fullfile(mbs.input.data.rawDir{idx_transect_files(i)},mbs.input.data.rawFileName{idx_transect_files(i)}),'file')==2                    
                    ifileInfo=parse_ifile(mbs.input.data.crestDir{idx_transect_files(i)},mbs.input.data.dfile(idx_transect_files(i)));
                    layer(i)=open_EK60_file_stdalone(mbs.input.data.rawDir{idx_transect_files(i)},mbs.input.data.rawFileName{idx_transect_files(i)},...
                        'PathToMemmap',datapath,'Frequencies',38000,'EsOffset',ifileInfo.es60error_offset);
                else
                    continue;
                end
                
                [idx_freq,found]=layer(i).find_freq_idx(38000);
                if found==0
                    continue;
                end
                
                origin=fullfile(mbs.input.data.crestDir{idx_transect_files(i)},sprintf('d%07d',mbs.input.data.dfile(idx_transect_files(i))));
                layer(i).OriginCrest=origin;
                layer(i).Transceivers(idx_freq).apply_cw_cal(mbs.input.data.CalRaw{idx_transect_files(i)});
            case 'crest'
                layer(i)=read_crest(mbs.input.data.crestDir{idx_transect_files(i)},sprintf('d%07d',mbs.input.data.dfile(idx_transect_files(i))),'PathToMemmap',datapath,'CVSCheck',0);
                idx_freq=find_freq_idx(layer(i),38000);
        end
        
        cal_rev_new = mbs.input.data.calRev{idx_transect_files(i)};
        if ~strcmp(cal_rev,cal_rev_new)
            cal_rev=cal_rev_new;
            svCorr = CVS_CalRevs(cvsroot,'CalRev',cal_rev);
        end
        
        mbs.input.data.svCorr(idx_transect_files(i))=svCorr;
        
        if isnan(mbs.input.data.absorbtion(i))
            layer(i).Transceivers(idx_freq).apply_absorption(mbs.input.header.default_absorption/1e3);
        else
            layer(i).Transceivers(idx_freq).apply_absorption(mbs.input.data.absorbtion(i)/1e3);
        end
          
        Transceiver =layer(i).Transceivers(idx_freq);
        
        switch mode
            case 'normal'
                RegCVS=mbs.input.data.Reg{idx_transect_files(i)};
                for uuk=1:length(RegCVS)
                    reg(uuk) = getRegSpecFromRegString(RegCVS{uuk});
                end
                if ~isempty(RegCVS)>0
                    layer(i).CVS_BottomRegions(cvsroot,'BotRev',mbs.input.data.BotRev{idx_transect_files(i)},'RegRev',mbs.input.data.RegRev{idx_transect_files(i)},'RegId',[reg(:).id]);
                else
                    layer(i).CVS_BottomRegions(cvsroot,'BotRev',mbs.input.data.BotRev{idx_transect_files(i)},'RegCVS',0);
                end   
                layer(i).save_regs();

            case 'sch'
                layer(i).CVS_BottomRegions(cvsroot,'BotRev',mbs.input.data.BotRev{idx_transect_files(i)},'RegCVS',0);
                layer(i).Transceivers(idx_freq).Algo=init_algos(layer(i).Transceivers(idx_freq).Data.Range);
                [idx_school_detect,~]=find_algo_idx(Transceiver,'SchoolDetection');
                linked_candidates=feval(layer(i).Transceivers(idx_freq).Algo(idx_school_detect).Function,layer(i).Transceivers(idx_freq),...
                    'Type','sv',...
                    'Sv_thr',-62,...
                    'h_min_can',5,...
                    'h_min_tot',10,...                   
                    'l_min_can',15,...
                    'l_min_tot',30,...
                    'nb_min_sples',100,...
                    'horz_link_max',5,...
                    'vert_link_max',5);
                
                layer(i).Transceivers(idx_freq).create_regions_from_linked_candidates(linked_candidates,'w_unit','pings','h_unit','meters','cell_w',10,'cell_h',5,'bbox_only',0);
                
                rm_id=nan(1,length(layer(i).Transceivers(idx_freq).Regions));
                for uuk=1:length(layer(i).Transceivers(idx_freq).Regions)
                    [mean_depth,~]=layer(i).Transceivers(idx_freq).get_mean_depth_from_region(layer(i).Transceivers(idx_freq).Regions(uuk).Unique_ID);
                    if nanmin(mean_depth)<200
                        rm_id(uuk)=layer(i).Transceivers(idx_freq).Regions(uuk).Unique_ID;
                    end
                end
                rm_id(isnan(rm_id))=[];
                for uik=1:length(rm_id)
                    layer(i).Transceivers(idx_freq).rm_region_id(rm_id(uik));
                end

                for uuk=1:length(layer(i).Transceivers(idx_freq).Regions)
                    RegCVS{uuk}=[num2str(layer(i).Transceivers(idx_freq).Regions(uuk).ID,'%.0f'),'()'];
                    reg(uuk) = getRegSpecFromRegString(RegCVS{uuk});
                end
                layer(i).save_regs();
        end
        
        Transceiver =layer(i).Transceivers(idx_freq);
        
        end_num(i+1)=end_num(i)+Transceiver.Data.Number(end);
        
        
        mbs.output.regionSum.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'ref' 'slice_size' 'good_pings' 'start_d' 'mean_d' 'finish_d' 'av_speed' 'vbscf' 'abscf'};
        mbs.output.regionSumAbscf.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_v_slices' 'transmit_start' 'latitude' 'longitude' 'column_abscf'};
        mbs.output.regionSumVbscf.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_h_slices' 'num_v_slices' 'region_vbscf' 'vbscf_values'};
        
        rs={};
        rsv={};
        rsa={};
        
        for j = 1:length(Transceiver.Regions);
            % Loops over all regions as requested in mbs input
            % script, then finds the according Region on Echoview
            % and exports Integration per region. To grid the Region
            % we are using a Region mask for the class 'export' in
            % Echoview (in each loop iteration only the current
            % region will get assigned to this class) so that the
            % Echogram will only consists out of this region. Then
            % the Cell grid will be changed according to the region
            % notes (written in there by createEVfromMbs).
            
            
            gps=Transceiver.GPSDataPing;
            reg_curr=Transceiver.Regions(j);
            
            regCellInt = reg_curr.Output;
            
            startPing = regCellInt.Ping_S(1);
            stopPing = regCellInt.Ping_E(end);
            
            ix = (startPing:stopPing);
            ix_good=setdiff(ix,Transceiver.IdxBad);
            % all pings for this region
            horzSlice = reg_curr.Cell_h;
            vertSlice = reg_curr.Cell_w;
            
            
            switch reg_curr.Reference
                case 'Surface';
                    refType = 's';
                    if isnan(reg(j).startDepth); start_d = Transceiver.Data.Range(reg_curr.Idx_r(1)); else start_d = reg(j).startDepth; end
                    if isnan(reg(j).finishDepth); finish_d = Transceiver.Data.Range(reg_curr.Idx_r(1)); else finish_d = reg(j).finishDepth; end
                case 'Bottom';
                    refType = 'b';
                    if isnan(reg(j).startDepth); start_d = 0; else start_d = reg(j).startDepth; end
                    if isnan(reg(j).finishDepth); finish_d = 0; else finish_d = reg(j).finishDepth; end
            end
            
            
            dist = m_lldist([gps.Long(reg_curr.Idx_pings(1)) gps.Long(reg_curr.Idx_pings(end))],[gps.Lat(reg_curr.Idx_pings(1)) gps.Lat(reg_curr.Idx_pings(end))])/1.852;% get distance as esp2 does... Straigth line estimate
            time_s = regCellInt.Time_S(1);
            time_e = regCellInt.Time_E(end);
            timediff = (time_e-time_s)*24;
            av_speed=dist/timediff;
            
            regCellIntSub = getCellIntSubSet(regCellInt, reg(j),refType);
            regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)=regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)-360;
            
            %% Region Summary (4th Mbs output Block)
            rs{j,1} = mbs.input.data.snapshot(idx_transect_files(i));
            rs{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rs{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rs{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rs{j,5} = reg(j).id;
            rs{j,6} = refType;
            rs{j,7} = horzSlice;
            rs{j,8} = length(ix_good); % filter for only good pings
            rs{j,9} = start_d;
            good_bot=Transceiver.Bottom.Range;
            good_bot(Transceiver.IdxBad)=[];
            rs{j,10} = nanmean(good_bot);% find bottom pings in good pings and only take mean from good ones
            rs{j,11} = finish_d;
            rs{j,12} = av_speed;
            rs{j,13} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nansum(regCellIntSub.Nb_good_pings_esp2.*regCellIntSub.Thickness_esp2));
            rs{j,14} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nanmax(regCellIntSub.Nb_good_pings_esp2));%Abscf Region
            
            
            %% Region Summary (abscf by vertical slice) (5th Mbs output Block)
            rsa{j,1} = mbs.input.data.snapshot(idx_transect_files(i));
            rsa{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rsa{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rsa{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rsa{j,5} = reg(j).id;
            rsa{j,6} = size(regCellIntSub.Lat_S,2);  % num_v_slices
            rsa{j,7} = nanmax(regCellIntSub.Ping_S); % transmit Start vertical slice
            rsa{j,8} = nanmax(regCellIntSub.Lat_S); % lat vertical slice
            rsa{j,9} = nanmax(regCellIntSub.Lon_S); % lon vertical slice
            rsa{j,10} = nansum(regCellIntSub.Sa_lin)./nanmax(regCellIntSub.Nb_good_pings_esp2);%sum up all abcsf per vertical slice
            rsa{j,11} = nanmax(regCellIntSub.Ping_E);
            nb_good_pings_reg{i,j} = nanmax(regCellIntSub.Nb_good_pings_esp2);
            end_num_regs(i)=end_num(i)+rsa{j,11}(end);
            
            %% Region vbscf (6th Mbs output Block)
            rsv{j,1}= mbs.input.data.snapshot(idx_transect_files(i));
            rsv{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rsv{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rsv{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rsv{j,5} = reg(j).id;
            rsv{j,6} = size(regCellIntSub.Sa_lin,1);% num_h_slices
            rsv{j,7} = size(regCellIntSub.Lat_S,2); % num_v_slices
            rsv{j,8} = rs{j,13}; % Vbscf Region
            [I,~]=find(~isnan(regCellIntSub.Sa_lin'));
            idx_first=nanmin(I);
            tmp = regCellIntSub.Sv_mean_lin_esp2(idx_first:(idx_first+rsv{j,6})-1,:);
            tmp(isnan(tmp))=0;
            tmp=tmp';
            tmp=tmp(:);
            rsv{j,9} = tmp; % vbscf_values (Sv_mean), reshape vbscf to output horizontal slice by vertical slice like Esp2
            
            %% Region echo integral for File Summary
            eint(i,j) = nansum(nansum(regCellIntSub.Sa_lin));
            
        end
        
        if ~isempty(Transceiver.Regions)
            mbs.output.regionSum.data =  [mbs.output.regionSum.data  ; rs];
            mbs.output.regionSumAbscf.data =  [mbs.output.regionSumAbscf.data  ; rsa];
            rsa_temp{i}=rsa;
            mbs.output.regionSumVbscf.data =  [mbs.output.regionSumVbscf.data  ; rsv];
        end
        clear reg;
    end

    idx_freq=find_freq_idx(layer(1),38000);


    gps_tot=layer(1).Transceivers(idx_freq).GPSDataPing;
    bot_tot=layer(1).Transceivers(idx_freq).Bottom;
    IdxBad_tot=layer(1).Transceivers(idx_freq).IdxBad;

    if length(layer)>1
        for i=2:length(layer)
            idx_freq=find_freq_idx(layer(i),38000);
            if layer(i).Transceivers(idx_freq).GPSDataPing.Time(1)> gps_tot.Time(end)
                bot_tot=concatenate_Bottom(bot_tot,layer(i).Transceivers(idx_freq).Bottom);
                IdxBad_tot=[IdxBad_tot(:) ; layer(i).Transceivers(idx_freq).IdxBad(:)];
            else
                bot_tot=concatenate_Bottom(layer(i).Transceivers(idx_freq).Bottom,bot_tot);
                IdxBad_tot=[ layer(i).Transceivers(idx_freq).IdxBad(:) ; IdxBad_tot(:)];
            end
            gps_tot=concatenate_GPSData(gps_tot,layer(i).Transceivers(idx_freq).GPSDataPing);
        end
    end
    layer.delete_layers([]);
    clear layer;
    
    gps_tot.Long(gps_tot.Long>180)=gps_tot.Long(gps_tot.Long>180)-360;
    
    %% File Summary (part of 2nd Mbs output Block)
    % We need to export the Integration by Cell for the whole
    % Echogram to get the spatial information. Abscf and Vbscf
    % are calculated by taking sum of the region Echo Integral
    
    idx_pings=1:length(gps_tot.Time);
    idx_good_pings=setdiff(idx_pings,IdxBad_tot);
    mbsVS = (mbs.input.header.vertical_slice_size);
    
    dist_tot = m_lldist([gps_tot.Long(1) gps_tot.Long(end)],[gps_tot.Lat(1) gps_tot.Lat(end)])/1.852;% get distance as esp2 does... Straigth line estimate
    time_s_tot = gps_tot.Time(1);
    time_e_tot = gps_tot.Time(end);
    timediff_tot = (time_e_tot-time_s_tot)*24;
    av_speed_tot=dist_tot/timediff_tot;
    
    
    good_bot_tot=nanmean(bot_tot.Range(idx_good_pings));
    
    
    %Will be used for Transect Summary
    fs{ii,1} = mbs.input.data.snapshot(idx_transect_files(i));
    fs{ii,2} = mbs.input.data.stratum{idx_transect_files(i)};
    fs{ii,3} = mbs.input.data.transect(idx_transect_files(i));
    fs{ii,4} = dist_tot; % dist
    fs{ii,7} = nanmean(good_bot_tot); % mean_d
    fs{ii,8}= length(idx_good_pings); % pings %
    fs{ii,9} = av_speed_tot; % av_speed
    fs{ii,10} = gps_tot.Lat(1); % start_lat
    fs{ii,11} = gps_tot.Long(1); % start_lon
    fs{ii,12} = gps_tot.Lat(end); % finish_lat
    fs{ii,13} = gps_tot.Long(end); % finish_lon
    fs{ii,14} = nansum(eint(:)); % Echo Integral
    fs{ii,15} = nansum(fs{ii,8}.*fs{ii,7}); % mean bottom depth * pings
    fs{ii,5} = fs{ii,14}/fs{ii,15}; % vbscf according to Esp2 formula
    fs{ii,6} = fs{ii,14}/fs{ii,8}; % abscf according to Esp2 formula
    
    %% Sliced File Summary
    % Export Integration by Cell for the whole Echogram gridded
    % to the defined vertical slice size from the mbs script to
    % get spatial information. The calculation of abscf is done
    % by summing all region abscf (rsa) for each slice (bin)


    bins=unique([idx_pings(1):mbsVS:idx_pings(end) idx_pings(end)]);
    %     bins=unique([1:mbsVS:end_num_regs(end) end_num_regs(end)]);
    binStart = bins(1:end-1);
    binEnd = bins(2:end);
    numSlices = length(binStart); % num_slices
    

    slice_abscf_ori=zeros(1,length(binStart));
    nb_good_pings=zeros(1,length(binStart));
    
    for iuu=1:length(rsa_temp)
        rsa_new=rsa_temp{iuu};
        for j = 1:size(rsa_new,1)
            att=zeros(1,length(rsa_new{j,11}));
            t_start=rsa_new{j,7}+end_num(iuu);
            for k = 1:length(binStart); % sum up abscf data according to bins      
                %t_end=rsa_new{j,11}+end_num(iuu);   
                ix = (t_start>=binStart(k) &  t_start<binEnd(k))& ~att;
                att(ix)=1;
                nb_good_pings(k)=nanmax(nansum(nb_good_pings_reg{iuu,j}(ix)),nb_good_pings(k));
                %slice_abscf(k) = slice_abscf(k)+ nansum(nb_good_pings_reg{iuu,j}(ix).*rsa_new{j,10}(ix));
                slice_abscf_ori(k) = (slice_abscf_ori(k)+nansum(rsa_new{j,10}(ix)));
            end
        end
    end
    

    
    
    %will be used for Sliced Transect Summary
    sfs{ii,1} = mbs.input.data.snapshot(idx_transect_files(1));
    sfs{ii,2} = mbs.input.data.stratum{idx_transect_files(1)};
    sfs{ii,3} = mbs.input.data.transect(idx_transect_files(1));
    sfs{ii,4} = mbsVS; % slice_size
    sfs{ii,5} = numSlices; % num_slices
    sfs{ii,6} = gps_tot.Lat(binStart); % latitude
    sfs{ii,7} = gps_tot.Long(binStart); % longitude
    sfs{ii,8} = slice_abscf_ori; % slice_abscf
    
    clear slice_abscf_ori;
    
end
mbs.output.temp.fileSum.data =  fs;
mbs.output.temp.sliceFileSum.data = sfs;



