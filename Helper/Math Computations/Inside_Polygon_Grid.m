function in = Inside_Polygon_Grid(X, Y, xv, yv)
%% Fast inpolygon for a meshgrid of points
% Returns the same result as inpolygon(X, Y, xv, yv) (points on the
% boundary count as inside) when X, Y come from meshgrid, but is much
% faster on large grids: each grid row is classified at once from where
% the boundary crosses that row, and only the points next to a crossing
% are checked with inpolygon itself. Other inputs fall back to inpolygon.
%
%% Syntax
%
% [X, Y] = meshgrid(xvec, yvec);
% in = Inside_Polygon_Grid(X, Y, xv, yv)
%
% Inputs:
%
% X, Y    - meshgrid arrays (every row of Y constant, every column of X constant).
% xv, yv  - polygon vertices (closed or not, as for inpolygon).
%
% Outputs:
%
% in      - logical array the size of X.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

xs = X(1,:);
ys = Y(:,1);
if ~ismatrix(X) || ~isequal(size(X), size(Y)) || size(X,2) < 3 || ...
        any(X(:) ~= reshape(repmat(xs, size(X,1), 1), [], 1)) || ...
        any(Y(:) ~= reshape(repmat(ys, 1, size(Y,2)), [], 1))
    in = inpolygon(X, Y, xv, yv);
    return
end

% Edges from vertex k to vertex k+1, closing the polygon
xv = xv(:);  yv = yv(:);
x1 = xv;  y1 = yv;
x2 = xv([2:end 1]);  y2 = yv([2:end 1]);

nearDist = 2*max(abs(diff(xs)));          % "next to a crossing": within two columns
yTol     = 1e-12*max(1, max(abs(yv)));
in   = false(size(X));
near = false(size(X));
for i = 1:numel(ys)
    y = ys(i);
    if any(abs(yv - y) <= yTol)            % row through a vertex: check it all exactly
        near(i,:) = true;
        continue
    end
    c  = (y1 <= y) ~= (y2 <= y);           % edges crossing this row (half-open rule)
    xc = x1(c) + (y - y1(c)).*(x2(c) - x1(c))./(y2(c) - y1(c));
    up = sign(y2(c) - y1(c));              % winding number: +1 up, -1 down
    in(i,:)   = sum(up .* (xs > xc), 1) ~= 0;
    near(i,:) = any(abs(xs - xc) <= nearDist, 1);
end
in(near) = inpolygon(X(near), Y(near), xv, yv);
end
