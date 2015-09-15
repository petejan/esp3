function setIdxBad(obj,IdxBad)

pings=obj.Data.Number;

while nanmax(IdxBad)>length(pings)
    IdxBad=IdxBad-1;
end

IdxBad(IdxBad<=0)=[];

obj.IdxBad=IdxBad;

end