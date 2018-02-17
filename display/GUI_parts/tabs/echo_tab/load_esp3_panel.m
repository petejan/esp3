function load_esp3_panel(main_figure,echo_tab_panel)

esp3_tab_comp.esp3_tab=new_echo_tab(main_figure,echo_tab_panel,'Title','ESP3');

jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
[esp3_tab_comp.browser,esp3_tab_comp.browser_container] = javacomponent(jObject, [], esp3_tab_comp.esp3_tab);
set(esp3_tab_comp.browser_container, 'Units','norm', 'Pos',[0,0,1,1]);
adress=sprintf('%s/html/index.html',whereisEcho());
esp3_tab_comp.browser.setCurrentLocation(adress);

setappdata(main_figure,'esp3_tab',esp3_tab_comp);

end