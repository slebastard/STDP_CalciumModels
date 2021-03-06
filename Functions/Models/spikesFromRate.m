function out = spikesFromRate(rate, dt)
%SPIKESFROMRATE Summary of this function goes here
%   Detailed explanation goes here

T = size(rate,1)*dt;

maxRate = max(max(rate));

% Find integral or redressed signal
% i = 1;
% itg(1) = itg0;
% for t=dt:dt:T
%     i = i+1;
%     itg(i) = itg(i-1) + rate(i)*dt;
% end

t = 0;
i=1;
out = [];

while t < T
    t = t - log(rand)./maxRate;
    if t > T
        break
    end
    if rand <= rate(max(1,floor(t/dt)))/maxRate
        out(i) = t;
        i = i+1;
    end
end

end

