% A function that takes in:
% - A function handle f and 
% - A scalar or vector of times t
% and returns an approximate  tangent vector at the time(s) t
function fp = Diff_f_forward(f,t,options)
arguments
    f            function_handle
    t            double 
    options.Dt   double =1e-10
    options.unit double = false
end

h = options.Dt;
fp = (f(t+h) - f(t))/(h);
if options.unit
    fp = fp/norm(fp);
end
end