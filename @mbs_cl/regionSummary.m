
function regionSummary(mbs,varargin) % Calculate
% region Summary, loop over all regions and return region,
% region abcsf and region vbscf (last 3 blocks of mbs output)
% and writes the results into mbs.output. It also creates a
% file and sliced file summary which is used by stratum
% summary to calculate Transect and Sliced Transect Summary

if nargin == 2;
    uu = varargin{1};
    if uu > length(mbs.input.data.transect)
        warning('Requested index > num transects, using num transects');
        uu=length(mbs.input.data.transect);
    end
else
    uu = 1:length(mbs.input.data.transect);
end

fileIdx = uu;

for uu = fileIdx;
    % Loop through all files
    %% Setup
    mbs.input.data.rawFile{uu} = mbs.input.data.rawFileName{uu};
    curr_transect=mbs.input.data.transect(uu);
    
    idx_transect_files=find(mbs.input.data.transect==curr_transect);
    idx_transect_files(~ismember(idx_transect_files,fileIdx))=[];
    end_num(1)=0;
    for i=idx_transect_files'
        
        layer(i)=open_EK60_file_stdalone(mbs.rawDir,mbs.input.data.rawFileName{i},1,38000,1,Inf) ;
        idx_freq=find_freq_idx(layer(i),38000);
        
        layer(i).Transceivers(idx_freq).Bottom=mbs.input.data.bottom{uu};
        layer(i).Transceivers(idx_freq).IdxBad=mbs.input.data.bad{uu};
        
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
         
        Transceiver.add_region(mbs.input.data.regions{i});
        Transceiver.Bottom=mbs.input.data.bottom{i};
        Transceiver.IdxBad=mbs.input.data.bad{i};
        
        % export boolean for goodping
        % read reg string
        reg = getRegSpecFromRegString(mbs.input.data.Reg{i});
        mbs.output.regionSum.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'ref' 'slice_size' 'good_pings' 'start_d' 'mean_d' 'finish_d' 'av_speed' 'vbscf' 'abscf'};
        mbs.output.regionSumAbscf.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_v_slices' 'transmit_start' 'latitude' 'longitude' 'column_abscf'};
        mbs.output.regionSumVbscf.header = {'snapshot' 'stratum' 'transect' 'file' 'region_id' 'num_h_slices' 'num_v_slices' 'region_vbscf' 'vbscf_values'};
        % delete file
        
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
            regx = Transceiver.find_reg_idx(reg.id); % find according region
            
            reg_curr=mbs.input.data.regions{i}(regx);
            
            idx_r=reg_curr.Sample_ori:reg_curr.Sample_ori+reg_curr.BBox_h-1;
            idx_r(idx_r>length(Transceiver.Data.Range))=[];
            idx_pings=reg_curr.Ping_ori:reg_curr.Ping_ori+reg_curr.BBox_w-1;
            
            reg_curr.integrate_region(Transceiver,idx_pings,idx_r);
            %regInt=integrate_region_comp(reg_curr,Transceiver,idx_pings,idx_r);
            regCellInt = reg_curr.Output;
            
            startPing = regCellInt.Ping_S(1);
            stopPing = regCellInt.Ping_E(end);
            
            ix = (startPing:stopPing)-startPing+1;
            % all pings for this region
            horzSlice = reg_curr.Cell_h;
            vertSlice = reg_curr.Cell_w;
            
            %         vertSlice = reg_curr.Cell_h;
            %         horzSlice = reg_curr.Cell_w;
            
            switch reg_curr.Reference
                case 'Surface';
                    refType = 's';
                case 'Bottom';
                    refType = 'b';
            end
            
            dist = (regCellInt.VL_E(end)-regCellInt.VL_S(1))/1e3;                       % get distance
            time_s = regCellInt.Time_S(1);
            time_e = regCellInt.Time_E(end);
            
            timediff = etime(datevec(time_e),datevec(time_s))/3600;
            
            regCellMat = getCellMatrix(regCellInt, horzSlice, vertSlice);       % put data in matrix
            regCellMatSub = getCellMatrixSubSet(regCellMat, reg, j, refType);   % get valid cells according to ping stats
            
            %% Region Summary (4th Mbs output Block)
            rs{j,1} = mbs.input.data.snapshot(i);
            rs{j,2} = mbs.input.data.stratum{i};
            rs{j,3} = mbs.input.data.transect(i);
            rs{j,4} = [mbs.input.data.dfileDir{i} '/' sprintf('d%07.f',mbs.input.data.dfile(i))];
            rs{j,5} = reg.id(j);
            rs{j,6} = refType;
            rs{j,7} = horzSlice;
            rs{j,8} = length(find((Transceiver.IdxBad(ix)==0))); % filter for only good pings
            if isnan(reg.startDepth); start = Transceiver.Data.Range(reg_curr.Sample_ori); else start = reg.startDepth; end
            rs{j,9} = start;
            rs{j,10} = nanmean(Transceiver.Bottom.Range(Transceiver.IdxBad(ix)==0));  % find bottom pings in good pings and only take mean from good ones
            if isnan(reg.finishDepth); finish = Transceiver.Data.Range(reg_curr.Sample_ori); else finish = reg.finishDepth; end
            rs{j,11} = finish;
            rs{j,12} = dist/timediff;
            rs{j,13} = nansum(nansum(regCellMatSub(:,:,13)))./nansum(nansum(regCellMatSub(:,:,14).*(regCellMatSub(:,:,11)-regCellMatSub(:,:,10))));%Vbsc
            rs{j,14} = nansum(nansum(regCellMatSub(:,:,13)))./nansum(nanmean(regCellMatSub(:,:,14)));%Abscf
            

            %% Region Summary (abscf by vertical slice) (5th Mbs output Block)
            rsa{j,1} = mbs.input.data.snapshot(i);
            rsa{j,2} = mbs.input.data.stratum{i};
            rsa{j,3} = mbs.input.data.transect(i);
            rsa{j,4} = [mbs.input.data.dfileDir{i} '/' sprintf('d%07.f',mbs.input.data.dfile(i))];
            rsa{j,5} = reg.id(j);
            rsa{j,6} = length(regCellMatSub(1,:,8));  % num_v_slices
            tmp = regCellMatSub(:,:,5);
            rsa{j,7} = nanmax(regCellMatSub(:,:,5))+startPing-1;         % transmit Start vertical slice
            rsa{j,8} = nanmax(regCellMatSub(:,:,8)); % lat vertical slice
            rsa{j,9} = nanmax(regCellMatSub(:,:,9)); % lon vertical slice
            rsa{j,10} = nansum(regCellMatSub(:,:,13))./nanmean(regCellMatSub(:,:,14));%sum up all abcsf per vertical slice
            rsa{j,11} = nanmax(regCellMatSub(:,:,5))+startPing-1+end_num(i); 
            
            %% Region vbscf (6th Mbs output Block)
            rsv{j,1} = mbs.input.data.snapshot(i);
            rsv{j,2} = mbs.input.data.stratum{i};
            rsv{j,3} = mbs.input.data.transect(i);
            rsv{j,4} = [mbs.input.data.dfileDir{i} '/' sprintf('d%07.f',mbs.input.data.dfile(i))];
            rsv{j,5} = reg.id(j);
            rsv{j,6} = nanmax(cell2mat(arrayfun(@(x) length(find(~isnan(regCellMatSub(:,x,1))==1)),1:size(regCellMatSub,2), 'uni', 0))); % num_h_slices, get max value of cells for each collum
            rsv{j,7} = length(regCellMatSub(1,:,8)); % num_v_slices
            rsv{j,8} = rs{j,13}; % region_vbscf
            tmp = reshape(regCellMatSub(:,:,3)',1,numel((regCellMat(:,:,2)))); tmp(isnan(tmp))=[]; 
            rsv{j,9} = tmp; % vbscf_values (Sv_mean), reshape vbscf to output horizontal slice by vertical slice like Esp2
            
            %% Region echo integral for File Summary
            %eint(j,1) = nansum(nansum(regCellMatSub(:,:,3).*(regCellMatSub(:,:,7).*vertSlice)));
            eint(i) = nansum(nansum(regCellMatSub(:,:,13)));
            
            
        end
        
        if i==idx_transect_files(1)
            mbs.output.regionSum.data = rs;
            mbs.output.regionSumAbscf.data = rsa;
            mbs.output.regionSumVbscf.data = rsv;
        else
            mbs.output.regionSum.data =  [mbs.output.regionSum.data  ; rs];
            mbs.output.regionSumAbscf.data =  [mbs.output.regionSumAbscf.data  ; rsa];
            mbs.output.regionSumVbscf.data =  [mbs.output.regionSumVbscf.data  ; rsv];
        end
    end
        layer_tot=layer(1);
        for kk=1:length(layer)-1
            layer_tot=concatenate_Layer(layer_tot,layer(kk+1));
        end
        
        Transceiver =layer_tot.Transceivers(idx_freq);
        %% File Summary (part of 2nd Mbs output Block)
        % We need to export the Integration by Cell for the whole
        % Echogram to get the spatial information. Abscf and Vbscf
        % are calculated by taking sum of the region Echo Integral
        
        range=double(Transceiver.Data.Range);
        samples=(1:length(range))';
        pings=double(Transceiver.Data.Number);
        startPing=pings(1);
        idx_pings=1:length(pings);
        idx_r=samples;
        
        mbsVS = str2double(mbs.input.data.vertical_slice_size);
        
        reg_temp=region_cl(...
            'ID',999,...
            'Name','All Echogramm',...
            'Type','Data',...
            'Ping_ori',pings(1),...
            'Sample_ori',samples(1),...
            'BBox_w',length(idx_pings),...
            'BBox_h',length(idx_r),...
            'Shape','Rectangular',...
            'Reference','Surface',...
            'Cell_w',mbsVS,...
            'Cell_w_unit','pings',...
            'Cell_h',9999,...
            'Cell_h_unit','meters',...
            'Output',[]);
        
        reg_temp.integrate_region(Transceiver,idx_pings,idx_r);
        
        CellInt = reg_temp.Output;
        time_s = CellInt.Time_S(1);
        time_e = CellInt.Time_E(end);
        
        timediff = etime(datevec(time_e),datevec(time_s))/3600;                 % get time difference
        fs{i,1} = mbs.input.data.snapshot(i);
        fs{i,2} = mbs.input.data.stratum{i};
        fs{i,3} = mbs.input.data.transect(i);
        fs{i,4} = (CellInt.VL_E(end)-CellInt.VL_S(1))/1e3; % dist
        fs{i,7} = nanmean(Transceiver.Bottom.Range(Transceiver.IdxBad==0)); % mean_d
        fs{i,8} = length(find((Transceiver.IdxBad==0))); % pings % note that Esp2 usually rejects first ping, Echhoview doesn't, so this might be 1 higher than Echoview output
        fs{i,9} = fs{i,4}/timediff; % av_speed
        fs{i,10} = CellInt.Lat_S(1); % start_lat
        fs{i,11} = CellInt.Lon_S(1); % start_lon
        fs{i,12} = CellInt.Lat_E(end); % finish_lat
        fs{i,13} = CellInt.Lon_E(end); % finish_lon
        fs{i,14} = nansum(eint); % Echo Integral
        fs{i,15} = nansum((fs{i,7}*fs{i,8})); % mean bottom depth * pings
        fs{i,5} = fs{i,14}/fs{i,15}; % vbscf according to Esp2 formula
        fs{i,6} = fs{i,14}/(fs{i,8}); % abscf according to Esp2 formula
        
        %% Sliced File Summary
        % Export Integration by Cell for the whole Echogram gridded
        % to the defined vertical slice size from the mbs script to
        % get spatial information. The calculation of abscf is done
        % by summing all region abscf (rsa) for each slice (bin)
        
        numSlices = length(CellInt.Ping_S); % num_slices
        binStart = CellInt.Ping_S'+startPing-1;
        binEnd = CellInt.Ping_E'+startPing-1;
        for k = 1:length(binStart); % sum up abscf data according to bins
            ix =  rsa{j,11}>=binStart(k) &  rsa{j,11}<=binEnd(k);
            for l = 1:size(rsa,1);
                slice_abscf(l,k) = nansum(rsa{l,10}(ix));
            end
        end
        sfs{i,1} = mbs.input.data.snapshot(i);
        sfs{i,2} = mbs.input.data.stratum{i};
        sfs{i,3} = mbs.input.data.transect(i);
        sfs{i,4} = mbsVS; % slice_size
        sfs{i,5} = numSlices; % num_slices
        sfs{i,6} = CellInt.Lat_S'; % latitude
        sfs{i,7} = CellInt.Lon_S'; % longitude
        sfs{i,8} = slice_abscf; % slice_abscf
        clear slice_abscf;
        
end
mbs.output.temp.fileSum.data =  fs;
mbs.output.temp.sliceFileSum.data = sfs;



