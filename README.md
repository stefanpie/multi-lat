# multi_lat
MATLAB Implementations of 2D Multilateration Algorithms

This repository contains software that use 2D multilateration algorithms to determine the location of a sound source. This is part of a larger project I am currently on to use piezoelectric discs to turn any flat surface into a touch enabled surface using cheap and modular hardware. 

The main problem can be reduced to reducing the squared error of a set of hyperbolic equations derived from the differences in time of arrival of the sound to each disk; an optimization problem. I wanted to implement something that would not be computationally complex if needed to be implemented directly on the hardware or embedded system. I also wanted something simple to explain and implement as well as not have to use derivatives or gradients. The first method I implemented just calculates the error of a gird of evenly spaced pints and selects the minimum of all the points sampled. This is easy to code; however, requires a lot of computations depending on of the resolution of the grid you want to sample. The second method uses a direct search (also known as pattern search) optimization method. I specifically used the coordinate search method and half the search radius each time neighboring points did not decease the error. This is much more computationally efficient in the long run for higher accuracy calculations.

These algorithms will probably be rewritten in another language when actually implemented in the prototyping stage of this project. If you are interested in this idea/project, reach out to me.
