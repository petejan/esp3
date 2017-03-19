function [tags,channelID,freq,IDs,ver] = list_tags_regions_xml(reg_xml_file)
% [tags,channelID,freq,IDs,ver] = list_tags_regions_xml(reg_xml_file)
%
% DESCRIPTION
%
% List tags contained in a region XML file
%
% USE
%
%
% PROCESSING SUMMARY
%
%
% INPUT VARIABLES
%
% -reg_xml_file: full path to region XML file
%
% OUTPUT VARIABLES
%
% -tags: cell containing tags for each regions
% -channelID: cell channel containing for which the region has been defined
% -freq: vector containing frequency for which the region has been defined
% -IDs: vector containing region IDs
% -version of the database that is in the file (-1 is XML only)
%
% RESEARCH NOTES

%
% NEW FEATURES
%
% 2017-03-16: first version.
%
% EXAMPLE
%
%
%%%
% Yoann Ladroit NIWA
%%%



[region_xml,ver]=parse_region_xml(reg_xml_file);

nb_freq=length(region_xml);

nb_reg=0;
for i=1:nb_freq
    nb_reg=length(region_xml{i}.Regions)+nb_reg;
end

tags=cell(1,nb_reg);
channelID=cell(1,nb_reg);
freq=nan(1,nb_reg);
IDs=nan(1,nb_reg);

u=0;
for i=1:nb_freq
    for ir=1:length(region_xml{i}.Regions)
        u=u+1;
        tags{u}=region_xml{i}.Regions{ir}.Tag;
        channelID{u}=region_xml{i}.Infos.ChannelID;
        freq(u)=region_xml{i}.Infos.Freq;
        IDs(u)=region_xml{i}.Regions{ir}.ID;
    end
end


end
