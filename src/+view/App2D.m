classdef App2D < matlab.apps.AppBase
    properties (Access = public)
        UIFigure
        MainLayout       matlab.ui.container.GridLayout
        Axes             matlab.ui.control.UIAxes
        ControlPanel     matlab.ui.container.GridLayout
        StartButton
        ResetButton
        AddRobotButton
        RemoveRobotButton
        AddItemButton
        RemoveItemButton
        ReadOnlyModel
    end

    methods (Access = private)
        function createComponents(app, controller)
            % Main Figure
            app.UIFigure = uifigure('Name', 'Robot Pathfinder', 'Position',[100 100 800 600]);

            app.MainLayout = uigridlayout(app.UIFigure, [1,2]);
            app.MainLayout.ColumnWidth = {'3x','1x'};
            app.MainLayout.RowHeight = {'1x'};

            app.Axes = uiaxes(app.MainLayout);
            title(app.Axes, "Pathfinder Grid");
            app.Axes.Layout.Row = 1;
            app.Axes.Layout.Column = 1;

            app.ControlPanel = uigridlayout(app.MainLayout, [6,1]);
            app.ControlPanel.RowHeight = repmat({'fit'},1,6);
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 2;

            app.StartButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Start', 'ButtonPushedFcn', ...
                @(btn,event) controller.onStart());
            app.ResetButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Reset', 'ButtonPushedFcn', ...
                @(btn,event) controller.onReset());
            app.AddRobotButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Add Robot', 'ButtonPushedFcn', ...
                @(btn,event) app.promptAddRobot(controller));
            app.RemoveRobotButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Remove Robot', 'ButtonPushedFcn', ...
                @(btn,event) app.promptRemoveRobot(controller));
            app.AddItemButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Add Item', 'ButtonPushedFcn', ...
                @(btn,event) app.promptAddItem(controller));
            app.RemoveItemButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Remove Item', 'ButtonPushedFcn', ...
                @(btn,event) app.promptRemoveItem(controller));
        end
    end

    methods (Access = public)
        function app = App2D(controller, readOnly)
            createComponents(app, controller);
            app.ReadOnlyModel = readOnly;
        end

        function drawWorld(app)
            cla(app.Axes);
            hold(app.Axes, 'on');

            gridSize = size(app.ReadOnlyModel.getCells());
            xlim(app.Axes, [0 gridSize(1)]);
            ylim(app.Axes, [0 gridSize(2)]);
            app.Axes.XGrid = 'on';
            app.Axes.YGrid = 'on';

            % Draw obstacles/items
            cells = app.ReadOnlyModel.getCells();
            for i = 1:size(cells,1)
                for j = 1:size(cells,2)
                    val = cells(i,j);
                    if val ~= 0
                        plot(app.Axes, i, j, 'ks', 'MarkerSize',12,'MarkerFaceColor','k');
                    end
                end
            end

            % Draw robots
            robots = app.ReadOnlyModel.getRobots();
            for r = robots
                pos = r.getPosn();
                plot(app.Axes, pos(1), pos(2), 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');
            end

            hold(app.Axes, 'off');
        end
    end

    methods(Access = private)
        function [pos, speed] = promptAddRobot(app, controller)
            answer = inputdlg({'X Position:','Y Position:','Speed:'}, 'Add Robot', [1 35]);
            if isempty(answer)
                pos = []; speed = [];
                return;
            end
            pos = [str2double(answer{1}), str2double(answer{2})];
            speed = str2double(answer{3});
            controller.addRobot(pos, speed);
        end
    
        function pos = promptRemoveRobot(app, controller)
            answer = inputdlg({'X Position:','Y Position:'}, 'Remove Robot', [1 35]);
            if isempty(answer)
                pos = [];
                return;
            end
            pos = [str2double(answer{1}), str2double(answer{2})];
            controller.removeRobot(pos);
        end
    
        function [pos, val] = promptAddItem(app, controller)
            answer = inputdlg({'X Position:','Y Position:','Item Value:'}, 'Add Item', [1 35]);
            if isempty(answer)
                pos = []; val = [];
                return;
            end
            pos = [str2double(answer{1}), str2double(answer{2})];
            val = str2double(answer{3});
            controller.addItem(pos, val);
        end
    
        function pos = promptRemoveItem(app, controller)
            answer = inputdlg({'X Position:','Y Position:'}, 'Remove Item', [1 35]);
            if isempty(answer)
                pos = [];
                return;
            end
            pos = [str2double(answer{1}), str2double(answer{2})];
            controller.removeItem(pos);
        end
    end
end
