clear all
close all

N_SEED = 100;
SEEDinit = 1;
K = 50;
N = K*20;

ge_BM = zeros(N_SEED,N_SEED);
ge_Lasso = zeros(N_SEED,N_SEED);
ge_ARD = zeros(N_SEED,N_SEED);

% compute RMSE in generalization
for s1 = 1:N_SEED
    display(s1)
    % read weight vectors (and relevance vector for BM and ARD)
    % BM
    dname = sprintf('result_BM_K%d',K);
    fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,s1,500,N);
    load(fname);
    B_BM = B0;
    flag_pruned = ks_pruned;
    % Lasso
    dname = sprintf('../test_pruning/est_K%d',K);
    fname = sprintf('%s/B_Lasso_N%d_SEED%d.txt',dname,N,s1+SEEDinit-1);
    B_Lasso = importdata(fname);
    % ARD
    dname = sprintf('est_ARD_K%d',K);
    fname = sprintf('%s/ARD_params_SEED%d_TEMEG%d_N%d.mat',dname,s1+SEEDinit-1,500,N);
    load(fname);
    B_ARD = p;
    for s2 = 1:N_SEED
        % read target vector Y and input matrix X00
        dname = sprintf('../test_pruning/data_K%d',K);
        fname = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname,s2,500,N);
        load(fname);
        fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,s2,500,N);
        load(fname);
        % BM
        idx_relevant = find(flag_pruned(:) == 0);
        X = X00(:,idx_relevant);
        ge_BM(s1,s2) = norm(Y-X*B_BM)./sqrt(N);
        % Lasso
        ge_Lasso(s1,s2) = norm(Y-X00*B_Lasso)./sqrt(N);
        % ARD
        X = X00(:,B_ARD.Relevant);
        ge_ARD(s1,s2) = norm(Y-X*B_ARD.Value)./sqrt(N);
    end
end

% convert the results into vectors
E = eye(size(ge_BM,1));
rmse_BM = ge_BM(E(:) == 0);
rmse_Lasso = ge_Lasso(E(:) == 0);
rmse_ARD = ge_ARD(E(:) == 0);

% visualization
med_ARD = median(rmse_ARD(:));
figure(1)
set(gca,'FontName','Helvetica','FontSize',20);
plot([0.5 3.5],med_ARD.*[1 1],'g','LineWidth',2)
hold on
boxplot([rmse_BM, rmse_Lasso, rmse_ARD]);
hold off
xlabel('Method');
ylabel('RMSE');
xlim([0.5 3.5]);
%ylim([0.9,1.1]);
set(gca,'XTickLabel',{'BM';'Lasso';'ARD'},'XTick',1:3);
pbaspect([1,1,1])
fname = sprintf('Generalization_error_RMSE_K%d.eps',K);
saveas(figure(1),fname,'epsc2');

save('generalization_errors.mat','rmse_BM','rmse_Lasso','rmse_ARD');
