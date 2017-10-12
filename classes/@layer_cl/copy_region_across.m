function copy_region_across(layer,idx_freq,active_reg,idx_freq_end)

fprintf('Copying regions from %.0f kHz\n',layer.Frequencies(idx_freq));

for ireg=1:length(active_reg)
    [regs,idx_freq_end]=layer.generate_regions_for_other_freqs(idx_freq,active_reg(ireg),idx_freq_end);
    
    for idx=1:length(idx_freq_end)
        layer.Transceivers(idx_freq_end(idx)).add_region(regs(idx),'Split',0);
    end
end

disp('Done');

end