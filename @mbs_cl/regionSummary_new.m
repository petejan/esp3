
function regionSummary_new(mbs,idx_trans,type) % Calculate

transects=mbs.input.data.transect;



if length(idx_trans) > length(transects)
    warning('Requested index > num transects, using num transects');
    idx_trans=1:length(transects);
end


idx_transects=transects(idx_trans);
idx_transects(abs([1 diff(idx_transects)])==0)=[];


mbs.output.regionSum.data = [] ;
mbs.output.regionSumAbscf.data = [];
mbs.output.regionSumVbscf.data = [];

for ii=1:length(idx_transects)
    % Loop through all files
    %% Setup
    curr_transect=idx_transects(ii);
    idx_transect_files=find(mbs.input.data.transect==curr_transect);
    
    end_num(1)=0;
	rsa_temp={};
    eint=0;
    for i=1:length(idx_transect_files)
        
        disp(sprintf('Opening file %s',mbs.input.data.rawFileName{idx_transect_files(i)}));

        switch type
            case 'raw'
                layer(i)=open_EK60_file_stdalone(mbs.rawDir,mbs.input.data.rawFileName{idx_transect_files(i)},'PathToMemmap',pwd,'Frequencies',38000,'FieldNames',{'sv'});        
                idx_freq=find_freq_idx(layer(i),38000);
                layer(i).Transceivers(idx_freq).apply_cw_cal(mbs.cal);               
            case 'crest'          
                layer(i)=read_crest(mbs.crestDir,sprintf('d%07d',mbs.input.data.dfile(idx_transect_files(i))),'PathToMemmap',pwd,'CVSCheck',0);
                idx_freq=find_freq_idx(layer(i),38000);
        end
        layer(i).Transceivers(idx_freq).apply_absorption(mbs.absorbtion);
        layer(i).Transceivers(idx_freq).Bottom=mbs.input.data.bottom{idx_transect_files(i)};
        layer(i).Transceivers(idx_freq).IdxBad=mbs.input.data.bad{idx_transect_files(i)};
        
        Transceiver =layer(i).Transceivers(idx_freq);
           
        end_num(i+1)=end_num(i)+Transceiver.Data.Number(end);
       
        Transceiver.setBottomIdxBad(mbs.input.data.bottom{idx_transect_files(i)},mbs.input.data.bad{idx_transect_files(i)});       
  
        
        
        % export boolean for goodping
        % read reg string
        reg = getRegSpecFromRegString(mbs.input.data.Reg{idx_transect_files(i)});
        mbs.output.regionSum.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'ref' 'slice_size' 'good_pings' 'start_d' 'mean_d' 'finish_d' 'av_speed' 'vbscf' 'abscf'};
        mbs.output.regionSumAbscf.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_v_slices' 'transmit_start' 'latitude' 'longitude' 'column_abscf'};
        mbs.output.regionSumVbscf.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_h_slices' 'num_v_slices' 'region_vbscf' 'vbscf_values'};
        % delete file
        
        %         figure();
        %         ax=axes();
        %         layer(i).display_layer(38000,'Sv',ax,[],[],[],[],[],1);
        %
        for j = 1:length(reg.id);
            % Loops over all regions as requested in mbs input
            % script, then finds the according Region on Echoview
            % and exports Integration per region. To grid the Region
            % we are using a Region mask for the class 'export' in
            % Echoview (in each loop iteration only the current
            % region will get assigned to this class) so that the
            % Echogram will only consists out of this region. Then
            % the Cell grid will be changed according to the region
            % notes (written in there by createEVfromMbs).
            
            idx_reg=[];
            for iik=1:length(mbs.input.data.regions{idx_transect_files(i)})
                if reg.id==mbs.input.data.regions{idx_transect_files(i)}(iik).ID
                    idx_reg=iik;
                end
            end
            if isempty(idx_reg)
                idx_reg=1;
            end
            reg_curr=mbs.input.data.regions{idx_transect_files(i)}(idx_reg);
            switch type
                case 'raw'
                    reg_curr.Idx_pings=reg_curr.Idx_pings+1;
                    reg_curr.Idx_r=reg_curr.Idx_r+1;
                case 'crest'
            end
            Transceiver.add_region(reg_curr);
            gps=Transceiver.GPSDataPing;
            
            [regx,~] = Transceiver.find_reg_idx_id(reg.id); % find according region
            
            reg_curr=Transceiver.Regions(regx);
                       
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
                     if isnan(reg.startDepth); start_d = Transceiver.Data.Range(reg_curr.Idx_r(1)); else start_d = reg.startDepth; end
                     if isnan(reg.finishDepth); finish_d = Transceiver.Data.Range(reg_curr.Idx_r(1)); else finish_d = reg.finishDepth; end
                case 'Bottom';
                    refType = 'b';
                    if isnan(reg.startDepth); start_d = 0; else start_d = reg.startDepth; end
                    if isnan(reg.finishDepth); finish_d = 0; else finish_d = reg.finishDepth; end
            end
            
            %dist = (regCellInt.VL_E(end)-regCellInt.VL_S(1))/1e3;    
            %dist=nansum(m_lldist(gps.Long(reg_curr.Idx_pings),gps.Lat(reg_curr.Idx_pings))/1.852);% get distance
            %av_speed=nanmean(m_lldist(gps.Long(reg_curr.Idx_pings),gps.Lat(reg_curr.Idx_pings))./diff(gps.Time(reg_curr.Idx_pings)*24)/1.852);
            
            dist = m_lldist([gps.Long(reg_curr.Idx_pings(1)) gps.Long(reg_curr.Idx_pings(end))],[gps.Lat(reg_curr.Idx_pings(1)) gps.Lat(reg_curr.Idx_pings(end))])/1.852;% get distance as esp2 does... Straigth line estimate 
            time_s = regCellInt.Time_S(1);
            time_e = regCellInt.Time_E(end);            
            timediff = (time_e-time_s)*24;        
            av_speed=dist/timediff;
            
            regCellIntSub = getCellIntSubSet(regCellInt, reg, j, refType);
            regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)=regCellIntSub.Lon_S(regCellIntSub.Lon_S>180)-360;
           
            %% Region Summary (4th Mbs output Block)
            rs{j,1} = mbs.input.data.snapshot(idx_transect_files(i));
            rs{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rs{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rs{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rs{j,5} = reg.id(j);
            rs{j,6} = refType;
            rs{j,7} = horzSlice;
            rs{j,8} = length(ix_good); % filter for only good pings
            rs{j,9} = start_d;
            good_bot=Transceiver.Bottom.Range(ix_good);
            rs{j,10} = nanmean(good_bot);% find bottom pings in good pings and only take mean from good ones
            rs{j,11} = finish_d;
            rs{j,12} = av_speed;
            rs{j,13} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nansum(regCellIntSub.Nb_good_pings.*~isnan(regCellIntSub.Thickness_esp2)*reg_curr.Cell_h));%Vbsc    
            %rs{j,13} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nansum(regCellIntSub.Nb_good_pings.*abs(regCellIntSub.Layer_depth_max-regCellIntSub.Layer_depth_max)));%Vbsc    
            rs{j,14} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nanmean(regCellIntSub.Nb_good_pings));%Abscf
            
            
            %% Region Summary (abscf by vertical slice) (5th Mbs output Block)
            rsa{j,1} = mbs.input.data.snapshot(idx_transect_files(i));
            rsa{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rsa{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rsa{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rsa{j,5} = reg.id(j);
            rsa{j,6} = size(regCellIntSub.Lat_S,2);  % num_v_slices
            rsa{j,7} = nanmax(regCellIntSub.Ping_S); % transmit Start vertical slice
            rsa{j,8} = nanmax(regCellIntSub.Lat_S); % lat vertical slice
            rsa{j,9} = nanmax(regCellIntSub.Lon_S); % lon vertical slice
            rsa{j,10} = nansum(regCellIntSub.Sa_lin)./nanmean(regCellIntSub.Nb_good_pings);%sum up all abcsf per vertical slice
            rsa{j,11} = nanmax(regCellIntSub.Ping_E);
            nb_good_pings_reg{i,j} = nanmean(regCellIntSub.Nb_good_pings);
            end_num_regs(i)=end_num(i)+rsa{j,11}(end);
            
            %% Region vbscf (6th Mbs output Block)
            rsv{j,1}= mbs.input.data.snapshot(idx_transect_files(i));
            rsv{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rsv{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rsv{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rsv{j,5} = reg.id(j);
            rsv{j,6} = nanmax(nansum(~isnan(regCellIntSub.Sa_lin))); % num_h_slices, get max value of cells for each collum
            rsv{j,7} = size(regCellIntSub.Lat_S,2); % num_v_slices
            rsv{j,8} = rs{j,13}; % region_vbscf
            [I,~]=find(~isnan(regCellIntSub.Sa_lin'));
            idx_first=nanmin(I);
            
            tmp = regCellIntSub.Sv_mean_lin_esp2(idx_first:(idx_first+rsv{j,6})-1,:);
            tmp(isnan(tmp))=0;
            tmp=tmp';
            tmp=tmp(:);
            rsv{j,9} = tmp; % vbscf_values (Sv_mean), reshape vbscf to output horizontal slice by vertical slice like Esp2
            
            %% Region echo integral for File Summary
            %eint(j,1) = nansum(nansum(regCellMatSub(:,:,3).*(regCellMatSub(:,:,7).*vertSlice)));
            eint(i) = nansum(nansum(regCellIntSub.Sa_lin));
            
            
        end
        
        mbs.output.regionSum.data =  [mbs.output.regionSum.data  ; rs];
        mbs.output.regionSumAbscf.data =  [mbs.output.regionSumAbscf.data  ; rsa];
        rsa_temp{i}=rsa;
        mbs.output.regionSumVbscf.data =  [mbs.output.regionSumVbscf.data  ; rsv];
        
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
    mbsVS = str2double(mbs.input.data.vertical_slice_size);
       
    dist_tot = m_lldist([gps_tot.Long(1) gps_tot.Long(end)],[gps_tot.Lat(1) gps_tot.Lat(end)])/1.852;% get distance as esp2 does... Straigth line estimate 
    time_s_tot = gps_tot.Time(1);
    time_e_tot = gps_tot.Time(end); 
    timediff_tot = (time_e_tot-time_s_tot)*24; 
    av_speed_tot=dist_tot/timediff_tot;
    
%     dist_tot=nansum(m_lldist(gps_tot.Long,gps_tot.Lat)/1.852);
%     av_speed_tot=nanmean(m_lldist(gps_tot.Long,gps_tot.Lat)./diff(gps_tot.Time*24)/1.852);
%     
    
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
    fs{ii,14} = nansum(eint); % Echo Integral
    fs{ii,15} = nansum(fs{ii,8}.*fs{ii,7}); % mean bottom depth * pings
    fs{ii,5} = fs{ii,14}/fs{ii,15}; % vbscf according to Esp2 formula
    fs{ii,6} = fs{ii,14}/fs{ii,8}; % abscf according to Esp2 formula
    
    %% Sliced File Summary
    % Export Integration by Cell for the whole Echogram gridded
    % to the defined vertical slice size from the mbs script to
    % get spatial information. The calculation of abscf is done
    % by summing all region abscf (rsa) for each slice (bin)
    
    
    bins=unique([1:mbsVS:idx_pings(end) idx_pings(end)]);
%     bins=unique([1:mbsVS:end_num_regs(end) end_num_regs(end)]);
    binStart = [1 bins(2:end-1)-1];
    binEnd = bins(2:end);
    numSlices = length(binStart); % num_slices
    
    slice_abscf=zeros(1,length(binStart));
    slice_abscf_ori=zeros(1,length(binStart));
    nb_good_pings=zeros(1,length(binStart));
    t_start={};
    t_end={};
    for i=1:length(idx_transect_files)
        reg = getRegSpecFromRegString(mbs.input.data.Reg{idx_transect_files(i)});
        rsa=rsa_temp{i};

        for j = 1:length(reg.id);
            for k = 1:length(binStart); % sum up abscf data according to bins
                t_start{i,j}=rsa{j,7}+end_num(i);
                t_end{i,j}=rsa{j,11}+end_num(i);
                ix = (t_start{i,j}>=binStart(k) &  t_start{i,j}<=binEnd(k));
                find(ix);
                nb_good_pings(k)=nb_good_pings(k)+nansum(nb_good_pings_reg{i,j}(ix));
                slice_abscf(k) = slice_abscf(k)+ nansum(nb_good_pings_reg{i,j}(ix).*rsa{j,10}(ix));
                slice_abscf_ori(k) = slice_abscf_ori(k)+ nansum(rsa{j,10}(ix));
            end
        end
    end
    
    %slice_abscf=slice_abscf./nb_good_pings;
    slice_abscf=slice_abscf_ori;
    
    
   %will be used for Sliced Transect Summary
    sfs{ii,1} = mbs.input.data.snapshot(idx_transect_files(i));
    sfs{ii,2} = mbs.input.data.stratum{idx_transect_files(i)};
    sfs{ii,3} = mbs.input.data.transect(idx_transect_files(i));
    sfs{ii,4} = mbsVS; % slice_size
    sfs{ii,5} = numSlices; % num_slices
    sfs{ii,6} = gps_tot.Lat(binStart); % latitude
    sfs{ii,7} = gps_tot.Long(binStart); % longitude
    sfs{ii,8} = slice_abscf; % slice_abscf
    
    clear slice_abscf;
    
end
mbs.output.temp.fileSum.data =  fs;
mbs.output.temp.sliceFileSum.data = sfs;



