function icon=get_icons_cdata(icon_dir)

icon.zin  = iconRead([icon_dir 'tool_zoom_in.png']);

icon.zout = iconRead([icon_dir 'tool_zoom_out.png']);

icon.fplot = iconRead([icon_dir 'freq_plot.png']);

icon.bad_trans = iconRead([icon_dir 'bad_trans.png']);

icon.pan = iconRead([icon_dir 'pan.png']);

icon.ts_cal = iconRead([icon_dir 'ts_cal.png']);

icon.eba_cal = iconRead([icon_dir 'eba_cal.png']);

icon.edit_bot = iconRead([icon_dir 'edit_bot.png']);



end