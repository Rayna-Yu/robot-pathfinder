classdef RlTest < matlab.unittest.TestCase
    %RlTest A test suite for the reinforcement learning algorithm
    methods(TestClassSetup)
        function addModelToPath(testCase)
            addpath(fullfile(pwd, '../src'));
        end
    end
    
    properties
        Grid
        Robot1
        Robot2
        Agent
    end

    methods(TestMethodSetup)
        function createGridAndAgents(testCase)
            testCase.Grid = model.Grid2D(5, 5);
            testCase.Robot1 = robot.BasicRobot([1, 1], 1);
            testCase.Robot2 = robot.BasicRobot([5, 5], 1);
            testCase.Grid = testCase.Grid.addRobot(testCase.Robot1);
            testCase.Grid = testCase.Grid.addRobot(testCase.Robot2);
            testCase.Grid.captureInitial();
            testCase.Agent = algorithms.rl(testCase.Grid);
        end
    end

    methods(Test)
        function testQInitialization(testCase)
            cells = testCase.Grid.getCells();
            numStates = numel(cells);
            numActions = 4;
            testCase.verifySize(testCase.Agent.getQ(), ...
                [numStates, numActions]);
        end

        function testStepRewardGoal(testCase)
            % Move Robot1 directly to goal
            goalPos = testCase.Grid.getGoal();
            if (goalPos(2) < 5)
                startPos = goalPos + [0, 1];
                actionIdx = 3;
            else
                startPos = goalPos + [0, -1];
                actionIdx = 4;
            end
            robotGoal = robot.BasicRobot([startPos(1), startPos(2)], 1);
            testCase.Grid = testCase.Grid.addRobot(robotGoal);
            
            [reward, done] = testCase.Agent.step(3, actionIdx);

            testCase.verifyEqual(done, true);
            map = testCase.Grid.getMap();
            testCase.verifyEqual(reward, map('goal').value);
        end

        function testStepRewardPit(testCase)
            % Place a pit at Robot1's position
            testCase.Grid = testCase.Grid.addItem([2, 1],'pit');
            [reward, done] = testCase.Agent.step(1, 2);
            testCase.verifyTrue(done);
            map = testCase.Grid.getMap();
            testCase.verifyEqual(reward, map('pit').value);
        end

        function testTrainEpisodeUpdatesQ(testCase)
            initialQ = testCase.Agent.getQ();
            
            [testCase.Agent, totalReward] = testCase.Agent.trainEpisode(10);
            
            testCase.verifyTrue(isnumeric(totalReward));
            testCase.verifyNotEqual(totalReward, 0, ...
                'Total reward should reflect some learning');
            
            updatedQ = testCase.Agent.getQ();
            testCase.verifyNotEqual(initialQ, updatedQ, ...
                'Q-table should be updated after training');

            testCase.verifyTrue(any(abs(updatedQ(:) - initialQ(:)) > 1e-6), ...
                'Some Q-values should change after training');
        end

        function testTrainEpisodeLearningImprovement(testCase)
            totalRewards = zeros(1,10);
            for ep = 1:10
                [testCase.Agent, totalRewards(ep)] = testCase.Agent.trainEpisode(50);
            end

            testCase.verifyGreaterThan(max(totalRewards), 0, ...
                'Agent should accumulate positive rewards after multiple episodes');
        end

    end
end
