classdef StirlingEngine < handle
    %StirlingEngine This class defines some basic characteristics of Stirling engine
    
    properties
        U_1 = 30;   % Overall heat transfer coefficient of Stirling engine at air side, W/m^2-K
        U_2 = 30;  % Overall heat transfer coefficient of Stirling engine at water side, W/m^2-K
        A_1 = 6;    % Heat transfer area of Stirling engine at air side, m^2
        A_2 = 6;    % Heat transfer area of Stirling engine at water side, m^2
        k = 1.4;    % Specific heat ratio of the working gas in Stirling engine, for H2
        gamma = 3.375;  % Compression ratio of Stirling engine, ~\cite{Fraser2008}
        s_se = 20;  % Speed of Stirling engine, Hz (10Hz, 5kW)
        n_g = 4.158e-2; % Amount of working gas in each Stirling engine, mol
        V_DH = 7.028e-5;    % Dead volume of heater, m^3
        V_DC = 1.318e-5;     % Dead volume of cooler, m^3
        V_DR = 5.055e-5;    % Dead volume of regenerator, m^3
        S_E = 1.2082e-4;    % Swap volume of the expand space, m^3
        S_C = 1.1413e-4;    % Swap volume of the compress space, m^3
        C_E = 3.052e-5;     % Clearance volume of the expand space, m^3
        C_C = 2.868e-5;     % Clearance volume fo the compress space, m^3
%         n_g = 0.04171;        % Amount of working gas in each Stirling engine, mol
        p = 2.76e6;         % Mean pressure, Pa
        N_h = 40;           % Number of heater tubes
        l_h = 0.2453;       % Average heater tube length, m
        d_i_h = 0.00302;    % Heater internal diameter, m
        N_l = 312;          % Number of cooler tubes
        l_l = 0.0461;       % Average cooler tube length, m
        d_i_l = 0.00109;    % Cooler internal diameter, m
        st1_i;   % Heating stream at inlet
        st1_o;   % Heating stream at outlet
        st2_i;   % Cooling stream at inlet
        st2_o;   % Cooling stream at outlet
        P;      % Power of the Stirling engine, W
        eta;    % Efficiency of the Stirling enine
        T_H;    % Temperature of compression, K
        T_L;    % Temperature of expansion, K
    end
    
    methods
        function obj = StirlingEngine
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
        end
        function T_H = get.T_H(obj)
            % Highest temperature of expansion space, K
            T_H = obj.st1_i.T.v - (obj.st1_i.T.v - obj.st1_o.T.v) ./ (1 - ...
                exp(- obj.U_1 .* obj.A_1 ./ (obj.st1_i.q_m.v .* obj.st1_i.cp)));
        end
        function T_L = get.T_L(obj)
            % Lowest temperature of compression space, K
            T_L = obj.st2_i.T.v - (obj.st2_i.T.v - obj.st2_o.T.v) ./ (1 - ...
                exp(- obj.U_2 .* obj.A_2 ./ (obj.st2_i.q_m.v .* obj.st2_i.cp)));
        end
        function T_R = T_R(obj)
            % Regenerator temperature, K
            T_R = Const.LogMean(obj.T_H(), obj.T_L());
        end
        function e = e(obj)
            % Regeneration effectiveness of the Stirling engine
            e = (obj.T_R() - obj.T_L()) ...
                ./ (obj.T_H() - obj.T_L());
        end
        function gamma_h = gamma_h(obj)            
            V_E = obj.S_E + obj.C_E;
            V_C = obj.S_C + obj.C_C;
            k_hl = obj.V_DH ./ obj.T_H + obj.V_DR ./ obj.T_R + obj.V_DC ./ obj.T_L;
            gamma_h = (V_E + V_C + k_hl * obj.T_H) / (V_E + k_hl * obj.T_H);
        end
        function gamma_l = gamma_l(obj)            
            V_E = obj.S_E + obj.C_E;
            V_C = obj.S_C + obj.C_C;
            k_hl = obj.V_DH ./ obj.T_H + obj.V_DR ./ obj.T_R + obj.V_DC ./ obj.T_L;
            gamma_l = (V_E + V_C + k_hl * obj.T_L) / (V_E + k_hl * obj.T_L);
        end
        function eta = get.eta(obj)
            % Efficiency of the Stirling engine using formula
%             e = obj.e();
%             eta = (obj.T_H - obj.T_L) ./ (obj.T_H + ...
%                 (1 - e) .* (obj.T_H - obj.T_L) ...
%                 ./ (obj.k -1) ./ log(obj.gamma));
            eta = (obj.T_H * log(obj.gamma_h) - obj.T_L * log(obj.gamma_l))...
                ./ (obj.T_H * log(obj.gamma_h) + (1 - obj.e) .* ...
                (obj.T_H - obj.T_L) ./ (obj.k - 1));
        end
        function eta = eta1(obj)
            % Efficiency of the Stirling engine using definition
            Q_1 = obj.st1_i.q_m.v .* (obj.st1_i.h - obj.st1_o.h);
            Q_2 = obj.st2_i.q_m.v .* (obj.st2_o.h - obj.st2_i.h);
            eta =  (Q_1 - Q_2) ./ Q_1;
        end
        function P = P1(obj)
            % Power of the Stirling engine using the efficiency
            eta2 = obj.eta();
            % P = obj.st1_i.q_m.v .* obj.cp_1 .* (obj.st1_i.T.v - obj.st1_o.T.v) .* eta;
            P = obj.st1_i.q_m.v .* (obj.st1_i.h - obj.st1_o.h) .* eta2;
        end
        function P = get.P(obj)
            % Power of the Stirling engine using the speed of engine
%             P1 = obj.n_g .* Const.R .* (obj.T_H - obj.T_L) .* ...
%                 log(obj.gamma) .* obj.s_se;
            P1 = obj.n_g .* Const.R .* (obj.T_H * log(obj.gamma_h) ...
                - obj.T_L * log(obj.gamma_l)) .* obj.s_se;
            if P1 > 0
                P = P1;
            else
                P = 0;
            end
        end
        function get_o(obj)
            obj.st1_i.flowTo(obj.st1_o);
            obj.st1_o.p = obj.st1_i.p;
            obj.st2_i.flowTo(obj.st2_o);
            obj.st2_o.p = obj.st2_i.p;
            guess = [obj.st1_i.T.v - 14300 / (obj.st1_i.cp * obj.st1_i.q_m.v);
                obj.st2_i.T.v + 9300 / (obj.st2_i.cp * obj.st2_i.q_m.v)]; 
            % Guess value of temperatures of two outlet streams
            options = optimset('Display', 'off');
            fsolve(@(x)Calc_o(x, obj), guess, options);
        end
        function F = Calc_o(x, se)
            se.st1_o.T.v = x(1);
            se.st2_o.T.v = x(2);
            F = [se.P1 - se.P;
                se.eta1 - se.eta];
        end
        function get_i(obj)
            obj.st1_i.flowTo(obj.st1_o);
            obj.st1_o.p = obj.st1_i.p;
            obj.st2_o.flowTo(obj.st2_i);
            obj.st2_i.p = obj.st2_o.p;
            guess = [obj.st1_i.T.v - 14300 / (obj.st1_i.cp * obj.st1_i.q_m.v);
                obj.st2_o.T.v - 9300 / (obj.st2_o.cp * obj.st2_o.q_m.v)];
            options = optimset('DisPlay', 'off');
            fsolve(@(x)Calc_i(x, obj), guess, options);
        end
        function F = Calc_i(x, se)
            se.st1_o.T.v = x(1);
            se.st2_i.T.v = x(2);
            F = [se.P1 - se.P;
                se.eta1 - se.eta];
        end
    end
end