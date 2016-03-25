clear;
%% Dish Collector
% A dish collector is built under given ambient parameters
ap = AirPipe;
il = InsLayer;
amb = Ambient;

dc = DishCollector;
    dc.st_i.fluid = char(Const.Fluid(1));
    dc.st_i.T = Temperature(convtemp(350, 'C', 'K'));
    dc.st_i.p = 5e5;
    
    dc.st_o = dc.st_i.flow();
    dc.st_o.T = Temperature(convtemp(800, 'C', 'K'));
    dc.st_o.p = dc.st_i.p;
    
    dc.amb = amb;
    dc.airPipe = ap;
    dc.insLayer = il;

guess1 = [1500; 400; 0.1];
options = optimset('Display','iter');
[x1, fval1] = fsolve(@(x1)CalcDishCollector(x1, dc), ...
    guess1, options);

st1(3) = Stream;
st1(1) = dc.st_o.converge(2.990 / dc.st_o.q_m.v);
%% Stirling Engine Array
% Two kinds of connection orders of the Stirling engines are considered.
q_m_2 = Q_m(5.625);  % To be calculated;

st1(2) = st1(1).flow();

st2(11) = Stream;

st2(5).fluid = char(Const.Fluid(2));
st2(5).T = Temperature(327.2);  % to be calculated
st2(5).p = 1e6;
st2(5).q_m = q_m_2; % to be calculated
st2(6) = st2(5).flow();
st2(6).p = st2(5).p;

sea = SEA(10, 'Same');
    sea.st1_i = st1(1);
    sea.st1_o = st1(2);
    sea.st2_i = st2(5);
    sea.st2_o = st2(6);

sea.calculate();
%% Trough Collector
%

tc = TroughCollector;
tc.amb = Ambient;

st3(4) = Stream;

st3(1).fluid = char(Const.Fluid(3));
st3(1).T = Temperature(convtemp(350, 'C', 'K'));
st3(1).p = 2e6;
st3(1).q_m.v = 53.41;  % To be calculated

st3(4) = st3(1).flow();
st3(4).T = Temperature(convtemp(225, 'C', 'K'));     % To be calculated
st3(4).p = st3(1).p;

tc.st_i = st3(4);
tc.st_o = st3(1);

da = Deaerator;
da.p = 1e6;

st2(11) = Stream;

st2(1).fluid = char(Const.Fluid(2));
st2(1).T = Temperature(convtemp(340, 'C', 'K'));
st2(1).p = 2.35e6;
st2(1).q_m.v = 6.672;  % To be calculated

st2(2).fluid = st2(1).fluid;
st2(2).p = 1.5e4;

st2(3).fluid = st2(1).fluid;
% st2(3).p = da.p;
st2(3).p = 1e6;
%% Turbine
% A steam turbine is created
tb = Turbine;
tb.st1 = st2(1);
tb.st2 = st2(2);
tb.st3 = st2(3);
tb.y = 0.1;
tb.calculate();
st2(2) = tb.st2;    % Necessary for the stream has been diverged in the turbine
st2(3) = tb.st3;    % Necessary for the stream has been diverged in the turbine
%% Condenser
% A condenser is created
cd = Condenser;
cd.st1 = st2(2);
st2(4) = cd.st2;
%% Pump1
% The pump btween Sitlring engine array and Condenser
st2(4).fluid = char(Const.Fluid(2));
pu1 = Pump;
pu1.st1 = st2(4);
pu1.p = 1e6;
st2(5) = pu1.st2;

