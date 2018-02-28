clear all;
p = mfilename('fullpath');
[path_classes,~,~]=fileparts(p);
file_summary=fullfile(path_classes,'class_summary.txt');


[pathdir,dir_name]=find_dir_recursive(path_classes,'^@');
fid{1}=1;
fid{2}=fopen(file_summary,'w');


for ii=1:length(fid)
    for i=1:length(pathdir)
        class_curr=dir_name{i}(2:end);
        curr_props=properties(class_curr);
        curr_methods=methods(class_curr,'-full');
        fprintf(fid{ii},'---------------------------------------------------------\n');
        fprintf(fid{ii},'CLASS %s:\n',class_curr);
        fprintf(fid{ii},'---------------------------------------------------------\n');
        fprintf(fid{ii},'PROPERTIES :\n');
        for ip=1:length(curr_props)
            fprintf(fid{ii},'- %s\n',curr_props{ip});
        end
        fprintf(fid{ii},'\n');
        fprintf(fid{ii},'METHODS :\n');
        for im=1:length(curr_methods)
            fprintf(fid{ii},'- %s\n',curr_methods{im});
        end
        fprintf(fid{ii},'\n\n');
    end
end
fclose(fid{2});