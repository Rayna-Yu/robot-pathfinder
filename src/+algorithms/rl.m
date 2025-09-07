classdef rl
    %RL Reinforcement learning algorithm for the robots path finding
    % algorithm
    
    properties(Access = private)
        ModelGrid
        Q
        alpha = 0.1
        gamma = 0.9
        epsilon = 0.2
        actions
    end
    
    methods
        function obj = rl(grid)
            obj.ModelGrid = grid;
            obj.actions = {[-1 0], [1 0], [0 -1], [0 1]};
            numStates = numel(grid.getCells());
            numActions = numel(obj.actions);
            obj.Q = zeros(numStates, numActions);
        end

        function [obj, totalReward] = trainEpisode(obj, maxSteps)
            totalReward = 0;
            robots = obj.ModelGrid.getRobots();
            numRobots = length(robots);
            doneFlags = false(1, numRobots);
        
            for step = 1:maxSteps
                rewards = zeros(1, numRobots);
        
                for r = 1:numRobots
                    if doneFlags(r)
                        continue; 
                    end
        
                    posn = robots(r).getPosn();
                    state = obj.encodeState(posn);
       
                    numActions = numel(obj.actions);
                    if rand < obj.epsilon
                        actionIdx = randi(numActions);
                    else
                        [~, actionIdx] = max(obj.Q(state, :));
                    end
        
                    [reward, done] = obj.step(r, actionIdx);

                    newPosn = robots(r).getPosn();
                    newState = obj.encodeState(newPosn);
                    obj.Q(state, actionIdx) = obj.Q(state, actionIdx) + ...
                        obj.alpha * (reward + obj.gamma * max(obj.Q(newState, :)) ...
                        - obj.Q(state, actionIdx));
        
                    rewards(r) = reward;
        
                    if done
                        doneFlags(r) = true;
                    end
                end
        
                totalReward = totalReward + sum(rewards);
        
                if all(doneFlags)
                    break;
                end
            end
        end

        function [reward, done] = step(obj, robotIdx, action)
            dir = obj.actions{action};

            try
                obj.ModelGrid.move(robotIdx, dir);
                robots = obj.ModelGrid.getRobots();
                robot = robots(robotIdx);
                posn = robot.getPosn();
                reward = obj.getReward(posn);

                map = obj.ModelGrid.getMap();
                goal = map("goal");
                done = (reward == goal.value) || reward <= map("pit").value;
            catch ME
                if any(strcmp(ME.identifier, {'Grid2D:OutOfBounds', ...
                        'Grid2D:Collision'}))
                    reward = -200;
                    done = true;
                else
                    rethrow(ME);
                end
            end
        end

        function s = encodeState(obj, posn)
            s = sub2ind(size(obj.ModelGrid.getCells()), posn(1), posn(2));
        end

        function reward = getReward(obj, posn)
            grid = obj.ModelGrid.getCells();
            val = grid(posn(1),posn(2));
            reward = 0;
            map = obj.ModelGrid.getMap();
            keys = map.keys;
            for k = 1:length(keys)
                item = map(keys{k});
                if val == item.value
                    reward = item.value;
                    return;
                end
            end

            if reward == 0
                reward = -1;
            end
        end
    end
end

