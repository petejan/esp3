%% check_fmt_box.m
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
% * |src|: TODO: write description and info on variable
% * |evt|: TODO: write description and info on variable
% * |min_val|: TODO: write description and info on variable
% * |max_val|: TODO: write description and info on variable
% * |deflt_val|: TODO: write description and info on variable
% * |precision|: TODO: write description and info on variable
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
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function check_fmt_box(src,evt,min_val,max_val,deflt_val,precision)

E = str2double(get(src,'string'));

if ~isnan(E)&&isnumeric(E)
    if E >= max_val && E <=min_val
        set(hObject_S,'value',E)
    elseif E < min_val
        set(src,'string',num2str(min_val,precision))
    elseif E > max_val
        set(src,'string',num2str(max_val,precision))
    end
else
    set(src,'string',num2str(deflt_val,precision));
end


end