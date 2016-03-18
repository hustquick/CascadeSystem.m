function F = CalcDishCollector(x, dc, amb)
%CalcDishCollector Use expressions to calculation parameters of dish
%collector
%   First expression expresses q_dr_1 in two different forms
%   Second expression expresses q_cond_tot = q_cond_conv + q_cond_rad
%   Third expression expresses q_in = q_ref + q_dr_1 + q_cond_tot +
%   q_conv_tot + q_rad_emit
dc.T_p.v = x(1);
dc.T_ins.v = x(2);
dc.st_i.q_m.v = x(3);
F = [dc.q_dr_1_1() - dc.q_dr_1_2();
    dc.q_cond_tot() - dc.q_cond_conv(amb) - ...
    dc.q_cond_rad(amb);
    dc.q_dr_1_1() + dc.q_ref(amb) + (dc.q_cond_tot() ...
    + dc.q_conv_tot(amb) + dc.q_rad_emit(amb)) - dc.q_in(amb)];
end
