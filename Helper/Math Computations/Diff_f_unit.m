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
h = 1e-6;
fp = (f(t+h) - f(t-h))/(2*h);
if isscalar(t)
    fp = fp/(norm(fp) + eps);
else
    % Normalise along the component dimension (the one not of length
    % numel(t)); if both are, row t means one column per sample
    dim = find(size(fp) ~= numel(t), 1);
    if isempty(dim), dim = 1 + iscolumn(t); end
    fp = fp ./ (vecnorm(fp, 2, dim) + eps);
end
end