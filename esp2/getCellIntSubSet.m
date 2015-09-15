function regCellInSubSet = getCellIntSubSet(regCellInt, reg, j, refType)

sd = ones(size(regCellInt.Layer_depth_min));
fd = ones(size(regCellInt.Layer_depth_max));
if refType == 'b'
    for i = 1:size(regCellInt.Sv_mean,2)
        startBorder = nanmax(regCellInt.y_node(:,i)-regCellInt.height(:,i)/2)-reg.startDepth(j);
        finishBorder = nanmax(regCellInt.y_node(:,i)+regCellInt.height(:,i)/2)-reg.finishDepth(j);
        if ~isnan(reg.startDepth(j));
            sd(:,i) = regCellInt.y_node(:,i)-regCellInt.height(:,i)/2 <= startBorder;
        end
        if ~isnan(reg.finishDepth(j));
            fd(:,i) = regCellInt.y_node(:,i)+regCellInt.height(:,i)/2 > finishBorder;
        end
    end
else
    for i = 1:size(regCellInt.Sv_mean,2)
        if ~isnan(reg.startDepth(j));
            sd(:,i) = regCellInt.y_node(:,i)-regCellInt.height(:,i)/2 >= reg.startDepth(j);
        end
        if ~isnan(reg.finishDepth(j));
            sd(:,i) = regCellInt.y_node(:,i)+regCellInt.height(:,i)/2 < reg.finishDepth(j);
        end
    end
end

ss = ones(size(regCellInt.Interval));
if ~isnan(reg.startSlice(j));
    ss = regCellInt.Interval >= reg.startSlice(j);
end

fs = ones(size(regCellInt.Interval));
if ~isnan(reg.finishSlice(j));
    fs = regCellInt.Interval <= reg.finishSlice(j);   
end
ix = sd == 1 & fd == 1 & ss == 1 & fs == 1;

fnames=fieldnames(regCellInt);

for uu=1:length(fnames)
    regCellInSubSet.(fnames{uu})=regCellInt.(fnames{uu}); 
    regCellInSubSet.(fnames{uu})(ix==0)=nan; 
end


end