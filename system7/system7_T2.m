clear;
% Different kinds of connection form of Stirling engines
number = 1;
n_se = 6;
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
T1 = zeros(1, number);

for k = 1 : number
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 0.3;        % Change this value
st1.T.v = 670 + 30 * k;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(1));
st2.q_m.v = 0.3;
st2.T.v = 300;
st2.p.v = 5e5;

sea1 = SEC(n_se,'Parallel');
sea1.st1_i = st1;
sea1.st2_i = st2;

sea2 = SEA;
sea2.n1 = 1;
sea2.n2 = n_se;
sea2.order = 'Same';
sea2.st1_i = st1;
sea2.st2_i = st2;

sea3 = SEA;
sea3.n1 = 1;
sea3.n2 = n_se;
sea3.order = 'Reverse';
sea3.st1_i = st1;
sea3.st2_i = st2;

sea4 = SEC(n_se,'Serial1');
sea4.st1_i = st1;
sea4.st2_i = st2;

sea5 = SEC(n_se,'Serial2');
sea5.st1_i = st1;
sea5.st2_i = st2;

sea1.calculate;
sea2.calculate;
sea3.calculate;
sea4.calculate;
sea5.calculate;

eta1(k) = sea1.eta;
eta2(k) = sea2.eta;
eta3(k) = sea3.eta;
eta4(k) = sea4.eta;
eta5(k) = sea5.eta;
P1(k) = sea1.P;
P2(k) = sea2.P;
P3(k) = sea3.P;
P4(k) = sea4.P;
P5(k) = sea5.P;
T1(k) = st1.T.v;
end

subplot(1,2,1);

plot(T1,eta1);
hold on
plot(T1,eta2);
plot(T1,eta3);
plot(T1,eta4);
plot(T1,eta5);
legend('1', '2', '3', '4', '5');

subplot(1,2,2);
plot(T1,P1);
hold on
plot(T1,P2);
plot(T1,P3);
legend('1', '2', '3', '4', '5')
plot(T1,P4);
plot(T1,P5)
