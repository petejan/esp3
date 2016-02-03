function regCellInSubSet = getCellIntSubSet(regCellInt, reg, refType)

sd = ones(size(regCellInt.Layer_depth_min));
fd = ones(size(regCellInt.Layer_depth_max));

switch refType
    case {'b','bottom','Bottom'}
        for i = 1:size(regCellInt.Sv_mean_lin,2)
            startBorder = nanmax(regCellInt.y_node(:,i)-regCellInt.height(:,i)/2)-reg.startDepth;
            finishBorder = nanmax(regCellInt.y_node(:,i)+regCellInt.height(:,i)/2)-reg.finishDepth;
            if ~isnan(reg.startDepth);
                sd(:,i) = regCellInt.y_node(:,i)-regCellInt.height(:,i)/2 <= startBorder;
            end
            if ~isnan(reg.finishDepth);
                fd(:,i) = regCellInt.y_node(:,i)+regCellInt.height(:,i)/2 > finishBorder;
            end
        end
    otherwise
        for i = 1:size(regCellInt.Sv_mean_lin,2)
            if ~isnan(reg.startDepth);
                sd(:,i) = regCellInt.y_node(:,i)-regCellInt.height(:,i)/2 >= reg.startDepth;
            end
            if ~isnan(reg.finishDepth);
                sd(:,i) = regCellInt.y_node(:,i)+regCellInt.height(:,i)/2 < reg.finishDepth;
            end
        end
end

ss = ones(size(regCellInt.Interval));
if ~isnan(reg.startSlice);
    ss = regCellInt.Interval >= reg.startSlice;
end

fs = ones(size(regCellInt.Interval));
if ~isnan(reg.finishSlice);
    fs = regCellInt.Interval <= reg.finishSlice;
end
ix = sd == 1 & fd == 1 & ss == 1 & fs == 1;

fnames=fieldnames(regCellInt);

for uu=1:length(fnames)
    regCellInSubSet.(fnames{uu})=regCellInt.(fnames{uu});
    regCellInSubSet.(fnames{uu})(ix==0)=nan;
end


end