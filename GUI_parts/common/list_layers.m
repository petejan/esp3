function layers_Str=list_layers(layers,varargin)

p = inputParser;

addRequired(p,'layers',@(obj) isa(obj,'layer_cl'));
addParameter(p,'nb_char',[],@(x) isnumeric(x));

parse(p,layers,varargin{:});
nb_char=p.Results.nb_char;

nb_layers=length(layers);
layers_Str=cell(1,nb_layers);
for i=1:nb_layers 
    file_curr='';

    [~,filename_cell]=fileparts_cell(layers(i).Filename);
    for il=1:length(layers(i).Filename)
    file_curr=[file_curr ' ' filename_cell{il}];
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
if isempty(nb_char)||nb_char>length(new_name)
    layers_Str{i}=new_name;
else
    layers_Str{i}=[new_name(1:nb_char) '...'];    
end

end