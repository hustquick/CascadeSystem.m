classdef Temperature < handle
    %Temperature This class is defined to make temperature a handle class
    
    properties
        v;  % Value of Temperature, K
    end
    
    methods
        function obj = Temperature(v)
            if nargin ==0
            else
                obj.v = v;
            end
        end
    end
    
end

