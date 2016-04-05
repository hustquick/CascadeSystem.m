function F = CalcSystem(x, cs)
%CalcSystem Use expressions to calculate some parameters of the system
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways
%     x = zeros(sea.n1,2);

cs.st1(1).q_m.v = x(1);
cs.st2(1).q_m.v = x(2);
cs.st3(1).q_m.v = x(3);

cs.dca.dc.st_i = cs.dca.st_i.diverge(1);
cs.dca.dc.st_o = cs.dca.st_o.diverge(1);
cs.dca.dc.calculate;
cs.dca.n = cs.dca.st_i.q_m.v ./ cs.dca.dc.st_i.q_m.v;
cs.dca.eta = cs.dca.dc.eta;

cs.ge.P = 4e6;
cs.ge.eta = 0.975;

cs.tb.st_o_2.p = cs.da.p;
cs.tb.work;

cs.cd.work;

cs.pu1.p = cs.da.p;
cs.pu1.work;

cs.sea.calculate;

cs.da.work;

cs.pu2.p = cs.tb.st_i.p;
cs.pu2.work;

cs.ph.calculate;

cs.ev.calculate;

cs.sh.calculate;

F = [cs.tb.P - cs.ge.P ./ cs.ge.eta;
    cs.da.q_m.v - cs.da.st_o.q_m.v;
    cs.he.st2_q_m - cs.he.st2_i.q_m.v];
end

