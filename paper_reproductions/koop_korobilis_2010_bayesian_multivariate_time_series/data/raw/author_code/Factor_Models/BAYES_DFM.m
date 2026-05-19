%BAYES_DFM This implements the state-space estimation of the dynamic
%factors, their loadings and autoregressive parameters. The program was
%written by Piotr Eliasz (2003) Princeton University for his PhD thesis and
%and used in Bernake, Boivin and Eliasz (2005), published in QJE.
%Modified by Dimitris Korobilis on Monday, June 11, 2007
%--------------------------------------------------------------------------
% Estimate dynamic factor model:
%                X_t = Lam x F_t + e_t
%                F_t = B(L) x F_t-1 + u_t
% The previous (Eliasz, 2005) version was:
%         [X_t ; Y_t] = [Lf Ly ; 0 I] x [F_t ; Y_t] + e_t
%         [F_t ; Y_t] = [B(L) ; 0 I] x [F_t-1 ; Y_t-1] + u_t
%
%--------------------------------------------------------------------------

clear all;
clc;
randn('seed',sum(100*clock)); %#ok<*RAND>
rand('seed',sum(100*clock));
%---------------------------LOAD DATA--------------------------------------
% simulated dataset
X=dfmdgp();

[T,N]=size(X);
%Demean xraw
X=X-repmat(mean(X),T,1);

% Number of factors & lags in B(L):
K=3;
lags=1;
%----------------------------PRELIMINARIES---------------------------------
% Set some Gibbs - related preliminaries
nods = 10000;  % Number of draws
bid = 2000;   % Number of burn-in-draws
thin = 1;   % Consider every thin-th draw (thin value)

% store draws in:
Ldraw=zeros(nods-bid,N,K);
Bdraw=zeros(nods-bid,K,K,lags);
Qdraw=zeros(nods-bid,K,K);
Fdraw=zeros(nods-bid,T,K);  
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
% Run a VAR in F, obtain initial B and Q
[B,Bc,v,Q,invFF]=estvar(F0,lags,[]);

% Put it all in state-space representation, write obs equ as XY=FY*L+e
XY=X;   %Tx(N+M)
FY=F0;

% adjust for lags in state equation, Q is KxK
Q=[Q zeros(K,K*(lags-1));zeros(K*(lags-1),K*lags)];
B=[B(:,:);eye(K*(lags-1)) zeros(K*(lags-1),K)];

% start with
Sp=zeros(K*lags,1);
Pp=eye(K*lags);  

% Proper Priors:-----------------------------------------------------------
% on VAR -- Normal-Wishart, after Kadiyala, Karlsson, 1997
% on Q -- si
% on B -- increasing tightness
% on observable equation:
% N(0,I)-iG(3,0.001)

% prior distributions for VAR part, need B and Q
vo=K+2;
s0=3;
alpha=0.001;
L_var_prior=eye(K);
Qi=zeros(K,1);

% singles out latent factors
indexnM=ones(K,lags);
indexnM=find(indexnM==1);
%***************End of Preliminaries & PriorSpecification******************

tic;
%==========================================================================
%========================== Start Sampling ================================
%==========================================================================
%
%************************** Start the Gibbs "loop" ************************
disp('Number of iterations');
for rep = 1:nods + bid
    if mod(rep,200) == 0
        disp(rep);
    end

    % STEP 1. =========|DRAW FACTORS
    % generate Gibbs draws of the factors
    H=L;
    F=B;
    [t,n]=size(XY);
    kml=size(Sp,1);
    km=size(L,2);
    S=zeros(t,kml);
    P=zeros(kml^2,t);
    Sdraw=zeros(t,kml);
    for i=1:t
        y = XY(i,:)';
        nu = y - H*Sp(1:km);   % conditional forecast error
        f = H*Pp(1:km,1:km)*H' + R;    % variance of the conditional forecast error
        finv=inv(f);
        
        Stt = Sp + Pp(:,1:km)*H'*finv*nu;
        Ptt = Pp - Pp(:,1:km)*H'*finv*H*Pp(1:km,:);
        
        if i < t
            Sp = F*Stt;
            Pp = F*Ptt*F' + Q;
        end
        
        S(i,:) = Stt';
        P(:,i) = reshape(Ptt,kml^2,1);
    end
    
    % draw Sdraw(T|T) ~ N(S(T|T),P(T|T))
    Sdraw(t,:)=S(t,:);
    Sdraw(t,indexnM)=mvnrnd(Sdraw(t,indexnM)',Ptt(indexnM,indexnM),1);
    
    % iterate 'down', drawing at each step, use modification for singular Q
    Qstar=Q(1:km,1:km);
    Fstar=F(1:km,:);
    
    for i=t-1:-1:1
        Sf = Sdraw(i+1,1:km)';
        Stt = S(i,:)';
        Ptt = reshape(P(:,i),kml,kml);
        f = Fstar*Ptt*Fstar' + Qstar;
        finv = inv(f);
        nu = Sf - Fstar*Stt;
        
        Smean = Stt + Ptt*Fstar'*finv*nu;
        Svar = Ptt - Ptt*Fstar'*finv*Fstar*Ptt;
       
        Sdraw(i,:) = Smean';
        Sdraw(i,indexnM) = mvnrnd(Sdraw(i,indexnM)',Svar(indexnM,indexnM),1);
    end
    FY=Sdraw(:,1:km);
    
	% Demean
    FY=FY-repmat(mean(FY),T,1);
    
    % STEP 2. ========|DRAW COEFFICIENTS
    % -----------------------2.1. STATE EQUATION---------------------------
    % first univ AR for scale in priors
    for i=1:km
        [Bi,Bci,vi,Qi(i),invFYFYi]=estvar(FY(:,i),lags,[]);
    end
    Q_prior=diag(Qi);
    B_var_prior=diag(kron(1./Qi',1./(1:lags)));
    [Bd,Bdc,v,Qd,invFYFY]=estvar(FY,lags,[]);
    B_hat=Bd(:,:)';
    Z=zeros(T,km,lags);
    for i=1:lags
        Z(lags+1:T,:,i)=FY(lags+1-i:T-i,:);
    end
    Z=Z(:,:);
    Z=Z(lags+1:T,:);
    iB_var_prior=inv(B_var_prior);
    B_var_post=inv(iB_var_prior+Z'*Z);
    B_post=B_var_post*(Z'*Z)*B_hat;
    Q_post=B_hat'*Z'*Z*B_hat+Q_prior+(T-lags)*Qd-B_post'*(iB_var_prior+Z'*Z)*B_post;
    
    % Draw Q from inverse Wishart
    iQd=randn(T+vo,km)*chol(inv(Q_post));
    Qd=inv(iQd'*iQd);
    Q(1:km,1:km)=Qd;

    % Draw B conditional on Q
    vecB_post=reshape(B_post,km*km*lags,1);
    vecBd = vecB_post+chol(kron(Qd,B_var_post))'*randn(km*km*lags,1);
    Bd = reshape(vecBd,km*lags,km)';
    B(1:km,:)=Bd;
    
    % Truncate to ensure stationarity
    while max(abs(eig(B)))>0.999
        vecBd = vecB_post+chol(kron(Qd,B_var_post))'*randn(km*km*lags,1);
        Bd = reshape(vecBd,km*lags,km)';
        B(1:km,:)=Bd;
    end
    
    % ----------------------2.2. OBSERVATION EQUATION----------------------
    % OLS quantities
    L_OLS = inv(FY'*FY)*(FY'*X(:,K+1:N));
    R_OLS = (X - FY*L')'*(X - FY*L')./(T-N);
    
    
    L=[eye(K) L_OLS]';
    
    for n=1:N
        ed=X(:,n)-FY*L(n,:)';

        % draw R(n,n)
        R_bar=s0+ed'*ed+L(n,:)*inv(L_var_prior+inv(FY'*FY))*L(n,:)';        
        Rd=chi2rnd(T+alpha);
        Rd=R_bar/Rd;
        R(n,n)=Rd;
    end
    
    % Save draws
    if rep > bid
        Ldraw(rep-bid,:,:)=L(1:N,1:km);
        Bdraw(rep-bid,:,:,:)= reshape(Bd,km,km,lags);
        Qdraw(rep-bid,:,:)=Qd;
        Fdraw(rep-bid,:,:)=FY;
        Rdraw(rep-bid,:)=diag(R);
    end
end
toc;
% ==========================Finished Sampling==============================
% =========================================================================

% Do thining in case of high correlation
thin_val = 1:thin:((nods-bid)/thin);
Ldraw = Ldraw(thin_val,:,:);
Bdraw = Bdraw(thin_val,:,:,:);
Qdraw = Qdraw(thin_val,:,:);
Fdraw = Fdraw(thin_val,:,:);

% Average over Gibbs draws
Fdraw2=squeeze(mean(Fdraw,1));
Ldraw2=squeeze(mean(Ldraw,1));
Qdraw2=squeeze(mean(Qdraw,1));
Bdraw2=squeeze(mean(Bdraw,1));

% Get matrix of autoregressive parameters B
Betas = [];
for dd = 1:lags
    B = mean(Bdraw,1);
    beta = B(1,:,:,dd);
    beta_new = zeros(K,K);
    for jj=1:K
        beta_new(:,jj) = beta(1,:,jj);
    end
    Betas = [Betas beta_new]; %#ok<AGROW>
end

