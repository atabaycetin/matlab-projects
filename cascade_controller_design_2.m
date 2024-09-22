clc
clear all
close all
format short

s = tf('s');

G = 0.5 / (s * (1 + s));
T_s = .001;
G_ZOH = 1 / (1 + s * (T_s / 2));
K_G = dcgain(G*s);
g_G = 1;

delta_y = 2;
delta_a = 0;
delta_t = 0;
w_t = 0;



% e_r = 0 for r(t) = heaviside(t) => h-type = 0
rho = 1;
% g = 1 or g = 2;

% y_d_y <= 0.2 for d_y = delta_t * t * heaviside(t) => h-type 1
% g = 1 -> system is type 1
g = 1;

% g = g_C + g_G
g_C = g_G - g;

% y_d_y = 0.2 -> delta_y / K_1 = 0.2
K_1 = delta_y / 0.2;
K_g = K_1;

% G has no pole/zero with strictly positive real part 
% K_g = K_C * K_G > 0

K_C = K_g / K_G;

C_ss = K_C / s^g_C;

C = C_ss;
L_1 = C * G;

% Transient requirements
overshoot = 10;
t_s_1 = 2;

damp = 0.59;
T_p = 20 * log10(1.05);
S_p = 20 * log10(1.36);

% t_s_1 * w_c = 5.5;
w_c = 5.5 / t_s_1; % 2.75

% nichols(L_1)
% hold on
% T_grid(T_p)
% S_grid(S_p)

% phase = -162, gain = 0.511
% required between -132 and -108
% delta_phi between 54 and 30

m_d = 10;
w_w_d = 2;
w_d = w_c / w_w_d;

C_Z = (1 + (s / w_d)) / (1 + s / (m_d * w_d));
C = C * C_Z;

% nichols(L_2)
% hold on
% T_grid(T_p)
% S_grid(S_p)

% We need a gain adjustment
K_adj = -10^(30/20);

L_2 = C * G_ZOH * G * K_adj;

nichols(L_2)
hold on
T_grid(T_p)
S_grid(S_p)

C_d = c2d(C, T_s, 'zoh');

%% check steady state tracking error requirements

slope = 0;
step_value = 1;

delta_a = 0;
delta_t = 0;
delta_y = 0;
w_t = 0;

out = sim('cascade_controller_design_2_sim');

if abs(out.e.Data(end)) < 1e-05
    disp("Steady state tracking error is equal to:")
    disp(out.e.Data(end))
    fprintf("The value converges to 0!\n\n")
else
    disp("Steady state tracking error is more than 0")
    disp("The execution is stopping now")
    pause(2)
end

%% Check steady state output error due to d_y requirements

slope = 0;
step_value = 0;

delta_a = 0;
delta_t = 0;
delta_y = 2;
w_t = 0;

out = sim('cascade_controller_design_2_sim');

if out.y.Data(end) <= 0.2
    disp("Steady state output error due to d_y is less than 0.2 and equal to:")
    disp(out.y.Data(end))
else
    disp("Steady state output error due to d_y is more than 0.2")
    disp("The execution is stopping now")
    pause(2)
end

%% Check overshoot and settling time requirements

slope = 0;
step_value = 1;

delta_a = 0;
delta_t = 0;
delta_y = 0;
w_t = 0;

out = sim('cascade_controller_design_2_sim');

overshoot = stepinfo(out.y.Data, out.y.Time).Overshoot;

if overshoot <= 10
    disp("Overshoot is less than 10% and equal to:")
    fprintf("    %.2f%% \n\n", overshoot);
else
    disp("Overshoot is more than 10% and equal to:")
    disp(overshoot)
    disp("The execution is stopping now")
    pause(2)
end

settling_time = stepinfo(out.y.Data, out.y.Time).SettlingTime;
if settling_time <= 2
    disp("Settling time is less than 2 seconds and equal to:")
    disp(settling_time)
else
    disp("Settling time is more than 2 seconds")
    disp("The execution is stopping now")
    pause(2)
end











