function pings = readEKRaw_DeleteBot(pings, idx)
%readEKRaw__DeleteBot  Delete one or more pings from a bottom detection structure
%   pings = readEKRaw__DeleteBot(pings, idx) deletes one or more pings from
%   a bottom detection structure
%
%   REQUIRED INPUT:
%               pings:   A pings data structure.  Note that this must be a
%                        scalar reference to the pings structure as this
%                        function works on a single frequency at a time.
%                 idx:   A scalar or vector of indexes to be removed from
%                        the data structure.
%
%   OPTIONAL PARAMETERS:    None.
%
%   OUTPUT:
%       The bottom detection data structure with the elements specified in "idx"
%       removed.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

pings.number(idx) = [];
pings.time(idx) = [];
pings.bottomdepth(idx) = [];
