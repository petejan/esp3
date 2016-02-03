function regfile=load_regfile(path,file)

reg_filename=find_regfile(path,file);

if ~isempty(reg_filename)
    tmp=load(reg_filename);
    regfile=tmp.regfile;
else
    regfile=[];
    return;
end
