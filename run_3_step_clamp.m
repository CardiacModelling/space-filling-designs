function [t,V,states] = run_3_step_clamp(y0, Model_Params, Protocol_Params)

duration1 = Protocol_Params(1);
V_step1 = Protocol_Params(2);
duration2 = Protocol_Params(3);
V_step2 = Protocol_Params(4);
duration3 = Protocol_Params(5);
V_step3 = Protocol_Params(6);

options = odeset;
start_time = 0;
end_time = duration1;
[t1,states1] = ode15s(@model,[start_time end_time],y0,options,[0 V_step1; duration1 V_step1], Model_Params, Protocol_Params);
V1 = ones(length(t1),1).*V_step1;

start_time = duration1;
end_time = duration1+duration2;

[t2,states2] = ode15s(@model,[start_time end_time],states1(end,:),options,[start_time V_step2; end_time V_step2], Model_Params, Protocol_Params);
V2 = ones(length(t2),1).*V_step2;

start_time = duration1+duration2;
end_time = duration1+duration2+duration3;
[t3,states3] = ode15s(@model,[start_time end_time],states2(end,:),options,[start_time V_step3; end_time V_step3], Model_Params, Protocol_Params);
V3 = ones(length(t3),1).*V_step3;

% t = [t1(1:end-1); t2(1:end-1); t3];
% states = [states1(1:end-1,:); states2(1:end-1,:); states3];
% V = [V1(1:end-1); V2(1:end-1); V3];

t = [t1; t2(2:end); t3(2:end)];
states = [states1; states2(2:end,:); states3(2:end,:)];
V = [V1; V2(2:end); V3(2:end)];

