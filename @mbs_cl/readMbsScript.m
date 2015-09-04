 function readMbsScript(mbs,varargin)  % Reads an MBS script (either
            workingPath = pwd;           
            if nargin == 2
                    mbsId = varargin{1};
                    rev = [];

            elseif nargin == 3
                if  ischar(varargin{1})      % get the right one for mbs id and revision number
                    mbsId = varargin{1};
                    rev = varargin{2};
                else
                    mbsId = varargin{2};
                    rev = varargin{1};
                end
            end
            
            %% checkout mbs script from CVS
            if exist('mbsId')
                if min([isstrprop(mbsId(1:end-14) , 'alpha'), isstrprop(mbsId(end-13:end) , 'digit')]) ~= 1;  % check if string is of MBS ID type
                    mbsId = [];
                    error('MbsID is of the wrong format');
                else     % checkout mbs spec
                    outDir = [get_tempname '/'];
                    %run command - make output directory for cvs
                    if ~mkdir(outDir)
                        error('Unable to create temporary cvs directory');
                    end
                    fileName = [outDir '/mbs/' mbsId];
  
                    if isempty(rev); % Get latest revision
                        command = ['cvs -d ' getCVSRepository ' checkout mbs/' mbsId]; 
                    else             % Get specified revision
                        command = ['cvs -d ' getCVSRepository ' checkout -r ' num2str(rev) ' mbs/' mbsId];
                    end
                    %Run command - export mbs script from CVS
                    cd(outDir);
                    
                    [~, b] = system(command, '-echo');
                    if ~isempty(strfind(b, 'cannot'));  
                        error(b); 
                    end
                    cd(workingPath);
                end
            end
            
            
            %% Read mbs file
            mbs.input.Script = fileName;
            if ~exist(fileName,'file');
                error([fileName ' does not exist']);
            else
                fid=fopen(fileName,'r+');
                if fid==-1
                    error(['Unable to open ' fileName]);
                else
                    i = 1;
                    while 1
                        % this while loop loops over the whole script and puts all
                        % the information into the mbs.input structure
                        tline = fgetl(fid);
                        if ~ischar(tline); break; end;              % end of file
                        if strncmp(tline,'#',1); continue; end;     % ignore commented lines
                        if strfind(tline,'snapshot')
                            sn = str2double(tline(strfind(tline,':')+2:end));
                            tline = fgetl(fid);
                            while 1                                 % loop through all snapshots
                                if ~ischar(tline); break; end;      % end of file
                                if isempty(tline); tline = fgetl(fid); continue; end    % skip empty rows
                                if strncmp(tline,'#',1); tline = fgetl(fid); continue; end;     % ignore commented lines
                                if strfind(tline,'snapshot'); break; end
                                if strfind(tline,'stratum');
                                    st = tline(strfind(tline,':')+2:end);
                                end
                                tline = fgetl(fid);
                                while 1                             % loop through all strata
                                    if ~ischar(tline); break; end;  % end of file
                                    if isempty(tline); tline = fgetl(fid); continue; end    % skip empty rows
                                    if strncmp(tline,'#',1); tline = fgetl(fid); continue; end;     % ignore commented lines
                                    if strfind(tline,'stratum'); break; end
                                    if strfind(tline,'transect');
                                        t = str2double(tline(strfind(tline,':')+2:end));
                                        tline = fgetl(fid);
                                        while 1                     % loop through all transects
                                            if ~ischar(tline); break; end; % end of file
                                            if isempty(tline); tline = fgetl(fid); continue; end    % skip empty rows
                                            if strncmp(tline,'#',1); tline = fgetl(fid); continue; end;     % ignore commented lines
                                            if  ~isempty(strfind(tline,'snapshot')) || ~isempty(strfind(tline,'stratum')) || ~isempty(strfind(tline,'transect')); break; end
                                            mbs.input.data.snapshot(i,1) = sn;
                                            mbs.input.data.stratum{i,1} = st;
                                            mbs.input.data.transect(i,1) = t;
                                            [tok,tline] = strtok(tline,' ');
                                            [mbs.input.data.dfileDir{i,1},tmp] = fileparts(tok);
                                            mbs.input.data.transducer{i,1} = mbs.input.data.dfileDir{i}(9:end);
                                            mbs.input.data.dfile(i,1) = str2double(tmp(2:end));
                                            [tok,tline] = strtok(tline, ' ');
                                            mbs.input.data.channel(i,1) = str2double(tok);
                                            [tok,tline] = strtok(tline, ' ');
                                            mbs.input.data.calRev(i,1) = str2double(tok);
                                            [tok,tline] = strtok(tline, ' ');
                                            mbs.input.data.BotRev(i,1) = str2double(tok);
                                            [tok,tline] = strtok(tline, ' ');
                                            mbs.input.data.RegRev(i,1) = str2double(tok);
                                            [tok,~] = strtok(tline, ' ');
                                            mbs.input.data.Reg{i,1} = tok;
                                            tline = fgetl(fid);
                                            i = i+1;
                                        end
                                    end
                                end
                            end
                        elseif isempty(tline); continue;             % skip empty rows
                        else
                            name = tline(1: strfind(tline, ': ')-1);
                            value = tline(strfind(tline, ': ')+2:end);
                            if ~isempty(strfind(value, '#')); value = value(1:strfind(value, '#')-1); end;% ignore what's written after #
                            if ~isempty(str2double(value)) && isempty(strfind(value, '/')); %value = str2double(value); % convert to number if it's one
                                mbs.input.data.(name) =value;  % save mbs overall specifications
                            else
                                 mbs.input.data.(name) ='';  % save mbs overall specifications
                            end
                        end
                    end
                    disp('read mbs Script and saved in mbs.input.data')
                    fclose(fid);
                    if ~isempty(strfind(computer, 'WIN')) %cygwin cvs uses linux paths
                        [~, result]=system(['cygpath -u ' outDir]); %so convert outDir
                        outDir = result;
                    end
                    system(['rm -Rf ' outDir]); %Remove temp CVS dir
                end
            end
        end