function help_menu(~,~)
dialog_fig=figure('Visible','on',...
    'Units','pixels','Position',[500 300 400 300],...                                      
    'Name','Shortcuts','NumberTitle','off',...   
    'Resize','on',...
    'MenuBar','none',...
    'visible','on');

labelStr = ['<html><ul>Shortcuts:'...
    '<li><i>1</i> : Zoom In (right click for vertical zoom)</li>'...
    '<li><i>Shift+1</i> : Zoom Out (right click for zoom all)</li>'...
    '<li><i>2</i> : Mark bad transmit</li>'...
    '<li><i>3</i> : Edit Bottom</li>'...
    '<li><i>4</i> : Create Region</li>'...
    '<li><i>b</i> : Toggle Under bottom display</li>'...
    '<li><i>r</i> : Toggle Region display</li>'...
    '<li><i>t</i> : Toggle Bad Transmit display</li>'...
    '<li><i>f</i> : Change Frequency</li>'...
    '<li><i>e</i> : Change Data displayed</li>'...
    '</ul></html>'];
jLabel = javaObjectEDT('javax.swing.JLabel',labelStr);
[~,~] = javacomponent(jLabel,[0,0,360,300],dialog_fig);
end