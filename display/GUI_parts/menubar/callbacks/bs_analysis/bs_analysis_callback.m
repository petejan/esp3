function bs_analysis_callback(~,~,main_figure)
update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
choice = questdlg('Do you want Use Ray tracing?', ...
    'Ray tracing',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'Yes'
        ray_tray=1;
        
    case 'No'
        ray_tray=0;
    otherwise
        ray_tray=0;
end

phi_std_thr=20/180*pi;
trans_angle=[0 -45];%pitch roll
pos_trans=[-5;-5;-5];%dalong dacross dz
att_cal=[0 0];

bs_analysis(layer,'IdxFreq',idx_freq,'PhiStdThr',phi_std_thr,'TransAngle',trans_angle,'PosTrans',pos_trans,'AttCal',att_cal,'RayTrayBool',ray_tray)


end