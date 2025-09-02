classdef BasicController < handle
    properties
        Model
        View  
    end
    
    methods
        function obj = BasicController(m)
            obj.Model = m;
            obj.View = view.App2D(obj, model.ReadOnly2D(m));
            obj.updateView();
        end

        function updateView(obj)
            obj.View.drawWorld();
        end
        
        function onStart(obj)
            obj.Model.start();
            obj.updateView();
        end
        
        function onReset(obj)
            obj.Model.reset();
            obj.updateView();
        end

        function addRobot(obj, posn, speed)
            r = robot.BasicRobot(posn, speed);
            obj.Model.addRobot(posn, r);
            obj.updateView();
        end

        function removeRobot(obj, posn)
            obj.Model.removeRobot(posn);
            obj.updateView();
        end

        function addItem(obj, posn, itemVal)
            obj.Model.addItem(posn, itemVal);
            obj.updateView();
        end

        function removeItem(obj, posn)
            obj.Model.removeItem(posn);
            obj.updateView();
        end
    end
end
