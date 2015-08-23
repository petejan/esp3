%readEKRaw_SimpleExample.m
%
%  A script showing the basic usage of the readEKRaw library.  This script
%  reads 2 frequencies from an example data file containing 3 frequencies then
%  creates echograms and anglograms of the data.
%
%   REQUIRES:   readEKRaw toolbox
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-


%  define paths to example raw and bot files
rawFile = 'data\D20040615-T094615.raw';
botFile = 'data\D20040615-T094615.bot';

%  read in raw file - only reading 18 and 120 khz
disp('Reading .raw file...');
[header, rawData] = readEKRaw(rawFile);%, 'Frequencies', 120000);

%  extract calibration parameters from raw data structure
%
%    calParms is a structure array containing transceiver specific settings
%    such as gain, frequency, transmitpower, etc. which is used by other
%    functions in the readEKRaw library.  readEKRaw_GetCalParms extracts these
%    parameters from the rawData structure.
%
%    If you need to set your parameters explicitly you can simply build or
%    modify this structure yourself. Or you can create an XML based parameter
%    file and read it using the readEKRaw_ReadXMLParms function.
calParms = readEKRaw_GetCalParms(header, rawData);

%  read in the .bot file - return data as range
disp('Reading .bot file...');
[header, botData] = readEKBot(botFile, calParms, rawData, ...
    'ReturnRange', true);

%  convert power to Sv
data = readEKRaw_Power2Sv(rawData, calParms);

%  convert electrical to physical angles
data = readEKRaw_ConvertAngles(data, calParms);

%  create some simple figures of the data
disp('Plotting...');
nFreqs = length(data.pings);
for n=1:nFreqs
    %  plot the echogram
    readEKRaw_SimpleEchogram(data.pings(n).Sv, data.pings(n).number, ...
        data.pings(n).range, 'Threshold', [-80,-34], 'Title', ...
        ['Sv  ' num2str(calParms(n).frequency)]);
    %  plot the bottom
    hold on
    plot(data.pings(n).number, botData.pings.bottomdepth(n,:), 'c');
    hold off
    
    %  plot the anglogram
    readEKRaw_SimpleAnglogram(data.pings(n).alongship, ...
        data.pings(n).athwartship, data.pings(n).number, ...
        data.pings(n).range, 'Title', ...
        ['Angles  ' num2str(calParms(n).frequency)]);
    %  plot the bottom
    hold on
    plot(data.pings(n).number, botData.pings.bottomdepth(n,:), 'c');
    hold off
end