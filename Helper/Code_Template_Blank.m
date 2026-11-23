function Code_Template_Blank()
%% Blank template for a new visualization (copy, rename the file and the
%  function, then replace this paragraph with what the student sees and
%  controls). See Code_Template.m for a filled-in example.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all;

%% User parameters for math objects. 
% Adjust these to modify selected math objects below.

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Plot for Something',1); % Plots_to_test is an optional argument to allow for more subplots
title(app.ax,app.fig.Name,'Interpreter','latex')

%% Optional math functions for plot computations
% None

%% ============== Make the initial plots =================================

%% Precompute math for updates
% Light weight so skip

%% Build UI
NumControls = 2; % maximum number of controls

%% Functions for UI elements
% none



%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)

    end
end
 