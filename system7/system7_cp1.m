clear;
% Different kinds of connection form of Stirling engines
number = 10;
n_se = 6;
sea1 = SEC.empty;
sea2 = SEA.empty;
sea3 = SEA.empty;
sea4 = SEC.empty;
sea5 = SEC.empty;

eta1 = zeros(1, number);
eta2 = zeros(1, number);
eta3 = zeros(1, number);
eta4 = zeros(1, number);
eta5 = zeros(1, number);
P1 = zeros(1, number);
P2 = zeros(1, number);
P3 = zeros(1, number);
P4 = zeros(1, number);
P5 = zeros(1, number);
c_p1 = zeros(1, number);

st1 = Stream;
st2 = Stream;

for k = 1 : number
    st1(k) = Stream;
%     st1(k).fluid = char(Const.Fluid(1));
    st1(k).q_m.v = 0.6;        % Change this value
    st1(k).T.v = 1000;
    st1(k).p.v = 5e5;

    st2(k) = Stream;
    st2(k).fluid = char(Const.Fluid(1));
    st2(k).q_m.v = 0.6;
    st2(k).T.v = 300;
    st2(k).p.v = 5e5;
end

st1(1).fluid = char(cellstr(char('Argon')));
st1(2).fluid = char(Const.Fluid(1));
st1(3).fluid = char(cellstr(char('CarbonMonoxide')));
st1(4).fluid = char(cellstr(char('CarbonDioxide')));
st1(5).fluid = 'Water';
st1(6).fluid = char(cellstr(char('Benzene')));
st1(7).fluid = char(cellstr(char('Ethylene')));
st1(8).fluid = char(cellstr(char('Ethane')));
st1(9).fluid = char(cellstr(char('Helium')));
st1(10).fluid = char(cellstr(char('Hydrogen')));


for k = 1 : number
    sea1(k) = SEC(n_se,'Parallel');
    sea1(k).st1_i = st1(k);
    sea1(k).st2_i = st2(k);

    sea2(k) = SEA;
    sea2(k).n1 = 1;
    sea2(k).n2 = n_se;
    sea2(k).order = 'Same';
    sea2(k).st1_i = st1(k);
    sea2(k).st2_i = st2(k);

    sea3(k) = SEA;
    sea3(k).n1 = 1;
    sea3(k).n2 = n_se;
    sea3(k).order = 'Reverse';
    sea3(k).st1_i = st1(k);
    sea3(k).st2_i = st2(k);

    sea4(k) = SEC(n_se,'Serial1');
    sea4(k).st1_i = st1(k);
    sea4(k).st2_i = st2(k);

    sea5(k) = SEC(n_se,'Serial2');
    sea5(k).st1_i = st1(k);
    sea5(k).st2_i = st2(k);

    sea1(k).calculate;
    sea2(k).calculate;
    sea3(k).calculate;
    sea4(k).calculate;
    sea5(k).calculate;

    eta1(k) = sea1(k).eta;
    eta2(k) = sea2(k).eta;
    eta3(k) = sea3(k).eta;
    eta4(k) = sea4(k).eta;
    eta5(k) = sea5(k).eta;
    P1(k) = sea1(k).P;
    P2(k) = sea2(k).P;
    P3(k) = sea3(k).P;
    P4(k) = sea4(k).P;
    P5(k) = sea5(k).P;
    c_p1(k) = st1(k).cp;
end

subplot(1,2,1);

plot(c_p1,eta1);
hold on
plot(c_p1,eta2);
plot(c_p1,eta3);
plot(c_p1,eta4);
plot(c_p1,eta5);
legend('1', '2', '3', '4', '5');

subplot(1,2,2);
plot(c_p1,P1);
hold on
plot(c_p1,P2);
plot(c_p1,P3);
plot(c_p1,P4);
plot(c_p1,P5);
legend('1', '2', '3', '4', '5')