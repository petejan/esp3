function addBadSector(trans_obj,IdxBad,isgood)

if isempty(IdxBad)
    return;
end

trans_obj.Bottom.Tag(IdxBad)=(isgood>0);

end