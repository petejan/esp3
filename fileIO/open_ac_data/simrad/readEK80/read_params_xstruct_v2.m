function params=read_params_xstruct_v2(xstruct)

params=xstruct.Parameter.Channel.Attributes;
att=fieldnames(params);

% for j=1:length(att)
%     val_temp=str2double(params.(att{j}));
%     if ~isnan(val_temp)
%         params.(att{j})=val_temp;
%     end
% end



for j=1:length(att)
    switch att{j}
        case 'ChannelID'
        otherwise
            val_temp=str2double(params.(att{j}));
            if ~isnan(val_temp)
                params.(att{j})=val_temp;
            end
    end
    
end
end

