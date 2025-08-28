classdef Grid2D < AbsGrid
    % Represents a Grid a plain grid that has obstacles and robots
    
    properties(Access = private)
        Cells
        Obstacles
        Rewards
        Robots
        size
    end
    
    methods
        function obj = Grid2D(x,y)
            %GRID Construct an instance of this class
            %   Creates an empty grid given the x dimension 
            % and y dimension
            % randomly generates different types of obstacles
            % randomly generates different types of rewards
            % and randomly places the given number of randomly generated
            % robots
            obj.Cells = x + y; % TODO: impl
            obj.Size = [x, y];
        end

        function robots = getRobots(obj)
            robots = obj.Robots;

        end

        function obstacles = getObstacles(obj)
            obstacles = obj.Obstacles;
        end
    end
end

