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
    options.unit double = false
end

h = options.Dt;
fp = (f(t+h) - f(t))/(h);
if options.unit
    fp = fp/norm(fp);
end
end