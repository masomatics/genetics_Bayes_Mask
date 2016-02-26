clear all
close all

if(1)
    K = 10;
    N = K.*20;
    I_max = K*20;
    for randseed = 1:100
        SEED = randseed;
        dname = sprintf('../test_pruning/data_K%d',K);
        fname = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        T_EM_EG = 500;
        bm_pruning(Y,X00,I_max,SEED,T_EM_EG,ks_irrelevant);
        
    end
end

if(1)
    K = 30;
    N = K.*20;
    I_max = K*20;
    for randseed = 51:150
        SEED = randseed;
        dname = sprintf('../test_pruning/data_K%d',K);
        fname = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        T_EM_EG = 500;
        bm_pruning(Y,X00,I_max,SEED,T_EM_EG,ks_irrelevant);
        
    end
end

if(1)
    K = 50;
    N = K.*20;
    I_max = K*15;
    for randseed = 1:100
        SEED = randseed;
        dname = sprintf('../test_pruning/data_K%d',K);
        fname = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        T_EM_EG = 500;
        bm_pruning(Y,X00,I_max,SEED,T_EM_EG,ks_irrelevant);
        
    end
end

if(1)
    K = 100;
    N = K.*20;
    I_max = K*10;
    for randseed = 1:100
        SEED = randseed;
        dname = sprintf('../test_pruning/data_K%d',K);
        fname = sprintf('%s/data_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        fname = sprintf('%s/result_SEED%d_TEMEG%d_N%d.mat',dname,SEED,500,N);
        load(fname);
        T_EM_EG = 500;
        bm_pruning(Y,X00,I_max,SEED,T_EM_EG,ks_irrelevant);
        
    end
end