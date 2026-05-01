% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate second derative vector at the time(s) t
function fpp = Diff2_f(f,t)
h = 1e-6;
fpp = (f(t+h) -2*f(t) + f(t-h))/(h^2);
end