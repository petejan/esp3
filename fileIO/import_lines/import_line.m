function line=import_line(PathToFile,Filename)
[~,~,ext]=fileparts(Filename);
if ~(exist(fullfile(PathToFile,Filename),'file')==2)
    switch(ext)
        case '.evl'
            line=create_line_from_evl(fullfile(PathToFile,Filename));
        case {'.txt'; '.dat'}
            line=create_line_from_rbr(fullfile(PathToFile,Filename));
        case {'.mat'}
            line=create_line_from_rbr_mat(fullfile(PathToFile,Filename));
        case {'.cnv'}
            line=create_line_from_seabird(fullfile(PathToFile,Filename));
    end
else
    line=[];
end
end