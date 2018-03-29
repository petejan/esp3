function [data_c,mean_corrected_value] = correctES60(data,offset,silent)

period = 2721;
if isempty(offset)||ischar(offset)
    offset=nan;
end

num_pings = size(data,2);
rd_zone=data(1,:);
rd_zone(rd_zone<0)=nan;

% Apply all possible corrections to the first sample in each ping. Calculate the standard
% deviation and mean of the corrected first sample amplitude

gpu_comp=get_gpu_comp_stat();

if gpu_comp
    pings=gpuArray(single(1:num_pings));
    periods=gpuArray(single((1:period)'));
    rd_zone=gpuArray(single(rd_zone));
    data=gpuArray(data);
    fit = struct('std',ones(period,1,'single','gpuArray')*1000,'mean', zeros(period,1,'single','gpuArray'));
else
    pings=single(1:num_pings);
    periods=single((1:period)');
    fit = struct('std',ones(period,1,'single')*1000,'mean', zeros(period,1,'single'));
end

mat_tri=bsxfun(@minus,rd_zone,es60_error(bsxfun(@plus,pings,periods)));
fit.std=nanstd(mat_tri,0,2);
fit.mean=nanmean(mat_tri,2);

% Ideally, the minimum standard deviation will give the appropriate zero error ping number
[val_std, zero_error_ping] = nanmin(fit.std);
if val_std>0.1
    if silent==0
        disp('It does not look like there is a triangle wave error here...');
    end
    if isa(data,'gpuArray')
        data_c=gather(data);
    else
        data_c=data;
    end
    mean_corrected_value=0;
    
    %     figure();
    %     plot(rd_zone)
    %     xlabel('Ping number')
    %     ylabel('Third sample received power (dB re 1 W, uncalibrated)')
    %     legend('Uncorrected')
    %     grid on;
    
    return;
end
% if there are enough pings to guarantee a change in slope in the
% error, use the value, otherwise investigate a bit more.
if num_pings < period/2
    % Now check to see if the minimum is a good one
    std_of_std = nanstd(fit.std);
    % find zero error ping numbers where the std of the fit is close to the minimum
    close_values = find(fit.std < min(fit.std)+0.01*std_of_std);
    if length(close_values) > 40 % too many values close to the minimum, so we don't trust
        % any of them and use the supplied offset (or ask for one)
        if isnan(offset)
            if silent==0
                disp('Cannot find the zero error ping number. You need to manually supply an offset.')
            end
        else % we have been supplied with an offset to use
            if silent==0
                disp('Using supplied offset.')
            end
            % Now find the zero error ping number with the corrected mean that is closest to the
            % supplied offset, but still with a low std.
            % This code is not vectorised, but this is not the normal case so the loss in speed
            % should be acceptable.
            min_with_offset = 100000000;
            
            for j = 1:length(fit.std)
                if (abs(fit.mean(j) - offset) < min_with_offset) && (fit.std(j) < min(fit.std)+0.01*std_of_std)
                    min_with_offset = abs(fit.mean(j)-offset);
                    zero_error_ping = j;
                end
            end
        end
        mean_corrected_value= nanmean(rd_zone - es60_error((1:num_pings)+zero_error_ping));
        if silent==0
            disp(['The mean corrected value is ' num2str(mean_corrected_value) ' dB'])
        end
    else % Is this code good enough? Does there need to be more checking of the result here?
        % We get here if there are less than 40 zero error ping numbers with a low std. If this is the
        % case, we simply take the zero error ping number with the lowest std.
        mean_corrected_value = nanmean(rd_zone - es60_error((1:num_pings)+zero_error_ping));
        if silent==0
            disp(['The mean corrected value is ' num2str(mean_corrected_value) ' dB'])
        end
    end
else
    % There were enough pings to cover a change in slope in the error, so we're done.
    mean_corrected_value = nanmean(rd_zone - es60_error((1:num_pings)+zero_error_ping));
    if silent==0
        disp(['The mean corrected value is ' num2str(mean_corrected_value) ' dB'])
    end
end
%
% figure();
% disp(['The zero error ping number is ' num2str(zero_error_ping)])
% plot(rd_zone)
% hold on
% plot(rd_zone - es60_error((1:num_pings)+zero_error_ping), 'r')
% xlabel('Ping number')
% ylabel('Third sample received power (dB re 1 W, uncalibrated)')
% legend('Uncorrected', 'Corrected')
% grid on;

data_c=data-repmat(es60_error(pings+zero_error_ping),size(data,1),1);
if isa(data_c,'gpuArray')
    data_c=gather(data_c);
end

end

