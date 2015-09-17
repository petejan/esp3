function repositoryName = getCVSRepository

% Usage: repositoryName = getCVSRepository
% Returns the name of the cvs repository
% where the bottom and region files are stored.

if ~isempty(strfind(computer, 'LNX'))          %Linux
    repositoryName = '/home/acdc/esp2files';
elseif ~isempty(strfind(computer, 'WIN'))      %Windows
%     s=license('inuse','MATLAB');
%     repositoryName = [':ext:' s.user '@wellacoustic:/home/acdc/esp2files'];
    repositoryName = ':local:Z:\';
else
    error('Unable to determine cvs repository');
end
  