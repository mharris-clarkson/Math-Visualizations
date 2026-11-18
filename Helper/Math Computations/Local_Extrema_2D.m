function [isMax, isMin] = Local_Extrema_2D(Z)
%% Local_Extrema_2D  Interior local maxima and minima of a gridded surface.
%
%   [isMax, isMin] = Local_Extrema_2D(Z)
%
%  Base MATLAB replacement for imregionalmax / imregionalmin / ordfilt2
%  (those need the Image Processing Toolbox). A grid point is flagged when
%  it is strictly larger (isMax) or strictly smaller (isMin) than all 8 of
%  its neighbours. Edge points are never flagged: a local extremum needs a
%  full neighbourhood around it, which matches the Calc 3 definition.
%
%  Example
%     [X, Y] = meshgrid(linspace(-3, 3, 400));
%     Z = peaks(X, Y);
%     [isMax, isMin] = Local_Extrema_2D(Z);
%     maxPts = [X(isMax), Y(isMax), Z(isMax)];   % 3 local maxima
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%

[m, n] = size(Z);
isMax  = false(m, n);
isMin  = false(m, n);
if m < 3 || n < 3, return, end

rows = 2:m-1;
cols = 2:n-1;
C    = Z(rows, cols);          % interior points
nbMax = -inf(size(C));         % largest neighbour of each interior point
nbMin =  inf(size(C));         % smallest neighbour of each interior point

for di = -1:1
    for dj = -1:1
        if di == 0 && dj == 0, continue, end
        N     = Z(rows + di, cols + dj);
        nbMax = max(nbMax, N);
        nbMin = min(nbMin, N);
    end
end

isMax(rows, cols) = C > nbMax;
isMin(rows, cols) = C < nbMin;
end
