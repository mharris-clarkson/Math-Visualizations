function Latex_Defaults(target)
%% Make LaTeX the default interpreter for every text object in a figure
% After this call, title, xlabel, ylabel, zlabel, text, legend, colorbar
% ticks, axis ticks and annotations created inside target use LaTeX without
% passing 'Interpreter','latex' each time. uiFigure calls this on every
% figure it creates, so scripts built with uiFigure never need it.
%
%% Syntax
%
% Latex_Defaults(fig)     % one figure (no side effects elsewhere)
% Latex_Defaults(groot)   % every new figure in this MATLAB session
% Latex_Defaults()        % same as Latex_Defaults(gcf)
%
% Inputs:
%
% target - a figure handle or groot.
%
% Note: plain text that contains LaTeX special characters (_ % & # ^ { })
% outside of $...$ will raise an "Unable to interpret LaTeX string"
% warning. Escape them (\_ \% \&) or put the text inside $...$.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    target = gcf
end

props = {'DefaultTextInterpreter', ...
         'DefaultAxesTickLabelInterpreter', ...
         'DefaultLegendInterpreter', ...
         'DefaultColorbarTickLabelInterpreter', ...
         'DefaultTextarrowshapeInterpreter', ...
         'DefaultTextboxshapeInterpreter'};

for i = 1:numel(props)
    try
        set(target, props{i}, 'latex');
    catch
        % Property not available in this MATLAB release: skip it
    end
end
end
