classdef Deaerator < handle
    %Deaerator This class describes the deaerator
    
    properties
        p;
        st_i_1;
        st_i_2;
        st_o;
        q_m
    end
    properties(Dependent)
%         st_o;
    end
    
    methods
        function obj = Deaerator
           obj.st_i_1 = Stream;
           obj.st_i_2 = Stream;
           obj.st_o = Stream;
        end
    end
    methods
        function work(obj)
            obj.st_o.fluid = obj.st_i_1.fluid;
            obj.st_o.p = obj.p;
            obj.st_o.x = 0;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'P', obj.st_o.p, 'Q', ...
                obj.st_o.x, obj.st_o.fluid);
            obj.st_o.q_m.v = obj.st_i_1.q_m.v + obj.st_i_2.q_m.v;
        end
        function value = get.q_m(obj)
            value = Q_m;
            value.v = (obj.st_i_1.h .* obj.st_i_1.q_m.v + ...
                obj.st_i_2.h .* obj.st_i_2.q_m.v) ./ obj.st_o.h;
        end
    end
    
end