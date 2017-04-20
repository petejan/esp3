function add_attitude(layer,attitude_full)

if isempty(attitude_full)
    return;
end

for ui=1:length(layer.Transceivers)
    attitude=attitude_full.resample_attitude_nav_data(layer.Transceivers.Time);
    layer.Transceivers(ui).AttitudeNavPing=attitude;
end
layer.AttitudeNav=attitude_full;
end