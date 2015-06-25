
script = 'JO20130212120719'; %This the the CVS name for the MBS script that ESP2 processes
input=readMbsScript(script);
[regions,bottom,bad,rawFileName]=convertBRfromMbs(input,1);


filename=fullfile('X:\','tan0301',rawFileName{1});
