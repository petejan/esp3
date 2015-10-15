function display_saved_mbs_callback(~,~,hObject_main)

hfigs=getappdata(hObject_main,'ExternalFigures');
mbs_vec=getappdata(hObject_main,'MBS');

if ~isempty(mbs_vec)
    hfig=figure();
    hold on;
    nb_row=ceil(length(mbs_vec)/3);
    nb_col=nanmin(length(mbs_vec),3);
    for i=1:length(mbs_vec)
        ax(i)= subplot(nb_row,nb_col,i);
        mbs_vec(i).display_mbs_results_map(ax(i));
    end
end

hfigs_new=[hfigs hfig];
setappdata(hObject_main,'ExternalFigures',hfigs_new);

end