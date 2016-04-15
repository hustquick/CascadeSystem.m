classdef SEA < handle
    %SEA This class defines the Stirling engine array
    %   The array is built with the same kind of Stirling engines, all of
    %   them are the objects of StirlingEngine class.
    
    properties
        n_se       % Number of Stirling engines in the Stirling engine array
    end
    properties
        se;         % A row of the Stirling engine array
        n1;         % Number of columns of the Stirling engine array
        st1_i;      % Inlet stream of first fluid to the Stirling engine array
        st1_o;      % Outlet stream of first fluid to the Stirling engine array
        st2_i;      % Inlet stream of second fluid to the Stirling engine array
        st2_o;      % Outlet stream of second fluid to the Stirling engine array
        order;      % Flow order of the heating flow and cooling flow to the
        % Stirling engines, 'Same' means the two flows have the same
        % order, 'Reverse' means the two flows have reverse
        % order, other orders are not considered
        eta;
        P;
    end
    properties(Dependent)
        n2;         % Number of rows of the Stirling engine array
        st1_i_r;    % Inlet stream of first fluid after divergence
        st2_i_r;    % Inlet stream of second fluid after divergence
    end
    
    methods
        function obj = SEA(n1, order)
            % n1 is the number of columns of the Stirling engine array,
            % order is a string, 'Same' or 'Reverse'
            obj.n1 = n1;
            se1(1, n1) = StirlingEngine;
            obj.se = se1;
            obj.st1_i = Stream;
            obj.st1_o = Stream;
            obj.st2_i = Stream;
            obj.st2_o = Stream;
            obj.order = order;
        end
    end
    methods
        function calculate(obj, guess)
%             guess = zeros(2, obj.n1);   % 2 * n1 unknown parameters (outlet temperature of two fluids in each column)
            
            cp_1 = obj.st1_i.cp;
            cp_2 = obj.st2_i.cp;
            obj.se(1).st1_i = obj.st1_i_r;
            obj.se(1).st1_o = obj.se(1).st1_i.flow();
            obj.se(1).st1_o.p = obj.se(1).st1_i.p;
            obj.se(1).cp_1 = cp_1;
            
            if (strcmp(obj.order, 'Same'))
                %%%%% Same order %%%%%
                obj.se(1).st2_i = obj.st2_i_r;
                obj.se(1).st2_o = obj.se(1).st2_i.flow();
                obj.se(1).st2_o.p = obj.se(1).st2_i.p;
                obj.se(1).cp_2 = cp_2;
                for i = 2 : obj.n1
                    obj.se(i).cp_1 = cp_1;
                    obj.se(i).cp_2 = cp_2;
                    obj.se(i).st1_i = obj.se(i-1).st1_o;
                    obj.se(i).st2_i = obj.se(i-1).st2_o;
                    obj.se(i).st1_o = obj.se(i).st1_i.flow();
                    obj.se(i).st1_o.p = obj.se(i).st1_i.p;
                    obj.se(i).st2_o = obj.se(i).st2_i.flow();
                    obj.se(i).st2_o.p = obj.se(i).st2_i.p;
                end
                
%                 for j = 1 : obj.n1
%                     guess(j,1) = obj.se(1).st1_i.T.v - 27 * j;
%                     guess(j,2) = obj.se(1).st2_i.T.v + 4 * j;
%                 end
            elseif (strcmp(obj.order,'Reverse'))
                %%%%% Inverse order %%%%%
                obj.se(1).cp_2 = cp_2;
                for i = 2 : obj.n1
                    %                     obj.se(i) = StirlingEngine;
                    obj.se(i).cp_1 = cp_1;
                    obj.se(i).cp_2 = cp_2;
                end
                obj.se(obj.n1).st2_i = obj.st2_i_r;
                obj.se(obj.n1).st2_o = obj.se(obj.n1).st2_i.flow();
                obj.se(obj.n1).st2_o.p = obj.se(obj.n1).st2_i.p;
                
                for i = 1 : obj.n1-1
                    obj.se(i+1).st1_i = obj.se(i).st1_o;
                    obj.se(obj.n1-i).st2_i = obj.se(obj.n1+1-i).st2_o;
                    
                    obj.se(i+1).st1_o = obj.se(i+1).st1_i.flow();
                    obj.se(i+1).st1_o.p = obj.se(i+1).st1_i.p;
                    obj.se(obj.n1-i).st2_o = obj.se(obj.n1-i).st2_i.flow();
                    obj.se(obj.n1-i).st2_o.p = obj.se(obj.n1-i).st2_i.p;
                end
                
%                 for j = 1 : obj.n1
%                     guess(j,1) = obj.se(1).st1_i.T.v - 27 * j;
%                     guess(j,2) = obj.se(obj.n1).st2_i.T.v + ...
%                         4 * (obj.n1 + 1 - j);
%                 end
            else
                error('Uncomplished work.');
            end
                        
            options = optimset('Algorithm','levenberg-marquardt','Display','iter');
            [x] = fsolve(@(x)CalcSEA(x, obj), guess, options);
            
            obj.st1_o.T = obj.se(obj.n1).st1_o.T;
            obj.st1_o.p = obj.se(obj.n1).st1_o.p;
            
            if (strcmp(obj.order, 'Same'))
                obj.st2_o.T = obj.se(obj.n1).st2_o.T;
                obj.st2_o.p = obj.se(obj.n1).st2_o.p;
            elseif (strcmp(obj.order,'Reverse'))
                obj.st2_o.T = obj.se(1).st2_o.T;
                obj.st2_o.p = obj.se(1).st2_o.p;
            else
                error('Uncomplished work.');
            end
            
            P1 = zeros(obj.n1,1);
            
            for i = 1 : obj.n1
                obj.se(i).st1_o.T.v = x(i, 1);
                obj.se(i).st2_o.T.v = x(i, 2);
                obj.se(i).P = obj.se(i).P1();
                P1(i) = obj.se(i).P2();
            end
            obj.eta = sum(P1) ./ (obj.st1_i_r.q_m.v * ...
                (obj.se(1).st1_i.h - obj.se(obj.n1).st1_o.h));
            obj.st2_o.q_m = obj.st2_i.q_m;
            obj.P = sum(P1) .* obj.n_se ./ obj.n1;
            obj.st1_o.q_m = obj.st1_i.q_m;
            obj.st2_o.q_m = obj.st2_i.q_m;
        end
        function F = CalcSEA(x, sea)
            %CalcSEA Use expressions to calculate Temperatures of Stirling Engine Array
            %   First expression expresses eta of each Stirling engine in two ways
            %   Second expression expresses P of each Stirling engine in two ways
            %     x = zeros(sea.n1,2);
            for i = 1 : sea.n1
                sea.se(i).st1_o.T.v = x(i, 1);
                sea.se(i).st2_o.T.v = x(i, 2);
            end

            F = zeros(sea.n1,2);
            for j = 1 : sea.n1
                F(j,1) = 1 - sea.se(j).eta1() ./ sea.se(j).eta2();
                F(j,2) = 1 - sea.se(j).P1() ./ sea.se(j).P2();
            end
        end
    end
    methods
        function value = get.n2(obj)
            value = obj.n_se / obj.n1;
        end
        function value = get.st1_i_r(obj)
            value = obj.st1_i.diverge(obj.n1/obj.n_se);
        end
        function value = get.st2_i_r(obj)
            value = obj.st2_i.diverge(obj.n1/obj.n_se);
        end
    end
    
end

