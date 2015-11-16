function compile_echo(root_folder,nomFunc)

folders=folders_list(root_folder);
switch computer
    case 'PCWIN'
        str{1} = sprintf('mcc  -M ''-win32'' -v -m %s ', nomFunc);
    case 'PCWIN64'
        str{1} = sprintf('mcc -v -m %s ', fullfile(root_folder,nomFunc));
    case 'GLNX86'
        str{1} = sprintf('mcc -v -m %s ', fullfile(root_folder,nomFunc));
    case 'GLNXA64'
        str{1} = sprintf('mcc -v -m %s ', fullfile(root_folder,nomFunc));
    otherwise
        str{1} = sprintf('mcc -v -m %s ', fullfile(root_folder,nomFunc));
end

for i= 1:(length(folders))
    str{end+1}=sprintf('-a %s ',folders{i});
end

str{end+1}='-w enable ';

str_mcc =[str{:}];
disp(str_mcc);
eval(str_mcc)

end