function m_proj(proj,varargin)
% M_PROJ  Initializes map projections info, putting the result into a structure
%
%         M_PROJ('get') tells you the current state
%         M_PROJ('set') gives you a list of all possibilities
%         M_PROJ('set','proj name') gives info about a projection in the 
%                                   'get' list.
%         M_PROJ('proj name','property',value,...) initializes a projection.
%
%
%         see also M_GRID, M_LL2XY, M_XY2LL.

% Rich Pawlowicz (rich@ocgy.ubc.ca) 2/Apr/1997
%
% This software is provided "as is" without warranty of any kind. But
% it's mine, so you can't sell it.
%
% 20/Sep/01 - Added support for other coordinate systems.
% 25/Feb/07 - Swapped "get" and "set" at lines 34 and 47 
%		to make it consistent with the help 
%		(and common Matlab style)
%	    - Added lines 62-70 & 74 
%		to harden against error when no proj is set
%             (fixes thanks to Lars Barring)

global MAP_PROJECTION MAP_VAR_LIST MAP_COORDS

% Get all the projections
projections=m_getproj;

if nargin==0, proj='usage'; end;

proj=lower(proj);

switch proj,

  case 'set',              % Print out their names
    if nargin==1,
      disp(' ');
      disp('Available projections are:'); 
      for k=1:length(projections),
        disp(['     ' projections(k).name]);
      end;
    else
      k=m_match(varargin{1},projections(:).name);
      eval(['X=' projections(k).routine '(''set'',projections(k).name);']);
      disp(X);
    end;

  case 'get',              % Get the values of all set parameters
    if nargin==1,
      if isempty(MAP_PROJECTION),
         disp('No map projection initialized');
         m_proj('usage');
      else
         k=m_match(MAP_PROJECTION.name,projections(:).name);
         eval(['X=' projections(k).routine '(''get'');']);
         disp('Current mapping parameters -');
         disp(X);
      end;
    else
      if isempty(MAP_PROJECTION),          
        k=m_match(varargin{1},projections(:).name);
        eval(['X=' projections(k).routine '(''set'',projections(k).name);']);
        X=strvcat(X, ...
                  ' ', ...
                  '**** No projection is currently defined      ****', ...
                  ['**** USE "m_proj(''' varargin{1} ''',<see options above>)" ****']);
        disp(X);
      else
	k=m_match(varargin{1},projections(:).name);
	eval(['X=' projections(k).routine '(''get'');']);
	disp(X);
      end;	
    end;

  case 'usage',
    disp(' ');
    disp('Possible calling options are:');
    disp('  ''usage''                    - this list');
    disp('  ''set''                      - list of projections');
    disp('  ''set'',''projection''         - list of properties for projection');
    disp('  ''get''                      - get current mapping parameters (if defined)');
    disp('  ''projection'' <,properties> - initialize projection\n');

 otherwise                % If a valid name, give the usage.
    k=m_match(proj,projections(:).name);
    MAP_PROJECTION=projections(k);
        
    eval([ projections(k).routine '(''initialize'',projections(k).name,varargin{:});']);

    % With the projection store what coordinate system we are using to define it.
    if isempty(MAP_COORDS),
      m_coord('geographic');
    end;  
    MAP_PROJECTION.coordsystem=MAP_COORDS;
    
end;



%----------------------------------------------------------
function match=m_match(arg,varargin);
% M_MATCH Tries to match input string with possible options

% Rich Pawlowicz (rich@ocgy.ubc.ca) 2/Apr/1997

match=strmatch(lower(arg),cellstr(lower(char(varargin))));

if length(match)>1,
  error(['Projection ''' arg ''' not a unique specification']);
elseif isempty(match),
  error(['Projection ''' arg ''' not recognized']);
end;
