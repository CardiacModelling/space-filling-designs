function [t,V,states] = run_ramp_clamp(y0, Model_Params, Protocol_Params)

assert(length(Protocol_Params)==5)

duration1 = Protocol_Params(1);
V_step1 = Protocol_Params(2);
duration2 = Protocol_Params(3);
duration3 = Protocol_Params(4);
V_step3 = Protocol_Params(5);

clamp = [0 V_step1
         duration1 V_step1
         duration1+duration2 V_step3
         duration1+duration2+duration3 V_step3];

options = odeset;
[t,states] = ode15s(@model,[0:1:clamp(end,1)],y0,options,clamp, Model_Params, Protocol_Params);
V = interp1(clamp(:,1),clamp(:,2),t,'linear');