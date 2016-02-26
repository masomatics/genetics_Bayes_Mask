% FAB for 1D target
function [B,lambda,P,Bt,lambdat,Pt,Mu,I_termination,flag_pruned,FIC] = fab_regr_1d_v2(Y,X,B0,lambda0,P0,Mu0,delta,iterations,mode_Estep, mode_Mstep,learning_coeff,flag_est_lambda)
%version 2 replace sum_n by matrix multiplication.
%Also mode_Estep 2 and 3 are implemented.
%Also takes learning_coeff as an input value
%Also takes flag which determine if lambda (noise precision) is estimated.
%Also input and output the posterior of Z

%****Input variables******
%Y: N column vector of target values
%X: NxK Explanatory variables
%B0: K column vector of initial values of coefficients
%lambda0: A scalar value of initial precision
%P0: K column vector of initial values of Bernoulli p
%delta: tolerance of P for model pruning
%iteretions: Max Number of iterations
%mode_Estep = 1: trial-dependent Z, 2: trial-independent Z
%mode_Mstep = 1: EM algorithm, 2: Steepest descent on (b,p), 3: Steepest descent on (b, s (= b*p))
%learning_coeff: learning coefficient in gradient methods.
%flag_est_lambda = 0: lambda fixed, 1: lambda to be estimated

%****Output variables****
%I_termination: Interation number at termination of optimization
%FIC: Evaluated FIC value (not implemented yet)
%B,lambda,P: Estimated parameter values
%(Note that update of lambda is not yet implemented)

% Initialization
N = size(X,1);% Number of data points
K = size(X,2);% Dimension of parameter vector

B = B0;
lambda = lambda0;
P = P0;
Mu = Mu0;
%Mu = 0.5.*ones(N,K);% Mu: NxK matrix for Bernoulli mean of Z
N_iteration = iterations;
I_termination = iterations;% # of Iteration when model pruning happend
Bt = zeros(K,N_iteration);% Learning trajectory of B
Pt = zeros(K,N_iteration);% Learning trajectory of P
lambdat = zeros(1,N_iteration);% Learning trajectory of lambda
flag_pruned = zeros(K,1);
% start FAB inference
%tic
eps = 0.00001;
for I = 1:N_iteration
    %display(I)
    %display('E step...')
    %toc
    %%%%%%%%%%E-step%%%%%%%%%%
    for I2 = 1:5% update of Mu requires several iterations of the fixed-point equation. 10 and 100 make no difference
        if mode_Estep == 1
            for k = 1:K
                temp = Y - 0.5.*B(k).*X(:,k);
                for k2 = 1:K
                   if k2 ~= k
                      temp = temp - B(k2).*(Mu(:,k2).*X(:,k2)); 
                   end
                end
                c = lambda.*B(k).*X(:,k).*temp;
                E = c + (log((P(k))/(1-P(k) + eps)) - 1./(2*(P(k))*N)).*ones(N,1);% without eps, P(k) = 1 is frozen
                Mu(:,k) = 1./(1 + exp(-E));% The update is not synchronous for different ks
            end
        elseif mode_Estep == 2
            display('mode_Estep=2 has not been implemented yet!!(Actually we do not have to.)');
        end
    end
    %display(Mu)
    %%%%%%%%Model pruning%%%%%%%%%%
    for k = 1:K%
        if sum(Mu(:,k)) <= N*delta
            P(k) = 0;
            flag_pruned(k) = 1;
        end
    end
    if sum(flag_pruned(:)) > 0
        display('Dimension reduction...');
        I_termination = I;
        Bt(:,I) = B;
        lambdat(I) = lambda;
        Pt(:,I) = P;
        break;
    end
    %%%%%%%%%M or G step%%%%%%%%%%%%
    XM = (X .* Mu);
    F = XM'*XM + ((XM'*(X - XM)).* eye(K));
    if mode_Mstep == 1 % EM algorithm
        % Update of B
        %F = zeros(K,K);
        %for n = 1:N
        %    F = F + (X(n,:)'*X(n,:)).*(Mu(n,:)'*Mu(n,:) + diag(Mu(n,:) - Mu(n,:).*Mu(n,:))); 
        %end
        b = XM' * Y;
        B = linsolve(F,b);
        % Update of P
        P = sum(Mu,1)'./N;
    else % Gradient method
        XM = (X .* Mu);
        GB = XM'*Y - F*B;% Gradient of B
        GB = lambda.*GB;
        SumMu = sum(Mu,1)';
        Denom_GP = SumMu.*P.*(1-P) - P.*P.*(N-SumMu) -0.5.*P.*(1-P) + 0.5.*(1-P).*SumMu./N;
        GP = zeros(K,1);
        for k = 1:K
           if P(k)~=0 && P(k)~=1
              GP(k) = Denom_GP(k)./P(k)./P(k)./(1-P(k));
           end
        end
        if mode_Mstep == 2% Steepest descent
            B = B + learning_coeff .* GB;
            P = P + learning_coeff .* GP;
        elseif mode_Mstep == 3% Transformed Steepest descent
            TGB = zeros(K,1);
            TGP = zeros(K,1);
            for k = 1:K
                TGB(k) = learning_coeff.*(GB(k) - P(k)./B(k).*GP(k));
                if P(k)~=0 && P(k)~=1
                    TGP(k) = learning_coeff.*(-P(k)./B(k).*GB(k) + (1 + P(k).*P(k))./B(k)./B(k).*GP(k));
                end
            end
            absmax_TGP = max(abs(TGP(:)));
            TGP_limit = 0.05;
            if absmax_TGP > TGP_limit
               TGB = TGP_limit.*TGB./absmax_TGP;
               TGP = TGP_limit.*TGP./absmax_TGP;
            end
            B = B + TGB;
            P = P + TGP;
        end
        P(P(:) > 1) = 1;% projected gradient descent
        P(P(:) < 0) = 0;
    end
    % Update of lambda (always M step)
    if flag_est_lambda == 1
        residual = Y'*Y - 2.*Y'*(XM*B) + B'*F*B;
        lambda = N./residual;
    end
    % preserving tentative parameters
    Bt(:,I) = B;
    lambdat(I) = lambda;
    Pt(:,I) = P;
    %sum(isnan(Mu(:)))
    %sum(isnan(S(:)))
    %sum(isnan(P(:)))
end % end of FAB inference
FIC = 0;
end