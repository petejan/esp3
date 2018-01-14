%% create_region_context_menu.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |reg_plot|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
% * |ID|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function create_region_context_menu(reg_plot,main_figure,ID)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

switch class(ID)
    case 'matlab.graphics.primitive.Patch'
        isreg=0;
        select_plot=ID;
        ID=0;
    otherwise
        isreg=1;
        select_plot=trans_obj.get_region_from_Unique_ID(ID);
end
context_menu=uicontextmenu(main_figure,'Tag','RegionContextMenu','UserData',ID);

for ii=1:length(reg_plot)
    reg_plot(ii).UIContextMenu=context_menu;
end

if isreg>0
    idx_other=setdiff(1:numel(layer.Frequencies),idx_freq);
    region_menu=uimenu(context_menu,'Label','Region');
    uidisp=uimenu(region_menu,'Label','Display');
    uimenu(uidisp,'Label','Region SV','Callback',{@display_region_callback,main_figure});
    uimenu(uidisp,'Label','Region Fish Density','Callback',{@display_region_fishdensity_callback,main_figure});
    uimenu(uidisp,'Label','Frequency differences','Callback',{@freq_diff_callback,main_figure});
    
    uifreq=uimenu(region_menu,'Label','Copy to other channels');
    uimenu(uifreq,'Label','all','Callback',{@copy_region_callback,main_figure,[]});
    
    for ifreq=idx_other
        uimenu(uifreq,'Label',sprintf('%.0fkHz',layer.Frequencies(ifreq)/1e3),'Callback',{@copy_region_callback,main_figure,ifreq});
    end
    
    uimenu(region_menu,'Label','Merge Overlapping Regions','CallBack',{@merge_overlapping_regions_callback,main_figure});
    uimenu(region_menu,'Label','Merge Overlapping Regions (per Tag)','CallBack',{@merge_overlapping_regions_per_tag_callback,main_figure});
end



analysis_menu=uimenu(context_menu,'Label','Analysis');
uimenu(analysis_menu,'Label','Display Pdf of values','Callback',{@disp_hist_region_callback,select_plot,main_figure});

if isreg>0
    uimenu(analysis_menu,'Label','Classify','Callback',{@classify_reg_callback,main_figure});
    uimenu(analysis_menu,'Label','Display Region Statistics','Callback',{@reg_integrated_callback,main_figure});
end

if isreg>0
    export_menu=uimenu(context_menu,'Label','Export');
    uimenu(export_menu,'Label','Export integrated region to .xlsx','Callback',{@export_region_callback,main_figure});
end

uimenu(analysis_menu,'Label','Spectral Analysis (noise)','Callback',{@noise_analysis_callback,select_plot,main_figure});


freq_analysis_menu=uimenu(context_menu,'Label','Frequency Analysis');
uimenu(freq_analysis_menu,'Label','Display TS Frequency response','Callback',{@freq_response_reg_callback,select_plot,main_figure,'sp'});
uimenu(freq_analysis_menu,'Label','Display Sv Frequency response','Callback',{@freq_response_reg_callback,select_plot,main_figure,'sv'});

if strcmp(trans_obj.Mode,'FM')
    uimenu(freq_analysis_menu,'Label','Create Frequency Matrix Sv','Callback',{@freq_response_mat_callback,select_plot,main_figure});
    uimenu(freq_analysis_menu,'Label','Create Frequency Matrix TS','Callback',{@freq_response_sp_mat_callback,select_plot,main_figure});
end


algo_menu=uimenu(context_menu,'Label','Algorithms');
uimenu(algo_menu,'Label','Apply Bottom Detection V1','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v1'});
uimenu(algo_menu,'Label','Apply Bottom Detection V2','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v2'});
uimenu(algo_menu,'Label','Find Bad Transmits from region/selection','Callback',{@find_bt_cback,select_plot,main_figure});
uimenu(algo_menu,'Label','Shift Bottom','Callback',{@shift_bottom_callback,select_plot,main_figure});
uimenu(algo_menu,'Label','Apply Single Target Detection','Callback',{@apply_st_detect_cback,select_plot,main_figure});
uimenu(algo_menu,'Label','Apply Target tracking','Callback',{@apply_track_target_cback,select_plot,main_figure});
uimenu(algo_menu,'Label','Apply School Detection','Callback',{@apply_school_detect_cback,select_plot,main_figure});



end

function freq_diff_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
IDs=curr_disp.Active_reg_ID;

reg_curr=trans_obj.get_region_from_Unique_ID(IDs);
layer.copy_region_across(idx_freq,reg_curr,[]);

frequencies=layer.Frequencies;
n=length(layer.Frequencies);

uniquev=generate_couples(n);

output_reg=cell(numel(IDs),n);

for i=1:n
    trans=layer.Transceivers(i);
    for j=1:numel(IDs)
        reg=trans.get_region_from_Unique_ID(reg_curr(j).Unique_ID);
        output_reg{j,i}=trans.integrate_region_v3(reg,'keep_bottom',1);
    end
end

for j=1:numel(numel(IDs))
    for i=1:size(uniquev,1)
        
        output_reg_1=output_reg{j,uniquev(i,1)};
        output_reg_2=output_reg{j,uniquev(i,2)};
        output_diff  = substract_reg_outputs( output_reg_1,output_reg_2);
        
        if ~isempty(output_diff)
            sv=pow2db_perso(output_diff.Sv_mean_lin(:));
            cax_min=prctile(sv,5);
            cax_max=prctile(sv,95);
            cax=curr_disp.getCaxField('sv');
            
            switch reg_curr.Reference
                case 'Line'
                    line_obj=layer.get_first_line();
                otherwise
                    line_obj=[];
            end
            
            reg_curr(j).display_region(output_diff,'main_figure',main_figure,...
                'alphadata',double(pow2db_perso(output_reg_1.Sv_mean_lin)>cax(1)),...
                'Cax',[cax_min cax_max],...
                'Name',sprintf('%s, %dkHz-%dkHz',reg_curr(j).print,frequencies(uniquev(i,1))/1e3,frequencies(uniquev(i,2))/1e3),...
                'line_obj',line_obj);
        else
            fprintf('Cannot compute differences %dkHz-%dkHz\n',frequencies(uniquev(i,1))/1e3,frequencies(uniquev(i,2))/1e3);
        end
    end
end


end

function export_region_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);
reg_curr=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID);
[path_tmp,~,~]=fileparts(layer.Filename{1});
layers_Str=list_layers(layer,'nb_char',80);
for i=1:numel(reg_curr)
    
    [fileN, path_tmp] = uiputfile('*.xlsx',...
        'Save Sliced transect (integration results)',...
        fullfile(path_tmp,[layers_Str{1} 'reg_' reg_curr(i).disp_str() '.xlsx']));
    
    if isequal(path_tmp,0)
        return;
    end
    
    if exist(fullfile(path_tmp,fileN),'file')>1
        delete(fullfile(path_tmp,fileN));
    end
    
    output_reg=trans_obj.integrate_region_v3(reg_curr(i));
    
    reg_output_sheet=reg_output_to_sheet(output_reg);
    xlswrite(fullfile(path_tmp,fileN),reg_output_sheet,1);
end
end



function reg_integrated_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

reg_curr=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID);
for i=1:numel(reg_curr)
    regCellInt=trans_obj.integrate_region_v3(reg_curr(i));
    if isempty(regCellInt)
        return;
    end
    
    display_region_stat_fig(main_figure,regCellInt);
end
end




function disp_hist_region_callback(~,~,select_plot,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');


switch class(select_plot)
    case 'region_cl'
        [trans_obj,~]=layer.get_trans(curr_disp);
        
        reg_obj=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID);
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
        reg_obj=region_cl('Name','Select Area','Idx_r',idx_r,'Idx_pings',idx_pings,'Unique_ID','1');
end

trans=layer.get_trans(curr_disp);

for i=1:length(reg_obj)
    reg_curr=reg_obj(i);
    data=trans.Data.get_subdatamat(reg_curr.Idx_r,reg_curr.Idx_pings,'field',curr_disp.Fieldname);
    
    sub_bot=trans.Bottom.Sample_idx(reg_curr.Idx_pings);
    idxBad=find(trans.Bottom.Tag==0);
    
    
    
    [sub_bot_mat,sub_sample_mat]=meshgrid(sub_bot,reg_curr.Idx_r);
    
    sub_idx_bad=intersect(reg_curr.Idx_pings,idxBad);
    sub_idx_bad=sub_idx_bad-reg_curr.Idx_pings(1)+1;
    
    switch reg_curr.Shape
        case 'Polygon'
            mask=reg_curr.MaskReg;
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
    
    new_echo_figure(main_figure,'Name',sprintf('Region %d Histogram: %s',reg_curr.ID,curr_disp.Type),'Tag',sprintf('histo%s',reg_curr.Unique_ID));
    hold on;
    title(tt);
    bar(x,pdf);
    grid on;
    ylabel('Pdf');
    xlabel(xlab);
    
end

end

