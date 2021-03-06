% Copyright 2015 The Regents of the University of California
%
% Implemented by Jeff Irion (Adviser: Dr. Naoki Saito)



matrix = imread('barbara.png','png');
% matrix = imresize(matrix,0.5);
matrix = double(matrix)/255;

% constants
[rows,cols] = size(matrix);

% generate row and column permutation vectors
[~,Prows] = sort(rem((1:rows)'*pi,1),'descend');        % the row permutation
[~,Pcols] = sort(rem((1:cols)'*sqrt(2),1),'descend');   % the reverse row permutation
rowsP = (1:rows)'; rowsP(Prows) = rowsP;                % the reverse row permutation
colsP = (1:cols)'; colsP(Pcols) = colsP;                % the reverse col permutation

% permute the matrix
matrix = matrix(Prows,Pcols);

% partition the matrix
[GProws,GPcols] = PartitionTreeMatrixDhillon(matrix);

% find the coarse-to-fine row best basis
dG = GHWT_Analysis(Gpath(rows,matrix),GProws);
[~,~,~,BSrows] = GHWT_BestBasis(dG,GProws,0.1,1);

% find the coarse-to-fine column best basis
dG = GHWT_Analysis(Gpath(cols,matrix'),GPcols);
[~,~,~,BScols] = GHWT_BestBasis(dG,GPcols,0.1,1);

% visualize the coarse-to-fine row and column best bases
Matrix_BasisVisual(matrix,GProws,GPcols,BSrows,BScols,'r','r',2,2);