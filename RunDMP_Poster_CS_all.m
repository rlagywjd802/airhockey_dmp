clc
clear all
home

global R2D
global D2R
global l1
global l2
global dt
global tf
global ay
global by
global az
global w
global c
global h
global tau
global error_coupling
global n_dofs
global n_bfs
global goal
global y_0

% Variable for converting RADIAN -> DEGREE or DEGREE -> RADIAN %
R2D = 180/pi;
D2R = pi/180;

%-------------------------------------------%
% 0. Get Data
%-------------------------------------------%
% left hit(r)->left return(g)->
% right hit(b)->right return(m)->
% straight hit(k)->straight return(c)
q_d = load("back_js.txt");  % ------------------------------------------------> Set
dt = 0.001;
timestep = length(q_d);
tf = dt*(timestep-1);   
T = 0:dt:tf;

w = load("w_straight_back.txt"); % ----------------------------------------------------> Set
h = load("h_straight_back.txt");
c = load("c_straight_back.txt");


%-------------------------------------------%
% 1. Set the Parameters
%-------------------------------------------%

% Robot Parameters 
l1 = 0.2;
l2 = 0.2;

% Constant Parameters %     ----------------------------------------------------> Set
% % for right hit and left hit
% az = 1;
% ay = [7, 7];
% by = [7, 7];
% for straight hit
az = 0.5;
ay = [20, 10];
by = [20, 10];

% Canonical System %
tau = 1;
error = 0.0;
error_coupling = 1.0 / (1.0+error);

% DMP Parameters %
n_dofs = 2; % number of degree of freedom
n_bfs = 100; % number of basis function per DMP



%-------------------------------------------%
% 2. Define Points
%-------------------------------------------%
% left hit(r)->left return(g)->
% right hit(b)->right return(m)->
% straight hit(k)->straight return(c)
s = [0.052, 0.088];
v1 = [-0.196 ,0.187];   % puck point from camera
v2 = [0, 0.1];
v3 = [0.046 ,0.307];   % puck point from camera
v4 = [-0.024,0.1];
v5 = [-0.02 ,0.3];    % puck point from camera
g = [0, 0.1];


%-----------------------------------------------------------------------%
% 7. Set initial and goal Point
%-----------------------------------------------------------------------%
y_0 = v5;    %-------------------------------------------------------------------> Set
goal = g;

%-----------------------------------------------------------------------%
% 3. Generate trajectory to track
%   Output : y_t, dy_t, ddy_t -> Joint space
%-----------------------------------------------------------------------%
% Initialize tracking trajectory & goal
y_t = y_0; 
dy_t = zeros(n_dofs);
ddy_t = zeros(n_dofs); 
z_t = 1.0;
f_t = [0, 0];

% Iteration numbers
n = 1;        %Iterator for main loop
n_trj = 1;

% Plot Setting %
figure(1)
title('Animation')
grid
hold on
axis([-0.5 0.5 -0.5 0.5]);
   Ax1 = [0, l1];
   Ay1 = [0, 0];
   Ax2 = [l1, l1+l2];
   Ay2 = [0, 0];
   p1 = line(Ax1,Ay1,'LineWidth',[5],'Color','b');
   p2 = line(Ax2,Ay2,'LineWidth',[5],'Color','c');


% Robot Implementation 
for i = 0 : dt : tf
    
    % Run Canonical System %
    z_t = z_t + (-az*z_t*error_coupling)*tau*dt;  % [1]
    [y_t, dy_t, ddy_t, f_t] = dmp_step(z_t, y_t, dy_t, ddy_t);
    
    % Inverse Kinematics
    x2 = y_t(1);    y2 = y_t(2);
    [q1, q2] = IK(x2,y2);
    x1 = l1*cos(q1);    y1 = l1*sin(q1);        
    
    % Save the results of end-effector position, velocity, acceleration
	x1_save(n) = x2;      % Save the end-effector position
	x2_save(n) = y2;
    dx1_save(n) = dy_t(1);
    dx2_save(n) = dy_t(2);
    ddx1_save(n) = ddy_t(1);
    ddx2_save(n) = ddy_t(2);
    f1_save(n) = f_t(1);
    f2_save(n) = f_t(2);
    
    % Calculate the coordinates of robot geometry for animation 
	Ax1 = [0, x1];  
	Ay1 = [0, y1];
   	Ax2 = [x1, x2];   
	Ay2 = [y1, y2];
   
    % Update the animation
	if rem(n,5) == 0
        set(p1,'X', Ax1, 'Y',Ay1);
        set(p2,'X', Ax2, 'Y',Ay2);
        drawnow
    end
    %pause(0.1);    
  
    % Save 1st and 2nd joint's location, (x1, y1) and (x2, y2)
	if rem(n,1) == 0
        x_save(n_trj) = x2;
        y_save(n_trj) = y2;
        n_trj = n_trj + 1;        
    end
    
    % Increase the iteration number
	n=n+1;    

end

figure(2)
% title('Animation')
hold on
axis([-0.2 0.2 0 0.4]);
% Draw trajectory 
% left hit(r)->left return(g)->
% right hit(b)->right return(m)->
% straight hit(k)->straight return(c)
plot(x_save, y_save, 'c')   % ------------------------------------------------> Set
xlabel('x (m)')
ylabel('y (m)')