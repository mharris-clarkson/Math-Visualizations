% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate unit tangent vector at the time(s) t
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fp = Diff_f_unit(f,t)
h = 1e-6;   % ~optimal for central differences (1e-10 gives ~1e-6 rounding noise)
fp = (f(t+h) - f(t-h))/(2*h);
if isscalar(t)
    fp = fp/(norm(fp) + eps); % eps avoids 0/0 where the speed is zero
else
    % One tangent per sample: normalise along the dimension that holds the
    % vector components (the one whose length is not numel(t)). When both
    % sizes equal numel(t) (e.g. 3 samples of a 3D curve) use t's shape:
    % row t -> one column per sample, column t -> one row per sample.
    dim = find(size(fp) ~= numel(t), 1);
    if isempty(dim), dim = 1 + iscolumn(t); end
    fp = fp ./ (vecnorm(fp, 2, dim) + eps);
end
end