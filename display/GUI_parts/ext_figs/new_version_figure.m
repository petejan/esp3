function new_version_figure(main_figure)
echo_ver = get_ver();
fprintf('Version %s\n',echo_ver);
if isdeployed()
    try
        %echo_ver='0.8.1';
        fprintf('Checking for updates...');
        tmp=webread('http://sourceforge.net/projects/esp3/best_release.json',weboptions('ContentType','json'));
        real_struct=tmp.platform_releases.windows;
        real_filename=real_struct.filename;
        last_ver=sscanf(real_filename,'/esp3_install_ver_%1d.%1d.%1d.msi');
        curr_ver=sscanf(echo_ver,'%1d.%1d.%1d');
        new_bool=last_ver>curr_ver;
        new_same_bool=last_ver>=curr_ver;
        new=0;
        if new_bool(1)>0
            new=1;
        elseif new_bool(2)>0&&new_same_bool(1)>0
            new=1;
        elseif new_bool(3)>0&&new_same_bool(2)>0&&new_same_bool(1)>0
            new=1;
        end
        
        if new>0
            
            QuestFig=new_echo_figure(main_figure,'units','pixels','position',[200 200 400 100],...
                'WindowStyle','modal','Visible','on','resize','off','tag','dlnewversion','Name','Update Available');
            bgcolor = num2cell(get(main_figure, 'Color'));
            centerfig(QuestFig);
            % Create and display the text label
            labelStr = sprintf('<html>New version available! Download here: <a href="">%s</a></html>',real_struct.url);
            jLabel = javaObjectEDT('javax.swing.JLabel', labelStr);
            [hjLabel,~] = javacomponent(jLabel, [10,20,380,80], QuestFig);           
            % Modify the mouse cursor when hovering on the label
            hjLabel.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
            hjLabel.setBackground(java.awt.Color(bgcolor{:}));
            % Set the label's tooltip
            %hjLabel.setToolTipText(['Visit the ' real_struct.url ' website']);
            
            % Set the mouse-click callback
            set(hjLabel, 'MouseClickedCallback', @(h,e)web(real_struct.url, '-browser'))
                       
        end
    catch
        disp('Could not check for updates online');
    end
end





end