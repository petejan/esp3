function set_single_select_mode_table(h)  

% Get java scroll pane object
j_scrollpane = findjobj(h);

% Get java table object
j_table = j_scrollpane.getViewport.getView;

% (optional) Make entire ROW highlighted when user clicks on any row(s)
j_table.setNonContiguousCellSelection(false);
j_table.setColumnSelectionAllowed(false);
j_table.setRowSelectionAllowed(true);

% Set selection mode to SINGLE_SELECCTION
j_table.setSelectionMode(0);
j_table.setCellSelectionEnabled(true);
j_table.update();
