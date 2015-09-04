
function regionSummary_new(mbs,varargin) % Calculate

transects=mbs.input.data.transect;
transects(abs([1;diff(mbs.input.data.transect)])==0)=[];

if nargin == 2;
    uu = varargin{1};
    if length(uu) > length(transects)
        warning('Requested index > num transects, using num transects');
        uu=1:length(transects);
    end
else
    uu = 1:length(transects);
end

idx_transects = transects(uu);
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
        
        layer(i)=open_EK60_file_stdalone([],pwd,mbs.rawDir,mbs.input.data.rawFileName{idx_transect_files(i)},38000,1,Inf);
        
        idx_freq=find_freq_idx(layer(i),38000);
        
        layer(i).Transceivers(idx_freq).Bottom=mbs.input.data.bottom{idx_transect_files(i)};
        layer(i).Transceivers(idx_freq).IdxBad=mbs.input.data.bad{idx_transect_files(i)};
        
        Transceiver =layer(i).Transceivers(idx_freq);
        
        if i==1
            end_num(i+1)=Transceiver.Data.Number(end);
        else
            Transceiver.Data.Number=Transceiver.Data.Number;
            end_num(i+1)=end_num(i)+Transceiver.Data.Number(end);
        end
        
        new_cal.SaCorr = -0.55;
        new_cal.Gain= 25.42;
        Transceiver.apply_cw_cal(new_cal);
        
        new_absorption=8/1000;
        Transceiver.apply_absorption(new_absorption);
        
        Transceiver.add_region(mbs.input.data.regions{idx_transect_files(i)});
        Transceiver.Bottom=mbs.input.data.bottom{idx_transect_files(i)};
        Transceiver.IdxBad=mbs.input.data.bad{idx_transect_files(i)};
        
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
            [regx,~] = Transceiver.find_reg_idx_id(reg.id); % find according region
            
            reg_curr=mbs.input.data.regions{idx_transect_files(i)}(regx);
            
            reg_curr.integrate_region(Transceiver);
            
            regCellInt = reg_curr.Output;
            
            startPing = regCellInt.Ping_S(1);
            stopPing = regCellInt.Ping_E(end);
            
            ix = (startPing:stopPing);
            % all pings for this region
            horzSlice = reg_curr.Cell_h;
            %vertSlice = reg_curr.Cell_w;
            
            
            switch reg_curr.Reference
                case 'Surface';
                    refType = 's';
                case 'Bottom';
                    refType = 'b';
            end
            
            %dist = (regCellInt.VL_E(end)-regCellInt.VL_S(1))/1e3;                       % get distance
            dist = m_lldist([regCellInt.Lon_S(1) regCellInt.Lon_E(end)],[regCellInt.Lat_S(1) regCellInt.Lat_E(end)])/1.852;% get distance as esp2 does... Straigth line estimate
   
            time_s = regCellInt.Time_S(1);
            time_e = regCellInt.Time_E(end);
            
            timediff = (time_e-time_s)*24;
            regCellIntSub = getCellIntSubSet(regCellInt, reg, j, refType);
            
            
            %% Region Summary (4th Mbs output Block)
            rs{j,1} = mbs.input.data.snapshot(idx_transect_files(i));
            rs{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rs{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rs{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rs{j,5} = reg.id(j);
            rs{j,6} = refType;
            rs{j,7} = horzSlice;
            rs{j,8} = length(find((Transceiver.IdxBad(ix)==0))); % filter for only good pings
            if isnan(reg.startDepth); start = Transceiver.Data.Range(reg_curr.Idx_r(1)); else start = reg.startDepth; end
            rs{j,9} = start;
            good_bot=Transceiver.Bottom.Range(ix);
            good_bot(Transceiver.IdxBad(ix)==0);
            rs{j,10} = nanmean(good_bot);% find bottom pings in good pings and only take mean from good ones
            if isnan(reg.finishDepth); finish = Transceiver.Data.Range(reg_curr.Idx_r(end)); else finish = reg.finishDepth; end
            rs{j,11} = finish;
            rs{j,12} = dist/timediff;
            rs{j,13} = nansum(nansum(regCellIntSub.Sa_lin))./nansum(nansum(regCellIntSub.Nb_good_pings.*(regCellIntSub.Layer_depth_max-regCellIntSub.Layer_depth_min)));%Vbsc
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
            rsa{j,11} = nanmax(regCellIntSub.Ping_E)-1+end_num(i);
            
            %% Region vbscf (6th Mbs output Block)
            rsv{j,1}= mbs.input.data.snapshot(idx_transect_files(i));
            rsv{j,2} = mbs.input.data.stratum{idx_transect_files(i)};
            rsv{j,3} = mbs.input.data.transect(idx_transect_files(i));
            rsv{j,4} = [mbs.input.data.dfileDir{idx_transect_files(i)} '/' sprintf('d%07.f',mbs.input.data.dfile(idx_transect_files(i)))];
            rsv{j,5} = reg.id(j);
            rsv{j,6} = nanmax(nansum(~isnan(regCellIntSub.Sv_mean))); % num_h_slices, get max value of cells for each collum
            rsv{j,7} = size(regCellIntSub.Lat_S,2); % num_v_slices
            rsv{j,8} = rs{j,13}; % region_vbscf
            [I,~]=find(isnan(regCellIntSub.Sv_mean'));
            idx_first=nanmin(I);
            tmp = 10.^(regCellIntSub.Sv_mean(idx_first:(idx_first+rsv{j,6})-1,:)/10);
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
    layer_tot=shuffle_layers(layer_cl,layer,0,1);
    clear layer;
    
    
    Transceiver =layer_tot.Transceivers(idx_freq);
    %% File Summary (part of 2nd Mbs output Block)
    % We need to export the Integration by Cell for the whole
    % Echogram to get the spatial information. Abscf and Vbscf
    % are calculated by taking sum of the region Echo Integral
    
    range=double(Transceiver.Data.Range);
    samples=(1:length(range))';
    pings=double(Transceiver.Data.Number);
    
    idx_pings=1:length(pings);
    idx_r=samples;
    
    mbsVS = str2double(mbs.input.data.vertical_slice_size);
    
    reg_temp=region_cl(...
        'ID',999,...
        'Name','All Echogramm',...
        'Type','Data',...
        'Idx_pings',idx_pings,...
        'Idx_r',idx_r,...
        'Shape','Rectangular',...
        'Reference','Surface',...
        'Cell_w',mbsVS,...
        'Cell_w_unit','pings',...
        'Cell_h',9999,...
        'Cell_h_unit','meters',...
        'Output',[]);
    
    reg_temp.integrate_region(Transceiver);
   
    
    CellInt = reg_temp.Output;
    
    %dist = (CellInt.VL_E(end)-CellInt.VL_S(1))/1e3; 
    dist_tot = m_lldist([CellInt.Lon_S(1) CellInt.Lon_S(1)],[CellInt.Lat_S(1) CellInt.Lat_E(end)])/1.852;% get distance as esp2 does... Straigth line estimate
    time_s_tot = CellInt.Time_S(1);
    time_e_tot = CellInt.Time_E(end);
    
    timediff_tot = (time_e_tot-time_s_tot)*24;  
    
    % get time difference
    fs{ii,1} = mbs.input.data.snapshot(idx_transect_files(i));
    fs{ii,2} = mbs.input.data.stratum{idx_transect_files(i)};
    fs{ii,3} = mbs.input.data.transect(idx_transect_files(i));
    fs{ii,4} = dist; % dist
    fs{ii,7} = nanmean(Transceiver.Bottom.Range(Transceiver.IdxBad==0)); % mean_d
    fs{ii,8}= length(find((Transceiver.IdxBad==0))); % pings %
    fs{ii,9} = dist_tot/timediff_tot; % av_speed
    fs{ii,10} = CellInt.Lat_S(1); % start_lat
    fs{ii,11} = CellInt.Lon_S(1); % start_lon
    fs{ii,12} = CellInt.Lat_E(end); % finish_lat
    fs{ii,13} = CellInt.Lon_E(end); % finish_lon
    fs{ii,14} = nansum(eint); % Echo Integral
    fs{ii,15} = nansum(fs{ii,8}.*fs{ii,7}); % mean bottom depth * pings
    fs{ii,5} = fs{ii,14}/fs{ii,15}; % vbscf according to Esp2 formula
    fs{ii,6} = fs{ii,14}/fs{ii,8}; % abscf according to Esp2 formula
    
    %% Sliced File Summary
    % Export Integration by Cell for the whole Echogram gridded
    % to the defined vertical slice size from the mbs script to
    % get spatial information. The calculation of abscf is done
    % by summing all region abscf (rsa) for each slice (bin)
    
    numSlices = length(CellInt.Ping_S); % num_slices
    binStart = CellInt.Ping_S';
    binEnd = CellInt.Ping_E';
    
    slice_abscf=zeros(1,length(binStart));
    
    for i=1:length(idx_transect_files)
        reg = getRegSpecFromRegString(mbs.input.data.Reg{idx_transect_files(i)});
        rsa=rsa_temp{i};
        for j = 1:length(reg.id);
            for k = 1:length(binStart); % sum up abscf data according to bins
                ix =  rsa{j,11}>=binStart(k) &  rsa{j,11}<=binEnd(k);
                    slice_abscf(k) = slice_abscf(k)+nansum(rsa{j,10}(ix));
            end
        end
    end
    
    
    sfs{ii,1} = mbs.input.data.snapshot(idx_transect_files(i));
    sfs{ii,2} = mbs.input.data.stratum{idx_transect_files(i)};
    sfs{ii,3} = mbs.input.data.transect(idx_transect_files(i));
    sfs{ii,4} = mbsVS; % slice_size
    sfs{ii,5} = numSlices; % num_slices
    sfs{ii,6} = CellInt.Lat_S'; % latitude
    sfs{ii,7} = CellInt.Lon_S'; % longitude
    sfs{ii,8} = slice_abscf; % slice_abscf
    
    
    clear slice_abscf;
    layer_tot.delete();
    clear layer_tot;
    
end
mbs.output.temp.fileSum.data =  fs;
mbs.output.temp.sliceFileSum.data = sfs;



