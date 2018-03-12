function line=import_line(PathToFile,Filename)

if nargin==1
    fileN=PathToFile;
else
    fileN=fullfile(PathToFile,Filename);
end
try
    [~,~,ext]=fileparts(fileN);
    if (exist(fileN,'file')==2)
        switch(ext)
            case '.evl'
                line=create_line_from_evl(fileN);
            case {'.txt'; '.dat'}
                line=create_line_from_rbr(fileN);
            case {'.mat'}
                line=create_line_from_rbr_mat(fileN);
            case {'.cnv'}
                line=create_line_from_seabird(fileN);
            case '.log'
                line=create_line_from_SupervisorLog(fileN);
            case {'.xls' '.xlsx' '.csv'}
                line=create_line_from_xls(fileN);
            otherwise
                line=[];
        end
    else
        line=[];
    end
catch err
    warning('Could not load line from file: %s\n',Filename);
    [~,f_temp,e_temp]=fileparts(err.stack(1).file);
    fprintf('Error in file %s, line %d\n',[f_temp e_temp],err.stack(1).line);
    disp(err.message);
    line=[];
end
end