%                         gausjoin.m%  Function to calculate a gaussian smoothing transfer function%  for putting two piecewise curves or several sets of two piecewise%  curves together%%    y1 and y2 are vectors or arrays that are functions of x%    tranpt is the value of x at which y1 transitions to y2%    tranwidth is the range in x values over which the transition occurs%%    x need not be monotonic, but will transition at first x>xtrans!!%    x need not be aligned with y1, y1 must be aligned with y2.%    x muxt be the same legnth as y1 and y2.%    x can miss transition point without generating error.%   %   If x is less than 5 points, doesnot do transition (For Now)%%    Ira Leifer                             8/14/98%%function y = gausjoin(x,y1,y2,tranpt,tranwidth); function y = gausjoin(x,y1,y2,tranpt,tranwidth);if nargin~=5, disp('Too few arguments'); return; end;sizx = zeros(1,2); sizy1 = sizx; sizy2 = sizx;sizx=size(x); sizy1 = size(y1); sizy2 = size(y2);if min(sizx) ~= 1, disp('X must be one dimensional!!!'); return; end;if max(sizx) ~= max(sizy2) | max(sizx)~=max(sizy2),                  disp('All Must be the same length!!!'  ); return; end;if min(x)<tranpt & max(x)<tranpt, y=y1; return; end;if min(x)>tranpt & max(x)>tranpt, y=y2; return; end;if find(max(sizx)==sizx) ~= find(max(sizy1)==sizy1), y1 = y1';sizy1=size(y1); end;if find(max(sizx)==sizx) ~= find(max(sizy2)==sizy2), y2 = y2';sizy2=size(y2); end;if length(x)<5,                                            % only 5 points   i = find(x<=tranpt); j = find(x >tranpt);   y = [y1(i) y2(j)];   return;end;if min(x)> tranpt-tranwidth/2,  y = y2; return; end;if max(x)< tranpt+tranwidth/2,  y = y1; return; end; % Transition Out of Range%disp(['x = ' num2str(sizx( 1)) ' ' num2str(sizx( 2))]);%disp(['y1= ' num2str(sizy1(1)) ' ' num2str(sizy1(2))]);%disp(['y2= ' num2str(sizy2(1)) ' ' num2str(sizy2(2))]);Wid = min(sizy1);%  disp(['Wid = ' num2str(Wid)]);Pts = max(sizx );%  disp(['Pts = ' num2str(Pts)]);% if (Pts==j2 & j~=Pts) | (Pts==i2 & i~=Pts),%    x=x'; [i j]=size(x); % disp(['Rotated']); % Rotate x to same dir as y1% end;Transfer = ones(sizx);  CompTransfer = zeros(sizy1);z        = ones(sizx);Tranwidth = tranwidth/2;i=find( x>= (tranpt-Tranwidth) );i=min(i):length(x);if Tranwidth~=0,   z = (x(i)-x(i(1)))/Tranwidth;   % Remove Offset, scale Transition to 0:1   z = exp(-z.*z);   Transfer(i) = z;else,   Transfer(i) = zeros(i);         % Step Function Transferend;if sizy1(1)>sizy1(2), Transfer=Transfer*ones(1,Wid);else                , Transfer=ones(Wid,1)*Transfer;end;y = Transfer.*y1+(1-Transfer).*y2;