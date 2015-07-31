function [data_c,mean_corrected_value] = correctES60(data,offset)

period = 2721;
if isempty(offset)
offset=nan;
end

num_pings = size(data,2);
rd_zone=data(1,:);
rd_zone(rd_zone<0)=nan;
fit = struct('std', ones(period,1)*1000, 'mean', zeros(period,1));
% Apply all possible corrections to the first sample in each ping. Calculate the standard
% deviation and mean of the corrected first sample amplitude
for j = 1:period
    fit.std(j) = nanstd( abs(rd_zone - es60_error((1:num_pings) + j)) );
    fit.mean(j) = nanmean( abs(rd_zone - es60_error((1:num_pings) + j)) );
end
% Ideally, the minimum standard deviation will give the appropriate zero error ping number
[~, zero_error_ping] = nanmin(fit.std);
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
            disp('Cannot find the zero error ping number. You need to manually supply an offset.')
        else % we have been supplied with an offset to use
            disp('Using supplied offset.')
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
         disp(['The mean corrected value is ' num2str(mean_corrected_value) ' dB'])
    else % Is this code good enough? Does there need to be more checking of the result here?
        % We get here if there are less than 40 zero error ping numbers with a low std. If this is the
        % case, we simply take the zero error ping number with the lowest std.
        mean_corrected_value = nanmean(rd_zone - es60_error((1:num_pings)+zero_error_ping));
        disp(['The mean corrected value is ' num2str(mean_corrected_value) ' dB'])
    end
else
    % There were enough pings to cover a change in slope in the error, so we're done.
    mean_corrected_value = nanmean(rd_zone - es60_error((1:num_pings)+zero_error_ping));
    disp(['The mean corrected value is ' num2str(mean_corrected_value) ' dB'])
end

%Show the correction for visual validation.
% errfig=figure();
% disp(['The zero error ping number is ' num2str(zero_error_ping)])
% plot(rd_zone)
% hold on
% plot(rd_zone - es60_error((1:num_pings)+zero_error_ping), 'r')
% xlabel('Ping number')
% ylabel('First sample received power?? (dB re 1 W, uncalibrated)')
% legend('Uncorrected', 'Corrected')
% grid on;
% pause(2)
% if open('errfig')
%     close(errfig)
% end
data_c=data-repmat(es60_error((1:num_pings)+zero_error_ping),size(data,1),1);
end

function error = es60_error(ping_nums)

% Calculates the form of the es60 triangle wave error.
%

step_value = 10*log10(2)/256;
max_error = 0.5;
min_error = -0.5;
period = 2721;

num_steps = round(2*(max_error - min_error) / step_value);
step_length = round(period / num_steps);

ping_nums = mod(ping_nums, period);

error = zeros(size(ping_nums)); % dB
i = find(ping_nums < 0.25*period);
error(i) = floor(ping_nums(i) / step_length) * step_value;
i = find(ping_nums >= 0.75*period);
error(i) =  floor( (ping_nums(i) - 0.75*period) / step_length) * ...
    step_value + min_error;
i = find(ping_nums >= 0.25*period & ping_nums < 0.75*period);
error(i) = -floor( (ping_nums(i) - 0.25*period) / step_length) * ...
    step_value + max_error;
end