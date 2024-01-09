function [t,V,states] = run_ramp_clamp(y0, Model_Params, Protocol_Params)

assert(length(Protocol_Params)==8)

duration1 = Protocol_Params(1);
V_step1 = Protocol_Params(2);
duration2 = Protocol_Params(3);
duration3 = Protocol_Params(4);
V_step3 = Protocol_Params(5);
duration4 = Protocol_Params(6);
duration5 = Protocol_Params(7);
V_step5 = Protocol_Params(8);

clamp = [0 V_step1
         duration1 V_step1
         duration1+duration2 V_step3
         duration1+duration2+duration3 V_step3
         duration1+duration2+duration3+duration4 V_step5
         duration1+duration2+duration3+duration4+duration5 V_step5];

options = odeset;
[t,states] = ode15s(@model,[0 clamp(end,1)],y0,options,clamp, Model_Params, Protocol_Params);
V = interp1(clamp(:,1),clamp(:,2),t,'linear');