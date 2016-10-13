function fig=disp_config_params(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'idx_ping',1,@isnumeric);

parse(p,trans_obj,varargin{:});

fig =new_echo_figure([],'Units','pixels','Position',[200 300 800 400],'Resize','off',...
    'Name',sprintf('Configuration/Parameters %s ping %d',trans_obj.Config.ChannelID,p.Results.idx_ping),...
    'MenuBar','none','Tag',sprintf('config_params%s',trans_obj.Config.ChannelID));

config_str=trans_obj.Config.config2str();

jLabel = javaObjectEDT('javax.swing.JLabel',config_str);
[~,~] = javacomponent(jLabel,[0,0,500,400],fig);

param_str=trans_obj.Params.param2str(p.Results.idx_ping);

jLabel = javaObjectEDT('javax.swing.JLabel',param_str);
[~,~] = javacomponent(jLabel,[500,0,300,400],fig);

end