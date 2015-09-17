function readMbsScript(mbs,fileName)

%% Read mbs file
mbs.input.Script = fileName;
[~,MbsId]=fileparts(fileName);

mbs.input.data.MbsId=MbsId;
mbs.input.data.title='';
mbs.input.data.main_species='';
mbs.input.data.voyage='';
mbs.input.data.areas='';
mbs.input.data.author='';
mbs.input.data.created='';

if ~exist(fileName,'file');
    error([fileName ' does not exist']);
else
    fid=fopen(fileName,'r+');
    if fid==-1
        error(['Unable to open ' fileName]);
    else
        i = 1;
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
                break;
            end              % end of file
            if strncmp(strrep(tline,' ',''),'#',1); continue; end;     % ignore commented lines
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
                                mbs.input.data.snapshot(i) = sn;
                                mbs.input.data.stratum{i} = st;
                                mbs.input.data.transect(i) = t;
                                
                                out=textscan(tline,'%s %.0f %s %s %s %s',1);
                                
                                [mbs.input.data.dfileDir{i},tmp] = fileparts(out{1}{1});
                                idx_slash=strfind(mbs.input.data.dfileDir{i},'/');
                                mbs.input.data.transducer{i} = mbs.input.data.dfileDir{i}(idx_slash(end)+1:end);
                                mbs.input.data.dfile(i) = str2double(tmp(2:end));
                                mbs.input.data.channel(i) = out{2};
                                mbs.input.data.calRev{i} = out{3}{1};
                                mbs.input.data.BotRev{i} = out{4}{1};
                                mbs.input.data.RegRev{i} = out{5}{1};
                                mbs.input.data.Reg{i} = out{6}{1};
                                tline = fgetl(fid);
                                i = i+1;
                            end
                        end
                    end
                end
            elseif isempty(tline); continue;             % skip empty rows
            else
                name = tline(1: strfind(tline, ': ')-1);
                name=strrep(name,' ','');
                value = tline(strfind(tline, ': ')+2:end);
                if ~isempty(strfind(value, '#')); value = value(1:strfind(value, '#')-1); end;% ignore what's written after #
                if  ~isnan(str2double(value))
                    value=str2double(value);
                end
                if  ~isempty(value);
                    mbs.input.data.(name) =value;  % save mbs overall specifications
                else
                    mbs.input.data.(name) ='';  % save mbs overall specifications
                end
            end
        end
        disp('read mbs Script and saved in mbs.input.data')
        fclose(fid);
        
    end
end

end