%readEKRaw_SimpleTest.m
%
%  A script showing the basic usage of the readEKRaw library that compares
%  the output of readEKRaw_Power2Sv to exported pings from Echoview.
%
%   REQUIRES:   readEKRaw toolbox
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  define which piing to plot
plotPing = 1;

%  define paths to example raw and bot files
rawFile = 'C:\Program Files\Simrad\Scientific\EK60\Examples\survey\OfotenDemo-D20001214-T145902.raw';
EVfile = 'C:\Program Files\Simrad\Scientific\EK60\Examples\survey\OfotenDemo-D20001214-T145902.mat';

%  read in raw file - only reading 18 and 120 khz
disp('Reading .raw file...');
[header, rawData] = readEKRaw(rawFile);

%  read in the EV export data
disp('Reading EV file...')
EVData = load(EVfile)

%  extract calibration parameters from raw data structure
calParms = readEKRaw_GetCalParms(header, rawData);


%  convert power to Sv
data = readEKRaw_Power2Sv(rawData, calParms);


%  create some simple figures of the data

%  plot the readEKRaw data
plot(data.pings(1).Sv(:,plotPing));

hold on
plot(2:2126,EVData.Data_values(plotPing,:), 'r');

