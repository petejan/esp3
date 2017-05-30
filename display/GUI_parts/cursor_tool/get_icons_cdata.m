function icon=get_icons_cdata(icon_dir)



icon.zin  = iconRead(fullfile(icon_dir,'tool_zoom_in.png'));

icon.zout = iconRead(fullfile(icon_dir,'tool_zoom_out.png'));

icon.fplot = iconRead(fullfile(icon_dir,'freq_plot.png'));

icon.bad_trans = iconRead(fullfile(icon_dir,'bad_trans.png'));

icon.pan = iconRead(fullfile(icon_dir,'pan.png'));

icon.ts_cal = iconRead(fullfile(icon_dir,'ts_cal.png'));

icon.eba_cal = iconRead(fullfile(icon_dir,'eba_cal.png'));

icon.edit_bot = iconRead(fullfile(icon_dir,'edit_bot.png'));

icon.folder = iconRead(fullfile(icon_dir,'folder_small.png'));

icon.del_lay = iconRead(fullfile(icon_dir,'delete.png'));

icon.prev_lay = iconRead(fullfile(icon_dir,'prev.png'));

icon.next_lay = iconRead(fullfile(icon_dir,'next.png'));

icon.add = iconRead(fullfile(icon_dir,'add.png'));

icon.undock= iconRead(fullfile(icon_dir,'undock.png'));

icon.ruler= iconRead(fullfile(icon_dir,'ruler.png'));

icon.create_reg= iconRead(fullfile(icon_dir,'create_reg.png'));
end