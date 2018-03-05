%% display_layer.m
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
% * |layer|: TODO: write description and info on variable
% * |curr_disp|: TODO: write description and info on variable
% * |fieldname|: TODO: write description and info on variable
% * |ax|: TODO: write description and info on variable
% * |main_echo|: TODO: write description and info on variable
% * |x|: TODO: write description and info on variable
% * |y|: TODO: write description and info on variable
% * |new|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |dr|: TODO: write description and info on variable
% * |dp|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel). 
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [dr,dp]=display_layer(layer,curr_disp,fieldname,ax,main_echo,x,y,new)


[trans_obj,~]=layer.get_trans(curr_disp);
if isempty(trans_obj)
    return;
end

screensize = getpixelposition(ax);

xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();

% ydata_r=trans_obj.get_transceiver_range();

if new==0
    [~,idx_ping_min]=nanmin(abs(xdata-x(1)));
    [~,idx_r_min]=nanmin(abs(ydata-y(1)));
    [~,idx_ping_max]=nanmin(abs(xdata-x(2)));
    [~,idx_r_max]=nanmin(abs(ydata-y(2)));
    if y(2)==Inf
        idx_r_max=length(ydata);
    end
    idx_ping=idx_ping_min:idx_ping_max;
    idx_r=idx_r_min:idx_r_max;
else
    idx_ping=1:length(xdata);
    idx_r=1:length(ydata);
    idx_ping=idx_ping(1:floor(nanmin(screensize(3),length(idx_ping))));
    %idx_r=idx_r(1:floor(nanmin(3*screensize(4),length(idx_r))));
    idx_r=idx_r(1:length(idx_r));
    x=[xdata(idx_ping(1)) xdata(idx_ping(end))];
    y=[ydata(1) ydata(idx_r(end))];
end


nb_samples=length(idx_r);
nb_pings=length(idx_ping);

outputSize=nanmin(screensize(3:4),[nb_pings nb_samples]);


dr=nanmax(floor(nb_samples/outputSize(2))-1,1);
dp=nanmax(floor(nb_pings/outputSize(1))-1,1);

% profile on;
 [data,sc]=trans_obj.Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);
%data=trans_obj.Data.get_datamat(fieldname);
% profile off;
% profile viewer;
% % 


if isempty(data)
    switch  fieldname
        case 'spdenoised'
            fieldname='sp';
            [data,sc]=trans_obj.Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);
        case 'svdenoised'
            fieldname='sv';
            [data,sc]=trans_obj.Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);           
    end
    
end

x_data_disp=xdata(idx_ping);
y_data_disp=ydata(idx_r);
if isempty(data)
    data=nan(numel(y_data_disp),numel(x_data_disp));
    sc='lin';
end

switch sc
    case 'lin'
        data_mat=10*log10(abs(data));
    otherwise
        data_mat=data;
end

data_mat=single(real(data_mat));


set(main_echo,'XData',x_data_disp,'YData',y_data_disp,'CData',data_mat);
% x
% [x_data_disp(1) x_data_disp(end)]
if length(x)>1
    set(ax,'xlim',[x(1) x(end)]);
end
% y
% [y_data_disp(1) y_data_disp(end)]
if length(y_data_disp)>1
    set(ax,'ylim',[y(1) y(end)]);
end

end