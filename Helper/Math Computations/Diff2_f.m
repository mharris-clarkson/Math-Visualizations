% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate second derative vector at the time(s) t
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fpp = Diff2_f(f,t)
h = 1e-4;
fpp = (f(t+h) -2*f(t) + f(t-h))/(h^2);
end