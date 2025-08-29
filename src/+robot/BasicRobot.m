classdef BasicRobot < AbsRobot
    %ROBOT A robot that can move in the 4 directions, up, down, left, right
    %It has a position and a speed
    
    properties
        Posn
        Speed
    end
    
    methods
        function obj = BasicRobot(startPosn,speed)
            %ROBOT Construct an instance of this class
            %   given a start position and speed, creates a robot
            obj.Posn = startPosn;
            obj.Speed = speed;
        end
        
        function obj = move(obj, dir, obstacles, bounds)
            %METHOD1 moves the robot in the given direction by the speed
            %of this robot if the obstacles allows it
            %   Detailed explanation goes here
            
        end
    end
end

