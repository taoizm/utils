function [Y,idx] = isomap(X,d,k)
%ISOMAP performs non-linear dimensionality reduction using Isometric Mapping.
%
% INPUT
%   X - Data points, specified as an n-by-m matrix, where each row
%       represents an m-dimensional point.
%   d - Number of dimensions for the manifold.
%   k - Number of neighbors to consider for each point.
%
% OUTPUT
%   Y   - Embedded points, returned as an n-by-d matrix.
%   idx - Indices of data points comprising the largest connected component.
%
% Example:
%
%   [Y,idx] = isomap(X,2,12);
%
%   Note: The output is identical to that from ISOMAP in the Matlab Toolbox
%   for Dimensionality Reduction created by Laurence van der Maaten
%   except for the signs of the values. This is because CMDSCALE enforces
%   a sign convention so that the largest element in each coordinate will
%   have a positive sign.
%
%   ISOMAP requires Statistics and Machine Learning Toolbox.
%   See also KNNSEARCH, DISTANCES, CMDSCALE
%
%   Copyright (c) 2023 Kentaro Tao
%   Released under the MIT license.
%   See https://opensource.org/license/mit/

p = inputParser;
p.addRequired('X',     @(x)validateattributes(x,'numeric',{'ndims',2}));
p.addOptional('d', 2,  @(x)validateattributes(x,'numeric',{'scalar','integer','positive'}));
p.addOptional('k', 12, @(x)validateattributes(x,'numeric',{'scalar','integer','positive'}));
p.parse(X,d,k);

X = p.Results.X;
d = p.Results.d;
k = p.Results.k;

tic;

%% Construct neighborhood graph
fprintf('Constructing neighborhood graph...\n');

[idx,D] = knnsearch(X,X,'K',k+1);
S = sparse(repmat(idx(:,1),1,k),idx(:,2:end),D(:,2:end));
G = graph(max(S,S'));
% Choose the largest connected component
[bin,binsizes] = G.conncomp;
if length(binsizes)>1
    fprintf('Multiple connected components are detected.\n');
    idx = binsizes(bin)==max(binsizes);
    if length(unique(bin(idx)))>1
        error('Unable to find the single largest connected component.');
    end
    fprintf('%d/%d data points are chosen... \n',sum(idx),size(X,1));
    G = G.subgraph(idx);
end

fprintf('\b done.\n  Elapsed time: %.3f seconds.\n',toc);

%% Compute shortest paths
fprintf('Computing shortest paths...\n');

D = G.distances;

fprintf('\b done.\n  Elapsed time: %.3f seconds.\n',toc);

%% Compute d-dimensional embedding
fprintf('Computing d-dimensional embedding...\n');

Y = cmdscale(D,d);

fprintf('\b done.\n  Elapsed time: %.3f seconds.\n',toc);

% Return indices of data points comprising the largest connected component
if nargout>1
    if exist('idx','var')
        idx = find(idx);
    else
        idx = 1:size(Y,1);
    end
end

end % END OF ISOMAP
