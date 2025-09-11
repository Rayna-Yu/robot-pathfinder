classdef (Abstract) AbsRobot < handle
    %AbsRobot A robot class that can move in a direction given the rules of
    %the concrete class and the obstacles present on the grid
    %   Detailed explanation goes here
    methods (Abstract)
        move(obj, dir, cells)
        getPosn(obj)
        updatePosn(obj, posn)
    end
end

