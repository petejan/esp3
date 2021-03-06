function init_listeners(main_figure)

curr_disp_obj=getappdata(main_figure,'Curr_disp');

if isappdata(main_figure,'ListenersH')
    ls=getappdata(main_figure,'ListenersH');
else
    ls=[];
end

ls=[ls addlistener(curr_disp_obj,'DispBottom','PostSet',@(src,envdata)listenDispBot(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispUnderBottom','PostSet',@(src,envdata)listenDispUnderBot(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'UnderBotTransparency','PostSet',@(src,envdata)listenUnderBotTransparency(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispBadTrans','PostSet',@(src,envdata)listenDispBadTrans(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispReg','PostSet',@(src,envdata)listenDispReg(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispTracks','PostSet',@(src,envdata)listenDispTracks(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispLines','PostSet',@(src,envdata)listenDispLines(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'CursorMode','PostSet',@(src,envdata)listenCursorMode(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'Active_reg_ID','PostSet',@(src,envdata)listenActive_reg_ID(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'ChannelID','PostSet',@(src,envdata)listenChannelID(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'Fieldname','PostSet',@(src,envdata)listenField(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'Cmap','PostSet',@(src,envdata)listenCmap(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'Cax','PostSet',@(src,envdata)listenCax(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'Font','PostSet',@(src,envdata)listenFont(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispSecFreqs','PostSet',@(src,envdata)listenDispSecFreqs(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'DispSecFreqsOr','PostSet',@(src,envdata)listenDispSecFreqs(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'H_axes_ratio','PostSet',@(src,envdata)listenAxesRatio(src,envdata,main_figure))];
ls=[ls addlistener(curr_disp_obj,'V_axes_ratio','PostSet',@(src,envdata)listenAxesRatio(src,envdata,main_figure))];
setappdata(main_figure,'ListenersH',ls);

end