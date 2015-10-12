 function matSubSet = getCellMatrixSubSet( mat, reg, j, refType)
            % returns a subset of the Cellmatrix according to the
            % specifications (bounds) in the reg file. All slices that dont
            % fall entirely within these bounds are replaced with NaNs.
            
            if refType == 'b'
                for i = 1:size(mat,2)
                    startBorder = max(mat(:,i,11))-reg.startDepth(j);
                    finishBorder = max(mat(:,i,11))-reg.finishDepth(j);
                    if ~isnan(reg.startDepth(j));
                        sd(i) = mat(:,i,10) <= startBorder;
                    else
                        sd = ones(size(mat(:,:,10)));
                    end
                    if ~isnan(reg.finishDepth(j));
                        fd(:,i) = mat(:,i,11) >= finishBorder;
                    else
                        fd = ones(size(mat(:,:,11)));
                    end
                end
            else
                if ~isnan(reg.startDepth(j));
                    sd = mat(:,:,10) >= reg.startDepth(j);
                else
                    sd = ones(size(mat(:,:,10)));
                end
                if ~isnan(reg.finishDepth(j));
                    fd = mat(:,:,11) <= reg.finishDepth(j);
                else
                    fd = ones(size(mat(:,:,11)));
                end
            end
            
            if ~isnan(reg.startSlice(j));
                ss = mat(:,:,1) >= reg.startSlice(j);
            else
                ss = ones(size(mat(:,:,1)));
            end
            if ~isnan(reg.finishSlice(j));
                fs = mat(:,:,1) <= reg.finishSlice(j);
            else
                fs = ones(size(mat(:,:,1)));
            end
            
            ix = sd == 1 & fd == 1 & ss == 1 & fs == 1;
            matSubSet = [];
            for i = 1:size(mat,3)
                tmp = mat(:,:,i);
                tmp(ix==0) = NaN;
                matSubSet = cat(3, matSubSet, tmp);
            end
        end