classdef Preheater < handle
    %Preheater 
    
    properties
        st1_i;
        st1_o;
        st2_i;
        st2_o;
        Delta_T = 15;
    end
    properties(Dependent)
        
    end
    
    methods
        function obj = Preheater
            obj.st1_i = Stream;
            obj.st2_i = Stream;
            obj.st1_o = Stream;
            obj.st2_o = Stream;
        end
    end
    methods
        function calculate(obj)
            obj.st1_o.fluid = obj.st1_i.fluid;
            obj.st1_o.p = obj.st1_i.p;
            obj.st1_o.q_m = obj.st1_i.q_m;
            obj.st1_o.x = 0;
            obj.st1_o.T.v = CoolProp.PropsSI('T', 'P', obj.st1_o.p, ...
                'Q', obj.st1_o.x, obj.st1_o.fluid);
            
            obj.st2_i.T.v = obj.st1_o.T.v + obj.Delta_T;
            obj.st2_i.p = obj.st2_o.p;
            obj.st2_i.fluid = obj.st2_o.fluid;
            obj.st2_i.q_m = obj.st2_o.q_m;
            
            st2_o_h = obj.st2_i.h - (obj.st1_o.h - obj.st1_i.h) .* ...
                obj.st1_i.q_m.v ./ obj.st2_i.q_m.v;
            obj.st2_o.T.v = CoolProp.PropsSI('T', 'P', obj.st2_o.p, ...
                'H', st2_o_h, obj.st2_o.fluid);
        end
    end
       
end

