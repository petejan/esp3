
        function stratumSummary(mbs)  % takes output from region summary,
            % calculates transect & stratum summary and writes the results
            % into mbs.output
            mbs.output.stratumSum.header = {'snapshot' 'stratum' 'no_transects' 'abscf_mean' 'abscf_sd' 'abscf_wmean' 'abscf_var'};   % mbs output headers
            mbs.output.transectSum.header = {'snapshot' 'stratum' 'transect' 'dist' 'vbscf' 'abscf' 'mean_d' 'pings' 'av_speed' 'start_lat' 'start_lon' 'finish_lat' 'finish_lon'};
            mbs.output.slicedTransectSum.header = {'snapshot' 'stratum' 'transect' 'slice_size' 'num_slices' 'latitude' 'longitude' 'slice_abscf'};
            mbs.output.stratumSum.data = [];
            mbs.output.slicedTransectSum.data = [];
            mbs.output.transectSum.data = [];
            
            for ii = 1:size(mbs.output.temp.fileSum.data,1)
                % this for loop fills all empty cells with NaNs
                for jj = 1:size(mbs.output.temp.fileSum.data,2)
                    if isempty(mbs.output.temp.fileSum.data{ii,jj})
                       mbs.output.temp.fileSum.data{ii,jj} = NaN;
                    end
                end
            end
            
            %% Transect and Sliced Transect Summary (2nd and 3rd mbs output block)
            % calculate transect and sliced transect summary
            tmp = cell2mat(mbs.output.temp.fileSum.data(:,1));
            snaps = unique(tmp(~isnan(tmp)));
            for i = 1:length(snaps)
                % loop over all snapshots and get data subset
                ix = find(cell2mat(mbs.output.temp.fileSum.data(:,1))==snaps(i));
                tmpSn =mbs.output.temp.fileSum.data(ix,:);
                tmpSnSl =mbs.output.temp.sliceFileSum.data(ix,:);
                strats = unique(tmpSn(:,2));
                for j = 1:length(strats)
                    % loop over all strata and get data subset
                    jx = (strcmp(tmpSn(:,2), strats{j}));
                    trans = unique(cell2mat(tmpSn(jx,3)));
                    for k = 1:length(trans)
                        mbs.output.transectSum.data = [mbs.output.transectSum.data ; tmpSn(k,1:13)];
                        mbs.output.transectSum.data{k,5} =  nansum(cell2mat(tmpSn(k,14)))/nansum(cell2mat(tmpSn(k,15))); % vbscf according to Esp2 formula
                        mbs.output.transectSum.data{k,6} =  nansum(cell2mat(tmpSn(k,14)))/nansum(cell2mat(tmpSn(k,8))); % abscf according to Esp2 formula
                        mbs.output.slicedTransectSum.data = [mbs.output.slicedTransectSum.data ; tmpSnSl(k(1),:)];
                    end
                end
                
            end
            
            %% Stratum Summary (1st mbs output block)
            % calculate stratum summary from transect summary data
            % according to esp2 formula
            for i = 1:length(snaps)
                % loop over all snapshots and get data subset
                ix = find(cell2mat(mbs.output.transectSum.data(:,1))==snaps(i));
                strats = unique(mbs.output.transectSum.data(ix,2));
                for j = 1:length(strats)
                    % loop over all strata and get data subset
                    jx = find(strcmp(mbs.output.transectSum.data(ix,2), strats{j}));
                    ss{j,1} = mbs.output.transectSum.data{jx(1),1}; % snapshot
                    ss{j,2} = mbs.output.transectSum.data{jx(1),2}; % stratum
                    ss{j,3} = length(mbs.output.transectSum.data(jx,6)); % % no_transects
                    sum_abscf=nansum(cell2mat(mbs.output.transectSum.data(jx,6)));                 
                    ss{j,4} =sum_abscf/ss{j,3} ; % abscf_mean
                    sum_sq_abscf=nansum(cell2mat(mbs.output.transectSum.data(jx,6)).^2);
                    if ss{j,3}>1
                        ss{j,5} = sqrt((sum_sq_abscf-ss{j,4}.^2.*ss{j,3})/(ss{j,3}-1)); % abscf_sd
                    else
                        ss{j,5}=0;
                    end
                    
                    ss{j,6} = nansum(cell2mat(mbs.output.transectSum.data(jx,4)).*cell2mat(mbs.output.transectSum.data(jx,6)))/...
                        nansum(cell2mat(mbs.output.transectSum.data(jx,4))); % abscf_wmean according to esp2 formula
                    if ss{j,3}>1
                    ss{j,7} = (nansum((cell2mat(mbs.output.transectSum.data(jx,4)).^2).*(cell2mat(mbs.output.transectSum.data(jx,6)).^2))-2*ss{j,6}*...
                        nansum((cell2mat(mbs.output.transectSum.data(jx,4)).^2).*(cell2mat(mbs.output.transectSum.data(jx,6))))+...
                        ss{j,6}^2*nansum(cell2mat(mbs.output.transectSum.data(jx,4)).^2))*...
                        ss{j,3}/((ss{j,3}-1)*nansum(cell2mat(mbs.output.transectSum.data(jx,4)))^2); % abscf_var according to esp2 formula
                    else
                        ss{j,7}=0;
                    end
                end
                mbs.output.stratumSum.data = [mbs.output.stratumSum.data ; ss];
            end
%            mbs.output=rmfield(mbs.output,'temp');
%            mbs.output = orderfields(mbs.output, {'stratumSum' 'transectSum' 'slicedTransectSum' 'regionSum' 'regionSumAbscf' 'regionSumVbscf'});
%         end