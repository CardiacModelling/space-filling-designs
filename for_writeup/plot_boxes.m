close all
clear all

plot3([0.5 0.5],[0 0],[-120 60],'k-')
xlim([0 1])
ylim([0 1])
zlim([-120 60])
xlabel('Activation, $a$ gate','interpreter','latex')
ylabel('Recovery, $r$ gate','interpreter','latex')
zlabel('Voltage (mV)','interpreter','latex')
zticks([-120 -90 -60 -30 0 30 60])

hold all

for side=1:3
    for line = 1:7
        x=0;
        y=0;
        V=1;
        tmp = (line-1)/6;
        if side==1
            x = tmp
            plot3([x x],[y y],[-120 60].*V,'k-')
            x=0
            V=-120+tmp*180
            plot3([0 1],[0 0],[V V],'k-')
        elseif side==2
            y=tmp
            plot3([x x],[y y],[-120 60].*V,'k-')
            V=-120+tmp*180
            plot3([0 0],[0 1],[V V],'k-')
        elseif side==3
            V=60
            plot3([tmp tmp],[0 1],[V V],'k-')
            plot3([0 1],[tmp tmp],[V V], 'k-')
        end
        
    end
end
set(gca,'FontSize',14)
set(gcf,'Renderer','Painter')
exportgraphics(gcf,'cubes.pdf');