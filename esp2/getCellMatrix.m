function mat = getCellMatrix(regCellInt, horzSlice, vertSlice)
% convert RegCellOutput to 3D matrix. 1 dim is no of
% horzslices, 2 dim is no of vertslices and 3rd are 12 different
% variables as described below.

mat = zeros(size(regCellInt.Sv_mean,1),size(regCellInt.Sv_mean,2),12);
regCellInt.Layer = regCellInt.Layer+(abs(min(regCellInt.Layer(:)))+1);

mat(:,:,1) = regCellInt.Interval;            % Interval
mat(:,:,2) = regCellInt.Sv_mean;             % Sv_mean
mat(:,:,3) = 10.^(regCellInt.Sv_mean/10);     % Sv_mean Linear
mat(:,:,4) = regCellInt.ABC;                 % ABC
mat(:,:,5) = regCellInt.Ping_S;              % Ping_S
mat(:,:,6) = regCellInt.Ping_E;              % Ping_E
mat(:,:,7) = regCellInt.Thickness_mean;      % Thickness_mean
mat(:,:,8) = regCellInt.Lat_S;               % Lat_Start
mat(:,:,9) = regCellInt.Lon_S;               % Lon_Start
mat(:,:,10) = regCellInt.Layer_depth_min;    % Cell top border
mat(:,:,11) = regCellInt. Layer_depth_max;   % Cell lower border
mat(:,:,13) = 10.^(regCellInt.Sa/10); 
mat(:,:,14) = regCellInt.Nb_good_pings; 


for m = 1:size(regCellInt.Sv_mean,1)
    for n = 1:size(regCellInt.Sv_mean,2)        
        mat(m,n,12) = 1/2*((length(regCellInt.Ping_S(m,n):regCellInt.Ping_E(m,n))/vertSlice)+(regCellInt.Thickness_mean(m,n)/horzSlice));   % Contribution of regionCell to FullCell
    end
end

end