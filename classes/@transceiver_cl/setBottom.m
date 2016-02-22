function setBottom(obj,bottom_obj)

range=obj.Data.Range;
pings=obj.Data.Number;

if isempty(bottom_obj)
    return;
end
IdxBad=find(bottom_obj.Tag==0);

IdxBad(IdxBad<=0)=[];
new_bot_sple=nan(size(pings));
new_bot_r=nan(size(pings));

bot_sple=bottom_obj.Sample_idx;

if ~isempty(bot_sple)   
    i0=abs(length(bot_sple)-length(pings));
    
    if length(bot_sple)>length(pings)
        new_bot_sple=bot_sple(1:end-i0);
    elseif length(bot_sple)<length(pings)
        new_bot_sple(2:length(bot_sple)+1)=bot_sple;
        IdxBad=IdxBad+1;
    else
        new_bot_sple=bot_sple;
    end
    
    while nanmax(IdxBad)>length(pings)
        IdxBad=IdxBad-1;
    end
    
    new_bot_sple(new_bot_sple>length(range))=length(range);
    new_bot_sple(new_bot_sple<=0)=1;
    
    new_bot_r(~isnan(new_bot_sple))=range(new_bot_sple(~isnan(new_bot_sple)));
end
tag=ones(size(new_bot_r));
tag(IdxBad)=0;
obj.Bottom=bottom_cl('Origin',bottom_obj.Origin,'Range',new_bot_r,'Sample_idx',new_bot_sple,'Double_bot_mask',bottom_obj.Double_bot_mask,'Tag',tag);

end