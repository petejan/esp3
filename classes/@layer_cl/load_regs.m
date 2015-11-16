function load_regs(layer)

path=layer.PathToFile;
if length(layer.Filename)>1
    file=[layer.Filename{1} '_' layer.Filename{end}];
else
    file=layer.Filename{1};
end


reg_filename=fullfile(path,'echoanalysisfiles',[file '.mat']);

if exist(reg_filename,'file')==2
    load(reg_filename);
else
    return;
end

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