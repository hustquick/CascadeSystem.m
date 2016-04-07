function F = CalcSystem(x, cs)
%CalcSystem Use expressions to calculate some parameters of the system
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways
%     x = zeros(sea.n1,2);

 cs.dca.st_i = cs.st1(3);
cs.dca.st_o = cs.st1(1);
cs.sea.st1_i = cs.st1(1);
cs.sea.st1_o = cs.st1(2);
cs.sea.st2_i = cs.st2(5);
cs.sea.st2_o = cs.st2(6);
cs.he.st1_i = cs.st1(2);
cs.he.st1_o = cs.st1(3);
cs.he.st2_i = cs.st2(11);
cs.he.st2_o = cs.st2(1);
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
cs.tca.st_i = cs.st3(4);
cs.tca.st_o = cs.st3(1);

%% Design parameters
cs.dca.st_i.T = Temperature(convtemp(350, 'C', 'K'));   % Design parameter
cs.tb.st_o_1.p = 1.5e4;
cs.da.p = 1e6;
cs.DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

cs.dca.dc.st_i = cs.dca.st_i.diverge(1);
cs.dca.dc.st_o = cs.dca.st_o.diverge(1);
cs.dca.dc.calculate;
cs.dca.n = cs.dca.st_i.q_m.v ./ cs.dca.dc.st_i.q_m.v;
cs.dca.eta = cs.dca.dc.eta;

cs.ge.P = 4e6;
cs.ge.eta = 0.975;

cs.tb.st_o_2.p = cs.da.p;
cs.tb.work(cs.ge);

cs.cd.work;

cs.pu1.p = cs.da.p;
cs.pu1.work;

cs.sea.calculate;

cs.da.work;

cs.pu2.p = cs.tb.st_i.p;
cs.pu2.work;

cs.he.work;

% get q_m_3
cs.ph.st1_o.x = 0;
cs.ph.st1_o.T.v = CoolProp.PropsSI('T', 'P', cs.ph.st1_o.p, ...
    'Q', cs.ph.st1_o.x, cs.ph.st1_o.fluid);
cs.ph.st2_i.T.v = cs.ph.st1_o.T.v + cs.DeltaT_3_2;
cs.ph.st2_i.q_m.v = cs.ph.st1_o.q_m.v .* (cs.sh.st1_o.h - ...
    cs.ph.st1_o.h) ./ (cs.sh.st2_i.h - cs.ph.st2_i.h);

cs.ph.calculate;

cs.ev.calculate;

cs.sh.calculate;

cs.tca.tc.st_i = cs.tca.st_i.diverge(1);
cs.tca.tc.st_o = cs.tca.st_o.diverge(1);
cs.tca.tc.calculate;
cs.tca.n1 = cs.tca.tc.n;
cs.tca.n2 = cs.tca.st_i.q_m.v ./ cs.tca.tc.st_i.q_m.v;
cs.tca.eta = cs.tca.tc.eta;

F = [cs.sea.P ./ cs.sea.eta - cs.sea.st1_i.q_m.v ...
    .* (cs.sea.st1_i.h - cs.sea.st1_o.h);
    cs.tb.y - cs.da.y];
    %cs.he.st2_q_m - cs.he.st2_i.q_m.v];
end