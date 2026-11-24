% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate  tangent vector at the time(s) t
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fp = Diff_f_forward(f,t,options)
arguments
    f            function_handle
    t            double 
    options.Dt   double = 1e-8  % ~optimal for one-sided differences (sqrt(eps))
    options.unit logical = false   % true: return unit tangent(s)
end

h = options.Dt;
fp = (f(t+h) - f(t))/(h);
if options.unit
    if isscalar(t)
        fp = fp/(norm(fp) + eps); % eps avoids 0/0 where the speed is zero
    else
        % One unit tangent per sample (norm(fp) of the whole array would
        % scale every tangent by the same number). Same rule as Diff_f_unit.
        dim = find(size(fp) ~= numel(t), 1);
        if isempty(dim), dim = 1 + iscolumn(t); end
        fp = fp ./ (vecnorm(fp, 2, dim) + eps);
    end
end
end