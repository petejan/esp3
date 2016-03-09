function [s_pdf,x_value,y_value,nb_pings_in_pdf]= sliding_pdf(x_data,y_data,win,bins,spc,gauss_win)

if length(bins)==1
    nb_pings=ceil(max(size(x_data))/spc);
    s_pdf=nan(bins,nb_pings);
    x_value=nan(bins,nb_pings);
    y_value=nan(bins,nb_pings);
    nb_pings_in_pdf=nan(1,nb_pings);
else
    nb_pings=ceil(max(size(x_data))/spc);
    s_pdf=nan(length(bins),nb_pings);
    x_value=nan(length(bins),nb_pings);
    y_value=nan(length(bins),nb_pings);
    nb_pings_in_pdf=nan(1,nb_pings);
end
 %h = waitbar(0,sprintf('Ping %i/%i',1,nb_pings),'Name','Sliding Pdf Processing');

for i=1:nb_pings
    idx_num=(abs(double(x_data)-double(x_data(1+(i-1)*spc)))<(win+1)/2);
    
    %     figure(1)
    %     plot(abs(double(x_data)-double(x_data(i))))
    %     drawnow;
    %     grid on;
    if min(size(y_data))>1
        y_data_temp=y_data(:,idx_num);
        if gauss_win
            weight_idx=repmat(exp(-(double(x_data(idx_num)-double(x_data(1+(i-1)*spc)))).^2/(2*(win/4)^2)),size(y_data,1),1);
        else
            weight_idx=ones(size(y_data));
        end
    else
        y_data_temp=y_data(idx_num);
        if gauss_win
            weight_idx=exp(-(double(x_data(idx_num)-double(x_data(1+(i-1)*spc)))).^2/(2*(win/4)^2));
        else
            weight_idx=ones(size(y_data));
        end
    end
    nb_pings_in_pdf(i)=length(y_data_temp(~isnan(y_data_temp)));
    [s_pdf_temp,y_value_temp]=pdf_perso(y_data_temp,'bin',bins,'weight',weight_idx,'win_type','gauss');
       
    s_pdf(:,i)=s_pdf_temp';
    y_value(:,i)=y_value_temp';
    x_value(:,i)=x_data(1+(i-1)*spc);
    %waitbar(i/nb_pings,h,sprintf('Ping %i/%i',i,nb_pings))
end
%close(h);
end

