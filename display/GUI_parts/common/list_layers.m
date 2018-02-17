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
    
    [~,filename_cell,~]=cellfun(@fileparts,layers(i).Filename,'UniformOutput',false);
    
    for il=1:length(layers(i).Filename)
        file_curr=[file_curr ' ' filename_cell{il}];
    end
    
    %file_curr=layers(i).Filename{1};
    switch layers(i).Filetype
        case 'ASL'
            t1=floor(layers(i).Transceivers(1).Time(1));
            t2=floor(layers(i).Transceivers(1).Time(end));
            if t1==t2
                new_name=['ASL ' datestr(t1)];
            else
                new_name=['ASL ' datestr(t1) 'to' datestr(t2)];
            end
            
        otherwise
            if ~isempty(layers(i).get_survey_data())
                new_name=[deblank(layers(i).get_survey_data().print_survey_data()) file_curr];
            else
                new_name=file_curr;
            end
            
            if strcmp(new_name,'')
                new_name=file_curr;
            end
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