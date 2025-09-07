classdef GridTest < matlab.unittest.TestCase
    % Unit tests for the Grid2D class

    methods(TestClassSetup)
        function addModelToPath(testCase)
            addpath(fullfile(pwd, '../src'));
        end
    end

    properties
        Grid
        FreePos
    end
    
    methods(TestMethodSetup)
        function createGrid(testCase)
            testCase.Grid = model.Grid2D(5, 5);
            goal = testCase.Grid.getGoal();
            if (goal(1) ~= 5)
                testCase.FreePos = [goal(1) + 1,goal(2)];
            else
                testCase.FreePos = [goal(1) - 1, goal(2)];
            end
        end
    end
    
    
    methods (Test)
        % constructor
        function testInvalidDimensions(testCase)
            % Check that constructor throws the correct error
            testCase.verifyError(@() model.Grid2D(0,0), ...
                'Grid2D:InvalidDimensions');
            testCase.verifyError(@() model.Grid2D(2,0), ...
                'Grid2D:InvalidDimensions');
            testCase.verifyError(@() model.Grid2D(-1,-1), ...
                'Grid2D:InvalidDimensions');
        end
        
        function testGridInitialization(testCase)
            rows = 10;
            cols = 15;
            g = model.Grid2D(rows, cols);
            
            cells = g.getCells();
            
            testCase.verifySize(cells, [rows cols], ...
                "Grid dimensions should match input rows/cols");
           
            map = g.getMap();
            goalStruct = map("goal");
            goalVal = goalStruct.value;
            testCase.verifyTrue(any(cells(:) == goalVal), ...
                "Grid must contain a goal");
        end

        % Getters
        function testGetRobotsEmpty(testCase)
            testCase.verifyEmpty(testCase.Grid.getRobots());
        end

        function testGetCellsSize(testCase)
            cells = testCase.Grid.getCells();
            testCase.verifyEqual(size(cells), [5, 5]);
        end

        function testGetMap(testCase)
            KeySet = {'goal', 'mud', 'water', 'coin', 'food', 'pit'};
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
            'marker','o', 'size',14, 'label','Pit', 'type','negative')};
            map = testCase.Grid.getMap();
            testCase.verifyEqual(map, containers.Map(KeySet,ValueSet));
        end

        % test add and remove robots
        function testAddRobot(testCase)
            robotsInitial = testCase.Grid.getRobots();
            testCase.verifyEqual(numel(robotsInitial), 0);

            r = robot.BasicRobot([1,1], 2);
            testCase.Grid = testCase.Grid.addRobot(r);
            robots = testCase.Grid.getRobots();
            testCase.verifyEqual(numel(robots), 1);
            testCase.verifyEqual(robots(1).getPosn(), [1 1]);
        end

        function testAddRobotOutOfBounds(testCase)
            r1 = robot.BasicRobot([5, 6], 1);
            testCase.verifyError(@() testCase.Grid.addRobot(r1), ...
                'Grid2D:OutOfBounds');
        end

        function testAddOverlappingRobot(testCase)
            r1 = robot.BasicRobot([2 2], 3);
            r2 = robot.BasicRobot([2 2], 1);
            testCase.Grid = testCase.Grid.addRobot(r1);
            testCase.verifyError(@() testCase.Grid.addRobot(r2), ...
                'Grid2D:OverlappingRobot');
        end

        function testRemoveRobot(testCase)
            r = robot.BasicRobot([3 3], 1);
            r2 = robot.BasicRobot([2, 1], 1);
            testCase.Grid = testCase.Grid.addRobot(r);
            testCase.Grid = testCase.Grid.addRobot(r2);
            testCase.Grid = testCase.Grid.removeRobot([3 3]);
            testCase.verifyEqual(numel(testCase.Grid.getRobots()), 1);
            testCase.Grid = testCase.Grid.removeRobot([2, 1]);
            testCase.verifyEmpty(testCase.Grid.getRobots());
        end

        function testRemoveRobotEmptyCell(testCase)
            testCase.verifyWarning(@() testCase.Grid.removeRobot([4 4]), ...
                'Grid2D:Warn');
        end

        function testRemoveRobotOutOfBounds(testCase)
            testCase.verifyError(@() testCase.Grid.removeRobot([0 1]), ...
                'Grid2D:OutOfBounds');
            testCase.verifyError(@() testCase.Grid.removeRobot([1 6]), ...
                'Grid2D:OutOfBounds');
        end

        % add and remove item
        function testAddItem(testCase)
            g = model.Grid2D(5,5);
            val = 400;
            pos = testCase.FreePos;
            g = g.addItem(pos,"coin");
            
            cells = g.getCells();
            testCase.verifyEqual(cells(pos(1),pos(2)), val, ...
                "Item should be placed in correct location");
        end
        
        function testAddItemOnOccupiedCell(testCase)
            g = model.Grid2D(5,5);
            g = g.addItem(testCase.FreePos, "coin");
            
            testCase.verifyError(@() g.addItem(testCase.FreePos, "water"), ...
                'Grid2D:OccupiedSpace');
        end

        function testAddItemOnGoal(testCase)
            goal = testCase.Grid.getGoal();
            testCase.verifyError(@() testCase.Grid.addItem(goal, "food"), ...
                'Grid2D:OccupiedSpace');
        end

        function testAddItemOutOfBounds(testCase)
            testCase.verifyError(@() testCase.Grid.addItem([1 6], "pit"), ...
                'Grid2D:OutOfBounds');
        end

        function testRemoveItem(testCase)
            testCase.Grid = testCase.Grid.addItem(testCase.FreePos, "coin");
            cells = testCase.Grid.getCells();
            testCase.verifyEqual(cells(testCase.FreePos(1), ...
                testCase.FreePos(2)), 400);
            

            testCase.Grid = testCase.Grid.removeItem(testCase.FreePos);
            cells = testCase.Grid.getCells();
            testCase.verifyEqual(cells(testCase.FreePos(1), ...
                testCase.FreePos(2)), 0);
        end

        function testRemoveItemEmptyCell(testCase)
            testCase.verifyWarning(@() testCase.Grid.removeItem(testCase.FreePos), ...
                'Grid2D:Warn');
        end

        function testRemoveItemGoal(testCase)
            testCase.verifyWarning(@() testCase.Grid.removeItem(testCase.Grid.getGoal()), ...
                'Grid2D:Warn');
        end

        function testRemoveItemOutOfBounds(testCase)
            testCase.verifyError(@() testCase.Grid.removeItem([6 1]), ...
                'Grid2D:OutOfBounds');
        end

        %test foundend
        function testFoundEndNoRobots(testCase)
            testCase.verifyTrue(testCase.Grid.foundEnd());
        end

        function testFoundEndRobotsNone(testCase)
            r1 = robot.BasicRobot([1 1], 2);
            r2 = robot.BasicRobot([2 2], 1);
            testCase.Grid = testCase.Grid.addRobot(r1);
            testCase.Grid = testCase.Grid.addRobot(r2);
            testCase.verifyFalse(testCase.Grid.foundEnd());
        end

        function testFoundEndRobots(testCase)
            goal = testCase.Grid.getGoal();
            r1 = robot.BasicRobot(goal, 2);
            testCase.Grid = testCase.Grid.addRobot(r1);
            testCase.verifyTrue(testCase.Grid.foundEnd());

            r2 = robot.BasicRobot([2, 3], 2);
            testCase.Grid = testCase.Grid.addRobot(r2);
            testCase.verifyFalse(testCase.Grid.foundEnd());
        end

        function testCanMove(testCase)
            testCase.verifyFalse(testCase.Grid.canMove([1, 6]))
            testCase.verifyFalse(testCase.Grid.canMove([-1, 5]))
            testCase.verifyTrue(testCase.Grid.canMove([1, 5]))
            testCase.verifyTrue(testCase.Grid.canMove([2, 2]))
            testCase.verifyFalse(testCase.Grid.canMove([0, 6]))

            r1 = robot.BasicRobot([2, 3], 1);
            testCase.Grid.addRobot(r1);
            testCase.verifyFalse(testCase.Grid.canMove([2, 3]))
        end

        % TODO : test move
        % TODO : add tests for start and the algorithm

    end
end
