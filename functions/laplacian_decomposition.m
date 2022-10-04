function [U,LambdaL] = laplacian_decomposition(W)

% Number of regions
n_ROI = size(W,1);

% Symmetric Normalization of adjacency matrix
D=diag(sum(W,2)); %degree; sum the fiber exiting each ROI (it is equal to the number of fibers entering the same ROI)
Wsymm=D^(-1/2)*W*D^(-1/2);
Wnew=Wsymm;

% compute normalized Laplacian
L=eye(n_ROI)-Wnew;

% Laplacian Decomposition
[U,LambdaL] = eig(L);
[LambdaL, IndL]=sort(diag(LambdaL));%order eigvalues
U=U(:,IndL);%order eigvectors

