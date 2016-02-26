clear all
close all

N_SEED = 100;
SEEDinit = 1;
T_EM_EGs = [500];%[200; 2000000];
K = 100;
N_data = K*20;
dname1 = sprintf('../test_pruning/data_K%d',K);

RMSEs_ARD = zeros(N_SEED,1);

% Settings of ARD
%OPTIONS = SB2_UserOptions('fixedNoise',1,'DiagnosticLevel',0);
%SETTINGS = SB2_ParameterSettings('Beta',1./V);

% ARD implemented by Tipping
rec_ks_pruned_ARD = zeros(K,N_SEED);
recall_ARD = zeros(N_SEED,1);
prec_ARD = zeros(N_SEED,1);
for n = 1:N_SEED
    matfilename = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname1,n+SEEDinit-1,T_EM_EGs(1),N_data);
    load(matfilename);
    matfilename = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname1,n+SEEDinit-1,T_EM_EGs(1),N_data);
    load(matfilename);
    [p, hp, d] = SparseBayes('Gaussian', X00, Y);
    ks_pruned_ARD = ones(K,1);
    ks_pruned_ARD(p.Relevant) = 0;
    rec_ks_pruned_ARD(:,n) = ks_pruned_ARD;
    
    recall_ARD(n) = sum(ks_pruned_ARD(ks_irrelevant))./(length(ks_irrelevant));
    prec_ARD(n) = sum(ks_pruned_ARD(ks_irrelevant))./sum(ks_pruned_ARD);
    
    display(p.Relevant)
    dname = sprintf('est_ARD_K%d',K);
    mkdir(dname);
    X = X00(:,p.Relevant);
    rmse = norm(Y-X*p.Value)./sqrt(N_data);
    fname = sprintf('%s/ARD_params_SEED%d_TEMEG%d_N%d.mat',dname,n+SEEDinit-1,T_EM_EGs(1),N_data);
    save(fname,'p','hp','d','rmse');
    RMSEs_ARD(n) = rmse;
end
f_measure_ARD = 2.*recall_ARD.*prec_ARD./(recall_ARD + prec_ARD);
fname = sprintf('metrics_ARD_K%d_N%d.mat',K,N_data);
save(fname,'rec_ks_pruned_ARD','recall_ARD','prec_ARD','f_measure_ARD','RMSEs_ARD');