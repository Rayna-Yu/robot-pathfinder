classdef BasicRobot < robot.AbsRobot
    %ROBOT A robot that can move in the 4 directions, up, down, left, right
    %It has a position and a speed and an algorithm in which it tries
    %finding its path for
    
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
        
        function occupied = move(obj, dir, occupied)
            %moves the robot in the given direction by the speed
            %of this robot if the occupied matrix allows it
            %   where dir is a direction vector and occupied is the matrix
            % of occupied spaces by robots
            newPos = obj.Posn + (dir * obj.Speed);
            [rows, cols] = size(occupied);
            if newPos(1)<1 || newPos(1)>rows || newPos(2)<1 || newPos(2)>cols
                error('Grid2D:OutOfBounds', 'Robot out of bounds')
            end

            if occupied(newPos(1), newPos(2)) == 0
                occupied(obj.Posn(1), obj.Posn(2)) = 0;
                occupied(newPos(1), newPos(2)) = 1;
                obj.Posn = newPos;
            else
                error('Grid2D:Collision', 'Robots can not collide')
            end
        end

        function posn = getPosn(obj)
            %gets the position of the robot
            posn = obj.Posn;
        end

        function updatePosn(obj, posn)
            % forces an update on the position of the robot
            obj.Posn = posn;
        end
    end
end

