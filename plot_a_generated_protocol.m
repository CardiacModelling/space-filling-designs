close all
clear all

% Protocol to plot
clamps = load('resulting_designs_2019/2019-05-20-07-30_Space_Filling_Params_-191710.txt');

% Model parameters
load('each_cell_params.mat')
Model_Params = each_cell_params(:,5); % Cell 5

% The standard steps at the beginning defined to interpolate:
start_clamp = [ 0 -80
    250 -80.0
    250.00001 -120
    300 -120
    700 -80
    900 -80
    900.0001 40
    1900 40
    1900.0001 -120
    2400 -120 ];


full_clamp = start_clamp;
t = [0];
V = [-80];
y = [0.00017    0.601]; % Steady state for -80mV

next_time_add = 0;
for i=1:length(clamps)
    last_time = full_clamp(end,1)+next_time_add;
    if isnan(clamps(i,2))
        disp(['Found a Nan on line ' num2str(i)])
        next_time_add = clamps(i,1)
        continue
    end
    
    start_point = [last_time+0.00001 clamps(i,2)];
    end_point = [last_time+clamps(i,1) clamps(i,2)];
    full_clamp = [full_clamp; start_point; end_point];
    next_time_add = 0;
end
full_clamp

options = odeset;
[t,y]=ode15s(@model,[0:1:full_clamp(end,1)],y,options,full_clamp,Model_Params);

V = interp1(full_clamp(:,1),full_clamp(:,2),t,'linear',-80);

figure(1)
subplot(4,1,1)
plot(t,V,'k-','LineWidth',1.5);
subplot(4,1,2)
plot(t,y,'LineWidth',1.5)
legend('a gate','r gate')
xlabel('Time (ms)')
ylabel('Gating variable')

IKr = Model_Params(end).*y(:,1).*y(:,2).*(V-(-88.6));

subplot(4,1,3)
plot([t(1) t(end)],[0 0],'k--')
hold on
plot(t,IKr,'b-','LineWidth',1.5)
hold off
xlabel('Time (ms)')
ylabel('g*O*(V-E_K)')

% Phase plots
a = y(:,1);
r = y(:,2);

subplot(4,1,4)
plot(a,r,'b-','LineWidth',1.5)
xlabel('activation a')
ylabel('recovery r')

figure(2)
plot3(a,r,V,'b-','LineWidth',2)
xlabel('activation a')
ylabel('recovery r')
zlabel('Voltage (mV)')

N_boxes = 6;
box_hits = zeros(N_boxes,N_boxes,N_boxes);
box_hits = update_box_hits(box_hits, t, y, V);
total_hits = sum(sum(sum(box_hits>1)));
fprintf('This protocol hits %i/(%i^3) boxes (%.1f%%).\n',total_hits,N_boxes,100*total_hits/(N_boxes^3))
