classdef GridTest < matlab.unittest.TestCase
    % Unit tests for the Grid2D class

    methods(TestClassSetup)
        function addModelToPath(testCase)
            addpath(fullfile(pwd, '../src'));
        end
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    
    methods (Test)
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
            pos = [1,1];
            g = g.addItem(pos, 10);
            
            % Try to add another item at same pos (should trigger warning)
            testCase.verifyError(@() g.addItem(pos, -7), ...
                'Grid2D:OccupiedSpace', ...
                "Should warn if cell already occupied");
        end
        
        %TODO : gotta add tests for add robot
    end
end
