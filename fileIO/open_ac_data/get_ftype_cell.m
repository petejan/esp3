function ftype=get_ftype_cell(files)

if ~iscell(files)
    files={files};
end
ftype=cell(1,numel(files));

for ifi=1:numel(files)
    ftype{ifi}=get_ftype(files{ifi});
end

end