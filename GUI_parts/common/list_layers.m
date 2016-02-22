function layers_Str=list_layers(layers)

nb_layers=length(layers);
layers_Str=cell(1,nb_layers);
for i=1:nb_layers
    if ~isempty(layers(i).get_survey_data())
        new_name=[layers(i).Filename{1} ' ' layers(i).get_survey_data().print_survey_data()];
    else
        new_name=layers(i).Filename{1};
    end
    
    if strcmp(new_name,'')
         new_name=fullfile(layers(i).Filename{1});
    end
    
    u=1;
    new_name_ori=new_name;
    while nansum(strcmp(new_name,layers_Str))>=1
        new_name=[new_name_ori '_' num2str(u)];
        u=u+1;
    end
    layers_Str{i}=new_name;
end

end