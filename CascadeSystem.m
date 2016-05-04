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
        DeltaT_3_2;
    end
    
    methods
        function obj = CascadeSystem
            obj.st1(3) = Stream;
            obj.st2(11) = Stream;
            obj.st3(4) = Stream;
        end
    end
    
end
