function reload_logbook_fig(log_tab,file_add)
path_db=getappdata(log_tab,'path_data');
data_ori=getappdata(log_tab,'data_ori');
surv_data_table=getappdata(log_tab,'surv_data_table');
dbconn=sqlite(fullfile(path_db,'echo_logbook.db'),'connect');
data_ori_new=update_data_table(dbconn,data_ori,file_add,path_db);
setappdata(log_tab,'data_ori',data_ori_new);
set(surv_data_table.table_main,'Data',data_ori_new);
dbconn.close();
search_callback([],[],log_tab);