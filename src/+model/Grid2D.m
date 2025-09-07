classdef Grid2D < model.AbsGrid
    % Represents a Grid that has obstacle, rewards and blank values
    % arranged in a 2D grid with robots also placed on the grid
    % the goal of each robot is to accumulate the most amount of points
    
    properties (Access = private, Constant)
        KeySet = {'goal', 'mud', 'water', 'coin', 'food', 'pit'}
        ValueSet = {struct('value', 1000, 'color',[0,1,0], 'marker','s', ...
            'size', 14, 'label','Goal', 'type','positive'), ...
            struct('value', -200, 'color',[0.4,0.2,0], ...
            'marker','o', 'size',12, 'label','Mud', 'type','negative'), ...
            struct('value', -300, 'color',[0,0,1], ...
            'marker','o', 'size',12, 'label','Water', 'type','negative'), ...
            struct('value', 400, 'color',[1,0.84,0], ...
            'marker','o', 'size',10, 'label','Coin', 'type','positive'), ...
            struct('value', 200, 'color',[1,0.5,0],  ...
            'marker','o', 'size',10, 'label','Food', 'type','positive'), ...
            struct('value', -10000, 'color',[0,0,0], ...
            'marker','o', 'size',14, 'label','Pit', 'type','negative')}
    end

    properties(Access = private)
        ItemMap
        Goal %[row, col]
        Cells
        Robots
        Occupied
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
            if rows < 1 || cols < 1
                error('Grid2D:InvalidDimensions', ...
                    "grid dimensions must be a positive integer")
            end
            obj.ItemMap = containers.Map(obj.KeySet, obj.ValueSet);
            obj.Goal = [randi(rows), randi(cols)];
            obj.Cells = zeros(rows,cols);
            % randomly place a goal location
            valStruct = obj.ItemMap('goal');
            obj.Cells(obj.Goal(1), obj.Goal(2)) = valStruct.value;
            obj.Robots = [];
            obj.Occupied = zeros(rows, cols);
        end

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

        function goal = getGoal(obj)
            goal = obj.Goal;
        end

        function obj = addRobot(obj, r)
            %Adds a robot into the grid by adding the robot to the list of 
            %robots and marks the cells as occupied in the occupy matrix
            [rows, cols] = size(obj.Occupied);
            robotPos = r.getPosn();
            if robotPos(1)<1 || robotPos(1)>rows ...
                    || robotPos(2)<1 || robotPos(2)>cols
                    error('Grid2D:OutOfBounds', ...
                        'Robot can not be placed out of bounds')
            elseif obj.Occupied(robotPos(1), robotPos(2)) == 1
                error('Grid2D:OverlappingRobot', ...
                    'Robot is already present here')
            else
                obj.Robots = [obj.Robots, r];
                obj.Occupied(robotPos(1), robotPos(2)) = 1;
            end
        end

        function obj = removeRobot(obj, posn)
            % removes the robot at a given position in the grid if such
            % robot exists.
            [rows, cols] = size(obj.Cells);
            if posn(1)<1 || posn(1)>rows || posn(2)<1 || posn(2)>cols
                error('Grid2D:OutOfBounds', 'Position is out of bounds')
            end

            if obj.Occupied(posn(1), posn(2)) == 0
                warning('Grid2D:Warn', 'No robot in selected position')
                return
            end

            obj.Occupied(posn(1), posn(2)) = 0;
            idx = arrayfun(@(r) isequal(r.getPosn(), posn), obj.Robots);
            obj.Robots(idx) = [];
        end

        function obj = addItem(obj, posn, itemName)
            %place item onto the grid of cells if there is not something
            %already there given the item value
            %where posn is [row,col] coordinate of the target item placement
            [rows, cols] = size(obj.Cells);
            if ~isKey(obj.ItemMap, itemName)
                error('Grid2D:InvalidInput', 'Unknown item type')
            end

            itemStruct = obj.ItemMap(itemName);
            itmValue = itemStruct.value;

            if posn(1)<1 || posn(1)>rows || posn(2)<1 || posn(2)>cols
                error('Grid2D:OutOfBounds', 'Position is out of bounds')
            end

            if (itmValue == obj.ItemMap("goal").value)
                error('Grid2D:InvalidInput', 'Can not add an additional goal')
            end

            if obj.Cells(posn(1), posn(2)) == 0
                obj.Cells(posn(1), posn(2)) = itmValue;
            else
                error('Grid2D:OccupiedSpace', 'Cell already occupied')
            end
        end

       function obj = removeItem(obj, posn)
           % removes the item at a specific position on the grid
           % if that cell is not empty
            [rows, cols] = size(obj.Cells);
            if posn(1)<1 || posn(1)>rows || posn(2)<1 || posn(2)>cols
                error('Grid2D:OutOfBounds', 'Position is out of bounds')
            end

            if obj.Cells(posn(1), posn(2)) == 0
                warning('Grid2D:Warn', 'No item in selected position')
            end

            if obj.Cells(posn(1), posn(2)) == obj.ItemMap('goal').value
                warning('Grid2D:Warn', 'Can not remove the goal')
            end

            obj.Cells(posn(1), posn(2)) = 0;
        end

        function obj = start(obj, algorithm)
            %Starts a given algorithm on the conditions of this grid
            % TODO : IMPLEMENT
            play = true;
            while(play)
                algorithm.next(obj)
                if obj.foundEnd()
                    play = false;
                end
            end
        end

        function move(obj, robotIdx, dir)
            robot = obj.Robots(robotIdx);
            obj.Occupied = robot.move(dir, obj.Occupied);
        end

        function bool = foundEnd(obj)
            % Determines whether all robots have reached the goal
            bool = all(arrayfun(@(r) isequal(r.getPosn(), obj.Goal), ...
                obj.Robots));
        end

        function bool = canMove(obj, posn)
            % Is the given posn in the bounds of this grid?
            [rows, cols] = size(obj.Cells);
            inBounds = posn(1)>=1 && posn(1)<=rows && posn(2)>=1 && posn(2)<=cols;
            bool = inBounds && obj.Occupied(posn(1), posn(2)) == 0;
        end
    end

end

