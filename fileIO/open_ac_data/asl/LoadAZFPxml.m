% Parameters: the instrument parameters from the XML file
%
% Ver 1.1 October 31, 2016 
% written by Dave Billenness
% ASL Environmental Sciences Inc.
% 1-6703 Rajpur Place, Victoria, B.C., V8M 1Z5, Canada
% T: +1 (250) 656-0177 ext. 126
% E: dbillenness@aslenv.com 
% w: http://www.aslenv.com/ 
% For any suggestions, comments, questions or collaboration, please contact me.
%**********************************************************
function Parameters = LoadAZFPxml(pathname,xmlfilename,Parameters)

xDoc = xmlread(fullfile(pathname, xmlfilename));

Parameters.NumFreq = str2double(xDoc.getElementsByTagName('NumFreq').item(0).getFirstChild.getData);
Parameters.SerialNumber = str2double(xDoc.getElementsByTagName('SerialNumber').item(0).getFirstChild.getData);
Parameters.BurstInterval = str2double(xDoc.getElementsByTagName('BurstInterval').item(0).getFirstChild.getData);
Parameters.PingsPerBurst = str2double(xDoc.getElementsByTagName('PingsPerBurst').item(0).getFirstChild.getData);
Parameters.AverageBurstPings = str2double(xDoc.getElementsByTagName('AverageBurstPings').item(0).getFirstChild.getData);

% temperature coeff
Parameters.ka = str2double(xDoc.getElementsByTagName('ka').item(0).getFirstChild.getData);
Parameters.kb = str2double(xDoc.getElementsByTagName('kb').item(0).getFirstChild.getData);
Parameters.kc = str2double(xDoc.getElementsByTagName('kc').item(0).getFirstChild.getData);
Parameters.A = str2double(xDoc.getElementsByTagName('A').item(0).getFirstChild.getData);
Parameters.B = str2double(xDoc.getElementsByTagName('B').item(0).getFirstChild.getData);
Parameters.C = str2double(xDoc.getElementsByTagName('C').item(0).getFirstChild.getData);

% tilts
Parameters.X_a = str2double(xDoc.getElementsByTagName('X_a').item(0).getFirstChild.getData);
Parameters.X_b = str2double(xDoc.getElementsByTagName('X_b').item(0).getFirstChild.getData);
Parameters.X_c = str2double(xDoc.getElementsByTagName('X_c').item(0).getFirstChild.getData);
Parameters.X_d = str2double(xDoc.getElementsByTagName('X_d').item(0).getFirstChild.getData);
Parameters.Y_a = str2double(xDoc.getElementsByTagName('Y_a').item(0).getFirstChild.getData);
Parameters.Y_b = str2double(xDoc.getElementsByTagName('Y_b').item(0).getFirstChild.getData);
Parameters.Y_c = str2double(xDoc.getElementsByTagName('Y_c').item(0).getFirstChild.getData);
Parameters.Y_d = str2double(xDoc.getElementsByTagName('Y_d').item(0).getFirstChild.getData);

% get parameters for each transducer freq
for(jj=1:Parameters.NumFreq)
    Parameters.DigRate(jj) = str2double(xDoc.getElementsByTagName('DigRate').item(jj-1).getFirstChild.getData);
    Parameters.LockOutIndex(jj) = str2double(xDoc.getElementsByTagName('LockOutIndex').item(jj-1).getFirstChild.getData);
    Parameters.Gain(jj) = str2double(xDoc.getElementsByTagName('Gain').item(jj-1).getFirstChild.getData);
    Parameters.PulseLen(jj) = str2double(xDoc.getElementsByTagName('PulseLen').item(jj-1).getFirstChild.getData);
    Parameters.DS(jj) = str2double(xDoc.getElementsByTagName('DS').item(jj-1).getFirstChild.getData);
    Parameters.EL(jj) = str2double(xDoc.getElementsByTagName('EL').item(jj-1).getFirstChild.getData);
    Parameters.TVR(jj) = str2double(xDoc.getElementsByTagName('TVR').item(jj-1).getFirstChild.getData);
    Parameters.VTX(jj) = str2double(xDoc.getElementsByTagName('VTX0').item(jj-1).getFirstChild.getData);
    Parameters.BP(jj) = str2double(xDoc.getElementsByTagName('BP').item(jj-1).getFirstChild.getData);
end

Parameters.SensorsFlag = str2double(xDoc.getElementsByTagName('SensorsFlag').item(0).getFirstChild.getData);