function [n_eval,delta,alpha,phi_est]=est_phicross_mat(n,amp,phase,phi_fix)

[nb_samples,nb_pings]=size(n);
alpha=nansum(amp.*(n-repmat(nanmean(n),nb_samples,1)).*(phase-repmat(nanmean(phase),nb_samples,1)))./nansum(amp.*(n-repmat(nanmean(n),nb_samples,1)).^2);
beta=repmat(nanmean(phase),nb_samples,1)-repmat(alpha,nb_samples,1).*repmat(nanmean(n),nb_samples,1);

phi_est=repmat(alpha,nb_samples,1).*n+beta;
delta=sqrt(nanmean((phi_est-phase).^2));
n_eval=abs((phi_fix-beta)./repmat(alpha,nb_samples,1));