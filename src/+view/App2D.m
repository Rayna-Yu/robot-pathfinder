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

    methods (Access = public)
        function app = App2D(controller, readOnly)
            createComponents(app, controller);
            app.ReadOnlyModel = readOnly;
            drawWorld(app);
        end

        function drawWorld(app)
            cla(app.Axes);
            hold(app.Axes,'on');
            gridSize = size(app.ReadOnlyModel.getCells());
            xlim(app.Axes, [1 gridSize(1)]);
            ylim(app.Axes, [1 gridSize(2)]);
            app.Axes.XGrid = 'on';
            app.Axes.YGrid = 'on';

            itemMap = app.ReadOnlyModel.getMap();
            keys = itemMap.keys;
            for k = 1:length(keys)
                item = itemMap(keys{k});
                [rIdx, cIdx] = find(app.ReadOnlyModel.getCells() == item.value);
                for i = 1:length(rIdx)
                    h = plot(app.Axes, rIdx(i), cIdx(i), item.marker, ...
                        'MarkerSize', item.size, ...
                        'MarkerFaceColor', item.color, ...
                        'Color', item.color, 'LineWidth', 1.5);
                    h.ButtonDownFcn = @(src,event) showTooltip(src, 'item', item);
                end
            end
        
            robots = app.ReadOnlyModel.getRobots();
            for r = robots
                pos = r.getPosn();
                h = plot(app.Axes, pos(1), pos(2), 'ro', ...
                    'MarkerSize',12,'MarkerFaceColor','r','LineWidth',1.5);
                h.ButtonDownFcn = @(src,event) showTooltip(src, 'robot', r);
            end
        
            hold(app.Axes,'off');
        end
    end

    methods(Access = private)
        function createComponents(app, controller)
            app.UIFigure = uifigure('Name', 'Robot Pathfinder', ...
                'Position', [500 500 800 600]);
            app.MainLayout = uigridlayout(app.UIFigure, [1,2]);
            app.MainLayout.ColumnWidth = {'3x','1x'};
            app.MainLayout.RowHeight = {'1x'};

            % Axes
            app.Axes = uiaxes(app.MainLayout);
            title(app.Axes, "Pathfinder Grid");
            app.Axes.Layout.Row = 1;
            app.Axes.Layout.Column = 1;

            % Control panel
            app.ControlPanel = uigridlayout(app.MainLayout, [6,1]);
            app.ControlPanel.RowHeight = repmat({'fit'},1,6);
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 2;

            % Buttons
            app.StartButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Start', 'ButtonPushedFcn', @(btn,event) controller.onStart());
            app.ResetButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Reset', 'ButtonPushedFcn', @(btn,event) controller.onReset());
            app.AddRobotButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Add Robot', 'ButtonPushedFcn', @(btn,event) app.promptAddRobot(controller));
            app.RemoveRobotButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Remove Robot', 'ButtonPushedFcn', @(btn,event) app.promptRemoveRobot(controller));
            app.AddItemButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Add Item', 'ButtonPushedFcn', @(btn,event) app.promptAddItem(controller));
            app.RemoveItemButton = uibutton(app.ControlPanel, 'push', ...
                'Text', 'Remove Item', 'ButtonPushedFcn', @(btn,event) app.promptRemoveItem(controller));
        end

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

        function [pos, itemName] = promptAddItem(app, controller)
            itemKeys = app.ReadOnlyModel.getMap().keys;
            d = uifigure('Name','Select Item','Position',[500 500 300 150]);
            lbl1 = uilabel(d,'Text','X Position:','Position',[10 100 60 22]);
            txtX = uieditfield(d,'numeric','Position',[80 100 50 22]);
            lbl2 = uilabel(d,'Text','Y Position:','Position',[10 70 60 22]);
            txtY = uieditfield(d,'numeric','Position',[80 70 50 22]);
            lbl3 = uilabel(d,'Text','Item:','Position',[10 40 60 22]);
            dd = uidropdown(d,'Items',itemKeys,'Position',[80 50 150 22]);
            btn = uibutton(d,'Text','OK','Position',[100 10 50 22],'ButtonPushedFcn',@(btn,event) uiresume(d));
            uiwait(d);
            gridSize = size(app.ReadOnlyModel.getCells());

            if isempty(txtX.Value) || isempty(txtY.Value)
                pos = []; itemName = [];
            elseif isnan(txtX.Value) || isnan(txtY.Value) || ...
                   txtX.Value < 1 || txtX.Value > gridSize(2) || ...
                   txtY.Value < 1 || txtY.Value > gridSize(1)
               uialert(d, 'Invalid position!','Error');
               pos = []; itemName = [];
               delete(d);
               return;
            else
                pos = [txtX.Value, txtY.Value];
                itemName = dd.Value;
            end
            delete(d);
            if ~isempty(pos)
                controller.addItem(pos, itemName);
            end
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

function showTooltip(plotObj, type, obj)
    ax = ancestor(plotObj, 'axes');
    switch type
        case 'item'
            msg = sprintf('%s: %d', obj.label, obj.value);
        case 'robot'
            pos = obj.getPosn();
            if ismethod(obj,'getSpeed')
                spd = obj.getSpeed();
            else
                spd = NaN;
            end
            msg = sprintf('Robot [%d,%d] Speed %.1f', pos(1), pos(2), spd);
    end
    txt = text(ax, plotObj.XData, plotObj.YData, msg, ...
               'FontSize',10, 'BackgroundColor','w', 'EdgeColor','k');
    pause(0.5);
    t = timer('StartDelay',1, 'TimerFcn', @(~,~) delete(txt));
    start(t);
end


