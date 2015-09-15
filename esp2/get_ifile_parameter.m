function variable_value = get_ifile_parameter(file,variable_name)


%if a d-,n- or t- file was specified instead of an i-file use the corresponding i-file
tok = file(end-7);
num = file((end-6):end);
if (tok == 'd' || tok == 'n' || tok == 't') && ~isempty(str2double(num))
    file(end-7) = 'i';
end


fid = fopen(file);
if fid == -1
    error(['File not found or permission denied for ' file]);
end
variable_value = [];

while 1
    if feof(fid)
        break;
    end
    line = fgetl(fid);
    idx_str=strfind(line,variable_name);
    if ~isempty(idx_str)
       idx_str=strfind(line,'=');
       if length(line)>idx_str
        r=line(idx_str+1:end);
        if (~isnan(str2double(r)))       
            variable_value = str2double(r); 
        else                                   
            variable_value = deblank(r);
        end
       end
       break;
    end
end


fclose(fid);