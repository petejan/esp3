function line_node=surv_data_to_logbook_xml(surv_data_obj,docNode,filename,varargin)

p = inputParser;

addRequired(p,'surv_data_obj',@(x) isa(x,'survey_data_cl'));
addRequired(p,'docNode',@(x) isa(x,'org.apache.xerces.dom.DocumentImpl'));
addRequired(p,'filename',@ischar);
addParameter(p,'StartTime',0,@isnumeric);
addParameter(p,'EndTime',1,@isnumeric);
parse(p,surv_data_obj,docNode,filename,varargin{:});

if p.Results.StartTime==0
    st=datestr(get_start_date_from_raw(filename),'yyyymmddHHMMSS');
else
    st=datestr(p.Results.StartTime,'yyyymmddHHMMSS');
end

if p.Results.EndTime==1
    et='1';
else
    et=datestr(p.Results.EndTime,'yyyymmddHHMMSS');
end


line_node = docNode.createElement('line');
line_node.setAttribute('Filename',deblank(filename));
line_node.setAttribute('Snapshot',num2str(surv_data_obj.Snapshot,'%.0f'));

if ~ischar(surv_data_obj.Comment)
    line_node.setAttribute('Comment',num2str(surv_data_obj.Comment,'%.0f'));
else
    line_node.setAttribute('Comment', surv_data_obj.Comment);
end

if ~ischar(surv_data_obj.Stratum)
    line_node.setAttribute('Stratum',num2str(surv_data_obj.Stratum,'%.0f'));
else
    line_node.setAttribute('Stratum', surv_data_obj.Stratum);
end

line_node.setAttribute('Transect',num2str(surv_data_obj.Transect,'%.0f'));
line_node.setAttribute('StartTime',st);
line_node.setAttribute('EndTime',et);


end