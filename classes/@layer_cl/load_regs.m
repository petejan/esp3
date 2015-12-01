function load_regs(layer)

path=layer.PathToFile;
if length(layer.Filename)>1
    file=[layer.Filename{1} '_' layer.Filename{end}];
else
    file=layer.Filename{1};
end

regfile=load_regfile(path,file);

if ~isempty(regfile)
freqs=regfile.frequency;

for i=1:length(layer.Frequencies)
    idx_reg=find(layer.Frequencies(i)==freqs);
    
    if isfield(regfile,'Bottom')
        layer.Transceivers(i).setBottom(regfile.Bottom(idx_reg));
    end
    if ~isempty(idx_reg)
        layer.Transceivers(i).add_region(regfile.Regions{idx_reg},'Origin','Saved')
        
    end
    
end
end


end