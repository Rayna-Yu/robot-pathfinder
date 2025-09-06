classdef RobotTest < matlab.unittest.TestCase
    methods(TestClassSetup)
        function addModelToPath(testCase)
            addpath(fullfile(pwd, '../src'));
        end
    end

    methods (Test)
        
        function testConstructor(testCase)
            r = robot.BasicRobot([2 3], 1);
            testCase.verifyEqual(r.getPosn(), [2 3], ...
                "Initial position incorrect");
            testCase.verifyEqual(r.Speed, 1, ...
                "Speed not set correctly");
        end
        
        % test getter
        function testGetPosn(testCase)
            r = robot.BasicRobot([5 5], 2);
            testCase.verifyEqual(r.getPosn(), [5 5]);
        end
        
        % test move
        function testMoveUp(testCase)
            occupied = zeros(5,5);
            occupied(3,3) = 1;
            r = robot.BasicRobot([3 3], 1);
            
            occupied = r.move([-1 0], occupied); % move up
            testCase.verifyEqual(r.getPosn(), [2 3]);
            testCase.verifyEqual(occupied(2,3), 1);
            testCase.verifyEqual(occupied(3,3), 0);
        end
        
        function testMoveDown(testCase)
            occupied = zeros(5,5);
            occupied(2,3) = 1;
            r = robot.BasicRobot([2 3], 1);
            
            occupied = r.move([1 0], occupied); % move down
            testCase.verifyEqual(r.getPosn(), [3 3]);
            testCase.verifyEqual(occupied(3,3), 1);
            testCase.verifyEqual(occupied(2,3), 0);
        end
        
        function testMoveLeft(testCase)
            occupied = zeros(5,5);
            occupied(3,3) = 1;
            r = robot.BasicRobot([3 3], 1);
            
            occupied = r.move([0 -1], occupied); % move left
            testCase.verifyEqual(r.getPosn(), [3 2]);
            testCase.verifyEqual(occupied(3,2), 1);
            testCase.verifyEqual(occupied(3,3), 0);
        end
        
        function testMoveRight(testCase)
            occupied = zeros(5,5);
            occupied(3,3) = 1;
            r = robot.BasicRobot([3 3], 1);
            
            occupied = r.move([0 1], occupied); % move right
            testCase.verifyEqual(r.getPosn(), [3 4]);
            testCase.verifyEqual(occupied(3,4), 1);
            testCase.verifyEqual(occupied(3,3), 0);
        end
        
        function testBlockedMove(testCase)
            occupied = zeros(5,5);
            occupied(3,3) = 1;
            occupied(2,3) = 1; 
            r = robot.BasicRobot([3 3], 1);
            
            occupied = r.move([-1 0], occupied);
            testCase.verifyEqual(r.getPosn(), [3 3]);
            testCase.verifyEqual(occupied(3,3), 1);
        end
        
        function testOutOfBoundsThrowsError(testCase)
            occupied = zeros(5,5);
            occupied(1,3) = 1;
            r = robot.BasicRobot([1 3], 1);
            
            testCase.verifyError(@() r.move([-1 0], occupied), ...
                'Grid2D:OutOfBounds');
        end
        
        function testSpeedGreaterThanOne(testCase)
            occupied = zeros(5,5);
            occupied(2,2) = 1;
            r = robot.BasicRobot([2 2], 2);
            
            occupied = r.move([0 1], occupied); % move right by 2
            testCase.verifyEqual(r.getPosn(), [2 4]);
            testCase.verifyEqual(occupied(2,4), 1);
            testCase.verifyEqual(occupied(2,2), 0);
        end
        
        function testMultipleRobots(testCase)
            occupied = zeros(5,5);
            occupied(2,2) = 1;
            occupied(4,4) = 1;
            
            r1 = robot.BasicRobot([2 2], 1);
            r2 = robot.BasicRobot([4 4], 1);
            
            occupied = r1.move([1 0], occupied); % move down
            occupied = r2.move([-1 0], occupied); % move up
            
            testCase.verifyEqual(r1.getPosn(), [3 2]);
            testCase.verifyEqual(r2.getPosn(), [3 4]);
            testCase.verifyEqual(occupied(3,2), 1);
            testCase.verifyEqual(occupied(3,4), 1);
        end
    end
end
