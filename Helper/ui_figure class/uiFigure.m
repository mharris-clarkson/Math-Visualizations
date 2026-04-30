classdef uiFigure < handle
%% Class for creating nice figure objects for dynamic plots.
%  It returns a figure handle, axes handles and button/slider handles for 
%  modifying the data. 
%  app = UIApplet(name, numSubPlots) initalizes the object with some
%  subplots (default is 1)
%
%  addControl adds a button or slider on a grid decided by uiGrid. Can 
%  do rows and cols with equal or min size spacing. The data of these 
%  items are modifiable if needed as noted in demo()
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
% Copyright (c) 2026 Matthew Harris
% Licensed under the MIT License.
% See LICENSE file in the project root for full license information.
    properties
        fig
        ax = gobjects(0)
        controls = gobjects(0)
    end

    methods
        % ============================================
        % Initalize applet and apply Pretty_Plot for nice labels
        % ============================================
        function app = uiFigure(name, numSubPlots)
            arguments
                name
                numSubPlots (1,1) double = 1
            end

            % Initalize the figure
            app.fig = figure('Color','w',...
                'Name',name,...
                'WindowState','maximized');

            % Create subplots
            for i = 1:numSubPlots
                app.ax(i) = subplot(1, numSubPlots, i);
                hold(app.ax(i), 'on')
                Pretty_Plot(app.ax(i));
                %% add manual? etc?
            end
        end

        % ============================================
        % OBJECT ADDER - Adds both buttons and sliders to the grid built
        % by uiGrid
        % ============================================
        function [h, label] = addControl(app,type,label,idx,Num_Obj,callback,options)
            arguments
                app
                type
                label
                idx
                Num_Obj
                callback
                % Grid control options
                options.minY         double = []
                options.maxY         double = []
                options.minX         double = []
                options.maxX         double = []
                options.width        double = []
                options.height       double = []
                options.gap          double = []
                options.autoCenter   logical =[]
                options.colOrRow     string = 'col'
                options.maxheight    double = []
                % Button/Slider shaired controls
                options.Visible      string  = []
                options.FontSize     double  = []
                % Button control options
                options.ColorChange logical  = []
                % Slider controls
                options.Default       double = []
                options.labelRatio    double = []
                options.Number_format string = []
                options.AddToEnd      char   = ''
                options.Min           double = []
                options.Max           double = []
            end
            % Check for valid colOrRow values
            if ~(strcmpi(options.colOrRow,'row') || strcmpi(options.colOrRow,'col'))
                error('UIApplet - addControl: colOrRow should be ''row'' or ''col'' but was %s', options.colOrRow);
            end

            % Build gridOpts from only the fields that were explicitly set
            gridOpts = struct();
            fields = {'minY','maxY','minX','maxX',...
                'width','height','gap','autoCenter','colOrRow'};
            for i = 1:numel(fields)
                f = fields{i};
                if ~isempty(options.(f))
                    gridOpts.(f) = options.(f);
                end
            end
            gridArgs = namedargs2cell(gridOpts);

            %compute position
            pos = uiGrid(idx, Num_Obj, gridArgs{:});

            switch type
                case "button"
                    % Build Buton Opts from only the fields that were explicitly set
                    btnOpts = struct();
                    fields = {'Visible','ColorChange','colOrRow','FontSize'};
                    for i = 1:numel(fields)
                        f = fields{i};
                        if ~isempty(options.(f))
                            btnOpts.(f) = options.(f);
                        end
                    end
                    btnArgs = namedargs2cell(btnOpts);
                    h = CreateUIButton(app, label, pos, callback, btnArgs{:});
                    app.controls(idx) = h; % store
                case "slider"
                    sldOpts = struct();
                    fields = {'Visible','ColorChange','colOrRow','Min',...
                        'Max','Default','FontSize','Number_format','AddToEnd'};
                    for i = 1:numel(fields)
                        f = fields{i};
                        if ~isempty(options.(f))
                            sldOpts.(f) = options.(f);
                        end
                    end
                    sldArgs = namedargs2cell(sldOpts);
                    h = CreateUISlider(app, label, pos, callback, sldArgs{:});
                    app.controls(idx) = h; % store
            end
        end

        % ============================================
        % LATEX BUTTON
        % ============================================
        function Button = CreateUIButton(app, name, pos, CallbackFcn, options)
            arguments
                app
                name                 string
                pos                  double
                CallbackFcn          function_handle
                options.Visible      string  = "on"
                options.ColorChange  logical = false
                options.colOrRow     string  = 'col'
                options.FontSize     double  = 18
            end
            % Call helper function to resize axes to fit buttons/sliders if needed
            Subplot_Mover(app, pos, options.colOrRow);

            % Add button with dynamic fontsize based on the button pixel size
            Button = uicontrol_Latex(app.fig, ...
                'String',   name, ...
                'Position', pos, ...
                'FontSize', options.FontSize, ...
                'Callback', CallbackFcn,...
                'Visible', options.Visible,...
                'Color_change',options.ColorChange);
        end

        % ============================================
        % LATEX SLIDER
        % ============================================
        function Slider = CreateUISlider(app, Name, pos, CallbackFcn, options)
            arguments
                app
                Name                 string
                pos                  double
                CallbackFcn          function_handle
                options.Default       double  = 0
                options.Min           double  = 0
                options.Max           double  = 1
                options.Visible       string  = "on"
                options.colOrRow      string  = 'col'
                options.labelRatio    double  = 0.4
                options.Number_format char    = '%.2f'
                options.AddToEnd      char    = ''
                options.FontSize      double  = 18
                
            end

            % Grab Slider/Label pos to split for label/slider
            SliderPosition    = pos;
            SliderLabPosition = pos;

            % Adjust slider and label to share the space
            SliderPosition(4)    = SliderPosition(4) * options.labelRatio;
            SliderLabPosition(2) = SliderPosition(2) + SliderPosition(4) + 0.001; % num is padding
            SliderLabPosition(4) = pos(4) * (1 - options.labelRatio);

            %% Call helper function to resize axes to fit the slider if needed
            Subplot_Mover(app, pos, options.colOrRow);

            %% Make slider label
            ax_label = axes(app.fig, ...
                'Units',    'normalized', ...
                'Position', SliderLabPosition, ...
                'Visible',  'off');

            % Disable all interactivity on ax_label
            axtoolbar(ax_label, {});
            disableDefaultInteractivity(ax_label);
            ax_label.Interactions = [];
            ax_label.Toolbar.Visible = 'off';

            % Format initial label string
            if strcmp(options.Number_format, '%d')
                Label_str = sprintf('%s%d%s', Name, round(options.Default,0), options.AddToEnd);
            else
                fmt = ['%s' options.Number_format '%s'];
                Label_str = sprintf(fmt, Name, options.Default, options.AddToEnd);
            end

            Slider_label = text(ax_label, 0.5, 0.5, Label_str, ... % hard coded center
                'Interpreter',         'latex', ...
                'HorizontalAlignment', 'center', ...
                'FontSize',            options.FontSize,...
                'VerticalAlignment',   'middle',...
                'HitTest',             'off', ...
                'PickableParts',       'none');

            %% Make slider object
            Slider = uicontrol(app.fig, ...
                'Style',    'slider', ...
                'Min',      options.Min, ...
                'Max',      options.Max, ...
                'Value',    options.Default, ...
                'Units',    'normalized', ...
                'Position', SliderPosition, ...
                'Visible',  options.Visible,...
                'Callback', CallbackFcn);

            % Store name and label on the slider handle
            Slider.UserData.name  = Name;
            label    = Slider_label;
            Slider.UserData.label = label;
            Slider.UserData.ax_label = ax_label;        % not used

            %% Listener that auto-updates label whenever Value changes
            addlistener(Slider, 'Value', 'PostSet', @(~,~) updateLabel(Slider.Value));

            function updateLabel(val)
                if strcmp(options.Number_format, '%d')
                    set(Slider.UserData.label, 'String', sprintf('%s%d%s', Name, round(val), options.AddToEnd));
                else
                    fmt = ['%s' options.Number_format '%s'];
                    set(label, 'String', sprintf(fmt, Name, val, options.AddToEnd));
                end
            end

        end



        % ============================================
        % SUBPLOT MOVER
        % ============================================
        function Subplot_Mover(app, pos, colOrRow)
            arguments
                app
                pos  double
                colOrRow string
            end
            % From position compute shifting factor
            if strcmpi(colOrRow, 'row')
                ShiftBy = pos(2) + pos(4) + 0.1;
            else
                ShiftBy = pos(1) - 0.01;
            end

            ax_list = findobj(app.fig, 'Type', 'axes');

            if strcmp(colOrRow, 'col')
                if ~isfield(app.fig.UserData, 'SubplotsMoved') || ~app.fig.UserData.SubplotsMoved
                    for i = 1:numel(ax_list)
                        pos = ax_list(i).Position;
                        ax_list(i).Position(1) = pos(1) * (ShiftBy * 1.1);
                        ax_list(i).Position(3) = pos(3) * (ShiftBy * 1.1);
                    end
                end
            else
                if ~isfield(app.fig.UserData, 'SubplotsMoved') || ~app.fig.UserData.SubplotsMoved
                    new_bottom = ShiftBy;
                    for i = 1:numel(ax_list)
                        pos = ax_list(i).Position;
                        if pos(2) < new_bottom
                            shrink = new_bottom - pos(2);
                            ax_list(i).Position(2) = new_bottom;
                            ax_list(i).Position(4) = max(0.05, pos(4) - shrink);
                        end
                    end
                end

            end
            app.fig.UserData.SubplotsMoved = true;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%  END FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end