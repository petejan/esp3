function idx_ringdown=analyse_ringdown(RingDown)
global DEBUG;

nb_pings=max(size(RingDown));
win=min(75,nb_pings);
bin=min(11,round(nb_pings/5));
spc=1;

if size(RingDown,1)>1&&size(RingDown,2)>1
    RingDownMean=20*log10(nanmean(10.^(RingDown/20)));
else
    RingDownMean=RingDown;
end
Ring_down_thr=2*nanstd(RingDown);


[pdf_RD,x_RD]=pdf_perso(RingDownMean,'bin',2*bin);
[~,idx_max]=nanmax(pdf_RD);
idx_ringdown_1=abs(RingDownMean-x_RD(idx_max))<=(Ring_down_thr+Ring_down_thr*5);
RingDownMean(~idx_ringdown_1)=nan;
RingDown(~idx_ringdown_1,:)=nan;
Ring_down_thr=2*nanstd(RingDown);
if Ring_down_thr==0
    idx_ringdown=ones(size(RingDownMean));
    return;
end;

[s_pdf,x_value,y_value,~]= sliding_pdf((1:nb_pings),RingDownMean,win,bin,spc,1);

% shading interp

%[~,idx_max]=nanmax(s_pdf);
%idx_high_p=s_pdf<=(0.1*repmat(s_pdf(idx_max+(bin*(0:nb_pings-1))),size(s_pdf,1),1));
%y_value(idx_high_p)=nan;

[s_pdf_sorted,idx_sort]=sort(s_pdf,1,'descend');
idx_sort=idx_sort+ones(bin,1)*(0:size(idx_sort,2)-1)*bin;
y_value_sorted=y_value(idx_sort);


% figure();
% pcolor(x_value(idx_sort),y_value(idx_sort),s_pdf_sorted);
% shading interp

RingDownMPV=nanmean(y_value_sorted(1:3,:));
idx_ringdown=(abs(RingDownMean-RingDownMPV)<Ring_down_thr)&idx_ringdown_1;


if DEBUG
    figure();
    plot(RingDownMean,'linewidth',2);
    hold on;
    plot(RingDownMPV,'-r','linewidth',2);
    plot(RingDownMPV-Ring_down_thr,'--r','linewidth',2);
    plot(RingDownMPV+Ring_down_thr,'--r','linewidth',2);
    grid on;
    set(gca,'fontsize',16);
    xlabel('Ping number');
    ylabel('Sv (dB)');
    grid on;
    title('Ring Down Zone')
    pause;
    close gcf;
    
end


end