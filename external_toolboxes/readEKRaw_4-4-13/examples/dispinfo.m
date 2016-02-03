filename='d:\D20120609-T220532.raw';
[header,data]=readEKRaw(filename);

nChannels = length(data.pings);
disp(['Channels in file: ' num2str(nChannels)]);

for i=1:nChannels
    disp(data.config(i).channelid);
    disp(['    first ping:' datestr(data.pings(i).time(1), 'mm/dd-HH:MM:SS.FFF')]);
    disp(['     last ping:' datestr(data.pings(i).time(end), 'mm/dd-HH:MM:SS.FFF')]);
end