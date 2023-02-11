2/22/2023 - JOSEPH SKITKA - Joseph.Skitka@gmail.com

WARNING: do not attempt to use this code without understanding it first.  This is a very ugly / quick adapation to the following routines:

mom_vi_hdissip.F
mom_vi_del2uv.F

so that leith (approximately) only acts on the horizontally rotational part of the flow.  

WARNING: this code will only work of mom_vi_hdissip.F and mom_vi_del2uv.F are not used by any other part of the code.  Horizontal viscosity needs to be computed using the vector invariant formulation.  Otherwise this will not work!!
