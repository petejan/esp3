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