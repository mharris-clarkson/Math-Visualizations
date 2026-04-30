% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate tangent vector at the time(s) t
function fp = Diff_f(f,t)
h = 1e-10;
fp = (f(t+h) - f(t-h))/(2*h);
fp = fp;%/norm(fp);
end