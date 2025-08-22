# This is a small test based on MITgcm/verification/isomip meant to
# demonstrate, diagnose, and find a fix for the supercooled waters found in
# the initial trillium llc1080 simulation.
 git clone git@github.com:MITgcm/MITgcm
 git clone git@github.com/MITgcm-contrib/llc_hires
 cd MITgcm
 mkdir build run
 cd build
 ../tools/genmake2 -mpi -mods ../../llc_hires/trillium/isomip/code
 make depend
 make -j
 cd ../run
 ln -sf ../build/mitgcmuv .
 cp ../../llc_hires/trillium/isomip/input/* .
 mpiexec -n 4 ./mitgcmuv
