function create_region_context_menu(reg_plot,main_figure,reg_curr)

context_menu=uicontextmenu;
for ii=1:length(reg_plot)
    reg_plot(ii).UIContextMenu=context_menu;
    reg_plot(ii).ButtonDownFcn={@activate_region_callback,reg_curr,main_figure};
end

uimenu(context_menu,'Label','Display Pdf of values','Callback',{@disp_hist_region_callback,reg_curr,main_figure});
uimenu(context_menu,'Label','Delete Region','Callback',{@delete_region_uimenu_callback,reg_curr,main_figure});
%uimenu(context_menu,'Label','Activate Region','Callback',{@activate_region_callback,reg_curr,main_figure});

end

function disp_hist_region_callback(~,~,reg_curr,main_figure)
extfig=getappdata(main_figure,'ExternalFigures');
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

trans=layer.Transceivers(idx_freq);
data=trans.Data.get_subdatamat(curr_disp.Fieldname,reg_curr.Idx_r,reg_curr.Idx_pings);

sub_bot=trans.Bottom.Sample_idx(reg_curr.Idx_pings);
idxBad=find(trans.Bottom.Tag==0);
[sub_bot_mat,sub_sample_mat]=meshgrid(sub_bot,reg_curr.Idx_r);

sub_idx_bad=intersect(reg_curr.Idx_pings,idxBad);
sub_idx_bad=sub_idx_bad-reg_curr.Idx_pings(1)+1;

switch reg_curr.Shape
    case 'Polygon'
        data(isnan(reg_curr.Sv_reg))=nan;
    case 'Rectangular'
        
end
data(sub_sample_mat>=sub_bot_mat)=nan;
data(:,sub_idx_bad)=nan;

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

hfig=figure('Name',sprintf('Region Histogram: %s',curr_disp.Type),'NumberTitle','off');
hold on;
title(tt);
bar(x,pdf);
grid on;
ylabel('Pdf');
xlabel(xlab);

extfig=[extfig hfig];
setappdata(main_figure,'ExternalFigures',extfig);

end

function delete_region_uimenu_callback(~,~,reg_curr,main_figure)
delete_region_callback([],[],main_figure,reg_curr.Unique_ID);
end