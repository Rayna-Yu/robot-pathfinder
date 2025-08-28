classdef (Abstract) AbsObstacle
    %OBSTACLE An obstacle a robot can bump into or go into on a grid
    methods (Abstract)
        overlaps(obj, itm)
        moveOnTo(obj, itm)
    end
end

