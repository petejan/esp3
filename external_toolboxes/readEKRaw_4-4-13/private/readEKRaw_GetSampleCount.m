function nSamples = readEKRaw_GetSampleCount(fid, CIDs, sampleRange, maxSampleRange, ping)
%readEKRaw_GetSampleCount  Scan EK/ES RAW0 datagram for sample counts
%   nSamples = readEKRaw_GetSampleCount(fid, frequencies, sampleRange, ping)  
%       returns an array of values representing the ping'th non-zero sample count 
%       for each channel specified in the channel ID array.
%
%   REQUIRED INPUT:
%               fid:    file handle id
%              CIDs:    vector specifying the channel ID's of the transceivers to scan
%       sampleRange:    2 element vector defining the beginning and ending
%                       sample to return.
%    maxSampleRange:    scalar value defining the maximum number of samples
%                       to return.
%              ping:    scalar value specifying the ping to extract sample count
%                       from.  If the sample count for the provided ping is 0,
%                       the function will continue reading the file until a
%                       non-zero sample count is returned.
%
%       Note that specifying an initial sampleRange that is beyond the maximum
%       number of samples in the file will cause this function to scan the entire
%       file before returning.  Make sure you specify your sampleRange correctly!
%
%   OPTIONAL PARAMETERS:    None
%
%   OUTPUT:
%       A vector nFreqs long of uint16 values specifying the number of samples
%       in the first ping that reports more than 0 samples.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

HEADER_LEN = 12;                %  Raw datagram header size
cdat=[];
%  get position in file
fPosition = ftell(fid);

%  determine number of freqs and allocate return array
nXcvrs = length(CIDs);
nSamples = zeros(nXcvrs, 1, 'uint16');

%  create array that tracks number of pings scanned
nPings = zeros(nXcvrs, 1, 'uint16');

%  scan file and extract sample counts for specified freqs
while (nXcvrs > 0)
    
    %  read the next datagram
    len = fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end

    %  scan file for RAW datagrams
    [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, 0);
    if strcmp(dgType, 'RAW0')
        
        %  read channel ID
        channel = fread(fid,1,'int16', 'l');
        cdat = [cdat channel];


        %  skip to the samplecount record and read
        fseek(fid, 66, 0);
        sampleCount = fread(fid,1,'int32', 'l');

        %  adjust sampleCount based on the sample range to be extracted
        if (sampleRange(1) <= sampleCount)
            if (sampleRange(2) == 65535)
                endIdx = sampleCount;
            else
                endIdx = sampleRange(2);
            end
            if (endIdx > maxSampleRange); endIdx = maxSampleRange; end
            sampleCount = (endIdx - sampleRange(1)) + 1;
        else
            sampleCount = 0;
        end

        %  store sample number if required/valid
        idx = find(CIDs == channel);
        nPings(idx) = nPings(idx) + 1;
        if (~isempty(idx)) && (sampleCount > 0) && ...
                (nPings(idx) >= ping) && (nSamples(idx) == 0)
            nSamples(idx) = sampleCount;
            nXcvrs = nXcvrs - 1;
        end
        
        %  skip to the next datagram
        fseek(fid, len - 72 - HEADER_LEN, 0);
        
    else
        %  Skip to the next datagram
        fseek(fid, len - HEADER_LEN, 0);
    end
    
    fread(fid, 1, 'int32', 'l');
    
end

%  reset file pointer
fseek(fid, fPosition, 'bof');

