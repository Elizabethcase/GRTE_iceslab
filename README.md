This code takes in glacier outlines and a DEM and generates ice thicknesses using a simple slab model. The methods are based on Florentine et al 2020.

**Dependencies**
- [TopoToolBox](https://topotoolbox.wordpress.com/download/) is required to run this code 

**Data**
The outlines included here as "GRTE_glacier_outlines.mat" are preliminary and from multiple sources, including Dan McGrath and Reynolds et al 2011.

Please contact me (ehc2150 [at] columbia [dot] edu) for the LiDAR DEM and [Dan McGrath](https://people.warnercnr.colostate.edu/?daniel.mcgrath) for the GPR data. 

**References**
1. Florentine C, Harper J, and Fagre, D. "Parsing complex terrain controls on mountain glacier response to climate forcing." 2020. Global and Planetary Change 191. [Link](https://doi.org/10.1016/j.gloplacha.2020.103209)
2. Reynolds H. "Recent Glacier Fluctuations in Grand Teton National Park, Wyoming." 2012. [Link.](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwip5ca7p9fzAhWDdd8KHfpWDvAQFnoECAMQAQ&url=https%3A%2F%2Fwww.nps.gov%2Fgrte%2Flearn%2Fnature%2Fupload%2FReynolds_Hazel_2011-opt-red.pdf&usg=AOvVaw2VuMkAHnhKwp2WLlD4FAdY)

**IceDepthVol_fromDEMandOutlines.m**
*Calculates ice thickness from DEM, outline of glacier using a simple slab model*

- Lines 1-10 load data. 
	- Line 5 loads GRTE_glacier_outlines.mat
	- Line 9 loads the DEM derived from LiDAR (file too large for github, please contact me)
- Lines 12-17 reduce the DEM resolution
	- Change the value for `res` on line 13 to increase or decrease the resolution
- Lines 19-40 plot the glacier outlines over the DEM
- Lines 44-45 get the slope and aspect across the whole DEM 
- Lines 47-71 plot the slope, aspect, and glacier outlines
- Lines 73-75 convert the slope and aspect into matrices
- Lines 79-128 calculate the thickness at all locations 
	- simple slab modeL: $d = \frac{\tau_b}{\rho_I g sin(\theta)}$ 
		- where $d$ is the thickness, $\tau_b$ is the yield strength at the base of the ice, $\rho_I$ is the ice density, $g$ is the gravitational constant, and $\theta$ is the slope of the ice
		- lines 80-82 set the constant values for the slab model
- The rest of the code plots the thickness and other values

**MiddleTetonModelvsGPR.m**
*Compares slab-derived thickness to GPR*
- Lines 1-20 load the data
- Lines 22-27 reduce the resolution of the DEM
- Lines 29-37 extract the aspect and slope from the DEM
- Lines 40-86 calculate thickness & volume for Middle Teton Glacier
- Lines 89 onward overlay the GPR depths on the slab-model-derived ice thickness
