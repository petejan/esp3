function compare_reg_output( out_reg_1,out_reg_2,ref )

fields=fieldnames(out_reg_1);

fig=figure();
ax=axes(fig,'outerposition',[0 0.5 1 0.5]);
grid(ax,'on');

ax2=axes(fig,'outerposition',[0 0 0.5 0.5]);
grid(ax2,'on');
xlabel('Reg 1')

ax3=axes(fig,'outerposition',[0.5 0 0.5 0.5]);
grid(ax3,'on');
xlabel('Reg 2');

linkprop([ax3 ax2],'CLim');


for i=1:length(fields)
    if ~all(size(out_reg_1.(fields{i}))==size(out_reg_2.(fields{i})))
        fprintf('Can not compare field %s, not same size\n',fields{i});
        continue;
    end
    switch ref
        case 'Surface'
            reg_1_f=(out_reg_1.(fields{i}));
            alpha_1=~isnan((out_reg_1.(fields{i})));
        otherwise
            reg_1_f=flipud(out_reg_1.(fields{i}));
            alpha_1=~isnan(flipud(out_reg_1.(fields{i})));
    end
    
    diff_cells=reg_1_f-out_reg_2.(fields{i});
    diff_mean=nanmean(diff_cells(:));
    
    imagesc(ax2,reg_1_f,'AlphaData',alpha_1);colorbar(ax2);
    imagesc(ax3,out_reg_2.(fields{i}),'AlphaData',~isnan(out_reg_2.(fields{i})));colorbar(ax3);
    
    imagesc(ax,diff_cells);colorbar(ax);
    title(ax,sprintf('Average diff for %s: %f',fields{i},diff_mean));
    pause(0.1);
    
end
close(fig);

end

