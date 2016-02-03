function calParms = readEKRaw_ReadXMLParms(filename)
% readEKRaw_ReadXMLParms - Reads the calibration parms XML file and returns a structure
%   calParms = readEKRaw_ReadXMLParms(filename) Reads the calibration
%   parms XML file and returns the data as a calParms structure
%
%   This ended up messier than I would have liked but I wasn't able to find an
%   XML toolkit that was open, returned data in the proper type, and worked as
%   advertised.
%
%   REQUIRED INPUT:
%        filename:    The filename of the XML file to read. 
%
%   OPTIONAL PARAMETERS: None
%       
%   OUTPUT: ReadEKRaw CalParms structure
%
%   REQUIRES:   XMLTree from the "XML Parser" package. This is no longer
%               available thru the MATLAB Central File Exchange and is now
%               included in the readEKRaw toolkit.
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%

%-

%  read the contents of the XML file into an XMLTree object
xml = xmltree(filename);

%  convert to a structure
cp = convert(xml);

%  determine the number of transceivers in the XML struct
if (iscell(cp.soundername))
    nXcvrs = length(cp.soundername);
else
    nXcvrs = 1;
end

%  create the calibration parameters structure
calParms = repmat(struct('soundername', '', 'frequency', 0, ...
    'soundvelocity', 0, 'sampleinterval', 0, 'absorptioncoefficient', 0, ...
    'gain', 0, 'equivalentbeamangle', 0, 'beamwidthalongship', 0, ...
    'beamwidthathwartship', 0, 'pulselengthtable', 0, ...
    'gaintable', 0, 'sacorrectiontable', 0, 'transmitpower', 0, ...
    'pulselength', 0, 'anglesensitivityalongship', 0, ...
    'anglesensitivityathwartship', 0, 'anglesoffsetalongship', 0, ...
    'angleoffsetathwartship', 0, 'transducerdepth', 0), 1, nXcvrs);

%  sort the entries by frequency
if (nXcvrs > 1)
    flist = zeros(nXcvrs,1);
    for n=1:nXcvrs; flist(n)=str2double(cp.frequency{n}); end
    [null, sortedList] = sort(flist);
else
    sortedList = 1;
end

%  convert from string to numeric and populate calParms struct
fields = fieldnames(cp);
nFields = length(fields);
for n=1:nFields
    if (nXcvrs > 1)
        cp.(fields{n}) = cellfun(@convertCell, cp.(fields{n}), 'UniformOutput', false);
    else
        cp.(fields{n}) = {convertCell(cp.(fields{n}))};
    end
    %  copy the converted fields in sorted order
    for m=1:nXcvrs; calParms(m).(fields{n}) = cp.(fields{n}){sortedList(m)}; end
end

end

function cd = convertCell(cd)
    %  check if the cell is already numeric (NaN)
    if (~isnan(cd(1)))
        %  convert to number - str2num is faster and returns [] if cell is char
        td = str2num(cd);
        %  if ~empty then we have a numeric value - return it
        if (~isempty(td)); cd = td; end
    end
end
