N_SEED = 100;
SEEDinit = 1;
T_EM_EGs = [500];%[200; 2000000];
K = 100;
N_data = K*20;
dname1 = sprintf('data_K%d',K);
dname2 = sprintf('est_K%d',K);
dname3 = sprintf('result_BM_K%d',K);
if(0)% convert data (Y,X00) into csv file for Lasso
    for n = SEEDinit:(SEEDinit + N_SEED - 1)
        matfilename = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname1,n,T_EM_EGs(1),N_data);
        load(matfilename);
        
        csvfilename1 = sprintf('%s/Data_X_N%d_SEED%d_.csv',dname1,N_data,n);
        csvfilename2 = sprintf('%s/Data_Y_N%d_SEED%d_.csv',dname1,N_data,n);
        csvwrite(csvfilename1,X00);
        csvwrite(csvfilename2,Y);
    end
end

if(0)% process Lasso results and calculate F-measure
   display('Processing Lasso results...');
   rec_ks_pruned_Lasso = zeros(K,N_SEED);
   recall_Lasso = zeros(N_SEED,1);
   prec_Lasso = zeros(N_SEED,1);
   for n = 1:N_SEED
       matfilename = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname1,n+SEEDinit-1,T_EM_EGs(1),N_data);
       load(matfilename);
       matfilename = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname1,n+SEEDinit-1,T_EM_EGs(1),N_data);
       load(matfilename);
       fname = sprintf('%s/B_Lasso_N%d_SEED%d.txt',dname2,N_data,n+SEEDinit-1);
       p = importdata(fname);
       ks_pruned_Lasso = zeros(K,1);
       ks_pruned_Lasso(p(:) == 0) = 1;
       rec_ks_pruned_Lasso(:,n) = ks_pruned_Lasso;
       recall_Lasso(n) = sum(ks_pruned_Lasso(ks_irrelevant))./(length(ks_irrelevant));
       prec_Lasso(n) = sum(ks_pruned_Lasso(ks_irrelevant))./sum(ks_pruned_Lasso);
   end
   f_measure_Lasso = 2.*recall_Lasso.*prec_Lasso./(recall_Lasso + prec_Lasso);
   f_measure_Lasso(isnan(f_measure_Lasso)) = 0;
   display(f_measure_Lasso);
   fname = sprintf('LASSOresult_K%d_N%d.mat',K,N_data);
   save(fname,'rec_ks_pruned_Lasso','recall_Lasso','prec_Lasso','f_measure_Lasso');
end

if(0)% ARD estimation and calculate F-measure
    display('ARD regression...');
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
    end
    f_measure_ARD = 2.*recall_ARD.*prec_ARD./(recall_ARD + prec_ARD);
    fname = sprintf('ARDresult_K%d_N%d.mat',K,N_data);
    save(fname,'rec_ks_pruned_ARD','recall_ARD','prec_ARD','f_measure_ARD');
end


if(1)% processing FAB estimation and calculate F-measure
    display('Processing results from BM...');
    recall_BM = zeros(N_SEED,2);
    prec_BM = zeros(N_SEED,2);
    for ns = 1:N_SEED
        for n = 1:length(T_EM_EGs)
            %matfilename = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname3,ns+SEEDinit-1,T_EM_EGs(n),N_data);
            %load(matfilename);
            matfilename = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname3,ns+SEEDinit-1,T_EM_EGs(n),N_data);
            load(matfilename);
            recall_BM(ns,n) = rec_n_pruned_correct(I_max)./length(ks_irrelevant);
            prec_BM(ns,n) = rec_n_pruned_correct(I_max)./rec_n_pruned_total(I_max);
        end
    end
    f_measure_BM = 2.*recall_BM.*prec_BM./(recall_BM + prec_BM);
    fname = sprintf('BMresult_K%d_N%d.mat',K,N_data);
    save(fname,'recall_BM','prec_BM','f_measure_BM');
end

if(0)% plot elapsed times
    I_max = 200;
    elapsed_times = zeros(I_max,N_SEED,2);
    recalls = zeros(I_max,N_SEED,2);
    mistakes = zeros(I_max,N_SEED,2);
    for ns = 1:N_SEED
        for n = 1:2
            matfilename = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname1,ns+SEEDinit-1,T_EM_EGs(n),N_data);
            load(matfilename);
            elapsed_times(:,ns,n) = calc_time;
            recalls(:,ns,n) = rec_n_pruned_correct;
            mistakes(:,ns,n) = rec_n_pruned_total - rec_n_pruned_correct;
        end
    end
    %%%%%%%%%
    figure(1);
    set(gca,'FontName','Helvetica','FontSize',20);
    plot(elapsed_times(:,1,1),recalls(:,1,1),'r-o','LineWidth',1);
    hold on
    plot(elapsed_times(:,1,2),recalls(:,1,2),'b-o','LineWidth',1);
    legend('Hybrid FAB-EM-EG','FAB-EM');
    %plot(elapsed_times(:,1,1),mistakes(:,1,1),'m-s','LineWidth',1);
    %plot(elapsed_times(:,1,2),mistakes(:,1,2),'c-s','LineWidth',1);
    for ns = 2:N_SEED
        plot(elapsed_times(:,ns,1),recalls(:,ns,1),'r-o','LineWidth',1);
        plot(elapsed_times(:,ns,2),recalls(:,ns,2),'b-o','LineWidth',1);
        %plot(elapsed_times(:,ns,1),mistakes(:,ns,1),'m-s','LineWidth',1);
        %plot(elapsed_times(:,ns,2),mistakes(:,ns,2),'c-s','LineWidth',1);
    end
    hold off
    xlabel('Elapsed time (sec)');
    ylabel('Number of model pruning');
    xlim([-1,120]);
    ylim([-0.5,25.5]);
    figname = sprintf('elapsed_times.eps');
    saveas(figure(1),figname,'epsc2');
    
    figure(2);
    set(gca,'FontName','Helvetica','FontSize',20);
    data = [mistakes(I_max,:,2)' mistakes(I_max,:,1)'];
    bin = 0:6;
    hist(data,bin);
    xlabel('Number of wrong prunings');
    ylabel('Frequency');
    xlim([-0.5,6.5]);
    legend('FAB-EM','Hybrid FAB-EM-EG');
    figname = sprintf('histgram_wrong.eps');
    saveas(figure(2),figname,'epsc2');
    
end