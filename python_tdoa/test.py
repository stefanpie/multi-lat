import numpy as np
import matplotlib.pyplot as plt
import itertools
import math
from pprint import pprint
from mpl_toolkits import mplot3d
from scipy.optimize import minimize


v = 3960
rec_time_noise_stdd = 1e-5

transmit_time = 3


def distance(p0, p1):
    return math.sqrt((p0[0] - p1[0])**2 + (p0[1] - p1[1])**2)

target_location = (6, 8)

sensors = np.array([[0, 0], [0, 20], [20, 20], [20, 0]])
print('sensors:', sensors)

distances = np.array([ ( (x[0]-target_location[0])**2 + (x[1]-target_location[1])**2 )**0.5 for x in sensors])
print('distances:', distances)
arrival_times = distances / v + transmit_time
arrival_times += np.random.normal(loc=0, scale=rec_time_noise_stdd, size=sensors.shape[0])
print('arrival_times:', arrival_times)

def create_hyperbolic_curve_function(s_0, s_1, t_0, t_1, v):
    def hyperbolic_curve_function(x, y):
        return np.sqrt(np.square(x-s_1[0]) + np.square(y-s_1[1])) - np.sqrt(np.square(x-s_0[0]) + np.square(y-s_0[1])) - v*(t_1-t_0)
    return hyperbolic_curve_function

hyperbolic_curve_functions = []

for i, j in itertools.combinations(range(sensors.shape[0]), 2):
    hyperbolic_curve_functions.append(create_hyperbolic_curve_function(sensors[i],sensors[j],arrival_times[i],arrival_times[j],v))

def total_error_function(x,y):
    partial_errors = []
    for f in hyperbolic_curve_functions:
        partial_errors.append(np.abs(f(x,y)))
    total_error = sum(partial_errors)
    return total_error

def total_error_function_mod(point):
    return total_error_function(point[0], point[1])


def cordinate_search_minimization(f, x_0, max_iter=100, initial_step_size=1):
    step_size = initial_step_size
    current_location = x_0
    for i in range(max_iter):
        north = [x_0[0], x_0[1]+step_size]
        south = [x_0[0], x_0[1]-step_size]
        east = [x_0[0]+step_size, x_0[1]]
        west = [x_0[0]-step_size, x_0[1]]
        adj_locations = [north,south,east,west]
        adj_errors = list(map(f, adj_locations))
        min_adj_error = min(adj_errors)
        min_adj_error_location = adj_locations[adj_errors.index(min(adj_errors))]

        current_location_error = f(current_location)
        if min_adj_error < current_location_error:
            current_location = min_adj_error_location
        else:
            step_size = step_size/2

    print(current_location)

cordinate_search_minimization(total_error_function_mod, [5,5])

# opt_points = []
# def log_opt(xk):
#     opt_points.append(xk)

# result = minimize(total_error_function_mod, [5,5], method="Nelder-Mead", callback=log_opt)
# opt_points = np.array(opt_points)
# print(opt_points)

# Plot sensors and target location
fig, ax = plt.subplots(figsize=(5,5))
ax.set_ylim((-2, 22))
ax.set_xlim((-2, 22))
for i in range(sensors.shape[0]):
    x = sensors[i][0]
    y = sensors[i][1]
    ax.scatter(x, y)
    ax.annotate('Sensor '+str(i), (x, y))
ax.scatter(target_location[0], target_location[1])
ax.annotate('Target', (target_location[0], target_location[1]))
ax.plot(opt_points[:,0], opt_points[:,1])

X, Y = np.mgrid[-2:22:50j, -2:22:50j]

p = ax.pcolormesh(X,Y,total_error_function(X,Y), alpha=0.3)
fig.colorbar(p, ax=ax)


for f in hyperbolic_curve_functions:
    plt.contour(X, Y, f(X, Y), levels=[0])
plt.show()




# fig = plt.figure()
# ax = plt.axes(projection='3d')
# ax.plot_surface(X, Y, total_error_function(X,Y), cmap='viridis', edgecolor='none')
# for f in hyperbolic_curve_functions:
#     plt.contour(X, Y, f(X, Y), levels=[0])
# plt.show()