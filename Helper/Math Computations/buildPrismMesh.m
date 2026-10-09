function [V, bottomFaces, topFaces, sideFaces] = buildPrismMesh(xi, yj, zij, dx, dy)
%% Vertex/face arrays for a grid of axis-aligned prisms.
% Each prism has base [xi-dx/2,xi+dx/2] x [yj-dy/2,yj+dy/2] and height
% zij. Vectorized across all n prisms at once (no per-prism loop), for
% use with patch(). Shared by the Cartesian Riemann-prism demos.
xi = xi(:); yj = yj(:); zij = zij(:);
n = numel(xi);
cornerDX = dx/2*[-1, 1, 1, -1];
cornerDY = dy/2*[-1, -1, 1, 1];

CX = xi + cornerDX;     % n x 4: corner x-coords (same at bottom and top)
CY = yj + cornerDY;     % n x 4: corner y-coords (same at bottom and top)
Zb = zeros(n, 4);
Zt = repmat(zij, 1, 4);

Vx = reshape([CX, CX].', [], 1);
Vy = reshape([CY, CY].', [], 1);
Vz = reshape([Zb, Zt].', [], 1);
V  = [Vx, Vy, Vz];       % 8n x 3

base        = 8*(0:n-1).';
bottomFaces = base + (1:4);
topFaces    = base + (5:8);
sideFaces   = [base + [1 2 6 5]; ...
               base + [2 3 7 6]; ...
               base + [3 4 8 7]; ...
               base + [4 1 5 8]];
end