function listenActive_reg_ID(~,listdata,main_figure)

if~isdeployed
    disp('listenActive_reg_ID')
end

ID=listdata.AffectedObject.Active_reg_ID;

activate_region_callback(ID,main_figure);

update_reglist_tab(main_figure,0);

end