function [box_hits] = update_box_hits(box_hits,t,y,V)

    a = y(:,1);
    r = y(:,2);
    
    N_boxes = size(box_hits,1);
    voltage_lims=linspace(-120,60,N_boxes+1)';
    a_lims=linspace(0,1,N_boxes+1)';
    r_lims=linspace(0,1,N_boxes+1)';
    
    for i=1:length(t)
        % Don't give any benefits to small currents...
        % Changed my mind on this - channel needs to be closed at the right
        % time too!!
%         if a(i)*r(i) < 0.1
%             continue
%         end
        
        idx_a = find(a_lims<=a(i),1,'last');
        idx_r = find(r_lims<=r(i),1,'last');
        idx_V = find(voltage_lims<=V(i),1,'last');
        if idx_a == N_boxes+1
            idx_a = N_boxes;
        end
        if idx_r == N_boxes+1
            idx_r = N_boxes;
        end
        if idx_V == N_boxes+1
            idx_V = N_boxes;
        end
        box_hits(idx_a,idx_r,idx_V) = box_hits(idx_a,idx_r,idx_V)+1;
    end
end

