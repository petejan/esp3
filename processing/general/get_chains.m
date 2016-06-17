
function [new_chains_start,new_chains_end,new_chains,idx_looked]=get_chains(couples,chains_start,chains_end,chains,idx_looked)

start_couple=couples(:,1);
end_couple=couples(:,2);

if isempty(idx_looked)
    chains_start=couples(1,1);
    chains_end=couples(1,2);
    chains={couples(1,:)};
    idx_looked=1;
else
    if isempty(chains_start)
        idx_not=find(~ismember((1:size(couples,1)),idx_looked));
        chains_start=couples(idx_not(1),1);
        chains_end=couples(idx_not(1),2);
        chains={couples(idx_not(1),:)};
        idx_looked=[idx_looked idx_not(1)];
    end
end


new_chains={};
new_chains_start=[];
new_chains_end=[];
unfinished=0;
u=0;
for i=1:length(chains)
    i_next=find(start_couple==chains_end(i));
    i_prev=find(end_couple==chains_start(i));
    
    if  ~isempty(i_next)||~isempty(i_prev)
        unfinished=1;
    end   
    
    if ~isempty(i_next)&&~isempty(i_prev)

        for i_n=1:length(i_next)
            for i_p=1:length(i_prev)
                u=u+1;
                new_chains{u}=[start_couple(i_prev(i_p)) chains{i} end_couple(i_next(i_n))];
                new_chains_start(u)=start_couple(i_prev(i_p));
                new_chains_end(u)=end_couple(i_next(i_n));
                idx_looked=unique([idx_looked i_next(i_n) i_prev(i_p)]);
            end
        end
    elseif ~isempty(i_next)
        for i_n=1:length(i_next)
            u=u+1;
            new_chains{u}=[chains{i} end_couple(i_next(i_n))];
            new_chains_start(u)=chains{i}(1);
            new_chains_end(u)=end_couple(i_next(i_n));
            idx_looked=unique([idx_looked i_next(i_n)]);
        end
    elseif ~isempty(i_prev)
        for i_p=1:length(i_prev)
            u=u+1;
            new_chains{u}=[start_couple(i_prev(i_p)) chains{i}];
            new_chains_start(u)=start_couple(i_prev(i_p));
            new_chains_end(u)=chains{i}(end);
             idx_looked=unique([idx_looked i_prev(i_p)]);
        end
    else
        u=u+1;
        new_chains{u}=chains{i};
        new_chains_start(u)=chains_start(i);
        new_chains_end(u)=chains_end(i);
    end
end

if unfinished==1
    [new_chains_start,new_chains_end,new_chains,idx_looked]=get_chains(couples,new_chains_start,new_chains_end,new_chains,idx_looked);
end

end