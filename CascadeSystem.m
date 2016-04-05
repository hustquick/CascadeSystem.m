classdef CascadeSystem
    %CascadeSystem
    
    properties
        st1 = Stream;
        st2 = Stream;
        st3 = Stream;
        dca = DCA;
        tca = TCA;
        tb = Turbine;
        ge = Generator;
        cd = Condenser;
        pu1 = Pump;
        sea;
        da = Deaerator;
        pu2 = Pump;
        ph = Preheater;
        ev = Evaporator;
        sh = Superheater;
        he = HeatExchanger;
    end
    
    methods
        function obj = CascadeSystem
            obj.st1(3) = Stream;
            obj.st2(11) = Stream;
            obj.st3(4) = Stream;
        end
        function F = CalcCascadeSystem(obj, x)
            %CalcCascadeSystem Use expressions to calculation parameters of cascade
            %system
            obj.tb.flow();
            obj.tb.st_i.q_m.v = x(1);
            obj.tb.st_o_1.q_m.v = x(2);
            F = [obj.tb.given_P(obj.ge) - obj.tb.P;
                obj.da.q_m.v - obj.tb.st_i.q_m.v];
            
        end
    end
    
end

