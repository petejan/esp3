function save_st_to_xls_callback(~,~,main_figure)
 
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[path_lay,files] = layer.get_path_files();

[~,fname,~]=fileparts(files{1});
trans_obj=layer.get_trans(curr_disp.Freq);


 file_path = path_lay{1};
 [Filename,path_f] = uiputfile( {fullfile(file_path,sprintf('%s_ST_%.0f.xlsx',fname,curr_disp.Freq))}, 'Save Single Targets');
 
 if Filename==0
     return;
 end
 
 file=fullfile(path_f,Filename);
 
 trans_obj.save_st_to_xls(file);
 