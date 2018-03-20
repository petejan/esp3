function update_echo_int_alphamap(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');

if ~isempty(echo_int_tab_comp.main_plot.UserData)    
    switch echo_int_tab_comp.main_plot.UserData
        case {'nb_samples' 'prc'}
            cd=echo_int_tab_comp.main_plot.CData;
            cax=[prctile(cd(:),5) prctile(cd(:),95)];
        otherwise
            cax=curr_disp.getCaxField(echo_int_tab_comp.main_plot.UserData);
    end
    alpha_data= echo_int_tab_comp.main_plot.CData>cax(1);
    
    set(echo_int_tab_comp.main_ax,'Clim',cax);
    set(echo_int_tab_comp.main_plot,'alphadata',alpha_data);
end

end