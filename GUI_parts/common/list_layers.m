function layers_Str=list_layers(layers)

nb_layers=length(layers);
layers_Str=cell(1,nb_layers);
for i=1:nb_layers 
    file_curr='';
    for il=1:length(layers(i).Filename)
    [~,tmp,~]=fileparts(layers(i).Filename{il});
    file_curr=[file_curr ' ' tmp];
    end
    
    %file_curr=layers(i).Filename{1};
    if ~isempty(layers(i).get_survey_data())
       
        new_name=[layers(i).get_survey_data().print_survey_data() file_curr];
    else
        new_name=file_curr;
    end
    
    if strcmp(new_name,'')
         new_name=file_curr;
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