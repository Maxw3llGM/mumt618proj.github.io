classdef delayL
    properties
        inpointer  = 1
        outpointer = 1
        delayLine  (1,:) 
        M
        delay
        delta
    end
    methods
        function obj = delayL(Mval)
            if nargin == 1
                obj.M = Mval;
                obj.delay = floor(obj.M) + 2;
                obj.delta = obj.M - obj.delay;
                obj.delayLine = zeros(1,obj.delay);

                obj.inpointer = 1;
                obj.outpointer = obj.inpointer - floor(obj.M);
                if obj.outpointer <= 0
                    obj.outpointer = obj.outpointer + obj.delay;
                end
            end
        end
        function obj = setDelay(delaylength)
            obj.outpointer = obj.inpointer - delaylength;
            
        end


    end

end