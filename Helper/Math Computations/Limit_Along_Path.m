% A function that takes in:
% - values zp = f(x(t), y(t)) sampled along a path through the origin and
% - the path parameter t (the path reaches the origin at t = 0)
% and returns an estimate of the limit of f along that path: the mean of
% the k samples closest to (but not at) t = 0. Values below 'ZeroTol' are
% rounded to 0.
%
%% Syntax
%
% L = Limit_Along_Path(zp, t)
% L = Limit_Along_Path(zp, t, 'k', 10, 'ZeroTol', 1e-3)
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.
function L = Limit_Along_Path(zp, t, options)
arguments
    zp double
    t  double
    options.k       (1,1) double = 10
    options.ZeroTol (1,1) double = 0
end
r     = abs(t(:));
z     = zp(:);
valid = r > 0 & isfinite(z);
r = r(valid);
z = z(valid);
[~, idx] = sort(r);
k = min(options.k, numel(idx));
if k == 0
    L = NaN;
    return
end
L = mean(z(idx(1:k)));
if abs(L) < options.ZeroTol
    L = 0;
end
end
