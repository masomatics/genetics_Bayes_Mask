N_SEED = 100;
Ks = [10,30,50,100];
N_Ks = length(Ks);
Methods = {'BM','Lasso','ARD'};
N_M = length(Methods);
scores_BM = zeros(N_SEED,N_Ks,3);%(seed,K,scores(Recall,Precision,F))
scores_Lasso = zeros(N_SEED,N_Ks,3);
scores_ARD = zeros(N_SEED,N_Ks,3);

% read data
for nk = 1:N_Ks
    N_data = Ks(nk) * 20;
    %%% BM
    matfilename = sprintf('BMresult_K%d_N%d.mat',Ks(nk),N_data);
    load(matfilename);
    scores_BM(:,nk,1) = recall_BM(:,1);
    scores_BM(:,nk,2) = prec_BM(:,1);
    scores_BM(:,nk,3) = f_measure_BM(:,1);
    
    %%% Lasso
    matfilename = sprintf('../test_pruning/LASSOresult_K%d_N%d.mat',Ks(nk),N_data);
    load(matfilename);
    scores_Lasso(:,nk,1) = recall_Lasso(:,1);
    scores_Lasso(:,nk,2) = prec_Lasso(:,1);
    scores_Lasso(:,nk,3) = f_measure_Lasso(:,1);
    
    %%% ARD
    matfilename = sprintf('../test_pruning/ARDresult_K%d_N%d.mat',Ks(nk),N_data);
    load(matfilename);
    scores_ARD(:,nk,1) = recall_ARD(:,1);
    scores_ARD(:,nk,2) = prec_ARD(:,1);
    scores_ARD(:,nk,3) = f_measure_ARD(:,1);
end

scores_Lasso(isnan(scores_Lasso(:)) == 1) = 0;

mean_BM = squeeze(mean(scores_BM,1));
mean_Lasso = squeeze(mean(scores_Lasso,1));
mean_ARD = squeeze(mean(scores_ARD,1));

% the values below is SE, not SD.
std_BM = squeeze(std(scores_BM,1,1))./sqrt(N_SEED);
std_Lasso = squeeze(std(scores_Lasso,1,1))./sqrt(N_SEED);
std_ARD = squeeze(std(scores_ARD,1,1))./sqrt(N_SEED);

display(size(mean_BM))
display(size(std_BM))

% make figure
Ks_dummy = [10 30 50 70];% to make the equal intervals in the x-axis

figure(1);
set(gca,'FontName','Helvetica','FontSize',20);
hFig = errorbar(Ks_dummy,mean_BM(:,1),std_BM(:,1),'ro','LineWidth',1,'MarkerSize',10);
hold on
errorbar(Ks_dummy,mean_Lasso(:,1),std_Lasso(:,1),'bo','LineWidth',1,'MarkerSize',10);
errorbar(Ks_dummy,mean_ARD(:,1),std_ARD(:,1),'go','LineWidth',1,'MarkerSize',10);
errorbar(Ks_dummy,1 - mean_BM(:,2),std_BM(:,2),'rs','LineWidth',1,'MarkerSize',10);
errorbar(Ks_dummy,1 - mean_Lasso(:,2),std_Lasso(:,2),'bs','LineWidth',1,'MarkerSize',10);
errorbar(Ks_dummy,1 - mean_ARD(:,2),std_ARD(:,2),'gs','LineWidth',1,'MarkerSize',10);
hold off
set(hFig,'MarkerSize',10);
xlabel('K');
ylabel('Recall');
xlim([Ks_dummy(1)-5,Ks_dummy(end)+5]);
ylim([-0.1,1.1]);
%set(gca,'xscale','log');
saveas(figure(1),'recall_and_error.eps','epsc2');

figure(2);
set(gca,'FontName','Helvetica','FontSize',20);
errorbar(Ks_dummy,mean_BM(:,3),std_BM(:,3),'ro','LineWidth',1,'MarkerSize',12);
hold on
errorbar(Ks_dummy,mean_Lasso(:,3),std_Lasso(:,3),'bs','LineWidth',1,'MarkerSize',15);
errorbar(Ks_dummy,mean_ARD(:,3),std_ARD(:,3),'gd','LineWidth',1,'MarkerSize',15);
hold off
xlabel('K');
ylabel('F score');
xlim([Ks_dummy(1)-5,Ks_dummy(end)+5]);
ylim([0.5,1.0]);
set(gca,'xtick',Ks_dummy);
pbaspect([0.67 1 1]);
saveas(figure(2),'f1_score.eps','epsc2');

figure(3);
set(gca,'FontName','Helvetica','FontSize',20);
errorbar(Ks_dummy,mean_BM(:,2),std_BM(:,2),'ro','LineWidth',1,'MarkerSize',12);
hold on
errorbar(Ks_dummy,mean_Lasso(:,2),std_Lasso(:,2),'bs','LineWidth',1,'MarkerSize',15);
errorbar(Ks_dummy,mean_ARD(:,2),std_ARD(:,2),'gd','LineWidth',1,'MarkerSize',15);
hold off
xlabel('K');
ylabel('Precision');
xlim([Ks_dummy(1)-5,Ks_dummy(end)+5]);
ylim([0.5,1.0]);
set(gca,'xtick',Ks_dummy);
pbaspect([0.67 1 1]);
saveas(figure(3),'prec.eps','epsc2');

figure(4);
set(gca,'FontName','Helvetica','FontSize',20);
errorbar(Ks_dummy,mean_BM(:,1),std_BM(:,1),'ro','LineWidth',1,'MarkerSize',12);
hold on
errorbar(Ks_dummy,mean_Lasso(:,1),std_Lasso(:,1),'bs','LineWidth',1,'MarkerSize',15);
errorbar(Ks_dummy,mean_ARD(:,1),std_ARD(:,1),'gd','LineWidth',1,'MarkerSize',15);
hold off
xlabel('K');
ylabel('Recall');
xlim([Ks_dummy(1)-5,Ks_dummy(end)+5]);
ylim([0.5,1.0]);
set(gca,'xtick',Ks_dummy);
pbaspect([0.67 1 1]);
saveas(figure(4),'recall.eps','epsc2');


