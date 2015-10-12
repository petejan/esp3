function readMbsScript(mbs,dataroot,fileName)

%% Read mbs file
mbs.input.Script = fileName;
[~,MbsId]=fileparts(fileName);

mbs.input.header.MbsId=MbsId;
mbs.input.header.title='';
mbs.input.header.main_species='';
mbs.input.header.voyage='';
mbs.input.header.areas='';
mbs.input.header.author='';
mbs.input.header.created='';
mbs.input.header.vertical_slice_size=500;
mbs.input.header.comments='';
mbs.input.header.use_exclude_regions=true;
mbs.input.header.default_absorption=8;
mbs.input.header.es60_correction= false;

mbs.input.data.snapshot=[];
mbs.input.data.stratum={};
mbs.input.data.transect=[];
mbs.input.data.dfileDir={};
mbs.input.data.crestDisr={};
mbs.input.data.cawDir={};
mbs.input.data.channel=[];
mbs.input.data.calRev={};
mbs.input.data.BotRev={};
mbs.input.data.rawFileName={};
mbs.input.data.rawSubDir={};
mbs.input.data.Algo={};
mbs.input.data.CalCrest=[];
mbs.input.data.CalRaw={};
mbs.input.data.absorbtion=[];
mbs.input.data.length=[];


%key_fields={'snapshot','stratum','transect','length','absorbtion'};

sn=[];
st='';
tr=[];

if ~exist(fileName,'file');
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
            
            if isempty(tline);
                tline = fgetl(fid);
                continue;
            end
            
            if strncmp(strrep(tline,' ',''),'#',1);
                tline = fgetl(fid);
                continue;  % ignore commented lines
            end;
            
            if strfind(tline,'snapshot')
                sn = str2double(tline(strfind(tline,':')+2:end));tline = fgetl(fid);
                continue;
            end
            
            if strfind(tline,'stratum');
                st = tline(strfind(tline,':')+2:end);tline = fgetl(fid);
                continue;
            end
            
            if strfind(tline,'transect');
                tr = str2double(tline(strfind(tline,':')+2:end));tline = fgetl(fid);
                ab=nan;
                ln=nan;
                continue;
            end
            
            if strfind(tline,'absorbtion');
                ab = tline(strfind(tline,':')+2:end);
                tline = fgetl(fid);
                continue;
            end
            
            if strfind(tline,'length');
                ln = tline(strfind(tline,':')+2:end);
                tline = fgetl(fid);
                continue;
            end
            
            if ~isempty(strfind(tline, ': '))
                name = tline(1: strfind(tline, ': ')-1);
                name=strrep(name,' ','');
                value = tline(strfind(tline, ': ')+2:end);
                if ~isempty(strfind(value, '#')); value = value(1:strfind(value, '#')-1); end;% ignore what's written after #
                if  ~isnan(str2double(value))
                    value=str2double(value);
                end
                if  ~isempty(value);
                    mbs.input.header.(name) =value;  % save mbs overall specifications
                else
                    mbs.input.header.(name) ='';  % save mbs overall specifications
                end
                tline = fgetl(fid);
                continue;
            end
            
            if ~isempty(sn)&&~isempty(tr)&&~strcmp(st,'');
                
                mbs.input.data.snapshot(i) = sn;
                mbs.input.data.stratum{i} = st;
                mbs.input.data.transect(i) = tr;
                mbs.input.data.absorbtion(i) = ab;
                mbs.input.data.length(i) = ln;
                
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
                    expr='alg';
                    mbs.input.data.Algo{i} = regexp(str_rem,expr,'match');
                end
                
                idx_slash=strfind(mbs.input.data.dfileDir{i},'/');
                
                mbs.input.data.transducer{i} = mbs.input.data.dfileDir{i}(idx_slash(end)+1:end);
                mbs.input.data.dfile(i) = str2double(tmp(2:end));
                
                mbs.input.data.crestDir{i}=fullfile(dataroot,mbs.input.data.dfileDir{i});
                
                ifile_info=parse_ifile(mbs.input.data.crestDir{i},mbs.input.data.dfile(i));
                mbs.input.data.rawDir{i}=fullfile(mbs.input.data.crestDir{i},ifile_info.rawSubDir);
                mbs.input.data.rawFileName{i}=ifile_info.rawFileName;
                mbs.input.data.rawSubDir{i}=ifile_info.rawSubDir;
                mbs.input.data.CalCrest(i)=ifile_info.Cal_crest;
                mbs.input.data.CalRaw{i}=struct('G0',ifile_info.G0,'SACORRECT',ifile_info.SACORRECT);
                                
                i = i+1;
                
                tline = fgetl(fid);
                if ~ischar(tline)
                    break; % end of file
                end
      
            else
                tline = fgetl(fid);
            end
        end
        
        
        
        disp('read mbs Script and saved in mbs.input.data')
        fclose(fid);
        
    end
end

end