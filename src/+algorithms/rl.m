classdef rl
    %RL Reinforcement learning algorithm for the robots path finding
    % algorithm
    
    properties(Access = private)
        ModelGrid
        Q
        alpha = 0.1
        gamma = 0.9
        epsilon = 0.3
        Actions
        Observers
    end
    
    methods
        function obj = rl(grid)
            % Initial constructor for the Reinforcement Learning algorithm
            % given a grid
            obj.ModelGrid = grid;
            obj.Actions = {[-1 0], [1 0], [0 -1], [0 1]};
            numStates = numel(grid.getCells());
            numActions = numel(obj.Actions);
            obj.Q = zeros(numStates, numActions);
            obj.Observers = {};
        end

        function q = getQ(obj)
            % Gets Q
            q = obj.Q;
        end

        function obj = addObserver(obj, callback)
            % Register a new observer callback
            if isempty(obj.Observers)
                obj.Observers = {callback};
            else
                obj.Observers{end+1} = callback;
            end
        end
    
        function notifyObservers(obj, data)
            % Call all registered observers with event data
            if ~isempty(obj.Observers)
                for i = 1:numel(obj.Observers)
                    obj.Observers{i}(data);
                end
            end
        end

        function [obj, totalReward] = trainEpisode(obj, maxSteps)
            % Trains one episode of the reinforcement learning
            obj.ModelGrid.reset();
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
       
                    numActions = numel(obj.Actions);
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

                    eventData = struct( ...
                        'type', 'step', ...
                        'state', state, ...
                        'action', actionIdx, ...
                        'reward', reward, ...
                        'newState', newState ...
                    );
                    obj.notifyObservers(eventData);
        
                    if done
                        doneFlags(r) = true;
                    end
                end
        
                totalReward = totalReward + sum(rewards);

                episodeData = struct( ...
                    'type', 'episode', ...
                    'totalReward', totalReward ...
                );
                obj.notifyObservers(episodeData);

        
                if all(doneFlags)
                    break;
                end
            end
        end

        function [reward, done] = step(obj, robotIdx, action)
            % does one step for the reinforcement learning and returns
            % the reward and whether the step results in a done move
            dir = obj.Actions{action};

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
            % encodes the state
            s = sub2ind(size(obj.ModelGrid.getCells()), posn(1), posn(2));
        end

        function reward = getReward(obj, posn)
            % gets the reward at a given posn, -1 if there is nothing 
            % there to punish for taking longer
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

