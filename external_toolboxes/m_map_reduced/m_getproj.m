
%---------------------------------------------------------
function projections=m_getproj;
% M_GETPROJ Gets a list of the different projection routines
%           and returns a structure containing both their
%           names and the formal name of the projection.
%           (used by M_PROJ).

% Rich Pawlowicz (rich@ocgy.ubc.ca) 9/May/1997
%
% 9/May/97 - fixed paths for Macs (thanks to Dave Enfield)
%
% 7/05/98 - VMS pathnames (thanks to Helmut Eggers)

% Get all the projections

lpath=which('m_proj');
fslashes=findstr(lpath,'/');
bslashes=findstr(lpath,'\');
colons=findstr(lpath,':');
closparantheses=findstr(lpath,']');
if ~isempty(fslashes),
  lpath=[ lpath(1:max(fslashes)) 'private/'];
elseif ~isempty(bslashes),
  lpath=[ lpath(1:max(bslashes)) 'private\'];
elseif ~isempty(closparantheses),       % for VMS computers only, others don't use ']' in filenames
  lpath=[ lpath(1:max(closparantheses)-1) '.private]'];
else,
  lpath=[ lpath(1:max(colons)) 'private:'];
end;

w=dir([lpath 'mp_*.m']);

if isempty(w), % Not installed correctly
  disp('**********************************************************');
  disp('* ERROR - Can''t find anything in a /private subdirectory *');
  disp('*         m_map probably unzipped incorrectly - please   *');
  disp('*         unpack again, preserving directory structure   *');
  disp('*                                                        *');
  disp('*         ...Abandoning m_proj now.                      *');
  error('**********************************************************');
end;  
	
l=1;
projections=[];
for k=1:length(w),
 funname=w(k).name(1:(findstr(w(k).name,'.'))-1);
 projections(l).routine=funname;
 eval(['names= ' projections(l).routine '(''name'');']);
 for m=1:length(names);
   projections(l).routine=funname;
   projections(l).name=names{m};
   l=l+1;
 end;
end;