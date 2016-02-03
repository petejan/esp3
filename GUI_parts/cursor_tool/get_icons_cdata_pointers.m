function icon_pointer=get_icons_cdata_pointers(icon_dir)

icon=get_icons_cdata(icon_dir);
icon_fields=fieldnames(icon);

for i=1:length(icon_fields)
icon_pointer.(icon_fields{i})=double(nansum(icon.(icon_fields{i}),3)>0);
icon_pointer.(icon_fields{i})(icon_pointer.(icon_fields{i})==0)=nan;
end



end