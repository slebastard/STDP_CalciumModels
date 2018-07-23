function [rho_hist, w_hist, c_hist] = pheno_model( pre_spikes_hist, post_spikes_hist, params, int_scheme, int_step, noise_lvl)
%NAIVE_MODEL Simulates the behavior of a synapse whose behavior follows the
%naive Calcium_based dynamics
%   Detailed explanation goes here

%% Default parameter values + unpacking params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

def_params = [...
    1000 ...        % T             total simu time     (ms)
    .3 ...          % rho_0         init syn strength
    .3 ...         % w_0
    1 ...           % C_pre
    2 ...           % C_post
    20 ...          % tau_Ca
    3 ...           % delay_pre
    1 ...           % theta_dep
    200 ...         % gamma_dep
    1.3 ...         % theta_pot
    321 ...         % gamma_pot
    150 ...         % tau_rho           syn plast time cst  (ms)
    1000 ...        % tau_w
    0.6 ...         % theta_act
    0 ...           % sigma
    ];

switch nargin
    case 0
        pre_spikes_hist = [];
        post_spikes_hist = [];
        params = def_params;
        int_scheme = 'euler_expl';
        int_step = 0.1;
    case 1
        post_spikes_hist = [];
        params = def_params;
        int_scheme = 'euler_expl';
        int_step = 0.1;
    case 2
        params = def_params;
        int_scheme = 'euler_expl';
        int_step = 0.1;
    case 3
        int_scheme = 'euler_expl';
        int_step = 0.1;
    case 4
        int_step = 0.1;
    case 5
    otherwise
        error('5 inputs max are accepted')
end

%%%%%%%%%%%%%%%%%%%%
% Unpacking params %
%%%%%%%%%%%%%%%%%%%%

T = params(1);
rho_0 = params(2);
w_0 = params(3);

step = int_step;
n_steps = T / step;

C_pre = params(4);
C_post = params(5);
tau_Ca = params(6);
delay_pre = params(7);

theta_dep = params(8);
gamma_dep = params(9);

theta_pot = params(10);
gamma_pot = params(11);

tau_rho = params(12);
tau_w = params(13);
theta_act = params(14);
sigma = params(15);

eq_thr = 1e-5;
S_attr = 40;
rho_max = 200;

%% Building events list based on calcium hypothesis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

len_pre = length(pre_spikes_hist);
len_post = length(post_spikes_hist);

evts = [];
simult_thr = 1e-6;

if len_pre > 0
    for pre_evtID=1:len_pre
        evts = cat(1, evts, [pre_spikes_hist(pre_evtID) + delay_pre, C_pre]);
    end
end

if len_post > 0
    for post_evtID=1:len_post
        evts = cat(1, evts, [post_spikes_hist(post_evtID),C_post]);
    end
end

evts = sortrows(evts, 1);

%% Simulating process
%%%%%%%%%%%%%%%%%%%%%

if strcmp(int_scheme, 'euler_expl')
    % Initiate simulation %
    %%%%%%%%%%%%%%%%%%%%%%%
    rho = params(2);
    w = params(3);
    t = 0;
    c = 0;
    
    rho_hist = rho;
    w_hist = w;
    c_hist = 0;

    % Check whether simulation is trivial %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(evts)
        rho_hist = rho_0 * ones(n_steps);
        w_f = zeta(rho);
        w_hist = (w_0-w_f)*exp(-step*(0:n_steps-1)/tau_w);
    else
        % Scheme propagation %
        %%%%%%%%%%%%%%%%%%%%%%
        while t < T
            c_hist = [c_hist, c];
            evt = find(and(t - double(evts(:,1)) <= int_step, t > double(evts(:,1))));
            if evt
                C_bump = sum(evts(evt,2));
                c = c + C_bump; 
            end
            
            rho = rho + step/tau_rho * (gamma_pot*(rho_max-rho)*(c > theta_pot) - gamma_dep*rho*(c > theta_dep)) * (c > theta_act);
            w_f = 0.5*erfc((S_attr-rho)/sqrt(2*sigma^2));
            w = w + step/tau_w * (w_f-w);
            
            rho_hist = [rho_hist, rho];
            w_hist = [w_hist; w];
            c = c * exp(-step/tau_Ca);
            t = t + step;
        end
    end     
        
else
	error('This integration scheme is not currently handled')
end

end
