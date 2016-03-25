classdef Turbine < handle
    %SteamTurbine This class define steam turbine
    %   The steam turbine is a product, N-6 2.35, of Qingdao Jieneng Power
    %    Station Engineering Co., Ltd
    
    properties
        st1;    % Main steam stream
        st2;    % Exhaust steam stream
        st3;    % Extraction steam stream
        y;      % Extraction ratio
        eta_i;  % Isentropic efficiency
    end
    properties(Constant, Access = private)
        fluid_d = char(Const.Fluid(2));     % Designed working fluid
        T_s_d = Temperature(663.15);                     % Designed main steam temperature
        p_s_d = 2.35e6;                     % Designed main steam pressure
        p_c_d = 1.5e4;                      % Designed exhaust pressure
        q_m_d = Q_m(8.084);                 % Designed mass flow rate
        %         q_m_d = Q_m(32.09 / 3.6);
        P_d = 6e6;                          % Designed power
    end
    properties(Dependent, Access = protected)
        h1;     % Mass specific enthalpy of stream 1, J/kg
        s1;     % Mass specific entropy of stream 1, J/kg-K
        h2;     % Mass specific enthalpy of stream 2, J/kg
        s2;     % Mass specific entropy of stream 2, J/kg-K
        h3;     % Mass specific enthalpy of stream 3, J/kg
        s3;     % Mass specific entropy of stream 3, J/kg-K
        P;      % Power of steam turbine, W
        eta;    % Efficiency of the turbine
    end
    
    methods
        function obj = Turbine
            obj.st1 = Stream;
            obj.st2 = Stream;
            obj.st3 = Stream;
        end
    end
    methods
        %         function get_eta_i(obj)
        %             h_1_d = CoolProp.PropsSI('H', 'T', obj.T_s_d.v, 'P', ...
        %                 obj.p_s_d, obj.fluid_d);
        %             s_1_d = CoolProp.PropsSI('S', 'T', obj.T_s_d.v, 'P', ...
        %                 obj.p_s_d, obj.fluid_d);
        %             h_2_d = h_1_d - obj.P_d / obj.q_m_d.v;
        %             h_2_i_d = CoolProp.PropsSI('H', 'S', s_1_d, 'P', ...
        %                 obj.p_c_d, obj.fluid_d);
        %             obj.eta_i = (h_1_d - h_2_d) / (h_1_d - h_2_i_d);
        %         end
        function st2 = flowInTurbine(obj, st1, p)
            st2 = Stream;
            st2.fluid = st1.fluid;
            st2.q_m = st1.q_m;
            st2.p = p;
            st1.s = CoolProp.PropsSI('S', 'T', st1.T.v, 'P', ...
                st1.p, st1.fluid);
            h2_i = CoolProp.PropsSI('H', 'P', st2.p, 'S', st1.s, st2.fluid);
            st1.h = CoolProp.PropsSI('H', 'T', st1.T.v, 'P', ...
                st1.p, st1.fluid);
            h2 = st1.h - obj.eta_i .* (st1.h - h2_i);
            h2_l = CoolProp.PropsSI('H', 'P', st2.p, 'Q', 0, st2.fluid);
            h2_g = CoolProp.PropsSI('H', 'P', st2.p, 'Q', 1, st2.fluid);
            if (h2 >= h2_l && h2 <= h2_g)
                st2.x = (h2 - h2_l) ./ (h2_g - h2_l);
                st2.T.v = CoolProp.PropsSI('T', 'P', st2.p, ...
                    'Q', st2.x, st2.fluid);
                st2.h = CoolProp.PropsSI('H', 'P', st2.p, ...
                    'Q', st2.x, st2.fluid);
                st2.s = CoolProp.PropsSI('S', 'P', st2.p, ...
                    'Q', st2.x, st2.fluid);
            else
                st2.T.v = CoolProp.PropsSI('T', 'P', st2.p,'H', ...
                    h2, st2.fluid);
            end
        end
        function calculate(obj)
            st_tmp = obj.flowInTurbine(obj.st1, obj.st3.p);
            if (obj.y >= 0 && obj.y <= 1)
                obj.st3 = st_tmp.diverge(obj.y);
                st_tmp2 = st_tmp.diverge(1-obj.y);
                obj.st2 = obj.flowInTurbine(st_tmp2, obj.st2.p);
            else
                error('Wrong extraction ratio y value given!');
            end
        end
        
        function value = get.eta_i(obj)
            h_1_d = CoolProp.PropsSI('H', 'T', obj.T_s_d.v, 'P', ...
                obj.p_s_d, obj.fluid_d);
            s_1_d = CoolProp.PropsSI('S', 'T', obj.T_s_d.v, 'P', ...
                obj.p_s_d, obj.fluid_d);
            h_2_d = h_1_d - obj.P_d / obj.q_m_d.v;
            h_2_i_d = CoolProp.PropsSI('H', 'S', s_1_d, 'P', ...
                obj.p_c_d, obj.fluid_d);
            value = (h_1_d - h_2_d) / (h_1_d - h_2_i_d);
        end
    end
end