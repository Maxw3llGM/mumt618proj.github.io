function [y,xf] = reed_filter(pd, xl, a, b)
%Stable Reed Filter 
%   

    [y, xf] = filter(b,a,pd,xl);
    
%     figure(1)
%     impz(b,a)
%     grid on
%     figure(2)
%     grid on
% 
%     freqz(b,a)
end