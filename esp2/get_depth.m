% get_depth
% Returns a vector of numbers, where
% each number represents the depth of the 
% transducer in metres.
% Filenumber can be scalar or vector.
%
% get_depth(PathToFile, FileNumber)

% creates a temporary depth file produced by treport
% e.g.  treport i0000xxx t0000xxx > out.txt
% reads in this file and strips out the extraneous information.
%

% Created by Adam Dunford October 2000

function depth = get_depth(PathToFile, FileNumber)

depth = [];

for i = FileNumber

    %Create temporary depth file
    ifilename = [PathToFile, 'i', sprintf('%07d',i)];
    tfilename = [PathToFile, 't', sprintf('%07d',i)];
    if ~exist(tfilename,'file')
        disp(['Warning: file ' tfilename ' does not exist']);
        depth = [];
        return;
    end

    dfilename = get_tempname;

    cmd = ['treport -s ',ifilename,' ',tfilename,' > ' dfilename];
    [status, result] = unix(cmd);
    if ~isempty(findstr('Segmentation fault',result))
       warning(['Segmentation fault when running treport on ' tfilename])
    end

    %Read in file, and extract the depth, in column 8
    d = load(dfilename);
    depth = [depth; d(:,8)];
    
    %remove temp file
    delete(dfilename);
end

