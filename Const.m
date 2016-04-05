classdef Const
    %CONST This class is used to define constants
    
    properties (Constant = true)
        SIGMA = 5.67e-8;
        G = 9.807;
        R = 8.314;
    end
    
    properties (Constant = true)
        Fluid = cellstr(char('Air', 'Water', 'INCOMP::TVP1'));	% Fluids' name
        FlowType = cellstr(char('Parallel', 'Counter'));
    end
    methods(Static)
        function c  = LogMean( a, b )
            %LogMean A simple function provide the logarithmic mean number of given two numbers
            if (a * b > 0)
                c = (a - b) / log(a / b);
            else
                error('The two numbers are wrong!');
            end
        end
        function Nu = Nu_nat_conv(Gr, T_cav, T_amb, theta, d_ap, d_bar_cav)
            %Nu_nat_cav This function discribes the corrilation of Nusselt number of the cavity
            S = - 0.982 * (d_ap / d_bar_cav) + 1.12;
            Nu = 0.088 * Gr .^ (1/3) .* (T_cav ./ T_amb) .^ 0.18 ...
                .* (cos(theta))^2.47 .* (d_ap / d_bar_cav) .^ S;
        end
        function Nu = NuInPipe(Re, Pr, mu, mu_cav)
            %NuInPipe This is a function to get Nusselt number of forced convection in pipes:
            %     The correclation can be found in the book.
            Nu = 0.027 * Re ^ 0.8 .* Pr ^ (1 /3) * (mu ./ mu_cav)^0.14;
        end
        function Nu = NuOfExternalCylinder(Re, Pr)
            %NuOfExternalCylinder This is a function to get Nusselt number for flow perpendicular to
            %circular cylinder of diameter D, the average heat-transfer coefficient can
            %be obtained from the correlation in BOOK "Process Heat Transfer PRINCIPLES
            %AND APPLICATIONS".
            Nu = 0.3 + 0.62 * Re .^ (1/2) .* Pr .^ (1/3) / (1 + (0.4 / Pr) .^ (2/3)) .^ (1/4) ...
                .* (1 + (Re / 282000) .^ (5/8)) .^ (4/5);
        end        
    end
end
