function export_cells(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);


data_types=get(region_tab_comp.data_type,'string');
data_type_idx=get(region_tab_comp.data_type,'value');
data_type=data_types{data_type_idx};

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};

cell_h=str2double(get(region_tab_comp.cell_h,'string'));
cell_w=str2double(get(region_tab_comp.cell_w,'string'));

range=double(Transceiver.Data.Range);
samples=(1:length(range))';
pings=double(Transceiver.Data.Number);

idx_pings=1:length(pings);
idx_r=samples;


reg_temp=region_cl(...
    'ID',999,...
    'Name','All Echogramm',...
    'Type',data_type,...
    'Ping_ori',pings(1),...
    'Sample_ori',samples(1),...
    'BBox_w',length(idx_pings),...
    'BBox_h',length(samples),...
    'Shape','Rectangular',...
    'Reference','Surface',...
    'Cell_w',cell_w,...
    'Cell_w_unit',w_unit,...
    'Cell_h',cell_h,...
    'Cell_h_unit',h_unit,...
    'Output',[]);

reg_temp.integrate_region(Transceiver,idx_pings,idx_r);

Freq=layer.Frequencies(idx_freq);
Filename=layer.Filename;

if iscell(Filename)
    Filename=Filename{1};
end

file_outputs_def=[layer.PathToFile '\' Filename(1:end-5) '_' num2str(Freq) '_cell_outputs.csv'];

[file_outputs,path_out] = uiputfile('*_cell_outputs.csv','Select Filename for saving output',file_outputs_def);

if ~isequal(file_outputs,0)&&~isequal(path_out,0)
    
    new_struct=regions_to_struct(reg_temp);

struct2csv(new_struct,fullfile(path_out,file_outputs));
   
end

active_reg=reg_temp;
sv_disp=active_reg.Output.Sv_mean;
idx_type=find_type_idx(Transceiver.Data,'Sv');
cax=Transceiver.Data.SubData(idx_type).CaxisDisplay;


%sv_disp(sv_disp<cax(1))=nan;
if size(sv_disp,1)>1&&size(sv_disp,2)>1
    figure();
    subplot(2,1,1)
    pcolor(active_reg.Output.x_node,active_reg.Output.y_node,sv_disp)
    xlabel(sprintf('%s',active_reg.Cell_w_unit))
    ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
    shading interp
    caxis(cax);
    colorbar;
    axis ij
    hold on;
    subplot(2,1,2)
    plot(10*log10(nanmean(10.^(active_reg.Output.Sv_mean/10),2)),nanmean(active_reg.Output.y_node,2));
    grid on;
    xlabel('Sv mean')
    ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
    axis ij;
    grid on;
else
    figure();
    subplot(2,1,1)
    plot(active_reg.Output.x_node,sv_disp)
    xlabel(sprintf('%s',active_reg.Cell_w_unit))
    ylabel('Sv mean')
    
    axis ij
    hold on;
    subplot(2,1,2)
    plot(sv_disp,active_reg.Output.y_node)
    grid on;
    xlabel('Sv mean')
    ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
    axis ij;
    grid on;
end

end