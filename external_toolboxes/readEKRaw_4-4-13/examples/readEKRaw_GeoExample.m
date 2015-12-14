%readEKRaw_GeoExample 
%   readEKRaw_GeoExample is an example of reading an EK60 .raw data file while
%   applying a simple geographic mask to limit the data read to certain
%   regions of interest (ROIs).
%
%   In this example, a simple ROI comprised of two rectangles is defined and
%   passed to readEKRaw.  Two echograms, one for each segment within the ROIs
%   are plotted.  Then the ship track, coastline and ROI are plotted.
%   Green sections of ship track indicate where the track is inside the ROI,
%   sections that are red are outside the ROI.  The ROIs appear as blue boxes
%   that cut the ship track into 6 segments.
%
%   There are 3 sections inside the ROI and 3 sections out.  GPS fixes in
%   data.gps are tagged with the section id (+ values for in, - values for
%   out) in data.gps.seg.  Pings are tagged with the section ID too, but
%   since we discard ping data outside of the ROI, data.pings.seg only
%   contains positive values.
%
%   REQUIRES:   readEKRaw toolbox
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-


%  specify full path to raw file
rawFile = 'data\D20040615-T094615.raw';

%  define vertices of 2 polygons which will be used to define the 
%  geographic region of interest.

geoReg1 = [56.0607 -165.2143;
           56.0617 -165.2143;
           56.0617 -165.2130;
           56.0607 -165.2130];
geoReg2 = [56.061 -165.212;
           56.0622 -165.212;
           56.0622 -165.2108;
           56.061 -165.2108];
geoRegion = [geoReg1; geoReg2];

%  define the polygon connectivity array - tells inpoly how to
%  connect the dots
geoConn = [1 2;
           2 3;
           3 4;
           4 1;
           5 6;
           6 7;
           7 8;
           8 5];
         
%  read in raw file - passing geographic regions and connectivity.
disp('Reading .raw file...');
[header, data] = readEKRaw(rawFile, 'Frequencies', 18000, ...
    'GeoRegion', geoRegion, 'GeoConn', geoConn);

%  extract calibration parameters from raw data structure
calParms = readEKRaw_GetCalParms(header, data);

%  convert power to Sv
data = readEKRaw_Power2Sv(data, calParms);

%  determine the number of segments in and out of the geographic ROI
nSegsIn = max(data.gps.seg);
nSegsOut = abs(min(data.gps.seg));

%  create some simple figures of the data
disp('Plotting...');

%  determine how many trackline segments are in our regions of interest
nSegs = max(data.pings.seg);

%  plot each segments echogram data
for n=1:nSegsIn
    %  plot the echogram
    readEKRaw_SimpleEchogram(data.pings.Sv(:,data.pings.seg == n), ...
        data.pings.number(data.pings.seg == n), ...
        data.pings.range, 'Title', ...
        ['Trackline Segment ' num2str(n) '   Sv  ' num2str(calParms.frequency)]);
end

%  plot the ship track and ROI
figure();

%  plot the segments in the ROI as green and out as red
hold on
for n=1:nSegsIn
    plot(data.gps.lon(data.gps.seg == n), data.gps.lat(data.gps.seg == n), ...
        'color', [0,0.8,0], 'linewidth', 2.0);
    
end
for n=1:nSegsOut
    plot(data.gps.lon(data.gps.seg == -n), data.gps.lat(data.gps.seg == -n), ...
        'color', [0.8,0,0], 'linewidth', 2.0);
end

%  plot the regions
patch(geoRegion(:,2), geoRegion(:,1), 'b', 'faces', geoConn, ...
    'facecolor', 'none', 'edgecolor', 'b');
hold off





