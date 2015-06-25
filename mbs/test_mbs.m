% clear all;
% close all;


idx_file=[1 2 3];

%script = 'JO20130212120719'; %This the the CVS name for the MBS script that ESP2 processes
%script='JO20130218124319';
script = 'YL20140303095949';
mbs=mbs_cl();
mbs.readMbsScript(script);
mbs.convertBRfromMbs(idx_file);
%mbs.rawDir=fullfile('X:\','tan1301\hull\ek60\');
mbs.rawDir=fullfile('X:\','tan1401\hull\ek60\');
mbs.regionSummary(idx_file);
mbs.stratumSummary

%mbs.outputFile='CR2013_MatlabMBS_output.txt';
mbs.outputFile='CR2014_MatlabMBS_output.txt';

mbs.printOutput;

%check_diff('CR2013_MatlabMBS_output.txt','mbscr2013_output.txt');

check_diff('CR2014_MatlabMBS_output.txt','mbscr2014_output.txt');





