function str=get_str(obj,idx)

p = inputParser;

addRequired(p,'obj',@(x) isa(x,'map_input_cl'));
addRequired(p,'idx',@(h) isempty(h)|isnumeric(h));

parse(p,obj,idx);

if isempty(idx)
    idx=1:length(length(obj.Snapshot));
end
str=cell(1,length(idx));
for i=1:length(idx)
    
    if iscell(obj.Filename{idx(i)})
        str_temp=sprintf('%s\n',obj.Filename{idx(i)}{:});
    else
        str_temp=obj.Filename{idx(i)};
    end
    
    if ~isempty(obj.Stratum{idx(i)})
        str{i}=sprintf('Snap. %d Strat. %s Trans. %d\n File(s):\n %s',...
            obj.Snapshot(idx(i)),obj.Stratum{idx(i)},obj.Transect(idx(i)),str_temp);
        
        if obj.Snapshot(idx(i))==0&&strcmp(obj.Stratum(idx(i)),' ')&&obj.Transect(idx(i))==0
            str{i}=str_temp;
        end
    else
        str{i}=str_temp;
    end
end

end