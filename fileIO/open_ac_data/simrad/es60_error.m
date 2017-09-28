function error = es60_error(ping_nums)

% Calculates the form of the es60 triangle wave error.
%

step_value = single(10*log10(2)/256);
max_error = single(0.5);
min_error = single(-0.5);
period = single(2721);

num_steps = (round(2*(max_error - min_error) / step_value));
step_length = (round(period / num_steps));

ping_nums = mod(ping_nums, period);
if isa(ping_nums,'gpuArray')
    error = zeros(size(ping_nums),'single','gpuArray'); % dB
else
     error = zeros(size(ping_nums),'single'); % dB
end
i = (ping_nums < 0.25*period);
error = error +i.*(floor(ping_nums.*i / step_length) * step_value);

i = (ping_nums >= 0.75*period);
error = error + i.*(floor( (ping_nums - 0.75*period) / step_length) * ...
    step_value + min_error);

i = (ping_nums >= 0.25*period & ping_nums < 0.75*period);

error = error -i.*(floor((ping_nums - 0.25*period) / step_length) * ...
    step_value - max_error);
end