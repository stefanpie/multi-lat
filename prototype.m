
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Promblem Setup

% Define all the initial conditions for the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define random number generator

rng(1);

% Define the sensor locations (in cm.)
A = [0,0];
B = [0,1];
C = [1,1];
D = [1,0];
E = [7.5, 18.2];
F = [.2, .8];

sensors = [A;B;C;D;E];

% Define the speed of sound in the material used (in m/s)

s = 4000;

% Define tap postion for simulation (in m)

tap = [.5, .32];

% Define simulated time delta for each sensor using tap location

distances = zeros(length(sensors),1);
for i = 1:length(sensors)
    distances(i) = norm(sensors(i,:) - tap());
end
time_deltas = distances./s;

time_deltas = time_deltas;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerical Method for Successive Iterations of Monte Carlo
% Sampling to Minimize Squared Error of Nonlinear Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Define initial sample area

x_min = -0.5;
x_max = 1.5;
y_min = -0.5;
y_max = 1.5;

% Define grid

density = 200;

[X,Y] = meshgrid(linspace(x_min,x_max,density), linspace(y_min,y_max,density));

% Define all combinations of sensors

% sensor_combinations = combnk(1:length(sensors),2);
sensor_combinations = nchoosek(1:length(sensors),2);

% Define difference in arival times

difference_in_arrival_times = zeros(length(sensor_combinations),1);

for c = 1:size(sensor_combinations,1)
    difference_in_arrival_times(c) = time_deltas(sensor_combinations(c,1)) - time_deltas(sensor_combinations(c,2));
end

% Calculate squared error for all points in sample area

sqaured_error_grid = zeros(density,density);

% Loop thought all sample points
for a = 1:density
    for b = 1:density
        
        x = X(a,b); % Get x-cordinate of sample point
        y = Y(a,b); % Get y-cordinate of sample point
        sampled_point = [x, y];
        
        squared_errors =  zeros(length(sensor_combinations),1);
        
        for c = 1:size(sensor_combinations,1) % For each combination pair of sensor points
            
            point_i = sensors(sensor_combinations(c,1),:);
            delta_i = time_deltas(sensor_combinations(c,1));
            
            point_j = sensors(sensor_combinations(c,2),:);
            delta_j = time_deltas(sensor_combinations(c,2));
            
            d_i = norm(sampled_point - point_i); % Distance from sensor i to sample point
            d_j = norm(sampled_point - point_j); % Distance to sensor j to sample point
            c_detlta_t = s * difference_in_arrival_times(c); % c * (t_1 - t_2)
            
            squared_errors(c) = ((d_i - d_j - c_detlta_t)).^2; % Store squared error of sampled point
        end
        
        squared_error = sum(squared_errors,'all') / length(squared_errors); % Sum all squared error of a sample point for all sensors
        sqaured_error_grid(a,b) = squared_error; % Store sum of squared errors for a sample point
        
    end
end

% Get the location of the sample point with the lowest sqaured error
min_value = min(sqaured_error_grid,[],'all');
min_index = sqaured_error_grid == min_value;
[r_id, c_id] = find( min_index );
min_point = [ X(r_id,c_id), Y(r_id,c_id)];

% Plot sqaured errors for all sample points using a 3D mesh plot
figure(1);
surf(X,Y,sqaured_error_grid, 'EdgeColor', 'none', 'FaceAlpha',0.75);

% Plot all the hyperbolic functions that represent the posslibe soltions to the tap point 
figure(2);
hold on;
grid on;
contourf(X,Y,sqaured_error_grid, 20, 'LineColor','none');
colormap((parula));
brighten(.5);

scatter(min_point(1),min_point(2), 'filled', 'black');
scatter(sensors(:,1),sensors(:,2), 'filled', 'black');
for c = 1:length(sensor_combinations)
    
    syms x_ y_
    
    point_i = sensors(sensor_combinations(c,1),:);

    point_j = sensors(sensor_combinations(c,2),:);

    d_i = sqrt((x_ - point_i(1))^2 + (y_ - point_i(2))^2);
    d_j = sqrt((x_ - point_j(1))^2 + (y_ - point_j(2))^2);
    c_detlta_t = s * difference_in_arrival_times(c);
    
    
    fimplicit(d_i - d_j  == c_detlta_t);
end
hold off;