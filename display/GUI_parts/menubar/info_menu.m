function info_menu(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
dialog_fig=new_echo_figure(main_figure,...
    'Units','pixels','Position',[200 100 500 200],...
    'Name','Infos',...
    'Resize','off',...
    'Tag','infos',...
    'visible','off');

version=get_ver();
bgcolor = num2cell(get(main_figure, 'Color'));

labelStr1 = ['<html>' '<body><h3>' sprintf('ESP3 version %s',version) '</h3></body></html>'];
jLabel1 = javaObjectEDT('javax.swing.JLabel', labelStr1);
[hjLabel1,~] = javacomponent(jLabel1, [10,160,480,40], dialog_fig);
hjLabel1.setBackground(java.awt.Color(bgcolor{:}));


labelStr = '<html>Releases: <a href="https://sourceforge.net/projects/esp3/">ESP3 on SourceForge</a></html>';
jLabel = javaObjectEDT('javax.swing.JLabel', labelStr);
[hjLabel,~] = javacomponent(jLabel, [10,120,480,20], dialog_fig);
hjLabel.setBackground(java.awt.Color(bgcolor{:}));
set(hjLabel, 'MouseClickedCallback', @(h,e)web('https://sourceforge.net/projects/esp3/','-browser'))
hjLabel.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
hjLabel.setToolTipText('https://sourceforge.net/projects/esp3/');

labelStr = '<html>Source and help: <a href="https://bitbucket.org/echoanalysis/esp3/wiki/Home">ESP3 on Bitbucket</u></html>';
jLabel = javaObjectEDT('javax.swing.JLabel', labelStr);
[hjLabel,~] = javacomponent(jLabel, [10,100,480,20], dialog_fig);
hjLabel.setBackground(java.awt.Color(bgcolor{:}));
 set(hjLabel, 'MouseClickedCallback', @(h,e)web('https://bitbucket.org/echoanalysis/esp3/wiki/Home','-browser'))
 hjLabel.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
 hjLabel.setToolTipText('https://bitbucket.org/echoanalysis/esp3/wiki/Home');

labelStr = ['<html><u>'...
'Contacts:</u></html>'];
jLabel = javaObjectEDT('javax.swing.JLabel', labelStr);
[hjLabel,~] = javacomponent(jLabel, [10,70,480,20], dialog_fig);
hjLabel.setBackground(java.awt.Color(bgcolor{:}));

labelStryl ='<html><body>Yoann Ladroit : <a href="mailto:yoann.ladroit@niwa.co.nz">yoann.ladroit@niwa.co.nz</a></body></html>';
labelStrpe ='<html><body>Pablo Escobar-Flores: <a href="mailto:pablo.escobar@niwa.co.nz">pablo.escobar@niwa.co.nz</a></body></html>';
labelStras ='<html><body>Alexandre Schimel: <a href="mailto:alex.schimel@niwa.co.nz">alex.schimel@niwa.co.nz</a></body></html>';


jLabelyl = javaObjectEDT('javax.swing.JLabel', labelStryl);
[hjLabelyl,~] = javacomponent(jLabelyl, [10,50,480,20], dialog_fig);
hjLabelyl.setBackground(java.awt.Color(bgcolor{:}));
set(hjLabelyl, 'MouseClickedCallback', @(h,e)web('mailto:yoann.ladroit@niwa.co.nz'))
hjLabelyl.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
hjLabelyl.setToolTipText('mailto:yoann.ladroit@niwa.co.nz');
  
jLabelpe = javaObjectEDT('javax.swing.JLabel', labelStrpe);
[hjLabelpe,~] = javacomponent(jLabelpe, [10,30,480,20], dialog_fig);
hjLabelpe.setBackground(java.awt.Color(bgcolor{:}));
set(hjLabelpe, 'MouseClickedCallback', @(h,e)web('mailto:pablo.escobar@niwa.co.nz'))
hjLabelpe.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
hjLabelpe.setToolTipText('mailto:pablo.escobar@niwa.co.nz');
  
jLabelas = javaObjectEDT('javax.swing.JLabel', labelStras);
[hjLabelas,~] = javacomponent(jLabelas, [10,10,480,20], dialog_fig);
hjLabelas.setBackground(java.awt.Color(bgcolor{:}));
set(hjLabelas, 'MouseClickedCallback', @(h,e)web('mailto:alex.schimel@niwa.co.nz'))
hjLabelas.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
hjLabelas.setToolTipText('mailto:alex.schimel@niwa.co.nz');


% Set the label's tooltip
%hjLabel.setToolTipText(['Visit the ' real_struct.url ' website']);
format_color_gui(dialog_fig,curr_disp.Font);

set(dialog_fig,'Visible','on');
centerfig(dialog_fig);

end