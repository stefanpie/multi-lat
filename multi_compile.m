function tap_point = multi_compile(sensor_locations, arrival_times, speed_of_sound, search_area, search_grid_density)

% Define the sensor locations (in meters)
sensors = sensor_locations;

% Define the speed of sound in the material used (in m/s)

s = speed_of_sound;

% Define arival_times

time_deltas = arrival_times;



% Define initial sample area

x_min = search_area(1);
x_max = search_area(2);
y_min = search_area(3);
y_max = search_area(4);

% Define grid

density = search_grid_density;

[X,Y] = meshgrid(linspace(x_min,x_max,density), linspace(y_min,y_max,density));

% Define all combinations of sensors

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
            
            point_j = sensors(sensor_combinations(c,2),:);
            
            d_i = norm(sampled_point - point_i); % Distance from sensor i to sample point
            d_j = norm(sampled_point - point_j); % Distance to sensor j to sample point
            c_detlta_t = s * difference_in_arrival_times(c); % c * (t_1 - t_2)
            
            squared_errors(c) = ((d_i - d_j - c_detlta_t)).^2; % Store squared error of sampled point
        end
        
        squared_error = sum(squared_errors); % Sum all squared error of a sample point for all sensors
        sqaured_error_grid(a,b) = squared_error; % Store sum of squared errors for a sample point
        
    end
end

% Get the location of the sample point with the lowest sqaured error
min_value = min(min(sqaured_error_grid));
min_index = sqaured_error_grid == min_value;
[r_id, c_id] = find( min_index );
min_point = [ X(r_id,c_id), Y(r_id,c_id)];

tap_point = min_point;
end
