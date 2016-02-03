function pings = readEKRaw_DeletePing(pings, idx)
%readEKRaw__DeletePing  Delete one or more pings from ping structure
%   pings = readEKRaw__DeletePing(pings, idx) deletes one or more pings and
%   associated data from the pings data structure.
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
%       The pings data structure with the elements specified in "idx"
%       removed.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

fat = false;
if (length(pings.transducerdepth) == ...
        length(pings.time)); fat = true; end;
if (fat)
    pings.mode(idx) = [];
    pings.transducerdepth(idx) = [];
    pings.frequency(idx) = [];
    pings.transmitpower(idx) = [];
    pings.pulselength(idx) = [];
    pings.bandwidth(idx) = [];
    pings.sampleinterval(idx) = [];
    pings.soundvelocity(idx) = [];
    pings.absorptioncoefficient(idx) = [];
    pings.offset(idx) = [];
end

if (isfield(pings, 'heave')); pings.heave(idx) = []; end
if (isfield(pings, 'roll')); pings.roll(idx) = []; end
if (isfield(pings, 'pitch')); pings.pitch(idx) = []; end
if (isfield(pings, 'temperature')); pings.temperature(idx) = []; end
if (isfield(pings, 'trawlopening'))
    pings.trawlopeningvalid(idx) = [];
    pings.trawlupperdepthvalid(idx) = [];
    pings.trawlupperdepth(idx) = [];
    pings.trawlopening(idx) = [];
end

pings.number(idx) = [];
pings.time(idx) = [];
pings.count(idx) = [];
if (isfield(pings, 'seg')); pings.seg(idx) = []; end
if (isfield(pings, 'power')); pings.power(:,idx) = []; end
if (isfield(pings, 'alongship')); pings.alongship(:,idx) = []; end
if (isfield(pings, 'athwartship')); pings.athwartship(:,idx) = []; end
if (isfield(pings, 'sv')); pings.sv(:,idx) = []; end
if (isfield(pings, 'sp')); pings.sp(:,idx) = []; end
if (isfield(pings, 'Sv')); pings.Sv(:,idx) = []; end
if (isfield(pings, 'Sp')); pings.Sp(:,idx) = []; end
