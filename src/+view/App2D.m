classdef App2D < matlab.apps.AppBase
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        Axes               matlab.ui.control.UIAxes
        StartButton        matlab.ui.control.Button
        ResetButton        matlab.ui.control.Button
        AddRobotButton     matlab.ui.control.Button
        RemoveRobotButton  matlab.ui.control.Button
        AddItemButton      matlab.ui.control.Button
        RemoveItemButton   matlab.ui.control.Button
        ReadOnlyModel
    end
    
    methods (Access = private)
        function createComponents(app, controller)
            % Create main figure and grid layout
            app.UIFigure = uifigure('Name', 'Robot Pathfinder');
            app.GridLayout = uigridlayout(app.UIFigure, [4,2]);
            app.GridLayout.RowHeight = {'1x','fit','fit','fit'};
            app.GridLayout.ColumnWidth = {'3x','fit'};

            % Axes for visualization
            app.Axes = uiaxes(app.GridLayout);
            app.Axes.Layout.Row = [1 9];
            app.Axes.Layout.Column = 1;
            title(app.Axes, "Pathfinder Grid");

            % Start button
            app.StartButton = uibutton(app.GridLayout, 'push', ...
                'Text', 'Start', ...
                'ButtonPushedFcn', @(btn,event) controller.onStart());
            app.StartButton.Layout.Row = 1;
            app.StartButton.Layout.Column = 2;
            
            % Reset button
            app.ResetButton = uibutton(app.GridLayout, 'push', ...
                'Text', 'Reset', ...
                'ButtonPushedFcn', @(btn,event) controller.onReset());
            app.ResetButton.Layout.Row = 2;
            app.ResetButton.Layout.Column = 2;

            % Add Robot button
            app.AddRobotButton = uibutton(app.GridLayout, 'push', ...
                'Text', 'Add Robot', ...
                'ButtonPushedFcn', @(btn,event) controller.addRobot());
            app.AddRobotButton.Layout.Row = 3;
            app.AddRobotButton.Layout.Column = 2;

            % Remove Robot button
            app.RemoveRobotButton = uibutton(app.GridLayout, 'push', ...
                'Text', 'Remove Robot', ...
                'ButtonPushedFcn', @(btn,event) controller.removeRobot());
            app.RemoveRobotButton.Layout.Row = 4;
            app.RemoveRobotButton.Layout.Column = 2;

            % Add Item button
            app.AddItemButton = uibutton(app.GridLayout, 'push', ...
                'Text', 'Add Item', ...
                'ButtonPushedFcn', @(btn,event) controller.addItem());
            app.AddItemButton.Layout.Row = 5;
            app.AddItemButton.Layout.Column = 2;

            % Remove Item button
            app.RemoveItemButton = uibutton(app.GridLayout, 'push', ...
                'Text', 'Remove Item', ...
                'ButtonPushedFcn', @(btn,event) controller.removeItem());
            app.RemoveItemButton.Layout.Row = 6;
            app.RemoveItemButton.Layout.Column = 2;
        end
    end
    
    methods (Access = public)
        function app = App2D(controller, readOnly)
            createComponents(app, controller);
            app.ReadOnlyModel = readOnly;
        end

        function drawWorld(app)
            % Clear old drawing
            cla(app.Axes); 
            hold(app.Axes, 'on');

            % Get grid size
            gridSize = size(app.ReadOnlyModel.getCells());
            xlim(app.Axes, [0 gridSize(1)]);
            ylim(app.Axes, [0 gridSize(2)]);
            app.Axes.XGrid = 'on';
            app.Axes.YGrid = 'on';

            % Draw obstacles
            obstacles = app.ReadOnlyModel.getCells();
            for k = 1:size(obstacles,1)
                pos = obstacles(k,:);
                plot(app.Axes, pos(1), pos(2), 'ks', ...
                    'MarkerSize', 12, 'MarkerFaceColor','k');
            end

            % Draw robots
            robots = app.ReadOnlyModel.getRobots();
            for r = robots
                pos = r.getPosn();
                plot(app.Axes, pos(1), pos(2), 'ro', ...
                    'MarkerSize', 10, 'MarkerFaceColor','r');
            end

            hold(app.Axes, 'off');
        end
    end
end
