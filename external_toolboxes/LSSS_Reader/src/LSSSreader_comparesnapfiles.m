function status=LSSSreader_comparesnapfiles(region1,region2)
%
% this function takes the output structure from LSSSreader_readsnapfiles
% and compares the content of the two files.
%
% inout :
% region1 : Output from LSSSreader_readsnapfiles
% region2 : Output from LSSSreader_readsnapfiles
%
% Output
% status : Status of the comparison
% status = 1 : No changes detected
% status = 2 : Different number of polygons
% status = 3 : Different areas in at least one polygon (relative difference > 1e-3)
% status = 4 : Different number of polygons AND Different areas in at least one polygon
%

tol = 1e-3;

status.comment = 'OK';
status.statustype = 0;
    
% Loop over structures
if length(region1)~=length(region2)
    status.comment = 'Different number of polygons';
    status.statustype = 1;
else
    A1= NaN(1,length(region1));
    A2= NaN(1,length(region1));
    for i=1:length(region1)
        % Sum the volume of all regions in the files
        A1(i)=polyarea(region1(i).x,region1(i).y);
        A2(i)=polyarea(region2(i).x,region2(i).y);
    end
    A1_sum = sum(A1);
    A2_sum = sum(A2);
    
    if (A1_sum-A2_sum)/A1_sum>tol
        status.comment = 'Different area of polygons';
        status.statustype = 2;
    end
end

