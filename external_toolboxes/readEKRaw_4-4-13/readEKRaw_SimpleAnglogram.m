function [fh, ih] = readEKRaw_SimpleAnglogram(alon, athw, x, y, varargin)
%  readEKRaw_SimpleAnglogram - create a simple anglogram figure
%   [fh, ih] = readEKRaw_SimpleAnglogram(data, x, y, varargin) creates a figure
%   of an anglogram given alongship angles, athwartship angles, X (ping number)
%   and y (range).
%
%   This is a simple function intended mainly to be used by the readEKRaw
%   library examples.  Development on a proper plotting package us underway.
%
%   REQUIRED INPUT:
%              alon:    A N x M matrix of alongship angle data.
%
%              athw:    A N x M matrix of athwartship angle data.
%
%                 x:    A vector of length M containing the corresponding ping
%                       number or time for each ping in data.
%
%                 y:    A vector of length N containing the corresponding range
%                       or depth for each sample in data.
%
%   OPTIONAL PARAMETERS:
%
%            Figure:    Set this parameter to a number or handle ID specifying
%                       the figure to plot the echogram into.  If a non-existant
%                       figure number is passed, a new figure is created.  If an
%                       existing figure is passed, the contents of that figure
%                       are replaced with the echogram.
%                           Default: [];
%
%        MajorRange:    Set this parameter to a 2 element vector [low, high]
%                       specifying the values (in deg) used in scaling the a
%                       alongship data for display.
%                           Default [-12, 12];
%
%        MinorRange:    Set this parameter to a 2 element vector [low, high]
%                       specifying the values (in deg) used in scaling the a
%                       athwartship data for display.
%                           Default [-12, 12];
%
%             Title:    Set this parameter to a string defining the figure
%                       title.
%                           Default: 'Anglogram'
%
%            XLabel:    Set this parameter to a string defining the X axis
%                       label.
%                           Default: 'Ping'
%
%            YLabel:    Set this parameter to a string defining the Y axis
%                       label.
%                           Default: 'Range (m)'
%

%   Rick Towler
%   National Oceanic and Atmospheric Administration
%   Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov

%-

%  set display parameters
yLabelText = 'Range (m)';
xLabelText = 'Ping';
pTitle = 'Anglogram';
fh = [];
mjRange = [-12,12];
mnRange = [-12,12];

for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'xlabel'
            xLabelText = varargin{n + 1};
        case 'ylabel'
            yLabelText = varargin{n + 1};
        case 'majorrange'
            if (length(varargin{n + 1}) == 2)
                mjRange = varargin{n + 1};
            else
                warning('readEKRaw:ParameterError', ...
                    ['Range - major axis range incorrect number of ' ...
                    'arguments. Using defaults.']);
            end
        case 'minorrange'
            if (length(varargin{n + 1}) == 2)
                mnRange = varargin{n + 1};
            else
                warning('readEKRaw:ParameterError', ...
                    ['Range - minor axis range incorrect number of ' ...
                    'arguments. Using defaults.']);
            end
        case 'title'
            pTitle = varargin{n + 1};
        case 'figure'
            fh = varargin{n + 1};
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{n}]);
    end
end

%  threshold and scale
alon(alon > mjRange(2)) = mjRange(2);
alon(alon < mjRange(1)) = mjRange(1);
athw(athw > mnRange(2)) = mnRange(2);
athw(athw < mnRange(1)) = mnRange(1);
agSize = size(alon);
anglogram = zeros(agSize(1), agSize(2), 3);
anglogram(:,:,1) = (alon - mjRange(1)) / (mjRange(2) - mjRange(1));
anglogram(:,:,3) = (athw - mnRange(1)) / (mnRange(2) - mnRange(1));

%  create or raise figure
if (isempty(fh))
    fh = figure();
else
    figure(fh);
end

%  create the anglogram image
ih = image(x, y, anglogram);
set(gca, 'XGrid', 'on', 'Units','pixels');

%  set figure properties
hrscb=['fp=get(gcbo,''Position''); ah=get(gcbo,''UserData'');' ...
    'p=[0,0,fp(3),fp(4)]; set(ah,''OuterPosition'',p);'];
set (fh, 'ResizeFcn', hrscb, 'Units','pixels', 'UserData', gca);

%  label the plot
xlabel(xLabelText);
ylabel(yLabelText);
title(pTitle);
