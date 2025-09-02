classdef BasicController < handle
    properties
        Model
        View  
    end
    
    methods
        function obj = PathfinderController(model, view)
            obj.Model = model;
            obj.View = view;
            obj.updateView();
        end
        
        function onStart(obj)
            obj.Model.start();
            obj.updateView();
        end
        
        function onReset(obj)
            obj.Model.reset();
            obj.updateView();
        end
        
        function updateView(obj)
            ax = obj.View.Axes;
            cla(ax); 
            hold(ax, 'on');
            
            obj.Model.draw(ax);
            
            for r = obj.Model.Robots
                pos = r.getPosn();
                plot(ax, pos(1), pos(2), 'o', ...
                    'MarkerSize', 10, 'MarkerFaceColor', 'b');
            end

            
            hold(ax, 'off');
        end

        function addRobot(obj, posn, speed)
            r = robot.BasicRobot(posn, speed);
            obj.Model.addRobot(posn, r);
        end

        function removeRobot(obj, posn)
            obj.Model.removeRobot(posn);
        end

        function addItem(obj, posn, itemVal)
            obj.Model.addItem(posn, itemVal);
        end

        function removeItem(obj, posn)
            obj.Model.removeItem(posn);
        end
    end
end
