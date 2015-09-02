
function label_out=format_label(tick,ax_type)

str_start='    ';
switch lower(ax_type)
    case 'time'
        str_end='s';
    case 'number'
        str_end='';
    case 'distance'
        str_end='m';
    otherwise
        str_end='';
end

label_out=cell(length(tick),1);

switch lower(ax_type)
    case 'time' 
        label_out=mat2cell(datestr(tick,'HH:MM:SS'),ones(1,size(tick,2)),8);
    otherwise
        for i=1:length(tick)
            label_out{i}=[str_start num2str(tick(i),' %.0f') str_end];           
        end
        
end
end