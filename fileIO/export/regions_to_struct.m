function new_struct=regions_to_struct(Regions,output_vec)

output_names=fieldnames(output_vec(1));
for k=length(output_names):-1:1
    new_struct.(output_names{k})=[];
end

names=fieldnames(Regions(1));

for k=length(names):-1:1
    if ~strcmp(names{k},'MaskReg')&&~strcmp(names{k},'Y_cont')&&~strcmp(names{k},'X_cont')&&~strcmp(names{k},'Idx_pings')&&~strcmp(names{k},'Idx_r')
        if iscell(Regions(1).(names{k}))||ischar(Regions(1).(names{k}))
            new_struct.(names{k})={};
        else
            new_struct.(names{k})=[];
        end
    end
end

for i=1:length(Regions)
    output_names=fieldnames(output_vec(i));
    for k=1:length(output_names)
        curr_data=output_vec(i).(output_names{k});
        new_struct.(output_names{k})=[new_struct.(output_names{k}); curr_data(:)];
    end
    n=length(curr_data(:));
    names=fieldnames(Regions(i));
    for k=length(names):-1:1
       if ~strcmp(names{k},'MaskReg')&&~strcmp(names{k},'Y_cont')&&~strcmp(names{k},'X_cont')&&~strcmp(names{k},'Idx_pings')&&~strcmp(names{k},'Idx_r')
            if iscell(Regions(i).(names{k}))||ischar(Regions(i).(names{k}))
                new_struct.(names{k})=[new_struct.(names{k});repmat({Regions(i).(names{k})},n,1)];
            else
                new_struct.(names{k})=[new_struct.(names{k});repmat(Regions(i).(names{k}),n,1)];
            end
        end
    end
    
end
new_struct=orderfields(new_struct,length(fieldnames(new_struct)):-1:1);