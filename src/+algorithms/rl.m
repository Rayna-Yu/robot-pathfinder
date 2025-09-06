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
            obj.actions = [0 1; 0 -1; 1 0; -1 0];
            numStates = numel(grid.getCells());
            numActions = size(obj.actions, 1);
            obj.Q = zeros(numStates, numActions);
        end

        function [obj, totalReward] = trainEpisode(obj, maxSteps)
            totalReward = 0;
            robots = obj.ModelGrid.getRobots();

            for step = 1:maxSteps
                moves = zeros(length(robots), 2);
                rewards = zeros(1, length(robots));

                for r = 1:length(robots)
                    pos = robots(r).getPosn();
                    state = obj.encodeState(pos);

                    if rand < obj.epsilon
                        actionIdx = randi(size(obj.actions, 1));
                    else
                        [~, actionIdx] = max(obj.Q(state, :));
                    end

                    move = obj.actions(actionIdx, :);
                    newPos = pos + move;

                    if ~obj.ModelGrid.canMove(newPos)
                        rewards(r) = -100;
                        moves(r,:) = [0 0];
                        newPos = pos;
                    else
                        rewards(r) = obj.getReward(newPos);
                        moves(r,:) = move;
                    end

                    newState = obj.encodeState(newPos);
                    obj.Q(state, actionIdx) = obj.Q(state, actionIdx) + ...
                        obj.alpha*(rewards(r) + obj.gamma*max(obj.Q(newState, :)) ...
                        - obj.Q(state, actionIdx));
                end

                for r = 1:length(robots)
                    if any(moves(r,:))
                        obj.ModelGrid.move(r, moves(r,:));
                    end
                end

                totalReward = totalReward + sum(rewards);

                if obj.ModelGrid.foundEnd()
                    break;
                end
            end
        end

        function [reward, done] = step(obj, robotIdx, action)
            dir = obj.actions(action, :);

            try
                obj.ModelGrid = obj.ModelGrid.move(robotIdx, dir);
                pos = robot.getPosn();
                cells = obj.ModelGrid.getCells();
                reward = cells(pos(1), pos(2));

                map = obj.ModelGrid.getMap();
                goal = map("goal");
                done = (reward == goal.value);
            catch ME
                if strcmp(ME.identifier, 'Grid2D:OutOfBounds')
                    reward = -100; % punish hitting wall
                    done = true;
                else
                    rethrow(ME);
                end
            end
        end

        function s = encodeState(obj, pos)
            s = sub2ind(size(obj.ModelGrid.getCells()), pos(1), pos(2));
        end

        function reward = getReward(obj, pos)
            grid = obj.ModelGrid.getCells();
            val = grid(pos(1),pos(2));
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
        end
    end
end

