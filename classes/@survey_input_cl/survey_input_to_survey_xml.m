function survey_input_to_survey_xml(survey_input_obj,varargin)

p = inputParser;

addRequired(p,'survey_input_obj',@(x) isa(x,'survey_input_cl'));
addParameter(p,'xml_filename',fullfile(pwd,'survey_xml.xml'),@ischar);
% addParameter(p,'Author','',@ischar);
% addParameter(p,'Comment','',@ischar);
% addParameter(p,'Main_species','',@ischar);
% addParameter(p,'Title','',@ischar);
addParameter(p,'open_file',true,@islogical);

parse(p,survey_input_obj,varargin{:});


docNode = com.mathworks.xml.XMLUtils.createDocument('survey_processing');
main_node=docNode.getDocumentElement;
survey_node = docNode.createElement('survey');
fields_infos=fields(survey_input_obj.Infos);
%
% for i=1:length(fields_infos)
%     if isfield(p.Results,fields_infos{i})
%         survey_input_obj.Infos.(fields_infos{i})=p.Results.(fields_infos{i});
%     end
% end
survey_input_obj.Infos.Created=datestr(now);

for i=1:length(fields_infos)
    survey_node.setAttribute(fields_infos{i},survey_input_obj.Infos.(fields_infos{i}));
end



main_node.appendChild(survey_node);

options_node = docNode.createElement('options');
fields_opts=fields(survey_input_obj.Options);
for i=1:length(fields_opts)
    if isnumeric(survey_input_obj.Options.(fields_opts{i}))
        options_node.setAttribute(fields_opts{i},num2str(survey_input_obj.Options.(fields_opts{i}),'%.0f '));
    else
        options_node.setAttribute(fields_opts{i},survey_input_obj.Options.(fields_opts{i}));
    end
end
main_node.appendChild(options_node);

for ical=1:length(survey_input_obj.Cal)
    cal_node = docNode.createElement('cal');
    fields_cal=fields(survey_input_obj.Cal(ical));
    for i=1:length(fields_cal)
        switch fields_cal{i}
            case 'FREQ'
                cal_node.setAttribute(fields_cal{i},num2str(survey_input_obj.Cal(ical).(fields_cal{i}),'%.0f '));
            otherwise
                cal_node.setAttribute(fields_cal{i},num2str(survey_input_obj.Cal(ical).(fields_cal{i}),'%.2f '));
        end
    end
    
    main_node.appendChild(cal_node);
    
end


algo_node = docNode.createElement('algos');
for ial=1:length(survey_input_obj.Algos)
    al_node = docNode.createElement(survey_input_obj.Algos{ial}.Name);
    fields_al=fields(survey_input_obj.Algos{ial}.Varargin);
    for i=1:length(fields_al)
        if isnumeric(survey_input_obj.Algos{ial}.Varargin.(fields_al{i}))||islogical(survey_input_obj.Algos{ial}.Varargin.(fields_al{i}))
            al_node.setAttribute(fields_al{i},num2str(survey_input_obj.Algos{ial}.Varargin.(fields_al{i})));
        else
            al_node.setAttribute(fields_al{i},survey_input_obj.Algos{ial}.Varargin.(fields_al{i}));
        end
    end
    algo_node.appendChild(al_node);
    
end
main_node.appendChild(algo_node);

if ~isempty(survey_input_obj.Regions_WC)
    for iregwc=1:length(survey_input_obj.Regions_WC)
        reg_wc_node = docNode.createElement('regions_WC');
        fields_reg_wc=fields(survey_input_obj.Regions_WC{iregwc});
        for i=1:length(fields_reg_wc)
            if isnumeric(survey_input_obj.Regions_WC{iregwc}.(fields_reg_wc{i}))
                reg_wc_node.setAttribute(fields_reg_wc{i},num2str(survey_input_obj.Regions_WC{iregwc}.(fields_reg_wc{i})));
            else
                reg_wc_node.setAttribute(fields_reg_wc{i},survey_input_obj.Regions_WC{iregwc}.(fields_reg_wc{i}));
            end
        end
        main_node.appendChild(reg_wc_node);
    end
    
end

if ~isempty(survey_input_obj.Snapshots)
    for isnap=1:length(survey_input_obj.Snapshots)
        snap_node = docNode.createElement('snapshot');
        snap_node.setAttribute('number',num2str(survey_input_obj.Snapshots{isnap}.Number));
        snap_node.setAttribute('folder',survey_input_obj.Snapshots{isnap}.Folder);
        for istrat=1:length(survey_input_obj.Snapshots{isnap}.Stratum)
            strat_node = docNode.createElement('stratum');
            strat_node.setAttribute('name',survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Name);
            for itrans=1:length(survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects)
                trans_node = docNode.createElement('transect');
                trans_node.setAttribute('number',num2str(survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.number));
                
                for ireg=1:length(survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Regions)
                    reg_node = docNode.createElement('region');
                    reg=survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Regions{ireg};
                    if isfield(reg,'ver')
                        reg_node.setAttribute('ver',num2str(reg.ver));
                        if isfield(reg,'IDs')
                            if ischar(reg.IDs)
                                reg_node.setAttribute('IDs',reg.IDs);
                            else
                                reg_node.setAttribute('IDs',num2str(reg.IDs));
                            end
                        end
                    end
                    
                    if isfield(reg,'name')
                        reg_node.setAttribute('name',reg.name);
                    end
                    trans_node.appendChild(reg_node);
                end
                
                
                
                bot_node = docNode.createElement('bottom');
                bot=survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Bottom;
                
                if isfield(bot,'ver')
                    bot_node.setAttribute('ver',num2str(bot.ver));
                end
                
                trans_node.appendChild(bot_node);
                
                strat_node.appendChild(trans_node);
                
            end
            snap_node.appendChild(strat_node);
        end
        main_node.appendChild(snap_node);
    end
    
    
    
    xmlwrite(p.Results.xml_filename,docNode);
    %type(xml_file);
    if p.Results.open_file
        open(p.Results.xml_filename);
        [stat,~]=system(['start notepad++ ' p.Results.xml_filename]);
        if stat~=0
            disp('You should install Notepad++...');
            system(['start ' p.Results.xml_filename]);
        end
    end
    
    
end