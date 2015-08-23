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


%  define paths to example raw and bot files
rawFile = 'C:\Program Files\Simrad\Scientific\EK60\Examples\survey\OfotenDemo-D20001214-T145902.raw';
EVfile = 'C:\Program Files\Simrad\Scientific\EK60\Examples\survey\OfotenDemo-D20001214-T145902.mat';

%  read in raw file - only reading 18 and 120 khz
disp('Reading .raw file...');
[header, rawData] = readEKRaw(rawFile);

%  read in the EV export data
EVData = load(EVfile)

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


%  convert power to Sv
data = readEKRaw_Power2Sv(rawData, calParms);



%  create some simple figures of the data

