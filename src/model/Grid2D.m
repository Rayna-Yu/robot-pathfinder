classdef Grid2D < AbsGrid
    % Represents a Grid that has obstacle, rewards and blank values
    % arranged in a 2D grid with robots also placed on the grid
    % the goal of each robot is to accumulate the most amount of points
    
    properties(Access = private, Constant)
        KeySet = {'goal','mud','water','coins', 'food', 'wall', 'pit'};
        ValueSet = [100, -5, -7, 10, 3, -inf, -500];
        ItemMap = containers.Map(keySet,valueSet
    end

    properties(Access = private)
        Goal %[row, col]
        Cells
        Robots
    end
    
    methods
        function obj = Grid2D(rows,cols)
            %GRID Construct an instance of this class
            %   Creates an empty grid given the x dimension 
            % and y dimension
            % randomly generates different types of obstacles
            % randomly generates different types of rewards
            % and randomly places the given number of randomly generated
            % robots
            obj.Goal = [randi(rows), randi(cols)];
            obj.Cells = zeros(rows,cols);
            % randomly place a goal location
            obj.Cells(obj.Goal(1), obj.Goal(2)) = ItemMap.get("goal");
            obj.Robots = [];
        end

        % TODO : GOTTA RETURN COPIES
        function robots = getRobots(obj)
            %Returns a copy of all the robots present in this grid
            robots = obj.Robots;

        end

        function cells = getCells(obj)
            %Returns a copy of the cells of this grid
            cells = obj.Cells;
        end

        function map = getMap(obj)
            %Returns a copy of the item map of this grid
            map = obj.ItemMap;
        end

        function obj = addRobots(obj, robot)
            %Adds a robot into the grid by adding the robot to the list of 
            %robots
            if any(arrayfun(arrayfun(@(r) r.on(robot.getPosn()), ...
                    obj.Robots)))
                warning('Robot is already present here')
            else
                obj.Robots(end+1) = robot;
            end
        end

        function obj = addItem(obj, posn, itmValue)
            %place item onto the grid of cells if there is not something
            %already there given the item value
            %where posn is [row,col] coordinate of the target item placement
            target = obj.Cells(posn(1), posn(2));
            if target == 0
                obj.Cells(posn(1), posn(2)) = itmValue;
            else
                warning('Cell already occupied')
            end
        end

        function obj = start(obj, algorithm)
            %Starts a given algorithm on the conditions of this grid
            play = true;
            while(play)
                algorithm.next(obj)
                if obj.goalReached()
                    play = false;
                end
            end
        end
    end

    methods(Access = private)
        % determines whether the path finding is done by determining
        % whether all robots have reached the goal
        function done = goalReached(obj)
            done = all(arrayfun(arrayfun(@(r) r.on(obj.Goal), ...
                obj.Robots)));
        end
    end
end

