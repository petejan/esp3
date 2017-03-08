function hfig=display_region_stat_fig(main_figure,regIntStruct)
%
% DESCRIPTION
%
% Display figure with table summarizing region stats.
%
% INPUT VARIABLES
%
% [This section contains bullet points of input variables with types and description]
% - main_figure: handle to main ESP3 window
% - regIntStruct: output from integrate_region
% OUTPUT VARIABLES
%
% [This section contains bullet points of output variables]
% - hfig: handle to created figure
% RESEARCH NOTES
%
% [This section describes what features are temporary, needed future developments and paper references.]

% NEW FEATURES
%
% [This section contains dates and descriptions of major updates]
% YYYY-MM-DD: second version. Describes the update.
% 2017-03-07: first version.
%
%
%%%
% Yoann Ladroit, NIWA
%%%

hfig=new_echo_figure(main_figure,'Tag','reg_stat','Resize','off','Units','pixels','Position',[200 200 400 400]);

columnname = {'Variable','Value','unit'};
columnformat = {'char','numeric','char'};
regSummary=cell(4,3);
regSummary{1,1}='Sv Mean';
regSummary{1,2}=pow2db_perso(nanmean(regIntStruct.Sv_mean_lin(:)));
regSummary{1,3}='dB';

regSummary{2,1}='NASC Esp2';
regSummary{2,2}=4*pi*1852^2*nansum(nansum(regIntStruct.Sa_lin))./nansum(nanmax(regIntStruct.Nb_good_pings_esp2));
regSummary{2,3}='m2/nmi2';

regSummary{3,1}='NASC Esp3';
regSummary{3,2}=4*pi*1852^2*nansum(nansum(regIntStruct.Sa_lin))./nansum(nanmax(regIntStruct.Nb_good_pings));
regSummary{3,3}='m2/nmi2';

regSummary{4,1}='NASC Echoview';
regSummary{4,2}=nanmean(nansum(regIntStruct.NASC));
regSummary{4,3}='m2/nmi2';


table_main=uitable('Parent',hfig,...
    'Data', regSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false false false],...
    'Units','Normalized','Position',[0 0 1 1],...
    'RowName',[]);

pos_t = getpixelposition(table_main);

set(table_main,'ColumnWidth',{pos_t(3)/3, pos_t(3)/3, pos_t(3)/3});
movegui(hfig,'center');