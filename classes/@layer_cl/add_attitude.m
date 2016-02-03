function add_attitude(layer,attitude_full)

if isempty(attitude_full)
    return;
end
layer.AttitudeNav=attitude_full;
for ui=1:length(layer.Transceivers)
    attitude=attitude_full.resample_attitude_nav_data(layer.Transceivers.Data.Time);
    layer.Transceivers(ui).AttitudeNavPing=attitude;
end
end