%% setBottom.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |obj|: TODO: write description and info on variable
% * |bottom_obj|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function setBottom(obj,bottom_obj)


if isempty(obj.Data)
    return;
end

if isempty(bottom_obj)
    bottom_obj=bottom_cl();
end

samples=obj.get_transceiver_samples();
pings=obj.get_transceiver_pings();

IdxBad=find(bottom_obj.Tag==0);

IdxBad(IdxBad<=0)=[];

new_bot_sple=nan(size(pings));

bot_sple=bottom_obj.Sample_idx;

if ~isempty(bot_sple)   
    i0=abs(length(bot_sple)-length(pings));
    
    if length(bot_sple)>length(pings)
        new_bot_sple(1+i0:end)=bot_sple(1:end-(i0+1));
        IdxBad=IdxBad+i0;
    elseif length(bot_sple)<length(pings)
        new_bot_sple(1+i0:i0+length(bot_sple))=bot_sple;
        IdxBad=IdxBad+i0;
    else
        new_bot_sple=bot_sple;
    end
    
    while nanmax(IdxBad)>length(pings)
        IdxBad=IdxBad-1;
    end
    
    new_bot_sple(new_bot_sple>length(samples))=length(samples);
    new_bot_sple(new_bot_sple<=0)=1;
end

tag=ones(size(new_bot_sple));
tag(IdxBad)=0;

new_bot_sple(isnan(new_bot_sple(:))&tag(:)==1)=length(samples);
obj.Bottom=bottom_cl('Origin',bottom_obj.Origin(:)','Sample_idx',new_bot_sple(:)','Tag',tag(:)','Version',bottom_obj.Version);

end