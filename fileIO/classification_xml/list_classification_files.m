function [files_classif,trees,titles]=list_classification_files()
app_path_main=whereisEcho();
classif_path=fullfile(app_path_main,'config','classification');
list_classif=dir(fullfile(classif_path,'*.xml'));
list_classif={list_classif([list_classif(:).isdir]==0).name};

files_classif=cell(1,numel(list_classif));
trees=cell(1,numel(list_classif));
titles=cell(1,numel(list_classif));
for ifi=1:numel(list_classif)
    try
        files_classif{ifi}=fullfile(classif_path,list_classif{ifi});
        trees{ifi}=decision_tree_cl(files_classif{ifi});   
        if strcmp(trees{ifi}.Title,'')
           [~,titles{ifi},~]=fileparts(list_classif{ifi}) ;
        else
            titles{ifi}=trees{ifi}.Title;
        end
    catch err
        trees{ifi}=[];
        fprintf('Could not parse xml survey from file %s\n',list_classif{ifi});
        disp(err.message);
        continue;      
    end  
end
    
files_classif(cellfun(@isempty,trees))=[];
trees(cellfun(@isempty,trees))=[];
titles(cellfun(@isempty,trees))=[];

end
