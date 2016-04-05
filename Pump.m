classdef Pump < handle
    %Pump This class describe pumps
    
    properties(Constant)
        eta = 0.85;     % Isentropic efficiency
    end
    properties
        st_i;            % Inlet flow stream
        st_o;           % Outlet flow stream
        p;              % outlet pressure, Pa
    end
    properties(Dependent)
        
    end
    
    methods
        function obj = Pump
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
    end
    methods
        function work(obj)
            obj.st_o.fluid = obj.st_i.fluid;
            obj.st_o.p = obj.p;
            s_i = obj.st_i.s;
            h_i = CoolProp.PropsSI('H', 'S', s_i, 'P', obj.st_o.p, obj.st_o.fluid);
            h = obj.st_i.h + (h_i - obj.st_i.h) ./ obj.eta;
            obj.st_o.q_m = obj.st_i.q_m;
            obj.st_o.T.v = CoolProp.PropsSI('T', 'H', h, ...
                'P', obj.st_o.p, obj.st_o.fluid);
        end
    end
    
end

