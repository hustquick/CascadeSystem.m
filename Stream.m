classdef Stream < handle
    %Stream This class describes a fluid stream
    
    properties
        fluid;  % Fluid type
        q_m;    % Mass flow rate, kg/s
        T;      % Temperature, K
        p;      % Pressure, Pa
        x;      % Quality of two?phase stream
    end
    properties(Dependent)
        h;      % Mass specific enthalpy, J.kg
        s;      % Mass specific entropy, J/kg-K
        cp;     % Specific heat under constant pressure, J/kg-K
    end
    
    methods
        function obj = Stream
            obj.T = Temperature;
            obj.q_m = Q_m;
        end
        function flow(obj, st)
            % st2 is another state of the same stream st1 after a flow
            % process
            st.fluid = obj.fluid;
            st.q_m = obj.q_m;
        end
        function st2 = mix(obj, st1)
            % Get the properties of a stream mixed by two streams converged
            % The two streams have the same fluid type
            if obj.fluid == st1.fluid
                if  obj.p == st1.p
                    st2 = Stream;
                    st2.fluid = obj.fluid;
                    st2.p = obj.p;
                    st2.q_m = obj.q_m + st1.q_m;
                    h_1 = CoolProp.PropsSI('H', 'T', obj.T.v, 'P', obj.p, obj.fluid);
                    h_2 = CoolProp.PropsSI('H', 'T', st1.T.v, 'P', st1.p, st1.fluid);
                    h_3 = (obj.q_m .* h_1 + st1.q_m .* h_2) ./ (obj.q_m + st1.q_m);
                    st2.T.v = CoolProp.PropsSI('T', 'H', h_3, 'P', st2.p);
                else
                    error('The two streams have different pressures!');
                end
            else
                error('The two streams have different fluid types!');
            end
        end
        function st = converge(obj, n)
            % Get the properties of a stream converged from several streams
            % It is converged from n equal parts
            st = Stream;
            st.fluid = obj.fluid;
            st.q_m.v = obj.q_m.v .* n;
            st.T = obj.T;
            st.p = obj.p;
        end
        function st = diverge(obj, y)
            % Get the properties of a stream diverged from a stream
            % It is diverged into n equal parts
            st = Stream;
            st.fluid = obj.fluid;
            st.q_m.v = obj.q_m.v .* y;
            st.T = obj.T;
            st.p = obj.p;
        end
    end
    methods
        function value = get.h(obj)
            if isempty(obj.x)
                value = CoolProp.PropsSI('H', 'T', obj.T.v, ...
                    'P', obj.p, obj.fluid);
            else
                value = CoolProp.PropsSI('H', 'P', obj.p, 'Q', ...
                    obj.x, obj.fluid);
            end
        end
        function value = get.s(obj)
            if isempty(obj.x)
                value = CoolProp.PropsSI('S', 'T', obj.T.v, ...
                    'P', obj.p, obj.fluid);
            else
                value = CoolProp.PropsSI('S', 'P', obj.p, 'Q', ...
                    obj.x, obj.fluid);
            end
        end
        function value = get.cp(obj)
            if isempty(obj.x)
                value = CoolProp.PropsSI('C', 'T', obj.T.v, ...
                    'P', obj.p, obj.fluid);
            else
                value = inf;
            end
        end
    end
end