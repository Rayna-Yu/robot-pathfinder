classdef ReadOnly2D
    %READONLY2D A read only class for the Grid2d class. So it only has
    % the functions that read but don't modify
    
    properties(Access = private)
        Grid
    end
    
    methods
        function obj = ReadOnly2D(model)
            %READONLY2D wraps a model so that it can only be read
            obj.Grid = model;
        end
    end

    methods
        function robots = getRobots(obj)
            %Returns a copy of all the robots present in this grid
            robots = obj.Grid.getRobots();

        end

        function cells = getCells(obj)
            %Returns a copy of the cells of this grid
            cells = obj.Grid.getCells();
        end

        function map = getMap(obj)
            %Returns a copy of the item map of this grid
            map = obj.Grid.getMap();
        end

        function goal = getGoal(obj)
            %Returns the goal of a grid
            goal = obj.Grid.getGoal();
        end
    end
end

