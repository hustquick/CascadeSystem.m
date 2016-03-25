classdef Pump < handle
    %Pump This class describe pumps
    
    properties(Constant)
        eta = 0.85;     % Isentropic efficiency
    end
    properties
        st1;            % Inlet flow stream
        p;              % outlet pressure, Pa
    end
    properties(Dependent)
        st2;
    end
    
    methods
        function obj = Pump
            obj.st1 = Stream;
        end
    end
    methods
        function value = get.st2(obj)
%             obj.st1.h = CoolProp.PropsSI('H', 'T', obj.st1.T.v, 'P', ...
%                 obj.st1.p, obj.st1.fluid);
%             obj.st1.s = CoolProp.PropsSI('S', 'T', obj.st1.T.v, 'P', ...
%                 obj.st1.p, obj.st1.fluid);
            value = Stream;
            value.fluid = obj.st1.fluid;
            value.p = obj.p;
            s_i = obj.st1.s;
            h_i = CoolProp.PropsSI('H', 'S', s_i, 'P', value.p, value.fluid);
            value.h = obj.st1.h + (h_i - obj.st1.h) ./ obj.eta;
            value.T.v = CoolProp.PropsSI('T', 'H', value.h, ...
                'P', value.p, value.fluid);
        end
    end
    
end

