function I = Polygon_Integral(f, xv, yv, options)
%% Accurate double integral of f(x,y) over the region inside a polygon
% Integrates over vertical slices: at each x the slice of the region is
% one or more y-intervals (found from where the polygon's edges cross that
% vertical line), each integrated with Gauss-Legendre in y; the slices are
% then integrated in x with MATLAB's adaptive integral(). Much more
% accurate than summing f over a grid of cells (the cut cells along the
% boundary limit a grid sum to a few digits).
%
% The polygon must not cross itself. f must work elementwise on arrays.
%
%% Syntax
%
% I = Polygon_Integral(f, xv, yv)
% I = Polygon_Integral(f, xv, yv, 'Nodes', 60, 'RelTol', 1e-10)
%
% Inputs:
%
% f        - function handle f(x,y).
% xv, yv   - polygon vertices (closed or not).
% 'Nodes'  - Gauss-Legendre points per y-interval (default 40).
% 'AbsTol', 'RelTol' - tolerances for the x integral (default 1e-10).
%
% Outputs:
%
% I        - the integral of f over the region.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    f        function_handle
    xv       double
    yv       double
    options.Nodes  (1,1) double = 40
    options.AbsTol (1,1) double = 1e-10
    options.RelTol (1,1) double = 1e-10
end
xv = xv(:);  yv = yv(:);
x1 = xv;  y1 = yv;  x2 = xv([2:end 1]);  y2 = yv([2:end 1]);
[gx, gw] = gaussLegendre(options.Nodes);   % nodes and weights on [-1, 1]

I = integral(@slices, min(xv), max(xv), 'AbsTol', options.AbsTol, 'RelTol', options.RelTol);

    function g = slices(xs)
        g = zeros(size(xs));
        for k = 1:numel(xs)
            x  = xs(k);
            c  = (x1 <= x) ~= (x2 <= x);
            yc = sort(y1(c) + (x - x1(c)).*(y2(c) - y1(c))./(x2(c) - x1(c)));
            for j = 1:2:numel(yc) - 1           % inside between pairs of crossings
                a = yc(j);  b = yc(j+1);
                y = (b - a)/2*gx + (a + b)/2;
                g(k) = g(k) + (b - a)/2 * sum(gw .* f(x + 0*y, y));
            end
        end
    end
end

function [x, w] = gaussLegendre(n)
% Gauss-Legendre nodes and weights on [-1, 1] (Golub-Welsch)
k = 1:n-1;
beta = k ./ sqrt(4*k.^2 - 1);
[V, D] = eig(diag(beta, 1) + diag(beta, -1));
[x, idx] = sort(diag(D));
w = 2 * V(1, idx).'.^2;
end
