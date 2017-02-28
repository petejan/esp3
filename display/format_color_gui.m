function format_color_gui(fig,font_choice)
%background_col=get(groot,'defaultUicontrolBackgroundColor');

background_col='white';
for i=1:length(fig)
    set(fig(i),'Color',background_col);
    panel_obj=findobj(fig(i),'Type','uipanel');
    set(panel_obj,'BackgroundColor',background_col,'bordertype','line');
    
    % tabgroup_obj=findobj(fig(i),'Type','uitabgroup');
    % set(tabgroup_obj,'BackgroundColor','White','bordertype','line');
       
    % set background color of all tab objects that have one to white
    tab_obj=findobj(fig(i),'Type','uitab','-property','BackgroundColor');
    set(tab_obj,'BackgroundColor',background_col);
    
    % set background color of all button group objects that have one to white
    buttongroup_obj=findobj(fig(i),'Type','uibuttongroup','-property','BackgroundColor');
    set(buttongroup_obj,'BackgroundColor',background_col);
    
    control_obj=findobj(fig(i),'Type','uicontrol','-not',{'Style','PushButton','-or','Style','togglebutton'});
    set(control_obj,'BackgroundColor',background_col);
    
    if~isempty(font_choice)
        if strcmp(fig(i).Tag,'font_choice')
            continue;
        end
        text_obj=findobj(fig(i),'-property','FontName');
        
        %set(text_obj,'FontName','Gabriola');
        %set(text_obj,'FontName','	');
        set(text_obj,'FontName',font_choice);
    end
    
    % size_obj=findobj(fig,'-property','FontSize');
    % set(size_obj,'FontSize',12);
end
end