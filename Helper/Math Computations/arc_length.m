% A function that takes in:
% - A function handles x,y, z and
% - time limits tlims
% and returns an approximate arelength
function len = arc_length(x, y, z, tlims)
t = linspace(tlims(1), tlims(2), 1000);
dt = t(2) - t(1);
dX = Diff_f(x,t);
dY = Diff_f(y,t);
dZ = Diff_f(z,t);
len  =sum(sqrt(dX.^2 + dY.^2 + dZ.^2)) * dt;
end