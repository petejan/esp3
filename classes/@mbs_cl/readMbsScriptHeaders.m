function readMbsScriptHeaders(mbs,fileName)

%% Read mbs file header
[~,MbsId]=fileparts(fileName);

mbs_header=mbs_header_cl();
mbs_header.MbsId=MbsId;
mbs_header.Script=fileName;

if ~exist(fileName,'file')
    error([fileName ' does not exist']);
else
    fid=fopen(fileName,'r+');
    if fid==-1
        error(['Unable to open ' fileName]);
    else
        while 1
            % this while loop loops over the whole script and puts all
            % the information into the mbs.input structure
            tline = fgetl(fid);
            if ~ischar(tline)
                break;
            end              % end of file
            
            if strncmp(strrep(tline,' ',''),'#',1)
                continue
            end   % ignore commented lines
            if contains(tline,'snapshot')||contains(tline,'transect')||contains(tline,'stratum')
                break;
            elseif isempty(tline)
                continue;             % skip empty rows
            else
                name = tline(1: strfind(tline, ': ')-1);
                name=strrep(name,' ','');
                value = tline(strfind(tline, ': ')+2:end);
                if isempty(value)
                    continue;
                end
                if contains(value, '#')
                    value = value(1:strfind(value, '#')-1);
                end% ignore what's written after #
                if  ~isnan(str2double(value))
                    value=str2double(value);
                end
                if  ~isempty(value)
                    mbs_header.(name) =value;  % save mbs overall specifications
                else
                    mbs_header.(name) ='';  % save mbs overall specifications
                end
            end
        end
        fclose(fid);
        
    end
end

mbs.Header=mbs_header;
end

