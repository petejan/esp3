%% generate_couples.m
%
% Generate all unique permutative couples from n numbers
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |n|: number of couples
%
% *OUTPUT VARIABLES*
%
% * |unique_couple|: matrix of couples (size (n!/(2(n-2)!))=n(n-1)/2)
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-06-15: first version Yoann Ladroit
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function


function unique_couples=generate_couples(n)

a=fliplr(fullfact(ones(1,2)*n));
b=sort(a,2);
idx=any(~diff(b')',2);
a(idx,:)=[];

a = sort(a, 2);
[u, idx] = unique(a, 'rows');

unique_couples=nan(size(u));
unique_couples(:,1) = a(idx,1);
unique_couples(:,2) = a(idx,2);
