% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate tangent vector at the time(s) t
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fp = Diff_f(f,t)
h = 1e-6;
fp = (f(t+h) - f(t-h))/(2*h);

end