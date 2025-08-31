classdef GridTest < matlab.unittest.TestCase
    % Unit tests for the Grid2D class

    methods(TestClassSetup)
        function addModelToPath(testCase)
            addpath(fullfile(pwd, '../src'));
        end
    end

    properties
        Grid
    end
    
    methods(TestMethodSetup)
        function createGrid(testCase)
            testCase.Grid = model.Grid2D(5, 5);
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
            % create a grid and test dimensions
            rows = 10;
            cols = 15;
            g = model.Grid2D(rows, cols);
            
            cells = g.getCells();
            
            testCase.verifySize(cells, [rows cols], ...
                "Grid dimensions should match input rows/cols");
            
            % verify goal is inside grid
            map = g.getMap();
            goalVal = map("goal");
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
            KeySet = {'goal','mud','water','coins', 'food', 'wall', 'pit'};
            ValueSet = [100, -5, -7, 10, 3, -inf, -500];
            map = testCase.Grid.getMap();
            testCase.verifyEqual(map, containers.Map(KeySet,ValueSet));
        end
        
        % functions
        function testAddItem(testCase)
            g = model.Grid2D(5,5);
            pos = [2,3];
            val = 10;
            g = g.addItem(pos,val);
            
            cells = g.getCells();
            testCase.verifyEqual(cells(pos(1),pos(2)), val, ...
                "Item should be placed in correct location");
        end
        
        function testAddItemOnOccupiedCell(testCase)
            g = model.Grid2D(5,5);
            pos = [3,2];
            g = g.addItem(pos, 10);
            
            % Try to add another item at same pos (should trigger warning)
            testCase.verifyError(@() g.addItem(pos, -7), ...
                'Grid2D:OccupiedSpace', ...
                "Should warn if cell already occupied");
        end

        function testAddRobot(testCase)
            robotsInitial = testCase.Grid.getRobots();
            testCase.verifyEqual(numel(robotsInitial), 0);

            r = robot.BasicRobot([1,1], 2);
            testCase.Grid = testCase.Grid.addRobots(r);
            robots = testCase.Grid.getRobots();
            testCase.verifyEqual(numel(robots), 1);
            testCase.verifyEqual(robots(1).getPosn(), [1 1]);
        end

        function testAddRobotOutOfBounds(testCase)
            r1 = robot.BasicRobot([5, 6], 1);
            testCase.verifyError(@() testCase.Grid.addRobots(r1), ...
                'Grid2D:OutOfBounds');
        end

        function testAddOverlappingRobot(testCase)
            r1 = robot.BasicRobot([2 2], 3);
            r2 = robot.BasicRobot([2 2], 1);
            testCase.Grid = testCase.Grid.addRobots(r1);
            testCase.verifyError(@() testCase.Grid.addRobots(r2), ...
                'Grid2D:OverlappingRobot');
        end
        
    end
end
