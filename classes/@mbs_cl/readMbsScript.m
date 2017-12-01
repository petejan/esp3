function readMbsScript(mbs,dataroot,fileName)

%% Read mbs file

[~,MbsId]=fileparts(fileName);

mbs.Header=mbs_header_cl();
mbs.Header.MbsId=MbsId;
mbs.Header.Script = fileName;
mbs.Input=mbs_input_cl();


%key_fields={'snapshot','stratum','transect','length','absorption'};

sn=[];
st='';
tr=[];

if ~exist(fileName,'file')
    error([fileName ' does not exist']);
else
    fid=fopen(fileName,'r+');
    if fid==-1
        error(['Unable to open ' fileName]);
    else
        i = 1;  tline = fgetl(fid);
        while 1
            
            if ~ischar(tline)
                break; % end of file
            end
            
            if isempty(tline)
                tline = fgetl(fid);
                continue;
            end
            
            if strncmp(strrep(tline,' ',''),'#',1)
                tline = fgetl(fid);
                continue;  % ignore commented lines
            end
            
            if contains(tline,'snapshot')
                sn = str2double(tline(strfind(tline,':')+2:end));tline = fgetl(fid);
                continue;
            end
            
            if contains(tline,'stratum')
                st = tline(strfind(tline,':')+2:end);tline = fgetl(fid);
                continue;
            end
            
            if contains(tline,'transect')
                tr = str2double(tline(strfind(tline,':')+2:end));tline = fgetl(fid);
                ab=nan;
                ln=nan;
                continue;
            end
            
            if contains(tline,'absorption')&&~contains(tline,'default_absorption');
                if ~contains(tline,'#')
                    ab = tline(strfind(tline,':')+2:end);
                else
                    ab = tline(strfind(tline,':')+2:strfind(tline,'#')-1);
                end
                tline = fgetl(fid);
                continue;
            end
            
            if contains(tline,'length')
                ln = tline(strfind(tline,':')+2:end);
                tline = fgetl(fid);
                continue;
            end
            
            if contains(tline, ': ')
                name = tline(1: strfind(tline, ': ')-1);
                name=strrep(name,' ','');
                value = tline(strfind(tline, ': ')+2:end);
                if contains(value, '#'); value = value(1:strfind(value, '#')-1); end;% ignore what's written after #
                if  ~isnan(str2double(value))
                    value=str2double(value);
                end
                if  ~isempty(value)
                    mbs.Header.(name) =value;  % save mbs overall specifications
                else
                    mbs.Header.(name) ='';  % save mbs overall specifications
                end
                tline = fgetl(fid);
                continue;
            end
            
            if ~isempty(sn)&&~isempty(tr)&&~strcmp(st,'')
                
                mbs.Input.snapshot(i) = sn;
                mbs.Input.stratum{i} = st;
                mbs.Input.transect(i) = tr;
                mbs.Input.absorption(i) = ab;
                mbs.Input.length(i) = ln;
                
                [out,pos]=textscan(tline,'%s %.0f %s %s %s',1);
                
                [mbs.Input.dfileDir{i},tmp] = fileparts(out{1}{1});
                mbs.Input.channel(i) = out{2};
                mbs.Input.calRev{i} = out{3}{1};
                mbs.Input.botRev{i} = out{4}{1};
                if ~isempty(out{5})
                    mbs.Input.regRev{i} = out{5}{1};
                else
                    mbs.Input.regRev{i} = [];
                end
                
                if pos<=length(tline)
                    str_rem=tline(pos+1:end);
                end
                
                if isempty(str_rem)
                    mbs.Input.reg{i} = [];
                    mbs.Input.algo{i}= [];
                else
                    str_rem=strrep(str_rem,' ','');
                    expr='\d*\([\-]*\d*\)';
                    RegCVS = regexp(str_rem,expr,'match');
                    for uuk=1:length(RegCVS)
                        mbs.Input.reg{i}(uuk) = getRegSpecFromRegString(RegCVS{uuk});
                    end
                    
                    expr='alg';
                    mbs.Input.algo{i} = regexp(str_rem,expr,'match');
                end
                
                idx_slash=strfind(mbs.Input.dfileDir{i},'/');
                
                mbs.Input.transducer{i} = mbs.Input.dfileDir{i}(idx_slash(end)+1:end);
                mbs.Input.dfileNum(i) = str2double(tmp(2:end));
                
                mbs.Input.crestDir{i}=fullfile(dataroot,mbs.Input.dfileDir{i});
                
                ifile_info=parse_ifile(fullfile(mbs.Input.crestDir{i},sprintf('i%07d', mbs.Input.dfileNum(i))));
                
                mbs.Input.rawDir{i}=fullfile(mbs.Input.crestDir{i},ifile_info.rawSubDir);
                mbs.Input.rawFileName{i}=ifile_info.rawFileName;
                mbs.Input.rawSubDir{i}=ifile_info.rawSubDir;
                mbs.Input.calCrest(i)=ifile_info.Cal_crest;
                mbs.Input.calRaw{i}=struct('G0',ifile_info.G0,'SACORRECT',ifile_info.SACORRECT);
                mbs.Input.EsError(i)=ifile_info.es60error_offset;
                i = i+1;
                
                tline = fgetl(fid);
                if ~ischar(tline)
                    break; % end of file
                end
                
            else
                tline = fgetl(fid);
            end
        end
        
        
        
        disp('read mbs Script and saved in mbs.Input')
        fclose(fid);
        
    end
end

end