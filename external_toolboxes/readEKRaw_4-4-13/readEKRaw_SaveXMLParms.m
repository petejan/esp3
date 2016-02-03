function readEKRaw_SaveXMLParms(calParms, filename)
% readEKRaw_SaveXMLParms - Saves the calParms structure as an XML file
%   readEKRaw_SaveXMLParms(calParms, filename) Saves the calParms structure
%   as an XML file.
%
%   REQUIRED INPUT:
%        calParms:    The calibration parameters structure
%        filename:    The filename of the resulting XML file. 
%
%   OPTIONAL PARAMETERS: None
%       
%   OUTPUT: None
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

%  Convert a few fields to double since the XMLTree library doesn't deal with singles well.
nXcvrs = length(calParms);
for n=1:nXcvrs
    calParms(n).soundvelocity = double(calParms(n).soundvelocity);
    calParms(n).sampleinterval = double(calParms(n).sampleinterval);
    calParms(n).absorptioncoefficient = double(calParms(n).absorptioncoefficient);
    calParms(n).transmitpower = double(calParms(n).transmitpower);
    calParms(n).pulselength = double(calParms(n).pulselength);
    calParms(n).transducerdepth = double(calParms(n).transducerdepth);
end

%  convert the struct to an XML object
xml = struct2xml(calParms);

%  write the XML file
save(xml, filename);


