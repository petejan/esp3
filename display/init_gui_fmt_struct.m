function gui_fmt=init_gui_fmt_struct()

gui_fmt.x_sep=10;
gui_fmt.y_sep=5;
gui_fmt.txt_w=110;
gui_fmt.txt_h=25;
gui_fmt.box_w=40;
gui_fmt.box_h=30;
gui_fmt.button_w=60;
gui_fmt.button_h=30;

gui_fmt.txtStyle=struct('Style','text','units','pixels','HorizontalAlignment','right','BackgroundColor','white');
gui_fmt.txtTitleStyle=struct('Style','text','units','pixels','HorizontalAlignment','center','BackgroundColor','white','Fontweight','Bold');
gui_fmt.edtStyle=struct('Style','Edit','units','pixels','BackgroundColor','white');
gui_fmt.pushbtnStyle=struct('Style','pushbutton','units','pixels');
gui_fmt.chckboxStyle=struct('Style','checkbox','Units','pixels','BackgroundColor','white');
gui_fmt.popumenuStyle=struct('Style','popupmenu','Units','pixels');
gui_fmt.lstboxStyle=struct('Style','listbox','Units','pixels');