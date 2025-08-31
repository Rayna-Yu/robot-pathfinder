classdef (Abstract) AbsGrid
    %ABSGRID Summary of this class goes here
    %   Detailed explanation goes here
    methods
        getRobots(obj)
        getCells(obj)
        getMap(obj)
        addRobot(obj, robot)
        removeRobot(obj, posn)
        addItem(obj, posn, itemValue)
        removeItem(obj, posn)
        start(obj, algorithm)
        foundEnd(obj)
    end
end

