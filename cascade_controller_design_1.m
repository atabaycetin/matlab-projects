clc
close all
clear all
format short

s = tf('s');

G = 2 / ( (1 + 0.2 * s) * (1 + 0.1 * s) );
T_s = 0.001;
G_ZOH = 1 / (1 + s * (T_s / 2));

K_G = dcgain(G);
pole(G); % G has no poles in 0, therefore K_0 = K_C

% r(t) = t * heaviside(t) -> h-type 1
% abs( rho / K_1 ) = 0.1
rho = 1;

% e_r <= 0.1 -> g = 1
% K_g = lim (s * L)
K_1 = 10;

% d_a = delta_a * heaviside(t) -> h-type 0
% y_d_a = 0 -> g_C = 1 or g_C = 2. Since g = 1 because of e_r, g_C = 1
% K_g_C = lim (s * C)

g_C = 1;
g = 1;
g_G = 0;

% G has no pole/zero with strictly positive real part => K_g = K_C * K_G > 0
% 10 = K_C * 2;
K_C = K_1 / K_G;

% K_C > 0

C_ss = K_C / s^g_C; % Steady State Controller = 5 / s
C = C_ss;
L_1 = C * G_ZOH * G;

% nyquist(L_1); No crossing of (-1, 0jw)

s_ = 30;
t_r = 0.3;

% From the tables (alternatively, the formulas can be used):
damp = 0.36;

T_p = 20 * log10(1.49);
S_p = 20 * log10(1.77);

% t_r * w_c = 1.82
% t_r * w_b = 2.95
w_c = 1.82 / t_r; % 6.07
w_b = 2.95 / t_r; % 9.84

% nichols(L_1)
% hold on
% T_grid(T_p)
% S_grid(S_p)

% phase = -172, gain = -1.1
% required phase between -137 and -145
% delta_phi = 35 - 27

% design lag network

w_w_z = 3;
w_z = 6.5 / w_w_z;

C_D = (1 + s / w_z);
C = C * C_D;
L_2 = C * G_ZOH * G;

% nichols(L_2)
% hold on
% T_grid(T_p)
% S_grid(S_p)

C_d = c2d(C, T_s, 'tustin');

% we can modify the values in the sim, or we can define them here
% and get the required values without dealing with the simulink file

% check steady state tracking error requirements
slope = 1;
step_value = 0;

delta_a = 0;
delta_t = 0;
delta_y = 0;
w_t = 0;

out = sim('AC_L15_Example_sim');
if max(out.e.Data) < 0.1
    disp("Steady state tracking error is less than 0.1 and equal to:")
    disp(max(out.e.Data))
else 
    disp("Steady state tracking error is more than 0.1")
    disp("The execution is stopping now")
    pause(2)
end

% Check steady state output error due to d_a requirements

slope = 0;
step_value = 0;

delta_a = 0.2;
delta_t = 0;
delta_y = 0;
w_t = 0;

out = sim('AC_L15_Example_sim');

if max(out.y_a.Data) == 0
    disp("Steady state output error due to d_a is equal to:")
    disp(max(out.y_a.Data))
else
    disp("Steady state output error due to d_a is NOT equal to 0")
    disp("The execution is stopping now")
    pause(2)
end

% Check overshoot and rise time requirements

slope = 0;
step_value = 1;

delta_a = 0;
delta_t = 0;
delta_y = 0;
w_t = 0;

out = sim('AC_L15_Example_sim');
overshoot = round(max(out.y.Data) - out.y.Data(end), 2)*100;
rise_time = stepinfo(out.y.Data, out.y.Time).RiseTime;

if overshoot <= 30
    disp("Overshoot is less than 30% and equal to:")
    disp(overshoot)
else
    disp("Overshoot is more than 30% and equal to:")
    disp(overshoot)
    disp("The execution is stopping now")
    pause(2)
end

if rise_time <= 0.3
    disp("Rise time is less than 0.3 seconds and equal to:")
    disp(rise_time)
else
    disp("Rise time is more than 0.3 seconds")
    disp("The execution is stopping now")
    pause(2)
end
