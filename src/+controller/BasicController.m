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

        function onEvent(obj, data)
            switch data.type
                case 'step'
                    obj.View.drawWorld();
                    pause(0.1);
                case 'episode'
                    x = obj.View.RewardLine.XData;
                    y = obj.View.RewardLine.YData;
        
                    x(end+1) = numel(x)+1;
                    y(end+1) = data.totalReward; 
        
                    obj.View.RewardLine.XData = x;
                    obj.View.RewardLine.YData = y;
                    drawnow;
            end
        end
        
        function onStart(obj)
            numEpisodes = 50;
            maxSteps = 200;
            algo = algorithms.rl(obj.Model);

            algo = algo.addObserver(@(data) obj.onEvent(data));
            obj.View.RewardLine.XData = [];
            obj.View.RewardLine.YData = [];
        
            for ep = 1:numEpisodes
                [algo, totalReward] = algo.trainEpisode(maxSteps);
                obj.onEvent(struct('type','episode','totalReward',totalReward));
            end
        end
        
        function onReset(obj)
            obj.Model.reset();
            obj.updateView();
        end

        function addRobot(obj, posn, speed)
            r = robot.BasicRobot(posn, speed);
            obj.Model.addRobot(r);
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
