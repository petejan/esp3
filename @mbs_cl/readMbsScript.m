function readMbsScript(mbs,dataroot,fileName)

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
mbs.input.data.vertical_slice_size=500;

if ~exist(fileName,'file');
    error([fileName ' does not exist']);
else
    fid=fopen(fileName,'r+');
    if fid==-1
        error(['Unable to open ' fileName]);
    else
        i = 1;        
        tline = fgetl(fid);
        while 1       
            if ~ischar(tline)
                break; % end of file
            end         
            
            if strncmp(strrep(tline,' ',''),'#',1);
                tline = fgetl(fid);
                continue;  % ignore commented lines
            end;    
            
            if strfind(tline,'snapshot')
                while 1 
                    sn = str2double(tline(strfind(tline,':')+2:end));
                    tline = fgetl(fid);       
                    % loop through all snapshots
                    if ~ischar(tline); break; end;      % end of file
                    
                    if isempty(tline); tline = fgetl(fid); continue; end    % skip empty rows
                    
                    if strncmp(tline,'#',1); tline = fgetl(fid); continue; end;     % ignore commented lines
                    
                    if strfind(tline,'snapshot'); 
                        break; 
                    end
                    
                    if strfind(tline,'stratum');
                        st = tline(strfind(tline,':')+2:end);
                    end
                    
                    tline = fgetl(fid);
                    while 1                             % loop through all strata
                        if ~ischar(tline); 
                            break; % end of file
                        end;                          
                        if isempty(tline)
                            tline = fgetl(fid); continue; % skip empty rows       
                        end    
                        if strncmp(tline,'#',1) 
                            tline = fgetl(fid); continue;  % ignore commented lines
                        end  
                        if ~isempty(strfind(tline,'snapshot')) || ~isempty(strfind(tline,'stratum'))
                            break; 
                        end
                        if strfind(tline,'transect');
                            t = str2double(tline(strfind(tline,':')+2:end));
                            tline = fgetl(fid);
                            while 1                     % loop through all transects
                                if ~ischar(tline) 
                                    break; % end of file
                                end; 
                                if isempty(tline)
                                    tline = fgetl(fid); 
                                    continue;% skip empty rows
                                end    
                                if strncmp(tline,'#',1)
                                    tline = fgetl(fid);  % ignore commented lines
                                    continue;
                                end             
                                if  ~isempty(strfind(tline,'snapshot')) || ~isempty(strfind(tline,'stratum')) || ~isempty(strfind(tline,'transect')); 
                                    break; 
                                end
                                mbs.input.data.snapshot(i) = sn;
                                mbs.input.data.stratum{i} = st;
                                mbs.input.data.transect(i) = t;
                                
                                [out,pos]=textscan(tline,'%s %.0f %s %s %s',1);
                                                               
                                [mbs.input.data.dfileDir{i},tmp] = fileparts(out{1}{1});
                                mbs.input.data.channel(i) = out{2};
                                mbs.input.data.calRev{i} = out{3}{1};
                                mbs.input.data.BotRev{i} = out{4}{1};
                                if ~isempty(out{5})
                                    mbs.input.data.RegRev{i} = out{5}{1};
                                else
                                    mbs.input.data.RegRev{i} = [];
                                end
                                
                                if pos<=length(tline)
                                str_rem=tline(pos+1:end);
                                end
                                
                                if isempty(str_rem)            
                                    mbs.input.data.Reg{i} = [];
                                else
                                    str_rem=strrep(str_rem,' ','');
                                     expr='\d*\([\-]*\d*\)';                               
                                    mbs.input.data.Reg{i} = regexp(str_rem,expr,'match');
                                end
                                

                                
                                idx_slash=strfind(mbs.input.data.dfileDir{i},'/');
                                mbs.input.data.transducer{i} = mbs.input.data.dfileDir{i}(idx_slash(end)+1:end);
                                mbs.input.data.dfile(i) = str2double(tmp(2:end));
                                
                                mbs.crestDir=fullfile(dataroot,mbs.input.data.dfileDir{i});
                                
                                ifile_info=get_ifile_info(mbs.crestDir,mbs.input.data.dfile(i));
                                
                                mbs.rawDir=fullfile(mbs.crestDir,ifile_info.rawSubDir);
                                
                                mbs.input.data.rawFileName{i}=ifile_info.rawFileName;
                                mbs.input.data.rawSubDir{i}=ifile_info.rawSubDir;
                                
                                mbs.input.data.CalCrest(i)=ifile_info.Cal_crest;
                                mbs.input.data.CalRaw{i}=struct('G0',ifile_info.G0,'SACORRECT',ifile_info.SACORRECT);

                                tline = fgetl(fid);
                                i = i+1;
                            end
                        end
                    end
                end
            elseif isempty(tline); % skip empty rows
                tline = fgetl(fid);
                continue;             
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
            tline = fgetl(fid);
        end
        disp('read mbs Script and saved in mbs.input.data')
        fclose(fid);
        
    end
end

end