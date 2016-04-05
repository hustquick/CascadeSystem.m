classdef Condenser < handle
    %Condensor This class describes condensor
    
    properties
        st_i;
        st_o;
    end
    properties(Dependent)
    end
    
    methods
        function obj = Condenser
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
    end
    methods
%         function value = get.st2(obj)
%             value = Stream;
%             value.fluid = obj.st1.fluid;
%             value.q_m.v = obj.st1.q_m.v;
%             value.p = obj.st1.p;
%             value.x = 0;
%             value.T.v = CoolProp.PropsSI('T', 'P', value.p, 'Q', ...
%                 value.x, value.fluid);
%         end
        function work(obj)
            obj.st_o.fluid = obj.st_i.fluid;
            obj.st_o.q_m = obj.st_i.q_m;
            obj.st_o.p = obj.st_i.p;
            obj.st_o.x = 0;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'P', obj.st_o.p, 'Q', ...
                obj.st_o.x, obj.st_o.fluid);
        end
    end
    
end