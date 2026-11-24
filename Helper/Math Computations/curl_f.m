% A function that takes in:
% - Function handles F1, F2, F3 for the components of a vector field
%   F(x,y,z) = <F1, F2, F3> and
% - Scalars or arrays of points x, y, z
% and returns the approximate components of curl F at the point(s)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function [X_curl,Y_curl,Z_curl] = curl_f(F1,F2,F3,x,y,z,options)
arguments
    F1            function_handle
    F2            function_handle
    F3            function_handle
    x             double
    y             double
    z             double
    options.Dt   double = 1e-6
end

h = options.Dt;
[X_curl,Y_curl,Z_curl]= deal((F3(x,y+h,z)-F3(x,y-h,z))/(2*h) - (F2(x,y,z+h)-F2(x,y,z-h))/(2*h), ...
     (F1(x,y,z+h)-F1(x,y,z-h))/(2*h) - (F3(x+h,y,z)-F3(x-h,y,z))/(2*h), ...
     (F2(x+h,y,z)-F2(x-h,y,z))/(2*h) - (F1(x,y+h,z)-F1(x,y-h,z))/(2*h));
end