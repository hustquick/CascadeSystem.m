classdef DishCollector < handle
    %DishCollector is a kind of Collector which uses dish mirror as the reflector
    %and uses volumetric receiver
    
    properties(Constant)
        A = 87.7;         % Aperture area of the collector, m^2
        gamma = 0.97;       % Intercept factor of the collector
        rho = 0.91;         % Reflectance of the collector
        shading = 0.95;     % Shading factor of the collector
        d_ap = 0.184;       % Aperture diameter of the dish receiver, m
        d_cav = 0.46;       % Diameter of the cavity of the dish receiver, m
        dep_cav = 0.23;     % Depth of the cavity of the dish receiver, m
        theta = degtorad(45);% Dish aperture angle(0 is horizontal, 90 is vertically down), rad
    end
    properties
        amb;        % Ambient
        %         airPipe.T;        % Temperature of the fluid pipe, K
        %         insLayer.T;      % Outside temperature of the insulating layer, K
        st_i;       % Inlet stream
        st_o;       % Outlet stream
        airPipe;    % Air pipe
        insLayer;   % Insulating layer
    end
    properties(Dependent)
        q_use;      % Energy used, transferred to the fluid, W
        q_tot;      % Energy projected to the reflector, W
        eta;        % Thermal efficiency of the collector
    end
    properties(Dependent, Access = protected)
        A_ins;      % Insulating layer outside area, m^2
        A_cav;      % Cavity area, m^2
    end
    
    methods
        function obj = DishCollector
            obj.amb = Ambient;
            obj.insLayer.T = Temperature;
            obj.airPipe.T = Temperature;
            obj.airPipe = AirPipe;
            obj.insLayer = InsLayer;
            obj.st_i = Stream;
            obj.st_o = Stream;
        end
        function q_in = q_in(obj)
            % The accepted energy from the reflector, W
            q_in = obj.amb.I_r .* obj.A .* obj.gamma * obj.shading * obj.rho;
        end
        function q_dr_1 = q_dr_1_1(obj)
            % Heat absorbed by the fluid, W
            h_o = CoolProp.PropsSI('H', 'T', obj.st_o.T.v,...
                'P', obj.st_o.p, obj.st_o.fluid);
            h_i = CoolProp.PropsSI('H', 'T', obj.st_i.T.v,...
                'P', obj.st_i.p, obj.st_i.fluid);
            q_dr_1 = obj.st_i.q_m.v .* (h_o - h_i);
        end
        function q_dr_1 = q_dr_1_2(obj)
            % Heat transferred from the air pipe to the air, W
            T = (obj.st_i.T.v + obj.st_o.T.v)/2;
            p = (obj.st_i.p + obj.st_o.p)/2;
            density = CoolProp.PropsSI('D', 'T', T, 'P', p, obj.st_i.fluid);
            v = 4 .* obj.st_i.q_m.v ./ (pi * obj.airPipe.d_i .^2 .* density);
            mu = CoolProp.PropsSI('V', 'T', T, 'P', p, obj.st_i.fluid);
            Re = density * v * obj.airPipe.d_i / mu;
            Cp = CoolProp.PropsSI('C', 'T', T, 'P', p, obj.st_i.fluid);
            k = CoolProp.PropsSI('L', 'T', T, 'P', p, obj.st_i.fluid);
            Pr = Cp .* mu ./k;
            mu_cav = CoolProp.PropsSI('V', 'T', obj.airPipe.T.v,...
                'P', p, obj.st_i.fluid);
            Nu_prime = Const.NuInPipe(Re, Pr, mu, mu_cav);
            
            c_r = 1 + 3.5 * obj.airPipe.d_i / (obj.d_cav - ...
                obj.airPipe.d_i - 2 * obj.airPipe.delta_a);
            Nu = c_r * Nu_prime;
            
            h = Nu * k / obj.airPipe.d_i;
            
            H_prime_c = obj.airPipe.d_i + 2 * obj.airPipe.delta_a;
            N = floor(obj.dep_cav ./ H_prime_c);
            H_c = obj.dep_cav ./ N;
            L_c = N .* sqrt((pi * obj.d_cav).^2 + H_c.^2);
            A_airPipe = pi * obj.airPipe.d_i .* L_c;
            
            DeltaT1 = obj.airPipe.T.v - obj.st_i.T.v;
            DeltaT2 = obj.airPipe.T.v - obj.st_o.T.v;
            DeltaT = Const.LogMean(DeltaT1, DeltaT2);
            
            q_dr_1 = h .* A_airPipe .* DeltaT;
        end
        function q_ref = q_ref(obj)
            % Reflected energy by the receiver, W
            A_ap = pi * obj.d_ap .^ 2 / 4;
            
            alpha_eff = obj.airPipe.alpha ./ (obj.airPipe.alpha + ...
                (1 - obj.airPipe.alpha) .* (A_ap ./ obj.A_cav()));
            
            q_ref = (1 - alpha_eff) .* obj.q_in;
        end
        function q_cond_conv = q_cond_conv(obj)
            % Convection loss from the insulating layer, W
            mu = CoolProp.PropsSI('V', 'T', obj.amb.T.v, ...
                'P', obj.amb.p, obj.amb.fluid);
            density = CoolProp.PropsSI('D', 'T', obj.amb.T.v,...
                'P', obj.amb.p, obj.amb.fluid);
            nu = mu ./ density;
            
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            
            Re = obj.amb.w .* d_o ./ nu;
            
            Cp = CoolProp.PropsSI('C', 'T', obj.amb.T.v, ...
                'P', obj.amb.p, obj.amb.fluid);
            k = CoolProp.PropsSI('L', 'T', obj.amb.T.v, ...
                'P', obj.amb.p, obj.amb.fluid);
            Pr = Cp .* mu ./ k;
            
            Nu = Const.NuOfExternalCylinder(Re, Pr);
            
            h = Nu * k / d_o;
            A_ins = obj.A_ins;
            q_cond_conv = h .* A_ins .* (obj.insLayer.T.v - obj.amb.T.v);
        end
        function q_cond_rad = q_cond_rad(obj)
            % Radiation loss from the insulating layer, W
            q_cond_rad = obj.insLayer.epsilon .* obj.A_ins * ...
                Const.SIGMA .* (obj.insLayer.T.v.^4 - obj.amb.T.v .^ 4);
        end
        function q_cond_tot = q_cond_tot(obj)
            % Heat loss from air pipe to the insulating layer, W
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            q_cond_tot = (obj.airPipe.T.v - obj.insLayer.T.v) ./ ...
                (log(d_o ./ obj.insLayer.d_i) ./ ...
                (2 * pi * obj.insLayer.lambda .* obj.dep_cav));
        end
        function q_conv_tot = q_conv_tot(obj)
            % Total covection loss, W
            T = (obj.airPipe.T.v + obj.amb.T.v) / 2;   % Film temperature is used
            k = CoolProp.PropsSI('L', 'T', T, 'P', obj.amb.p, obj.amb.fluid);
            
            d_bar_cav = obj.d_cav - 2 * obj.airPipe.d_i - 4 * ...
                obj.airPipe.delta_a;
            
            beta = CoolProp.PropsSI('ISOBARIC_EXPANSION_COEFFICIENT', ...
                'T', T, 'P', obj.amb.p, obj.amb.fluid);
            mu = CoolProp.PropsSI('V', 'T', T, 'P', obj.amb.p, obj.amb.fluid);
            density = CoolProp.PropsSI('D', 'T', T, 'P', ...
                obj.amb.p, obj.amb.fluid);
            nu = mu ./ density;
            Gr = Const.G * beta .* (obj.airPipe.T.v - obj.amb.T.v) .* ...
                d_bar_cav .^ 3 ./ nu .^ 2;
            
            Nu = Const.Nu_nat_conv(Gr, obj.airPipe.T.v, obj.amb.T.v, ...
                obj.theta, obj.d_ap, d_bar_cav);
            h_nat = k .* Nu ./ d_bar_cav;
            
            h_for = 0.1967 * obj.amb.w .^ 1.849;
            
            q_conv_tot = (h_nat + h_for) .* obj.A_cav() .* ...
                (obj.airPipe.T.v - obj.amb.T.v);
        end
        function q_rad_emit = q_rad_emit(obj)
            % Emitted radiation loss, W
            A_ap = pi * obj.d_ap .^ 2 / 4;
            alpha_eff = obj.airPipe.alpha ./ (obj.airPipe.alpha + ...
                (1 - obj.airPipe.alpha) .* (A_ap / obj.A_cav));
            epsilon_cav = alpha_eff;
            q_rad_emit = epsilon_cav .* A_ap * Const.SIGMA .* ...
                (obj.airPipe.T.v .^4 - obj.amb.T.v .^ 4);
        end
        function calculate(obj)
            guess = [1500; 400; 0.1] ;
            options = optimset('Display','iter');
            fsolve(@(x)CalcDishCollector(x, obj), ...
                guess, options);
            obj.st_o.q_m = obj.st_i.q_m;
        end
        function F = CalcDishCollector(x, dc)
            %CalcDishCollector Use expressions to calculation parameters of dish
            %collector
            %   First expression expresses q_dr_1 in two different forms
            %   Second expression expresses q_cond_tot = q_cond_conv + q_cond_rad
            %   Third expression expresses q_in = q_ref + q_dr_1 + q_cond_tot +
            %   q_conv_tot + q_rad_emit
            dc.airPipe.T.v = x(1);
            dc.insLayer.T.v = x(2);
            dc.st_i.q_m.v = x(3);
            F = [dc.q_dr_1_1 - dc.q_dr_1_2;
                dc.q_cond_tot - dc.q_cond_conv - ...
                dc.q_cond_rad;
                dc.q_dr_1_1 + dc.q_ref + (dc.q_cond_tot ...
                + dc.q_conv_tot + dc.q_rad_emit) - dc.q_in];
        end
    end
    methods
        function value = get.A_ins(obj)
            % Get the insulating layer outside area, m^2
            d_o = obj.insLayer.d_i + 2 * obj.insLayer.delta;
            value = pi * d_o .* (obj.dep_cav + obj.insLayer.delta);
        end
        function value = get.A_cav(obj)
            % Get the cavity area, m^2
            d_bar_cav = obj.d_cav - 2 * obj.airPipe.d_i ...
                - 4 * obj.airPipe.delta_a;
            value = pi * d_bar_cav .^ 2 / 4 + pi * d_bar_cav ...
                * obj.dep_cav + pi * (d_bar_cav .^ 2 - obj.d_ap .^ 2) / 4;
        end
        function value = get.q_use(obj)
            value = obj.st_i.q_m.v .* (obj.st_o.h - obj.st_i.h);
        end
        function value = get.q_tot(obj)
            value = obj.amb.I_r .* obj.A;
        end
        function value = get.eta(obj)
            value = obj.q_use ./ obj.q_tot;
        end
    end
end