function readMbsScriptHeaders(mbs,fileName)


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
            if ~isempty(strfind(tline,'snapshot'))||~isempty(strfind(tline,'transect'))||~isempty(strfind(tline,'stratum'))
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
                if ~isempty(strfind(value, '#'));
                    value = value(1:strfind(value, '#')-1);
                end% ignore what's written after #
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
        fclose(fid);
        
    end
end

end