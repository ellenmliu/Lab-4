function [path] = shortest_path(costs)

%
% given a 2D array of costs, compute the minimum cost vertical path
% from top to bottom which, at each step, either goes straight or
% one pixel to the left or right.
%
% costs:  a HxW array of costs
%
% path: a Hx1 vector containing the indices (values in 1...W) for 
%       each step along the path

%dimensions of costs
[H, W] = size(costs);

%matrix containing the minimum E[i,j]
E = padarray(costs, [0 1], 999);

%matrix with the pointer of previous path of 
parent = nan(H, W);

%E[i,j] = min(E[i-1,j-1], E[i-1,j], E[i-1,j+1]) + e[i,j]
for  i = 2:H
    for j = 2:W+1
        [m, ind] = min([E(i-1,j-1), E(i-1,j), E(i-1,j+1)]);
        E(i,j) = m + E(i,j);
        %parent(i,j-1) = (((j-1)+(ind-2))-1) * H + (i-1);
        parent(i,j-1) = (j+ind-3);
    end
end

%find the minimum total path cost and it's index
[M, index] = min(E(H,:));

% initialize path
path = nan(H,1);

%elem = ((index-1)-1) * H + H;
elem = index - 1;
% Hx1 vector containing the indices for each step along the path
for h = H:-1:1
    path(h) = elem;
    elem = parent(h, elem);
end