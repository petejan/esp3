function sampledata = readEKRaw_AllocateSampledata(len)
%readEKRaw_AllocateSampledata  Allocate a structure for storing sample data
%   sampledata = readEKRawSampledata(len) pre-allocates a structure for
%       storing individual sample data datagrams. 
%
%   REQUIRED INPUT:
%               len:    length of sample data arrays (power and angle)
%
%   OPTIONAL PARAMETERS:    None
%       
%   OUTPUT:
%       Output is a data structure for use with readEKRaw_ReadSampleData
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%
%   Based on code by Lars Nonboe Andersen, Simrad.

%-

sampledata.channel = int16(0);
sampledata.mode = int8(0);
sampledata.transducerdepth = single(0);
sampledata.frequency = single(0);
sampledata.transmitpower = single(0);
sampledata.pulselength = single(0);
sampledata.bandwidth = single(0);
sampledata.sampleinterval = single(0);
sampledata.soundvelocity = single(0);
sampledata.absorptioncoefficient = single(0);
sampledata.heave = single(0);
sampledata.roll = single(0);
sampledata.pitch = single(0);
sampledata.temperature = single(0);
sampledata.trawlupperdepthvalid = int16(0);
sampledata.trawlopeningvalid = int16(0);
sampledata.trawlupperdepth = single(0);
sampledata.trawlopening = single(0);
sampledata.offset = int32(0);
sampledata.count = int32(0);
sampledata.power = zeros(1,len, 'single') - 999;
sampledata.alongship = zeros(1,len, 'int8');
sampledata.athwartship = zeros(1,len, 'int8');
