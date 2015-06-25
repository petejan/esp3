function data=reorder_ping(data)

for ii=length(data.pings)
    time=data.pings(ii).time;
    
    
    if ~issorted(time)
        idx_sort=sort(time);
        
        data.pings(2).comp
        
        props=fieldnames(data.pings(ii));
        
        for i=1:length(props)
            if size(data.pings(ii).(props{i}),2)==length(time)
            data.pings(ii).(props{i})=data.pings(ii).(props{i})(:,idx_sort);
            end
        end
        
                
        props=fieldnames(data.params(ii));
        
        for i=1:length(props)
            if length(data.params(ii).(props{i}),2)==length(time)
            data.params(ii).(props{i})=data.params(ii).(props{i})(:,idx_sort);
            end
        end

    end
    
end
end