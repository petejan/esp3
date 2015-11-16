function load_svp_callback(~,~,main_figure) 
layer=getappdata(main_figure,'Layer');
if layer.ID_num==0
    return;
end

[svp_filename,svp_path]= uigetfile( {fullfile(layer.PathToFile,'*.asvp*')}, 'Pick a Svp file','MultiSelect','off');   
    if svp_filename~=0
        u=importdata(fullfile(svp_path,svp_filename));
        z_c=u.data(:,1);
        c=u.data(:,2);
    else
        choice = questdlg('Do you want to continue with no SVP and constant velocity profile?', ...
            'File opening mode',...
            'Yes','No', ...
            'No');
        % Handle response
        switch choice
            case 'Yes'
                z_c=1:2*1e4;
                c=layer.Env.SoundSpeed*ones(size(z_c));
            case 'No'
                return;
        end
        
        if isempty(choice)
            return;
        end
    end
    
z_interp=z_c(1):1:z_c(end);    
c_interp=interpn(z_c,c,z_interp,'linear');

figure();
plot(c_interp,z_interp,'-o');
hold on;
plot(c,z_c,'-+');
axis ij;
ylim([z_c(1) z_c(end)]);
xlabel('SoundSpeed(m/s)');
ylabel('Depth (m)');
grid on;
legend('Interpolated','Measured');

layer.EnvData=layer.EnvData.set_svp(z_c,c);

setappdata(main_figure,'Layer',layer);

end