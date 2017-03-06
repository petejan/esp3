function create_region_context_menu(reg_plot,main_figure,reg_curr)

context_menu=uicontextmenu(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

for ii=1:length(reg_plot)
    reg_plot(ii).UIContextMenu=context_menu;
    reg_plot(ii).ButtonDownFcn={@activate_region_callback,reg_curr,main_figure};
end

uimenu(context_menu,'Label','Display Region','Callback',{@display_region_callback,reg_curr,main_figure});
uimenu(context_menu,'Label','Delete Region','Callback',{@delete_region_uimenu_callback,reg_curr,main_figure});
uimenu(context_menu,'Label','Copy to other frequencies','Callback',{@copy_region_callback,reg_curr,main_figure});
uimenu(context_menu,'Label','Merge Overlapping Regions','CallBack',{@merge_overlapping_regions_callback,main_figure});


analysis_menu=uimenu(context_menu,'Label','Analysis');
uimenu(analysis_menu,'Label','Display Pdf of values','Callback',{@disp_hist_region_callback,reg_curr,main_figure});
uimenu(analysis_menu,'Label','Classify','Callback',{@classify_reg_callback,reg_curr,main_figure});
uimenu(analysis_menu,'Label','Spectral Analysis (noise)','Callback',{@noise_analysis_callback,reg_curr,main_figure});
uimenu(analysis_menu,'Label','Display Region Integration values (NASC)','Callback',{@reg_integrated_callback,reg_curr,main_figure});

freq_analysis_menu=uimenu(context_menu,'Label','Frequency Analysis');
uimenu(freq_analysis_menu,'Label','Display Frequency response','Callback',{@freq_response_reg_callback,main_figure});

if strcmp(layer.Transceivers(idx_freq).Mode,'FM')
    uimenu(freq_analysis_menu,'Label','Create Frequency Matrix Sv','Callback',{@freq_response_mat_callback,main_figure});
    uimenu(freq_analysis_menu,'Label','Create Frequency Matrix Sp','Callback',{@freq_response_sp_mat_callback,main_figure});
end


algo_menu=uimenu(context_menu,'Label','Algorithms');
uimenu(algo_menu,'Label','Apply Bottom Detection V1 ','Callback',{@apply_bottom_detect_cback,reg_curr,main_figure,'v1'});
uimenu(algo_menu,'Label','Apply Bottom Detection V2 ','Callback',{@apply_bottom_detect_cback,reg_curr,main_figure,'v2'});
uimenu(algo_menu,'Label','Apply Single Target Detection ','Callback',{@apply_st_detect_cback,reg_curr,main_figure});


end

function copy_region_callback(~,~,reg_curr,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
layer.copy_region_across(idx_freq,reg_curr,[]);
end

function reg_integrated_callback(~,~,reg_curr,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
regCellInt=layer.Transceivers(idx_freq).integrate_region(reg_curr);

fprintf('NASC (esp2): %.0f\n', 4*pi*1852^2*nansum(nansum(regCellInt.Sa_lin))./nansum(nanmax(regCellInt.Nb_good_pings_esp2)));
fprintf('NASC (v2): %.0f\n', 4*pi*1852^2*nansum(nansum(regCellInt.Sa_lin))./nansum(nanmax(regCellInt.Nb_good_pings)));
fprintf('NASC: %.0f\n', nanmean(nansum(regCellInt.NASC)));
end



function disp_hist_region_callback(~,~,reg_curr,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

trans=layer.Transceivers(idx_freq);
data=trans.Data.get_subdatamat(reg_curr.Idx_r,reg_curr.Idx_pings,'field',curr_disp.Fieldname);

sub_bot=trans.Bottom.Sample_idx(reg_curr.Idx_pings);
idxBad=find(trans.Bottom.Tag==0);
[sub_bot_mat,sub_sample_mat]=meshgrid(sub_bot,reg_curr.Idx_r);

sub_idx_bad=intersect(reg_curr.Idx_pings,idxBad);
sub_idx_bad=sub_idx_bad-reg_curr.Idx_pings(1)+1;

switch reg_curr.Shape
    case 'Polygon'
        mask=reg_curr.create_mask();
        data(~mask)=nan;
    case 'Rectangular'
        
end
data(sub_sample_mat>=sub_bot_mat)=nan;
data(:,sub_idx_bad)=nan;

if ~any(~isnan(data))
    return;
end

[pdf,x]=pdf_perso(data,'bin',50);

tt=reg_curr.print();
switch lower(deblank(curr_disp.Fieldname))
    case{'alongangle','acrossangle'}
        xlab=sprintf('Angle (deg)');
    case{'alongphi','acrossphi'}
        xlab='Phase (deg)';
    otherwise
        xlab=sprintf('%s (dB)',curr_disp.Type);
end

new_echo_figure(main_figure,'Name',sprintf('Region Histogram: %s',curr_disp.Type),'Tag','region_pdf');
hold on;
title(tt);
bar(x,pdf);
grid on;
ylabel('Pdf');
xlabel(xlab);

end

function delete_region_uimenu_callback(~,~,reg_curr,main_figure)
delete_region_callback([],[],main_figure,reg_curr.Unique_ID);
end