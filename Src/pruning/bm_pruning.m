function [] = bm_pruning(Y,X,I_max,SEED,T_EM_EG,ks_irrelevant)
N = size(X,1);% Number of data points
K = size(X,2);% Dimension of parameter vector
V = 0.2;

%B00 = ones(K,1)./K;
B00 = X\Y;
P00 = 0.5.*ones(K,1);
%lambda00 = 1./V./10;
lambda00 = 1./var(Y);
Mu00 = 0.5.*ones(N,K);
B0 = B00;
P0 = P00;
lambda0 = lambda00;
Mu0 = Mu00;
iterations = 50;% iteration number for each run between model prunings
mode_Estep = 1;% 1: trial-dependent latent variable, 2: trial-independent
mode_Mstep = 1;% 1: FAB EM, 2: Steepest descvisent, 3: Maeda's descent
alpha = 0.02./N;
tolerance = eps;% machine epsilon pre-defined in MATLAB
flag_est_lambda = 1;

ks_pruned = zeros(K,1);
ks_pruned_t = zeros(K,iterations*K);
k_to_k_map = (1:K)';
Bt_total = zeros(K,iterations*K);
Lt_total = zeros(1,iterations*K);
Pt_total = zeros(K,iterations*K);

T_counter = 0;% counter of toal iteration number;
%T_EM_EG = 200*1000;% Iteration number for transition from FAB-EM to FAB-EG.
flag_EM_EG = 0;
T_counter_t = zeros(K,1);

%I_max = K*4;% Number of executing fab_regr_1d_v2
calc_time = zeros(I_max,1);
rec_n_pruned_total = zeros(I_max,1);
rec_n_pruned_correct = zeros(I_max,1);

display(T_EM_EG);
display(SEED);
display(N);

%display(ks_pruned)
%display(ks_irrelevant)

tic
for I = 1:I_max
    %display(mode_Mstep)
    iterations2 = iterations;
    if flag_EM_EG == 1 && mode_Mstep == 1
        mode_Mstep = 3;
        display('transition to FAB-EG...');
    elseif (T_counter + iterations > T_EM_EG) && flag_EM_EG == 0
        display('last FAB-EM run...')
        iterations2 = T_EM_EG - T_counter;
        flag_EM_EG = 1;
    end
    [B0,lambda0,P0,Bt,Lt,Pt,Mu0,I_termination,flag_pruned,FIC] = fab_regr_1d_v2(Y,X,B0,lambda0,P0,Mu0,tolerance,iterations2,mode_Estep,mode_Mstep,alpha,flag_est_lambda);
    n_pruned = sum(flag_pruned);
    % preserving results
    range = (T_counter+1):(T_counter+I_termination);
    for k = 1:length(B0)
        Bt_total(k_to_k_map(k),range) = Bt(k,1:I_termination);
        Pt_total(k_to_k_map(k),range) = Pt(k,1:I_termination);
    end
    Lt_total(range) = Lt(1:I_termination);
    % pruning
    %display(n_pruned)
    %display(lambda0)
    %display(B0)
    %display(P0)
    for n = 1:n_pruned
        for k = 1:K
            if flag_pruned(k) == 1
                ks_pruned(k_to_k_map(k)) = 1;
                B0(k) = [];
                P0(k) = [];
                X(:,k) = [];
                Mu0(:,k) = [];
                k_to_k_map(k) = [];
                break;
            end
        end
    end
    ks_pruned_t(:,range) = repmat(ks_pruned,[1,I_termination]);
    %
    T_counter = T_counter + I_termination;
    T_counter_t(I) = T_counter;
    %
    calc_time(I) = toc;
    rec_n_pruned_total(I) = sum(ks_pruned);
    rec_n_pruned_correct(I) = sum(ks_pruned(ks_irrelevant));
end
%display(ks_irrelevant);
%display(ks_pruned);
n_pruned_total = sum(ks_pruned)
n_pruned_correct = sum(ks_pruned(ks_irrelevant))
n_irrelevant = K./2;
recall = n_pruned_correct./n_irrelevant
precision = n_pruned_correct./n_pruned_total
display(T_counter);

%display(B0)
%display(P0)
%display(lambda0)
%display([Bt_total(:,T_counter).*Pt_total(:,T_counter) B])
%display(I_termination)
%display(FIC)
Bt_total = [B00 Bt_total];
Pt_total = [P00 Pt_total];
Lt_total = [lambda00 Lt_total];
toc
dname = sprintf('result_BM_K%d',K);
mkdir(dname)
%vis;
fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,SEED,T_EM_EG,N);
save(fname,'X','B0','ks_pruned','ks_irrelevant','calc_time','rec_n_pruned_total','rec_n_pruned_correct','I_max','T_EM_EG');
end