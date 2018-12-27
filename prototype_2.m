
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
F = [10, 15];

sensors = [A;B;C;D;E;F];

% Define the speed of sound in the material used (in m/s)

s = 4000;

% Define tap postion for simulation (in m)

tap = [8.567894, 14.335225];

% Define simulated time delta for each sensor using tap location

distances = zeros(length(sensors),1);
for i = 1:length(sensors)
    distances(i) = norm(sensors(i,:) - tap());
end
time_deltas = distances./s;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerical Method for Successive Iterations of Monte Carlo
% Sampling to Minimize Squared Error of Nonlinear Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Define initial sample area

x_min = -0.5;
x_max = 20;
y_min = -0.5;
y_max = 20;


% Define all combinations of sensors

% sensor_combinations = combnk(1:length(sensors),2);
sensor_combinations = nchoosek(1:length(sensors),2);

% Define difference in arival times

difference_in_arrival_times = zeros(length(sensor_combinations),1);

for c = 1:size(sensor_combinations,1)
    difference_in_arrival_times(c) = time_deltas(sensor_combinations(c,1)) - time_deltas(sensor_combinations(c,2));
end


number_of_itterations = 100;
cordinate_radius = 0.2;
scaling_factor = 1/2;

refrence_point = [(x_min + x_max)/2, (y_min + y_max)/2];

point_list = [refrence_point];
error_list = [];

for x = 1:number_of_itterations
    current_error = squared_error_multi(refrence_point, sensors, sensor_combinations, difference_in_arrival_times, s);
    error_list = [error_list, current_error];
    north = refrence_point + [0, cordinate_radius];
    south = refrence_point + [0, -cordinate_radius];
    east = refrence_point + [cordinate_radius, 0];
    west = refrence_point + [-cordinate_radius, 0];
    neighbors = [north;south;east;west];
    north_error = squared_error_multi(north, sensors, sensor_combinations, difference_in_arrival_times, s);
    south_error = squared_error_multi(south, sensors, sensor_combinations, difference_in_arrival_times, s);
    east_error = squared_error_multi(east, sensors, sensor_combinations, difference_in_arrival_times, s);
    west_error = squared_error_multi(west, sensors, sensor_combinations, difference_in_arrival_times, s);
    errors = [north_error; south_error; east_error; west_error];
    [M,I] = min(errors);
    if M < current_error
        refrence_point = neighbors(I,:);
        point_list = [point_list; refrence_point];
    elseif M > current_error
        cordinate_radius = cordinate_radius*scaling_factor;
    end
end

hold on;
figure(1);
scatter(refrence_point(1), refrence_point(2), 'filled', 'black');
scatter(sensors(:,1), sensors(:,2), 'filled', 'black');
plot(point_list(:,1), point_list(:,2), '-x');
figure(2);
plot([1:number_of_itterations], error_list, '-x');

% % Plot sqaured errors for all sample points using a 3D mesh plot
% figure(1);
% surf(X,Y,sqaured_error_grid, 'EdgeColor', 'none', 'FaceAlpha',0.75);
% 
% % Plot all the hyperbolic functions that represent the posslibe soltions to the tap point 
% figure(2);
% hold on;
% grid on;
% contourf(X,Y,sqaured_error_grid, 20, 'LineColor','none');
% colormap((parula));
% brighten(.5);
% 
% scatter(min_point(1),min_point(2), 'filled', 'black');
% scatter(sensors(:,1),sensors(:,2), 'filled', 'black');
% for c = 1:length(sensor_combinations)
%     
%     syms x_ y_
%     
%     point_i = sensors(sensor_combinations(c,1),:);
% 
%     point_j = sensors(sensor_combinations(c,2),:);
% 
%     d_i = sqrt((x_ - point_i(1))^2 + (y_ - point_i(2))^2);
%     d_j = sqrt((x_ - point_j(1))^2 + (y_ - point_j(2))^2);
%     c_detlta_t = s * difference_in_arrival_times(c);
%     
%     
%     fimplicit(d_i - d_j  == c_detlta_t);
% end
% hold off;




function squared_error = squared_error_multi(point, sensors, sensor_combinations, difference_in_arrival_times, s)
    sampled_point = point;

    squared_errors =  zeros(length(sensor_combinations),1);

    for c = 1:size(sensor_combinations,1) % For each combination pair of sensor points

        point_i = sensors(sensor_combinations(c,1),:);

        point_j = sensors(sensor_combinations(c,2),:);

        d_i = norm(sampled_point - point_i); % Distance from sensor i to sample point
        d_j = norm(sampled_point - point_j); % Distance to sensor j to sample point
        c_detlta_t = s * difference_in_arrival_times(c); % c * (t_1 - t_2)

        squared_errors(c) = ((d_i - d_j - c_detlta_t)).^2; % Store squared error of sampled point
    end

    squared_error = sum(squared_errors,'all') / length(squared_errors); % Sum all squared error of a sample point for all sensors
end