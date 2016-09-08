function obj=create_bottom_from_evl(filename,range,timevec)

p = inputParser;

addRequired(p,'filename',@ischar);
addRequired(p,'range',@isnumeric);
addRequired(p,'timevec',@isnumeric);

parse(p,filename,range,timevec);

if exist(filename,'file')==0
    obj=bottom_cl();
    disp('Cannot find specified .evl file');
    return;
end

[timestamp,depth,tag]=read_evl(filename);

depth_resampled=resample_data_v2(depth,timestamp,timevec);
sample_idx=resample_data_v2(1:length(range),range,depth_resampled,'Opt','Nearest');
tag_resampled=resample_data_v2(tag,timestamp,timevec,'Opt','Nearest');

obj=bottom_cl('Origin','EVL','Sample_idx',sample_idx,'Tag',tag_resampled~=2);

end