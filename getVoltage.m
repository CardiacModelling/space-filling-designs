function [V] = getVoltage(times,clamp)
	% Interpolate V at this time, using our own method which allows
    % vertical jumps!
    V = zeros(length(times),1);
    for t = 1:length(times)
        time = times(t);
        idx = find(clamp(:,1)<=time,1,'last');

        if time >= clamp(end,1)
            V(t) = clamp(end,2);
            continue
        end
        if idx < size(clamp,1) && clamp(idx,1)==clamp(idx+1,1)
            % then we are at a vertical jump and take the second voltage
            V(t) = clamp(idx,2);
            continue
        end
        if idx<size(clamp,1) && clamp(idx,2)==clamp(idx+1,2)
            V(t) = clamp(idx,2);
            continue
        end
        V(t) = clamp(idx,2) + (time - clamp(idx,1))/(clamp(idx+1,1)-clamp(idx,1))*(clamp(idx+1,2)-clamp(idx,2));
    end
end