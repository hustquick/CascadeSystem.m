clear;
cs = CascadeSystem;
cs.sea = SEA(10, 'Reverse');
%% Streams
for i = 1 : 3
    cs.st1(i).fluid = char(Const.Fluid(1));
    cs.st1(i).T = Temperature(convtemp(800, 'C', 'K'));
    cs.st1(i).p = 5e5;      % Design parameter, air pressure in dish receiver, Pa
    cs.st1(i).q_m.v = 2.990;          %%%%%%% To be calculated!
end

for i = 1 : 11
    cs.st2(i).fluid = char(Const.Fluid(2));
    cs.st2(i).T = Temperature(convtemp(340, 'C', 'K'));
    cs.st2(i).p = 2.35e6;
    cs.st2(i).q_m = Q_m(6.672);         %%%%%%% To be calculated!
end

for i = 1 : 4
    cs.st3(i).fluid = char(Const.Fluid(3));
    cs.st3(i).T = Temperature(convtemp(350, 'C', 'K'));    % Design parameter
    cs.st3(i).p = 2e6;
    cs.st3(i).q_m = Q_m(50);            %%%%%%%% To be calculated!
end

cs.dca.st_i = cs.st1(3);
cs.dca.st_o = cs.st1(1);
cs.sea.st1_i = cs.st1(1);
cs.sea.st1_o = cs.st1(2);
cs.sea.st2_i = cs.st2(5);
cs.sea.st2_o = cs.st2(6);
cs.he.st1_i = cs.st1(2);
cs.he.st1_o = cs.st1(3);
cs.tb.st_i = cs.st2(1);
cs.tb.st_o_1 = cs.st2(2);
cs.tb.st_o_2 = cs.st2(3);
cs.cd.st_i = cs.st2(2);
cs.cd.st_o = cs.st2(4);
cs.pu1.st_i = cs.st2(4);
cs.pu1.st_o = cs.st2(5);
cs.da.st_i_1 = cs.st2(3);
cs.da.st_i_2 = cs.st2(6);
cs.da.st_o = cs.st2(7);
cs.pu2.st_i = cs.st2(7);
cs.pu2.st_o = cs.st2(8);
cs.ph.st1_i = cs.st2(8);
cs.ph.st1_o = cs.st2(9);
cs.ph.st2_i = cs.st3(3);
cs.ph.st2_o = cs.st3(4);
cs.ev.st1_i = cs.st2(9);
cs.ev.st1_o = cs.st2(10);
cs.ev.st2_i = cs.st3(2);
cs.ev.st2_o = cs.st3(3);
cs.sh.st1_i = cs.st2(10);
cs.sh.st1_o = cs.st2(11);
cs.sh.st2_i = cs.st3(1);
cs.sh.st2_o = cs.st3(2);

%% Design parameters
cs.dca.st_i.T = Temperature(convtemp(350, 'C', 'K'));   % Design parameter
cs.tb.st_o_1.p = 1.5e4;
cs.tb.st_o_1.q_m.v = 5;     %%%%%% To be calculated
cs.da.p = 1e6;

guess = [2.99; 6.67; 50];
options = optimset('Display','iter');
fsolve(@(x)CalcSystem(x, cs), ...
                guess, options);