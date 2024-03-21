function [t,V,states] = run_6_step_clamp(y0, Model_Params, Protocol_Params)

duration1 = Protocol_Params(1);
V_step1 = Protocol_Params(2);
duration2 = Protocol_Params(3);
V_step2 = Protocol_Params(4);
duration3 = Protocol_Params(5);
V_step3 = Protocol_Params(6);
duration4 = Protocol_Params(7);
V_step4 = Protocol_Params(8);
duration5 = Protocol_Params(9);
V_step5 = Protocol_Params(10);
duration6 = Protocol_Params(11);
V_step6 = Protocol_Params(12);

options = odeset;
start_time = 0;
end_time = duration1;
[t1,states1] = ode15s(@model,[start_time end_time],y0,options,[0 V_step1; duration1 V_step1], Model_Params, Protocol_Params);
V1 = ones(length(t1),1).*V_step1;

start_time = end_time;
end_time = start_time+duration2;
[t2,states2] = ode15s(@model,[start_time end_time],states1(end,:),options,[start_time V_step2; end_time V_step2], Model_Params, Protocol_Params);
V2 = ones(length(t2),1).*V_step2;

start_time = end_time;
end_time = start_time+duration3;
[t3,states3] = ode15s(@model,[start_time end_time],states2(end,:),options,[start_time V_step3; end_time V_step3], Model_Params, Protocol_Params);
V3 = ones(length(t3),1).*V_step3;

start_time = end_time;
end_time = start_time+duration4;
[t4,states4] = ode15s(@model,[start_time end_time],states3(end,:),options,[start_time V_step4; end_time V_step4], Model_Params, Protocol_Params);
V4 = ones(length(t4),1).*V_step4;

start_time = end_time;
end_time = start_time+duration5;
[t5,states5] = ode15s(@model,[start_time end_time],states4(end,:),options,[start_time V_step5; end_time V_step5], Model_Params, Protocol_Params);
V5 = ones(length(t5),1).*V_step5;

start_time = end_time;
end_time = start_time+duration6;
[t6,states6] = ode15s(@model,[start_time end_time],states5(end,:),options,[start_time V_step6; end_time V_step6], Model_Params, Protocol_Params);
V6 = ones(length(t6),1).*V_step6;

t = [t1(1:end-1); t2(1:end-1); t3(1:end-1); t4(1:end-1); t5(1:end-1); t6];
states = [states1(1:end-1,:); states2(1:end-1,:); states3(1:end-1,:); states4(1:end-1,:); states5(1:end-1,:); states6];
V = [V1(1:end-1); V2(1:end-1); V3(1:end-1); V4(1:end-1); V5(1:end-1); V6];



