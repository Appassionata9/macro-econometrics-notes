%BFM - Bayesian Factor Model

clear all;
clc;
randn('state',sum(100*clock)); %#ok<RAND>
rand('twister',sum(100*clock)); %#ok<RAND>

% Generate data
X = bfmdgp();
[T,N]=size(X);

%Demean xraw
X=X-repmat(mean(X),T,1);

% Number of factors
K=3;
%----------------------------PRELIMINARIES---------------------------------
% Set some Gibbs - related preliminaries
nods = 10000;  % Number of draws to keep
bid = 2000;   % Number of burn-in-draws
ndraws = nods + bid; % Total number of draws
thin = 1;   % Consider every thin-th draw (thin value)

% store draws in:
Ldraw=zeros((nods-bid)/thin,N,K);
Fdraw=zeros((nods-bid)/thin,T,K);  
Rdraw=zeros((nods-bid)/thin,N,1);
%********************************************************
% STANDARDIZE for PC only
X_st=X./repmat(std(X,1),T,1);
% First step - extract PC from X
[F0,Lf]=extract(X_st,K);
% Transform factors and loadings for LE normalization
[ql,rl]=qr(Lf');
Lf=rl;  % do not transpose yet, is upper triangular
F0=F0*ql;
% Need identity in the first K columns of Lf, call them A for now
A=Lf(:,1:K);
Lf=[eye(K),inv(A)*Lf(:,(K+1):N)]';
F0=F0*A;
% Obtain R:
e=X_st-F0*Lf';
R=e'*e./T;
R=diag(diag(R));
L=Lf;
F=randn(T,K);
%------------------PRIORS:--------------
L_var_prior=eye(K);

% Hyperparameters for R(n,n) ~ IG(a/2,b/2)
mu_sigeps = .5;
a = 3;
b = (1/(2*mu_sigeps));

v0=5;
s0=0.1;

tic;
%==========================================================================
%========================== Start Sampling ================================
%==========================================================================
%
%************************** Start the Gibbs "loop" ************************
disp('Number of iterations');
for rep = 1:nods
    if mod(rep,100) == 0
        disp(rep);
    end
    
    % STEP 1. =========|DRAW FACTORS
    for t=1:T
        F_var = inv(eye(K) + L'*inv(R)*L);
        F_mean = F_var*L'*inv(R)*X(t,:)';
        Fd = F_mean + chol(F_var)'*randn(K,1);
        F(t,1:K)=Fd';
    end
    
    % STEP 2. =========|DRAW LOADINGS + SIGMA
    for n=1:N
        ed=X(:,n)-F*L(n,:)';
       % R(n,n) = invgamrnd((T/2) + a, inv(inv(b) + .5*ed'*ed),1,1);
       
        % draw R(n,n)
        R_2 = (s0 + ed'*ed/2);
        R_1 = (v0 + T/2);
        rd = gamrnd(R_1,1/R_2);
        Rd=inv(rd);
        R(n,n)=Rd;

        % draw L(n,1:K):
        if n <= K
            Lg=zeros(K,1);
            L_var_post=inv(inv(eye(n))+inv(R(n,n))*F(:,1:n)'*F(:,1:n));
            Lpostmean = L_var_post*(inv(R(n,n))*F(:,1:n)'*X(:,n));
            Lg(1:n-1,:) = Lpostmean(1:n-1,:) + chol(L_var_post(1:n-1,1:n-1))'*randn(n-1,1);
            Lg(n,:) = normlt_rnd(Lpostmean(n),L_var_post(n,n),0);
            L(n,1:K)=Lg';
        elseif n>K
            L_var_post=inv(inv(L_var_prior)+inv(R(n,n))*F'*F);
            Lpostmean=L_var_post*(inv(R(n,n))*F'*X(:,n));
            Ld=Lpostmean + chol(L_var_post)'*randn(K,1);
            L(n,1:K)=Ld';
        end
    end
    
    if rep>bid && mod(rep,thin)==0;
        Ldraw((rep-bid)/thin,:,:)=L;
        Fdraw((rep-bid)/thin,:,:)=F;
        Rdraw((rep-bid)/thin,:,:)=diag(R);
    end
        
end
toc;