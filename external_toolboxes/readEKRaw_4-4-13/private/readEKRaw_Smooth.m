function yout = readEKRaw_Smooth(yin, N, varargin)
%rhtSmooth  Smooth data using a running mean.
%   yout = readEKRaw_Smooth(yin, N, varargin) Smooths the provided vector using a
%       running mean with window width N.  Optionally uses edge trucation to
%       smooth points near the edges.
%
%   REQUIRED INPUT:
%               yin:    The data to be smoothed.  Must be a vector.
%                 N:    A scalar value set to the width of the smoothing
%                       window.  If the width value is even, then width + 1 will
%                       be used.
%
%   OPTIONAL PARAMETERS:
%       EdgeTruncate:   Set this parameter to apply smoothing to all points.  If
%                       True, and the neighborhood around a point includes a point
%                       outside the array, the nearest edge point is used to
%                       compute the smoothed result.  If EdgeTruncate is False,
%                       the end points are copied from the original array.
%
%                       For example, when smoothing an N-element vector with a 3
%                       point wide smoothing window, the first point of the
%                       result R(0) is equal to A(0) if EdgeTruncate is false, but
%                       is equal to (A(0)+A(0)+A(1))/3 if EdgeTruncate is true.
%                       In the same manner, R(N-1) is set to A(N-1)if false, and
%                       (A(N-2)+A(N-1)+A(N-1)/3) if true.
%                           Default: False
%
%            Median:    Set this parameter to true to smooth using a median
%                       filter (running median with window width N).
%                           Default: False
%
%   OUTPUT:
%       Output is a vector of smoothed data the same length as the input vector.
%
%   REQUIRES:   None
%

%   Rick Towler
%   NOAA Alaska Fisheries Science Center
%   Midwater Assesment and Conservation Engineering Group
%   rick.towler@noaa.gov
%
%   Based on smooth.m by Olof Liungman, 1997

%-

if nargin<2, error('Not enough input arguments!'), end
[rows,cols] = size(yin);
if min(rows,cols)~=1, error('Y data must be a vector!'), end
if length(N)~=1, error('N must be a scalar!'), end

%  define defaults
edgeTruncate = false;              %  default is to replace endpoints
useMedian = false;                 %  default is to use running mean smooth

%  process optional parameters
for m = 1:2:length(varargin)
    switch lower(varargin{m})
        case 'edgetruncate'
            edgeTruncate = 0 < varargin{m + 1};
        case 'median'
            useMedian = 0 < varargin{m + 1};
        otherwise
            warning('readEKRaw:ParameterError', ...
                ['Unknown property name: ' varargin{m}]);
    end
end

%  convert N from window width to half-width
winSize = N;
N = floor(N / 2);
if (N < 2)
    %  do not smooth for window sizes <= 1
    yout=yin;
    return
end

yin = (yin(:))';
l = length(yin);
yout = zeros(1,l);
temp = zeros(2 * N + 1, l - 2 * N);
temp(N+1,:) = yin(N+1:l-N);

for i = 1:N
    if edgeTruncate
        % smooth end points
        edge = (l-N:l+N) - i + 1;
        edge(edge > l) = l;
        if (useMedian)
            yout(l-i+1) = median(yin(edge));
        else
            yout(l-i+1) = sum(yin(edge)) / winSize;
        end
        edge = (-N:N) + i;
        edge(edge < 1) = 1;
        if (useMedian)
            yout(i) = median(yin(edge));
        else
            yout(i) = sum(yin(edge)) / winSize;
        end
    else
        % copy end points
        yout(i) = yin(i);
        yout(l-i+1) = yin(l-i+1);
    end
    temp(i,:) = yin(i:l-2*N+i-1);
    temp(N+i+1,:) = yin(N+i+1:l-N+i);
end
if (useMedian)
    yout(N+1:l-N) = median(temp);
else
    yout(N+1:l-N) = mean(temp);
end

if size(yout)~=[rows,cols], yout = yout'; end

