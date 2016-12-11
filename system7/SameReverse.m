clear all
clc

n_se = 2;


st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 3;        % Change this value
st1.T.v = 1070 + 30;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(1));
st2.q_m.v = 3;
st2.T.v = 150;
st2.p.v = 1e5;

k = 1;

sea1(k) = SEA;
sea1(k).n1 = 1;
sea1(k).n2 = n_se;
sea1(k).order = 'Same';
sea1(k).st1_i = st1;
sea1(k).st2_i = st2;

sea2(k) = SEA;
sea2(k).n1 = 1;
sea2(k).n2 = n_se;
sea2(k).order = 'Reverse';
sea2(k).st1_i = st1;
sea2(k).st2_i = st2;

sea1(k).calculate;
sea2(k).calculate;

eta1(k) = sea1(k).eta;
eta2(k) = sea2(k).eta;

P1(k) = sea1(k).P;
P2(k) = sea2(k).P;

for i = 1 : n_se
    eta1(i) = sea1(k).se(i).eta;
    eta2(i) = sea2(k).se(i).eta;
end

for i = 1 : n_se
    P1(i) = sea1(k).se(i).P;
    P2(i) = sea2(k).se(i).P;
end

