function export_region_to_xls(layer_obj,active_reg,varargin)

[path_tmp,~,~]=fileparts(layer_obj.Filename{1});
layers_Str=list_layers(layer_obj,'nb_char',80);
output_f_def=fullfile(path_tmp,[layers_Str{1} '_regions' '.xlsx']);

p = inputParser;
addRequired(p,'layer_obj',@(x) isa(x,'layer_cl'));
addRequired(p,'active_reg',@(x) isa(x,'region_cl'));
addParameter(p,'output_f',output_f_def,@ischar);
addParameter(p,'idx_freq',1,@isnumeric);
addParameter(p,'idx_freq_end',[],@isnumeric);

parse(p,layer_obj,active_reg,varargin{:});


if exist(p.Results.output_f,'file')>1
    delete(p.Results.output_f);
end

reg_descr_table=[];
for u=1:numel(active_reg)
    
    [regs_end,idx_freq_end,~,~]=layer_obj.generate_regions_for_other_freqs(p.Results.idx_freq,active_reg(u),p.Results.idx_freq_end);
    regs=[active_reg(u) regs_end];
    [idx_freq_sort,is]=sort([p.Results.idx_freq,idx_freq_end]);
    regs=regs(is);
    reg_descriptors=layer_obj.Transceivers(p.Results.idx_freq).get_region_descriptors(active_reg(u));
    
    for ir=1:length(idx_freq_sort)
        output_reg=layer_obj.Transceivers(ir).integrate_region_v4(regs(ir));
        reg_output_table=reg_output_to_table(output_reg);
        %writetable(reg_output_table,p.Results.output_f,'Sheet',sprintf('%.0fkHz',layer_obj.Frequencies(idx_freq_sort(ir))/1e3));
        writetable(reg_output_table,p.Results.output_f,'Sheet',ir+1);
        output_reg.Sv_mean_lin(output_reg.Sv_mean_lin==0)=nan;
        Sv_mean=pow2db_perso(nanmean(output_reg.Sv_mean_lin(:)));
        delta_sv=nanstd(pow2db_perso(output_reg.Sv_mean_lin(:)));
        reg_descriptors.(sprintf('Sv_%.0fkHz',layer_obj.Frequencies(idx_freq_sort(ir))/1e3))=Sv_mean;
        reg_descriptors.(sprintf('Delta_Sv_%.0fkHz',layer_obj.Frequencies(idx_freq_sort(ir))/1e3))=delta_sv;
    end
    
    reg_descr_table = [reg_descr_table;struct2table(reg_descriptors,'asarray',1)];
end
%writetable(reg_descr_table,p.Results.output_f,'Sheet','Descriptors');
writetable(reg_descr_table,p.Results.output_f,'Sheet',1);
end